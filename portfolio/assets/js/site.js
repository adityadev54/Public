(() => {
  const root = document.documentElement;
  root.dataset.theme = localStorage.getItem('theme') || 'dark';

  window.toggleTheme = () => {
    root.dataset.theme = root.dataset.theme === 'light' ? 'dark' : 'light';
    localStorage.setItem('theme', root.dataset.theme);
  };

  window.toggleDrawer = () => {
    const drawer = document.querySelector('.mobile-drawer');
    const open = drawer?.classList.toggle('active');
    document.querySelector('.hamburger')?.classList.toggle('active', open);
    document.querySelector('.nav-overlay')?.classList.toggle('active', open);
    document.body.style.overflow = open ? 'hidden' : '';
  };

  document.addEventListener('DOMContentLoaded', () => {
    document.querySelector('.home-lab')?.setAttribute('id', 'lab');
    document.querySelectorAll('a[href^="#"]').forEach(link => {
      link.addEventListener('click', event => {
        const target = document.querySelector(link.getAttribute('href'));
        if (!target) return;
        event.preventDefault();
        target.scrollIntoView({
          behavior: matchMedia('(prefers-reduced-motion: reduce)').matches ? 'auto' : 'smooth',
          block: 'start'
        });
        history.replaceState(null, '', link.getAttribute('href'));
        if (document.querySelector('.mobile-drawer.active')) toggleDrawer();
      });
    });

    // Brand marks should not depend on Lucide's changing icon catalog.
    document.querySelectorAll('[data-lucide="github"]').forEach(icon => {
      icon.outerHTML = '<svg class="github-mark" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path fill-rule="evenodd" d="M12 2C6.48 2 2 6.59 2 12.25c0 4.53 2.87 8.37 6.84 9.73.5.1.68-.22.68-.49 0-.24-.01-1.05-.01-1.91-2.78.62-3.37-1.21-3.37-1.21-.45-1.18-1.11-1.49-1.11-1.49-.91-.64.07-.63.07-.63 1 .08 1.53 1.06 1.53 1.06.89 1.57 2.34 1.12 2.91.85.09-.67.35-1.12.64-1.38-2.22-.26-4.56-1.14-4.56-5.07 0-1.12.39-2.04 1.03-2.76-.1-.26-.45-1.31.1-2.72 0 0 .84-.28 2.75 1.05A9.3 9.3 0 0 1 12 6.99a9.3 9.3 0 0 1 2.5.34c1.91-1.33 2.75-1.05 2.75-1.05.55 1.41.2 2.46.1 2.72.64.72 1.03 1.64 1.03 2.76 0 3.94-2.34 4.8-4.57 5.06.36.32.68.94.68 1.9 0 1.38-.01 2.49-.01 2.83 0 .27.18.59.69.49A10.24 10.24 0 0 0 22 12.25C22 6.59 17.52 2 12 2Z" clip-rule="evenodd"/></svg>';
    });
    if (window.lucide) window.lucide.createIcons();
    document.querySelectorAll('a[href$="about.html"], a[href$="skills.html"]').forEach(link => { link.hidden = true; });
    const labCuts = [...document.querySelectorAll('.home-lab .process-cut')];
    const activateLabCut = cut => labCuts.forEach(item => {
      const active = item === cut;
      item.classList.toggle('active', active);
      item.setAttribute('aria-expanded', String(active));
      item.removeAttribute('aria-pressed');
    });
    labCuts.forEach(cut => {
      cut.addEventListener('pointerenter', () => activateLabCut(cut));
      cut.addEventListener('focus', () => activateLabCut(cut));
      cut.addEventListener('click', () => activateLabCut(cut));
    });
    document.querySelectorAll('.creative-toggle').forEach(button => {
      const front = button.querySelector('.creative-front');
      const back = button.querySelector('.creative-back');
      const setFlipped = flipped => {
        button.setAttribute('aria-expanded', String(flipped));
        button.setAttribute('aria-label', `${flipped ? 'Show image' : 'Show details'} for ${button.dataset.pieceLabel}`);
        front.setAttribute('aria-hidden', String(flipped));
        back.setAttribute('aria-hidden', String(!flipped));
        if (flipped) button.setAttribute('aria-describedby', back.id);
        else button.removeAttribute('aria-describedby');
      };
      button.addEventListener('click', () => setFlipped(button.getAttribute('aria-expanded') !== 'true'));
      button.addEventListener('keydown', event => {
        if (event.key === 'Escape') setFlipped(false);
      });
    });
    if (!matchMedia('(prefers-reduced-motion: reduce)').matches && 'IntersectionObserver' in window) {
      const observer = new IntersectionObserver(entries => entries.forEach(entry => {
        if (entry.isIntersecting) entry.target.classList.add('visible');
      }), { threshold: .08 });
      document.querySelectorAll('[data-reveal]').forEach(element => {
        element.classList.add('reveal');
        observer.observe(element);
      });
    }
  });
})();
