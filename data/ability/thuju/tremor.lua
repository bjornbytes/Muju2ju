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
Tremor.damage = 40
Tremor.stun = .75
Tremor.width = 125


----------------
-- Behavior
----------------
function Tremor:use()
  local width, stun, silence, structureDamageMultiplier = self.width, self.stun, nil, nil

  if self:hasUpgrade('concussion') then
    stun = self.upgrades.concussion.stun
    silence = self.upgrades.concussion.silence
  end

  if self:hasUpgrade('fissure') then
    width = width * self.upgrades.fissure.widthMultiplier
    structureDamageMultiplier = self.upgrades.fissure.structureDamageMultiplier
  end

  self:createSpell({width = width, stun = stun, silence = silence, structureDamageMultiplier = structureDamageMultiplier})
end


----------------
-- Upgrades
----------------
local Concussion = {}
Concussion.code = 'concussion'
Concussion.name = 'Concussion'
Concussion.description = 'Tremor stuns for longer and silences enemies afterwards.'
Concussion.stun = 1.5
Concussion.silence = 4

local Fissure = {}
Fissure.code = 'fissure'
Fissure.name = 'Fissure'
Fissure.description = 'Tremor has increased range and deals additional damage to structures.'
Fissure.widthMultiplier = 2
Fissure.structureDamageMultiplier = 2

Tremor.upgrades = {Concussion, Fissure}

return Tremor
