local Taunt = extend(Ability)
Taunt.code = 'taunt'

----------------
-- Meta
----------------
Taunt.name = 'Taunt'
Taunt.description = 'Taunt things'


----------------
-- Data
----------------
Taunt.cooldown = 5
Taunt.range = 100
Taunt.targets = 2
Taunt.duration = 3


----------------
-- Behavior
----------------
function Taunt:use()
  local targets = table.take(ctx.target:inRange(self.unit, self.range, 'enemy', 'unit'), self.targets)
  table.each(targets, function(target)
    target.buffs:add('taunt', {target = self.unit, timer = self.duration})
  end)

  if self:hasUpgrade('impenetrablehide') then
    self.unit.buffs:add('impenetrablehide', {timer = self.duration, armor = self.upgrades.impenetrablehide.armor})
  end

  if self:hasUpgrade('wardofthorns') then
    self.unit.buffs:add('wardofthorns', {reflectAmount = self.upgrades.wardofthorns.reflectAmount})
  end
end


----------------
-- Upgrades
----------------
local ImpenetrableHide = {}
ImpenetrableHide.code = 'impenetrablehide'
ImpenetrableHide.name = 'Impenetrable Hide'
ImpenetrableHide.description = 'You get armor when you are taunting things.'
ImpenetrableHide.armor = .4

local WardOfThorns = {}
WardOfThorns.code = 'wardofthorns'
WardOfThorns.name = 'Ward of Thorns'
WardOfThorns.description = 'You reflect damage dealt by taunted attackers.'
WardOfThorns.reflectAmount = .5

Taunt.upgrades = {ImpenetrableHide, WardOfThorns}

return Taunt
