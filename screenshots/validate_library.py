"""Validate retained presentation assets and the visual-library links without generating media."""
import json
import re
from pathlib import Path
from PIL import Image

root = Path(__file__).resolve().parent.parent
manifest = json.loads((root / "screenshots/library-captures.json").read_text())
accepted = manifest["accepted"]
assert len({entry["file"] for entry in accepted}) == len(accepted), "Duplicate accepted capture"
for entry in accepted:
    for pattern in (manifest["originalPathPattern"], manifest["presentationPathPattern"]):
        path = root / pattern.format(file=entry["file"])
        assert path.is_file(), f"Missing retained image: {path}"
        with Image.open(path) as image:
            allowed = {"PNG"} if pattern == manifest["presentationPathPattern"] else {"PNG", "JPEG"}
            assert image.format in allowed, f"Unexpected image format: {path}"
            image.verify()

library = (root / "RUMI_SCREEN_LIBRARY.md").read_text()
for link in re.findall(r"\]\(([^)]+)\)", library):
    if link.startswith(("https://", "http://", "#")):
        continue
    target = link.split("#", 1)[0]
    assert (root / target).is_file(), f"Broken local library link: {target}"

qms = "*This is a functional requirements document intended to give Design and Engineering a working starting point. It is not a formal traceable requirements record. Traceable product requirements (MRD/SRS) for regulatory purposes are maintained in Greenlight Guru, the official QMS system of record.*"
assert (root / "RUMI_REQUIREMENTS.md").read_text().rstrip().endswith(qms), "QMS closing note changed"
assert len(re.findall(r"^\| (?:[1-9]|[12][0-9]|3[0-6]|\+[1-7]) \|", library, re.MULTILINE)) == 43, "Feature index must cover 36 retained features and seven additions"
print(f"Verified {len(accepted)} accepted original/slide pairs, local library links, 43 feature rows, and exact QMS closing note.")
print(f"{len(manifest['stagedNotAccepted'])} staged captures remain excluded from the accepted set.")
