const fs = require('fs-extra');
const idList = JSON.parse(fs.readFileSync('./IDList.json'));
const ids = JSON.parse(fs.readFileSync('./IDs.json'));
fs.writeFileSync(
	'./IDs.md',
	'If you see this, either the file is being generated, or an error occurred during generation!'
);

const tableBegin = `| Version | ID |\n| --- | --- |`;
const MapFunc = (version, id) => {
	return `| ${version} | [\`${id}\`](https://www.roblox.com/library/${id}/) |\n`;
};

const ForIn = (t, cb) => {
	let result = '';
	for (const k in t) {
		if (Object.hasOwnProperty.call(t, k)) {
			const v = t[k];
			result += cb(k, v);
		}
	}
	return result;
};

let Markdown = `
<!-- The below was generated using the Conglomeration -> Lua -> Upload Tool licensed under the MIT License. -->
#### Latest Builds
Latest Release: [\`${ids[0]}\`](https://www.roblox.com/library/${ids[0]}/)<br/>
Latest Pre-Release: [\`${ids[1]}\`](https://www.roblox.com/library/${ids[1]}/)

#### Release Versions
${tableBegin}
${ForIn(idList.release, MapFunc)}

#### Pre-Release Versions
${tableBegin}
${ForIn(idList.pre, MapFunc)}

#### All Versions
${tableBegin}
${ForIn(idList.raw, MapFunc)}`;

fs.writeFileSync('./IDs.md', Markdown);
