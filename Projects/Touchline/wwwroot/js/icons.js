// Locally bundled Heroicons outline sprite. Decorative icons keep text labels accessible.
export function icon(name) {
    const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
    for (const [key, value] of Object.entries({ class: 'hero-icon', viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor', 'stroke-width': '1.5', 'aria-hidden': 'true', focusable: 'false' })) svg.setAttribute(key, value);
    const use = document.createElementNS(svg.namespaceURI, 'use');
    use.setAttribute('href', `/vendor/heroicons/sprite.svg#${name}`); svg.append(use);
    return svg;
}
export function setAction(button, name, label) {
    button.replaceChildren(icon(name), document.createTextNode(label));
}

// Icon-only tools retain an accessible name and a native hover hint.
export function setIconAction(button, name, label) {
    button.replaceChildren(icon(name));
    button.setAttribute('aria-label', label);
    button.title = label;
}
