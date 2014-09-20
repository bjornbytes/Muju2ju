Hud = class()

local g = love.graphics

function Hud:init()
  self.particles = Manager('particle')

  self:resize()

  self.normalFont = g.newFont('media/fonts/inglobal.ttf', 14)
  self.boldFont = g.newFont('media/fonts/inglobalb.ttf', 14)
  self.titleFont = g.newFont('media/fonts/inglobal.ttf', 24)

  self.health = HudHealth()
  self.protect = HudProtect()
  self.juju = HudJuju()
  self.minions = HudMinions()
  self.timer = HudTimer()
  self.tutorial = HudTutorial()
  self.upgrades = HudUpgrades()
  self.pause = HudPause()
  self.dead = HudDead()

  ctx.view:register(self, 'gui')
end

function Hud:update()
  self.protect:update()
  self.juju:update()
  self.minions:update()
  self.timer:update()
  self.tutorial:update()
  self.upgrades:update()
  self.pause:update()
  self.dead:update()

  -- TODO
  self.particles:update()
  if ctx.ded then love.keyboard.setKeyRepeat(true) end -- events
end

function Hud:gui()
  self.health:draw()
  self.protect:draw()
  self.juju:draw()
  self.minions:draw()
  self.timer:draw()
  self.tutorial:draw()
  self.upgrades:draw()
  self.pause:draw()
  self.dead:draw()
end

function Hud:keypressed(key)
  self.upgrades:keypressed(key)
  self.dead:keypressed(key)
end

function Hud:mousereleased(...)
  self.upgrades:mousereleased(...)
  self.dead:mousereleased(...)
  self.pause:mousereleased(...)
end

function Hud:textinput(char)
  self.dead:textinput(char)
end

function Hud:gamepadpressed(...)
  self.upgrades:gamepadpressed(...)
end

function Hud:resize()
  self.u = ctx.view.frame.width
  self.v = ctx.view.frame.height
end
