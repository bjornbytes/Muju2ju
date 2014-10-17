local tween = require 'lib/deps/tween/tween'

HudUpgrades = class()

function HudUpgrades:init()
  self.active = false
  self.time = 0
  self.prevTime = self.time
  self.maxTime = .45
  self.factor = {value = 0}
  self.tween = tween.new(self.maxTime, self.factor, {value = 1}, 'inOutBack')
end

function HudUpgrades:update()
  self.active = love.keyboard.isDown('tab')
  self.prevTime = self.time
  if self.active then self.time = math.min(self.time + tickRate, self.maxTime)
  else self.time = math.max(self.time - tickRate, 0) end
end

function HudUpgrades:draw()
  --
end

function HudUpgrades:keypressed(key)
  --
end

function HudUpgrades:keyreleased(key)
  --
end

function HudUpgrades:mousereleased(x, y, button)
  --
end

function HudUpgrades:gamepadpressed(gamepad, button)
  --
end
