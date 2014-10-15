Server = class()

Server.tag = 'server'

function Server:load()
  self.config = config

	self.paused = false
	self.ded = false
  self.timer = 0

  self.event = Event()
  self.net = NetServer()
  --self.view = View()
  self.map = Map()
	self.players = Players()
  self.shrines = Manager()
  self.units = Units()
  self.jujus = Jujus()
  self.shrujus = Shrujus()
  self.spells = Spells()
	self.target = Target()
  --self.hud = Hud()

  if ctx.config.game.kind == 'survival' then
    ctx.shrines:add(Shrine, {x = ctx.map.width / 2, team = 1})
  elseif ctx.config.game.kind == 'vs' then
    --
  end
end

function Server:update()
	if self.paused or self.ded then
		return
	end

  self.net:update()

  if self.net.state == 'waiting' then return self.net:sync() end

  self.timer = self.timer + 1
	self.players:update()
	self.shrines:update()
  self.units:update()
  self.jujus:update()
  self.shrujus:update()
  self.spells:update()
  --self.view:update()

  self.net:snapshot()

  self.net:sync()
end

--[[function Server:draw()
  self.view:draw()
end]]
