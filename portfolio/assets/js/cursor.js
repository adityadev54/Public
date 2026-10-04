(() => {
  if (window.matchMedia('(pointer: coarse)').matches || window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;
  const dot = document.createElement('div');
  const ring = document.createElement('div');
  dot.className = 'cursor-dot'; ring.className = 'cursor-ring';
  document.body.append(dot, ring);
  addEventListener('pointermove', e => {
    const position = `translate3d(${e.clientX}px,${e.clientY}px,0)`;
    dot.style.transform = position;
    ring.style.transform = position;
    document.documentElement.classList.add('cursor-ready');
  }, { passive: true });
  document.querySelectorAll('a, button, .project-card, .ct-link').forEach(el => {
    el.addEventListener('mouseenter', () => document.documentElement.classList.add('cursor-hover'));
    el.addEventListener('mouseleave', () => document.documentElement.classList.remove('cursor-hover'));
  });
  addEventListener('mousedown', () => document.documentElement.classList.add('cursor-down'));
  addEventListener('mouseup', () => document.documentElement.classList.remove('cursor-down'));
})();
