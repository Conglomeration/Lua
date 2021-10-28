-- Conglomeration
-- A tool to allow saving/loading many different roblox datatypes, aswell as some minor compression for some non-roblox datatypes
local typeof = require('typeof')
local Util = require('util')
local Parsers = require('Parsers')
local b64 = require('Base64')

local formatVersion = 'STANDARD-0.1.0';

local _DEBUGOUT = 0 -- SET TO 0 IF NOT TRYING TO DEBUG OUTPUTTED CODE | BREAKS FORMAT | 0=DEFAULT (USE THIS PLS), 1=Normal human-readable, 2=YML-Array | BREAKS EDGE-CASES

--- List of header-codes
local hcode = {
  ['HEADER_BEGIN'] = '\1';
  ['END_HEADER_FIELD'] = '\7'; -- present after every DATA_ hcode excluding DATA_BEGIN
  ['DATA_NAME'] = '\3';
  ['DATA_TYPE'] = '\4';
  ['DATA_LENGTH'] = '\5';
  ['DATA_LAST'] = '\11'; -- is last chunk?
  ['DATA_BEGIN'] = '\6'; -- Shown at the beginning of each body, ends the header
  ['FORMAT_VERSION_BEGIN'] = '\8';
  ['FORMAT_VERSION_END'] = '\9';
}
if _DEBUGOUT ~= 0 then
  formatVersion =
    'DEBUGOUT.' .. _DEBUGOUT .. '-' ..
      formatVersion
  if _DEBUGOUT == 1 then
    for k in pairs(hcode) do
      hcode[k] = '\n[' .. k .. ']'
    end
  elseif _DEBUGOUT == 2 then
    for k in pairs(hcode) do
      hcode[k] = '\n- hcode-' .. k .. ': '
    end
  end
end
for k, v in pairs(hcode) do hcode[v] = k end

-- ANCHOR Get Parser
local getParser = function( dataType )
  for _, o in pairs(Parsers) do
    if o[0] == dataType then return o end
  end
  error(
    'No parser found for datatype ' .. dataType
  )
end

