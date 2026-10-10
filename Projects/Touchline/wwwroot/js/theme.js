// Color preferences affect only the interface, never the pixels submitted for analysis.
const button = document.getElementById('themeToggle');
function syncThemeButton() {
    const light = document.documentElement.dataset.bsTheme === 'light';
    button.setAttribute('aria-label', light ? 'Switch to dark mode' : 'Switch to light mode');
    button.title = light ? 'Dark mode' : 'Light mode';
    document.querySelector('meta[name="theme-color"]').content = light ? '#fafafa' : '#000000';
}
button.addEventListener('click', () => {
    const next = document.documentElement.dataset.bsTheme === 'light' ? 'dark' : 'light';
    document.documentElement.dataset.bsTheme = next;
    try { localStorage.setItem('touchline-theme', next); } catch {}
    syncThemeButton();
});
syncThemeButton();
