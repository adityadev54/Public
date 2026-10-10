"""Small deterministic SoccerNet jersey pilot. Ground truth is used only for scoring.
Usage: python3 Tools/evaluate_jersey.py /path/to/test --limit 10 --frames 5
"""
import argparse
import collections
import json
import re
import subprocess
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('dataset', type=Path)
parser.add_argument('--limit', type=int, default=10)
parser.add_argument('--frames', type=int, default=5)
args = parser.parse_args()
if not 1 <= args.limit <= 100 or not 1 <= args.frames <= 40:
    parser.error('Use 1–100 tracklets and 1–40 frames.')
root = Path(__file__).resolve().parents[1]
labels = json.loads((args.dataset / 'test_gt.json').read_text())
# Numeric order, independent of label values; no favorable subset selection.
ids = sorted(labels, key=lambda value: int(value))[:args.limit]
rows = []
for identity in ids:
    files = sorted((args.dataset / 'images' / identity).glob('*.jpg'), key=lambda path: int(path.stem.rsplit('_', 1)[-1]))
    if not files:
        rows.append(dict(tracklet=identity, error='No JPEG frames')); continue
    count = min(args.frames, len(files))
    selected = [files[round(i * (len(files) - 1) / max(1, count - 1))] for i in range(count)]
    votes = collections.Counter()
    for path in selected:
        process = subprocess.run([str(root / 'Tools/vision-reader')], input=path.read_bytes(), capture_output=True, timeout=120)
        if process.returncode:
            raise RuntimeError('Local vision helper failed; run dotnet build first.')
        evidence = json.loads(process.stdout)
        # Whole-crop OCR: these images are already supplied player crops, not full-field detections.
        readings = evidence.get('readings', [])
        numbers = set()
        for reading in readings:
            match = re.fullmatch(r'\s*(\d{1,2})[-.,]?\s*', reading['text'])
            if match and reading['confidence'] >= .4:
                numbers.add(int(match.group(1)))
        votes.update(numbers)
    ranked = votes.most_common()
    prediction = ranked[0][0] if ranked and ranked[0][1] >= 2 and (len(ranked) == 1 or ranked[0][1] >= ranked[1][1] + 2) else -1
    expected = int(labels[identity])
    rows.append(dict(tracklet=identity, frames=len(selected), prediction=prediction, expected=expected,
                     correct=prediction == expected, votes=dict(votes)))
    print(f'{identity}: predicted {prediction}, label {expected}', flush=True)
scored = [row for row in rows if 'correct' in row]
report = dict(dataset='SoccerNet Jersey test', method='Whole-player-crop local OCR; repeated-vote baseline',
    selection='First numeric tracklet IDs; uniformly sampled frames', aiCalls=0,
    tracksEvaluated=len(scored), correct=sum(row['correct'] for row in scored),
    accuracy=sum(row['correct'] for row in scored)/len(scored) if scored else None,
    abstentions=sum(row['prediction']==-1 for row in scored),
    note='Small descriptive pilot, not benchmark-wide accuracy. -1 is the unreadable class; no tracking evaluation.', results=rows)
output=root/'Data/evaluation'; output.mkdir(parents=True, exist_ok=True)
(output/'jersey-local-pilot.json').write_text(json.dumps(report, indent=2))
print(json.dumps({key:value for key,value in report.items() if key!='results'}, indent=2))
