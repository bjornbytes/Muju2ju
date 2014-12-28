local g = love.graphics
local sha1 = require 'lib/deps/sha1/sha1'

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

  self.hashes = {}

  self.patcherThread = love.thread.newThread('app/thread/patcher.lua')
  self.patcherOut = love.thread.getChannel('patcher.out')
  self.patchProgress = 0
  self.patching = false
  self.fileCount = 390
end

function MenuLogin:update()
  self:updateCursorPosition()

  local hashed = self.patcherOut:pop()
  if hashed then
    if hashed == 'done' then
      self.hash = self.patcherOut:pop()
      self:doneHashing(self.hash)
    else
      print(hashed)
      self.patchProgress = tonumber(hashed)
      print('hashed ' .. hashed .. ' files')
    end
  end

  if self.patcherThread:getError() then
    print(self.patcherThread:getError())
  end
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

  if self.patching then
    g.setColor(0, 0, 0, 100)
    g.rectangle('fill', u * .2, v * .45, u * .6, v * .1)

    g.setColor(100, 100, 100)
    g.rectangle('line', u * .2 + .5, v * .45 + .5, u * .6, v * .1)

    g.setColor(200, 200, 200)
    local percent = self.patchProgress / self.fileCount
    g.rectangle('fill', u * .2 + 8, v * .45 + 8, (u * .6 - 16) * percent, v * .1 - 16)
  end
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

  ctx.loader:set('Logging in...')
end

function MenuLogin:hubMessage(message, data)
  if message == 'login' then
    if data.error then
      print('login failed (' .. data.error .. ')')

      if data.error == 401 then
        ctx.failure:set('Incorrect username or password')
      elseif data.error == 'Network is unreachable' then
        ctx.failure:set('Unable to connect')
      else
        ctx.failure:set('Unknown error occurred')
      end

      ctx.loader:unset()
    else
      ctx.user = data.user
      ctx.user.token = data.token
      self:patch()
    end
  elseif message == 'connect' then
    if data.patch then
      ctx.hub:send('patch', {hashes = self.hashes})
      ctx.loader:set('Patching...')
    else
      ctx:push('main')
      ctx.loader:unset()
    end
  elseif message == 'patch' then
    
    ctx:push('main')
    ctx.loader:unset()
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

function MenuLogin:resize()
  table.clear(self.geometry)
end

function MenuLogin:patch()
  ctx.loader:set('Checking game version...')

  self.patcherThread:start()
  self.patching = true
end

function MenuLogin:doneHashing(hash)
  ctx.hub:send('connect', {gameHash = hash})
end
