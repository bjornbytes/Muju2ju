MenuMain = class()

local g = love.graphics

function MenuMain:init()

  -- Ghetto Gooey.
  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

  self.geometryFunctions = {
    survival = function()
      local u, v = ctx.u, ctx.v
      local gx = self.gutter.offset + self.gutter.width
      local x = gx * u
      local w = 1 - gx
      return {x + ((.5 - .08) * w * u) - (.2 * u), .82 * v, .2 * u, .1 * v}
    end,

    versus = function()
      local u, v = ctx.u, ctx.v
      local x = (self.gutter.offset + self.gutter.width) * u
      local w = 1 - (self.gutter.width + self.gutter.offset)
      return {x + ((.5 + .08) * w * u), .82 * v, .2 * u, .1 * v}
    end,

    units = function()
      local u, v = ctx.u, ctx.v
      local gx = self.gutter.offset + self.gutter.width
      local w = 1 - gx
      local ct = #ctx.user.deck
      local inc = .3 * w * u
      local radius = .08
      local topmargin = .08
      local x = (gx + w  / 2) * u - (inc * (ct - 1) / 2)
      local res = {}
      for i = 1, ct do
        table.insert(res, {x, (ctx.nav.height + topmargin + radius) * v, radius * v})
        x = x + inc
      end
      return res
    end,

    muju = function()
      local u, v = ctx.u, ctx.v
      local gx = self.gutter.offset + self.gutter.width
      local w = 1 - gx
      local radius = .08
      local y = .5
      return {(gx + w / 2) * u, (ctx.nav.height + y) * v, radius * v}
    end,

    unitRunes = function()
      local u, v = ctx.u, ctx.v
      local units = self.geometry.units
      local radius = .035
      local margin = .04
      local inc = .035
      local spread = (1 - (self.gutter.offset + self.gutter.width)) ^ .6
      local res = {}
      for i = 1, #units do
        local x, y, r = unpack(units[i])
        res[i] = {}
        local xx = x - (inc + 2 * radius) * v * spread
        for j = 1, 3 do
          local bump = .015 * ((j == 1 or j == 3) and 1 or 0)
          local y = y + r + (margin + radius - bump) * v
          table.insert(res[i], {xx, y, radius * v})
          xx = xx + (inc + 2 * radius) * v * spread
        end
      end
      return res
    end,

    mujuRunes = function()
      local u, v = ctx.u, ctx.v
      local x, y, r = unpack(self.geometry.muju)
      local radius = .045
      local margin = .04
      local inc = .045
      local spread = (1 - (self.gutter.offset + self.gutter.width)) ^ .6
      local xx = x - ((inc + 2 * radius) * v * spread) - ((inc * .85 + 2 * radius) * v * spread)
      local res = {}
      for j = 1, 5 do
        local bump = .01 * ((j <= 2 or j >= 4) and 1 or 0)
        local bump = bump + (.03 * ((j == 1 or j == 5) and 1 or 0))
        local y = y + r + (margin + radius - bump) * v
        table.insert(res, {xx, y, radius * v})
        local inc = inc * ((j == 1 or j == 4) and .85 or 1)
        xx = xx + (inc + 2 * radius) * v * spread
      end
      return res
    end
  }

  self.gutter = MenuMainGutter()
  self.hover = MenuMainHover()
end

function MenuMain:activate()
  local function makeIcon() return {x = 0, y = 0, targetX = 0, targetY = 0, smooth = 16} end
  self.icons = {}
  table.each(ctx.user.units, function(unit) self.icons[unit] = makeIcon() end)
  table.each(ctx.user.runes, function(rune) self.icons[rune.token] = makeIcon() end)

  self.gutter.units = {}
  for _, code in ipairs(ctx.user.units) do
    local inDeck = false
    for j = 1, #ctx.user.deck do if ctx.user.deck[j].code == code then inDeck = true break end end
    if not inDeck then
      table.insert(self.gutter.units, code)
    end
  end

  self.gutter.runes = {}
  for _, rune in ipairs(ctx.user.runes) do
    local token = rune.token
    local inDeck = false
    for i = 1, #ctx.user.deck do
      for j = 1, #ctx.user.deck[i].runes do
        if ctx.user.deck[i][j].token == token then
          inDeck = true
          break
        end
      end
    end

    if not inDeck then
      table.insert(self.gutter.runes, token)
    end
  end
