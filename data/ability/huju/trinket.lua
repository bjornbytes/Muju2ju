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
Trinket.range = 200
Trinket.duration = 4
Trinket.attackSpeedMultiplier = .3
Trinket.speedMultiplier = .4


----------------
-- Behavior
----------------
function Trinket:activate()
  --
end

function Trinket:use()
  --
end


----------------
-- Upgrades
----------------
local Imbue = {}
Imbue.code = 'imbue'
Imbue.name = 'Imbue'
Imbue.description = 'Trinket heals the ally at the end and reduces their cooldowns.'

local Surge = {}
Surge.code = 'surge'
Surge.name = 'Surge'
Surge.description = 'Trinket explodes at the end, damaging enemies and knocking them back.'

Trinket.upgrades = {Distortion, Bide}

return Trinket
