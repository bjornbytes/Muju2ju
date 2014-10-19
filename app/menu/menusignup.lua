local http = require('socket.http')

MenuSignup = class()

function MenuSignup:init()
  self.gooey = Gooey(data.gooey.menu.signup)

  self.username = self.gooey:find('username')
  self.password = self.gooey:find('password')
  self.passwordRetype = self.gooey:find('passwordRetype')

  self.gooey:find('signupButton'):on('clicked', f.cur(self.signup, self))
  self.gooey:find('exitButton'):on('clicked', function()
    love.event.quit()
  end)
  self.gooey:find('cancelButton'):on('clicked', function()
    self.username.text = ''
    self.password.text = ''
    self.passwordRetype.text = ''

    ctx.page = 'login'
  end)
end

function MenuSignup:update()
  self.gooey:update()
end

function MenuSignup:draw()
  self.gooey:draw()
end

function MenuSignup:keypressed(key)
  if key == 'tab' then
    if self.gooey.focused == self.username then
      self.gooey:focus(self.password)
    elseif self.gooey.focused == self.password then
      self.gooey:focus(self.passwordRetype)
    elseif self.gooey.focused == self.passwordRetype then
      self.gooey:focus(self.username)
    end
  end
  self.gooey:keypressed(key)
end

function MenuSignup:keyreleased(...) self.gooey:keyreleased(...) end
function MenuSignup:mousepressed(...) self.gooey:mousepressed(...) end
function MenuSignup:mousereleased(...) self.gooey:mousereleased(...) end
function MenuSignup:textinput(...) self.gooey:textinput(...) end

function MenuSignup:signup()
  local username = self.username.text
  local password, passwordRetype = self.password.text, self.passwordRetype.text

  if password == passwordRetype then
    ctx.hub:send('signup', {username = username, password = password})
  else
    print('Passwords did not match.')  
  end
end

function MenuSignup:signedUp(data)
  if not data.error then
    ctx.page = 'main'
    ctx.userState.token = data.token
  else
    print(data.error)
  end
end
