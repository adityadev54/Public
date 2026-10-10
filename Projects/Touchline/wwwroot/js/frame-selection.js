// Assign candidates to consecutive time windows instead of clustering global sharpness peaks.
export function sampleWindow(index, samples, count) {
    return Math.min(count - 1, Math.floor(index * count / samples));
}
