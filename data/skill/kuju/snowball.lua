local Snowball = {}
Snowball.code = 'snowball'

----------------
-- Meta
----------------
Snowball.name = 'Snowball'
Snowball.description = 'Snowball things'


----------------
-- Data
----------------
Snowball.cooldown = 5


----------------
-- Behavior
----------------
function Snowball:activate()

end


----------------
-- Upgrades
----------------
local Something = {}
Something.name = 'Snowball Something'
Something.description = 'This upgrade does something to make snowball better.'

local Something2 = {}
Something2.name = 'Snowball Something'
Something2.description = 'This is another upgrade that makes snowball better.'

Snowball.upgrades = {Something, Something2}

return Snowball
