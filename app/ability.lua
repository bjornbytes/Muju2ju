Ability = class()

function Ability:hasUpgrade(upgrade)
  return self.owner.owner.deck[self.owner.class.code].upgrades[self.code][upgrade]
end
