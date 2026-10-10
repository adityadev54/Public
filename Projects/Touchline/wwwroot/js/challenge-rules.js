import { numericReadings } from './evidence.js';
// Conservative scoring: ambiguous readings never count as a successful deception.
export function jerseyReading(person) {
    const values = [...new Set(numericReadings(person?.readings || [])
        .filter(reading => reading.confidence >= .4).map(reading => Number(reading.text)))];
    return values.length === 1 ? values[0] : null;
}
export function overlap(a, b) {
    const area = Math.max(0, Math.min(a.x+a.width,b.x+b.width)-Math.max(a.x,b.x)) *
        Math.max(0, Math.min(a.y+a.height,b.y+b.height)-Math.max(a.y,b.y));
    return area / (a.width*a.height+b.width*b.height-area || 1);
}
export function matchingPlayer(target, people) {
    const matches = people.map(person => ({person, score:overlap(target,person)})).sort((a,b)=>b.score-a.score);
    return matches[0]?.score >= .35 && (!matches[1] || matches[0].score-matches[1].score >= .1) ? matches[0].person : null;
}
