"""Capture a separate, reproducible Privia web chapter; never touch accepted iOS assets.
Usage: python screenshots/capture_privia.py [base-url]
Uses actual controls, synthetic entries and no mocked AI response. AI screenshots
are captured separately only when an actual gateway response has been verified.
"""
import json
import sys
from pathlib import Path
from playwright.sync_api import sync_playwright, expect

ROOT = Path(__file__).resolve().parent
OUT = ROOT / 'privia-web'
OUT.mkdir(exist_ok=True)
base = sys.argv[1] if len(sys.argv) > 1 else 'http://localhost:8080'
ledger = []
with sync_playwright() as p:
    browser = p.chromium.launch()
    page = browser.new_page(viewport={'width': 390, 'height': 844}, device_scale_factor=2, reduced_motion='reduce')
    errors = []
    page.on('pageerror', lambda err: errors.append(str(err)))
    page.goto(base)
    page.wait_for_timeout(1200)
    def capture(name, caption):
        page.wait_for_timeout(500)
        page.screenshot(path=str(OUT / f'{name}.png'))
        ledger.append({'file': f'{name}.png', 'caption': caption, 'patient': 'Elena · synthetic', 'ai': 'No fabricated AI replies', 'source': base})
    def close():
        page.get_by_role('button', name='Close', exact=True).last.click()
    def nav(label):
        page.get_by_role('navigation', name='Main navigation').get_by_role('link', name=label, exact=True).click()
    capture('01-today', 'One visit, her questions, and a conversation she can return to.')
    nav('Care')
    page.get_by_role('button', name='Manage sample connections').click()
    for label in ['Sample Gmail', 'Sample Google Calendar', 'Sample care information']:
        page.get_by_label(label, exact=False).check()
    capture('02-sources', 'Choose sample evidence separately; this is not Google authorization.')
    close()
    page.get_by_role('button', name='Lab preparation', exact=False).click()
    capture('03-order-missing', 'An unconfirmed order leads to a question, not a fabricated booking.')
    page.get_by_role('button', name='Prepare a question to the practice').click()
    page.get_by_label('Message', exact=True).fill('I felt faint at my last blood draw. Could we discuss support and confirm the preparation and lab order before I choose a time?')
    page.get_by_role('button', name='Review recipient and message').click()
    page.get_by_text('Review · nothing sent', exact=True).scroll_into_view_if_needed()
    capture('04-message-review', 'Her stated concern becomes an editable practice question; no real message is sent.')
    page.get_by_role('button', name='Apply to sample messages').click()
    close()
    page.get_by_role('button', name='PRIVIA HEALTH DEMO').click()
    page.get_by_label('Stage a clinician-approved sample order').check()
    page.get_by_label('Stage a sample practice response').check()
    close()
    page.get_by_role('button', name='Lab preparation', exact=False).click()
    page.get_by_text('View source emails and instructions', exact=True).click()
    page.get_by_label('Search sample inbox').fill('location')
    page.get_by_text('Lab location and planning details', exact=True).click()
    page.get_by_text('Lab location and planning details', exact=True).scroll_into_view_if_needed()
    capture('05-email-evidence', 'Read the exact sample email; preparation remains unconfirmed.')
    page.get_by_text('View source emails and instructions', exact=True).click()
    page.get_by_role('button', name='Compare all three times').click()
    page.get_by_role('button', name='9:30–10:00 am', exact=False).click()
    page.get_by_text('A time that fits', exact=True).scroll_into_view_if_needed()
    capture('06-calendar-comparison', 'A real local overlap check compares three sample times; no slot is reserved.')
    page.get_by_role('button', name='Review this event', exact=True).click()
    page.get_by_role('button', name='Save sample event', exact=True).click()
    page.get_by_text('Saved sample event · not a booking', exact=True).scroll_into_view_if_needed()
    capture('07-saved-calendar', 'Only a private title and time are saved; a calendar event is not a lab booking.')
    page.get_by_role('button', name='Continue to your visit questions').click()
    page.get_by_label('Add a question', exact=True).fill('What support is available if I feel faint during the blood draw?')
    page.get_by_role('button', name='Add to this visit', exact=True).click()
    page.get_by_label('Add a question', exact=True).fill('How should I keep and share my home blood-pressure readings?')
    page.get_by_role('button', name='Add to this visit', exact=True).click()
    page.get_by_text('Choose observations (0)', exact=True).click()
    page.get_by_role('checkbox').check()
    page.get_by_role('button', name='Review your visit guide', exact=True).click()
    page.get_by_role('button', name='Save as reviewed', exact=True).click()
    page.get_by_text('Patient review ·', exact=False).scroll_into_view_if_needed()
    capture('08-reviewed-guide', 'Her questions and one selected observation stay attached to the same appointment.')
    close()
    page.get_by_role('button', name='Log', exact=True).click()
    page.get_by_label('Blood pressure · mmHg', exact=True).fill('136/82')
    capture('09-direct-log', 'A direct reading entry needs no AI conversation and makes no medical assessment.')
    page.get_by_role('button', name='Save entry', exact=True).click()
    page.get_by_role('button', name='PRIVIA HEALTH DEMO').click()
    page.get_by_label('Advance to after the sample visit').check()
    close()
    nav('You')
    page.get_by_role('button', name='Your personal plan', exact=False).click()
    page.get_by_label('A step you choose', exact=True).fill('Keep my notebook beside the blood-pressure cuff')
    page.get_by_label('When it fits', exact=True).fill('When I clear the table after breakfast')
    page.get_by_role('button', name='Add a reason, obstacle or fallback').click()
    page.get_by_label('What gets in the way', exact=True).fill('I put the notebook away and forget where it is')
    page.get_by_label('An easier nonclinical step', exact=True).fill('Just put the notebook next to the cuff today')
    page.get_by_role('button', name='Make it smaller', exact=True).click()
    page.get_by_text('Your check-in · optional', exact=True).scroll_into_view_if_needed()
    capture('10-smaller-step', 'A difficult routine can become a smaller practical step, without changing prescribed care.')
    close()
    page.get_by_role('button', name='PRIVIA HEALTH DEMO').click()
    page.get_by_role('button', name='SMS preview', exact=True).click()
    page.get_by_label('Sample incoming text', exact=True).fill('BP 136')
    page.get_by_role('button', name='Submit sample reply', exact=True).click()
    page.get_by_label('Sample incoming text', exact=True).fill('BP 136/82 2026-09-30 08:00')
    page.get_by_role('button', name='Submit sample reply', exact=True).click()
    capture('11-sms-continuity', 'Sample SMS clarifies an incomplete reading and acknowledges without echoing health details.')
    page.get_by_role('button', name='Open app · continue the same thread').click()
    capture('12-return-to-app', 'Return to the shared thread; sample acknowledgments are visibly distinct from live AI.')
    assert not errors, errors
    page.reload()
    expect(page.get_by_text('Elena', exact=True)).to_be_visible()
    page.get_by_label('Talk with Rumi', exact=True).click()
    expect(page.get_by_text('BP 136/82 2026-09-30 08:00', exact=True)).to_be_visible()
    ledger_meta = {'date': '2026-09-17', 'platform': 'web / Chromium', 'viewport': '390 × 844 @2x', 'acceptance': 'Captured and inspected; not user-approved presentation slides', 'runtimeErrors': errors, 'relaunchVerified': True, 'screens': ledger}
    (OUT / 'manifest.json').write_text(json.dumps(ledger_meta, indent=2, ensure_ascii=False))
    print(json.dumps({'captured': len(ledger), 'runtimeErrors': errors, 'relaunchVerified': True}))
    browser.close()
