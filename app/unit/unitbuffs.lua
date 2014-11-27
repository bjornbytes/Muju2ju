UnitBuffs = class()

function UnitBuffs:init(owner)
  self.owner = owner
  self.list = {}

  table.merge(table.only(self.owner.class, Unit.classStats), self.owner)
  self:applyRunes()
end

function UnitBuffs:update()
  table.with(self.list, 'update')
end

function UnitBuffs:add(code, vars)
  local buff = data.buffs[code]()
  self.list[code] = buff
  f.exe(buff.activate, buff, self.owner, vars)
end

function UnitBuffs:getBuff(code)
  return self.list[code]
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

