const fs = require('fs-extra');
const idList = JSON.parse(fs.readFileSync('./IDList.json'));
const ids = JSON.parse(fs.readFileSync('./IDs.json'));
const namePrefix = 'Conglomeration v';
// fs.writeFileSync(
// 	'./IDs.md',
// 	'If you see this, either the file is being generated, or an error occurred during generation!'
// );

const tableBegin = `| Version | ID  |\n| ------- | --- |`;
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

const noblox = require('noblox.js');

(async () => {
	const id0 = await noblox.getProductInfo(ids[0]);
	const id1 = await noblox.getProductInfo(ids[1]);

	let Markdown = `<!--BEGIN @GENERATED-->
<!-- The below was generated using the Conglomeration -> Lua -> Upload Tool licensed under the MIT License. -->
### Latest Builds
| Release Type | Version | ID                                                         |
| ------------ | ------- | ---------------------------------------------------------- |
| Release      | ${id0.Name.replace(namePrefix, '')} | [\`${
		ids[0]
	}\`](https://www.roblox.com/library/${ids[0]}/) |
| Pre-Release  | ${id1.Name.replace(namePrefix, '')} | [\`${
		ids[1]
	}\`](https://www.roblox.com/library/${ids[1]}/) |

### Release Versions
${tableBegin}
${ForIn(idList.release, MapFunc)}

### Pre-Release Versions
${tableBegin}
${ForIn(idList.pre, MapFunc)}

### All Versions
${tableBegin}
${ForIn(idList.raw, MapFunc)}`;

	fs.writeFileSync('./IDs.md', Markdown);
	fs.writeFileSync(
		'../Roblox.md',
		fs
			.readFileSync('../Roblox.md', 'utf-8')
			.split('<!--BEGIN @GENERATED-->')[0] + Markdown
	);
})();
