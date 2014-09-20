HudUpgrades = class()

local g = love.graphics
local rich = require 'lib/deps/richtext/richtext'

function HudUpgrades:init()
  self.active = false
  self.alpha = 0
	self.dotAlpha = {}
  self.bought = 0

	self.cursorX = g.getWidth() / 2
	self.cursorY = g.getHeight() / 2
	self.prevCursorX = self.cursorX
	self.prevCursorY = self.cursorY
	self.cursorSpeed = 0

	self.tooltip = nil
	self.tooltipRaw = ''
  self.tooltipOptions = {
    title = g.newFont('media/fonts/inglobal.ttf', 24),
    bold = g.newFont('media/fonts/inglobalb.ttf', 14),
    normal = g.newFont('media/fonts/inglobal.ttf', 14),
    white = {255, 255, 255}, whoCares = {230, 230, 230}, red = {255, 100, 100}, green = {100, 255, 100}
  }
end

function HudUpgrades:update()
	self.alpha = math.lerp(self.alpha, self.active and 1 or 0, 12 * tickRate)

	for i = 1, #self.pillows do
		local pillow = self.pillows[i]
		if pillow.check() then
			pillow.alpha = math.min(pillow.alpha + 2 * tickRate, 1)
		end
	end

	-- Virtual cursor
	if ctx.player.gamepad then
		local vx, vy = 0, 0
		local xx, yy = ctx.player.gamepad:getGamepadAxis('leftx'), ctx.player.gamepad:getGamepadAxis('lefty')
		local cursorSpeed = 500
		local len = (xx * xx + yy * yy) ^ .5
		self.prevCursorX = self.cursorX
		self.prevCursorY = self.cursorY
		self.cursorSpeed = math.lerp(self.cursorSpeed, len > .2 and cursorSpeed or 0, 18 * tickRate)
		len = len ^ 4
		vx = xx / len
		vy = yy / len
		vx = math.clamp(vx, -1, 1)
		vy = math.clamp(vy, -1, 1)
		vx = vx * self.cursorSpeed * len
		vy = vy * self.cursorSpeed * len
		self.cursorX = self.cursorX + vx * tickRate
		self.cursorY = self.cursorY + vy * tickRate
	end

	for key in pairs(self.dotAlpha) do
		self.dotAlpha[key] = math.lerp(self.dotAlpha[key], 1, 5 * tickRate)
		if self.dotAlpha[key] > .999 then
			self.dotAlpha[key] = nil
		end
	end

	if self.active then
		local mx, my = love.mouse.getPosition()
		local hover = false

		if ctx.player.gamepad then
			mx, my = self.cursorX, self.cursorY
		end

		for who in pairs(self.geometry) do
			for what, geometry in pairs(self.geometry[who]) do
				if math.distance(mx, my, geometry[1], geometry[2]) < geometry[3] then
					local str = ctx.upgrades:makeTooltip(who, what)
					self.tooltip = rich.new(table.merge({str, 300}, self.tooltipOptions))
					self.tooltipRaw = str:gsub('{%a+}', '')
					hover = true
					break
				end
			end
		end

    -- TODO auxiliary tooltips
		if math.distance(mx, my, 560, 140) < 38 then
			if #ctx.player.minions < 2 then
				local color = ctx.player.juju >= 80 and '{green}' or '{red}'
				local str = '{white}{title}Vuju{normal}\n{whoCares}Casts chain lightning and hexes enemies.\n\n' .. color .. '{bold}80 juju'
				self.tooltip = rich.new(table.merge({str, 300}, self.tooltipOptions))
				self.tooltipRaw = str:gsub('{%a+}', '')
				hover = true
			else
				local str = '{white}{title}Vuju{normal}\nUnlocked!'
				self.tooltip = rich.new(table.merge({str, 300}, self.tooltipOptions))
				self.tooltipRaw = str:gsub('{%a+}', '')
				hover = true
			end
		end

    -- TODO auxiliary tooltips
		if math.distance(mx, my, 245, 140) < 38 then
			local str = '{white}{title}Zuju{normal}\nUnlocked!'
			self.tooltip = rich.new(table.merge({str, 300}, self.tooltipOptions))
			self.tooltipRaw = str:gsub('{%a+}', '')
			hover = true
		end

		if not hover then self.tooltip = nil end
	end
