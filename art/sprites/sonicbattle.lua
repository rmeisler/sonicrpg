return {
    image = "sonicbattle.png",
    starting = "idle",
    w = 47,
    h = 55,

    animations = {
        idle = {
            frames = {{0,1}}
        },
		backward = {
			frames = {{0,0}}
		},
        crouch = {
            frames = {{3,0}}
        },
        leap = {
            frames = {{4,0}}
        },
		leap_dodge = {
			frames = {{5,0}}
		},
		victory = {
			frames = {{0,1}, {1,1}},
			speed = 0.1
		},
        pummel = {
            frames = {{0,2},{1,2},{2,2},{3,2},{0,2},{1,2},{2,2},{3,2},{0,2},{1,2},{2,2},{3,2},{0,0},{2,0}},
            speed = 0.05
        },
		spin = {
			frames = {{0,3}}
		},
		spincharge = {
			frames = {{0,7},{1,7},{2,7},{3,7},{4,7},{5,7}},
			speed = 0.08
		},
        hurt = {
            frames = {{2,1}}
        },
        dead = {
            frames = {{3,1}}
        },
		
		escape_right = {
			frames = {{0,5},{1,5},{2,5},{3,5}},
			speed = 0.08
		},
		escape_left = {
			frames = {{0,6},{1,6},{2,6},{3,6}},
			speed = 0.08
		},
		
		juiceupleft = {
			frames = {{6,6}}
		},
		juiceupright = {
			frames = {{6,5}},
			speed = 0.08
		},
		juiceup = {
			frames = {{6,7}},
			speed = 0.08
		},
		juiceright = {
			frames = {{0,8},{1,8},{2,8},{3,8}},
			speed = 0.08
		},
		
		-- Power ring animations
		fish_backpack = {
			frames = {{5,2},{6,2},{5,2},{6,2},{4,2},{4,2},{4,2}},
			speed = 0.2
		},
		foundring_backpack = {
			frames = {{5,3}, {5,3}, {5,3}, {5,3}, {5,3}, {5,3}, {5,3}, {5,3}, {6,3}, {5,4}, {5,4}, {5,4}, {5,4}, {5,4}, {5,4}},
			speed = 0.08
		},
		liftring = {
			frames = {{1,3},{2,3},{3,3},{4,3},{1,4},{2,4},{3,4},{4,4},{1,3}},
			speed = 0.1
		},
		liftring_idle = {
			frames = {{1,3}}
		},
    }
}