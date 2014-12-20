local Siphon = extend(Ability)
Siphon.code = 'siphon'

----------------
-- Meta
----------------
Siphon.name = 'Siphon'
Siphon.description = 'Siphon things'


----------------
-- Data
----------------
Siphon.cooldown = 15


----------------
-- Behavior
----------------
function Siphon:activate()
  --
end


----------------
-- Upgrades
----------------
local Equilibrium = {}
Equilibrium.name = 'Equilibrium'
Equilibrium.description = 'Increases the effect by 1% for every 1% of missing health.'

local Radiance = {}
Radiance.name = 'Radiance'
Radiance.description = 'Equally distributes an additional 50% of the heal amount to nearby allies.'

Siphon.upgrades = {Equilibrium, Radiance}

return Siphon
