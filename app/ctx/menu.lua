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

  self.pages = {
    signup = MenuSignup(),
    login = MenuLogin(),
    main = MenuMain(),
    lobby = MenuLobby()
  }

  self.page = self.user.token and 'main' or 'login'

  if table.has(arg, 'test') then
    Context:remove(self)
    Context:add(Game)
  end

  self.u, self.v = love.graphics.getDimensions()
end

function Menu:update()
  local page = self.pages[self.page]
	self.creditsAlpha = timer.rot(self.creditsAlpha)
  
  self.hub:update()

  self:run('update')
end

function Menu:draw()
  self:run('draw')
  self.nav:draw()
end

function Menu:keypressed(...)
  return self:run('keypressed', ...)
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
end

function Menu:run(key, ...)
  local page = self.pages[self.page]
  f.exe(page[key], page, ...)
end

function Menu:push(page, ...)
  self:run('deactivate', page)
  self.page = page
  self:run('activate', ...)
end
