#!/bin/bash
# Installs the required Luarocks Packages
# @copyright (c) @MokiyCodes. All Rights Reserved.
# @dependency Luarocks
# @dependency Lua5.1
# @dependency NPM

luarocks install luasrcdiet --lua-version 5.1
npm install luamin -g