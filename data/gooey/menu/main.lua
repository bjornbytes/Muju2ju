return {
	code = 'main',
	{ id = 'background',
		kind = 'Element',
		properties = {
			width = 1,
			height = 1,
			background = data.media.graphics.mainMenu
		},
		children = {
			{ id = 'header',
				kind = 'Element',
				properties = {
					width = 1,
					height = .06,
					padding = 4,
					background = {0, 0, 0, 100}
				},
				children = {
					{ id = 'editButton',
						kind = 'Button',
						properties = {
							width = .06,
							height = 1,
							border = {255, 255, 255},
							font = 'aeromatics'
						}
					},
					{ id = 'optionsButton',
						kind = 'Button',
						properties = {
							x = .88,
							y = 0,
							width = .06,
							height = 1,
							border = {255, 255, 255},
							font = 'aeromatics'
						}
					},
					{ id = 'exitButton',
						kind = 'Button',
						properties = {
							x = .94,
							y = 0,
							width = .06,
							height = 1,
							border = {255, 255, 255},
							font = 'aeromatics'
						}
					}
				}
			},
			{ id = 'body',
				kind = 'Element',
				properties = {
					x = 0,
					y = .06,
					width = 1,
					height = .94
				},
				children = {
					{ id = 'survivalButton',
						kind = 'Button',
						properties = {
							x = .2,
							y = .8,
							width = .25,
							height = .1,
							padding = 12,
							border = {255, 255, 255},
							font = 'aeromatics',
							text = 'Survival'
						}
					},
					{ id = 'versusButton',
						kind = 'Button',
						properties = {
							x = .55,
							y = .8,
							width = .25,
							height = .1,
							padding = 12,
							border = {255, 255, 255},
							font = 'aeromatics',
							text = 'Versus'
						}
					}
				}
			}
		}
	}
}
