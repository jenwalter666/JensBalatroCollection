--- STEAMODDED HEADER

--- MOD_NAME: Jen's Library
--- MOD_ID: JenLib
--- MOD_AUTHOR: [jenwalter666]
--- MOD_DESCRIPTION: Some functions that I commonly use which some people might find a use for
--- BADGE_COLOR: 000000
--- PREFIX: jenlib
--- VERSION: 0.2.0
--- LOADER_VERSION_GEQ: 1.0.0

--Global table, don't modify!
jl = {}

--Checks a string against a table of strings
function jl.bf(needle, haystack)
	if type(needle) ~= 'string' then return false end
	if type(haystack) ~= 'table' then return false end
	for k, v in pairs(haystack) do
		if type(v) == 'string' and v == needle then return true end
	end
	return false
end

--Returns the first instance of a given card by ID, or nil if the card doesn't exist
function jl.fc(id, area)
	if not area then area = 'jokers' end
	if not G[area] then return end
	for i = 1, #G[area].cards do
		if G[area].cards[i].config.center.key == id then return G[area].cards[i] end
	end
	return
end

--Easier way of doing chance rolls
function jl.chance(name, probability, absolute)
	return pseudorandom(name) < (absolute and 1 or G.GAME.probabilities.normal)/probability
end

--Returns a deep copy of a table without infinite recursion
function jl.deepcopy(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
  
    local s = seen or {}
    local res = {}
    s[obj] = res
    for k, v in pairs(obj) do res[deepCopy(k, s)] = deepCopy(v, s) end
    return setmetatable(res, getmetatable(obj))
end

--Easier way to call joker calculations
function jl.jokers(data)
	if G.jokers and #G.jokers.cards > 0 then
		for i = 1, #G.jokers.cards do
			local effects = G.jokers.cards[i]:calculate_joker(data)
			if effects and effects.joker_repetitions then
				rep_list = effects.joker_repetitions
				data.retrigger_joker = true
				for z=1, #rep_list do
					if type(rep_list[z]) == 'table' and rep_list[z].repetitions then
						for r=1, rep_list[z].repetitions do
							card_eval_status_text(rep_list[z].card, 'jokers', nil, nil, nil, rep_list[z])
							G.jokers.cards[i]:calculate_joker(data)
						end
					end
				end
				data.retrigger_joker = nil
			end
		end
	end
end

--Adds a delay to the event manager that uses real time instead of gamespeed-affected time
function realdelay(time, queue)
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
		timer = 'REAL',
        delay = time or 1,
        func = function()
           return true
        end
    }), queue)
end

function jl.rd(time, queue)
	realdelay(time, queue)
end

--Useful for enhancements
function jl.sc(context)
	return context.cardarea and context.cardarea == G.play and not context.before and not context.after and not context.repetition
end

function jl.favhand()
	if not G.GAME or not G.GAME.current_round then return 'High Card' end
	return G.GAME.current_round.most_played_poker_hand
end

function jl.sfavhand()
	if not G.GAME or not G.GAME.current_round then return 'High Card' end
	local chosen_hand = 'High Card'
	local _handname, _played, _order = 'High Card', -1, 100
	for k, v in pairs(G.GAME.hands) do
		if k ~= G.GAME.current_round.most_played_poker_hand and v.played > _played or (v.played == _played and _order > v.order) then 
			_played = v.played
			_handname = k
		end
	end
	chosen_hand = _handname
	return chosen_hand
end

function jl.lowhand()
	local chosen_hand = 'High Card'
	local lowest_level = math.huge
	for _, v in ipairs(G.handlist) do
		if G.GAME.hands[v].level <= lowest_level then
			chosen_hand = v
			lowest_level = G.GAME.hands[v].level
		end
	end
	return chosen_hand
end

function jl.hihand()
	local chosen_hand = 'High Card'
	local highest_level = -math.huge
	for _, v in ipairs(G.handlist) do
		if G.GAME.hands[v].level > lowest_level then
			chosen_hand = v
			highest_level = G.GAME.hands[v].level
		end
	end
	return chosen_hand
end

