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


----------------
-- Behavior
----------------
function Frostbite:use()
  self:createSpell({})
end


----------------
-- Upgrades
----------------
local Tundra = {}
Tundra.code = 'tundra'
Tundra.name = 'Tundra'
Tundra.description = 'This upgrade does something to make Frostbite better.'

local FrigidPrison = {}
FrigidPrison.code = 'frigidprison'
FrigidPrison.name = 'Frigid Prison'
FrigidPrison.description = 'This is another upgrade that makes Frostbite better.'

Frostbite.upgrades = {Tundra, FrigidPrison}

return Frostbite
