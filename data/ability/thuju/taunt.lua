local Taunt = extend(Ability)
Taunt.code = 'taunt'

----------------
-- Meta
----------------
Taunt.name = 'Taunt'
Taunt.description = 'Taunt things'


----------------
-- Data
----------------
Taunt.cooldown = 5
Taunt.range = 100
Taunt.targets = 2
Taunt.duration = 3


----------------
-- Behavior
----------------
function Taunt:activate()
  --
end

function Taunt:use()
  local targets = table.take(ctx.target:inRange(self.owner, self.range, 'enemy', 'unit'), self.targets)
  table.each(targets, function(target)
    target.buffs:add('taunt', self.owner, self.duration)
  end)
end


----------------
-- Upgrades
----------------
local ImpenetrableHide = {}
ImpenetrableHide.code = 'impenetrablehide'
ImpenetrableHide.name = 'Impenetrable Hide'
ImpenetrableHide.description = 'You get armor when you are taunting things.'

local WardOfThorns = {}
WardOfThorns.code = 'wardofthorns'
WardOfThorns.name = 'Ward of Thorns'
WardOfThorns.description = 'You reflect damage dealt by taunted attackers.'

Taunt.upgrades = {ImpenetrableHide, WardOfThorns}

return Taunt
