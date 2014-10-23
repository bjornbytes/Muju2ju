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

  self.geometry = {
    survival = function()
      return (.5 - .3) * ctx.u, .75 * ctx.v, .2 * ctx.u, .1 * ctx.v
    end,

    versus = function()
      return (.5 + .1) * ctx.u, .75 * ctx.v, .2 * ctx.u, .1 * ctx.v
    end
  }
end

function MenuMain:draw()
  local u, v = ctx.u, ctx.v

  g.setColor(255, 255, 255, 100)

  -- Survival Button
  g.rectangle('line', self.geometry.survival())

  -- Versus Button
  g.rectangle('line', self.geometry.versus())
end

function MenuMain:mousepressed(x, y, b)
  if b == 'l' then
    if math.inside(x, y, self.geometry.survival()) then
      ctx.hub:send('lobbyCreate', {gameType = 'survival'})
    elseif math.inside(x, y, self.geometry.versus()) then
      ctx.hub:send('lobbyCreate', {gameType = 'versus'})
    end
  end
end

function MenuMain:hubMessage(message, data)
  if message == 'lobbyCreate' then
    ctx:push('lobby', data.gameType or 'survival')
  end
end
