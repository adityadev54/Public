import { sourceMark } from './provenance.js';
import { setAction } from './icons.js';
import { numericReadings } from './evidence.js';

const byId = id => document.getElementById(id);
const tracksPerPage = 6;

// Render a bounded slice of evidence. All frames and annotations stay in the experiment.
export class EvidenceReview {
    constructor() {
        this.experiment = null;
        this.frameIndex = 0;
        this.trackPage = 0;
        this.focusTrack = null;
        this.pane = 'frames';
        byId('tracksTab').addEventListener('click', () => this.showPane('tracks'));
        byId('framesTab').addEventListener('click', () => this.showPane('frames'));
        for (const [id, direction] of [['prevTracks', -1], ['nextTracks', 1]])
            byId(id).addEventListener('click', () => { this.trackPage += direction; this.renderTracks(); });
        for (const [id, direction] of [['prevFrame', -1], ['nextFrame', 1]])
            byId(id).addEventListener('click', () => this.selectFrame(this.frameIndex + direction));
        byId('trackFilter').addEventListener('change', () => { this.trackPage = 0; this.renderTracks(); });
        byId('frameSelect').addEventListener('change', event => this.selectFrame(Number(event.target.value)));
        byId('readingsOnly').addEventListener('change', () => this.renderFrame());
        // Tabs work with keyboard arrows as well as clicks.
        for (const id of ['tracksTab', 'framesTab']) byId(id).addEventListener('keydown', event => {
            if (!['ArrowLeft', 'ArrowRight'].includes(event.key)) return;
            event.preventDefault();
            const pane = this.pane === 'tracks' ? 'frames' : 'tracks';
            if (pane === 'tracks' && !this.experiment?.tracking) return;
            this.showPane(pane); byId(pane === 'tracks' ? 'tracksTab' : 'framesTab').focus();
        });
    }

    reset() {
        this.experiment = null; this.frameIndex = 0; this.trackPage = 0; this.focusTrack = null;
        byId('trackFilter').value = 'all'; byId('readingsOnly').checked = false;
        byId('frames').replaceChildren(); byId('trackRows').replaceChildren();
        byId('sourcePanel').open = true; document.body.classList.remove('has-results');
        this.showPane('frames');
    }

    update(experiment, completed = false) {
        this.experiment = experiment;
        byId('tracksTab').disabled = !experiment.tracking;
        byId('frameSelect').replaceChildren();
        experiment.frames.forEach((frame, index) => {
            const option = document.createElement('option'); option.value = index;
            option.textContent = `Frame ${index + 1} · ${frame.timestamp.toFixed(2)}s`;
            byId('frameSelect').append(option);
        });
        if (completed) {
            // Store associations in data once; rendering no longer walks hundreds of crop nodes.
            for (const track of experiment.tracking.tracks) for (const observation of track.observations) {
                const frame = experiment.frames.find(frame => frame.timestamp === observation.timestamp);
                const person = frame?.people.find(person => person.id === observation.personId);
                if (person) person.trackId = track.id;
            }
            document.body.classList.add('has-results'); byId('sourcePanel').open = false;
            this.showPane('tracks');
        } else if (this.pane === 'frames') this.renderFrame();
    }

    showPane(pane) {
        if (pane === 'tracks' && !this.experiment?.tracking) pane = 'frames';
        this.pane = pane;
        for (const name of ['tracks', 'frames']) {
            const tab = byId(`${name}Tab`); const selected = name === pane;
            tab.setAttribute('aria-selected', String(selected)); tab.tabIndex = selected ? 0 : -1;
        }
        byId('trackResults').hidden = pane !== 'tracks'; byId('framePanel').hidden = pane !== 'frames';
        if (pane === 'tracks') this.renderTracks(); else this.renderFrame();
    }

    renderTracks() {
        if (!this.experiment?.tracking) return;
        const all = this.experiment.tracking.tracks;
        const filter = byId('trackFilter').value;
        const tracks = all.filter(track => filter === 'supported' ? track.number !== null : filter === 'multiple' ? track.sightings > 1 : true);
        const pages = Math.max(1, Math.ceil(tracks.length / tracksPerPage));
        this.trackPage = Math.max(0, Math.min(this.trackPage, pages - 1));
        byId('trackSummary').textContent = `${all.length} provisional tracks · ${all.filter(track => track.number !== null).length} with repeated support`;
        byId('trackRows').replaceChildren();
        const start = this.trackPage * tracksPerPage;
        for (const track of tracks.slice(start, start + tracksPerPage)) {
            const row = document.createElement('tr');
            const id = document.createElement('td'); id.textContent = `T${String(track.id).padStart(2, '0')}`;
            const evidence = document.createElement('td'); evidence.textContent = track.number === null ? track.numberStatus : `#${track.number} · repeated`;
            const details = document.createElement('small');
            details.textContent = track.candidates.map(candidate => `#${candidate.number}: ${candidate.observations} readings`).join(' / '); evidence.prepend(sourceMark('local', 'Local OCR')); evidence.append(details);
            if (track.aiReview) {
                const ai = document.createElement('small');
                ai.textContent = track.aiReview.status === 'error' ? `AI: ${track.aiReview.explanation}` :
                    `AI: ${track.aiReview.number === null ? 'abstained' : '#' + track.aiReview.number + ' · unverified'} · ${track.aiReview.explanation}`;
                evidence.append(sourceMark('ai', track.aiReview.status === 'error' ? 'AI request failed' : 'AI reviewed'), ai);
            }
            const sightings = document.createElement('td'); sightings.textContent = track.sightings;
            const interval = document.createElement('td'); interval.textContent = `${track.firstSeen.toFixed(1)}–${track.lastSeen.toFixed(1)}s`;
            const action = document.createElement('td'); const button = document.createElement('button');
            button.className = 'btn btn-dark btn-sm'; setAction(button, 'eye', 'Review');
            button.setAttribute('aria-label', `Review track ${track.id}`);
            button.addEventListener('click', () => {
                this.focusTrack = track.id;
                byId('readingsOnly').checked = false;
                this.frameIndex = this.experiment.frames.findIndex(frame => frame.timestamp === track.firstSeen);
                byId('video').currentTime = track.firstSeen;
                this.showPane('frames');
            });
            action.append(button); row.append(id, evidence, sightings, interval, action); byId('trackRows').append(row);
        }
        if (!tracks.length) {
            const row = document.createElement('tr'); const cell = document.createElement('td'); cell.colSpan = 5;
            cell.textContent = 'No tracks match this filter.'; row.append(cell); byId('trackRows').append(row);
        }
        byId('trackPage').textContent = tracks.length ? `${start + 1}–${Math.min(start + tracksPerPage, tracks.length)} of ${tracks.length}` : '0 tracks';
        byId('prevTracks').disabled = this.trackPage === 0;
        byId('nextTracks').disabled = this.trackPage >= pages - 1;
    }