function jl.rndhand(ignore, seed, allowhidden)
	local chosen_hand
	ignore = ignore or {}
	seed = seed or 'randomhand'
	if type(ignore) ~= 'table' then ignore = {ignore} end
	while true do
		chosen_hand = pseudorandom_element(G.handlist, pseudoseed(seed))
		if G.GAME.hands[chosen_hand].visible or allowhidden then
			local safe = true
			for _, v in pairs(ignore) do
				if v == chosen_hand then safe = false end
			end
			if safe then break end
		end
	end
	return chosen_hand
end

--Easier way to type G.SETTINGS.GAMESPEED
function jl.gspd(mod)
	if mod and tonumber(mod) then
		G.SETTINGS.GAMESPEED = mod
	end
	return G.SETTINGS.GAMESPEED
end

--Rounds a number to the nearest integer or decimal place
function jl.round( num, idp )

	local mult = 10 ^ ( idp or 0 )
	return math.floor( num * mult + 0.5 ) / mult

end

--Checks if it's "safe" to use consumables
function jl.canuse()
	return not (((G.play and #G.play.cards > 0) or (G.CONTROLLER.locked) or (G.GAME.STOP_USE and G.GAME.STOP_USE > 0)) and G.STATE ~= G.STATES.HAND_PLAYED and G.STATE ~= G.STATES.DRAW_TO_HAND and G.STATE ~= G.STATES.PLAY_TAROT)
end

--Checks if the game is currently going through a Booster Pack
function jl.booster()
	return (
		G.STATE == G.STATES.TAROT_PACK
		or G.STATE == G.STATES.PLANET_PACK
		or G.STATE == G.STATES.SPECTRAL_PACK
		or G.STATE == G.STATES.STANDARD_PACK
		or G.STATE == G.STATES.BUFFOON_PACK
		or G.STATE == G.STATES.SMODS_BOOSTER_OPENED
	)
end

--Far more convenient way of doing <card>.config.center, makes doing checks for variables easy, e.g. Card:gc().cost
function Card:gc()
	return (self.config or {}).center or {}
end

function Card:norank()
	return self.ability.name == 'Stone Card' or self.config.center.no_rank
end

function Card:nosuit()
	return self.ability.name == 'Stone Card' or self.config.center.no_suit
end

function Card:norankorsuit()
	return self:norank() or self:nosuit()
end

function Card:nosuitorrank() --alias
	return self:norank() or self:nosuit()
end

function Card:norankandsuit()
	return self:norank() and self:nosuit()
end

function Card:nosuitandrank() --alias
	return self:norank() and self:nosuit()
end

--Gets tiring to type all the G.E_MANAGER mumbojumbo every time for things that are simple
function Q(fc, de, tr, bl, ba)
	G.E_MANAGER:add_event(Event({
		trigger = tr,
		delay = de,
		blockable = bl,
		blocking = ba,
		func = fc
	}))
end

--[[ Boilerplate:
	{string = '', colours = {G.C.WHITE}, rotate = 1,shadow = true, bump = true,float=true, scale = 0.9, pop_in = 1.5/G.SPEEDFACTOR, pop_in_rate = 1.5*G.SPEEDFACTOR}
]]

function Card:add_dynatext(top, bottom, delay)
	if self.jenlib_alreadyhasdynatext then self:remove_dynatext() end
	G.E_MANAGER:add_event(Event({trigger = 'after', delay = delay or 0.4, func = function()
		if top then
			top_dynatext = DynaText(top)
			self.children.jenlib_topdyna = UIBox{definition = {n = G.UIT.ROOT, config = {align = 'tm', r = 0.15, colour = G.C.CLEAR, padding = 0.15}, nodes = {{n = G.UIT.O, config = {object = top_dynatext}}}},config = {align="tm", offset = {x=0,y=0},parent = self}}
		end
		if bottom then
			bot_dynatext = DynaText(bottom)
			self.children.jenlib_botdyna = UIBox{definition = {n = G.UIT.ROOT, config = {align = 'tm', r = 0.15, colour = G.C.CLEAR, padding = 0.15}, nodes = {{n = G.UIT.O, config = {object = bot_dynatext}}}},config = {align="bm", offset = {x=0,y=0},parent = self}}
		end
		self.jenlib_alreadyhasdynatext = true
	return true end }))
end

function Card:remove_dynatext(delay, speed)
	if self.jenlib_alreadyhasdynatext then
		G.E_MANAGER:add_event(Event({trigger = 'after', delay = delay or 0.5, func = function()
			if self.children.jenlib_topdyna then
				self.children.jenlib_topdyna.definition.nodes[1].config.object:pop_out(speed or 4)
			end
			if self.children.jenlib_botdyna then
				self.children.jenlib_botdyna.definition.nodes[1].config.object:pop_out(speed or 4)
			end
		return true end }))
		G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.5, func = function()
			if self.children.jenlib_topdyna then
				self.children.jenlib_topdyna:remove()
				self.children.jenlib_topdyna = nil
			end
			if self.children.jenlib_botdyna then
				self.children.jenlib_botdyna:remove()
				self.children.jenlib_botdyna = nil
			end
			self.jenlib_alreadyhasdynatext = nil
		return true end }))
	end
