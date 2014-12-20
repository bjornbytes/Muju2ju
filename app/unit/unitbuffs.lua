UnitBuffs = class()

function UnitBuffs:init(owner)
  self.owner = owner
  self.list = {}

  table.merge(table.only(self.owner.class, Unit.classStats), self.owner)
  self:applyRunes()
end

function UnitBuffs:preupdate()
  table.with(self.list, 'preupdate')
end

function UnitBuffs:postupdate()
  table.with(self.list, 'postupdate')
  table.with(self.list, 'update')
end

function UnitBuffs:add(code, vars)
  local buff = data.buff[code]()
  buff.owner = self.owner
  self.list[buff] = buff
  f.exe(buff.activate, buff, self.owner, vars)
  return buff
end

function UnitBuffs:remove(buff)
  if type(buff) == 'string' then
    -- remove by code
    return
  end

  f.exe(buff.deactivate, buff, self.owner)
  self.list[buff] = nil
end

function UnitBuffs:applyRunes()
  local owner = self.owner
  local player = owner.owner
  local runes = player.deck[owner.class.code].runes
  
  table.each(runes, function(rune)
    local level = rune.level
    if level > 0 then
      table.each(rune.values, function(levels, stat)
        local value = levels[level]
        if type(value) == 'number' then
          owner[stat] = owner[stat] + value
        elseif type(value) == 'string' and value:match('%%') then
          local original = owner.class[stat]
          local percent = tonumber(value:match('%-?%d')) / 100
          owner[stat] = owner[stat] + original * percent
        end
      end)
    end
  end)
end

