Game = class()

Game.tag = 'client'

function Game:load()
  self.config = config

	self.paused = false
	self.ded = false
  self.timer = 0

  self.event = Event()
  self.net = NetClient()
	self.view = View()
  self.map = Map()
  self.players = Players()

  self.event:on('ready', function()
    self.input = Input()
    self.shrines = Manager()
    self.units = Units()
    self.jujus = Jujus()
    self.spells = Spells()
    self.particles = Manager('particle')
    self.effects = Effects()
    self.target = Target()
    self.sound = Sound()
    self.hud = Hud()
    backgroundSound = self.sound:loop({sound = 'background'})

    if ctx.config.game.kind == 'survival' then
      ctx.shrines:add(Shrine, {x = ctx.map.width / 2, team = 1})
    elseif ctx.config.game.kind == 'vs' then
      --
    end
  end)

  self.event:on('particles.add', function(data)
    self.particles:add(data.kind, data)
  end)

  self.event:on('shrine.dead', function(data)
    if backgroundSound then backgroundSound:stop() end

    local p = ctx.players:get(self.id)
    if not p then return end

    local lost = self.config.game.kind == 'survival' or data.shrine.team == p.team

    if lost then
      ctx.event:emit('sound.play', {sound = 'youlose'})
    else
      -- I am winrar.
    end
  end)

	love.keyboard.setKeyRepeat(false)
end

function Game:quit()
  self.net:quit()
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
  self.shrines:update()
  self.units:update()
  self.jujus:update()
  self.spells:update()
	self.particles:update()

	self.view:update()
	self.hud:update()
	self.effects:update()
end

function Game:unload()
	if backgroundSound then backgroundSound:stop() end
end

function Game:draw()
	self.view:draw()
end

function Game:resize()
	self.view:resize()
	self.effects:resize()
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
