timer = {}
timer.rot = function(v, fn)
	if v > 0 then
		v = v - tickRate
		if v <= 0 then
			v = 0
			v = f.exe(fn) or 0
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
