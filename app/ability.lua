Ability = class()

function Ability:init()
  self.timer = 0
end

function Ability:createSpell(code, vars)
  if not vars then code, vars = self.code, code end
  ctx.spells:add(data.spell[self.unit.class.code][code], table.merge(vars, {ability = self}, true))
end

function Ability:getUnitDirection()
  return (self.unit.animation.flipped and -1 or 1)
end

function Ability:hasUpgrade(upgrade)
  do return true end
  local deck = self.unit.player.deck[self.unit.class.code]
  return deck.abilities[self.code] and deck.upgrades[self.code][upgrade]
end

function Ability:canUse()
  do return self.timer == 0 end
  return self.unit.player.deck[self.unit.class.code].abilities[self.code] and self.timer == 0
end

function Ability:rot()
  self.timer = timer.rot(self.timer, function()
    f.exe(self.ready, self)
  end)
end

function Ability:used()
  self.timer = self.cooldown or 0
end
