local util = {}

util.forEach = function( t, cb )
  for index, value in pairs(t) do
    cb(value, index)
  end
end;
util.split_fast = function( inputstr, sep )
  if sep == nil then sep = '%s' end
  local t = {}
  for str in string.gmatch(
    inputstr, '([^' .. sep .. ']+)'
  ) do table.insert(t, str) end
  return t
end
util.split = function( inputstr, sep )
  sep = sep or '%s'
  local t = {}
  for field, s in string.gmatch(
    inputstr,
    '([^' .. sep .. ']*)(' .. sep .. '?)'
  ) do
    table.insert(t, field)
    if s == '' then return t end
  end
end

return util
