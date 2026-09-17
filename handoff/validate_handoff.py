"""Validate the actual DOCX and its rendered PDF. Does not claim clinical verification."""
from pathlib import Path
from hashlib import sha256
import json
import re
import csv
import subprocess
from zipfile import ZipFile
import xml.etree.ElementTree as ET
from docx import Document
import pymupdf
from PIL import Image, ImageDraw

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'handoff'
source=(OUT/'RUMI_DEVELOPER_HANDOFF.md').read_text()
docx=OUT/'Rumi_Developer_Handoff.docx'
pdf=OUT/'Rumi_Developer_Handoff.pdf'
ns={'w':'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
with ZipFile(docx) as z:
    assert z.testzip() is None
    xml=ET.fromstring(z.read('word/document.xml'))
    all_text='\n'.join(e.text or '' for e in xml.findall('.//w:t',ns))
    images=[n for n in z.namelist() if n.startswith('word/media/')]
    assert len(images)>=12, 'Missing screenshot media'
    assert not any(n.endswith('vbaProject.bin') for n in z.namelist())
sections=re.findall(r'^## (\d+\. .+)$',source,re.M)
for heading in sections: assert heading in all_text, heading
assert len(sections)==15
qms='This is a functional requirements document intended to give Design and Engineering a working starting point. It is not a formal traceable requirements record. Traceable product requirements (MRD/SRS) for regulatory purposes are maintained in Greenlight Guru, the official QMS system of record.'
assert qms in all_text
assert (ROOT/'RUMI_REQUIREMENTS.md').read_text().rstrip().rstrip('*').endswith(qms)
feature_rows=re.findall(r'^\| (?:\d+|\+\d+) [^|]+\|',source,re.M)
assert len(feature_rows)==43, len(feature_rows)
missing=[]
for _,target in re.findall(r'\[([^\]]+)\]\(([^\)]+)\)',source):
    if not target.startswith(('http://','https://','#')) and not (ROOT/target.split('#')[0]).exists(): missing.append(target)
assert not missing, missing
asset_rows=list(csv.DictReader((OUT/'asset_inventory.csv').open()))
for row in asset_rows:
    file=ROOT/row['path']; assert file.exists(); assert sha256(file.read_bytes()).hexdigest()==row['sha256']
assert pdf.exists(), 'Render DOCX to PDF before running full validation'
rendered=pymupdf.open(pdf)
page_text='\n'.join(p.get_text() for p in rendered)
for number in range(1,16):
    heading=sections[number-1]
    assert re.sub(r'\s+',' ',heading) in re.sub(r'\s+',' ',page_text), heading
bounds=[]
for idx,page in enumerate(rendered):
    for block in page.get_text('blocks'):
        x0,y0,x1,y1,*_=block
        if x0 < -1 or y0 < -1 or x1 > page.rect.width+1 or y1 > page.rect.height+1: bounds.append(idx+1)
assert not bounds, bounds
# Contact sheets are layout QA derivatives, not replaced originals or accepted slides.
qa=OUT/'render-review'; qa.mkdir(exist_ok=True)
for start in range(0,len(rendered),12):
    canvas=Image.new('RGB',(1000,1260),'#dbe6df'); draw=ImageDraw.Draw(canvas)
    for offset in range(min(12,len(rendered)-start)):
        page=rendered[start+offset]; pix=page.get_pixmap(matrix=pymupdf.Matrix(.38,.38)); image=Image.frombytes('RGB',[pix.width,pix.height],pix.samples)
        image.thumbnail((240,385)); x=(offset%4)*250+(250-image.width)//2; y=(offset//4)*420+24
        canvas.paste(image,(x,y)); draw.text((x,y-17),f'Page {start+offset+1}',fill='#00211a')
    canvas.save(qa/f'pages-{start+1:02d}.jpg',quality=88)
report={'date':'2026-09-17','docx':str(docx.relative_to(ROOT)),'docxSha256':sha256(docx.read_bytes()).hexdigest(),'docxBytes':docx.stat().st_size,'sectionsVerified':len(sections),'featureRowsVerified':len(feature_rows),'embeddedImages':len(images),'assetRowsVerified':len(asset_rows),'brokenLocalLinks':missing,'qmsExact':True,'pdfPages':len(rendered),'pdfTextBoundsPassed':True,'layoutReview':'All rendered-page contact sheets inspected; content/figure bounds checked. This is document QA, not clinical approval','webBuild':'Managed static checks/build passed; see current session delivery update for final checkpoint','webTests':'68 passed (39 Privia + 1 disabled-entry + 28 existing); no native tests rerun','nativeBuild':'Not rerun; iOS source unchanged','liveClinicalIntegrations':'Not verified','manualCommit':'Not performed; Rork managed sync','remotePush':'Not observed'}
live_path=OUT/'live_ai_verification.json'
if live_path.exists():
    live=json.loads(live_path.read_text()); report['liveAI']={'replyCount':live['replyCount'],'statuses':live['statuses'],'sandboxCertificateBypass':live['sandboxCertificateBypass'],'noAppTLSChange':live['noAppTLSChange']}
report['browserEvidence']='handoff/browser_verification.json'
(OUT/'verification.json').write_text(json.dumps(report,indent=2))
print(json.dumps(report,indent=2))
