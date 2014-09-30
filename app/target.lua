Target = class()

local getEntries = {
  shrine = function(source, t)
    if source == ctx.shrine then return end
    table.insert(t, {ctx.shrine, math.abs(ctx.shrine.x - source.x)})
  end,
  player = function(source, t)
    ctx.players:each(function(player)
      if player.dead or player.invincible > 0 or source == player then return end
      table.insert(t, {player, math.abs(player.x - source.x)})
    end)
  end,
  enemy = function(source, t)
    ctx.units:each(function(unit)
      if source ~= unit and not unit.dead and unit.owner ~= source.owner then
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

function Target:closest(source, ...)
  local targets = halp(source, {...})
  table.sort(targets, function(a, b) return a[2] < b[2] end)
  return targets[1] and unpack(targets[1])
end

function Target:inRange(source, range, ...)
  local targets = halp(source, {...})
  return table.map(table.filter(targets, function(t) return t[2] <= range + t[1].width / 2 end), function(t) return t[1] end)
end
