Input = class()

local lk = love.keyboard
local function strunpack(val)
  if type(val) == 'table' then return unpack(val) end
  return val
end

local axes = {
  x = {
    keyboard = {{'left', 'a'}, {'right', 'd'}},
    gamepad = 'leftx'
  },
  y = {
    keyboard = {{'up', 'w'}, {'down ', 's'}},
    gamepad = 'lefty'
  }
}

local actions = {
  summon = {
    keyboard = ' ',
    gamepad = 'a'
  }
}

function Input:init()
  self.gamepad = nil
  self.dirtyActions = {
    keyboard = {},
    gamepad = {}
  }
end

function Input:update()
  for action in pairs(self.dirtyActions.keyboard) do
    if not self:keyboardAction(actions[action].keyboard) then self.dirtyActions.keyboard[action] = nil end
  end

  for action in pairs(self.dirtyActions.gamepad) do
    if not self.gamepadAction(actions[action].gamepad) then self.dirtyActions.gamepad[action] = nil end
  end
end

-- Axis
function Input:getAxis(axis)
  return self:keyboardAxis(unpack(axes[axis].keyboard)) or self:gamepadAxis(axes[axis].gamepad)
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
  local keyboard = not self.dirtyActions.keyboard[action] and self:keyboardAction(actions[action].keyboard)
  if keyboard then
    self.dirtyActions.keyboard[action] = true
    return true
  end

  local gamepad = not self.dirtyActions.gamepad[action] and self:gamepadAction(actions[action].gamepad)
  if gamepad then
    self.dirtyActions.gamepad[action] = true
    return true
  end

  return false
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
