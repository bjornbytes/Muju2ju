Ability = class()

function Ability:hasUpgrade(upgrade)
  do return true end
  return self.owner.owner.deck[self.owner.class.code].upgrades[self.code][upgrade]
end
