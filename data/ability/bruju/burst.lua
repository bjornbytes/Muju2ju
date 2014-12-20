local Burst = {}
Burst.code = 'burst'

----------------
-- Meta
----------------
Burst.name = 'Burst'
Burst.description = 'Burst things'


----------------
-- Data
----------------
Burst.cooldown = 5


----------------
-- Behavior
----------------
function Burst:activate()

end


----------------
-- Upgrades
----------------
local DamageRange = {}
DamageRange.name = 'Burst Damage and Range'
DamageRange.description = 'Burst does more damage and has more range.'

local Sanctuary = {}
Sanctuary.name = 'Sanctuary'
Sanctuary.description = 'Sanctuary bitch!'

Burst.upgrades = {DamageRange, Sanctuary}


return Burst
