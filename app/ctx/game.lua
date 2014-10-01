Game = class()

Game.tag = 'client'

function Game:load()
	self.paused = false
	self.ded = false
  self.timer = 0

  self.event = Event()
  self.net = NetClient()
	self.view = View()
  self.map = Map()
  self.players = Players()
	self.hud = Hud()

  self.event:on('ready', function()
    self.input = Input()
    self.shrine = Shrine()
    self.units = Units()
    self.spells = Manager('spell')
    self.particles = Manager('particle')
    self.effects = Effects()
    self.upgrades = Upgrades()
    self.target = Target()
    self.sound = Sound()
    backgroundSound = self.sound:loop({sound = 'background'})
  end)

  self.event:on('particles.add', function(data)
    self.particles:add(data.kind, data)
  end)

	love.keyboard.setKeyRepeat(false)
end

function Game:update()
  self.net:update()

  if self.net.state == 'connecting' or self.net.state == 'waiting' then return end

  self.input:update()

	if self.paused or self.ded then
    self.effects:paused()
    self.hud:update()
		return
	end

  self.timer = self.timer + 1
	self.players:update()
	self.shrine:update()
  self.units:update()
  self.spells:update()
	self.particles:update()

	self.view:update()
	self.hud:update()
	self.effects:update()
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
  if not self.id then return end

  self.hud:keypressed(key)

  -- Try to move elsewhere.
  if (key == 'p' or key == 'escape') and not self.hud.upgrades.active then self.paused = not self.paused
  elseif key == 'm' then self.sound:mute()
  elseif key == 'f' then love.window.setFullscreen(not love.window.getFullscreen()) end

  if self.hud.upgrades.active or self.paused or self.ded then return end

	--self.player:keypressed(key)
end

function Game:mousereleased(...)
  if not self.id then return end

  self.hud:mousereleased(...)
end

function Game:textinput(char)
  if not self.id then return end

	self.hud:textinput(char)
end

function Game:gamepadpressed(gamepad, button)
  if not self.id then return end

  self.hud:gamepadpressed(gamepad, button)

  if button == 'b' and self.paused then self.paused = not self.paused end
	if button == 'start' or button == 'guide' then self.paused = not self.paused end

	if self.hud.upgrades.active or self.paused or self.ded then return end

	--self.player:gamepadpressed(gamepad, button)
end

function Game:joystickadded(...)
  if not self.id then return end

  return self.input:joystickadded(...)
end

function Game:joystickremoved(...)
  if not self.id then return end

  return self.input:joystickremoved(...)
end
