MenuMainDeck = class()

local g = love.graphics

function MenuMainDeck:init()
  self.frameWidth = 0

  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

  self.geometryFunctions = {
    units = function()
      local u, v = ctx.u, ctx.v
      local ct = 3
      local inc = .3 * self.frameWidth
      local radius = .08
      local topmargin = .08
      local x = self.frameWidth / 2 - (inc * (ct - 1) / 2)
      local res = {}
      for i = 1, ct do
        table.insert(res, {x, (topmargin + radius) * v, radius * v})
        x = x + inc
      end
      return res
    end,

    muju = function()
      return {self.frameWidth / 2, .5 * ctx.v, .08 * ctx.v}
    end,

    unitRunes = function()
      local u, v = ctx.u, ctx.v
      local units = self.geometry.units
      local radius = .035
      local margin = .04
      local inc = .035
      local spread = (self.frameWidth / u) ^ .6
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
      local spread = (self.frameWidth / u) ^ .6
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
end

function MenuMainDeck:update()

end

function MenuMainDeck:draw()
  local u, v = ctx.u, ctx.v

  g.setColor(255, 255, 255)

  self.frameWidth = (1 - (ctx.pages.main.gutter.offset + ctx.pages.main.gutter.width)) * u

  g.push()
  g.translate(self:screenPoint(0, 0))

  table.each(self.geometry.units, function(unit, i)
    local x, y, r = unpack(unit)
    local image = data.media.graphics.menuCove
    local scale = r * 2 / 385
    local val = ctx.user.deck[i] and 255 or 180
    g.setColor(val, val, val)
    g.draw(image, x, y, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
    if ctx.user.deck[i] then
      g.printCenter(ctx.user.deck[i].code:capitalize(), x, y)
    end
  end)

  table.each(self.geometry.unitRunes, function(list, unit)
    table.each(list, function(rune, i)
      local x, y, r = unpack(rune)
      local image = data.media.graphics.menuCove
      local scale = r * 2 / 385
      local val = (ctx.user.deck[unit] and ctx.user.deck[unit].runes[i]) and 255 or 180
      g.setColor(val, val, val)
      g.draw(image, x, y, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
      if ctx.user.deck[unit] and ctx.user.deck[unit].runes[i] then
        local id = ctx.user.deck[unit].runes[i].id
        -- g.printCenter(runes[id].name, x, y)
      end
    end)
  end)

  local x, y, r = unpack(self.geometry.muju)
  local image = data.media.graphics.menuCove
  local scale = r * 2 / 385
  g.setColor(255, 255, 255)
  g.draw(image, x, y, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
  g.printCenter('Muju', x, y)

  table.each(self.geometry.mujuRunes, function(rune)
    local x, y, r = unpack(rune)
    local image = data.media.graphics.menuCove
    local scale = r * 2 / 385
    g.setColor(180, 180, 180)
    g.draw(image, x, y, 0, scale, scale, image:getWidth() / 2, image:getHeight() / 2)
  end)

  g.pop()
end

function MenuMainDeck:resize()
  table.clear(self.geometry)
end

function MenuMainDeck:screenPoint(x, y)
  local gutter, u, v = ctx.pages.main.gutter, ctx.u, ctx.v
  return x + (gutter.offset + gutter.width) * u, y and y + ctx.nav.height * v + .5
end