end

function HudUpgrades:draw()
  if ctx.ded then return end

  local u, v = ctx.hud.u, ctx.hud.v

	if self.alpha > .001 then
		local mx, my = love.mouse.getPosition()
		
    local upgradeMenu = data.media.graphics.upgradeMenu
		g.setColor(255, 255, 255, self.alpha * 250)
		g.draw(upgradeMenu, u * .5, v * .5, 0, .875, .875, upgradeMenu:getWidth() / 2, upgradeMenu:getHeight() / 2)

		for i = 1, #self.pillows do
			local pillow = self.pillows[i]
			if pillow.check() then
				g.setColor(255, 255, 255, 255 * pillow.alpha * self.alpha)
        local img = data.media.graphics['pillow' .. i]
				local x, y = unpack(pillow)
				x = ((x - 400) * .875) + 400
				y = ((y - 313) * .875) + 300
				g.draw(img, x, y, 0, .875, .875)
			end
		end

    local circles = data.media.graphics.upgradeMenuCircles
		g.setColor(255, 255, 255, self.alpha * 250)
		g.draw(circles, u * .5, v * .5, 0, 1, 1, circles:getWidth() / 2, circles:getHeight() / 2)

		g.setColor(0, 0, 0, self.alpha * 250)
		local str = tostring(math.floor(ctx.player.juju))
    g.setFont(ctx.hud.boldFont)
		g.print(str, u * .5 - ctx.hud.boldFont:getWidth(str) / 2, 65)

		for who in pairs(self.dotGeometry) do
			for what in pairs(self.dotGeometry[who]) do
				for i = 1, ctx.upgrades[who][what].level do
					local info = self.dotGeometry[who][what][i]
					if info then
						local x, y, scale = unpack(info)
						local dot = data.media.graphics.levelIcon
						local w, h = dot:getDimensions()
						g.setColor(255, 255, 255, (self.dotAlpha[who .. what .. i] or 1) * 255 * self.alpha)
						g.draw(dot, x + .5, y + .5, 0, scale / w, scale / h, w / 2, h / 2)
					end
				end
			end
		end

		g.setColor(255, 255, 255, 220 * self.alpha)
		local lw, lh = data.media.graphics.lock:getDimensions()
		for who in pairs(self.geometry) do
			for what, geometry in pairs(self.geometry[who]) do
				if not ctx.upgrades:checkPrerequisites(who, what) then
					local scale = math.min(geometry[3] / lw, geometry[3] / lh) + .1
					g.draw(data.media.graphics.lock, geometry[1], geometry[2], 0, scale, scale, lw / 2, lh / 2)
				end
			end
		end

		if self.tooltip then
			if ctx.player.gamepad then
				mx, my = math.lerp(self.prevCursorX, self.cursorX, tickDelta / tickRate), math.lerp(self.prevCursorY, self.cursorY, tickDelta / tickRate)
				mx, my = math.round(mx), math.round(my)
			end
      local font = ctx.hud.normalFont
			local textWidth, lines = font:getWrap(self.tooltipRaw, 300)
			local xx = math.min(mx + 8, u - textWidth - 24)
			local yy = math.min(my + 8, v - (lines * font:getHeight() + 16 + 7))
			g.setColor(30, 50, 70, 240)
			g.rectangle('fill', xx, yy, textWidth + 14, lines * font:getHeight() + 16 + 5)
			g.setColor(10, 30, 50, 255)
			g.rectangle('line', xx + .5, yy + .5, textWidth + 14, lines * font:getHeight() + 16 + 5)
			self.tooltip:draw(xx + 8, yy + 4)
		end
	end

	if self.active and ctx.player.gamepad then
    local xx, yy = math.lerp(self.prevCursorX, self.cursorX, tickDelta / tickRate), math.lerp(self.prevCursorY, self.cursorY, tickDelta / tickRate)
    g.setColor(255, 255, 255)
    g.draw(data.media.graphics.cursor, xx, yy)
	end