end

--Tries to call a specified function in the card's center
function Card:invokefunc(func, ...)
	local obj = self.config.center
	if obj and obj[func] and type(obj[func]) == 'function' then obj[func](...) end
end

--Changes the sprites of a card along its atlas
function Card:spritepos(child, X, Y)
	if self.children[child] then
		if self.children[child].set_sprite_pos then
			self.children[child]:set_sprite_pos({x = X, y = Y})
		end
	end
end

local resize_lookout = {'Default', 'Enhanced'}

--Multiplies the card's size by mod
function Card:resize(mod, force_save)
	if force_save or not self.origsize then self.origsize = {w = self.T.w, h = self.T.h} end
	self:hard_set_T(self.T.x, self.T.y, self.T.w * mod, self.T.h * mod)
	remove_all(self.children)
	self.children = {}
	self.children.shadow = Moveable(0, 0, 0, 0)
	self:set_sprites(self.config.center, jl.bf((self.ability or {}).set or '', resize_lookout) and self.config.card)
	if self.area then
		if (G.shop_jokers and self.area == G.shop_jokers) or (G.shop_booster and self.area == G.shop_booster) or (G.shop_vouchers and self.area == G.shop_vouchers) then
			create_shop_card_ui(self)
		end
	end
end

--Tries to reset the card's size, if saved
function Card:resetsize()
	if self.origsize then
		self:hard_set_T(self.T.x, self.T.y, self.origsize.w, self.origsize.h)
		remove_all(self.children)
		self.children = {}
		self.children.shadow = Moveable(0, 0, 0, 0)
		self:set_sprites(self.config.center, jl.bf((self.ability or {}).set or '', resize_lookout) and self.config.card)
		if self.area then
			if (G.shop_jokers and self.area == G.shop_jokers) or (G.shop_booster and self.area == G.shop_booster) or (G.shop_vouchers and self.area == G.shop_vouchers) then
				create_shop_card_ui(self)
			end
		end
	end
end

--Alias of Card:resize
function Card:grow(mod, force_save)
	self:resize(mod, force_save)
end

--Divides the card's size by mod, alias of Card:resize(1 / mod)
function Card:shrink(mod, force_save)
	self:resize(1 / mod, force_save)
end

--Displays some announcement text (duration is affected by gamespeed, providing duration's number as a string will normalise it, or you can do duration*jl.gspd())
function jl.a(txt, duration, size, col, snd, sndpitch, sndvol)
	if type(duration) == 'string' then
		duration = (tonumber(duration) or 0)*G.SETTINGS.GAMESPEED
	end
	G.E_MANAGER:add_event(Event({
		func = (function()
			if snd then play_sound(snd, sndpitch, sndvol) end
			attention_text({
				scale = size or 1.4, text = txt, hold = duration or 2, colour = col or G.C.WHITE, align = 'cm', offset = {x = 0,y = -2.7},major = G.play
			})
		return true
	end)}))
end
