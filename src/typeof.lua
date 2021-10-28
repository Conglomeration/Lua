-- typeof/getfenv compat
local getfenv = getfenv or
                  function() return _ENV end
local _typeof =
  getfenv().typeof or getfenv().type or function()
    error(
      'Type/Typeof is undefined. Please define it before loading Conglomeration'
    )
  end

typeof = function( ... )
  return _typeof(...):lower()
end

if (typeof'' ~= 'string') then
  error('Typeof returns invalid type')
end
return typeof;
