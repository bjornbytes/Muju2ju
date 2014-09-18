Hud = class()

local g = love.graphics
local rich = require 'lib/deps/richtext/richtext'

local normalFont = love.graphics.newFont('media/fonts/inglobal.ttf', 14)
local fancyFont = love.graphics.newFont('media/fonts/inglobal.ttf', 24)
local boldFont = love.graphics.newFont('media/fonts/inglobalb.ttf', 14)
Hud.richOptions = {title = fancyFont, bold = boldFont, normal = normalFont, white = {255, 255, 255}, whoCares = {230, 230, 230}, red = {255, 100, 100}, green = {100, 255, 100}}
Hud.upgradeGeometry = {
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

Hud.upgradeDotGeometry = {
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

function Hud:init()
  self.protectFont = love.graphics.newFont('media/fonts/inglobal.ttf', 64)
	self.cursorImage = g.newImage('media/graphics/cursor.png')
	self.cursorX = g.getWidth() / 2
	self.cursorY = g.getHeight() / 2
	self.prevCursorX = self.cursorX
	self.prevCursorY = self.cursorY
	self.cursorSpeed = 0
	self.upgrading = false
	self.upgradeDotAlpha = {}
	self.lock = g.newImage('media/graphics/lock.png')
	self.upgradeAlpha = 0
	self.upgradesBought = 0
	self.tooltip = nil
	self.tooltipRaw = ''
	self.jujuIconScale = .75
	self.timer = {total = 0, minutes = 0, seconds = 0}
	self.particles = Particles()
	self.selectBg = {media.graphics.selectZuju, media.graphics.selectVuju}
	self.selectFactor = {0, 0}
	self.selectExtra = {0, 0}
	self.selectQuad = {}
	self.selectQuad[1] = g.newQuad(0, 0, self.selectBg[1]:getWidth(), self.selectBg[1]:getHeight(), self.selectBg[1]:getWidth(), self.selectBg[1]:getHeight())
	self.selectQuad[2] = g.newQuad(0, 0, self.selectBg[2]:getWidth(), self.selectBg[2]:getHeight(), self.selectBg[2]:getWidth(), self.selectBg[2]:getHeight())
  self.dead = HudDead()
	self.deadScreen = 1
  self.pause = HudPause()
	self.tutorialIndex = 1
	self.tutorialTimer = 0
	self.tutorialEnabled = true or not love.filesystem.exists('playedBefore')
	self.tutorialImages = {
		[1] = media.graphics.tutorialMove1,
		[2] = media.graphics.tutorialSummon,
		[3] = media.graphics.tutorialMove2,
		[3.5] = media.graphics.tutorialJuju,
		[4] = media.graphics.tutorialShrine,
		[5] = media.graphics.tutorialMinions
	}
	self.tutorialDirty = {}
	self.protectAlpha = 3
	love.filesystem.write('playedBefore', 'achievement unlocked.')
	ctx.view:register(self, 'gui')

  self.upgradePillows = {
    {media.graphics.pipe1, 131, 238, check = function() return ctx.upgrades.zuju.empower.level >= 3 end, alpha = 0},
    {media.graphics.pipe2, 177, 234, check = function() return ctx.upgrades.zuju.fortify.level >= 3 end, alpha = 0},
    {media.graphics.pipe3, 230, 234, check = function() return ctx.upgrades.zuju.fortify.level >= 3 end, alpha = 0},
    {media.graphics.pipe4, 284, 237, check = function() return ctx.upgrades.zuju.burst.level >= 3 end, alpha = 0},
    {media.graphics.pipe5, 491, 238, check = function() return ctx.upgrades.vuju.surge.level >= 3 end, alpha = 0},
    {media.graphics.pipe6, 537, 234, check = function() return ctx.upgrades.vuju.charge.level >= 3 end, alpha = 0},
    {media.graphics.pipe7, 590, 234, check = function() return ctx.upgrades.vuju.charge.level >= 3 end, alpha = 0},
    {media.graphics.pipe8, 644, 237, check = function() return ctx.upgrades.vuju.condemn.level >= 3 end, alpha = 0},
    {media.graphics.pipe9, 205, 452, check = function() return ctx.upgrades.muju.flow.level >= 3 end, alpha = 0},
    {media.graphics.pipe10, 216, 492, check = function() return ctx.upgrades.muju.harvest.level >= 1 end, alpha = 0},
    {media.graphics.pipe11, 394, 437, check = function() return ctx.upgrades.muju.zeal.level >= 3 end, alpha = 0},
    {media.graphics.pipe12, 390, 499, check = function() return ctx.upgrades.muju.absorb.level >= 1 end, alpha = 0},
    {media.graphics.pipe13, 567, 452, check = function() return ctx.upgrades.muju.imbue.level >= 3 end, alpha = 0},
    {media.graphics.pipe14, 559, 493, check = function() return ctx.upgrades.muju.mirror.level >= 1 end, alpha = 0},
  }
end

function Hud:update()
	self.upgradeAlpha = math.lerp(self.upgradeAlpha, self.upgrading and 1 or 0, 12 * tickRate)
	self.protectAlpha = math.max(self.protectAlpha - tickRate, 0)
	self.jujuIconScale = math.lerp(self.jujuIconScale, .75, 12 * tickRate)
	for i = 1, #self.selectFactor do
		self.selectFactor[i] = math.lerp(self.selectFactor[i], ctx.player.selectedMinion == i and 1 or 0, 18 * tickRate)
		self.selectExtra[i] = math.lerp(self.selectExtra[i], 0, 5 * tickRate)
		if ctx.player.minions[i] then
			local y = self.selectBg[i]:getHeight() * (ctx.player.minioncds[i] / ctx.player.minions[i].cooldown)
			self.selectQuad[i]:setViewport(0, y, self.selectBg[i]:getWidth(), self.selectBg[i]:getHeight() - y)
		end
	end

	for i = 1, #self.upgradePillows do
		local pillow = self.upgradePillows[i]
		if pillow.check() then
			pillow.alpha = math.min(pillow.alpha + 2 * tickRate, 1)
		end
	end

	-- Tutorial hooks
	if self.tutorialEnabled and (not self.upgrading) and (not ctx.paused) then
		self.tutorialTimer = timer.rot(self.tutorialTimer)
		if self.tutorialTimer == 0 and tick > 2 / tickRate and not ctx.player.hasMoved and not self.tutorialDirty[1] then
			self.tutorialIndex = 1
			self.tutorialTimer = 2 * math.pi
			self.tutorialDirty[1] = true
		end
		if self.tutorialTimer == 0 and ctx.player.dead and ctx.player.ghost.first and not self.tutorialDirty[2] then
			self.tutorialIndex = 3
			self.tutorialTimer = 2 * math.pi
			self.tutorialDirty[2] = true
		end
		if self.tutorialTimer == 0 and tick > 8 / tickRate and ctx.player.summonedMinions == 0 and not ctx.player.dead and not self.tutorialDirty[3] then
			self.tutorialIndex = 2
			self.tutorialTimer = 2 * math.pi
			self.tutorialDirty[3] = true
		end
		if self.tutorialTimer == 0 and self.upgradesBought == 0 and tick > 35 / tickRate and ctx.player.juju >= 45 and not ctx.player.dead and not self.tutorialDirty[4] then
			self.tutorialIndex = 4
			self.tutorialTimer = 2 * math.pi
			self.tutorialDirty[4] = true
		end
		if self.tutorialTimer == 0 and #ctx.player.minions > 1 and not ctx.player.dead and not self.tutorialDirty[5] then
			self.tutorialIndex = 5
			self.tutorialTimer = 2 * math.pi
			self.tutorialDirty[5] = true
		end

		-- Tutorial unhooks
		local decay = function() while self.tutorialTimer > math.pi / 2 do self.tutorialTimer = self.tutorialTimer - math.pi / 2 end end
		if self.tutorialIndex == 1 and ctx.player.hasMoved then decay() end
		if self.tutorialIndex == 2 and (ctx.player.summonedMinions > 0 or ctx.player.dead) then decay() end
		if self.tutorialIndex == 3 and not ctx.player.dead then decay() end
		if self.tutorialIndex == 4 and self.upgradesBought > 0 then decay() end
		if self.tutorialIndex == 5 and ctx.player.selectedMinion == 2 then decay() end
	end

	-- Update Timer
	self:score()
	
	-- Virtual cursor for upgrades
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

	for key in pairs(self.upgradeDotAlpha) do
		self.upgradeDotAlpha[key] = math.lerp(self.upgradeDotAlpha[key], 1, 5 * tickRate)
		if self.upgradeDotAlpha[key] > .999 then
			self.upgradeDotAlpha[key] = nil
		end
	end

	if self.upgradeAlpha > .001 then
		local mx, my = love.mouse.getPosition()
		local hover = false

		if ctx.player.gamepad then
			mx, my = self.cursorX, self.cursorY
		end

		for who in pairs(self.upgradeGeometry) do
			for what, geometry in pairs(self.upgradeGeometry[who]) do
				if math.distance(mx, my, geometry[1], geometry[2]) < geometry[3] then
					local str = ctx.upgrades.makeTooltip(who, what)
					self.tooltip = rich.new(table.merge({str, 300}, self.richOptions))
					self.tooltipRaw = str:gsub('{%a+}', '')
					hover = true
					break
				end
			end
		end

		if math.distance(mx, my, 560, 140) < 38 then
			if #ctx.player.minions < 2 then
				local color = ctx.player.juju >= 80 and '{green}' or '{red}'
				local str = '{white}{title}Vuju{normal}\n{whoCares}Casts chain lightning and hexes enemies.\n\n' .. color .. '{bold}80 juju'
				self.tooltip = rich.new(table.merge({str, 300}, self.richOptions))
				self.tooltipRaw = str:gsub('{%a+}', '')
				hover = true
			else
				local str = '{white}{title}Vuju{normal}\nUnlocked!'
				self.tooltip = rich.new(table.merge({str, 300}, self.richOptions))
				self.tooltipRaw = str:gsub('{%a+}', '')
				hover = true
			end
		end

		if math.distance(mx, my, 245, 140) < 38 then
			local str = '{white}{title}Zuju{normal}\nUnlocked!'
			self.tooltip = rich.new(table.merge({str, 300}, self.richOptions))
			self.tooltipRaw = str:gsub('{%a+}', '')
			hover = true
		end

		if not hover then self.tooltip = nil end
	end

	self.particles:update()

	if ctx.ded then love.keyboard.setKeyRepeat(true) end
end

function Hud:health(x, y, percent, color, width, thickness)
	local g = love.graphics
	thickness = thickness or 2

	g.setColor(0, 0, 0, 160)
	g.rectangle('fill', x, y, width + 1, thickness + 1)
	g.setColor(color)
	g.rectangle('fill', x, y, percent * width, thickness)
end

function Hud:stackingTable(stackingTable, x, range, delta)
	local limit = x + range
	for i = x - range, limit, 1 do
		if not stackingTable[i] then
			stackingTable[i] = 1 
		else 
			stackingTable[i] = stackingTable[i] + delta
		end
	end
end

function Hud:score()
	if not self.upgrading and not ctx.paused and not ctx.ded then
		self.timer.total = self.timer.total + 1
	end
end

function Hud:gui()
	local w, h = love.graphics.getDimensions()

	if not ctx.ded then

		-- Juju icon
		g.setFont(boldFont)
		if not self.upgrading then
			g.setColor(255, 255, 255, 255 * (1 - self.upgradeAlpha))
			g.draw(media.graphics.juju, 52, 55, 0, self.jujuIconScale, self.jujuIconScale, media.graphics.juju:getWidth() / 2, media.graphics.juju:getHeight() / 2)
			g.setColor(0, 0, 0)
			g.printf(math.floor(ctx.player.juju), 16, 18 + media.graphics.juju:getHeight() * .375 - (g.getFont():getHeight() / 2), media.graphics.juju:getWidth() * .75, 'center')
			g.setColor(255, 255, 255)
		end

		-- Timer
		local total = self.timer.total * tickRate
		self.timer.seconds = math.floor(total % 60)
		self.timer.minutes = math.floor(total / 60)
		if self.timer.minutes < 10 then
			self.timer.minutes = '0' .. self.timer.minutes
		end
		if self.timer.seconds < 10 then
			self.timer.seconds = '0' .. self.timer.seconds
		end
		local str = self.timer.minutes .. ':' .. self.timer.seconds

		g.setColor(255, 255, 255)
		g.print(str, w - 25 - g.getFont():getWidth(str), 25)

		-- Minion indicator
		local yy = 135
		for i = 1, #ctx.player.minions do
			local bg = self.selectBg[i]
			local scale = .75 + (.15 * self.selectFactor[i]) + (.1 * self.selectExtra[i])
			local xx = 48 - 10 * (1 - self.selectFactor[i])
			local f, cost = g.getFont(), tostring(ctx.player.minions[i]:getCost())
			local tx, ty = xx - f:getWidth(cost) / 2 - (bg:getWidth() * .75 / 2) + 4, yy - f:getHeight() / 2 - (bg:getHeight() * .75 / 2) + 4
			local alpha = .65 + self.selectFactor[i] * .35

			-- Backdrop
			g.setColor(255, 255, 255, 80 * alpha)
			g.draw(bg, xx, yy, 0, scale, scale, bg:getWidth() / 2, bg:getHeight() / 2)

			-- Cooldown
			local _, qy = self.selectQuad[i]:getViewport()
			g.setColor(255, 255, 255, (150 + (100 * (ctx.player.minioncds[i] == 0 and 1 or 0))) * alpha)
			g.draw(bg, self.selectQuad[i], xx, yy + qy * scale, 0, scale, scale, bg:getWidth() / 2, bg:getHeight() / 2)

			-- Juice
			g.setBlendMode('additive')
			g.setColor(255, 255, 255, 60 * self.selectExtra[i])
			g.draw(bg, xx, yy, 0, scale + .2 * self.selectExtra[i], scale + .2 * self.selectExtra[i], bg:getWidth() / 2, bg:getHeight() / 2)
			g.setBlendMode('alpha')

			-- Cost
			g.setColor(0, 0, 0, 200 + 55 * self.selectFactor[i])
			g.print(cost, tx + 1, ty + 1)
			g.setColor(255, 255, 255, 200 + 55 * self.selectFactor[i])
			g.print(cost, tx, ty)
			yy = yy + self.selectBg[i]:getHeight() * 1
		end
		
		-- Health Bars
		local px, py = math.lerp(ctx.player.prevx, ctx.player.x, tickDelta / tickRate), math.lerp(ctx.player.prevy, ctx.player.y, tickDelta / tickRate)
		local green = {50, 230, 50}
		local red = {255, 0, 0}
		local purple = {200, 80, 255}

		self:health(px - 40, py - 15, ctx.player.healthDisplay / ctx.player.maxHealth, purple, 80, 3)
		self:health(ctx.shrine.x - 60, ctx.shrine.y - 65, ctx.shrine.healthDisplay / ctx.shrine.maxHealth, green, 120, 4)

		local stackingTable = {}
		table.each(ctx.enemies.enemies, function(enemy)
			local location = math.floor(enemy.x)
			self:stackingTable(stackingTable, location, enemy.width * 2, .5)
			self:health(enemy.x - 25, h - ctx.environment.groundHeight - enemy.height - 15 - 15 * stackingTable[location], enemy.healthDisplay / enemy.maxHealth, red, 50, 2)
		end)

		stackingTable = {}
		table.each(ctx.minions.minions, function(minion)
			local location = math.floor(minion.x)
			self:stackingTable(stackingTable, location, minion.width * 2, .5)
			self:health(minion.x - 25, h - ctx.environment.groundHeight - minion.height - 15 * stackingTable[location], minion.healthDisplay / minion.maxHealth, green, 50, 2)
		end)

		-- Tutorial
		if self.tutorialEnabled and self.tutorialTimer > 0 then
			g.setColor(255, 255, 255, 255 * math.abs(math.sin(self.tutorialTimer)))
			local x, y
			local ox, oy = 0, 0
			local scale
			local img = self.tutorialImages[self.tutorialIndex]
			if self.tutorialIndex == 1 then
				x, y = math.lerp(ctx.player.prevx, ctx.player.x, tickDelta / tickRate), math.lerp(ctx.player.prevy, ctx.player.y, tickDelta / tickRate) - 50
				ox, oy = img:getWidth() / 2, img:getHeight() / 2
				scale = .4
			elseif self.tutorialIndex == 2 then
				x, y = 48 + self.selectBg[1]:getWidth() * .45 + 16, 135 + self.selectBg[1]:getHeight() * .45 / 2 - 8
				ox, oy = 1, 56
				scale = .4
			elseif self.tutorialIndex == 3 then
				if not ctx.player.ghost then x, y = -1000, -1000
				else
					x, y = math.lerp(ctx.player.ghost.prevx, ctx.player.ghost.x, tickDelta / tickRate), math.lerp(ctx.player.ghost.prevy, ctx.player.ghost.y, tickDelta / tickRate) - 80
					ox, oy = img:getWidth() / 2, img:getHeight() / 2
					scale = .3
				end

				g.draw(self.tutorialImages[3.5], 100, 90, 0, .45, .45)
			elseif self.tutorialIndex == 4 then
				ox, oy = 440, 400
				x, y = ctx.shrine.x, ctx.shrine.y - 85
				scale = .4
			elseif self.tutorialIndex == 5 then
				x, y = 48 + self.selectBg[1]:getWidth() * .4 + 16, 135
				scale = .4
			end
			g.draw(img, x, y, 0, scale, scale, ox, oy)
		end

		-- Protect message
		if self.protectAlpha > .1 then
			g.setFont(self.protectFont)
			g.setColor(0, 0, 0, 150 * math.min(self.protectAlpha, 1))
			g.printf('Protect Your Shrine!', 2, h * .25 + 2, w, 'center')
			g.setColor(253, 238, 65, 255 * math.min(self.protectAlpha, 1))
			g.printf('Protect Your Shrine!', 0, h * .25, w, 'center')
			g.setFont(boldFont)
		end

		-- Pause Menu
    self.pause:draw()
	end

	-- Upgrade screen
	if self.upgradeAlpha > .001 and not ctx.ded then
		local mx, my = love.mouse.getPosition()
		local w2, h2 = w / 2, h / 2
		
    local upgradeMenu = media.graphics.upgradeMenu
		g.setColor(255, 255, 255, self.upgradeAlpha * 250)
		g.draw(upgradeMenu, 400, 300, 0, .875, .875, upgradeMenu:getWidth() / 2, upgradeMenu:getHeight() / 2)

		for i = 1, #self.upgradePillows do
			local pillow = self.upgradePillows[i]
			if pillow.check() then
				g.setColor(255, 255, 255, 255 * pillow.alpha * self.upgradeAlpha)
				local img, x, y = unpack(pillow)
				x = ((x - 400) * .875) + 400
				y = ((y - 313) * .875) + 300
				g.draw(img, x, y, 0, .875, .875)
			end
		end

    local circles = media.graphics.upgradeMenuCircles
		g.setColor(255, 255, 255, self.upgradeAlpha * 250)
		g.draw(circles, 400, 300, 0, 1, 1, circles:getWidth() / 2, circles:getHeight() / 2)

		g.setColor(0, 0, 0, self.upgradeAlpha * 250)
		local str = tostring(math.floor(ctx.player.juju))
		g.print(str, w2 - g.getFont():getWidth(str) / 2, 65)

		for who in pairs(self.upgradeDotGeometry) do
			for what in pairs(self.upgradeDotGeometry[who]) do
				for i = 1, ctx.upgrades[who][what].level do
					local info = self.upgradeDotGeometry[who][what][i]
					if info then
						local x, y, scale = unpack(info)
						local dot = media.graphics.levelIcon
						local w, h = dot:getDimensions()
						g.setColor(255, 255, 255, (self.upgradeDotAlpha[who .. what .. i] or 1) * 255 * self.upgradeAlpha)
						g.draw(dot, x + .5, y + .5, 0, scale / w, scale / h, w / 2, h / 2)
					end
				end
			end
		end

		g.setColor(255, 255, 255, 220 * self.upgradeAlpha)
		local lw, lh = self.lock:getDimensions()
		for who in pairs(self.upgradeGeometry) do
			for what, geometry in pairs(self.upgradeGeometry[who]) do
				if not ctx.upgrades.checkPrerequisites(who, what) then
					local scale = math.min(geometry[3] / lw, geometry[3] / lh) + .1
					g.draw(self.lock, geometry[1], geometry[2], 0, scale, scale, lw / 2, lh / 2)
				end
			end
		end

		if self.tooltip then
			local mx, my = love.mouse.getPosition()
			if ctx.player.gamepad then
				mx, my = math.lerp(self.prevCursorX, self.cursorX, tickDelta / tickRate), math.lerp(self.prevCursorY, self.cursorY, tickDelta / tickRate)
				mx, my = math.round(mx), math.round(my)
			end
			local textWidth, lines = normalFont:getWrap(self.tooltipRaw, 300)
			local xx = math.min(mx + 8, love.graphics.getWidth() - textWidth - 24)
			local yy = math.min(my + 8, love.graphics.getHeight() - (lines * g.getFont():getHeight() + 16 + 7))
			g.setColor(30, 50, 70, 240)
			g.rectangle('fill', xx, yy, textWidth + 14, lines * g.getFont():getHeight() + 16 + 5)
			g.setColor(10, 30, 50, 255)
			g.rectangle('line', xx + .5, yy + .5, textWidth + 14, lines * g.getFont():getHeight() + 16 + 5)
			self.tooltip:draw(xx + 8, yy + 4)
		end
	end

	-- Death Screen
	if ctx.ded then
    self.dead:draw()
  end

	if self.upgrading or ctx.paused or ctx.ded then
		if ctx.player.gamepad then
			local xx, yy = math.lerp(self.prevCursorX, self.cursorX, tickDelta / tickRate), math.lerp(self.prevCursorY, self.cursorY, tickDelta / tickRate)
			g.setColor(255, 255, 255)
			g.draw(self.cursorImage, xx, yy)
		end
	end
end

function Hud:keypressed(key)
	if (key == 'tab' or key == 'e') and math.abs(ctx.player.x - ctx.shrine.x) < ctx.player.width and not ctx.ded then
		self.upgrading = not self.upgrading
		return true
	end

	if key == 'escape' and self.upgrading and not ctx.ded then
		self.upgrading = false
	end

	if ctx.ded and self.deadAlpha > .9 then
		if key == 'backspace' then
			self.deadName = self.deadName:sub(1, -2)
		elseif key == 'return' then
			if self.deadScreen == 1 then self:sendScore() end
		end
		
		if key == 'escape' then
			Context:remove(ctx)
			Context:add(Menu)
		end
	end
end

function Hud:keyreleased(key)
	--
end

function Hud:textinput(char)
  self.dead:textinput(char)
end

function Hud:gamepadpressed(gamepad, button)
	if gamepad == ctx.player.gamepad and not ctx.ded then
    if button == 'b' and self.upgrading then
      self.upgrading = false
      self.cursorX = g.getWidth() / 2
      self.cursorY = g.getHeight() / 2
      self.prevCursorX = self.cursorX
      self.prevCursorY = self.cursorY
      return true
    end

		if (button == 'x' or button == 'y') and math.abs(ctx.player.x - ctx.shrine.x) < ctx.player.width then
			self.upgrading = not self.upgrading
			self.cursorX = g.getWidth() / 2
			self.cursorY = g.getHeight() / 2
			self.prevCursorX = self.cursorX
			self.prevCursorY = self.cursorY
			return true
		end

		if button == 'a' and (self.upgrading or ctx.paused or ctx.ded) then
			self:mousepressed(self.cursorX, self.cursorY, 'l')
			self:mousereleased(self.cursorX, self.cursorY, 'l')
		end
	end
end

function Hud:mousepressed(x, y, b)
	if not self.upgrading or ctx.ded then return end
	if math.inside(x, y, 670, 502, 48, 48) then
		self.upgrading = false
	end
end

function Hud:mousereleased(x, y, b)
	if self.upgrading and b == 'l' and not ctx.ded then
		for who in pairs(self.upgradeGeometry) do
			for what, geometry in pairs(self.upgradeGeometry[who]) do
				if math.distance(x, y, geometry[1], geometry[2]) < geometry[3] then
					local upgrade = ctx.upgrades[who][what]
					local nextLevel = upgrade.level + 1
					local cost = upgrade.costs[nextLevel]

					if ctx.upgrades.canBuy(who, what) and ctx.player:spend(cost) then
						ctx.upgrades[who][what].level = nextLevel
						ctx.sound:play({sound = 'menuClick'})
						for i = 1, 80 do
							self.particles:add(UpgradeParticle, {x = x, y = y})
						end
						self.upgradeDotAlpha[who .. what .. nextLevel] = 0
					end
				end
			end
		end

		if #ctx.player.minions < 2 and math.distance(x, y, 560, 140) < 38 and ctx.player:spend(80) then
			table.insert(ctx.player.minions, Vuju)
			table.insert(ctx.player.minioncds, 0)
			for i = 1, 100 do
				self.particles:add(UpgradeParticle, {x = x, y = y})
			end
			self.upgradesBought = self.upgradesBought + 1
		end
	end

  self.dead:mousepressed(x, y, b)

	if b == 'l' and ctx.paused then
		local w, h = g.getDimensions()
		if math.inside(x, y, w * .4, h * .4, 155, 60) then
			ctx.paused = not ctx.paused
		elseif math.inside(x, y, w * .4, h * .51, 155, 60) then
			Context:remove(ctx)
			Context:add(Menu)
		end
	end
end

