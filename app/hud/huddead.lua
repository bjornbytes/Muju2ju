HudDead = class()

local g = love.graphics

function HudDead:init()
  self.alpha = 0
  self.bigFont = love.graphics.newFont('media/fonts/inglobal.ttf', 64)
  self.mediumFont = love.graphics.newFont('media/fonts/inglobal.ttf', 44)
  self.smallFont = love.graphics.newFont('media/fonts/inglobal.ttf', 24)

  self.name = ''
  self.screen = 1
end

function HudDead:update()
  self.alpha = math.lerp(self.alpha, ctx.ded and 1 or 0, 12 * tickRate)
end

function HudDead:draw()
  local u, v = ctx.hud.u, ctx.hud.v

  if self.screen == 1 then
    local ok = media.graphics.deathOk
    local nameFrame = media.graphics.deathBox

    g.setColor(244, 188, 80, 255 * self.alpha)
    g.setFont(self.bigFont)
    local str = 'YOUR SHRINE HAS BEEN DESTROYED!'
    g.printf(str, 50, 30, 700, 'center')

    g.setColor(253, 238, 65, 255 * self.alpha)
    g.setFont(self.mediumFont)
    str = 'Your Score:'
    g.printf(str, 0, h * .325, w, 'center')

    g.setColor(240, 240, 240, 255 * self.alpha)
    str = tostring(math.floor(ctx.hud.timer.total * tickRate))
    g.printf(str, 0, h * .41, w, 'center')
    
    g.setColor(253, 238, 65, 255 * self.alpha)
    str = 'Your Name:'
    g.printf(str, 0, h * .51, w, 'center')

    g.setColor(255, 255, 255, 255 * self.alpha)
    g.draw(nameFrame, w / 2 - nameFrame:getWidth() / 2, h * .584)
    
    g.setColor(240, 240, 240, 255 * self.alpha)
    local font = g.getFont()
    local scale = 1
    while font:getWidth(self.name) * scale > nameFrame:getWidth() - 24 do scale = scale - .05 end
    
    local xx = w / 2 - font:getWidth(self.name) * scale / 2
    local yy = h * .584 + (nameFrame:getHeight() / 2) - font:getHeight() * scale / 2
    g.print(self.deadName, xx, yy, 0, scale, scale)

    local cursorx = xx + font:getWidth(self.name) * scale + 1
    g.line(cursorx, yy, cursorx, yy + font:getHeight() * scale)

    g.setColor(255, 255, 255, 255 * self.alpha)
    g.draw(ok, w / 2 - ok:getWidth() / 2, h * .825)
  else
    local replay = media.graphics.deathReplay
    local quit = media.graphics.deathQuit

    if self.highscores then
      g.setColor(253, 238, 65, 255 * self.alpha)
      g.setFont(self.mediumFont)
      g.printf('Highscores', 0, h * .05, w, 'center')

      g.setFont(self.smallFont)
      g.setColor(255, 255, 255, 255 * self.alpha)
      local yy = h * .2

      for _, entry in ipairs(self.highscores) do
        g.print(entry.who, w * .3, yy)
        g.printf(entry.what, 0, yy, w * .7, 'right')
        yy = yy + g.getFont():getHeight() + 4
      end
      
      g.draw(replay, w * .4, h * .825, 0, 1, 1, replay:getWidth() / 2)
      g.draw(quit, w * .6, h * .825, 0, 1, 1, quit:getWidth() / 2)
    else
      g.setColor(253, 238, 65, 255 * self.alpha)
      g.setFont(self.mediumFont)
      g.printf('Unable to load highscores :[', 0, h * .4, w, 'center')

      g.draw(replay, w * .4, h * .825, 0, 1, 1, replay:getWidth() / 2)
      g.draw(quit, w * .6, h * .825, 0, 1, 1, quit:getWidth() / 2)
    end
  end
end

function HudDead:mousepressed(x, y, b)
	if b == 'l' and ctx.ded then
		if self.screen == 1 then
			local img = media.graphics.deathOk
			local w2 = g.getWidth() / 2
			if math.inside(x, y, w2 - img:getWidth() / 2, g.getHeight() * .825, img:getDimensions()) then
				self:sendScore()
			end
		elseif self.screen == 2 then
			local img1 = media.graphics.deathReplay
			local img2 = media.graphics.deathQuit
			local w = g.getWidth()
			local h = g.getHeight()
			if math.inside(x, y, w * .4 - img1:getWidth() / 2, h * .825, img1:getDimensions()) then
				Context:remove(ctx)
				Context:add(Game)
			elseif math.inside(x, y, w * .6 - img2:getWidth() / 2, h * .825, img2:getDimensions()) then
				Context:remove(ctx)
				Context:add(Menu)
			end
		end
	end
end

function HudDead:textinput(char)
	if ctx.ded then
		if #self.name < 16 and char:match('%w') then
			self.name = self.name .. char
		end
	end
end

function Hud:sendScore()
	self.highscores = nil

	if #self.name > 0 then
		local seconds = math.floor(ctx.hud.timer.total * tickRate)
		local http = require('socket.http')
		http.TIMEOUT = 5
		local response = http.request('http://plasticsarcastic.com/mujuJuju/score.php?name=' .. self.name .. '&score=' .. seconds)
		if response then
			self.highscores = {}
			for who, what, when in response:gmatch('(%w+)%,(%w+)%,(%w+)') do
				table.insert(self.highscores, {who = who, what = what, when = when})
			end
		end
	end

	self.screen = 2
end
