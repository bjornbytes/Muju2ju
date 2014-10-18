timer = {}
timer.rot = function(v, fn)
	if v and v > 0 then
		v = v - tickRate
		if v <= 0 then
			v = (fn and fn()) or 0
		end
	end
	return v
end

isa = function(instance, class)
  while instance and type(instance) == 'table' do
    instance = getmetatable(instance).__index
    if instance == class then return true end
  end

  return false
end
