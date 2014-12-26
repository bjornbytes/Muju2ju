Hud = class()

local g = love.graphics

function Hud:init()
  self.health = HudHealth()
  self.target = HudTarget()
  self.countdown = HudCountdown()
  self.units = HudUnits()
  self.resources = HudResources()
  self.chat = HudChat()
  self.upgrades = HudUpgrades()
  self.dead = HudDead()
  self.tooltip = Tooltip()

  self.u = ctx.view.frame.width
  self.v = ctx.view.frame.height

  ctx.event:emit('view.register', {object = self, mode = 'gui'})
end

function Hud:update()
  self.tooltip:update()

  self.target:update()
  self.countdown:update()
  self.units:update()
  self.chat:update()
  self.upgrades:update()
  self.dead:update()
end

function Hud:gui()
  if ctx.net.state == 'connecting' then
    g.setFont('pixel', 8)
    g.setColor(255, 255, 255)
    g.print('connecting', g.getWidth() / 2 - g.getFont():getWidth('connecting') / 2, g.getHeight() / 2 - g.getFont():getHeight() / 2)
    return
  elseif ctx.net.state == 'waiting' then
    g.setFont('pixel', 8)
    g.setColor(255, 255, 255)
    g.print('waiting for players', g.getWidth() / 2 - g.getFont():getWidth('waiting for players') / 2, g.getHeight() / 2 - g.getFont():getHeight() / 2)
    return
  end

  self.health:draw()
  self.target:draw()
  self.countdown:draw()
  self.units:draw()
  self.resources:draw()
  self.chat:draw()
  self.dead:draw()
  self.tooltip:draw()
end

function Hud:keypressed(key)
  self.chat:keypressed(key)
  self.upgrades:keypressed(key)
end

function Hud:keyreleased(key)
  self.upgrades:keyreleased(key)
end

function Hud:mousepressed(...)
  self.units:mousepressed(...)
end

function Hud:mousereleased(...)
  self.dead:mousereleased(...)
end

function Hud:textinput(char)
  self.chat:textinput(char)
end

function Hud:gamepadpressed(...)
  self.upgrades:gamepadpressed(...)
end

function Hud:resize()
  self.u = ctx.view.frame.width
  self.v = ctx.view.frame.height
  self.chat:resize()
  self.tooltip:resize()
end

function Hud:ready()
  self.units:ready()
  self.countdown:ready()
end
