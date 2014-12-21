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
Infusion.currentHealthCost = .1


----------------
-- Behavior
----------------
function Infusion:activate()
  self.timer = 0
end

function Infusion:use()
  self.unit:hurt(self.unit.health * self.currentHealthCost, self.unit)
end


----------------
-- Upgrades
----------------
local Distortion = {}
Distortion.code = 'distortion'
Distortion.name = 'Distortion'
Distortion.description = 'Infusion speeds up allies and slows enemies.'

local Bide = {}
Bide.code = 'bide'
Bide.name = 'Bide'
Bide.description = 'Infusion absorbs damage and releases it back at enemies.'

Infusion.upgrades = {Distortion, Bide}

return Infusion
