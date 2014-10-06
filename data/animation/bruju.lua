local Bruju = extend(Animation)
Bruju.code = 'bruju'

Bruju.scale = .5
Bruju.offsety = 48
Bruju.initial = 'spawn'
Bruju.animations = {}

Bruju.animations.spawn = {
  priority = 3,
  blocking = true,
  speed = .85,
  mix = {
    walk = .4
  }
}

Bruju.animations.idle = {
  priority = 1,
  loop = true,
  speed = .3,
  mix = {
    walk = .2,
    death = .2
  }
}

Bruju.animations.walk = {
  priority = 1,
  loop = true,
  speed = .73,
  mix = {
    death = .2
  }
}

Bruju.animations.death = {
  priority = 3,
  blocking = true,
  speed = .8,
  complete = function(self, owner)
    owner:die()
  end
}

return Bruju
