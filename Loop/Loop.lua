--- STEAMODDED HEADER

--- MOD_NAME: Loop
--- MOD_ID: loop
--- MOD_AUTHOR: [jenwalter666]
--- MOD_DESCRIPTION: Adds a new voucher called Loop, allowing certain vouchers to be re-redeemed in the same run.
--- PRIORITY: -9999999999
--- BADGE_COLOR: 9f008c
--- PREFIX: loop
--- VERSION: 0.1.1
--- LOADER_VERSION_GEQ: 1.0.0

SMODS.Atlas {
	key = "modicon",
	path = "loop_avatar.png",
	px = 34,
	py = 34
}

SMODS.Atlas {
	key = "loopvoucher",
	path = "v_loop.png",
	px = 71,
	py = 95
}

LoopVoucher = {}
LoopVoucher.loopable = {
	'v_grabber',
	'v_nacho_tong',
	'v_wasteful',
	'v_recyclomancy',
	'v_reroll_glut',
	'v_reroll_surplus',
	'v_blank',
	'v_antimatter',
	'v_crystal_ball',
	'v_paint_brush',
	'v_palette'
}

--Allow external mods to add onto/remove from this list
LoopVoucher.AddLoopableVoucher = function(key)
	local already_exists = false
	for k, v in pairs(LoopVoucher.loopable) do
		if v == key then
			already_exists = true
			break
		end
	end
	if not already_exists then
		table.insert(LoopVoucher.loopable, key)
	end
end

LoopVoucher.RemoveLoopableVoucher = function(key)
	for k, v in pairs(LoopVoucher.loopable) do
		if v == key then
			table.remove(LoopVoucher.loopable, k)
			break
		end
	end
end

SMODS.Voucher {
	key = 'loop',
	loc_txt = {
		name = 'Loop',
		text = {
			'{C:attention}Unredeems{} certain vouchers,',
			'allowing them to be',
			'{C:attention}redeemed again{} for',
			'{C:green}stacking{} effects'
		}
	},
	atlas = 'loopvoucher',
	cost = 30,
	unlocked = true,
	discovered = true,
	requires = LoopVoucher.loopable
}

local redeemref = Card.redeem

function Card:redeem()
	redeemref(self)
	if self.config.center_key == 'v_loop_loop' then
		G.GAME.used_vouchers[self.config.center_key] = false
		for k, v in pairs(LoopVoucher.loopable) do
			G.GAME.used_vouchers[v] = false
		end
	end
end