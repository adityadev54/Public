import { aiHeaders } from './session.js';
// Trigger one review per uncertain track. Keep baseline evidence unchanged for comparison.
export function selectReviews(experiment, budget) {
    const priorities = { 'Conflicting readings': 0, 'Unreadable': 1, 'Single reading': 2 };
    return experiment.tracking.tracks.filter(track => track.number === null)
        .sort((a, b) => priorities[a.numberStatus] - priorities[b.numberStatus] || b.sightings - a.sightings || a.id - b.id)
        .slice(0, Math.max(0, Math.min(5, budget)));
}
async function bestCrop(experiment, track) {
    const candidates = track.observations.map(observation => {
        const frame = experiment.frames.find(frame => frame.timestamp === observation.timestamp);
        const person = frame.people.find(person => person.id === observation.personId);
        // Area and measured frame sharpness favor a larger, clearer view.
        return { frame, person, score: person.width * person.height * Math.max(1, frame.sharpness || 1) };
    }).sort((a, b) => b.score - a.score);
    const { frame, person } = candidates[0];
    const image = new Image(); image.src = frame.image; await image.decode();
    const width = Math.max(1, Math.round(person.width * image.naturalWidth));
    const height = Math.max(1, Math.round(person.height * image.naturalHeight));
    const scale = Math.min(2, 640 / Math.max(width, height));
    const canvas = document.createElement('canvas'); canvas.width = Math.max(1, Math.round(width * scale)); canvas.height = Math.max(1, Math.round(height * scale));
    canvas.getContext('2d').drawImage(image, person.x * image.naturalWidth, person.y * image.naturalHeight, width, height, 0, 0, canvas.width, canvas.height);
    return { trackId: track.id, timestamp: frame.timestamp,
        trigger: track.numberStatus === 'Conflicting readings' ? 'conflicting-readings' : track.numberStatus === 'Unreadable' ? 'unreadable' : 'single-reading',
        imageBase64: canvas.toDataURL('image/jpeg', .9).split(',')[1] };
}
export async function reviewUncertainTracks(experiment, budget, signal) {
    const selected = selectReviews(experiment, budget);
    if (!selected.length) return { model: null, calls: 0, inputTokens: 0, outputTokens: 0, answers: [] };
    const crops = [];
    for (const track of selected) { signal.throwIfAborted(); crops.push(await bestCrop(experiment, track)); }
    const response = await fetch('/api/ai/review', { method: 'POST', headers: await aiHeaders(), body: JSON.stringify({ crops, sport: experiment.sport || "soccer" }), signal });
    const result = await response.json();
    if (!response.ok) throw new Error(result.error || 'AI review failed.');
    for (const answer of result.answers) {
        const track = experiment.tracking.tracks.find(track => track.id === answer.trackId);
        track.aiReview = answer;
        track.mergedNumber = track.number ?? (answer.status === 'reviewed' && answer.isPlayer === true ? answer.number : null);
        track.mergedSource = track.number !== null ? 'repeated OCR' : track.mergedNumber !== null ? 'AI suggestion · unverified' : 'unresolved';
    }
    return result;
}
