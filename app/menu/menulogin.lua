local g = love.graphics
local sha1 = require 'lib/deps/sha1/sha1'

MenuLogin = class()

function MenuLogin:init()
  self.geometry = setmetatable({}, {__index = function(t, k)
    return rawset(t, k, self.geometryFunctions[k]())[k]
  end})

  self.geometryFunctions = {
    frame = function()
      local u, v = ctx.u, ctx.v
      local retype = self.retype
      local y = (.35 - (.17 / 2) * retype) * v
      local height = (.525 + .17 * retype) * v
      return {u * .25, y, u * .5, height}
    end,

    username = function()
      local u, v = ctx.u, ctx.v
      local retype = self.retype
      local y = (.45 - (.17 / 2 * retype)) * v
      return {u * .325, y, u * .35, v * .075}
    end,

    password = function()
      local u, v = ctx.u, ctx.v
      local retype = self.retype
      local y = (.45 - (.17 / 2 * retype) + .17) * v
      return {u * .325, y, u * .35, v * .075}
    end,

    retype = function()
      local u, v = ctx.u, ctx.v
      local retype = self.retype
      local y = (.45 - (.17 / 2 * retype) + .34) * v
      return {u * .325, y, u * .35, v * .075}
    end,

    login = function()
      local u, v = ctx.u, ctx.v
      local retype = self.retype
      local height = .075
      local edge = self.geometry.frame[2] + self.geometry.frame[4]
      local y = edge - (.05 + height) * v
      return {u * .325, y, u * .12, height * v}
    end,

    signup = function()
      local u, v = ctx.u, ctx.v
      local retype = self.retype
      local frameHeight = self.geometry.frame[4]
      local height = .075
      local edge = self.geometry.frame[2] + self.geometry.frame[4]
      local y = edge - (.05 + height) * v
      return {u * .555, y, u * .12, height * v}
    end,
  }

  self.input = MenuTextInput()
  self.input:add('username', '', 'Username')
  self.input:add('password', '', 'Password')
  self.input:add('retype', '', 'Retype Password')

  self.textboxPadding = .0225
  self.cursorx = nil
  self.prevcursorx = self.cursorx

  self.hashes = {}

  self.patcherThread = love.thread.newThread('app/thread/patcher.lua')
  self.patcherOut = love.thread.getChannel('patcher.out')
  self.patchProgress = 0
  self.patching = false
  self.fileCount = 390
  
  self.retype = 0
  self.lepr = Lepr(self, .4, 'inOutBack', {'retype'})
  self.signUp = false
end

function MenuLogin:update()
  self:updateCursorPosition()

  while true do
    local hashed = self.patcherOut:pop()
    if hashed then
      if hashed == 'done' then
        self.hash = self.patcherOut:pop()
        self:doneHashing(self.hash)
      else
        self.patchProgress = self.patchProgress + 1
        if type(hashed) == 'table' then table.insert(self.hashes, hashed) end
      end
    else
      break
    end
  end

  if self.patcherThread:getError() then
    print(self.patcherThread:getError())
  end
end

function MenuLogin:draw()
  local u, v = ctx.u, ctx.v

  g.setColor(255, 255, 255)
  local scale = v * .325 / data.media.graphics.title:getHeight()
  g.draw(data.media.graphics.title, u * .5, 0, 0, scale, scale, data.media.graphics.title:getWidth() / 2)

  self.lepr:update(delta)
  if self.lepr.tween.clock < self.lepr.tween.duration then table.clear(self.geometry) end
  local retypeAlpha = math.clamp(self.retype, 0, 1) * 255

  g.setColor(255, 255, 255)
  local scale = v * .325 / data.media.graphics.title:getHeight()
  g.draw(data.media.graphics.title, u * .5, 0, 0, scale, scale, data.media.graphics.title:getWidth() / 2)

  g.setColor(0, 0, 0, 160)
  g.rectangle('fill', unpack(self.geometry.frame))

  g.push()
  g.translate(.5, .5)

  local val = self.input.focused == 'username' and 200 or 100
  g.setColor(val, val, val)
  g.rectangle('line', unpack(self.geometry.username))

  val = self.input.focused == 'password' and 200 or 100
  g.setColor(val, val, val)
  g.rectangle('line', unpack(self.geometry.password))

  val = self.input.focused == 'retype' and 200 or 100
  g.setColor(val, val, val, retypeAlpha)
  g.rectangle('line', unpack(self.geometry.retype))

  g.setColor(100, 100, 100)
  g.rectangle('line', unpack(self.geometry.login))
  g.rectangle('line', unpack(self.geometry.signup))
  g.pop()

  g.setFont('mesmerize', v * .03)
  g.setColor(200, 200, 200)
  g.print('Username', self.geometry.username[1], self.geometry.username[2] - (.05 * v))
  g.print('Password', self.geometry.password[1], self.geometry.password[2] - (.05 * v))
  g.setColor(200, 200, 200, retypeAlpha)
  g.print('Retype Password', self.geometry.retype[1], self.geometry.retype[2] - (.05 * v))

  g.setColor(200, 200, 200)
  local _, uy = unpack(self.geometry.username)
  g.print(self.input.text.username, u * .325 + v * self.textboxPadding, uy + v * self.textboxPadding)

  local _, py = unpack(self.geometry.password)
  g.print(('*'):rep(#self.input.text.password), u * .325 + v * self.textboxPadding, py + v * self.textboxPadding)

  g.setColor(200, 200, 200, retypeAlpha)
  local _, ry = unpack(self.geometry.retype)
  g.print(('*'):rep(#self.input.text.retype), u * .325 + v * self.textboxPadding, ry + v * self.textboxPadding)

  if self.input.focused and self.cursorx then
    local y = self.geometry[self.input.focused][2] + self.textboxPadding * v
    local cursorx = math.lerp(self.prevcursorx or self.cursorx, self.cursorx, tickDelta / tickRate)
    g.setColor(255, 255, 255)
    g.line(cursorx, y, cursorx, y + g.getFont():getHeight())
  end

  g.setColor(200, 200, 200)
  local x, y, w, h
  x, y, w, h = unpack(self.geometry.login)
  g.printCenter(self.signUp and 'Ok' or 'Login', x + w / 2, y + h / 2)
  x, y, w, h = unpack(self.geometry.signup)
  g.printCenter(self.signUp and 'Cancel' or 'Sign Up', x + w / 2, y + h / 2)

  if self.patching then
    g.setColor(0, 0, 0)
    g.rectangle('fill', 0, 0, u, v)

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
    elseif self.input.focused == 'password' then self.input:focus(self.signUp and 'retype' or 'username')
    elseif self.input.focused == 'retype' then self.input:focus('username') end
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
  elseif math.inside(mx, my, unpack(self.geometry.retype)) and self.signUp then
    self.input:focus('retype')
    self:seekCursor('retype', mx)
  elseif math.inside(mx, my, unpack(self.geometry.login)) then
    if self.signUp then
      if self.input.text.password == self.input.text.retype then
        ctx.hub:send('signup', {username = self.input.text.username, password = self.input.text.password})
      else
        ctx.failure:set('Passwords don\'t match #shrekt')
      end
    else
      self:authenticate()
    end
  elseif math.inside(mx, my, unpack(self.geometry.signup)) then
    self.retype = 1 - self.retype
    self.signUp = not self.signUp
    self.lepr:reset()
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
  elseif message == 'signup' then
    if data.error then
      print(data.error)
      ctx.failure:set('Unknown error occurred')
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
  table.sort(self.hashes, function(a, b) return a.path < b.path end)

  ctx.hub:send('connect', {gameHash = hash})
end
