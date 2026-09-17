"""Non-mutating layout smoke on fresh browser contexts; synthetic data only."""
import json
from playwright.sync_api import sync_playwright
report=[]
with sync_playwright() as p:
    browser=p.chromium.launch()
    for w,h in [(320,740),(390,844),(768,1024),(1365,900)]:
        page=browser.new_page(viewport={'width':w,'height':h},reduced_motion='reduce')
        errors=[]; page.on('pageerror',lambda e: errors.append(str(e)))
        page.goto('http://localhost:8080'); page.wait_for_timeout(350)
        overflow=page.evaluate('document.documentElement.scrollWidth > innerWidth')
        page.get_by_role('navigation').get_by_role('link',name='Care',exact=True).click()
        page.get_by_role('button',name='Manage sample connections').click()
        page.keyboard.press('Escape')
        page.get_by_role('button',name='Log',exact=True).click()
        page.get_by_label('Blood pressure · mmHg').fill('135/82')
        page.get_by_role('button',name='Close',exact=True).click()
        page.get_by_role('button',name='Log',exact=True).click()
        assert page.get_by_label('Blood pressure · mmHg').input_value()=='135/82'
        assert not overflow and not errors
        report.append({'viewport':[w,h],'horizontalOverflow':overflow,'runtimeErrors':errors,'logDraftRecovery':True,'escapeDismissesDialog':True})
        page.close()
    browser.close()
print(json.dumps(report,indent=2))
