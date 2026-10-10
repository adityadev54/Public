// Only extracted JPEG frames reach the local server. Detection and OCR run locally; optional AI review is handled separately.
export async function readFrame(imageDataUrl, signal) {
    const response = await fetch('/api/frames/read', {
        method: 'POST', headers: { 'Content-Type': 'application/json' }, signal,
        body: JSON.stringify({ imageBase64: imageDataUrl.split(',')[1] })
    });
    if (response.status === 404) throw new Error('Restart the terminal server with Ctrl+C, then dotnet watch run --launch-profile http, and reload this page.');
    const result = await response.json();
    if (!response.ok) throw new Error(result.error || 'Frame processing failed.');
    return result;
}

export async function linkTracks(frames, signal) {
    const response = await fetch('/api/tracks/link', {
        method: 'POST', headers: { 'Content-Type': 'application/json' }, signal,
        body: JSON.stringify({ frames: frames.map(frame => ({ timestamp: frame.timestamp, people: frame.people })) })
    });
    if (response.status === 404) throw new Error('Restart the terminal server to enable tracking, then analyze the video again.');
    const result = await response.json();
    if (!response.ok) throw new Error(result.error || 'Tracking failed.');
    return result;
}
