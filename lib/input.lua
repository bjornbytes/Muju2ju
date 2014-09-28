Input = class()

local lk = love.keyboard
local function strunpack(val)
  if type(val) == 'table' then return unpack(val) end
  return val
end

local axisMap = {
  x = {
    keyboard = {{'left', 'a'}, {'right', 'd'}},
    gamepad = 'leftx'
  },
  y = {
    keyboard = {{'up', 'w'}, {'down ', 's'}},
    gamepad = 'lefty'
  }
}

local actionMap = {
  summon = {
    keyboard = ' ',
    gamepad = 'a'
  }
}

function Input:init()
  self.gamepad = nil
  self.axes = {}
  self.actions = {}
end

function Input:update()
  for action in pairs(actionMap) do
    if self.actions[action] then
      self.actions[action] = false
    else
      self.actions[action] = self:keyboardAction(actionMap[action].keyboard)
      self.actions[action] = self.actions[action] or self:gamepadAction(actionMap[action].gamepad)
    end
  end

  local p = ctx.players:get(ctx.id)
  local smooth = p.dead and 3 or 10
  for axis in pairs(axisMap) do
    local value = self:keyboardAxis(unpack(axisMap[axis].keyboard)) or self:gamepadAxis(axisMap[axis].gamepad)
    self.axes[axis] = math.lerp(self.axes[axis] or 0, value, math.min(smooth * tickRate, 1))
  end
end

-- Axis
function Input:getAxis(axis)
  return self.axes[axis]
end

function Input:keyboardAxis(neg, pos)
  neg = lk.isDown(strunpack(neg))
  pos = lk.isDown(strunpack(pos))
  return neg and -1 or (pos and 1 or 0)
end

function Input:gamepadAxis(axis)
  if not self.gamepad then return false end
  local val = self.gamepad:getGamepadAxis(axis)
  return math.abs(val) > .25 and val or 0
end

-- Action
function Input:getAction(action)
  return self.actions[action] == true
end

function Input:keyboardAction(buttons)
  return lk.isDown(strunpack(buttons))
end

function Input:gamepadAction(buttons)
  return self.gamepad and self.gamepad:isGamepadDown(strunpack(buttons))
end

-- Gamepad detection
function Input:joystickadded(joystick)
  if joystick:isGamepad() then self.gamepad = joystick
  else self:refreshGamepad() end
end

function Input:joystickremoved()
  self:refreshGamepad()
end

function Input:refreshGamepad()
  local joysticks = love.joystick.getJoysticks()
  self.gamepad = nil
  for i = 1, #joysticks do
    if joysticks[i]:isGamepad() then
      self.gamepad = joysticks[i]
      return
    end
  end
end
