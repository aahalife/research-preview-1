"""Start a disposable local preview process for browser verification."""
import subprocess
from pathlib import Path
log = Path('/tmp/rumi-vite.log').open('w')
p = subprocess.Popen(['bun', 'run', 'dev', '--host', '0.0.0.0'], cwd='web', stdout=log, stderr=log, start_new_session=True)
print(f'Vite PID {p.pid}; log /tmp/rumi-vite.log')
