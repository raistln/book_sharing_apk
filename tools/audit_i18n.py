import os
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

# Scan UI dart files for hardcoded strings (not using S.of)
ui_files = []
for root, dirs, files in os.walk('lib/ui'):
    dirs[:] = [d for d in dirs if d not in ['generated']]
    for f in files:
        if f.endswith('.dart') and not f.endswith('.g.dart'):
            ui_files.append(os.path.join(root, f))

# Pattern to find hardcoded string literals used in widget contexts
pattern = re.compile(
    r"(?:Text|title|label|hint|tooltip|message|content|body|subtitle)\s*[:(]\s*'([^']{3,})'|"
    r"const\s+Text\s*\(\s*'([^']{3,})'"
)

results = {}
for fp in ui_files:
    with open(fp, encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    matches = []
    for m in pattern.finditer(content):
        s = m.group(1) or m.group(2)
        if s and len(s) > 3:
            skip_words = ['/', 'package:', 'assets/', 'http', '.dart', '.arb',
                          'uuid', 'ISBN', 'Error:', 'debug', 'TODO', '##', '@@', 'UTF']
            if not any(x in s for x in skip_words):
                line_num = content[:m.start()].count('\n') + 1
                matches.append((line_num, s))
    
    if matches:
        results[fp] = matches

print(f'Files with potentially hardcoded strings: {len(results)}')
print()
for fp, matches in sorted(results.items()):
    print(f'--- {fp} ---')
    for line, s in matches[:40]:
        try:
            safe_s = s.encode('ascii', errors='replace').decode('ascii')
        except Exception:
            safe_s = repr(s)
        print(f'  L{line}: {safe_s}')
    print()
