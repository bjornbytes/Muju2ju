Ability = class()

function Ability:init()
  self.timer = 0
end

function Ability:getUnitDirection()
  return self.unit.flipped and 1 or -1 
end

function Ability:hasUpgrade(upgrade)
  do return true end
  return self.unit.player.deck[self.unit.class.code].upgrades[self.code][upgrade]
end

function Ability:canUse()
  return self.timer == 0
end

function Ability:rot()
  self.timer = timer.rot(self.timer, function()
    f.exe(self.ready, self)
  end)
end

function Ability:used()
  self.timer = self.cooldown or 0
end
