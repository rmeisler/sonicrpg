return {
    image = "sonicbattle.png",
    starting = "idle",
    w = 47,
    h = 55,

    animations = {
        idle = {
            frames = {{0,1}}
        },
		idle_lookup = {
            frames = {{5,5}}
        },
		backward = {
			frames = {{0,0}}
		},
        crouch = {
            frames = {{3,0}}
        },
		stun = {
            frames = {{0,4}}
        },
        leap = {
            frames = {{4,0}}
        },
		leap_dodge = {
			frames = {{5,0}}
		},
		victory = {
			frames = {{1,1}}
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
			frames = {{6,5}}
		},
		juicedownleft = {
			frames = {{6,9}}
		},
		juicedownright = {
			frames = {{6,8}}
		},
		juiceup = {
			frames = {{6,7}}
		},
		juicedown = {
			frames = {{5,8}}
		},
		juiceright = {
			frames = {{0,8},{1,8},{2,8},{3,8}},
			speed = 0.08
		},
		juiceleft = {
			frames = {{0,9},{1,9},{2,9},{3,9}},
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
		noring_idle = {
			frames = {{6,0}}
		},
		liftring_idle = {
			frames = {{1,3}}
		},
		ring_chargerun1 = {
			frames = {{4,11},{5,11},{6,11},{4,12}},
			speed = 0.07
		},
		ring_chargerun2 = {
			frames = {{5,12},{6,12},{4,13},{5,13}},
			speed = 0.02
		},
		ring_runleft = {
			frames = {{0,11},{1,11},{2,11},{3,11}},
			speed = 0.02
		},
		ring_runright = {
			frames = {{0,12},{1,12},{2,12},{3,12}},
			speed = 0.02
		},
		throw = {
			frames = {{1,10},{2,10},{3,10},{3,10},{3,10},{3,10}},
			speed = 0.1
		},
		tease = {
			frames = {{4,10},{5,10},{6,10}},
			speed = 0.2
		},
		shock = {
			frames = {{6,4}}
		},
		annoyed = {
			frames = {{4,8}}
		},
		thinking = {
			frames = {{4,9}}
		},
		criticizing = {
			frames = {{5,9}}
		},
		criticizing_sad = {
			frames = {{5,6}}
		},
		explain = {
			frames = {{4,5}}
		},
		idleup = {
			frames = {{4,6}}
		},
		takenback = {
			frames = {{0,10}}
		},
		block = {
			frames = {{2,0}}
		}
    }
}