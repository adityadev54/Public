"""Run against a local Touchline server: python3 Tests/tracking_checks.py [base_url]."""
import json
import sys
import urllib.request

base_url = sys.argv[1] if len(sys.argv) > 1 else 'http://localhost:5186'

def person(id, x, number=None):
    readings = [] if number is None else [dict(text=str(number), confidence=0.9, x=0, y=0, width=1, height=1)]
    return dict(id=id, confidence=0.9, x=x, y=0.3, width=0.1, height=0.2, readings=readings)

def link(frames):
    payload = dict(frames=[dict(timestamp=t, people=people) for t, people in frames])
    request = urllib.request.Request(base_url + '/api/tracks/link', json.dumps(payload).encode(), {'Content-Type': 'application/json'})
    with urllib.request.urlopen(request) as response:
        return json.load(response)['tracks']

# A box-width move stops overlapping the original box. Learned velocity must keep the ID.
tracks = link([(0, [person(1, .1, 3)]), (1, [person(1, .15, 3)]), (2, [person(1, .25, 3)])])
assert len(tracks) == 1 and tracks[0]['sightings'] == 3 and tracks[0]['number'] == 3
# One missed sample is recoverable within the bounded gap.
tracks = link([(0, [person(1, .1)]), (.5, [person(1, .15)]), (1, []), (1.5, [person(1, .25)])])
assert len(tracks) == 1 and tracks[0]['sightings'] == 3
# Long gaps must not reconnect distant-in-time observations.
assert len(link([(0, [person(1, .1)]), (3, [person(1, .1)])])) == 2
# Symmetric alternatives are deliberately split rather than assigned arbitrarily.
tracks = link([(0, [person(1, .2)]), (1, [person(1, .18), person(2, .22)])])
assert len(tracks) == 3
# Multiple people cannot attach to one track in the same frame.
tracks = link([(0, [person(1, .1), person(2, .6)]), (1, [person(1, .11), person(2, .61)])])
assert len(tracks) == 2 and all(t['sightings'] == 2 for t in tracks)
# Conflicting readings remain unresolved; OCR does not dictate identity.
tracks = link([(0, [person(1, .1, 3)]), (1, [person(1, .1, 12)])])
assert len(tracks) == 1 and tracks[0]['number'] is None
print('Passed 6 tracking checks: motion, missed sample, long gap, ambiguity, one-to-one, OCR conflict.')
