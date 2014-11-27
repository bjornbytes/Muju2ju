Animation = class()

function Animation:init()
  self:initSpine(self.code)

  for i = 1, #self.states do
    table.each(self.states[i].mix, function(time, to)
      self.spine.animationStateData:setMix(self.states[i].name, to, time)
    end)
  end

  self.event = Event()
  self.spine.animationState.onComplete = function() self.event:emit('complete', {state = self.state}) end
  self.spine.animationState.onEvent = function(_, data) self.event:emit('event', data) end

  self:set(self.default)
  self.speed = 1
  self.flipped = false
end

function Animation:draw(x, y)
  local skeleton, animationState = self.spine.skeleton, self.spine.animationState
  skeleton.x = x + (self.offsetx or 0)
  skeleton.y = y + (self.offsety or 0)
  skeleton.flipX = self.flipped
  animationState:update(delta * (self.state.speed or 1) * self.speed)
  animationState:apply(skeleton)
  skeleton:updateWorldTransform()
  skeleton:draw()
end

function Animation:set(name, options)
  if not name or not self.states[name] then return end
  options = options or {}

  local target = self.states[name]

  if self.state and self.state.name == target.name then return end
  if not options.force and self.state and self.state.priority > target.priority then return end

  self.state = target
  self.spine.animationState:setAnimationByName(0, self.state.name, self.state.loop)
end

function Animation:initSpine(name)
	local json = spine.SkeletonJson.new()
	json.scale = self.scale

	local skeletonData = json:readSkeletonDataFile('media/skeletons/' .. name .. '/' .. name .. '.json')

	local skeleton = spine.Skeleton.new(skeletonData)
	skeleton.createImage = function(_, attachment)
		return love.graphics and love.graphics.newImage('media/skeletons/' .. name .. '/' .. attachment.name .. '.png')
	end
	skeleton:setToSetupPose()
  local animationStateData = spine.AnimationStateData.new(skeletonData)
  local animationState = spine.AnimationState.new(animationStateData)

  self.spine = {
    json = json,
    skeletonData = skeletonData,
    skeleton = skeleton,
    animationStateData = animationStateData,
    animationState = animationState
  }
end

function Animation:on(...)
  return self.event:on(...)
end
