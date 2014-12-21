local Slow = extend(Buff)
Slow.code = 'slow'
Slow.tags = {'slow'}

function Slow:preupdate()
  local slows = self.unit.buffs:buffsWithTag('slow')
  local speed = self.unit.class.speed

  table.each(slows, function(slow)
    speed = speed * (1 - slow.amount)
  end)

  self.unit.speed = speed
end


return Slow
