Target = class()

local getEntries = {
  shrine = function(source, t)
    ctx.shrines:each(function(shrine)
      if source ~= shrine then
        table.insert(t, {shrine, math.abs(shrine.x - source.x)})
      end
    end)
  end,
  player = function(source, t)
    ctx.players:each(function(player)
      if source ~= player and not player.dead and player.invincible == 0 then
        table.insert(t, {player, math.abs(player.x - source.x)})
      end
    end)
  end,
  enemy = function(source, t)
    ctx.units:each(function(unit)
      if source ~= unit and not unit.dead and unit.owner ~= source.owner and unit.team ~= source.team then
        table.insert(t, {unit, math.abs(unit.x - source.x)})
      end
    end)
  end
}

local function halp(source, arg)
  local targets = {}
  table.each(arg, function(kind) getEntries[kind](source, targets) end)
  return targets
end

function Target:closestEnemy(source, ...)
  local targets = halp(source, false, {...})
  targets = table.filter(targets, function(t) return t[1].team ~= source.team end)
  table.sort(targets, function(a, b) return a[2] < b[2] end)
  return targets[1] and unpack(targets[1])
end

function Target:closestAlly(source, ...)
  local targets = halp(source, true, {...})
  targets = table.filter(targets, function(t) return t[1].team == source.team end)
  table.sort(targets, function(a, b) return a[2] < b[2] end)
  return targets[1] and unpack(targets[1])
end

function Target:enemiesInRange(source, range, ...)
  local targets = halp(source, false, {...})
  targets = table.filter(targets, function(t) return t[1].team ~= source.team end)
  return table.map(table.filter(targets, function(t) return t[2] <= range + t[1].width / 2 end), function(t) return t[1] end)
end

function Target:alliesInRange(source, range, ...)
  local targets = halp(source, true, {...})
  targets = table.filter(targets, function(t) return t[1].team == source.team end)
  return table.map(table.filter(targets, function(t) return t[2] <= range + t[1].width / 2 end), function(t) return t[1] end)
end
