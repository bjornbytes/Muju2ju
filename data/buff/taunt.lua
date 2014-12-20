local Taunt = {}
Taunt.code = 'taunt'

function Taunt:activate(target, timer)
  self.target = target
  self.timer = timer
end

function Taunt:postupdate()
  self.owner.target = self.target

  self.timer = timer.rot(self.timer, function()
    self.owner.buffs:remove(self)
  end)
end

function Taunt
