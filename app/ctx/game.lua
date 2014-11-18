Game = class()

Game.tag = 'client'

function Game:load(config, user)
  self.config = config
  self.user = user

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
    self.shrines = Manager()
    self.units = Units()
    self.jujus = Jujus()
    self.spells = Spells()
    self.particles = Manager('particle')
    self.effects = Effects()
    self.target = Target()
    self.sound = Sound()
    self.hud:ready()
    backgroundSound = self.sound:loop({sound = 'background'})

    if ctx.config.game.gameType == 'survival' then
      ctx.shrines:add(Shrine, {x = ctx.map.width / 2, team = 1})
    elseif ctx.config.game.gameType == 'vs' then
      ctx.shrines:add(Shrine, {x = ctx.map.width * .15, team = 1})
      ctx.shrines:add(Shrine, {x = ctx.map.width * .85, team = 2})
    end
  end)

  self.event:on('particles.add', function(data)
    self.particles:add(data.kind, data)
  end)

  self.event:on('over', function(data)
    if backgroundSound then backgroundSound:stop() end

    local p = ctx.players:get(ctx.id)
    if not p then return end

    local lost = data.winner ~= p.team

    if lost then
      print('you lose')
      Context:remove(ctx)
      Context:add(Menu, self.user)
    else
      print('you win')
      Context:remove(ctx)
      Context:add(Menu, self.user)
    end
  end)

	love.keyboard.setKeyRepeat(false)
end

function Game:quit()
  self:unload()
end

function Game:update()
  self.net:update()

  if self.net.state == 'connecting' or self.net.state == 'waiting' then
    self.view:update()
    return
  end

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
  self.net:quit()
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
  elseif key == 'm' then self.sound:mute() end

  if self.hud.upgrades.active or self.paused or self.ded then return end

	--self.player:keypressed(key)
end

function Game:keyreleased(key)
  if not self.id then return end

  self.hud:keyreleased(key)
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
