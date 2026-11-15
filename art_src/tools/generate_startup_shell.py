"""Build the self-contained Web loader from the owner's earlier Knit + Tin assets.

Run: python art_src/tools/generate_startup_shell.py
Source provenance and font licenses: art_src/ui/startup/.
"""
import base64
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'art_src/ui/startup'

def embedded(name, mime):
    return 'data:' + mime + ';base64,' + base64.b64encode((SOURCE / name).read_bytes()).decode()

template = (ROOT / 'web/startup_shell.template.html').read_text(encoding='utf8')
for name, mime in [('knit_red.png', 'image/png'), ('fair_isle_big.png', 'image/png'),
                   ('knit_overlay.png', 'image/png'), ('hat_santa.png', 'image/png'),
                   ('claus_3q.png', 'image/png'), ('BowlbyOne-Regular.ttf', 'font/ttf'),
                   ('NewRocker-latin.woff2', 'font/woff2')]:
    template = template.replace('@@' + name + '@@', embedded(name, mime))
assert '@@' not in template
licenses = '\n\n'.join((SOURCE / name).read_text(encoding='utf8') for name in
                       ['OFL_bowlbyone.txt', 'OFL_newrocker.txt'])
template = template.replace('</head>', '<!-- Bundled font licenses:\n' + licenses + '\n-->\n</head>')
(ROOT / 'web/shell.html').write_text(template, encoding='utf8')
print('Generated web/shell.html:', len(template.encode('utf8')), 'bytes')
