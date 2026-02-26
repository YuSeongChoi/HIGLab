#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const os = require('os');

const dest = path.join(os.homedir(), '.claude', 'commands', 'hig.md');

try {
  if (fs.existsSync(dest)) {
    fs.unlinkSync(dest);
    console.log('✅ HIG Lab skill removed');
  }
} catch (e) {
  console.error('⚠️  Uninstall failed:', e.message);
}
