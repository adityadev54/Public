# Host Touchline

Fly needs a Linux container. This version uses CPU SSDLite person detection and EasyOCR, with the same frame evidence, tracking and selective AI workflow. Outputs and confidence scores differ from Apple Vision; compare each engine separately.

1. Sign into Fly: `fly auth login`.
2. Create an app: `fly apps create <unique-name>`.
3. Set secrets securely using `fly secrets import -a <unique-name>` with standard input containing `APP_ACCESS_PASSWORD` (at least 16 characters) and `OPENROUTER_API_KEY`. Do not put keys in files, command history, or source control.
4. Deploy one machine: `fly deploy -a <unique-name> --ha=false`.
5. Open the app. Username: `touchline`. Password: the workspace access password.

Visitors share the owner's AI connection and cannot replace it. AI is limited to five review batches per minute; each analysis uses at most five crops. Share the workspace password only with invited testers. Fly billing applies; this is not an unlimited free host.

Original videos and the library stay in each visitor's browser. Sampled frames reach the server; selected AI crops reach the model provider. Videos and experiment results are not uploaded into permanent server storage. Export JSON before refreshing. A new domain has a separate browser library.

Quick use: choose a short clip, run analysis, review crops, verify numbers against the video, then open Research to compare labeled outcomes.
