local Shatter = {}
Shatter.code = 'shatter'

----------------
-- Meta
----------------
Shatter.name = 'Shatter'
Shatter.description = 'Shatter things'


----------------
-- Data
----------------
Shatter.cooldown = 5


----------------
-- Behavior
----------------
function Shatter:activate()

end


----------------
-- Upgrades
----------------
local Something = {}
Something.name = 'Shatter Something'
Something.description = 'This upgrade does something to make shatter better.'

local Something2 = {}
Something2.name = 'Shatter Something'
Something2.description = 'This is another upgrade that makes shatter better.'

Shatter.upgrades = {Something, Something2}

return Shatter

