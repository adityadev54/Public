import assert from 'node:assert/strict';
import { sampleWindow } from '../wwwroot/js/frame-selection.js';
// Both divisible and uneven candidate counts must cover every chronological window.
for (const [samples, count] of [[8, 2], [48, 12], [80, 24], [80, 40]]) {
    const groups = Array.from({length: samples}, (_, i) => sampleWindow(i, samples, count));
    assert.equal(new Set(groups).size, count);
    assert.ok(groups.every((group, i) => i === 0 || group >= groups[i - 1]));
    assert.ok(groups.every(group => group >= 0 && group < count));
}
// A very sharp final window cannot displace earlier time windows.
const scores = [1, 2, 3, 4, 100, 200, 300, 400];
const selected = [];
scores.forEach((score, i) => {
    const window = sampleWindow(i, scores.length, 2);
    if (!selected[window] || score > selected[window].score) selected[window] = {i, score};
});
assert.deepEqual(selected.map(frame => frame.i), [3, 7]);
console.log('Passed sampling checks: chronological coverage, uneven windows, clustered sharpness.');
