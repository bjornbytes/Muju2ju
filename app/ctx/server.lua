Server = class()

Server.tag = 'server'

function Server:load()
	self.paused = false
	self.ded = false
  self.timer = 0

  self.event = Event()
  self.net = NetServer()
  self.view = View()
  self.map = Map()
	self.players = Players()
	self.shrine = Shrine()
  self.units = Units()
  self.spells = Manager('spell')
	self.upgrades = Upgrades()
	self.target = Target()
  self.hud = Hud()
end

function Server:update()
	if self.paused or self.ded then
    self.player:paused()
		return
	end

  self.net:update()

  if self.net.state == 'waiting' then return self.net:sync() end

  self.timer = self.timer + 1
	self.players:update()
	self.shrine:update()
  self.units:update()
  self.spells:update()
  self.view:update()

  self.net:sync()
end

function Server:draw()
  self.view:draw()
end
