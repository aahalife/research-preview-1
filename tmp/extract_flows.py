"""Extract every page of the supplied flow reference without inferring missing text."""
from pathlib import Path
import fitz
source = Path('/tmp/rumi-agentic-flows.pdf')
doc = fitz.open(source)
out = Path('tmp/agentic-flows-extracted.txt')
parts = [f'PAGE {i+1}/{len(doc)}\n{p.get_text()}' for i,p in enumerate(doc)]
out.write_text('\n\n'.join(parts))
print(f'Extracted {len(doc)} pages; {sum(len(p.get_text()) for p in doc)} characters to {out}')
for i,p in enumerate(doc): print(f'Page {i+1}: {len(p.get_text())} characters')
