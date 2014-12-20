local Frostbite = extend(Ability)
Frostbite.code = 'Frostbite'

----------------
-- Meta
----------------
Frostbite.name = 'Frostbite'
Frostbite.description = 'Frostbite things'


----------------
-- Data
----------------
Frostbite.cooldown = 5
Frostbite.targeted = true


----------------
-- Behavior
----------------
function Frostbite:activate()

end


----------------
-- Upgrades
----------------
local Something = {}
Something.name = 'Frostbite Something'
Something.description = 'This upgrade does something to make Frostbite better.'

local Something2 = {}
Something2.name = 'Frostbite Something'
Something2.description = 'This is another upgrade that makes Frostbite better.'

Frostbite.upgrades = {Something, Something2}

return Frostbite
