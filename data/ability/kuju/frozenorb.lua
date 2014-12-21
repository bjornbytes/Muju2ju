local FrozenOrb = extend(Ability)
FrozenOrb.code = 'frozenorb'

----------------
-- Meta
----------------
FrozenOrb.name = 'Frozen Orb'
FrozenOrb.description = [[
Kuju sends out a projectile in a target direction that deals damage and slows units hit.
It then returns to Kuju, reapplying the damage and slow.
]]


----------------
-- Data
----------------
FrozenOrb.cooldown = 5


----------------
-- Behavior
----------------
function FrozenOrb:activate()

end


function FrozenOrb:use()
  ctx.spells.add(data.spell.kuju.frozenorb)
end


----------------
-- Upgrades
----------------
local WintersWrath = {}
WintersWrath.name = 'Winter\'s Wrath'
WintersWrath.description = 'Frozen Orb deals 10% more damage.'

local SweepingGale = {}
SweepingGale.name = 'Sweeping Gale'
SweepingGale.description = 'Frozen orb travels 25% further away from Kuju before returning.'

FrozenOrb.upgrades = {WintersWrath, SweepingGale}

return FrozenOrb

