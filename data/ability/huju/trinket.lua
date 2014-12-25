local Trinket = extend(Ability)
Trinket.code = 'trinket'

----------------
-- Meta
----------------
Trinket.name = 'Trinket'
Trinket.description = 'Trinket things'


----------------
-- Data
----------------
Trinket.cooldown = 15
Trinket.target = 'ally'
Trinket.range = 200
Trinket.duration = 4
Trinket.frenzy = .3
Trinket.haste = .4


----------------
-- Behavior
----------------
function Trinket:use(target)
  self:createSpell({target = target})
end


----------------
-- Upgrades
----------------
local Imbue = {}
Imbue.code = 'imbue'
Imbue.name = 'Imbue'
Imbue.description = 'Trinket heals the ally at the end and reduces their cooldowns.'
Imbue.heal = 75
Imbue.cooldownReduction = 3

local Surge = {}
Surge.code = 'surge'
Surge.name = 'Surge'
Surge.description = 'Trinket explodes at the end, damaging enemies and knocking them back.'
Surge.damage = 75
Surge.range = 100

Trinket.upgrades = {Distortion, Bide}

return Trinket
