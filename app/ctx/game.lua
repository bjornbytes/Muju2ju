Game = class()

function Game:load()
	self.paused = false
	self.ded = false

	self.view = View()
	self.environment = Environment()
	self.foreground = Foreground()
	self.enemies = Enemies()
	self.minions = Minions()
	self.player = Player()
	self.shrine = Shrine()
	self.jujus = Jujus()
	self.particles = Particles()
	self.effects = Effects()
	self.hud = Hud()
	self.upgrades = Upgrades()
	self.target = Target()
	self.sound = Sound()

	backgroundSound = self.sound:loop({sound = 'background'})
	love.keyboard.setKeyRepeat(false)
end

function Game:update()
	if self.hud.upgrades.active or self.paused or self.ded then
    self.player:paused()
    self.effects:paused()
    self.hud:update()
		return
	end

	self.enemies:update()
	self.minions:update()
	self.player:update()
	self.shrine:update()
	self.jujus:update()
	self.view:update()
	self.hud:update()
	self.effects:update()
	self.particles:update()
	self.environment:update()
	self.foreground:update()
end

function Game:unload()
	backgroundSound:stop()
end

function Game:draw()
	self.view:draw()
end

function Game:resize()
	self.view:resize()
	self.effects:resize()
  self.hud:resize()
end

function Game:keypressed(key)
  self.hud:keypressed(key)

  -- Try to move elsewhere.
  if (key == 'p' or key == 'escape') and not self.hud.upgrades.active then self.paused = not self.paused
  elseif key == 'm' then self.sound:mute()
  elseif key == 'f' then love.window.setFullscreen(not love.window.getFullscreen()) end

  if self.hud.upgrades.active or self.paused or self.ded then return end

	self.player:keypressed(key)
end

function Game:mousereleased(...)
  self.hud:mousereleased(...)
end

function Game:textinput(char)
	self.hud:textinput(char)
end

function Game:gamepadpressed(gamepad, button)
  self.hud:gamepadpressed(gamepad, button)

  if button == 'b' and self.paused then self.paused = not self.paused end
	if button == 'start' or button == 'guide' then self.paused = not self.paused end

	if self.hud.upgrades.active or self.paused or self.ded then return end

	self.player:gamepadpressed(gamepad, button)
end
