UnitBuffs = class()

function UnitBuffs:init(unit)
  self.unit = unit
  self.list = {}

  table.merge(table.only(self.unit.class, Unit.classStats), self.unit)
  self:applyRunes()
end

function UnitBuffs:preupdate()
  table.with(self.list, 'preupdate')
end

function UnitBuffs:postupdate()
  table.with(self.list, 'rot')
  table.with(self.list, 'postupdate')
  table.with(self.list, 'update')
end

function UnitBuffs:add(code, vars)
  if self:get(code) then return self:reapply(code, vars) end

  local buff = data.buff[code]()
  buff.unit = self.unit
  buff.ability = ability
  self.list[buff] = buff
  table.merge(vars, buff, true)
  f.exe(buff.activate, buff)
  return buff
end

function UnitBuffs:remove(buff)
  if type(buff) == 'string' then
    -- remove by code
    return
  end

  f.exe(buff.deactivate, buff, self.unit)
  self.list[buff] = nil
end

function UnitBuffs:get(code)
  return next(table.filter(self.list, function(buff) return buff.code == code end))
end

function UnitBuffs:reapply(code, vars)
  local buff = self:get(code)
  if buff then
    tabe.merge(vars, buff, true)
  else
    self:add(code, vars)
  end
end

function UnitBuffs:buffsWithTag(tag)
  local buffs = {}
  table.each(self.list, function(buff, name)
    if table.has(buff.tags, tag) then
      buffs[name] = buff
    end
  end)
  return buffs
end

function UnitBuffs:applyRunes()
  local unit, player = self.unit, self.unit.player
  local runes = player.deck[unit.class.code].runes
  
  table.each(runes, function(rune)
    local level = rune.level
    if level > 0 then
      table.each(rune.values, function(levels, stat)
        local value = levels[level]
        if type(value) == 'number' then
          unit[stat] = unit[stat] + value
        elseif type(value) == 'string' and value:match('%%') then
          local original = unit.class[stat]
          local percent = tonumber(value:match('%-?%d')) / 100
          unit[stat] = unit[stat] + original * percent
        end
      end)
    end
  end)
end

