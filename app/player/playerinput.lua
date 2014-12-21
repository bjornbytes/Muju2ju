PlayerInput = class()

local lk = love.keyboard
local function strunpack(val)
  if type(val) == 'table' then return unpack(val) end
  return val
end

local axisMap = {
  x = {
    keyboard = {'a', 'd'},
    gamepad = 'leftx'
  },
  y = {
    keyboard = {{'up', 'w'}, {'down ', 's'}},
    gamepad = 'lefty'
  },
  vx = {
    keyboard = {'left', 'right'},
    gamepad = 'rightx'
  }
}

function PlayerInput:init(owner)
  self.owner = owner
  self.list = {}

  self.gamepad = nil
  self.axes = {}
  self.active = true
end

function PlayerInput:update()
  local smooth = 8
  for axis in pairs(axisMap) do
    local value = self:keyboardAxis(unpack(axisMap[axis].keyboard)) or self:gamepadAxis(axisMap[axis].gamepad)
    self.axes[axis] = math.lerp(self.axes[axis] or 0, value, math.min(smooth * tickRate, 1))
  end

  self.active = not ctx.hud.chat.active
end

function PlayerInput:read()
  local input = self:current()

  input.x = self:getAxis('x')
  input.y = self:getAxis('y')
  input.summon = lk.isDown(' ')

  if self.owner.summonTimer > 0 then
    input.x = 0
  end

  if self.owner.animation.state.name == 'summon' then
    input.x = 0
  elseif self.owner.animation.state.name == 'resurrect' then
    input.x = 0
    input.summon = false
  end
 
  local vx = self:getAxis('vx')
  ctx.view.vx = 1000 * vx

  return input
end

function PlayerInput:keypressed(key)
  local input = self:current(tick + 1)

  if key == 'q' then
    input.ability = 1
    return
  elseif key == 'e' then
    input.ability = 2
    return
  end

  for stance, hotkey in pairs({'z', 'x', 'c'}) do
    if key == hotkey then
      input.stance = stance
      return
    end
  end

  for i = 1, #self.owner.deck do
    if i == tonumber(key) then
      input.selected = i
      return
    end
  end
end

function PlayerInput:keyreleased(key)

end

function PlayerInput:mousepressed(x, y, b)
  if b ~= 'l' then return end

  local input = self:current(tick + 1)
  for i = 1, #self.owner.deck do
    if self.owner.deck[i].instance and self.owner.deck[i].instance.animation:contains(x, y) then
      input.selected = i
      return
    end
  end
end

function PlayerInput:current(t)
  local t = t or tick
  local latest = self.list[#self.list]
  if latest and latest.tick == t then return latest end
  
  table.insert(self.list, {tick = t})
  return self.list[#self.list]
end

-- Axis
function PlayerInput:getAxis(axis)
  return self.axes[axis]
end

function PlayerInput:clearAxis(axis)
  self.axes[axis] = 0
end

function PlayerInput:keyboardAxis(neg, pos)
  neg = lk.isDown(strunpack(neg))
  pos = lk.isDown(strunpack(pos))
  return neg and -1 or (pos and 1 or 0)
end

function PlayerInput:gamepadAxis(axis)
  if not self.gamepad then return false end
  local val = self.gamepad:getGamepadAxis(axis)
  return math.abs(val) > .25 and val or 0
end

-- Gamepad detection
function PlayerInput:joystickadded(joystick)
  if joystick:isGamepad() then self.gamepad = joystick
  else self:refreshGamepad() end
end

function PlayerInput:joystickremoved()
  self:refreshGamepad()
end

function PlayerInput:refreshGamepad()
  local joysticks = love.joystick.getJoysticks()
  self.gamepad = nil
  for i = 1, #joysticks do
    if joysticks[i]:isGamepad() then
      self.gamepad = joysticks[i]
      return
    end
  end
end
