local FrozenOrb = {}
FrozenOrb.code = 'frozenorb'

----------------
-- Meta
----------------
FrozenOrb.name = 'Frozen Orb'
FrozenOrb.description = 'Fuck shit up'


----------------
-- Data
----------------
FrozenOrb.cooldown = 5


----------------
-- Behavior
----------------
function FrozenOrb:activate()

end


----------------
-- Upgrades
----------------
local Something = {}
Something.name = 'FrozenOrb Something'
Something.description = 'This upgrade does something to make FrozenOrb better.'

local Something2 = {}
Something2.name = 'FrozenOrb Something'
Something2.description = 'This is another upgrade that makes FrozenOrb better.'

FrozenOrb.upgrades = {Something, Something2}

return FrozenOrb

