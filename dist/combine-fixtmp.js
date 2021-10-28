// add polyfill
const s = `
-- localize globals
local require = require;
local math = math;
local bit = bit or bit32;
local error = error;
local table = table;
local string = string;
local pairs = pairs;
local setmetatable = setmetatable;
local print = print;
local tonumber = tonumber;
local ipairs = ipairs;

-- general polyfill
local fenv = (getfenv or function()return _ENV end)();
local package = --[[fenv.package or]] {["searchers"]={[2]=function(p) error("Module not bundled: "..p) end}}
if _VERSION == "Luau" then
  require = (function(...) return package["searchers"][2](...)() end);
  math = setmetatable({["mod"]=math.fmod},{__index=fenv.math})
end
`;

const fs = require('fs');
fs.writeFileSync('out-tmp.lua', s + fs.readFileSync('out-tmp.lua', 'utf-8'));
