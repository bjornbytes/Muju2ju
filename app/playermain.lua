PlayerMain = extend(Player)

function PlayerMain:init()
  self.gamepadSelectDirty = false
  self.inputs = {}

  Player.init(self)
end

function PlayerMain:update()
  if ctx.input.gamepad then -- TODO
    local ltrigger = ctx.input.gamepad:getGamepadAxis('triggerleft') > .5
    local rtrigger = ctx.input.gamepad:getGamepadAxis('triggerright') > .5
    if not self.gamepadSelectDirty then
      if rtrigger then self.selectedMinion = self.selectedMinion + 1 end
      if ltrigger then self.selectedMinion = self.selectedMinion - 1 end
      if self.selectedMinion <= 0 then self.selectedMinion = #self.minions
      elseif self.selectedMinion > #self.minions then self.selectedMinion = 1 end
    end
    self.gamepadSelectDirty = rtrigger or ltrigger
  end

  local input = self:readInput()
  self:move(input)
  self:slot(input)

  Player.update(self)
end

function PlayerMain:keypressed(key)
	for i = 1, #self.minions do
		if tonumber(key) == i then
			self.selectedMinion = i
			self.recentSelect = 1
			return
		end
	end
end

function PlayerMain:readInput()
  local t = {tick = tick}

  t.x = ctx.input:getAxis('x')
  t.y = ctx.input:getAxis('y')
  t.minion = self.selectedMinion

  table.insert(self.inputs, t)

  return t
end

function PlayerMain:trace()
  self.x, self.y = data.x, data.y
  self.health = data.health
  
  -- Discard inputs before the ack.
  while #self.inputs > 0 and self.inputs[1].tick < data.ack + 1 do
    table.remove(self.inputs, 1)
  end

  -- Server reconciliation: Apply inputs that occurred after the ack.
  for i = 1, #self.inputs do
    self:move(self.inputs[i])
  end
end
