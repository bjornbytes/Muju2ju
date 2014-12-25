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

FrozenOrb.damage = 5
FrozenOrb.range = 175
FrozenOrb.radius = 10
FrozenOrb.speed = 150
FrozenOrb.duration = 2
FrozenOrb.slow = .25


----------------
-- Behavior
----------------
function FrozenOrb:use()
  local damage, range = self.damage, self.range

  if self:hasUpgrade('winterswrath') then
    damage = damage + damage * .05
  end

  if self:hasUpgrade('sweepinggale') then
    range = range + range * .25
  end

  self:createSpell({
    damage = damage,
    range = range,
    radius = self.radius,
    speed = self.speed,
    slow = self.slow,
    duration = self.duration
  })
end


----------------
-- Upgrades
----------------
local WintersWrath = {}
WintersWrath.name = 'Winter\'s Wrath'
WintersWrath.code = 'winterswrath'
WintersWrath.description = 'Frozen Orb deals 10% more damage.'

local SweepingGale = {}
SweepingGale.name = 'Sweeping Gale'
SweepingGale.code = 'sweepinggale'
SweepingGale.description = 'Frozen orb travels 25% further away from Kuju before returning.'

FrozenOrb.upgrades = {WintersWrath, SweepingGale}

return FrozenOrb

