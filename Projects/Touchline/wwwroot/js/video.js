import { sampleWindow } from './frame-selection.js';

// Decode actual video frames using the browser's built-in media decoder.
function waitFor(video, event, signal) {
    return new Promise((resolve, reject) => {
        const timeout = setTimeout(() => finish(new Error('Video decoding timed out. Try a supported MP4.')), 15000);
        const done = () => finish();
        const error = () => finish(new Error('The video could not be decoded.'));
        const abort = () => finish(new DOMException('Canceled', 'AbortError'));
        function finish(problem) {
            clearTimeout(timeout);
            video.removeEventListener(event, done); video.removeEventListener('error', error);
            signal.removeEventListener('abort', abort);
            problem ? reject(problem) : resolve();
        }
        video.addEventListener(event, done, { once: true });
        video.addEventListener('error', error, { once: true });
        signal.addEventListener('abort', abort, { once: true });
        if (signal.aborted) abort();
    });
}
function sharpness(canvas) {
    const small = document.createElement('canvas'); small.width = 160; small.height = 90;
    const context = small.getContext('2d', { willReadFrequently: true });
    context.drawImage(canvas, 0, 0, 160, 90);
    const { data } = context.getImageData(0, 0, 160, 90);
    let score = 0;
    for (let y = 1; y < 89; y++) for (let x = 1; x < 159; x++) {
        const i = (y * 160 + x) * 4;
        score += Math.abs(data[i] * 4 - data[i - 4] - data[i + 4] - data[i - 640] - data[i + 640]);
    }
    return score / (158 * 88);
}
export async function extractFrames(url, count, strategy, signal, onProgress) {
    const decoder = document.createElement('video'); decoder.preload = 'auto'; decoder.muted = true;
    try {
        const ready = waitFor(decoder, 'loadeddata', signal); decoder.src = url; await ready;
        if (!Number.isFinite(decoder.duration) || decoder.duration <= 0) throw new Error('Video duration is unavailable.');
        const samples = strategy === 'selective' ? Math.min(count * 4, 80) : count;
        const canvas = document.createElement('canvas');
        const scale = Math.min(1, 3840 / decoder.videoWidth);
        canvas.width = Math.round(decoder.videoWidth * scale); canvas.height = Math.round(decoder.videoHeight * scale);
        const context = canvas.getContext('2d'); const frames = [];
        // Keep one best frame per time window, preserving coverage and bounding image memory.
        for (let i = 0; i < samples; i++) {
            const timestamp = decoder.duration * (i + 0.5) / samples;
            const sought = waitFor(decoder, 'seeked', signal); decoder.currentTime = timestamp; await sought;
            context.drawImage(decoder, 0, 0, canvas.width, canvas.height);
            const frame = { timestamp, sharpness: sharpness(canvas) };
            const window = strategy === 'selective' ? sampleWindow(i, samples, count) : i;
            if (!frames[window] || frame.sharpness > frames[window].sharpness) {
                frames[window] = { ...frame, image: canvas.toDataURL('image/jpeg', 0.92) };
            }
            onProgress(i + 1, samples);
        }
        return {
            duration: decoder.duration, width: decoder.videoWidth, height: decoder.videoHeight,
            sampled: samples, frames: frames.slice(0, count).sort((a, b) => a.timestamp - b.timestamp)
        };
    } finally { decoder.removeAttribute('src'); decoder.load(); }
}
