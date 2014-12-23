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
  ctx.spells:add(data.spell.huju.infusion, {ability = self})
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
