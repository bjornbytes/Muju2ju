local Tremor = extend(Ability)
Tremor.code = 'tremor'

----------------
-- Meta
----------------
Tremor.name = 'Tremor'
Tremor.description = 'Tremor things'


----------------
-- Data
----------------
Tremor.cooldown = 5


----------------
-- Behavior
----------------
function Tremor:activate()

end


----------------
-- Upgrades
----------------
local Concussion = {}
Concussion.name = 'Concussion'
Concussion.description = 'Tremor stuns for longer and silences enemies afterwards.'

local Fissure = {}
Fissure.name = 'Fissure'
Fissure.description = 'Tremor has increased range and deals additional damage to structures.'

Tremor.upgrades = {Concussion, Fissure}

return Tremor
