local Muju = extend(Animation)
Muju.code = 'muju'

Muju.scale = .6
Muju.offsety = Player.height / 2
Muju.initial = 'idle'
Muju.animations = {}

Muju.animations.idle = {
  priority = 1,
  loop = true,
  speed = .4,
  mix = {
    idle = .1,
    walk = .2,
    summon = .1,
    death = .2
  }
}

Muju.animations.walk = {
  priority = 1,
  loop = true,
  speed = function(self, owner)
    return math.abs(owner.speed / owner.walkSpeed)
  end,
  mix = {
    idle = .2,
    summon = .1,
    death = .2
  }
}

Muju.animations.summon = {
  priority = 2,
  blocking = true,
  speed = 1.85,
  mix = {
    walk = .2,
    idle = .2
  }
}

Muju.animations.death = {
  priority = 3,
  blocking = true,
  mix = {
    resurrect = .2
  }
}

Muju.animations.resurrect = {
  priority = 3,
  blocking = true,
  speed = 2
}

return Muju
