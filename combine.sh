echo ""
echo "Combine.sh"
echo "Combines all Conglomeration-related Lua Files into one final output file."
echo "Copyright (c) 2021 Mokiy. See https://astolfodev.mit-license.org/ for Licensing Information."
echo ""
echo "@depends LuaSrcDiet"
echo "@depends LuaMin"
echo "@depends LuaCC"
echo "@depends NodeJS >= 16"
echo ""
cd src;
luacc -o ../dist/out-tmp.lua Conglomeration util Parsers Base64 typeof;
cd ../dist;
node combine-fixtmp.js;
LuaSrcDiet out-tmp.lua -o out-tmp2.lua --opt-entropy --opt-comments --opt-whitespace --opt-emptylines --opt-eols --opt-strings --opt-numbers --opt-locals --details > luasrcdiet.log;
luamin -f out-tmp2.lua > out.lua;
node combine-final.js;
echo "Done!"