end

function MenuMain:update()
  self.gutter:update()
  self.hover:update()
end

function MenuMain:draw()
  local u, v = ctx.u, ctx.v
  local mx, my = love.mouse.getPosition()

  self.gutter:draw()
  self:positionIcons()

  g.setColor(255, 255, 255)

  -- Survival Button
  g.rectangle('line', unpack(self.geometry.survival))

  -- Versus Button
  g.rectangle('line', unpack(self.geometry.versus))

  -- Portraits
  table.each(self.geometry.units, function(unit)
    g.circle('line', unpack(unit))
  end)

  g.circle('line', unpack(self.geometry.muju))

  -- Runes
  table.each(self.geometry.unitRunes, function(unit)
    table.each(unit, function(rune)
      g.circle('line', unpack(rune))
    end)
  end)

  table.each(self.geometry.mujuRunes, function(rune)
    g.circle('line', unpack(rune))
  end)

  table.each(self.icons, function(icon)
    g.circle('fill', icon.x, icon.y, .035 * v)
  end)

  self.hover:draw()
end

function MenuMain:keypressed(key)
  self.gutter:keypressed(key)
end

function MenuMain:mousepressed(x, y, b)
  if b == 'l' then
    if math.inside(x, y, unpack(self.geometry.survival)) then
      ctx.hub:send('lobbyCreate', {gameType = 'survival'})
    elseif math.inside(x, y, unpack(self.geometry.versus)) then
      ctx.hub:send('lobbyCreate', {gameType = 'versus'})
    end
  end

  self.gutter:mousepressed(x, y, b)
  self.hover:mousepressed(x, y, b)
end

function MenuMain:mousereleased(x, y, b)
  self.hover:mousereleased(x, y, b)
end

function MenuMain:resize()
  table.clear(self.geometry)
  self.gutter:resize()
end

function MenuMain:hubMessage(message, data)
  if message == 'lobbyCreate' then
    ctx:push('lobby', data.gameType or 'survival')
  end
end

function MenuMain:positionIcons()
  local function snapHover(icon)
    if icon ~= self.icons[self.hover.icon] then
      icon.x, icon.y = icon.targetX, icon.targetY
    elseif not self.hover.active and math.distance(icon.x, icon.y, icon.targetX, icon.targetY) < 1 then
      self.hover.icon = nil
    end
  end

  local geometry = self.gutter.geometry.all
  table.each(geometry.units, function(unit, i)
    local icon = self.icons[self.gutter.units[i]]
    icon.targetX, icon.targetY = unpack(unit)
    snapHover(icon)
  end)

  table.each(geometry.runes, function(rune, i)
    local icon = self.icons[self.gutter.runes[i]]
    if icon then
      icon.targetX, icon.targetY = unpack(rune)
      snapHover(icon)
    end
  end)

  table.each(self.geometry.units, function(unit, i)
    if ctx.user.deck[i] then
      local icon = self.icons[ctx.user.deck[i].code]
      icon.targetX, icon.targetY = unpack(unit)
      snapHover(icon)
    end
  end)

  --[=[table.each(self.geometry.unitRunes, function(unit, i)
    table.each(unit, function(rune, j)
      local icon = self.icons[ctx.user.deck[i].runes[j]]
      icon.x, icon.y = unpack(unit)
    end)
  end)]=]

  if self.hover.active then
    self.icons[self.hover.icon].targetX = love.mouse.getX()
    self.icons[self.hover.icon].targetY = love.mouse.getY()
  end

  table.each(self.icons, function(icon)
    for _, k in pairs({'x', 'y'}) do
      icon[k] = math.lerp(icon[k], icon['target' .. k:capitalize()], math.min(icon.smooth * delta, 1))
    end
  end)
end
