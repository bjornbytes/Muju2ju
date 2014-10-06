local Huju = extend(Animation)
Huju.code = 'huju'

Huju.scale = .5
Huju.initial = 'idle'
Huju.animations = {}

Huju.animations.idle = {
  priority = 1,
  loop = true,
  speed = .4,
  mix = {
    cast = .2,
    death = .2
  }
}

Huju.animations.cast = {
  priority = 2,
  speed = .8,
  mix = {
    idle = .2,
    death = .2
  }
}

Huju.animations.death = {
  priority = 3,
  blocking = true,
  speed = .8,
  complete = function(self, owner)
    ctx.units:remove(owner)
  end
}

return Huju
