local Smash = {}
Smash.code = 'smash'

----------------
-- Meta
----------------
Smash.name = 'Smash'
Smash.description = 'Smash things'


----------------
-- Data
----------------
Smash.cooldown = 5


----------------
-- Behavior
----------------
function Smash:activate()

end


----------------
-- Upgrades
----------------
local Stun = {}
Stun.name = 'Smash Stun'
Stun.description = 'Ground Smash stuns things now.'

local Damage = {}
Damage.name = 'Smash Damage'
Damage.description = 'Ground Smash deals more damage.'

Smash.upgrades = {Stun, Damage}

return Smash
