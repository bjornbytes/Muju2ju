HudTutorial = class()

local g = love.graphics

function HudTutorial:init()
	self.index = 1
	self.timer = 0
	self.enabled = true or not love.filesystem.exists('playedBefore')
	self.dirty = {}
	self.images = {
		[1] = media.graphics.tutorialMove1,
		[2] = media.graphics.tutorialSummon,
		[3] = media.graphics.tutorialMove2,
		[3.5] = media.graphics.tutorialJuju,
		[4] = media.graphics.tutorialShrine,
		[5] = media.graphics.tutorialMinions
	}

	love.filesystem.write('playedBefore', 'achievement unlocked.')
end

function HudTutorial:update()
	if self.enabled and (not ctx.hud.upgrades.active) and (not ctx.paused) then
		self.timer = timer.rot(self.timer)
		if self.timer == 0 and tick > 2 / tickRate and not ctx.player.hasMoved and not self.dirty[1] then
			self.index = 1
			self.timer = 2 * math.pi
			self.dirty[1] = true
		end
		if self.timer == 0 and ctx.player.dead and ctx.player.ghost.first and not self.dirty[2] then
			self.index = 3
			self.timer = 2 * math.pi
			self.dirty[2] = true
		end
		if self.timer == 0 and tick > 8 / tickRate and ctx.player.summonedMinions == 0 and not ctx.player.dead and not self.dirty[3] then
			self.index = 2
			self.timer = 2 * math.pi
			self.dirty[3] = true
		end
		if self.timer == 0 and ctx.hud.upgrades.bought == 0 and tick > 35 / tickRate and ctx.player.juju >= 45 and not ctx.player.dead and not self.dirty[4] then
			self.index = 4
			self.timer = 2 * math.pi
			self.dirty[4] = true
		end
		if self.timer == 0 and #ctx.player.minions > 1 and not ctx.player.dead and not self.dirty[5] then
			self.index = 5
			self.timer = 2 * math.pi
			self.dirty[5] = true
		end

		-- Tutorial unhooks
		local decay = function() while self.timer > math.pi / 2 do self.timer = self.timer - math.pi / 2 end end
		if self.index == 1 and ctx.player.hasMoved then decay() end
		if self.index == 2 and (ctx.player.summonedMinions > 0 or ctx.player.dead) then decay() end
		if self.index == 3 and not ctx.player.dead then decay() end
		if self.index == 4 and self.upgrades.bought > 0 then decay() end
		if self.index == 5 and ctx.player.selectedMinion == 2 then decay() end
	end
end

function HudTutorial:draw()
  if ctx.ded then return end
  if self.enabled and self.timer > 0 then
    g.setColor(255, 255, 255, 255 * math.abs(math.sin(self.timer)))
    local x, y
    local ox, oy = 0, 0
    local scale
    local img = self.images[self.index]
    if self.index == 1 then
      x, y = math.lerp(ctx.player.prevx, ctx.player.x, tickDelta / tickRate), math.lerp(ctx.player.prevy, ctx.player.y, tickDelta / tickRate) - 50
      ox, oy = img:getWidth() / 2, img:getHeight() / 2
      scale = .4
    elseif self.index == 2 then
      x, y = 48 + self.selectBg[1]:getWidth() * .45 + 16, 135 + self.selectBg[1]:getHeight() * .45 / 2 - 8
      ox, oy = 1, 56
      scale = .4
    elseif self.index == 3 then
      if not ctx.player.ghost then x, y = -1000, -1000
      else
        x, y = math.lerp(ctx.player.ghost.prevx, ctx.player.ghost.x, tickDelta / tickRate), math.lerp(ctx.player.ghost.prevy, ctx.player.ghost.y, tickDelta / tickRate) - 80
        ox, oy = img:getWidth() / 2, img:getHeight() / 2
        scale = .3
      end

      g.draw(self.images[3.5], 100, 90, 0, .45, .45)
    elseif self.index == 4 then
      ox, oy = 440, 400
      x, y = ctx.shrine.x, ctx.shrine.y - 85
      scale = .4
    elseif self.index == 5 then
      x, y = 48 + self.selectBg[1]:getWidth() * .4 + 16, 135
      scale = .4
    end
    g.draw(img, x, y, 0, scale, scale, ox, oy)
  end
end

