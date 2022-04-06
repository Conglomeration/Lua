------------------------------------------------------------------------------------------------------------------
local Util = require('util')
local CFrameSerializer = {}
------------------------------------------------------------------------------------------------------------------
-- Encoder
function CFrameSerializer:EncodeCFrame( cf )
  local Position = cf.Position
  local LookVector = cf.LookVector;

  return Position.X .. ',' .. Position.Y .. ',' .. Position.Z .. '/' .. LookVector.X .. ',' .. LookVector.Y .. ',' .. LookVector.Z
end
-- Decoder
function CFrameSerializer:DecodeCFrame(
  str
 )
  str = str:gsub(' ','')
  local split = Util.split_fast(str, '/')
  local PosXYZ = Util.split_fast(str[1],',')
  local LookVectorXYZ = str[2] and Util.split_fast(str[2],',') or {0,0,0}
  local Position = Vector3.new(PosXYZ[1], PosXYZ[2], PosXYZ[3]);
  local LookVector = Vector3.new(LookVectorXYZ[1], LookVectorXYZ[2], LookVectorXYZ[3]);
  return CFrame.lookAt(Position,Position+LookVector)
end

return CFrameSerializer
------------------------------------------------------------------------------------------------------------------
