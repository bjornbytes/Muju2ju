local Trinket = extend(Spell)
Trinket.code = 'trinket'

local g = love.graphics

function Trinket:activate()
  local ability = self:getAbility()
  self.timer = ability.duration

  self.target.buffs:add('trinket', {timer = self.duration})
end

function Trinket:update()
  self.timer = timer.rot(self.timer, function()
    local ability = self:getAbility()

    if ability:hasUpgrade('imbue') then
      self.target:heal(ability.upgrades.imbue.heal, self:getUnit())
    elseif ability:hasUpgrade('surge') then
      table.each(ctx.target:inRange(self.target, ability.upgrades.surge.range, 'enemy', 'unit', 'player'), function(target)
        target:hurt(ability.upgrades.surge.damage, self:getUnit())
        -- TODO knockback
      end)
    end

    ctx.spells:remove(self)
  end)
end

function Trinket:draw()
  g.setColor(0, 255, 0)
  g.circle('line', self.target.x, self.target.y - 100, 5)
end

return Trinket
