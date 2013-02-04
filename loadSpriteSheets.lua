local spriteSheet = require 'spriteSheet'
local spriteSheetManager = require 'spriteSheetManager'

local body_animations =
{
	['standup'] = 
	{
		_frames = { 105 },
		_boundaries = { { 20,48,44,62 } },
		_delays = { 3600 },
		_offsets = { { 32, 64 } },
		_loopType = 'loop',
		_loopCount = -1	
	},
	['walkup'] = 
	{
		_frames = { 106, 107, 108, 109, 110, 111, 112, 113 },
		_boundaries = { 
			{ 20,48,44,62 }, { 20,48,44,62 }, { 20,48,44,62 },
			{ 20,48,44,62 }, { 20,48,44,62 }, { 20,48,44,62 },
			{ 20,48,44,62 }, { 20,48,44,62 }
		},
		_delays = { 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1 },
		_offsets = { 
			{ 32, 64 }, { 32, 64 }, { 32, 64 }, { 32, 64 }, 
			{ 32, 64 }, { 32, 64 }, { 32, 64 }, { 32, 64 }
		},
		_loopType = 'loop',
		_loopCount = -1	
	},
	['standleft'] = 
	{
		_frames = { 118 },
		_boundaries = { { 20,48,44,62 } },
		_delays = { 3600 },
		_offsets = { { 32, 64 } },
		_loopType = 'loop',
		_loopCount = -1	
	},	
	['walkleft'] = 
	{
		_frames = { 119, 120, 121, 122, 123, 124, 125, 126 },
		_boundaries = { 
			{ 20,48,44,62 }, { 20,48,44,62 }, { 20,48,44,62 },
			{ 20,48,44,62 }, { 20,48,44,62 }, { 20,48,44,62 },
			{ 20,48,44,62 }, { 20,48,44,62 }
		},		
		_delays = { 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1 },
		_offsets = { 
			{ 32, 64 }, { 32, 64 }, { 32, 64 }, { 32, 64 }, 
			{ 32, 64 }, { 32, 64 }, { 32, 64 }, { 32, 64 }
		},
		_loopType = 'loop',
		_loopCount = -1	
	},
	['standdown'] = 
	{
		_frames = { 131 },
		_boundaries = { { 20,48,44,62 } },
		_delays = { 3600 },
		_offsets = { { 32, 64 } },
		_loopType = 'loop',
		_loopCount = -1	
	},		
	['walkdown'] = 
	{
		_frames = { 132, 133, 134, 135, 136, 137, 138, 139 },
		_boundaries = { 
			{ 20,48,44,62 }, { 20,48,44,62 }, { 20,48,44,62 },
			{ 20,48,44,62 }, { 20,48,44,62 }, { 20,48,44,62 },
			{ 20,48,44,62 }, { 20,48,44,62 }
		},		
		_delays = { 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1 },
		_offsets = { 
			{ 32, 64 }, { 32, 64 }, { 32, 64 }, { 32, 64 }, 
			{ 32, 64 }, { 32, 64 }, { 32, 64 }, { 32, 64 }
		},
		_loopType = 'loop',
		_loopCount = -1	
	},
	['standright'] = 
	{
		_frames = { 144 },
		_boundaries = { { 20,48,44,62 } },
		_delays = { 3600 },
		_offsets = { { 32, 64 } },
		_loopType = 'loop',
		_loopCount = -1	
	},			
	['walkright'] = 
	{
		_frames = { 145, 146, 147, 148, 149, 150, 151, 152 },
		_boundaries = { 
			{ 20,48,44,62 }, { 20,48,44,62 }, { 20,48,44,62 },
			{ 20,48,44,62 }, { 20,48,44,62 }, { 20,48,44,62 },
			{ 20,48,44,62 }, { 20,48,44,62 }
		},		
		_delays = { 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1 },
		_offsets = { 
			{ 32, 64 }, { 32, 64 }, { 32, 64 }, { 32, 64 }, 
			{ 32, 64 }, { 32, 64 }, { 32, 64 }, { 32, 64 }
		},
		_loopType = 'loop',
		_loopCount = -1	
	},	
	['attackup'] = 
	{
		_frames = { 157, 158, 159, 160, 161, 162 },
		_boundaries = { 
			{ 20,48,44,62 }, { 20,48,44,62 }, { 20,48,44,62 },
			{ 20,48,44,62 }, { 20,48,44,62 }, { 20,48,44,62 }
		},		
		_delays = { 0.05, 0.05, 0.05, 0.05, 0.05, 0.05 },
		_offsets = { 
			{ 32, 64 }, { 32, 64 }, { 32, 64 }, { 32, 64 }, 
			{ 32, 64 }, { 32, 64 }
		},
		_loopType = 'pingpong',
		_loopCount = 2
	},	
	['attackleft'] = 
	{
		_frames = { 170, 171, 172, 173, 174, 175 },
		_boundaries = { 
			{ 20,48,44,62 }, { 20,48,44,62 }, { 20,48,44,62 },
			{ 20,48,44,62 }, { 20,48,44,62 }, { 20,48,44,62 }
		},		
		_delays = { 0.05, 0.05, 0.05, 0.05, 0.05, 0.05 },
		_offsets = { 
			{ 32, 64 }, { 32, 64 }, { 32, 64 }, { 32, 64 }, 
			{ 32, 64 }, { 32, 64 }
		},
		_loopType = 'pingpong',
		_loopCount = 2
	},
	['attackdown'] = 
	{
		_frames = { 183, 184, 185, 186, 187, 188 },
		_boundaries = { 
			{ 20,48,44,62 }, { 20,48,44,62 }, { 20,48,44,62 },
			{ 20,48,44,62 }, { 20,48,44,62 }, { 20,48,44,62 }
		},		
		_delays = { 0.05, 0.05, 0.05, 0.05, 0.05, 0.05 },
		_offsets = { 
			{ 32, 64 }, { 32, 64 }, { 32, 64 }, { 32, 64 }, 
			{ 32, 64 }, { 32, 64 }
		},
		_loopType = 'pingpong',
		_loopCount = 2
	},
	['attackright'] = 
	{
		_frames = { 196, 197, 198, 199, 200, 201 },
		_boundaries = { 
			{ 20,48,44,62 }, { 20,48,44,62 }, { 20,48,44,62 },
			{ 20,48,44,62 }, { 20,48,44,62 }, { 20,48,44,62 }
		},		
		_delays = { 0.05, 0.05, 0.05, 0.05, 0.04, 0.05 },
		_offsets = { 
			{ 32, 64 }, { 32, 64 }, { 32, 64 }, { 32, 64 }, 
			{ 32, 64 }, { 32, 64 }
		},
		_loopType = 'pingpong',
		_loopCount = 2
	}
}

