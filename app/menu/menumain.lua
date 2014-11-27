MenuMain = class()

local g = love.graphics

function MenuMain:init()
  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

  self.geometryFunctions = {
    play = function()
      local u, v = ctx.u, ctx.v
      local gx = self.gutter.offset + self.gutter.width
      local x = gx * u
      local w = 1 - gx
      return {x + (.5 * w * u) - (.1 * u), .82 * v, .2 * u, .1 * v}
    end
  }

  self.gutter = MenuMainGutter()
  self.deck = MenuMainDeck()
  self.drag = MenuMainDrag()
end

function MenuMain:activate()
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
      table.insert(self.gutter.runes, rune)
    end
  end
end

function MenuMain:update()
  self.gutter:update()
  self.deck:update()
  self.drag:update()
end

function MenuMain:draw()
  local u, v = ctx.u, ctx.v
  local mx, my = love.mouse.getPosition()

  self.gutter:draw()
  self.deck:draw()

  g.setColor(255, 255, 255)

  -- Play Button
  local x, y, w, h = unpack(self.geometry.play)
  local hover = math.inside(mx, my, x, y, w, h)
  local image = hover and data.media.graphics.buttonYellowHover or data.media.graphics.buttonYellow
  g.draw(image, x, y, 0, w / image:getWidth(), h / image:getHeight())

  g.setFont('philosopher', .05 * v)
  g.printCenter('PLAY', x + w / 2, y + h / 2)

  self.drag:draw()
end

function MenuMain:keypressed(key)
  self.gutter:keypressed(key)
end

function MenuMain:mousepressed(x, y, b)
  if b == 'l' then
    if math.inside(x, y, unpack(self.geometry.play)) then
      ctx.hub:send('lobbyCreate', {gameType = 'versus'})
    end
  end

  self.gutter:mousepressed(x, y, b)
  self.drag:mousepressed(x, y, b)
end

function MenuMain:mousereleased(x, y, b)
  self.drag:mousereleased(x, y, b)
end

function MenuMain:resize()
  table.clear(self.geometry)
  self.gutter:resize()
  self.deck:resize()
end

function MenuMain:hubMessage(message, data)
  if message == 'lobbyCreate' then
    --ctx:push('lobby', data.gameType, data.users)
    ctx.hub:send('lobbyQueue')
  elseif message == 'lobbyStart' then
    Context:add(Game, data, ctx.user)
    Context:remove(ctx)
  end
end
