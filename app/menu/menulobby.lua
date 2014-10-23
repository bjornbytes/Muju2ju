MenuLobby = class()

local g = love.graphics

function MenuLobby:init()
  self.geometry = {
    survivalStartSingle = function()
      return (.5 - .3) * ctx.u, .75 * ctx.v, .2 * ctx.u, .1 * ctx.v
    end,

    survivalStartCoop = function()
      return (.5 + .1) * ctx.u, .75 * ctx.v, .2 * ctx.u, .1 * ctx.v
    end
  }
end

function MenuLobby:activate(kind)
  self.kind = kind
  self.state = 'pre'
  self.players = {}

  self.lepr = Lepr(self, .45, 'inOutCubic', {})
end

function MenuLobby:update()

end

function MenuLobby:draw()
  local u, v = ctx.u, ctx.v

  self.lepr:update(delta)

  g.setColor(255, 255, 255)

  if self.kind == 'survival' then
    g.rectangle('line', self.geometry.survivalStartSingle())
    g.rectangle('line', self.geometry.survivalStartCoop())
  end
end

function MenuLobby:mousepressed(x, y, b)
  if b == 'l' then
    if self.kind == 'survival' then
      if math.inside(x, y, self.geometry.survivalStartSingle()) then
        ctx.hub:send('lobbyQueue')
      elseif math.inside(x, y, self.geometry.survivalStartCoop()) then
        ctx.hub:send('lobbyQueue')
      end
    end
  end
end

function MenuLobby:hubMessage(message, data)
  if message == 'lobbyStart' then
    Context:add(Game, data, ctx.user)
    Context:remove(ctx)
  end
end
