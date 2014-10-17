HudTutorial = class()

local g = love.graphics

function HudTutorial:init()
	self.index = 1
	self.timer = 0
	self.enabled = true or not love.filesystem.exists('playedBefore')
	self.dirty = {}
	self.images = {
		[1] = data.media.graphics.tutorialMove1,
		[2] = data.media.graphics.tutorialSummon,
		[3] = data.media.graphics.tutorialMove2,
		[3.5] = data.media.graphics.tutorialJuju,
		[4] = data.media.graphics.tutorialShrine,
		[5] = data.media.graphics.tutorialMinions
	}

	love.filesystem.write('playedBefore', 'achievement unlocked.')
end

function HudTutorial:update()
  local p = ctx.players:get(ctx.id)
	if self.enabled and (not ctx.hud.upgrades.active) and (not ctx.paused) then
		self.timer = timer.rot(self.timer)
		if self.timer == 0 and tick > 2 / tickRate and not p.hasMoved and not self.dirty[1] then
			self.index = 1
			self.timer = 2 * math.pi
			self.dirty[1] = true
		end
		if self.timer == 0 and p.dead and p.ghost.first and not self.dirty[2] then
			self.index = 3
			self.timer = 2 * math.pi
			self.dirty[2] = true
		end
		if self.timer == 0 and tick > 8 / tickRate and p.summonedMinions == 0 and not p.dead and not self.dirty[3] then
			self.index = 2
			self.timer = 2 * math.pi
			self.dirty[3] = true
		end
		if self.timer == 0 and ctx.hud.upgrades.bought == 0 and tick > 35 / tickRate and p.juju >= 45 and not p.dead and not self.dirty[4] then
			self.index = 4
			self.timer = 2 * math.pi
			self.dirty[4] = true
		end
		if self.timer == 0 and #p.minions > 1 and not p.dead and not self.dirty[5] then
			self.index = 5
			self.timer = 2 * math.pi
			self.dirty[5] = true
		end

		-- Tutorial unhooks
		local decay = function() while self.timer > math.pi / 2 do self.timer = self.timer - math.pi / 2 end end
		if self.index == 1 and p.hasMoved then decay() end
		if self.index == 2 and (p.summonedMinions > 0 or p.dead) then decay() end
		if self.index == 3 and not p.dead then decay() end
		if self.index == 4 and ctx.hud.upgrades.bought > 0 then decay() end
		if self.index == 5 and p.selectedMinion == 2 then decay() end
	end
end

function HudTutorial:draw()
  if true or ctx.net.state == 'ending' then return end
  local p = ctx.players:get(ctx.id)
  if self.enabled and self.timer > 0 then
    g.setColor(255, 255, 255, 255 * math.abs(math.sin(self.timer)))
    local x, y
    local ox, oy = 0, 0
    local scale
    local img = self.images[self.index]
    if self.index == 1 then
      x, y = math.lerp(p.prev.x, p.x, tickDelta / tickRate), math.lerp(p.prev.y, p.y, tickDelta / tickRate) - 50
      x, y = ctx.view:screenPoint(x, y)
      ox, oy = img:getWidth() / 2, img:getHeight() / 2
      scale = .4
    elseif self.index == 2 then
      x, y = 48 + ctx.hud.minions.bg[1]:getWidth() * .45 + 16, 135 + ctx.hud.minions.bg[1]:getHeight() * .45 / 2 - 8
      ox, oy = 1, 56
      scale = .4
    elseif self.index == 3 then
      if not p.ghost then x, y = -1000, -1000
      else
        x, y = math.lerp(p.ghostx, p.ghost.x, tickDelta / tickRate), math.lerp(p.ghost.prevy, p.ghost.y, tickDelta / tickRate) - 80
        x, y = ctx.view:screenPoint(x, y)
        ox, oy = img:getWidth() / 2, img:getHeight() / 2
        scale = .3
      end

      g.draw(self.images[3.5], 100, 90, 0, .45, .45)
    elseif self.index == 4 then
      ox, oy = 440, 400
      x, y = 0, 0 --ctx.shrine.x, ctx.shrine.y - 85
      x, y = ctx.view:screenPoint(x, y)
      scale = .4
    elseif self.index == 5 then
      x, y = 48 + ctx.hud.minions.bg[1]:getWidth() * .4 + 16, 125
      scale = .4
    end
    g.draw(img, x, y, 0, scale, scale, ox, oy)
  end
end

