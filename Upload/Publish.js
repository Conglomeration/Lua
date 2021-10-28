const fs = require('fs-extra');
if (!fs.existsSync('./TOKEN.txt'))
	error('ROBLOSECURITY file (TOKEN.txt) not found!');

const ROBLOSECURITY = fs.readFileSync('./TOKEN.txt', 'utf-8').split('\n')[0];
const Version = fs.readFileSync('../VERSION.txt', 'utf-8').split('\n')[0];
let Build = fs.readFileSync('../dist/out.lua', 'utf-8');
const SampleScript = fs.readFileSync('./SampleScript.rbxmx', 'utf-8');
const isBeta = Version.includes('-');
if (!fs.existsSync('./IDs.json')) fs.writeFileSync('./IDs.json', '[]');
if (!fs.existsSync('./IDList.json')) fs.writeFileSync('./IDList.json', '{}');
const ids = JSON.parse(fs.readFileSync('./IDs.json', 'utf-8'));
const idHistory = JSON.parse(fs.readFileSync('./IDList.json', 'utf-8'));
idHistory.raw = idHistory.raw ?? {};
idHistory.release = idHistory.release ?? {};
idHistory.pre = idHistory.pre ?? {};
let id = 0;
if (isBeta) id = 1;

if (!ids[id]) ids[id] = -1;

let Model = SampleScript.split('%ID%').join(id);

Build = Build.split('<').join('&lt;').split('>').join('&gt;');

Model = Model.split('%SOURCE%').join(Build);

fs.writeFileSync('Module.rbxmx', Buffer.from(Model), {
	encoding: 'utf-8',
});

const namePrefix = 'Conglomeration v';

const addToIDHistory = id => {
	idHistory.raw[Version] = id;
	const ispre = semver.prerelease(Version);
	idHistory[ispre && ispre[0] ? 'pre' : 'release'][Version] = id;
	console.log(idHistory[ispre && ispre[0] ? 'pre' : 'release']);
	fs.writeFileSync('./IDList.json', JSON.stringify(idHistory, null, 2));
};

const semver = require('semver');
const noblox = require('noblox.js');
const start = async () => {
	// You MUST call setCookie() before using any authenticated methods [marked by 🔐]
	// Replace the parameter in setCookie() with your .ROBLOSECURITY cookie.
	const currentUser = await noblox.setCookie(ROBLOSECURITY);
	console.log(`Logged in as ${currentUser.UserName} [${currentUser.UserID}]`);

	// Do everything else, calling functions and the like.
	// const groupInfo = await noblox.uploadModel('');
	const createNewModel = async () => {
		const newModel = await noblox.uploadModel(
			SampleScript.split('%ID%').join('-1').split('%SOURCE%').join(''),
			{
				name: 'Script | Waiting for Upload',
				description:
					'Will contain Conglomeration / Lua (Minified) once Uploaded.',
				copyLocked: false,
				allowComments: true,
			}
		);
		console.log('Created new Model', newModel.AssetId);
		ids[id] = newModel.AssetId;
		addToIDHistory(newModel.AssetId);
	};
	if (ids[id] == -1) await createNewModel();
	else {
		const Data = await noblox.getProductInfo(ids[id]);
		const v = Data.Name.replace(namePrefix, '');
		if (!semver.valid(v))
			throw new Error(
				'Invalid Semver Version. Pleasae delete your IDs.json and try again'
			);
		const diff = semver.diff(v, Version);
		if (
			diff == 'major' ||
			diff == 'minor' ||
			diff == 'premajor' ||
			diff == 'preminor'
		)
			await createNewModel();
	}

	const upload = async _id => {
		console.log('Uploading Model');
		await noblox.uploadModel(Model, {}, _id);
		console.log('Updating Model Name/Description');
		await noblox.configureItem(
			_id,
			namePrefix + Version,
			'Module for Conglomeration / Lua | Minified',
			true,
			true
		);
		addToIDHistory(_id);
	};
	await upload(ids[id]);
	console.log('Uploaded to ' + ids[id]);
	fs.writeFileSync('./IDs.json', JSON.stringify(ids));
	console.log('Updating IDs.md');
	require('./IDListToMD');
};
start();
