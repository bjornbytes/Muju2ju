Menu = class()

function Menu:load(user)
  self.user = user or {}
	self.sound = Sound()
	self.menuSounds = self.sound:loop({sound = 'menu'})
	self.font = love.graphics.newFont('media/fonts/pixel.ttf', 8)
	self.creditsAlpha = 0
	love.mouse.setCursor(love.mouse.newCursor('media/graphics/cursor.png'))

  love.keyboard.setKeyRepeat(true)
  
  if self.menuSounds then self.menuSounds:stop() end

  self.hub = MenuHub()
  self.nav = MenuNav()
  self.background = MenuBackground()
  self.loader = MenuLoader()
  self.tooltip = Tooltip()

  self.invitation = nil

  self.pages = {
    signup = MenuSignup(),
    login = MenuLogin(),
    main = MenuMain(),
    lobby = MenuLobby()
  }

  self:push(self.user.token and 'main' or 'login')

  if table.has(arg, 'test') then
    Context:remove(self)
    Context:add(Game, testConfig, {username = 'bjorn'})
  end

  self.u, self.v = love.graphics.getDimensions()
end

function Menu:update()
  local page = self.pages[self.page]
	self.creditsAlpha = timer.rot(self.creditsAlpha)
  
  self.hub:update()
  self.loader:update()
  self.tooltip:update()

  self:run('update')
end

function Menu:draw()
  self.background:draw()
  if self.page ~= 'login' then self.nav:draw() end
  self:run('draw')
  if self.invitation then
    love.graphics.setColor(255, 255, 255)
    love.graphics.print('you have an invitation', 10, 10)
  end
  self.loader:draw()
  self.tooltip:draw()
end

function Menu:keypressed(key)
  if key == 'return' and self.invitation then
    self.hub:send('lobbyInvitationResponse', {lobbyToken = self.invitation.lobbyToken, accept = true})
  end

  return self:run('keypressed', key)
end

function Menu:keyreleased(...)
  return self:run('keyreleased', ...)
end

function Menu:mousepressed(...)
  return self:run('mousepressed', ...)
end

function Menu:mousereleased(...)
  self.nav:mousereleased(...)
  return self:run('mousereleased', ...)
end

function Menu:textinput(...)
  return self:run('textinput', ...)
end

function Menu:resize()
  self.u, self.v = love.graphics.getDimensions()
  self:run('resize')
  self.background:resize()
  self.tooltip:resize()
end

function Menu:hubMessage(message, data)
  if message == 'lobbyInvitation' then
    self.invitation = data
  elseif message == 'lobbyInvitationResponse' then
    self:push('lobby', data.gameType, data.users)
    self.invitation = nil
  end

  self:run('hubMessage', message, data)
end

function Menu:run(key, ...)
  if not self.page or not self.pages[self.page] then return end
  local page = self.pages[self.page]
  f.exe(page[key], page, ...)
end

function Menu:push(page, ...)
  self:run('deactivate', page)
  self.page = page
  self:run('activate', ...)
end
