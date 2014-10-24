MenuLobby = class()

local g = love.graphics

function MenuLobby:init()
  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

  self.geometryFunctions = {
    survivalStart = function()
      return {(.5 - .1) * ctx.u, .82 * ctx.v, .2 * ctx.u, .1 * ctx.v}
    end,

    centeredPlayer1 = function()
      local u, v = ctx.u, ctx.v
      return {(.5 - .25) * u, .2 * v, .5 * u, .25 * v}
    end,

    centeredPlayer2 = function()
      local u, v = ctx.u, ctx.v
      return {(.5 - .25) * u, .5 * v, .5 * u, .25 * v}
    end
  }
end

function MenuLobby:activate(kind, players)
  self.kind = kind
  self.players = players
  self.searching = false
end

function MenuLobby:update()
  --
end

function MenuLobby:draw()
  local u, v = ctx.u, ctx.v

  g.setColor(255, 255, 255)

  g.setFont('philosopher', .08 * v)
  local str = self.kind:capitalize()
  g.print(str, u * .5 - g.getFont():getWidth(str) / 2, (ctx.nav.height + .02) * v)

  if self.kind == 'survival' then
    -- draw top button using data from self.players[1]
    -- draw bottom button using data from self.players[2], or an add button if there is no second player

    g.rectangle('line', unpack(self.geometry.centeredPlayer1))
    g.print(self.players[1].username, (.5 * u) - g.getFont():getWidth(self.players[1].username) / 2, .25 * v)
    g.rectangle('line', unpack(self.geometry.centeredPlayer2))

    if self.players[2] then
      g.print(self.players[2].username, (.5 * u) - g.getFont():getWidth(self.players[2].username) / 2, .25 * v)
    end

    if not self.searching then
      g.rectangle('line', unpack(self.geometry.survivalStart))
    end
  elseif self.kind == 'versus' then
    if not self.starting then
      -- draw top and bottom button like in survival.
    else
      -- draw either 4 buttons or 2 buttons depending on how many players in lobby.
    end
  end
end

function MenuLobby:mousepressed(x, y, b)
  if b == 'l' then
    if self.kind == 'survival' then
      if math.inside(x, y, unpack(self.geometry.survivalStart)) then
        self.searching = true
        ctx.hub:send('lobbyQueue')
      elseif #self.players < 2 and math.inside(x, y, unpack(self.geometry.centeredPlayer2)) then
        ctx.hub:send('lobbyInvite', {username = 'yoko'})
      end
    end
  end
end

function MenuLobby:resize()
  table.clear(self.geometry)
end

function MenuLobby:hubMessage(message, data)
  if message == 'lobbyStart' then
    Context:add(Game, data, ctx.user)
    Context:remove(ctx)
  elseif message == 'lobbyAdd' then
    if data.user.username ~= ctx.user.username then
      table.insert(self.players, data.user)
    end
  end
end
