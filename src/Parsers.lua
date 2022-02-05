local Util = require('util')
local CFrameSerializer = require('CFrameSerializer')
-- Generate Parser
--- datatype Actual typeof return
--- parse String -> Data
--- encode Data -> String
local generateParser = function(datatype, parse, encode) return {[0] = datatype:lower(); [1] = encode; [2] = parse} end
-- List of Datatype encoders and parsers
local Parsers = {
  -- SECTION Lua Datatypes
  -- ANCHOR color3
  generateParser('color3', function(c3) return c3.R .. '\6' .. c3.G .. '\6' .. c3.B end,
                 function(str) return Color3.new(Util.split_fast(str, '\6')) end);
  -- ANCHOR nil
  generateParser('nil', function() end, function() return '' end);
  -- ANCHOR string
  generateParser('String', function(str) return str end, function(str) return str end);
  -- ANCHOR number
  generateParser('Number', function(str) return tostring(str) end, function(str) return tonumber(str) end);
  -- ANCHOR function (warns/errors)
  generateParser('function', function(str)
    warn(
        'Unable to encode functions. Encoding functions will not be added in a future version.\nPlease implement your own lua bytecode parser and use a string to transmit this data.\nReturning nothing')
    return '';
  end, function(str)
    warn('Unable to parse functions. Might be added in a future version. Returning empty function')
    return function() error('Cannot parse functions yet. Please try again later', 2) end;
  end);
  -- ANCHOR userdata
  generateParser('UserData', function()
    error('Cannot parse UserData - Try adding a parser/encoder to Conglomeration for this specific type')
  end, function() error('Cannot encode UserData - Try adding a parser/encoder to Conglomeration for this specific type') end);
  -- !SECTION
  -- SECTION Roblox DataTypes
  -- ANCHOR UDim
  generateParser('UDim', function(udim) return udim.Scale .. '\6' .. udim.Offset end, function(str)
    local split = Util.split_fast(str, '\6')
    return UDim.new(split[1], split[2])
  end);
  -- ANCHOR UDim2
  generateParser('UDim2',
                 function(u2) return u2.X.Scale .. '\6' .. u2.Y.Scale .. '\6' .. u2.X.Offset .. '\6' .. u2.Y.Offset end,
                 function(str)
    local split = Util.split_fast(str, '\6')
    return UDim2.new(split[1], split[2], split[3], split[4])
  end);
  -- ANCHOR Vector3
  generateParser('Vector3', function(v3) return v3.X .. '\6' .. v3.Y .. '\6' .. v3.Z end, function(str)
    local split = Util.split_fast(str, '\6')
    return Vector3.new(split[1], split[2], split[3])
  end);
  -- ANCHOR Vector2
  generateParser('Vector2', function(v2) return v2.X .. '\6' .. v2.Y end, function(str)
    local split = Util.split_fast(str, '\6')
    return Vector2.new(split[1], split[2])
  end);
  -- ANCHOR CFrame
  generateParser('CFrame', function(cf) return CFrameSerializer:EncodeCFrame(cf) end,
                 function(cf) return CFrameSerializer:DecodeCFrame(cf) end);
  -- !SECTION
}
return Parsers
