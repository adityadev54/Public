import './theme.js';
import { ChallengeWorkspace } from './challenge.js?v=feedback-1';
import { renderResearch } from './research.js';
import { VideoLibrary } from './library.js';
import { aiHeaders } from './session.js';
import { sourceMark } from './provenance.js';
import { reviewUncertainTracks } from './ai.js';
import { setAction } from './icons.js';
import { readFrame, linkTracks } from './api.js';
import { extractFrames } from './video.js';
import { numericReadings } from './evidence.js';
import { EvidenceReview } from './review.js';

const byId = id => document.getElementById(id);
let experiment = null, clipUrl = null, clipName = '', controller = null;
const library = new VideoLibrary(file => { if (controller) { library.message('Finish or cancel the analysis before changing videos.'); return; } loadClip(file); showView('lab'); });
const review = new EvidenceReview();
const challenge = new ChallengeWorkspace(() => experiment);
let visionRuntime = null;
const runtimeReady = fetch('/api/runtime').then(response => response.json()).then(runtime => {
    visionRuntime = runtime;
    if (!runtime.hosted) return;
    // Keep CPU runs short enough for trial hosting, including form resets.
    for (const option of [...byId('budget').options]) {
        if (Number(option.value) > 5) option.remove();
        else option.defaultSelected = option.value === '2';
    }
    byId('budget').value = '2';
    document.querySelector('.quick-guide').textContent = 'Choose a short clip → Start with 2 frames → Run analysis → Review number evidence.';
    byId('processingSource').replaceChildren(sourceMark('local', 'Server processing'));
    document.querySelector('.privacy-note').textContent = 'Selected frames are processed on the server. AI review sends selected crops to a cloud model.';
    byId('sourceLegend').replaceChildren(sourceMark('local', 'Server detection & OCR'), sourceMark('ai', 'AI review · marked tracks'));
});
byId('processingSource').append(sourceMark('local', 'Local processing'));
byId('sourceLegend').append(sourceMark('local', 'Local detection & OCR'), sourceMark('ai', 'AI review · only marked tracks'));
byId('openAiSettings').addEventListener('click', () => { byId('userMenu').hidePopover(); byId('aiSettingsDialog').showModal(); refreshAiStatus(); });
function closeAiSettings() { byId('aiKey').value = ''; byId('aiSettingsDialog').close(); }
byId('closeAiSettings').addEventListener('click', closeAiSettings);
byId('aiSettingsDialog').addEventListener('close', () => byId('aiKey').value = '');
// Only dismiss a pointer gesture that both starts and ends outside the dialog.
const settingsDialog = byId('aiSettingsDialog');
let backdropPointer = false;
function outsideDialog(event) {
    const bounds = settingsDialog.getBoundingClientRect();
    return event.clientX < bounds.left || event.clientX > bounds.right || event.clientY < bounds.top || event.clientY > bounds.bottom;
}
settingsDialog.addEventListener('pointerdown', event => backdropPointer = event.target === settingsDialog && outsideDialog(event));
settingsDialog.addEventListener('click', event => {
    if (backdropPointer && event.target === settingsDialog && outsideDialog(event)) closeAiSettings();
    backdropPointer = false;
});
async function refreshAiStatus() {
    try {
        const response = await fetch('/api/ai/status', { cache: 'no-store' });
        if (!response.ok) throw new Error();
        const status = await response.json();
        byId('aiConnection').textContent = status.configured ? 'AI ready' : 'AI disconnected';
        // Hosted visitors can inspect the connection without changing the owner's key.
        document.querySelector('.ai-key-controls').hidden = Boolean(status.managed);
        if (status.managed) {
            byId('keyStatus').textContent = status.configured
                ? 'Shared AI connection is ready. Enable AI review before analyzing.'
                : 'Shared AI connection is not configured. The workspace owner adds the key in Fly secrets.';
        }
    } catch {
        byId('aiConnection').textContent = 'Connection status unavailable.';
        byId('keyStatus').textContent = 'Could not check the connection. Close this dialog and try again.';
    }
}
refreshAiStatus();
// Credentials never enter experiment data, exports, or browser storage.
async function saveKey(clear = false) {
    const input = byId('aiKey');
    if (!clear && !input.value.trim()) { byId('keyStatus').textContent = 'Enter your API key first.'; return; }
    byId('saveAiKey').disabled = true; byId('clearAiKey').disabled = true;
    try {
        const response = await fetch('/api/ai/key', { method: 'POST', headers: await aiHeaders(),
            body: JSON.stringify({ key: clear ? '' : input.value }) });
        if (!response.ok) {
            const problem = await response.json().catch(() => ({}));
            throw new Error(problem.error || (response.status === 404 ? 'Restart the server to load key settings.' : 'Could not save key. Refresh and try again.'));
        }
        input.value = '';
        const status = await response.json();
        byId('aiConnection').textContent = status.configured ? 'AI ready' : 'AI disconnected';
        byId('keyStatus').textContent = status.configured ? 'Key saved until server restart. The next review checks model access.' : 'Key cleared.';
        if (!clear && status.configured) closeAiSettings();
    } catch (error) { byId('keyStatus').textContent = error.message; }
    finally { byId('saveAiKey').disabled = false; byId('clearAiKey').disabled = false; }
}
byId('saveAiKey').addEventListener('click', () => saveKey());
byId('clearAiKey').addEventListener('click', () => saveKey(true));
byId('aiKey').addEventListener('keydown', event => { if (event.key === 'Enter') { event.preventDefault(); saveKey(); } });
document.addEventListener('research-frame',event=>{
    if (!experiment?.frames[event.detail]) return;
    showView('lab'); review.showPane('frames'); review.selectFrame(event.detail);
    byId('video').currentTime=experiment.frames[event.detail].timestamp;
    byId('framePanel').scrollIntoView({block:'nearest'});
});
function showView(view) {
    for (const id of ['lab', 'plan', 'library', 'challenge']) byId(id).hidden = id !== view;
    document.querySelector('.header-subtitle').textContent = '/ ' + ({lab: 'Sports vision', plan: 'Research plan', library: 'Video library', challenge: 'AI, prove it'})[view];
    document.querySelectorAll('[data-view]').forEach(button => button.classList.toggle('active', button.dataset.view === view));
    if (view === 'plan') renderResearch(experiment);
    if (view === 'challenge') challenge.render();
    closeSidebar();
}
byId('challengeAnalyze').addEventListener('click', () => showView('lab'));
document.querySelectorAll('[data-view]').forEach(button => button.addEventListener('click', () => showView(button.dataset.view)));
function closeSidebar() {
    byId('sidebar').classList.remove('open'); byId('sidebarScrim').hidden = true;
    byId('menu').setAttribute('aria-expanded', 'false');
}
byId('menu').addEventListener('click', () => {
    const open = byId('sidebar').classList.toggle('open');
    byId('sidebarScrim').hidden = !open;
    byId('menu').setAttribute('aria-expanded', String(open));
});
byId('closeSidebar').addEventListener('click', closeSidebar);
byId('sidebarScrim').addEventListener('click', closeSidebar);
document.addEventListener('keydown', event => { if (event.key === 'Escape') closeSidebar(); });
function updateMetrics() {
    if (!experiment) return;
    const sightings = experiment.frames.reduce((sum, frame) => sum + frame.people.length, 0);
    const readable = experiment.frames.reduce((sum, frame) =>
        sum + frame.people.filter(person => numericReadings(person.readings).length).length, 0);
    byId('metrics').replaceChildren();
    // Sightings include repeated people across frames; they are not unique players.
    for (const [value, label] of [[experiment.frames.length, 'Frames processed'], [sightings, 'Person sightings'], [readable, 'Crops with readings']]) {
        const metric = document.createElement('div'); metric.className = 'metric';
        const number = document.createElement('strong'); number.textContent = value;
        const name = document.createElement('span'); name.textContent = label;
        metric.append(number, name); byId('metrics').append(metric);
    }
}
function clearClip() {
    byId('video').pause(); byId('video').removeAttribute('src'); byId('video').load();
    if (clipUrl) URL.revokeObjectURL(clipUrl);
    clipUrl = null; experiment = null; library.current = null; byId('saveClip').disabled = true;
    byId('video').hidden = true; byId('preview').hidden = false;
    byId('clipName').textContent = 'No video selected'; byId('sessionLabel').textContent = 'No video selected'; byId('results').hidden = true;
    review.reset();
}
function loadClip(file) {
    if (!file) return;
    if (!file.type.startsWith('video/') && !/\.(mp4|mov|webm|m4v)$/i.test(file.name)) {
        byId('notice').textContent = 'Choose a supported video file.'; return;
    }
    clearClip(); clipName = file.name; clipUrl = URL.createObjectURL(file);
    byId('video').src = clipUrl; byId('video').hidden = false; byId('preview').hidden = true;
    byId('clipName').textContent = file.name; byId('sessionLabel').textContent = file.name; byId('notice').textContent = 'Video ready. Select Analyze video to begin.';
    library.current = file; byId('saveClip').disabled = false;
}
byId('clipInput').addEventListener('change', event => loadClip(event.target.files[0]));
byId('video').addEventListener('error', () => byId('notice').textContent = 'This format could not play. Try an MP4 supported by your browser.');
byId('newSession').addEventListener('click', () => {
    controller?.abort(); clearClip(); byId('clipInput').value = ''; byId('experimentForm').reset();
    byId('notice').textContent = 'Choose a video to start.'; showView('lab');
});
byId('experimentForm').addEventListener('submit', async event => {
    event.preventDefault();
    if (controller) { controller.abort(); return; }
    if (!clipUrl) { byId('notice').textContent = 'Choose a video first, then run the analysis.'; return; }
    controller = new AbortController(); const signal = controller.signal;
    setAction(byId('run'), 'stop', 'Cancel analysis'); byId('clipInput').disabled = true; byId('newSession').disabled = true;
    byId('results').hidden = true; review.reset(); byId('aiSummary').textContent = ''; experiment = null; byId('metrics').replaceChildren();
    byId('progress').hidden = false; byId('progress').value = 0;
    try {
        await runtimeReady;
        if (!visionRuntime) throw new Error('Could not identify the processing engine. Refresh and try again.');
        const selection = await extractFrames(clipUrl, Number(byId('budget').value), byId('strategy').value, signal, (done, total) => {
            byId('notice').textContent = `Extracting frames: ${done}/${total}…`;
            byId('progress').value = done / total * 40;
        });
        experiment = {
            fileName: clipName, sport: byId("sport").value, engine: visionRuntime.engine === 'linux' ? 'SSDLite + EasyOCR CPU' : 'Apple Vision', processingLocation: visionRuntime.hosted ? 'server' : 'local', strategy: byId('strategy').value,
            duration: selection.duration, width: selection.width, height: selection.height,
            framesSampled: selection.sampled, ocrCalls: 0, frames: []
        };
        for (const [index, frame] of selection.frames.entries()) {
            byId('notice').textContent = `Detecting people and reading their jerseys: frame ${index + 1}/${selection.frames.length}…`;
            const result = await readFrame(frame.image, signal);
            const evidence = {
                ...frame, readings: result.readings,
                candidates: numericReadings(result.readings), people: result.people || [], annotation: ''
            };
            experiment.frames.push(evidence); experiment.ocrCalls++;
            review.update(experiment); if (!byId('plan').hidden) renderResearch(experiment); updateMetrics(); byId('results').hidden = false;
            byId('summary').textContent = `${clipName} · ${selection.duration.toFixed(1)}s · ${experiment.ocrCalls} frames processed · person detection + OCR`;
            byId('progress').value = 40 + (index + 1) / selection.frames.length * 55;
        }
        byId('notice').textContent = 'Linking player detections and combining number evidence…';
        const tracking = await linkTracks(experiment.frames, signal);
        experiment.tracking = tracking;
        if (byId('aiEnabled').checked) {
            byId('notice').textContent = 'Reviewing selected uncertain tracks with AI…';
            try {
                experiment.ai = await reviewUncertainTracks(experiment, Number(byId('aiBudget').value), signal);
                const ai = experiment.ai;
                const suggestions = ai.answers.filter(answer => answer.status === 'reviewed' && answer.isPlayer === true && answer.number !== null).length;
                byId('aiSummary').textContent = `AI: ${ai.calls} calls · ${(ai.calls / (experiment.duration / 60)).toFixed(1)} calls/min · ${suggestions} unverified number suggestions · ${ai.inputTokens + ai.outputTokens} tokens. ${ai.answers.some(answer => answer.status === 'error') ? 'Some reviews failed; see track details.' : ''}`;
            } catch (error) {
                if (error.name === 'AbortError') throw error;
                experiment.ai = { status: 'error', error: error.message };
                byId('aiSummary').textContent = `AI review unavailable: ${error.message} Local results are retained.`;
            }
        } else byId('aiSummary').textContent = 'Local baseline only · AI review disabled.';
        review.update(experiment, true); if (!byId('plan').hidden) renderResearch(experiment);
        byId('progress').value = 100;
        byId('notice').textContent = 'Analysis complete. Review tracks or frame evidence.';
    } catch (error) {
        byId('notice').textContent = error.name === 'AbortError' ? 'Analysis canceled. Completed frame evidence remains available.' : error.message;
    } finally {
        controller = null; setAction(byId('run'), 'play', 'Analyze video'); byId('clipInput').disabled = false; byId('newSession').disabled = false;
        byId('progress').hidden = true;
    }
});
byId('export').addEventListener('click', () => {
    if (!experiment) return;
    // Export measured evidence and human labels, excluding large image payloads.
    const report = { ...experiment, frames: experiment.frames.map(({ image, ...frame }) => frame) };
    const url = URL.createObjectURL(new Blob([JSON.stringify(report, null, 2)], { type: 'application/json' }));
    const link = document.createElement('a'); link.href = url; link.download = 'touchline-frame-evidence.json'; link.click();
    setTimeout(() => URL.revokeObjectURL(url), 1000);
});

byId('sport').addEventListener('change', () => {
    document.querySelector('h1').textContent = byId('sport').value === 'american-football' ? 'American football analysis' : 'Soccer analysis';
});