-- the human male light body sprite sheet
local ss = spriteSheet:new(imageManager.load('images/sprites/body/male/light.png'))
ss:uniformFrames(64, 64)
ss:quads()
ss:animations(body_animations)
spriteSheetManager.sheet('male_body_light', ss)

--[[

-- the orc male green body sprite sheet
local ss = spriteSheet:new(imageManager.load('images/sprites/body/male/orc.png'))
ss:uniformFrames(64, 64)
ss:quads()
ss:animations(body_animations)
spriteSheetManager.sheet('male_body_orc', ss)

-- the brown shirt sprite sheet
local ss = spriteSheet:new(imageManager.load('images/sprites/torso/male/shirt_brown.png'))
ss:uniformFrames(64, 64)
ss:quads()
ss:animations(body_animations)
spriteSheetManager.sheet('male_torso_shirt_brown', ss)

-- the brown shirt sprite sheet
local ss = spriteSheet:new(imageManager.load('images/sprites/legs/male/metalpants_copper.png'))
ss:uniformFrames(64, 64)
ss:quads()
ss:animations(body_animations)
spriteSheetManager.sheet('male_legs_metalpants_copper', ss)

-- flying dagger sprite sheet
local ss = spriteSheet:new(imageManager.load('images/sprites/weapons/dagger.png'))
ss:uniformFrames(17, 17)
ss:quads()
ss:animations{
	['attack'] = 
	{
		_frames = { 1 },
		_boundaries = { 
			{ 0, 0, 17, 17 }
		},		
		_delays = { 3600 },
		_offsets = { 
			{ 8, 8 }
		},
		_loopType = 'loop',
		_loopCount = -1
	}
}
spriteSheetManager.sheet('weapons_flying_dagger', ss)

-- dungeon tile set
local i = imageManager.load('images/tiles/dungeon0.png')
i:setWrap('repeat', 'repeat')
i:setFilter('nearest', 'nearest')
local ss = spriteSheet:new(i)
ss:uniformFrames(32, 32)
ss:quads()
ss:tiles{
	nil, nil, nil, nil, 
	{ _offset = { 16, 32 }, _height = 60, _boundary = { -2, 24, 32, 32 } },
	{ _offset = { 16, 32 }, _height = 64, _boundary = { 0, 24, 32, 32 } },
	{ _offset = { 16, 32 }, _height = 64, _boundary = { 0, 24, 34, 32 } },
	nil, nil, nil, nil,
	{ _offset = { 16, 32 }, _height = 64, _boundary = { -2, 0, 18, 32 } },
	{ _offset = { 16, 32 }, _height = 64, _boundary = { 0, 0, 32, 32 } },
	{ _offset = { 16, 32 }, _height = 64, _boundary = { 16, 0, 34, 32 } },
	nil, nil, nil, nil, 	
	{ _offset = { 16, 32 }, _height = 64, _boundary = { -2, 0, 18, 32 } },
	{ _offset = { 16, 32 }, _height = 64, _boundary = { 0, 24, 32, 32 } },
	{ _offset = { 16, 32 }, _height = 64, _boundary = { 16, 0, 34, 32 } }	
}
spriteSheetManager.sheet('tiles_dungeon_0', ss)
]]
