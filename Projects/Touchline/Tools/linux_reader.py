"""CPU vision bridge. JPEG on stdin, normalized evidence JSON on stdout.
Uses the same tiling, person cap, upper-body OCR and coordinate contract as Apple Vision.
Model outputs differ; do not mix engines within a research comparison.
"""
import contextlib, io, json, os, sys
from pathlib import Path
import cv2
import numpy as np
import torch
from torchvision.models.detection import ssdlite320_mobilenet_v3_large, SSDLite320_MobileNet_V3_Large_Weights
from torchvision.ops import nms
import easyocr

torch.set_num_threads(int(os.getenv('VISION_THREADS', '2')))
cache = os.getenv('VISION_MODEL_DIR', str(Path.home() / '.cache/touchline'))
# Initialization messages must never contaminate the JSON protocol.
with contextlib.redirect_stdout(sys.stderr):
    model = ssdlite320_mobilenet_v3_large(weights=SSDLite320_MobileNet_V3_Large_Weights.DEFAULT).eval()
    reader = easyocr.Reader(['en'], gpu=False, model_storage_directory=cache,
                            download_enabled='--prepare' in sys.argv, verbose=False)
if '--prepare' in sys.argv:
    sys.exit(0)

def text_readings(image):
    h, w = image.shape[:2]
    if h < 2 or w < 2:
        return []
    result = []
    for corners, text, confidence in reader.readtext(image, paragraph=False, canvas_size=1280, mag_ratio=1):
        points = np.asarray(corners)
        x, y = points.min(axis=0)
        right, bottom = points.max(axis=0)
        result.append(dict(text=text, confidence=float(confidence), x=float(x/w),
                           y=float(y/h), width=float((right-x)/w), height=float((bottom-y)/h)))
    return result

image = cv2.imdecode(np.frombuffer(sys.stdin.buffer.read(), np.uint8), cv2.IMREAD_COLOR)
if image is None or image.shape[0]*image.shape[1] > 20000000:
    raise ValueError('Supply a valid image of at most 20 megapixels.')
h, w = image.shape[:2]
boxes, scores = [], []
with torch.inference_mode():
    for top in range(0, h, 576):
        for left in range(0, w, 576):
            tile = image[top:top+768, left:left+768]
            tensor = torch.from_numpy(cv2.cvtColor(tile, cv2.COLOR_BGR2RGB)).permute(2,0,1).float()/255
            output = model([tensor])[0]
            for box, score, label in zip(output['boxes'], output['scores'], output['labels']):
                if int(label) != 1 or float(score) < .35:
                    continue
                x1,y1,x2,y2 = box.tolist()
                boxes.append([max(0,x1+left), max(0,y1+top), min(w,x2+left), min(h,y2+top)])
                scores.append(float(score))
    keep = nms(torch.tensor(boxes, dtype=torch.float32), torch.tensor(scores), .35).tolist() if boxes else []
keep = sorted(keep, key=lambda i: boxes[i][0])[:40]
people = []
for identifier, i in enumerate(keep, 1):
    x1,y1,x2,y2 = boxes[i]
    crop = image[int(y1):max(int(y1)+1,int(y1+(y2-y1)*.65)), int(x1):max(int(x1)+1,int(x2))]
    scale = min(6, max(1,400/max(1,crop.shape[1])))
    crop = cv2.resize(crop, None, fx=scale, fy=scale, interpolation=cv2.INTER_CUBIC)
    people.append(dict(id=identifier, confidence=scores[i], x=x1/w,y=y1/h,
                       width=(x2-x1)/w,height=(y2-y1)/h,readings=text_readings(crop)))
print(json.dumps(dict(readings=text_readings(image), people=people), allow_nan=False))
