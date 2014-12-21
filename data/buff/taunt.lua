local Taunt = class()
Taunt.code = 'taunt'
Taunt.tags = {'taunt'}

function Taunt:activate()
  --
end

function Taunt:postupdate()
  self.timer = timer.rot(self.timer, function()
    self.unit.buffs:remove(self)
  end)
end

return Taunt
