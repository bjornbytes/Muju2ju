local Bruju = extend(Animation)
Bruju.code = 'bruju'

Bruju.scale = .5
Bruju.offsety = 48
Bruju.default = 'spawn'
Bruju.states = {}

Bruju.states.spawn = {
  priority = 3,
  blocking = true,
  speed = .85,
  mix = {
    walk = .4
  }
}

Bruju.states.idle = {
  priority = 1,
  loop = true,
  speed = .3,
  mix = {
    walk = .2,
    death = .2
  }
}

Bruju.states.walk = {
  priority = 1,
  loop = true,
  speed = .73,
  mix = {
    death = .2
  }
}

Bruju.states.death = {
  priority = 3,
  blocking = true,
  speed = .8
}

return Bruju
