return {
    image = "sally.png",
    starting = "idleleft",
    w = 47,
    h = 55,

    animations = {
		pose = {
			frames = {{0,4}}
		},
		shock = {
			frames = {{11,4}}
		},
		
		leapdown = {
			frames = {{5,2}}
		},
		
		nichole_project_start = {
			frames = {{10,2},{11,2}},
			speed = 0.05
		},
		nichole_project_idle = {
			frames = {{11,2},{12,2},{13,2},{12,2}},
			speed = 0.05
		},
		
		idleright = {
            frames = {{0,0}}
        },
		idleleft = {
			frames = {{0,1}}
		},
		idledown = {
			frames = {{0,2}}
		},
		idleup = {
			frames = {{0,3}}
		},
		walkright = {
			frames = {{1,0}, {2,0}, {3,0}, {4,0}, {5,0}, {6,0}, {7,0}, {8,0}},
			speed = 0.085,
			locationoffsets = {
				head = {
					{x = 0, y = 0}, {x = 0, y = 2}, {x = 0, y = 4}, {x = 0, y = 2},
					{x = 0, y = 0}, {x = 0, y = 2}, {x = 0, y = 4}, {x = 0, y = 2}
				}
			}
		},
		walkleft = {
			frames = {{1,1}, {2,1}, {3,1}, {4,1}, {5,1}, {6,1}, {7,1}, {8,1}},
			speed = 0.085,
			locationoffsets = {
				head = {
					{x = 0, y = 0}, {x = 0, y = 2}, {x = 0, y = 4}, {x = 0, y = 2},
					{x = 0, y = 0}, {x = 0, y = 2}, {x = 0, y = 4}, {x = 0, y = 2}
				}
			}
		},
		walkdown = {
			frames = {{1,2}, {2,2}, {3,2}, {4,2},{5,2}, {6,2}, {7,2}, {8,2}},
			speed = 0.08,
			locationoffsets = {
				head = {
					{x = 0, y = 0}, {x = 0, y = 2}, {x = 0, y = 4}, {x = 0, y = 2},
					{x = 0, y = 0}, {x = 0, y = 2}, {x = 0, y = 4}, {x = 0, y = 2}
				}
			}
		},
		walkup = {
			frames = {{1,3}, {2,3}, {3,3}, {4,3},{5,3}, {6,3}, {7,3}, {8,3}},
			speed = 0.08,
			locationoffsets = {
				head = {
					{x = 0, y = 0}, {x = 0, y = 2}, {x = 0, y = 4}, {x = 0, y = 2},
					{x = 0, y = 0}, {x = 0, y = 2}, {x = 0, y = 4}, {x = 0, y = 2}
				}
			}
		},
		
		nicholeright = {
            frames = {{9,0}}
        },
		nicholeleft = {
			frames = {{9,1}}
		},
		nicholedown = {
			frames = {{9,2}}
		},
		nicholeup = {
			frames = {{9,3}}
		},
		
		hideright = {
			frames = {{1,4}}
		},
		hideleft = {
			frames = {{3,4}}
		},
		hideup = {
			frames = {{5,4}}
		},
		hidedown = {
			frames = {{7,4}}
		},
		hidedownhand = {
			frames = {{8,4}}
		},
		
		peekright = {
			frames = {{2,4}}
		},
		peekleft = {
			frames = {{4,4}}
		},
		peekup = {
			frames = {{6,4}}
		},
		
		thinking = {
			frames = {{10,4}}
		},
    }
}