#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const os = require('os');

const src = path.join(__dirname, '..', 'hig.md');
const destDir = path.join(os.homedir(), '.claude', 'commands');
const dest = path.join(destDir, 'hig.md');

try {
  fs.mkdirSync(destDir, { recursive: true });
  fs.copyFileSync(src, dest);
  console.log('✅ HIG Lab skill installed → ~/.claude/commands/hig.md');
  console.log('   Use /hig in Claude Code to access 50 Apple framework references');
} catch (e) {
  console.error('⚠️  Install failed:', e.message);
}
