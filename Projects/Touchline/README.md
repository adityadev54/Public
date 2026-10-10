# Touchline

C# / ASP.NET Core (.NET 10), Bootstrap 5.3.8, and native Apple Vision OCR.

## Run on macOS

```sh
cd /Users/adipatel/Documents/ChatGPT/Touchline
dotnet watch run --launch-profile http
```

Open http://localhost:5186. Xcode command-line tools are required to compile the native OCR bridge during build. The app runs in your terminal; do not start a competing server on the same port.

## Real processing

Choose a video, select 1–5 frames and a sampling policy, then Analyze video. The browser decodes real frames (maximum width 3840), ranks sampled frames using an edge-sharpness heuristic when selected, and sends JPEGs only to the local C# endpoint. Apple Vision detects people using overlapping tiles to preserve small players, merges duplicate boxes, and reads enlarged upper-body crops. Standalone one- or two-digit readings appear as candidates, with timestamps, images and OCR scores. You can add verified labels and export JSON evidence. No synthetic output or paid API is used.

OCR scores are not calibrated jersey-number probabilities. Whole-frame OCR can read signs and scoreboards and can miss small or stylized jersey digits. Local person detection is connected. A spatial IoU tracking baseline is connected. A jersey-specific model, uncertainty-triggered review, and VLM are not connected yet. This is the real frame/OCR baseline, not the completed research system. Frames and labels are in memory and reset on refresh.

## Organization

- `Program.cs`: startup.
- `Models/`: API contracts.
- `Endpoints/`: input validation and HTTP routes.
- `Services/LocalOcrService.cs`: bounded native OCR execution.
- `Tools/VisionReader.swift`: small macOS Vision bridge; compiled during build.
- `wwwroot/js/video.js`: decoding and frame selection.
- `wwwroot/js/api.js`: local C# API calls.
- `wwwroot/js/app.js`: analysis orchestration, progress, cancellation, export.
- `wwwroot/js/review.js`: paginated tracks, single-frame review, persistent annotations.
- `wwwroot/js/evidence.js`: shared numeric-reading normalization.
- `wwwroot/css/app.css`: shared compact interface tokens.

Next: add player crops and tracking, then compare a jersey-specific reader with selective VLM review on labeled SoccerNet data.

## Verified crop run

A frame at 5.86 seconds from the locally downloaded 6079624 training clip produced 10 detected people. Native OCR read `3` and `12-` in two crops. The UI accepts a trailing punctuation mark as a numeric candidate and retains raw text. These observations are examples, not an accuracy benchmark or a count of all players present.

## Interface

Dark interface inspired by the live ChatGPT reference: black canvas, charcoal surfaces, neutral borders, white primary controls, and a compact analysis composer. Bootstrap remains locally bundled. Real result summaries show frames processed, person sightings (not unique players), and crops with number candidates. The Readings only filter hides unreadable crops while preserving them in exports. Responsive navigation supports dismissal with Escape or the backdrop.

## Tracking baseline

The C# PlayerTrackingService scores bounded motion-predicted overlap and center distance with one-to-one greedy assignment. It rejects large box-size changes and close competing matches (score margin below 0.08). Gaps longer than 2.5 seconds create new tracks. It counts number votes per sighting, requires two readings and a margin over conflicts before reporting repeated support. This is not a calibrated identity or accuracy claim. Camera cuts and crossing players may cause fragmentation or identity switches; no appearance re-identification or camera compensation is present. Use evenly spaced frames for tracking and independent labeled data to measure accuracy. Default sampling is 24 frames; long clips need denser sampling or shorter segments.

Track results include observations, OCR support counts, first/last sighting timestamps, and crop-to-track associations in JSON. Review buttons seek to the first sighting. No trajectories are converted into real-world distance or speed.

Verified association checks: repeated support, conflicting numbers, long-gap splitting, and one-to-one matching.

Historical spatial-baseline real-video check on 6079624 (18.8 seconds), 24 evenly spaced frames: 276 person sightings, 60 crops with numeric readings, 62 provisional track fragments, and 7 tracks with repeated support. The #3 and #12 tracks each span 24 sightings, with 13 and 20 matching readings respectively. These observations do not establish tracking accuracy; fragmentation is substantial and requires improvement and ground-truth evaluation.

Compact review: Tracks and Frames tabs show six tracks per page or one frame at a time. Track filters narrow the evidence, and Review opens the associated crop. Video settings collapse after completion. Human annotations stay in experiment data when changing frames and are included in JSON exports.

Responsive workspace: Bootstrap columns place video and analysis settings side by side from 768px, then stack on smaller screens. Results use a three-column summary row; frame evidence uses image and crop columns on desktop and stacks on mobile. Shared spacing and larger controls keep the workflow consistent.

Motion tracker validation: `python3 Tests/tracking_checks.py http://localhost:5186` checks learned movement, a missed sample, long-gap splitting, ambiguous alternatives, one-to-one matching, and conflicting OCR. These synthetic regression checks passed; real-video accuracy improvement has not yet been measured against labeled identities. Velocity extrapolation is capped to one previous box width/height, and gaps remain limited to 2.5 seconds.

## Selective AI vision review

Enable “Review uncertain tracks with AI” before running analysis. The pipeline prioritizes conflicting readings, then unreadable tracks, then single readings; longer tracks break ties. It selects one crop per track using crop area times measured frame sharpness, and caps requests at 1, 3, or 5 per run. This is a quality heuristic, not proof the crop is the clearest.

The server calls OpenRouter chat completions with structured JSON and explicit abstention. Default model: `dots-studio/dots-3-note-preview:free`, verified as image-capable with structured output in the model catalog on 2026-10-08. Set `AI_MODEL` to another compatible `:free` vision model if availability changes. Paid fallback is blocked with zero prompt/completion price limits. Free models still require a key and may be rate limited.

Start from your terminal without putting credentials in source or chat:

```bash
read -s 'OPENROUTER_API_KEY?OpenRouter key: '
export OPENROUTER_API_KEY
printf '\n'
dotnet run --project "/Users/adipatel/Documents/ChatGPT/Touchline" --launch-profile http
```

Create your key at https://openrouter.ai/settings/keys . Keys stay on the server. Optional AI sends selected JPEG person crops through OpenRouter to the selected model provider. Local detection and OCR remain available when AI is disabled or fails.

Each track keeps `number` (baseline), `aiReview` (answer, trigger, timestamp, status), and `mergedNumber`/`mergedSource` (an explicitly unverified AI suggestion if OCR was unresolved). AI never overwrites baseline votes. JSON includes answers, model, attempted calls, tokens, and all human annotations. The UI reports calls per video minute and suggestions. Failures stop further calls; no automatic retries. Requests do not persist images on this server.

No API key was available during development: provider inference remains unverified. Build, request validation, missing-key behavior and local tracking checks can be tested without paid calls. AI effectiveness requires independent ground truth; token usage and added suggestions are not accuracy measurements.

Web key entry: AI settings includes a masked OpenRouter key field, Save key, and Clear key. Credentials are held in server process memory only, never returned in API responses or included in exports. Restart clears the web-entered key. Clearing disables any environment key for the current session. AI endpoints require loopback access and a localhost host; mutations also require an exact same-origin Origin header. Key requests are bounded to 2 KiB. This is a local personal app, not a multi-user credential vault. Verified save/clear, no secret echo, invalid formats, missing/cross-site origin rejection, and no-store responses.
