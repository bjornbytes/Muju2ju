local Frostbite = extend(Ability)
Frostbite.code = 'frostbite'

----------------
-- Meta
----------------
Frostbite.name = 'Frostbite'
Frostbite.description = 'Frostbite things'


----------------
-- Data
----------------
Frostbite.cooldown = 18
Frostbite.target = 'location'
Frostbite.range = 150
Frostbite.width = 100
Frostbite.duration = 3
Frostbite.slow = .2
Frostbite.dps = 20
Frostbite.rootDuration = 1.5
Frostbite.rootThreshold = 2


----------------
-- Behavior
----------------
function Frostbite:use(target)
  local width, duration = self.width, self.rootDuration

  if self:hasUpgrade('tundra') then
    width = width * self.upgrades.tundra.widthMultiplier
  end

  if self:hasUpgrade('frigidprison') then
    duration = self.upgrades.frigidprison.rootDuration
  end

  self:createSpell({
    x = target,
    width = width,
    rootDuration = duration
  })
end


----------------
-- Upgrades
----------------
local Tundra = {}
Tundra.code = 'tundra'
Tundra.name = 'Tundra'
Tundra.description = 'This upgrade does something to make Frostbite better.'
Tundra.widthMultiplier = 1.5

local FrigidPrison = {}
FrigidPrison.code = 'frigidprison'
FrigidPrison.name = 'Frigid Prison'
FrigidPrison.description = 'This is another upgrade that makes Frostbite better.'
FrigidPrison.rootDuration = 3

Frostbite.upgrades = {Tundra, FrigidPrison}

return Frostbite
