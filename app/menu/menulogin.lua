local g = love.graphics

MenuLogin = class()

function MenuLogin:init()
  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

  self.geometryFunctions = {
    username = function()
      local u, v = ctx.u, ctx.v
      return {u * .325, v * .45, u * .35, v * .075}
    end,

    password = function()
      local u, v = ctx.u, ctx.v
      return {u * .325, v * .62, u * .35, v * .075}
    end,

    login = function()
      local u, v = ctx.u, ctx.v
      return {u * .325, v * .75, u * .12, v * .075}
    end,

    signup = function()
      local u, v = ctx.u, ctx.v
      return {u * .555, v * .75, u * .12, v * .075}
    end
  }

  self.input = MenuTextInput()
  self.input:add('username', '', 'Username')
  self.input:add('password', '', 'Password')

  self.textboxPadding = .0225
  self.cursorx = nil
  self.prevcursorx = self.cursorx
end

function MenuLogin:update()
  self:updateCursorPosition()
end

function MenuLogin:draw()
  local u, v = ctx.u, ctx.v

  g.setColor(0, 0, 0, 160)
  g.rectangle('fill', u * .25, v * .35, u * .5, v * .525)

  g.push()
  g.translate(.5, .5)

  local val = self.input.focused == 'username' and 200 or 100
  g.setColor(val, val, val)
  g.rectangle('line', unpack(self.geometry.username))

  val = self.input.focused == 'password' and 200 or 100
  g.setColor(val, val, val)
  g.rectangle('line', unpack(self.geometry.password))

  g.setColor(100, 100, 100)
  g.rectangle('line', unpack(self.geometry.login))
  g.rectangle('line', unpack(self.geometry.signup))
  g.pop()

  g.setFont('mesmerize', v * .03)
  g.setColor(200, 200, 200)
  g.print('Username', u * .325, v * .40)
  g.print('Password', u * .325, v * .57)

  local _, uy = unpack(self.geometry.username)
  g.print(self.input.text.username, u * .325 + v * self.textboxPadding, uy + v * self.textboxPadding)

  local _, py = unpack(self.geometry.password)
  g.print(('*'):rep(#self.input.text.password), u * .325 + v * self.textboxPadding, py + v * self.textboxPadding)

  if self.input.focused and self.cursorx then
    local y = (self.input.focused == 'username' and uy or py) + v * self.textboxPadding
    local cursorx = math.lerp(self.prevcursorx or self.cursorx, self.cursorx, tickDelta / tickRate)
    g.setColor(255, 255, 255)
    g.line(cursorx, y, cursorx, y + g.getFont():getHeight())
  end

  g.setColor(200, 200, 200)

  g.printCenter('Login', u * .325 + u * .06, v * .75 + v * .0375)
  g.printCenter('Sign Up', u * .555 + u * .06, v * .75 + v * .0375)

  g.setColor(255, 255, 255)
  local scale = v * .325 / data.media.graphics.title:getHeight()
  g.draw(data.media.graphics.title, u * .5, 0, 0, scale, scale, data.media.graphics.title:getWidth() / 2)
end

function MenuLogin:keypressed(key)
  if key == 'tab' then
    if self.input.focused == 'username' then self.input:focus('password')
    elseif self.input.focused == 'password' then self.input:focus('username') end
  elseif key == 'return' and self.input.focused == 'password' then
    self:authenticate()
  end

  self.input:keypressed(key)
end

function MenuLogin:textinput(char)
  self.input:textinput(char)
end

function MenuLogin:mousepressed(mx, my, b)
  if b ~= 'l' then return end

  self.input:unfocus()
  if math.inside(mx, my, unpack(self.geometry.username)) then
    self.input:focus('username')
    self:seekCursor('username', mx)
  elseif math.inside(mx, my, unpack(self.geometry.password)) then
    self.input:focus('password')
    self:seekCursor('password', mx)
  elseif math.inside(mx, my, unpack(self.geometry.login)) then
    self:authenticate()
  elseif math.inside(mx, my, unpack(self.geometry.signup)) then
    --
  end
end

function MenuLogin:authenticate()
  local username, password = self.input.text.username, self.input.text.password
  ctx.hub:send('login', {username = username, password = password})

  print('logging in')

  -- set up loading spinner!
end

function MenuLogin:hubMessage(message, data)
  if message == 'login' then
    if data.error then
      print('login failed (' .. data.error .. ')')
    else
      ctx.user = data.user
      ctx.user.token = data.token
      table.print(ctx.user)
      ctx.hub:send('connect')
    end
  elseif message == 'connect' then
    ctx:push('main')
  end
end

function MenuLogin:seekCursor(code, mx)
  local u, v = ctx.u, ctx.v
  local x, y, w, h = unpack(self.geometry[code])
  x = x + self.textboxPadding * v
  g.setFont('mesmerize', v * .03)

  local text = self.input.text[code]
  if code == 'password' then text = ('*'):rep(#text) end

  self.input.cursorPosition = 0
  if x + g.getFont():getWidth(text) < mx then
    self.input.cursorPosition = #text
  else
    local function subwidth(pos) return g.getFont():getWidth(text:sub(1, pos)) end
    while x + subwidth(self.input.cursorPosition) < mx and self.input.cursorPosition < #text do
      self.input.cursorPosition = self.input.cursorPosition + 1
    end
    if (x + subwidth(self.input.cursorPosition)) - mx > (subwidth(self.input.cursorPosition) - subwidth(self.input.cursorPosition - 1)) / 2 then
      self.input.cursorPosition = self.input.cursorPosition - 1
    end
  end
end

function MenuLogin:updateCursorPosition()
  self.prevcursorx = self.cursorx
  if self.input.focused then
    local u, v = ctx.u, ctx.v
    local x = u * .325 + v * self.textboxPadding
    local y = (self.input.focused == 'username' and self.geometry.username[2] or self.geometry.password[2]) + v * self.textboxPadding
    local cursorx = x
    local text = self.input.text[self.input.focused]
    if self.input.focused == 'password' then text = ('*'):rep(#text) end
    if self.input.cursorPosition > 0 then
      cursorx = x + g.getFont():getWidth(text:sub(1, self.input.cursorPosition))
    end
    cursorx = cursorx + 1
    self.cursorx = math.lerp(self.cursorx or cursorx, cursorx, math.min(18 * tickRate))
    self.cursorx = math.clamp(self.cursorx, x, x + g.getFont():getWidth(text .. 'M'))
  end
end
