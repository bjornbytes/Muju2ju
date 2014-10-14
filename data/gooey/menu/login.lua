return {
  code = 'login',
  { id = 'background',
    kind = 'Element',
    properties = {
      width = 1,
      height = 1,
      background = {0, 0, 0}
    },
    children = {
      { id = 'username',
        kind = 'TextField',
        properties = {
          x = .2,
          y = .5,
          width = .4,
          height = .05,
          padding = 8,
          font = 'aeromatics',
          text = '',
          placeholder = 'Username',
          border = {255, 255, 255}
        }
      },
      { id = 'password',
        kind = 'Password',
        properties = {
          x = .2,
          y = .58,
          width = .4,
          height = .05,
          padding = 8,
          font = 'aeromatics',
          text = '',
          placeholder = 'Password',
          border = {255, 255, 255}
        }
      },
      { id = 'loginButton',
        kind = 'Button',
        properties = {
          x = .2,
          y = .66,
          width = .15,
          height = .05,
          padding = 8,
          font = 'aeromatics',
          text = 'Login',
          border = {255, 255, 255}
        }
      },
			{ id = 'exitButton',
				kind = 'Button',
				properties = {
					x = .82,
					y = .90,
					width = .15,
					height = .05,
					padding = 8,
					font = 'aeromatics',
					text = 'Quit',
					border = {255, 255, 255}
				}
			}
    }
  }
}
