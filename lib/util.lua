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

if love.graphics then
  local g = love.graphics

  function g.rectangleCenter(how, x, y, w, h, nohor, nover)
    x = nohor and x or x - w / 2
    y = nover and y or y - h / 2
    return g.rectangle(how, x, y, w, h)
  end

  function g.printCenter(what, x, y)
    local font = g.getFont()
    g.print(what, x, y, 0, 1, 1, font:getWidth(what) / 2, font:getHeight() / 2)
  end
end

function math.insideCircle(x, y, cx, cy, r)
  return math.distance(x, y, cx, cy) < r
end
