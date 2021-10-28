const fs = require('fs');
// Convert to UTF8
fs.writeFileSync('out-tmp2.lua', fs.readFileSync('out-tmp2.lua', 'utf16le'), {
	encoding: 'utf-8',
});
