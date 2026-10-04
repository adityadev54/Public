# Particle galaxy hero design QA

## Evidence

- Source visual truth: the two user-provided reference screenshots in the September 30, 2026 conversation. The first defines the control panel; the second defines the green/cyan spiral-galaxy treatment.
- Implementation target: `http://127.0.0.1:5500/`, homepage hero.
- Implementation screenshot: unavailable because no supported browser surface is exposed in this session.
- Intended desktop viewport: 1440 × 1000 CSS px at device scale factor 1.
- Source pixels: control reference 534 × 592; galaxy reference was supplied at 2604 × 1770 and displayed at a normalized 1920 × 1305.
- Implementation pixels/density: unavailable; no browser capture could be made.
- State: portrait-particle start and galaxy end state using the supplied default simulation values.

## Full-view comparison evidence

Blocked. The source screenshots are visible in the conversation, but the implementation cannot be browser-rendered or captured in the available environment. Static source inspection is not accepted as visual comparison evidence.

## Focused region comparison evidence

Blocked for the same reason. The intended focused regions are the second-image particle silhouette and the fully formed spiral.

## Implemented

- Only `assets/images/Aditya-sketching-alpha.png`, the second homepage portrait, is used as the source and fallback image.
- Roughly 24,000 particles sample visible pixels and colors from that image.
- The same GPU particles interpolate into a procedural spiral galaxy; no separate galaxy image is used.
- The shader defaults are fixed to 4 spiral arms, 0.35 rotation speed, 60 radius, 4 disk thickness, 1.5 core brightness, and 2 star twinkle.
- Scroll morphs the portrait into the galaxy; tapping the canvas toggles the two states for direct inspection.
- No simulation control panel is rendered.
- The whole hero gains a progress-linked galaxy atmosphere, with coordinated headline, supporting-copy, and action contrast.
- Light mode uses darker teal/blue particle colors, standard alpha blending, and a pale green/blue galaxy atmosphere rather than the dark-mode additive treatment.

## Static and serving checks

- HTML parsing and single-image source assertions passed.
- JavaScript parsed successfully with JavaScriptCore.
- Homepage, shader script, and second portrait returned HTTP 200 from the local preview server.
- Browser-rendered screenshot: missing.
- Primary interactions tested in browser: missing.
- Console errors checked: missing.

## Findings

- [P1] Runtime visual fidelity cannot be verified.
  - Location: homepage particle-galaxy hero.
  - Evidence: the supported in-app browser returned `Browser is not available`, and no browser providers were listed.
  - Impact: particle density, WebGL point sizing, morph behavior, and responsive layout may still require visual tuning.
  - Fix: open the local preview in a supported browser, capture the intended desktop viewport and a mobile viewport, exercise the tap/scroll morph, inspect console output, and compare the captures with the supplied references.

## Required fidelity surfaces

- Fonts and typography: statically aligned to the portfolio font and the reference's compact uppercase control heading; browser verification blocked.
- Spacing and layout rhythm: the particle canvas remains integrated with the existing hero; browser verification blocked.
- Colors and visual tokens: dark mode uses luminous green/cyan additive particles; light mode uses darker teal/blue alpha-blended particles; browser verification blocked.
- Image quality and asset fidelity: the requested second portrait is the only sampled source; particle rendering quality is not browser-verified.
- Copy and content: the control panel has been intentionally removed; the six supplied values remain internal shader defaults.

## Comparison history

- Pass 1: browser capture could not start because the in-app browser is unavailable. No visual fixes can be responsibly inferred from a missing implementation capture.

## Implementation checklist

- Capture desktop portrait and full-galaxy states.
- Confirm the fixed shader defaults produce the intended galaxy.
- Check WebGL and page console errors.
- Capture the mobile stacked-control layout.
- Compare source and implementation together; resolve any P0/P1/P2 differences.

final result: blocked
