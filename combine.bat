@echo off
@REM del dist /f /q
@REM rmdir dist
@REM mkdir dist
cmd /c luacc -o dist/out-tmp.lua Conglomeration util Parsers Base64 typeof
cd dist
cmd /c node combine-fixtmp.js
cmd /c LuaSrcDiet out-tmp.lua -o out-tmp2.lua --opt-entropy --opt-comments --opt-whitespace --opt-emptylines --opt-eols --opt-strings --opt-numbers --opt-locals --details
cmd /c luamin -f out-tmp2.lua > out.lua
@REM del out-tmp.lua