end

function HudUpgrades:keypressed(key)
	if (key == 'tab' or key == 'e') and math.abs(ctx.player.x - ctx.shrine.x) < ctx.player.width and not ctx.ded then
		self.active = not self.active
	end

	if key == 'escape' and self.active and not ctx.ded then
		self.active = false
	end
end

function HudUpgrades:mousereleased(x, y, button)
  if ctx.ded then return end

	if self.active and button == 'l' then
		for who in pairs(self.geometry) do
			for what, geometry in pairs(self.geometry[who]) do
				if math.distance(x, y, geometry[1], geometry[2]) < geometry[3] then
					local upgrade = ctx.upgrades[who][what]
					local nextLevel = upgrade.level + 1
					local cost = upgrade.costs[nextLevel]

					if ctx.upgrades:canBuy(who, what) and ctx.player:spend(cost) then
						ctx.upgrades[who][what].level = nextLevel
						ctx.sound:play({sound = 'menuClick'})
						for i = 1, 80 do
							ctx.hud.particles:add('upgrade', {x = x, y = y})
						end
						self.dotAlpha[who .. what .. nextLevel] = 0
					end
				end
			end
		end

		if #ctx.player.minions < 2 and math.distance(x, y, 560, 140) < 38 and ctx.player:spend(80) then
			table.insert(ctx.player.minions, 'vuju')
			table.insert(ctx.player.minioncds, 0)
			for i = 1, 100 do
				ctx.hud.particles:add('upgrade', {x = x, y = y})
			end
			self.bought = self.bought + 1
		end

    if math.inside(x, y, 670, 502, 48, 48) then
      self.active = false
    end
	end
end

function HudUpgrades:gamepadpressed(gamepad, button)
  if ctx.ded then return end

  local u, v = ctx.hud.u, ctx.hud.v

	if gamepad == ctx.player.gamepad then
    if button == 'b' and self.active then
      self.active = false
      self.cursorX = u * .5
      self.cursorY = v * .5
      self.prevCursorX = self.cursorX
      self.prevCursorY = self.cursorY
      return true
    end

		if (button == 'x' or button == 'y') and math.abs(ctx.player.x - ctx.shrine.x) < ctx.player.width then
			self.active = not self.active
			self.cursorX = u * .5
			self.cursorY = v * .5
			self.prevCursorX = self.cursorX
			self.prevCursorY = self.cursorY
			return true
		end

		if button == 'a' and self.active then
			self:mousereleased(self.cursorX, self.cursorY, 'l')
		end
	end
end

HudUpgrades.geometry = {
	zuju = {
		empower = {161, 207, 28},
		fortify = {244, 212, 28},
		burst = {326, 208, 28},
		siphon = {193.5, 281, 32},
		sanctuary = {296, 281, 32}
	},
	vuju = {
		surge = {476, 208, 28},
		charge = {559, 212, 28},
		condemn = {641, 208, 28},
		arc = {508.5, 281, 32},
		soak = {611, 281, 32}
	},
	muju = {
		flow = {260, 406, 24},
		harvest = {218.5, 459.5, 26},
		refresh = {290, 478, 40},
		zeal = {400, 391, 20},
		absorb = {400, 442, 25},
		diffuse = {400, 507.5, 31},
		imbue = {537, 407, 24},
		mirror = {579, 461, 26},
		distort = {508, 478, 40}
	}
}

