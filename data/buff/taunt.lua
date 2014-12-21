local Taunt = class()
Taunt.code = 'taunt'
Taunt.tags = {'taunt'}

function Taunt:activate(target, timer)
  self.target = target
  self.timer = timer
end

function Taunt:postupdate()
  self.unit.target = self.target

  self.timer = timer.rot(self.timer, function()
    self.unit.buffs:remove(self)
  end)
end

return Taunt
