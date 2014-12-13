Hud = class()

local g = love.graphics

function Hud:init()
  self.particles = Manager('particle')

  self.normalFont = g.newFont('media/fonts/inglobal.ttf', 14)
  self.boldFont = g.newFont('media/fonts/inglobalb.ttf', 14)
  self.titleFont = g.newFont('media/fonts/inglobal.ttf', 24)

  self.health = HudHealth()
  self.protect = HudProtect()
  self.selector = HudSelector()
  self.juju = HudJuju()
  self.portrait = HudPortrait()
  self.minions = HudMinions()
  self.shruju = HudShruju()
  self.timer = HudTimer()
  self.tutorial = HudTutorial()
  self.chat = HudChat()
  self.upgrades = HudUpgrades()
  self.pause = HudPause()
  self.dead = HudDead()
  self.tooltip = Tooltip()

  self.u = ctx.view.frame.width
  self.v = ctx.view.frame.height

  ctx.event:emit('view.register', {object = self, mode = 'gui'})
end

function Hud:update()
  self.tooltip:update()

  self.protect:update()
  self.selector:update()
  self.juju:update()
  self.portrait:update()
  self.minions:update()
  self.shruju:update()
  self.tutorial:update()
  self.chat:update()
  self.upgrades:update()
  self.pause:update()
  self.dead:update()

  -- TODO
  self.particles:update()
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
  self.protect:draw()
  self.selector:draw()
  self.minions:draw()
  self.shruju:draw()
  self.juju:draw()
  self.portrait:draw()
  self.timer:draw()
  self.tutorial:draw()
  self.chat:draw()
  self.upgrades:draw()
  self.pause:draw()
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
  self.selector:mousepressed(...)
end

function Hud:mousereleased(...)
  self.selector:mousepressed(...)
  self.upgrades:mousereleased(...)
  self.pause:mousereleased(...)
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
  self.minions:ready()
end
