local Zuju = extend(Animation)
Zuju.code = 'zuju'

Zuju.scale = .5
Zuju.initial = 'spawn'
Zuju.animations = {}

Zuju.animations.spawn = {
  priority = 3,
  blocking = true,
  speed = .85,
  mix = {
    walk = .4
  }
}

Zuju.animations.idle = {
  priority = 1,
  loop = true,
  speed = .3,
  mix = {
    walk = .2,
    death = .2
  }
}

Zuju.animations.walk = {
  priority = 1,
  loop = true,
  speed = .73,
  mix = {
    death = .2
  }
}

Zuju.animations.death = {
  priority = 3,
  blocking = true,
  speed = .8,
  complete = function(self, owner)
    owner:die()
  end
}

return Zuju
