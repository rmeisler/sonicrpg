return {
    image = "swatbotwithblaster.png",
    starting = "idle",
    w = 56,
    h = 79,

    animations = {
		idle = {
            frames = {{0,0}}
        },
		backward = {
			frames = {{5,0}}
		},
		pose = {
			frames = {{0,3}}
		},
		shoot = {
			frames = {{7,3},{8,3}},
			speed = 0.06
		},
		shoot_idle = {
			frames = {{8,3}}
		},
		shoot_retract = {
			frames = {{8,3},{7,3}},
			speed = 0.06
		},
		
		pistol = {
			frames = {{8,5},{9,5},{8,5}},
			speed = 0.3
		},
		pistol_idle = {
			frames = {{8,5}}
		},
		
        idleright = {
            frames = {{0,0}}
        },
		idleleft = {
			frames = {{5,0}}
		},
		idledown = {
			frames = {{0,3}}
		},
		idleup = {
			frames = {{0,4}}
		},
		walkright = {
			frames = {{1,0},{2,0},{3,0},{4,0}},
			speed = 0.3
		},
		walkleft = {
			frames = {{6,0},{7,0},{8,0},{9,0}},
			speed = 0.3
		},
		walkdown = {
			frames = {{1,3},{2,3},{3,3},{2,3},{1,3},{4,3},{5,3},{6,3},{5,3},{4,3}},
			speed = 0.16
		},
		walkup = {
			frames = {{1,4},{2,4},{3,4},{2,4},{1,4},{4,4},{5,4},{6,4},{5,4},{4,4}},
			speed = 0.16
		},
		runright = {
			frames = {{0,1},{1,1},{2,1},{3,1},{4,1},{5,1},{6,1},{7,1}},
			speed = 0.1
		},
		runleft = {
			frames = {{0,2},{1,2},{2,2},{3,2},{4,2},{5,2},{6,2},{7,2}},
			speed = 0.1
		},
		rundown = {
			frames = {{0,5},{1,5},{2,5},{3,5},{4,5},{5,5},{6,5},{7,5}},
			speed = 0.1
		},
		runup = {
			frames = {{0,6},{1,6},{2,6},{3,6},{4,6},{5,6},{6,6},{7,6}},
			speed = 0.1
		},
		
		lightwalkright = {
			frames = {{1,0},{2,0},{3,0},{4,0}},
			speed = 0.3
		},
		lightwalkleft = {
			frames = {{6,0},{7,0},{8,0},{9,0}},
			speed = 0.3
		},
		lightwalkdown = {
			frames = {{1,3},{2,3},{3,3},{2,3},{1,3},{4,3},{5,3},{6,3},{5,3},{4,3}},
			speed = 0.16
		},
		lightwalkup = {
			frames = {{1,4},{2,4},{3,4},{2,4},{1,4},{4,4},{5,4},{6,4},{5,4},{4,4}},
			speed = 0.16
		},
		
		lightdown = {
			frames = {{0,3}}
		},
		lightup = {
			frames = {{0,4}}
		},
		lightleft = {
			frames = {{5,0}}
		},
		lightright = {
			frames = {{0,0}}
		},

		hurtleft = {
			frames = {{8,2}}
		},
		hurtright = {
			frames = {{8,1}}
		},
		hurtdown = {
			frames = {{9,4}}
		},
		hurt = {
			frames = {{8,1}}
		},
		idle_nopistol = {
			frames = {{8,6}}
		},
		hurt_nopistol = {
			frames = {{9,1}}
		},
		hurtdown_nopistol = {
			frames = {{9,3}}
		},
    }
}