-- SECTION Decode
-- ANCHOR String -> Chunk[]
local dataToChunkList = function( data )
  local hcode = hcode
  if _DEBUGOUT > 0 then
    local _hcode = {}
    for a, b in pairs(hcode) do
      _hcode[a] = string.gsub(b, '\n', '')
      data = data:gsub('\n', '')
    end
    hcode = _hcode
  end

  -- Check Header
  local stringHeader =
    hcode.FORMAT_VERSION_BEGIN .. formatVersion ..
      hcode.FORMAT_VERSION_END;
  if not data:sub(1, #stringHeader) ==
    stringHeader then
    error(
      'Incompatible Data Format (Header Mismatch)'
    )
  end

  data =
    string.sub(data, #stringHeader + 1, #data)

  -- Parse Data
  local chunks = {};

  local read = function( addToChunkList )
    -- print('Decoding Chunk:', data)
    local find =
      ({ data:find(hcode.DATA_BEGIN) })[2]
    if not find then
      error(
        'Cannot find DATA_BEGIN (' ..
          hcode.DATA_BEGIN .. ')'
      )
    end

    local rawChunkHeader = string.sub(
      data, 1, find
    )

    local readChunkField =
      function( hc )
        if not hc then
          error('INTERNAL: !hc')
        end
        local endField = hcode.END_HEADER_FIELD
        local _data = rawChunkHeader;
        local find1 = ({ _data:find(hc) })[1]
        if not find1 then
          error('Cannot find hc: ' .. hc, 2)
        end
        _data = string.sub(_data, find1 + 1)
        local find2 =
          ({ _data:find(endField) })[1]
        if not find2 then
          error('Cannot find end-hc', 2)
        end

        _data = string.sub(_data, 1, find2 - 1)

        return _data
      end

    local chunk = {}

    chunk.Name = b64.decode(
      readChunkField(
        hcode.DATA_NAME
      )
    )
    chunk.Type = readChunkField(hcode.DATA_TYPE)
    chunk.Length = tonumber(
      readChunkField(
        hcode.DATA_LENGTH
      )
    )
    chunk.__isLastChunk =
      readChunkField(
        hcode.DATA_LAST
      ) == 'true'
    chunk.Data = string.sub(
      data, find + 1, find + chunk.Length
    );
    -- print(
    --   'Decoded Chunk:', chunk.Name, chunk.Type,
    --   chunk.Length,
    --   chunk.__isLastChunk and 'LAST' or '!LAST',
    --   chunk.Data
    -- )

    if addToChunkList then
      table.insert(chunks, chunk)
    end

    data = string.sub(
      data, find + chunk.Length, #data
    )

    return chunk
  end
  local integretyChunk = read();
  if not integretyChunk.Name ==
    '\1________checkIntegrety' then
    error(
      'Invalid Integrety Check Chunk!\nSpec requires 1st chunk to be an integrety chunk'
    )
  end
  if (not integretyChunk.__isLastChunk) then
    local chunk = { __isLastChunk = false }
    repeat chunk = read(true) until chunk.__isLastChunk
  end
  return chunks
end
-- ANCHOR Chunk -> Content
local chunkToContent = function( chunk )
  local parser = getParser(chunk.Type)
  local decode = parser[1];
  return decode(chunk.Data)
end
-- ANCHOR String -> Record<string,ChunkContent>
-- NAME decode
local decode = function( data )
  local chunkList = dataToChunkList(data)
  local record = {}
  for _, chunk in pairs(chunkList) do
    record[chunk.Name] = chunkToContent(chunk)
  end
  return record
end
-- !SECTION

-- SECTION Encode
-- DESCRIPTION Encodes input into a chunk list
-- ANCHOR Content -> Chunk
local contentToChunk = function( name, content )
  if not name then error('No name specified') end
  if typeof(name) ~= 'string' then
    error('Name is not a string')
  end
  if string.find(name, hcode.END_HEADER_FIELD) then
    error(
      'Name cannot contain the symbol ' ..
        hcode.END_HEADER_FIELD
    )
  end
  name = b64.encode(name)

  local _dataType = typeof(content)
  local parser = getParser(_dataType)
  local encode = parser[2];
  local chunk = {}
  chunk.Name = name;
  chunk.Type = _dataType;
  chunk.Data = encode(content);
  chunk.Length = #chunk.Data;
  return chunk
end
-- ANCHOR Chunk[] -> String
local chunkListToData = function( chunkList )
  local data = '';

  local v = function( ... )
    local x = { ... }
    if #x > 1 then
      return table.concat({ ... }, '')
    else
      return x[1]
    end
  end

  local encodeChunk = function( _chunk,
    isLast )
    local chunk = hcode.HEADER_BEGIN
    local addToChunk = function( ... )
      chunk = chunk .. v(...)
    end

    -- Chunk Name
    addToChunk(
      hcode.DATA_NAME, _chunk.Name,
      hcode.END_HEADER_FIELD
    )
    -- Chunk Type
    addToChunk(hcode.DATA_TYPE, _chunk.Type)
    addToChunk(hcode.END_HEADER_FIELD)
    -- Chunk Length
    addToChunk(
      hcode.DATA_LENGTH, _chunk.Length,
      hcode.END_HEADER_FIELD
    )
    -- Is last chunk
    addToChunk(
      hcode.DATA_LAST, tostring(isLast),
      hcode.END_HEADER_FIELD
    )
    -- Data
    addToChunk(hcode.DATA_BEGIN, _chunk.Data)

    -- Return Encoded Chunk
    return chunk
  end

  for x, _chunk in pairs(chunkList) do
    if x == #chunkList then
      data = data .. encodeChunk(_chunk, true)
    else
      data = data .. encodeChunk(_chunk, false)
    end
  end

  return hcode.FORMAT_VERSION_BEGIN ..
           formatVersion ..
           hcode.FORMAT_VERSION_END ..
           encodeChunk(
      contentToChunk(
        '\1________checkIntegrety', 'works'
      )
    ) .. data
end
-- ANCHOR Record<string,ChunkContent> -> String
local encode = function( record )
  local chunks = {}
  for key, value in pairs(record) do
    table.insert(
      chunks, contentToChunk(key, value)
    )
  end
  return chunkListToData(chunks)
end
-- !SECTION

Parsers.table = {
  [0] = 'table';
  [1] = function( str )
    local chunks = dataToChunkList(str)
    local t = {}
    for _, chunk in pairs(chunks) do
      t[chunk.Name] = chunkToContent(chunk)
    end
    return t
  end;
  [2] = function( data )
    local chunks = {};
    for a, b in pairs(data) do
      if typeof(a) ~= 'string' and typeof(a) ~=
        'number' then
        error(
          'Only string/number-based keys are allowed for tables!'
        )
      end
      table.insert(
        chunks, contentToChunk(tostring(a), b)
      )
    end
    return chunkListToData(chunks)
  end;
}

-- Base Conglomeration Table
local Conglomeration = {}

-- Expose Functions
Conglomeration.__Parsers = Parsers;
Conglomeration.__ENCODING = {
  ['\1'] = chunkListToData;
  ['\2'] = contentToChunk;
}
Conglomeration.__DECODING = {
  ['\1'] = dataToChunkList;
  ['\2'] = chunkToContent;
}
Conglomeration.__Util = Util

print(
  decode(
    encode(
      {
        ['Name lmao'] = 'Value lmao';
        ['someName'] = { a = 'abcdefg' };
      }
    )
  )['Name lmao']
)

return Conglomeration
