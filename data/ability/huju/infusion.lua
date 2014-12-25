local Infusion = extend(Ability)
Infusion.code = 'infusion'

----------------
-- Meta
----------------
Infusion.name = 'Infusion'
Infusion.description = 'Infuse things'


----------------
-- Data
----------------
Infusion.cooldown = 8
Infusion.range = 150
Infusion.duration = 5
Infusion.currentHealthCost = .2
Infusion.maxHealthHeal = .3


----------------
-- Behavior
----------------
function Infusion:activate()
  self.channelTimer = 0
end

function Infusion:update()
  self.channelTimer = timer.rot(self.channelTimer, function()
    self.unit.channeling = false
  end)
end

function Infusion:use()
  self.unit:hurt(self.unit.health * self.currentHealthCost, self.unit)
  self.unit.channeling = true
  self.channelTimer = self.duration
  self:createSpell()
end


----------------
-- Upgrades
----------------
local Distortion = {}
Distortion.code = 'distortion'
Distortion.name = 'Distortion'
Distortion.description = 'Infusion speeds up allies and slows enemies.'
Distortion.slow = .5
Distortion.haste = .5

local Resilience = {}
Resilience.code = 'resilience'
Resilience.name = 'Resilience'
Resilience.description = 'Any allies under the effect of Infusion are immune to crowd control effects.'

Infusion.upgrades = {Distortion, Resilience}

return Infusion
