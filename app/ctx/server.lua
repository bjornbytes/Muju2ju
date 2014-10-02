Server = class()

Server.tag = 'server'

function Server:load()
	self.paused = false
	self.ded = false
  self.timer = 0

  self.event = Event()
  self.net = NetServer()
  --self.view = View()
  self.map = Map()
	self.players = Players()
	self.shrine = Shrine()
  self.units = Units()
  self.jujus = Jujus()
  self.spells = Manager('spell')
	self.upgrades = Upgrades()
	self.target = Target()
  --self.hud = Hud()
end

function Server:update()
	if self.paused or self.ded then
		return
	end

  self.net:update()

  if self.net.state == 'waiting' then return self.net:sync() end

  self.timer = self.timer + 1
	self.players:update()
	self.shrine:update()
  self.units:update()
  self.jujus:update()
  self.spells:update()
  --self.view:update()

  -- send a snapshot
  local snapshot = {tick = tick, players = {}, units = {}}
  self.players:each(function(player)
    local animationMap = {
      idle = 1,
      walk = 2,
      summon = 3,
      death = 4,
      resurrect = 5
    }

    local track = player.animation.state:getCurrent(0)

    local entry = {
      id = player.id,
      dead = player.dead,
      animationIndex = (track and animationMap[track.animation.name]) or 0,
      animationPrev = (track and track.previous and animationMap[track.previous.animation.name]) or 0,
      animationTime = track and track.time or 0,
      animationPrevTime = (track and track.previous and track.previous.time) or 0,
      animationFlip = player.animation.flipX == true
    }

    if not track or track.mixDuration == 0 then entry.animationAlpha = 0
    else entry.animationAlpha = math.min(track.mixTime / track.mixDuration * track.mix, 1) end

    if player.dead then
      entry.ghostX = player.ghostX
      entry.ghostY = player.ghostY
      
      local angle = math.round(math.deg(player.ghost.angle))
      while angle < 0 do angle = angle + 360 end
      entry.ghostAngle = angle
    else
      entry.x = player.x
      entry.health = math.round(player.health)
    end

    table.insert(snapshot.players, entry)
  end)

  self.units:each(function(unit)
    unit.syncCounter = unit.syncCounter + 1
    if unit.syncCounter >= unit.syncRate then
      table.insert(snapshot.units, {
        id = unit.id,
        x = math.round(unit.x),
        y = math.round(unit.y),
        health = math.round(unit.health)
      })

      unit.syncCounter = 0
    end
  end)

  self.net:emit('snapshot', snapshot)

  self.net:sync()
end

--[[function Server:draw()
  self.view:draw()
end]]
