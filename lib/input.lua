Input = class()

Input.devices = {
  keyboard = {
    action = 'isDown',
    axis = 'isDown'
  },
  gamepad = {
    action = 'isGamepadDown',
    axis = 'getGamepadAxis'
  }
}

Input.map = {
  axis = {
    x = {
      keyboard = {positive = {'left', 'a'}, negative = {'right', 'd'}},
      gamepad = 'leftx'
    },
    y = {
      keyboard = {positive = {'down', 's'}, negative = {'up', 'w'}},
      gamepad = 'lefty'
    }
  },
  action = {
    summon = {
      keyboard = ' ',
      gamepad = 'a'
    }
  }
}

function Input:init()
  self.keyboard = love.keyboard
  self.gamepad = nil
  self.dirtyActions = {}
end

function Input:update()
  --
end

function Input:getAxis(what)
  --
end

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