    selectFrame(index) {
        this.frameIndex = index; this.focusTrack = null; this.renderFrame();
    }

    renderFrame() {
        const frames = this.experiment?.frames || [];
        byId('frames').replaceChildren();
        if (!frames.length) return;
        this.frameIndex = Math.max(0, Math.min(this.frameIndex, frames.length - 1));
        const frame = frames[this.frameIndex];
        byId('frameSelect').value = String(this.frameIndex);
        byId('framePage').textContent = `${this.frameIndex + 1} of ${frames.length} frames`;
        byId('prevFrame').disabled = this.frameIndex === 0;
        byId('nextFrame').disabled = this.frameIndex === frames.length - 1;
        const card = document.createElement('article'); card.className = 'frame-card';
        const visual = document.createElement('div'); visual.className = 'frame-visual';
        const image = document.createElement('img'); image.alt = `Frame at ${frame.timestamp.toFixed(2)} seconds`;
        const heading = document.createElement('strong'); heading.textContent = `${frame.timestamp.toFixed(2)}s · ${frame.people.length} person sightings`;
        const note = document.createElement('p'); note.textContent = 'Review crops and verify the number. Track IDs are provisional.';
        visual.append(sourceMark('local', 'Local frame & detection'), image, heading, note); card.append(visual);
        const list = document.createElement('div'); list.className = 'player-grid'; card.append(list);
        const people = frame.people.filter(person => !byId('readingsOnly').checked || numericReadings(person.readings).length);
        if (!people.length) { const message = document.createElement('p'); message.className = 'filter-empty'; message.textContent = 'No matching crops. Turn off Readings only to review all detections.'; list.append(message); }
        // Attach before setting src, so cached frames cannot miss the load handler.
        image.addEventListener('load', () => {
            if (!card.isConnected) return;
            for (const person of people) {
                const tile = document.createElement('div'); tile.className = 'player-tile';
                tile.classList.toggle('focused-track', person.trackId === this.focusTrack);
                const canvas = document.createElement('canvas');
                canvas.width = Math.max(1, Math.round(person.width * image.naturalWidth));
                canvas.height = Math.max(1, Math.round(person.height * image.naturalHeight));
                canvas.getContext('2d').drawImage(image, person.x * image.naturalWidth, person.y * image.naturalHeight,
                    person.width * image.naturalWidth, person.height * image.naturalHeight, 0, 0, canvas.width, canvas.height);
                const label = document.createElement('strong'); label.textContent = person.trackId ? `T${String(person.trackId).padStart(2, '0')} · P${person.id}` : `Person ${person.id}`;
                const numbers = numericReadings(person.readings); tile.classList.toggle('has-reading', numbers.length > 0);
                const reading = document.createElement('p'); reading.textContent = numbers.length ? numbers.map(item => `#${item.text} · ${Math.round(item.confidence * 100)}% OCR`).join(' / ') : 'Number unreadable';
                const input = document.createElement('input'); input.className = 'form-control form-control-sm'; input.placeholder = 'Verify number'; input.maxLength = 20;
                input.value = person.annotation || '';
                input.setAttribute('aria-label', `Verified number for person ${person.id} at ${frame.timestamp.toFixed(2)} seconds`);
                input.addEventListener('input', () => person.annotation = input.value.trim());
                const reference = document.createElement('input'); reference.className='form-control form-control-sm'; reference.placeholder='Reference ID (e.g. A)'; reference.maxLength=30; reference.value=person.referenceId || '';
                reference.setAttribute('aria-label', `Reference identity for person ${person.id} at ${frame.timestamp.toFixed(2)} seconds`);
                reference.addEventListener('input',()=>person.referenceId=reference.value.trim());
                tile.append(canvas, label, sourceMark('local', 'Local OCR'), reading, input, reference); list.append(tile);
            }
            list.querySelector('.focused-track')?.scrollIntoView({ block: 'nearest', inline: 'nearest' });
        }, { once: true });
        byId('frames').append(card); image.src = frame.image;
    }
}
