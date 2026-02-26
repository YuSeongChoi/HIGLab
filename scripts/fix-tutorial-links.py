#!/usr/bin/env python3
import os
import glob

SITE_DIR = '/Users/leeo/Documents/workspace/code/HIGLab/site'

# Fix Korean tutorials (root level) - link to en/ version
for filepath in glob.glob(f'{SITE_DIR}/*/01-tutorial.html'):
    if '/en/' in filepath:
        continue
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Get framework name from path
    fw = filepath.split('/')[-2]
    
    # Fix EN link: 01-tutorial.en.html → ../en/{fw}/01-tutorial.html
    content = content.replace(
        f'href="01-tutorial.en.html"',
        f'href="../en/{fw}/01-tutorial.html"'
    )
    
    # Update emoji
    content = content.replace('🌐 EN', '🇺🇸 EN')
    
    # Fix hreflang links
    content = content.replace(
        f'href="https://m1zz.github.io/HIGLab/{fw}/01-tutorial.en.html"',
        f'href="https://m1zz.github.io/HIGLab/en/{fw}/01-tutorial.html"'
    )
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f'Fixed: {fw}/01-tutorial.html')

# Fix English tutorials (en/ folder) - link back to root
for filepath in glob.glob(f'{SITE_DIR}/en/*/01-tutorial.html'):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Get framework name from path
    fw = filepath.split('/')[-2]
    
    # Fix KO link: 01-tutorial.html → ../../{fw}/01-tutorial.html
    content = content.replace(
        f'href="01-tutorial.html" class="lang-toggle"',
        f'href="../../{fw}/01-tutorial.html" class="lang-toggle"'
    )
    
    # Update emoji
    content = content.replace('🌐 KO', '🇰🇷 KO')
    
    # Fix home link: ../index.html → ./index.html (stays in en/)
    # Actually should be index.html relative to en/
    content = content.replace(
        'href="../index.html" class="top-logo"',
        'href="../index.html" class="top-logo"'  # This is correct for en/fw/ -> en/
    )
    
    # Fix hreflang for en version
    content = content.replace(
        f'href="https://m1zz.github.io/HIGLab/{fw}/01-tutorial.en.html"',
        f'href="https://m1zz.github.io/HIGLab/en/{fw}/01-tutorial.html"'
    )
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f'Fixed: en/{fw}/01-tutorial.html')

print('\nDone!')
