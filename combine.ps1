Write-Output "Combine.ps1"
Write-Output "Combines all Conglomeration-related Lua Files into one final output file."
Write-Output "Copyright (c) 2021 Mokiy. See https://astolfodev.mit-license.org/ for Licensing Information."
Write-Output ""
Write-Output "@depends LuaSrcDiet"
Write-Output "@depends LuaMin"
Write-Output "@depends LuaCC"
Write-Output "@depends NodeJS >= 16"
Write-Output ""
Set-Location src;
cmd /c lua ../luacc.lua -o ../dist/out-tmp.lua Conglomeration util Parsers Base64 typeof CFrameSerializer;
Set-Location ../dist;
cmd /c node combine-fixtmp.js;
# cmd /c node luamin.js -f out-tmp.lua > out-tmp2.lua;
cmd /c node combine-fixencoding.js;
cmd /c lua ./luasrcdiet.lua out-tmp.lua -o out.lua --opt-entropy --opt-comments --opt-whitespace --opt-emptylines --opt-eols --opt-strings --opt-numbers --opt-locals --details > luasrcdiet.log;
cmd /c node combine-final.js;
Set-Location ..
Write-Output "Done!"
Write-Output ""