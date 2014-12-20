require 'app/player/player'

PlayerServer = extend(Player)

function PlayerServer:activate()
  self.history = {}
  self.ack = tick

  Player.activate(self)
end

function PlayerServer:get(t)
  if t == tick then return self end

  while self.history[1] and self.history[1].tick < tick - 2 / tickRate do
    table.remove(self.history, 1)
  end

  if #self.history == 0 then return self end

  if self.history[#self.history].tick < t then return self end

  for i = #self.history, 1, -1 do
    if self.history[i].tick <= t then return self.history[i] end
  end

  return self.history[1]
end

function PlayerServer:update()
	self.jujuTimer = timer.rot(self.jujuTimer, function()
		self.juju = self.juju + 1
		return 2
	end)

	--self:hurt(self.maxHealth * .033 * tickRate)

  Player.update(self)
end

function PlayerServer:getHealthbar()
  return self.x, self.y, self.health / self.maxHealth
end

function PlayerServer:trace(data)
  if data.tick <= self.ack or data.tick > tick + (.5 / tickRate) then return end

  self.ack = data.tick

  data.x = math.clamp(data.x, -1, 1)
  data.y = math.clamp(data.y, -1, 1)
  if data.selected then data.selected = math.clamp(data.selected, 1, #self.deck) end

  -- if not self.dead then?
  self:move(data)
  self:slot(data)

  if data.ability and self.deck[self.selected].instance then
    self.deck[self.selected].instance:ability(data.ability)
  end

  table.insert(self.history, setmetatable({
    x = self.x,
    y = self.y,
    tick = data.tick
  }, self.meta))

  -- reply with state
  if self.peer then
    local msg = {
      ack = self.ack,
      juju = math.round(self.juju)
    }

    if self.dead then
      msg.ghostX = self.ghostX
      msg.ghostY = self.ghostY
    else
      msg.x = self.x
      msg.health = math.round(self.health / self.maxHealth * 255)
    end

    ctx.net:send('input', self.peer, msg)
  end
end

function PlayerServer:spend(amount)
  if self.juju < amount then return false end
  self.juju = self.juju - amount
  return true
end

function PlayerServer:hurt(amount, source)
	if self.invincible == 0 then
		self.health = math.max(self.health - amount, 0)
		if self.gamepad and self.gamepad:isVibrationSupported() then
			local l, r = .25, .25
			if source then
				if source.x > self.x then r = .5
				elseif source.x < self.x then l = .5 end
			end

			self.gamepad:setVibration(l, r, .25)
		end
	end

	-- Death
	if self.health <= 0 and self.deathTimer == 0 then
    self:die()
    return true
	end
end

function PlayerServer:heal(amount, source)
  self.health = math.min(self.health + amount, self.maxHealth)
end
