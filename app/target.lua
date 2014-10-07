Target = class()

local teamFilters = {
  all = function() return true end,
  enemy = function(a, b) return a.team ~= b.team end,
  ally = function(a, b) return a.team == b.team end
}

local getEntries = {
  shrine = function(source, teamFilter, t)
    ctx.shrines:each(function(shrine)
      if source ~= shrine and teamFilter(source, shrine) then
        table.insert(t, {shrine, math.abs(shrine.x - source.x)})
      end
    end)
  end,
  player = function(source, teamFilter, t)
    ctx.players:each(function(player)
      if source ~= player and not player.dead and player.invincible == 0 and teamFilter(source, player) then
        table.insert(t, {player, math.abs(player.x - source.x)})
      end
    end)
  end,
  unit = function(source, teamFilter, t)
    ctx.units:each(function(unit)
      if source ~= unit and not unit.dead and teamFilter(source, unit) and unit:isTargetable(source) then
        table.insert(t, {unit, math.abs(unit.x - source.x)})
      end
    end)
  end
}

local function halp(source, teamFilter, arg)
  local targets = {}
  teamFilter = teamFilters[teamFilter]
  table.each(arg, function(kind) getEntries[kind](source, teamFilter, targets) end)
  return targets
end

function Target:closest(source, teamFilter, ...)
  local targets = halp(source, teamFilter, {...})
  table.sort(targets, function(a, b) return a[2] < b[2] end)
  return targets[1] and unpack(targets[1])
end

function Target:inRange(source, range, teamFilter, ...)
  local targets = halp(source, teamFilter, {...})
  return table.map(table.filter(targets, function(t) return t[2] <= range + t[1].width / 2 end), function(t) return t[1] end)
end
