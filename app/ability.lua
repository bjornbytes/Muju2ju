Ability = class()

function Ability:hasUpgrade(upgrade)
  do return true end
  return self.unit.player.deck[self.unit.class.code].upgrades[self.code][upgrade]
end
