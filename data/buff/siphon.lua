local Siphon = class()
Siphon.code = 'siphon'
Siphon.tags = {'lifesteal'}
Siphon.name = 'Siphon'

function Siphon:init()
  self.mode = 'passive'
end

function Siphon:postDealDamage(target, amount)
  local ability = self.ability
  local lifesteal = self.mode == 'active' and ability.activeLifesteal or ability.lifesteal
  local amount = lifesteal * amount

  if ability:hasUpgrade('equilibrium') then
    local percentMissing = 1 - (self.unit.health / self.unit.maxHealth)
    amount = amount * (1 + ability.upgrades.equilibrium.percentMissingMultiplier * percentMissing)
  end

  self.unit:heal(amount, self.unit)

  if ability:hasUpgrade('radiance') then
    local targets = ctx.target:inRange(self.unit, ability.upgrades.radiance.range, 'ally', 'unit', 'player')

    if #targets > 0 then
      local amount = (amount * ability.upgrades.radiance.amountMultiplier) / #targets
      table.each(targets, function(target)
        target:heal(amount, self.unit)
      end)
    end
  end
end

function Siphon:setPassive()
  self.mode = 'passive'
end

function Siphon:setActive()
  self.mode = 'active'
end

return Siphon
