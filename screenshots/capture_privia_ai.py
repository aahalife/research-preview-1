"""Supplementary live synthetic AI captures. Not a clinical evaluation.
The sandbox browser lacks the platform certificate trust chain; --sandbox-tls
bypasses certificate validation ONLY in this disposable test browser, never app code.
No auth headers/tokens are inspected, printed or stored.
"""
from pathlib import Path
import json
import sys
from playwright.sync_api import sync_playwright
ROOT=Path(__file__).resolve().parent
OUT=ROOT/'privia-web'
url='https://8bj7q7lzrlxpwebjl7tla-web.rork.live'
ignore='--sandbox-tls' in sys.argv
screens=[]
with sync_playwright() as p:
    browser=p.chromium.launch()
    page=browser.new_page(viewport={'width':390,'height':844},device_scale_factor=2,ignore_https_errors=ignore,reduced_motion='reduce')
    statuses=[]
    page.on('response',lambda r: statuses.append(r.status) if '/chat/completions' in r.url else None)
    page.goto(url)
    page.get_by_label('Talk with Rumi',exact=True).click()
    page.get_by_role('button',name='Enable temporary AI',exact=True).click()
    cases=[('13-live-concern','I keep putting off the blood test. Please do not jump to scheduling.','Live AI respects the request not to jump straight to scheduling.'),('14-live-draft','I felt faint at my last blood draw. Please help me draft a short question to my practice about support. Don’t save or send it yet.','A stated concern leads to a reviewable draft, not a fabricated arrangement.')]
    for index,(name,prompt,caption) in enumerate(cases):
        page.get_by_label('Message Rumi').fill(prompt)
        page.get_by_role('button',name='Send to Rumi',exact=True).click()
        page.wait_for_function("n => JSON.parse(localStorage.getItem('rumi.privia.elena.v1')||'{}').turns?.filter(t=>t.origin==='live-ai').length >= n",arg=index+1,timeout=45000)
        page.wait_for_timeout(500)
        page.screenshot(path=str(OUT/f'{name}.png'))
        screens.append({'file':f'{name}.png','caption':caption,'patient':'Elena · synthetic','source':url,'ai':'Actual gateway reply; supplementary fresh browser run'})
    state=page.evaluate("JSON.parse(localStorage.getItem('rumi.privia.elena.v1'))")
    replies=[{'text':t['text'],'suggestion':t.get('suggestion')} for t in state['turns'] if t['origin']=='live-ai']
    report={'date':'2026-09-17','source':url,'statuses':statuses,'replyCount':len(replies),'syntheticReplies':replies,'sandboxCertificateBypass':ignore,'noAppTLSChange':True,'screens':screens,'scope':'Synthetic app conversation only. Not full clinical or telephone validation.'}
    (ROOT.parent/'handoff/live_ai_verification.json').write_text(json.dumps(report,indent=2,ensure_ascii=False))
    print(json.dumps({'statuses':statuses,'replyCount':len(replies),'syntheticReplies':replies},ensure_ascii=False))
    browser.close()
