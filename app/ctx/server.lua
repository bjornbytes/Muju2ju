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
  self.spells = Manager('spell')
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
  self.spells:update()
  --self.view:update()

  -- send a snapshot
  local snapshot = {tick = tick, players = {}, units = {}}
  self.players:each(function(player)

    local entry = {
      id = player.id,
      dead = player.dead,
      animationData = player.animation:pack()
    }

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
    table.insert(snapshot.units, {
      id = unit.id,
      x = math.round(unit.x),
      y = math.round(unit.y),
      health = math.round(unit.health),
      animationData = unit.animation and unit.animation:pack() or nil
    })
  end)

  self.net:emit('snapshot', snapshot)

  self.net:sync()
end

--[[function Server:draw()
  self.view:draw()
end]]
