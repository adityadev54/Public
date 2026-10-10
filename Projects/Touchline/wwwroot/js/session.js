// Cookie-bound verification works in browser views even when Origin is omitted.
export async function aiHeaders() {
    const response = await fetch('/api/ai/session', { cache: 'no-store' });
    if (!response.ok) throw new Error('Restart the server and refresh to enable AI settings.');
    const session = await response.json();
    return { 'Content-Type': 'application/json', 'X-CSRF-TOKEN': session.token };
}
