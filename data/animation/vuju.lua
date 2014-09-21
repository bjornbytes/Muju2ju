local Vuju = extend(Animation)
Vuju.code = 'vuju'

Vuju.scale = .5
Vuju.initial = 'idle'
Vuju.animations = {}

Vuju.animations.idle = {
  priority = 1,
  loop = true,
  speed = .4,
  mix = {
    cast = .2,
    death = .2
  }
}

Vuju.animations.cast = {
  priority = 2,
  speed = .8,
  mix = {
    idle = .2,
    death = .2
  }
}

Vuju.animations.death = {
  priority = 3,
  blocking = true,
  speed = .8,
  complete = function(self, owner)
    ctx.minions:remove(owner)
  end
}

return Vuju
