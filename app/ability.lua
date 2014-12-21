Ability = class()

function Ability:getUnitDirection()
  return self.unit.flipped and 1 or -1 
end

function Ability:hasUpgrade(upgrade)
  do return true end
  return self.unit.player.deck[self.unit.class.code].upgrades[self.code][upgrade]
end
