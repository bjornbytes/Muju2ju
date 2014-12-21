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
Siphon.cooldown = 12
Siphon.duration = 6
Siphon.lifesteal = .2
Siphon.activeLifesteal = .4


----------------
-- Behavior
----------------
function Siphon:activate()
  self.buff = self.unit.buffs:add('siphon', {ability = self})
end

function Siphon:deactivate()
  self.unit.buffs:remove(self.buff)
end

function Siphon:ready()
  self.buff:setPassive()
end

function Siphon:use()
  self.buff:setActive()
end


----------------
-- Upgrades
----------------
local Equilibrium = {}
Equilibrium.code = 'equilibrium'
Equilibrium.name = 'Equilibrium'
Equilibrium.description = 'Increases the effect by 1% for every 1% of missing health.'
Equilibrium.percentMissingMultiplier = 1

local Radiance = {}
Radiance.code = 'radiance'
Radiance.name = 'Radiance'
Radiance.description = 'Equally distributes an additional 50% of the heal amount to nearby allies.'
Radiance.range = 100
Radiance.amountMultiplier = .5

Siphon.upgrades = {Equilibrium, Radiance}

return Siphon
