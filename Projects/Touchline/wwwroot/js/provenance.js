// Touchline source marks: a framed point for local processing, a woven diamond for AI.
export function sourceMark(source, label) {
    const badge = document.createElement('span'); badge.className = `source-mark source-${source}`;
    const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
    svg.setAttribute('viewBox', '0 0 24 24'); svg.setAttribute('aria-hidden', 'true');
    svg.innerHTML = source === 'ai'
        ? '<path d="M12 2 22 12 12 22 2 12Z M12 6 18 12 12 18 6 12Z" fill="none" stroke="currentColor" stroke-width="1.5"/><circle cx="12" cy="12" r="2" fill="currentColor"/>'
        : '<rect x="6" y="6" width="12" height="12" rx="3" fill="none" stroke="currentColor" stroke-width="1.5"/><path d="M9 2v4m6-4v4M9 18v4m6-4v4M2 9h4m-4 6h4m12-6h4m-4 6h4" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/><path d="m9 12 2 2 4-4" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>';
    badge.append(svg, document.createTextNode(label || (source === 'ai' ? 'AI reviewed' : 'Local analysis')));
    return badge;
}
