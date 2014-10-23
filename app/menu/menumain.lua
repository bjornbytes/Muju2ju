MenuMain = class()

local g = love.graphics

function MenuMain:init()
  -- Here lies the remains of Sir Gooey.
  -- Gooey was a great man, always wishing the best for
  -- everyone's user interfaces.  We all knew him at
  -- one point.  We all knew of his great potential.
  -- Such a tragedy, truly, to see him pass this early
  -- in his short life.  May the force be with you.

	--[[self.gooey = Gooey(data.gooey.menu.main)

	self.gooey:find('exitButton'):on('clicked', function()
		love.event.quit()
	end)

	self.gooey:find('survivalButton'):on('clicked', function()
    ctx.pages.lobby.kind = 'survival'
    ctx.page = 'lobby'
	end)

	self.gooey:find('versusButton'):on('clicked', function()
    ctx.pages.lobby.kind = 'versus'
    ctx.page = 'lobby'
	end)]]

  -- Ghetto Gooey.
  self.geometry = {
    survival = function()
      local u, v = ctx.u, ctx.v
      local gx = self.gutter.offset + self.gutter.width
      local x = gx * u
      local w = 1 - gx
      return x + ((.5 - .08) * w * u) - (.2 * u), .82 * v, .2 * u, .1 * v
    end,

    versus = function()
      local u, v = ctx.u, ctx.v
      local x = (self.gutter.offset + self.gutter.width) * u
      local w = 1 - (self.gutter.width + self.gutter.offset)
      return x + ((.5 + .08) * w * u), .82 * v, .2 * u, .1 * v
    end,

    units = function()
      local u, v = ctx.u, ctx.v
      local gx = self.gutter.offset + self.gutter.width
      local w = 1 - gx
      local ct = 3 or table.count(ctx.user.units)
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
      return (gx + w / 2) * u, (ctx.nav.height + y) * v, radius * v
    end,

    unitRunes = function()
      local u, v = ctx.u, ctx.v
      local units = self.geometry.units()
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
      local x, y, r = self.geometry.muju()
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
end

function MenuMain:draw()
  local u, v = ctx.u, ctx.v
  local mx, my = love.mouse.getPosition()

  self.gutter:draw()

  -- Survival Button
  g.rectangle('line', self.geometry.survival())

  -- Versus Button
  g.rectangle('line', self.geometry.versus())

  -- Portraits
  table.each(self.geometry.units(), function(unit)
    g.circle('line', unpack(unit))
  end)

  g.circle('line', self.geometry.muju())

  -- Runes
  table.each(self.geometry.unitRunes(), function(unit)
    table.each(unit, function(rune)
      g.circle('line', unpack(rune))
    end)
  end)

  table.each(self.geometry.mujuRunes(), function(rune)
    g.circle('line', unpack(rune))
  end)
end

function MenuMain:keypressed(key)
  self.gutter:keypressed(key)
end

function MenuMain:mousepressed(x, y, b)
  if b == 'l' then
    if math.inside(x, y, self.geometry.survival()) then
      ctx.hub:send('lobbyCreate', {gameType = 'survival'})
    elseif math.inside(x, y, self.geometry.versus()) then
      ctx.hub:send('lobbyCreate', {gameType = 'versus'})
    end
  end

  self.gutter:mousepressed(x, y, b)
end

function MenuMain:hubMessage(message, data)
  if message == 'lobbyCreate' then
    ctx:push('lobby', data.gameType or 'survival')
  end
end
