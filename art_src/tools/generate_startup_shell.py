"""Build the self-contained Web loader from the Knit + Tin startup assets.

Run: python art_src/tools/generate_startup_shell.py
Source provenance and font licenses: art_src/ui/startup/.
"""
import base64
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'art_src/ui/startup'

def embedded(name, mime):
    folder = ROOT / 'assets/fonts' if name.endswith('.ttf') else SOURCE
    return 'data:' + mime + ';base64,' + base64.b64encode((folder / name).read_bytes()).decode()

template = (ROOT / 'web/startup_shell.template.html').read_text(encoding='utf8')
for name, mime in [('knit_red.png', 'image/png'), ('fair_isle_big.png', 'image/png'),
                   ('knit_overlay.png', 'image/png'), ('hat_santa.png', 'image/png'),
                   ('claus_3q.png', 'image/png'), ('GrenzeGotisch-Bold.ttf', 'font/ttf'),
                   ('NewRocker-Regular.ttf', 'font/ttf'), ('Barlow-Medium.ttf', 'font/ttf')]:
    template = template.replace('@@' + name + '@@', embedded(name, mime))
assert '@@' not in template
licenses = '\n\n'.join((ROOT / 'assets/fonts' / name).read_text(encoding='utf8') for name in
                       ['OFL_grenzegotisch.txt', 'OFL_newrocker.txt', 'OFL_barlow.txt'])
licenses = '\n'.join(line.rstrip() for line in licenses.splitlines())
template = template.replace('</head>', '<!-- Bundled font licenses:\n' + licenses + '\n-->\n</head>')
(ROOT / 'web/shell.html').write_text(template, encoding='utf8')
print('Generated web/shell.html:', len(template.encode('utf8')), 'bytes')
