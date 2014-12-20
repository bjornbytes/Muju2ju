local Burst = {}
Burst.code = 'burst'

----------------
-- Meta
----------------
Burst.name = 'Burst'
Burst.description = 'Burst things'


----------------
-- Data
----------------
Burst.passive = true


----------------
-- Behavior
----------------
function Burst:die()
  ctx.spells:add(data.spell.bruju.burst, {owner = self})
end


----------------
-- Upgrades
----------------
local EssenceFlame = {}
EssenceFlame.name = 'Essence Flame'
EssenceFlame.description = 'Burst deals 50% increased damage and the radius is increased by 100%.'

local Sanctuary = {}
Sanctuary.name = 'Sanctuary'
Sanctuary.description = 'Burst heals allies in the area of effect for 15% of their maximum health.'

Burst.upgrades = {DamageRange, Sanctuary}

return Burst
