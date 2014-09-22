Server = class()

Server.tag = 'server'

function Server:load()
	self.paused = false
	self.ded = false
  self.timer = 0

  self.event = Event()
  self.net = NetServer()
  self.map = Map()
	self.player = Player()
	self.shrine = Shrine()
	self.enemies = Enemies()
	self.minions = Manager('minion')
  self.spells = Manager('spell')
	self.upgrades = Upgrades()
	self.target = Target()
end

function Server:update()
	if self.paused or self.ded then
    self.player:paused()
		return
	end

  self.net:update()

  self.timer = self.timer + 1
	self.player:update()
	self.shrine:update()
	self.enemies:update()
	self.minions:update()
  self.spells:update()
end
