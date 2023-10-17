#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const filePath = path.join(process.env.HOME, '.pnpmvm', 'pnpm-package.json');
const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));

const versionList = Object.keys(data.versions).sort((a, b) => {
	return a.localeCompare(b);
})

// TODO: add these later
// versionList.push(`latest: ${data['dist-tags'].latest}`);
// versionList.push(`latest-6: ${data['dist-tags']['latest-6']}`);
// versionList.push(`latest-7: ${data['dist-tags']['latest-7']}`);
// versionList.push(`latest-8: ${data['dist-tags']['latest-8']}`);

const versionString = versionList.join('\n') + '\n';
fs.writeFileSync(path.join(__dirname, 'versions.txt'), versionString, 'utf8');

// also set the default default version:
const latestVersion = data['dist-tags']['latest-8'];
fs.writeFileSync(path.join(__dirname, 'default-version.txt'), latestVersion + '\n', 'utf8');
