local Rewind = class()
Rewind.code = 'rewind'

----------------
-- Meta
----------------
Rewind.name = 'Rewind'
Rewind.description = 'Rewind things'


----------------
-- Data
----------------
Rewind.cooldown = 5


----------------
-- Behavior
----------------
function Rewind:activate()

end


----------------
-- Upgrades
----------------
local Chance = {}
Chance.name = 'Rewind Chance'
Chance.description = 'Higher chance to rewind if Bruju is low on health.'

local Reflect = {}
Reflect.name = 'Rewind Reflect'
Reflect.description = 'Rewind also reflects damage back at the attacker.'

Rewind.upgrades = {Chance, Reflect}

return Rewind
