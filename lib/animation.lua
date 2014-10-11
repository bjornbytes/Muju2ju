Animation = class()

Animation.offsetx = 0
Animation.offsety = 0

function Animation:init(owner, vars)
  local name = self.code
  if name == 'zuju' then name = 'vuju' end
  if name == 'bruju' then name = 'zuju' end
  if name == 'duju' then name = 'puju' end
  table.merge(vars, self, true)

	local json = spine.SkeletonJson.new()
	json.scale = self.scale 

	self.skeletonData = json:readSkeletonDataFile('media/skeletons/' .. name .. '/' .. name .. '.json')
	self.skeleton = spine.Skeleton.new(self.skeletonData)
	self.skeleton.createImage = function(_, attachment)
		return love.graphics and love.graphics.newImage('media/skeletons/' .. name .. '/' .. attachment.name .. '.png')
	end
	self.skeleton:setToSetupPose()

  self.owner = owner

  self.stateData = spine.AnimationStateData.new(self.skeletonData)

  local i = 0 -- 0-indexed because it gets sent over the network.
  self.animationMap = {}
  table.each(self.animations, function(animation, name)
    animation.name = name
    animation.index = i
    if animation.mix then
      table.each(animation.mix, function(time, to)
        self.stateData:setMix(name, to, time)
      end)
    end
    self.animationMap[i] = animation
    i = i + 1
  end)

  self.state = spine.AnimationState.new(self.stateData)

  self.state.onComplete = function(track)
    local action = self:current(track).complete
    if not action then return end
    if type(action) == 'function' then action(self, self.owner)
    elseif type(action) == 'string' then self:set(action) end
  end

  self.state.onEvent = function(track, event)
    if self.on and self.on[event.data.name] then
      self.on[event.data.name](self, self.owner, event)
    end
  end

  if self.initial then self:set(self.initial) end
end

function Animation:draw(x, y)
  self:reposition(x, y)
  self:tick(delta)
  self.skeleton:draw()
end

function Animation:drawRaw(data, x, y)
  local animation = self.animationMap[data.index]
  if not animation then print('draw: no animation') return end

  local spine = self.skeletonData:findAnimation(animation.name)
  local time = data.time * spine.duration

  if not data.mixing then
    spine:apply(self.skeleton, time, time, animation.loop, nil)
  else
    local previous = self.animationMap[data.mixWith]
    if previous then
      local prevSpine = self.skeletonData:findAnimation(previous.name)
      local prevTime = data.mixTime * prevSpine.duration
      prevSpine:apply(self.skeleton, prevTime, prevTime, previous.loop, nil)
      spine:mix(self.skeleton, time, time, animation.loop, nil, data.mixAlpha)
    end
  end

  self.skeleton.flipX = data.flipped
  self.skeleton.x = x + self.offsetx
  self.skeleton.y = y + self.offsety
  self.skeleton:updateWorldTransform()
  self.skeleton:draw()
end

function Animation:set(name)
  local current = self:current()
  if current and (current.name == name or self.animations[name].priority < current.priority) then return end
  self.state:setAnimationByName(0, name, self.animations[name].loop, 0)
end

function Animation:current(track)
  track = track or 0
  local animation = self.state:getCurrent(track)
  if not animation then return nil end
  return self.animations[animation.animation.name]
end

function Animation:blocking()
  local current = self:current()
  return current and current.blocking
end

function Animation:reposition(x, y)
  x = x or self.owner.x
  y = y or self.owner.y
  self.skeleton.x = x + self.offsetx
  self.skeleton.y = y + self.offsety
  self.skeleton.flipX = self.flipX
end

function Animation:tick(delta)
  delta = delta or tickRate

  local current = self:current()
  if not current then return end
  self.state:update(delta * (f.exe(current.speed, self, self.owner) or 1))
  self.state:apply(self.skeleton)
  self.skeleton:updateWorldTransform()
end

function Animation:pack()
  local result = {}

  local track = self.state:getCurrent(0)
  if not track then return end

  local animation = self.animations[track.animation.name]
  if not animation then return end

  local mixing = track.previous
  if mixing and not self.animations[mixing.animation.name] then return end

  result.index = animation.index
  result.time = math.clamp(track.time % track.animation.duration / track.animation.duration, 0, 1)
  result.flipped = self.flipX == true
  result.mixing = mixing
  if mixing then
    result.mixWith = self.animations[mixing.animation.name].index
    result.mixTime = math.clamp(mixing.time % mixing.animation.duration / mixing.animation.duration, 0, 1)
    result.mixAlpha = math.clamp(track.mixTime / track.mixDuration * track.mix, 0, 1)
  end

  return result
end
