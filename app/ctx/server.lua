Server = class()

function Server:load()
	self.paused = false
	self.ded = false
  self.timer = 0

  self.event = Event()
  self.input = Input()
  self.map = Map()
	self.player = Player()
	self.shrine = Shrine()
	self.enemies = Enemies()
	self.minions = Manager('minion')
  self.spells = Manager('spell')
	self.particles = Manager('particle')
	self.effects = Effects()
	self.hud = Hud()
	self.upgrades = Upgrades()
	self.target = Target()
	self.sound = Sound()

	backgroundSound = self.sound:loop({sound = 'background'})
	love.keyboard.setKeyRepeat(false)
end

function Server:update()
  self.input:update()

	if self.hud.upgrades.active or self.paused or self.ded then
    self.player:paused()
    self.effects:paused()
    self.hud:update()
		return
	end

  self.timer = self.timer + 1
	self.player:update()
	self.shrine:update()
	self.enemies:update()
	self.minions:update()
  self.spells:update()
	self.particles:update()

	self.view:update()
	self.hud:update()
	self.effects:update()
end

function Server:unload()
	backgroundSound:stop()
end

function Server:draw()
	self.view:draw()
end

function Server:resize()
	self.view:resize()
	self.effects:resize()
  self.hud:resize()
end

function Server:keypressed(key)
  self.hud:keypressed(key)

  -- Try to move elsewhere.
  if (key == 'p' or key == 'escape') and not self.hud.upgrades.active then self.paused = not self.paused
  elseif key == 'm' then self.sound:mute()
  elseif key == 'f' then love.window.setFullscreen(not love.window.getFullscreen()) end

  if self.hud.upgrades.active or self.paused or self.ded then return end

	self.player:keypressed(key)
end

function Server:mousereleased(...)
  self.hud:mousereleased(...)
end

function Server:textinput(char)
	self.hud:textinput(char)
end

function Server:gamepadpressed(gamepad, button)
  self.hud:gamepadpressed(gamepad, button)

  if button == 'b' and self.paused then self.paused = not self.paused end
	if button == 'start' or button == 'guide' then self.paused = not self.paused end

	if self.hud.upgrades.active or self.paused or self.ded then return end

	self.player:gamepadpressed(gamepad, button)
end

function Server:joystickadded(...)
  return self.input:joystickadded(...)
end

function Server:joystickremoved(...)
  return self.input:joystickremoved(...)
end
