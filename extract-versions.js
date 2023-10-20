#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const filePath = path.join(process.env.HOME, '.pnpmvm', 'pnpm-package.json');
const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));

const versionList = Object.keys(data.versions).sort((a, b) => {
	return a.localeCompare(b);
})

// also add majors:
versionList.push('6');
versionList.push('7');
versionList.push('8');

const versionString = versionList.join('\n') + '\n';
fs.writeFileSync(path.join(__dirname, 'versions.txt'), versionString, 'utf8');
