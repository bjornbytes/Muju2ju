local Taunt = {}
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
local Armor = {}
Armor.name = 'Taunt Armor'
Armor.description = 'You get armor when you are taunting things.'

local Reflect = {}
Reflect.name = 'Taunt Reflect'
Reflect.description = 'You reflect damage dealt by taunted attackers.'

Taunt.upgrades = {Armor, Reflect}

return Taunt
