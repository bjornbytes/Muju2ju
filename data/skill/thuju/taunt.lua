local Taunt = {}
Taunt.code = 'taunt'

----------------
-- Meta
----------------
Taunt.name = 'Taunt'
Taunt.description = 'Taunt things'


----------------
-- Data
----------------
Taunt.cooldown = 5


----------------
-- Behavior
----------------
function Taunt:activate()

end


----------------
-- Upgrades
----------------
local Armor = {}
Armor.name = 'Taunt Armor'
Armor.description = 'You get armor when you are taunting things.'

local Reflect = {}
Reflect.name = 'Taunt Reflect'
Reflect.description = 'You reflect damage dealt by taunted attackers.'

Taunt.upgrades = {Armor, Reflect}

return Taunt