HudUpgrades.dotGeometry = {
	zuju = {
		empower = {{139, 229, 7}, {149, 235, 7}, {160, 238, 7}, {171, 235, 7}, {181, 229, 7}},
		fortify = {{223, 233, 7}, {233, 239, 7}, {244, 241, 7}, {255, 239, 7}, {265, 233, 7}},
		burst = {{304, 229, 7}, {314, 235, 7}, {325, 238, 7}, {336, 235, 7}, {346, 229, 7}},
		siphon = {{177, 308, 9}, {193, 312, 9}, {209, 308, 9}},
		sanctuary = {{280, 308, 9}, {296, 312, 9}, {312, 308, 9}}
	},
	vuju = {
		surge = {{454, 229, 7}, {464, 235, 7}, {475, 238, 7}, {486, 235, 7}, {496, 229, 7}},
		charge = {{538, 233, 7}, {548, 239, 7}, {559, 241, 7}, {570, 239, 7}, {580, 233, 7}},
		condemn = {{619, 229, 7}, {629, 235, 7}, {640, 238, 7}, {651, 235, 7}, {661, 229, 7}},
		arc = {{492, 308, 9}, {508, 312, 9}, {524, 308, 9}},
		soak = {{595, 308, 9}, {611, 312, 9}, {627, 308, 9}}
	},
	muju = {
		flow = {{241.5, 423.5, 6}, {250.5, 428.5, 6}, {260.5, 431.5, 6}, {270.5, 428.5, 6}, {279.5, 423.5, 6}},
		harvest = {{203.5, 482.5, 8}, {217.5, 485.5, 8}, {231.5, 482.5, 8}},
		refresh = {{289, 514, 13}},
		zeal = {{386.5, 402.5, 4}, {392.5, 406.5, 4}, {399.5, 407.5, 4}, {406.5, 406.5, 4}, {412.5, 402.5, 4}},
		absorb = {{387, 463, 7}, {400, 466, 7}, {413, 463, 7}},
		diffuse = {{400, 535, 11}},
		imbue = {{517.5, 424.5, 6}, {526.5, 429.5, 6}, {536.5, 432.5, 6}, {546.5, 429.5, 6}, {555.5, 424.5, 6}},
		mirror = {{565.5, 483.5, 8}, {578.5, 486.5, 8}, {592.5, 483.5, 8}},
		distort = {{508, 514, 13}}
	}
}

HudUpgrades.pillows = {
  {131, 238, check = function() return ctx.upgrades.zuju.empower.level >= 3 end, alpha = 0},
  {177, 234, check = function() return ctx.upgrades.zuju.fortify.level >= 3 end, alpha = 0},
  {230, 234, check = function() return ctx.upgrades.zuju.fortify.level >= 3 end, alpha = 0},
  {284, 237, check = function() return ctx.upgrades.zuju.burst.level >= 3 end, alpha = 0},
  {491, 238, check = function() return ctx.upgrades.vuju.surge.level >= 3 end, alpha = 0},
  {537, 234, check = function() return ctx.upgrades.vuju.charge.level >= 3 end, alpha = 0},
  {590, 234, check = function() return ctx.upgrades.vuju.charge.level >= 3 end, alpha = 0},
  {644, 237, check = function() return ctx.upgrades.vuju.condemn.level >= 3 end, alpha = 0},
  {205, 452, check = function() return ctx.upgrades.muju.flow.level >= 3 end, alpha = 0},
  {216, 492, check = function() return ctx.upgrades.muju.harvest.level >= 1 end, alpha = 0},
  {394, 437, check = function() return ctx.upgrades.muju.zeal.level >= 3 end, alpha = 0},
  {390, 499, check = function() return ctx.upgrades.muju.absorb.level >= 1 end, alpha = 0},
  {567, 452, check = function() return ctx.upgrades.muju.imbue.level >= 3 end, alpha = 0},
  {559, 493, check = function() return ctx.upgrades.muju.mirror.level >= 1 end, alpha = 0},
}
