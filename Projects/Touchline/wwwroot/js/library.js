// Browser-local IndexedDB stores video blobs, not paths or cloud uploads.
export class VideoLibrary {
    constructor(openVideo) {
        this.openVideo = openVideo; this.current = null;
        this.database = new Promise((resolve, reject) => {
            const request = indexedDB.open('touchline-library', 1);
            request.onupgradeneeded = () => request.result.createObjectStore('videos', { keyPath: 'id' });
            request.onsuccess = () => resolve(request.result); request.onerror = () => reject(request.error);
        });
        document.getElementById('libraryInput').addEventListener('change', async event => {
            for (const file of event.target.files) await this.save(file);
            event.target.value = '';
        });
        document.getElementById('saveClip').addEventListener('click', () => this.current && this.save(this.current));
        document.getElementById('showRemoved').addEventListener('change', () => this.render());
        this.render();
    }
    async records() {
        const db = await this.database;
        return new Promise((resolve, reject) => {
            const request = db.transaction('videos').objectStore('videos').getAll();
            request.onsuccess = () => resolve(request.result); request.onerror = () => reject(request.error);
        });
    }
    async put(record) {
        const db = await this.database;
        return new Promise((resolve, reject) => {
            const transaction = db.transaction('videos', 'readwrite');
            transaction.objectStore('videos').put(record);
            transaction.oncomplete = resolve; transaction.onerror = () => reject(transaction.error);
            transaction.onabort = () => reject(transaction.error);
        });
    }
    message(text) { document.getElementById('libraryStatus').textContent = text; }
    async save(file) {
        try {
            if (!file.type.startsWith('video/') && !/\.(mp4|mov|webm|m4v)$/i.test(file.name)) throw Error('Choose a supported video.');
            if (file.size === 0) throw Error('This file is empty. Choose the original video file.');
            if (file.size > 250 * 1024 * 1024) throw Error('Use a clip smaller than 250 MB for the video library.');
            const records = await this.records(); const id = `${file.name}:${file.size}:${file.lastModified}`;
            const existing = records.find(record => record.id === id);
            if (existing && !existing.removed) { this.message('Already saved in your library.'); return; }
            if (records.filter(record => !record.removed).length >= 5) throw Error('Library holds five active clips. Remove one to make room.');
            if (records.filter(record => record.id !== id).reduce((sum, record) => sum + record.file.size, file.size) > 750 * 1024 * 1024) throw Error('Library storage limit reached (750 MB including removed clips).');
            await this.put({ id, file, name: file.name, added: existing?.added || Date.now(), removed: false });
            this.message('Video saved locally.'); await this.render();
        } catch (error) { this.message(error.name === 'QuotaExceededError' ? 'Browser storage is full. Try a smaller clip.' : error.message); }
    }
    async render() {
        try {
            const records = await this.records(); const list = document.getElementById('libraryList'); list.replaceChildren();
            document.getElementById('libraryCount').textContent = `${records.filter(record => !record.removed).length} / 5 videos`;
            for (const record of records.filter(record => !record.removed || document.getElementById('showRemoved').checked).sort((a,b) => b.added - a.added)) {
                const card = document.createElement('article'); card.className = 'library-card';
                const title = document.createElement('h2'); title.textContent = record.name;
                const size = document.createElement('p'); size.textContent = `${(record.file.size / 1024 / 1024).toFixed(1)} MB · ${record.removed ? 'Removed' : 'Saved on this browser'}`;
                const actions = document.createElement('div'); actions.className = 'key-actions';
                if (!record.removed) {
                    const open = document.createElement('button'); open.className = 'btn btn-light'; open.textContent = 'Use video';
                    open.addEventListener('click', () => this.openVideo(record.file)); actions.append(open);
                }
                const remove = document.createElement('button'); remove.className = 'btn btn-dark'; remove.textContent = record.removed ? 'Restore' : 'Remove';
                remove.addEventListener('click', async () => {
                    try {
                        if (record.removed && records.filter(item => !item.removed).length >= 5) throw Error('Remove an active clip before restoring.');
                        await this.put({ ...record, removed: !record.removed }); await this.render();
                    } catch (error) { this.message(error.message); }
                }); actions.append(remove); card.append(title, size, actions); list.append(card);
            }
            if (!list.children.length) { const empty = document.createElement('p'); empty.textContent = 'Add a video, then choose Use video to analyze it.'; list.append(empty); }
        } catch { this.message('Local browser storage is unavailable. You can still choose a video directly.'); }
    }
}
