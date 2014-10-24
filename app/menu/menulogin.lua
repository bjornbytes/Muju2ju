local http = require('socket.http')

MenuLogin = class()

function MenuLogin:init()
  self.gooey = Gooey(data.gooey.menu.login)

  self.username = self.gooey:find('username')
  self.password = self.gooey:find('password')

  self.gooey:find('loginButton'):on('clicked', f.cur(self.authenticate, self))

	self.gooey:find('exitButton'):on('clicked', function() 
		love.event.quit()
	end)

  self.gooey:find('signupButton'):on('clicked', function()
    ctx.page = 'signup'
  end)

  self.username:on('keypressed', function(data)
    if data.key == 'tab' then self.gooey:focus(self.password) end
  end)

  self.password:on('keypressed', function(data)
    if love.keyboard.isDown('lshift') and data.key == 'tab' then self.gooey:focus(self.username)
    elseif data.key == 'return' then
      self:authenticate()
    end
  end)

  --[[self.username.text = 'bjorn'
  self.password.text = 'asdf'
  self:authenticate()]]
end

function MenuLogin:update()
  self.gooey:update()
end

function MenuLogin:draw()
  self.gooey:draw()
end

function MenuLogin:keypressed(key)
  if key == 'tab' then
    if self.gooey.focused == self.username then
      self.gooey:focus(self.password)
    elseif self.gooey.focused == self.password then
      self.gooey:focus(self.username)
    end
  end

  self.gooey:keypressed(key)
end

function MenuLogin:keyreleased(...) self.gooey:keyreleased(...) end
function MenuLogin:mousepressed(...) self.gooey:mousepressed(...) end
function MenuLogin:mousereleased(...) self.gooey:mousereleased(...) end
function MenuLogin:textinput(...) self.gooey:textinput(...) end

function MenuLogin:authenticate()
  local username, password = self.username.text, self.password.text
  ctx.hub:send('login', {username = username, password = password})

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
