local tween = require 'lib/deps/tween/tween'

Lepr = class()

local function route(t, k, v)
  local mt = getmetatable(t)
  if mt.__tween[k] then mt.__tweento[k] = v
  else rawset(t, k, v) end
end

function Lepr:init(target, duration, kind, vars)
  local mt = getmetatable(target)
  mt.__tween = setmetatable(table.only(target, vars), {__index = mt.__index})
  mt.__tweento = table.only(target, vars)
  mt.__index = mt.__tween
  mt.__newindex = route
  table.each(vars, function(k) target[k] = nil end)
  self.tween = tween.new(duration, mt.__tween, mt.__tweento, kind)
end

function Lepr:update(dt) self.tween:update(dt) end
