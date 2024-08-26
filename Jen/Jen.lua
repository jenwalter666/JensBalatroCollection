--- STEAMODDED HEADER

--- MOD_NAME: Jen's Almanac DEMO
--- MOD_ID: jen
--- MOD_AUTHOR: [jenwalter666]
--- MOD_DESCRIPTION: Pandemonium and darkness incarnate.
--- PRIORITY: 9999999
--- BADGE_COLOR: 3c3cff
--- PREFIX: jen
--- VERSION: 0.0.3a-pre2
--- DEPENDENCIES: [Talisman>=2.0.0-beta4, Cryptid>=0.5.0~pre2, incantation>=0.4.1]
--- CONFLICTS: [fastsc]
--- LOADER_VERSION_GEQ: 1.0.0

SMODS.Atlas {
	key = "modicon",
	path = "almanac_avatar.png",
	px = 34,
	py = 34
}

Jen = {
	config = {
		wee_sizemod = 1.5,
		ante_threshold = 20,
		ante_pow10 = 25,
		ante_pow10_2 = 35,
		ante_pow10_3 = 50,
		ante_pow10_4 = 70,
		ante_exponentiate = 80,
		ante_tetrate = 90,
		ante_pentate = 100,
		ante_polytate = 125,
		polytate_factor = 10,
		polytate_decrement = 1,
		scalar_base = 1,
		scalar_increment = .13,
		scalar_additivedivisor = 50,
		scalar_exponent = 1,
		blind_scalar = {
		}
	}
}

if not IncantationAddons then
	IncantationAddons = {
		Stacking = {},
		Dividing = {},
		BulkUse = {},
		StackingIndividual = {},
		DividingIndividual = {},
		BulkUseIndividual = {}
	}
end

if not AurinkoAddons then
	AurinkoAddons = {}
end

local gsp = get_starting_params
function get_starting_params()
	newTable = gsp()
	newTable.consumable_slots = newTable.consumable_slots + 198
	return newTable
end

table.insert(IncantationAddons.Dividing, 'EX Consumables')
table.insert(IncantationAddons.BulkUse, 'Tokens')

AurinkoAddons.jen_wee = function(card, hand, instant, amount)
	if card and ((card.ability or {}).set or '') == 'Planet' and not card.playing_card then
		local twos = {}
		for k, v in pairs(G.deck.cards) do
			if v:get_id() == 2 then
				table.insert(twos, v)
			end
		end
		for k, v in pairs(G.hand.cards) do
			if v:get_id() == 2 then
				table.insert(twos, v)
			end
		end
		if #twos > 0 then
			card_eval_status_text(card, 'extra', nil, nil, nil, {message = #twos .. 'x Twos', colour = G.C.GREEN})
			for k, two in pairs(twos) do
				level_up_hand(two, hand, instant, amount)
			end
		end
	end
end

--{string = '', colours = {G.C.WHITE}, rotate = 1,shadow = true, bump = true,float=true, scale = 0.9, pop_in = 1.5/G.SPEEDFACTOR, pop_in_rate = 1.5*G.SPEEDFACTOR}

function Card:add_dynatext(top, bottom, delay)
	if self.jen_alreadyhasdynatext then self:remove_dynatext() end
	G.E_MANAGER:add_event(Event({trigger = 'after', delay = delay or 0.4, func = function()
		if top then
			top_dynatext = DynaText(top)
			self.children.jen_topdyna = UIBox{definition = {n = G.UIT.ROOT, config = {align = 'tm', r = 0.15, colour = G.C.CLEAR, padding = 0.15}, nodes = {{n = G.UIT.O, config = {object = top_dynatext}}}},config = {align="tm", offset = {x=0,y=0},parent = self}}
		end
		if bottom then
			bot_dynatext = DynaText(bottom)
			self.children.jen_botdyna = UIBox{definition = {n = G.UIT.ROOT, config = {align = 'tm', r = 0.15, colour = G.C.CLEAR, padding = 0.15}, nodes = {{n = G.UIT.O, config = {object = bot_dynatext}}}},config = {align="bm", offset = {x=0,y=0},parent = self}}
		end
		self.jen_alreadyhasdynatext = true
	return true end }))
end

function Card:remove_dynatext(delay, speed)
	if self.jen_alreadyhasdynatext then
		G.E_MANAGER:add_event(Event({trigger = 'after', delay = delay or 0.5, func = function()
			if self.children.jen_topdyna then
				self.children.jen_topdyna.definition.nodes[1].config.object:pop_out(speed or 4)
			end
			if self.children.jen_botdyna then
				self.children.jen_botdyna.definition.nodes[1].config.object:pop_out(speed or 4)
			end
		return true end }))
		G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.5, func = function()
			if self.children.jen_topdyna then
				self.children.jen_topdyna:remove()
				self.children.jen_topdyna = nil
			end
			if self.children.jen_botdyna then
				self.children.jen_botdyna:remove()
				self.children.jen_botdyna = nil
			end
			self.jen_alreadyhasdynatext = nil
		return true end }))
	end
end

function noretriggers(context)
	return not context.retrigger_joker_check and not context.retrigger_joker
end

for i = 1, Jen.config.ante_polytate do
	Jen.config.blind_scalar[i] = (1 + (Jen.config.scalar_base + (i/Jen.config.scalar_additivedivisor))) ^ (i * Jen.config.scalar_exponent)
end

function Card:spritepos(child, X, Y)
	if self.children[child] then
		if self.children[child].set_sprite_pos then
			self.children[child]:set_sprite_pos({x = X, y = Y})
		end
	end
end

local function batchfind(needle, haystack)
	if type(needle) ~= 'string' then return false end
	if type(haystack) ~= 'table' then return false end
	for k, v in pairs(haystack) do
		if type(v) == 'string' and v == needle then return true end
	end
	return false
end

local function round( num, idp )

	local mult = 10 ^ ( idp or 0 )
	return math.floor( num * mult + 0.5 ) / mult

end

local function in_booster()
	return (
		G.STATE == G.STATES.TAROT_PACK
		or G.STATE == G.STATES.PLANET_PACK
		or G.STATE == G.STATES.SPECTRAL_PACK
		or G.STATE == G.STATES.STANDARD_PACK
		or G.STATE == G.STATES.BUFFOON_PACK
		or G.STATE == G.STATES.SMODS_BOOSTER_OPENED
	)
end

local function bn(number)
	return type(number) == 'table' and number or type(number) == 'number' and Big:create(number) or Big:create(0)
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

function lvupallhands(amnt, card, fast)
	if not amnt then return end
	if amnt == 0 then return end
	if fast then
		update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize('k_all_hands'), chips = (amnt > 0 and '+' or '-'), mult = (amnt > 0 and '+' or '-'), StatusText = true, level=(amnt > 0 and '+' or '-') .. number_format(math.abs(amnt))})
	else
		update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize('k_all_hands'),chips = '...', mult = '...', level=''})
		G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
			play_sound('tarot1')
			card:juice_up(0.8, 0.5)
		return true end }))
		update_hand_text({sound = 'button', volume = 0.7, pitch = 0.9, delay = 0}, {chips = (amnt > 0 and '+' or '-'), mult = (amnt > 0 and '+' or '-'), StatusText = true, level=(amnt > 0 and '+' or '-') .. number_format(math.abs(amnt))})
		delay(1.3)
	end
	for k, v in pairs(G.GAME.hands) do
		level_up_hand(card, k, true, amnt)
	end
	update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
end

function Card:apply_cumulative_levels(hand)
	G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
		G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
			if self then
				if hand and G.GAME.hands[hand] then
					update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(hand, 'poker_hands'),chips = G.GAME.hands[hand].chips, mult = G.GAME.hands[hand].mult, level=G.GAME.hands[hand].level})
					level_up_hand(self, hand, false, (self.cumulative_lvs or 1))
					self.cumulative_lvs = nil
					update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
				else
					lvupallhands(self.cumulative_lvs, self)
					self.cumulative_lvs = nil
				end
			end
		return true end }))
	return true end }))
end

local function change_blind_size(newsize)
	newsize = bn(newsize)
	G.GAME.blind.chips = newsize
	G.E_MANAGER:add_event(Event({func = function()
		G.GAME.blind.chip_text = number_format(newsize)
		local chips_UI = G.hand_text_area.blind_chips
		G.FUNCS.blind_chip_UI_scale(G.hand_text_area.blind_chips)
		G.HUD_blind:recalculate() 
		chips_UI:juice_up()

		play_sound('chips2')
	return true end }))
end

function card_status_text(card, text, xoffset, yoffset, colour, size, delay, juice, jiggle, align, sound, volume, pitch, trig, F)
	if (delay or 0) <= 0 then
		if F and type(F) == 'function' then F(card) end
		attention_text({
			text = text,
			scale = size or 1, 
			hold = 0.7,
			backdrop_colour = colour or (G.C.FILTER),
			align = align or 'bm',
			major = card,
			offset = {x = xoffset or 0, y = yoffset or (-0.05*G.CARD_H)}
		})
		if sound then
			play_sound(sound, pitch or (0.9 + (0.2*math.random())), volume or 1)
		end
		if juice then
			if type(juice) == 'table' then
				card:juice_up(juice[1], juice[2])
			elseif type(juice) == 'number' and juice ~= 0 then
				card:juice_up(juice, juice / 6)
			end
		end
		if jiggle then
			G.ROOM.jiggle = G.ROOM.jiggle + jiggle
		end
	else
		G.E_MANAGER:add_event(Event({
			trigger = trig,
			delay = delay,
			func = function()
				if F and type(F) == 'function' then F(card) end
				attention_text({
					text = text,
					scale = size or 1, 
					hold = 0.7 + (delay or 0),
					backdrop_colour = colour or (G.C.FILTER),
					align = align or 'bm',
					major = card,
					offset = {x = xoffset or 0, y = yoffset or (-0.05*G.CARD_H)}
				})
				if sound then
					play_sound(sound, pitch or (0.9 + (0.2*math.random())), volume or 1)
				end
				if juice then
					if type(juice) == 'table' then
						card:juice_up(juice[1], juice[2])
					elseif type(juice) == 'number' and juice ~= 0 then
						card:juice_up(juice, juice / 6)
					end
				end
				if jiggle then
					G.ROOM.jiggle = G.ROOM.jiggle + jiggle
				end
				return true
			end
		}))
	end
end

local function hasgodsmarble()
	return #SMODS.find_card('j_jen_godsmarble') > 0
end

local function round( num, idp )

	local mult = 10 ^ ( idp or 0 )
	return math.floor( num * mult + 0.5 ) / mult

end

local function deepCopy(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
  
    local s = seen or {}
    local res = {}
    s[obj] = res
    for k, v in pairs(obj) do res[deepCopy(k, s)] = deepCopy(v, s) end
    return setmetatable(res, getmetatable(obj))
end

local function play_sound_q(sound, per, vol)
	G.E_MANAGER:add_event(Event({
		func = function()
			play_sound(sound,per,vol)
			return true
		end
	}))
end

local cacsr = CardArea.change_size
function CardArea:change_size(mod, silent)
	cacsr(self, mod)
	if not silent and (mod or 0) ~= 0 then
		G.E_MANAGER:add_event(Event({
			trigger = 'immediate',
			func = function()
				mod = mod or 0
				local text = 'Max +'
				local col = G.C.GREEN
				if mod < 0 then
					text = 'Max -'
					col = G.C.RED
				end
				attention_text({
					text = text..tostring(math.abs(mod)),
					scale = 1, 
					hold = 1,
					cover = self,
					cover_colour = col,
					align = 'cm',
				})
				play_sound('highlight2', 0.715, 0.2)
				play_sound('generic1')
				return true
			end
		}))
	end
end

function CardArea:change_size_absolute(mod, silent)
	self.config.card_limit = self.config.card_limit + (mod or 0)
	if not silent and (mod or 0) ~= 0 then
		G.E_MANAGER:add_event(Event({
			trigger = 'immediate',
			func = function()
				mod = mod or 0
				local text = 'Max +'
				local col = G.C.GREEN
				if mod < 0 then
					text = 'Max -'
					col = G.C.RED
				end
				attention_text({
					text = text..tostring(math.abs(mod)),
					scale = 1, 
					hold = 1,
					cover = self,
					cover_colour = col,
					align = 'cm',
				})
				play_sound('highlight2', 0.715, 0.2)
				play_sound('generic1')
				return true
			end
		}))
	end
end

function CardArea:change_max_highlight(mod, silent)
	self.config.highlighted_limit = self.config.highlighted_limit + (mod or 0)
	if not silent and (mod or 0) ~= 0 then
		G.E_MANAGER:add_event(Event({
			trigger = 'immediate',
			func = function()
				mod = mod or 0
				local text = 'Highlights +'
				local col = G.C.PURPLE
				if mod < 0 then
					text = 'Highlights -'
					col = G.C.IMPORTANT
				end
				attention_text({
					text = text..tostring(math.abs(mod)),
					scale = 1, 
					hold = 1,
					cover = self,
					cover_colour = col,
					align = 'cm',
				})
				play_sound('highlight2', 0.715, 0.2)
				play_sound('generic1')
				return true
			end
		}))
	end
end

function ease_winante(mod)
	G.E_MANAGER:add_event(Event({
		trigger = 'immediate',
		func = function()
			local ante_UI = G.hand_text_area.ante
			mod = mod or 0
			local text = 'Max +'
			local col = G.C.PURPLE
			if mod < 0 then
				text = 'Max -'
				col = G.C.GREEN
			end
			ante_UI.config.object:update()
			--If this line is written in the apply_to_run function above, the ante to win number will increase before the animation begins
			G.GAME.win_ante=G.GAME.win_ante+mod
			G.HUD:recalculate()
			--Popup text next to the chips in UI showing number of chips gained/lost
			attention_text({
				text = text..tostring(math.abs(mod)),
				scale = 0.6, 
				hold = 0.9,
				cover = ante_UI.parent,
				cover_colour = col,
				align = 'cm',
			})
			--Play a chip sound
			play_sound('highlight2', 0.4, 0.2)
			play_sound('generic1')
			return true
		end
	}))
end

function ease_ante_autoraisewinante(mod)
	local targetante = G.GAME.round_resets.ante + mod
	ease_ante(mod)
	if G.GAME.win_ante < targetante then
		G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.1, func = function()
			ease_winante(targetante - G.GAME.win_ante)
		return true end }))
	end
end

local function multante(number)
	local targetante = math.abs(G.GAME.round_resets.ante * (2 ^ (number or 1)))
	if G.GAME.round_resets.ante < 1 then ease_ante(math.abs(G.GAME.round_resets.ante) + 1) end
	ease_ante(math.min(1e308, G.GAME.round_resets.ante * (2 ^ (number or 1)) - G.GAME.round_resets.ante))
	if G.GAME.win_ante < targetante then
		G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.1, func = function()
			ease_winante(targetante - G.GAME.win_ante)
		return true end }))
	end
end

local function jenRGB(hue, sat, light, red, green, blue, contrast) 
  local r, g, b = 0;
  sat = sat or 0.5
  light = light or 0.75

  if hue < 60 then 
    r = 1; 
    g = sat + (1 - sat) * (hue / 60); 
    b = 1 - sat; 
  elseif hue < 120 then 
    r = sat + (1 - sat) * ((120 - hue) / 60); 
    g = 1; 
    b = 1 - sat;
  elseif hue < 180 then 
    r = 1 - sat; 
    g = 1; 
    b = sat + (1 - sat) * ((hue - 120) / 60);
  elseif hue < 240 then 
    r = 1 - sat; 
    g = sat + (1 - sat) * ((240 - hue) / 60); 
    b = 1;
  elseif hue < 300 then 
    r = sat + (1 - sat) * ((hue - 240) / 60); 
    g = 1 - sat; 
    b = 1;
  else 
    r = 1; 
    g = 1 - sat; 
    b = sat + (1 - sat) * ((360 - hue) / 60); end

  local gray = (0.2989 * r + 0.5870 * g + 0.1140 * b) * (1 - (contrast or 0))

  r = (1 - 0.5) * r + 0.5 * gray
  g = (1 - 0.5) * g + 0.5 * gray
  b = (1 - 0.5) * b + 0.5 * gray

  r = r * light * (red or 1)
  g = g * light * (green or 1)
  b = b * light * (blue or 1)

  return r, g, b
end

local game_updateref = Game.update
function Game:update(dt)
	game_updateref(self, dt)
	if G.ARGS.LOC_COLOURS then

		if not self.C.jen_RGB then
			self.C.jen_RGB = {0,0,0,1}
			self.C.jen_RGB_HUE = 0
		end

		local r, g, b = jenRGB(self.C.jen_RGB_HUE, 0.5, 1, 1.5, 1.5, 1.5, 1)

		self.C.jen_RGB[1] = r
		self.C.jen_RGB[3] = g
		self.C.jen_RGB[2] = b

		self.C.jen_RGB_HUE = (self.C.jen_RGB_HUE + 0.5) % 360
		G.ARGS.LOC_COLOURS['jen_RGB'] = self.C.jen_RGB
		
	end
end

local junk = function(self, card, badges)
	badges[#badges + 1] = create_badge('Junk', G.C.JOKER_GREY, nil, 1)
end

local sevensins = function(self, card, badges)
	badges[#badges + 1] = create_badge('The Seven Sins', HEX('7c0000'), G.C.RED, 1)
end

local twitch = function(self, card, badges)
	badges[#badges + 1] = create_badge('Twitch Series', HEX('9164ff'), G.C.jen_RGB, 1.5)
end

local iconic = function(self, card, badges)
	badges[#badges + 1] = create_badge('Icon Series', HEX('00FF99'), G.C.jen_RGB, 1.5)
end

local gaming = function(self, card, badges)
	badges[#badges + 1] = create_badge('Gaming Legends Series', HEX('7F00FF'), G.C.jen_RGB, 1.5)
end

local ritualistic = function(self, card, badges)
	badges[#badges + 1] = create_badge('Ritualistic', G.C.BLACK, G.C.RED, 1.4)
end

local transcendent = function(self, card, badges)
	badges[#badges + 1] = create_badge('Transcendent', G.C.jen_RGB, G.C.DARK_EDITION, 1.6)
end

local hypertranscendent = function(self, card, badges)
	badges[#badges + 1] = create_badge('Hypertranscendent', G.C.WHITE, G.C.jen_RGB, 3)
end

local omegatranscendent = function(self, card, badges)
	badges[#badges + 1] = create_badge('O M E G A T R A N S C E N D E N T', G.C.BLACK, G.C.jen_RGB, 3.25)
end

local function chance(name, probability, absolute)
	return pseudorandom(name) < (absolute and 1 or G.GAME.probabilities.normal)/probability
end

local function localecolour(name, r,g,b,a)
	local N = 'jen_' .. name
	if not G.ARGS.LOC_COLOURS[N] then
		G.C[N] = type(r) == 'string' and HEX(r) or {r, g, b, a}
		G.ARGS.LOC_COLOURS[N] = type(r) == 'string' and HEX(r) or {r, g, b, a}
	end
	return N
end

--MISCELLANEOUS

local function delay_realtime(time, queue)
    G.E_MANAGER:add_event(Event({
        trigger = 'after',
		timer = 'REAL',
        delay = time or 1,
        func = function()
           return true
        end
    }), queue)
end

local function abletouseconsumables()
	return not (((G.play and #G.play.cards > 0) or (G.CONTROLLER.locked) or (G.GAME.STOP_USE and G.GAME.STOP_USE > 0)) and G.STATE ~= G.STATES.HAND_PLAYED and G.STATE ~= G.STATES.DRAW_TO_HAND and G.STATE ~= G.STATES.PLAY_TAROT)
end

local function abletouseabilities()
	return abletouseconsumables() and not in_booster()
end

local function scoringcard(context)
	return context.cardarea and context.cardarea == G.play and not context.before and not context.after and not context.repetition
end

function get_favourite_hand()
	local chosen_hand = 'High Card'
	local highest_played = 0
	for _, v in ipairs(G.handlist) do
		if G.GAME.hands[v].played > highest_played then
			chosen_hand = v
			highest_played = G.GAME.hands[v].played
		end
	end
	return chosen_hand
end

function get_lowest_level_hand()
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

function get_random_hand(ignore, seed, allowhidden)
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

--CONSUMABLE TYPES

SMODS.ConsumableType {
	key = 'jen_tokens',
	collection_rows = {6, 6},
	primary_colour = G.C.CHIPS,
	secondary_colour = G.C.VOUCHER,
	loc_txt = {
		collection = 'Tokens',
		name = 'Token'
	},
	shop_rate = 3
}

SMODS.ConsumableType {
	key = 'jen_jokerability',
	collection_rows = {4, 4},
	primary_colour = G.C.CHIPS,
	secondary_colour = G.C.GREEN,
	loc_txt = {
		collection = 'Joker Abilities',
		name = 'Joker Ability'
	},
	shop_rate = 0
}

SMODS.ConsumableType {
	key = 'jen_exconsumable',
	collection_rows = {4, 5},
	primary_colour = G.C.CHIPS,
	secondary_colour = G.C.BLACK,
	loc_txt = {
		collection = 'EX Consumables',
		name = 'EX Consumable'
	},
	shop_rate = 0
}

--SOUNDS

SMODS.Sound({key = 'e_crystal', path = 'e_crystal.ogg'})
SMODS.Sound({key = 'megatrigger', path = 'megatrigger.ogg'})
SMODS.Sound({key = 'grindstone', path = 'grindstone.ogg'})
SMODS.Sound({key = 'metalhit', path = 'metal_hit.ogg'})
SMODS.Sound({key = 'enlightened', path = 'enlightened.ogg'})
SMODS.Sound({key = 'excard', path = 'ex_card.ogg'})
for i = 1, 2 do
	SMODS.Sound({key = 'metalbreak' .. i, path = 'metal_break' .. i .. '.ogg'})
	SMODS.Sound({key = 'ambientDramatic' .. i, path = 'ambientDramatic' .. i .. '.ogg'})
end
for i = 1, 3 do
	SMODS.Sound({key = 'crystalhit' .. i, path = 'crystal_hit' .. i .. '.ogg'})
	SMODS.Sound({key = 'hurt' .. i, path = 'hurt' .. i .. '.ogg'})
	SMODS.Sound({key = 'ambientSurreal' .. i, path = 'ambientSurreal' .. i .. '.ogg'})
end
for i = 1, 4 do
	SMODS.Sound({key = 'boost' .. i, path = 'boost' .. i .. '.ogg'})
end
SMODS.Sound({key = 'crystalbreak', path = 'crystal_break.ogg'})
SMODS.Sound({key = 'wererich', path = 'wererich.ogg'})
SMODS.Sound({key = 'heartbeat', path = 'warning_heartbeat.ogg'})
for i = 1, 5 do
	SMODS.Sound({key = 'collapse' .. i, path = 'collapse_' .. i .. '.ogg'})
end

--EDITION ASSETS

local shaders = {
	'chromatic',
	'gilded',
	'laminated',
	'reversed',
	'sepia',
	'wavy',
	'dithered',
	'watered',
	'sharpened',
	'missingtexture',
	'prismatic',
	'polygloss',
	'noisy',
	'ink',
	'strobe',
	'sequin',
	'blaze',
	'encoded',
	'misprint',
	'wee',
	--'graymatter',
	--'hardstone',
	--'bedrock',
	'ionized',
	'diplopia',
	'moire'
}

local shaders2 = {
	'bloodfoil',
	'cosmic'
}

for k, v in pairs(shaders) do
	SMODS.Shader({key = v, path = v .. '.fs'})
	SMODS.Sound({key = 'e_' .. v, path = 'e_' .. v .. '.ogg'})
end

for k, v in pairs(shaders2) do
	SMODS.Shader({key = v, path = v .. '.fs'})
end

--EDITIONS

SMODS.Edition({
    key = "prismatic",
    loc_txt = {
        name = "Prismatic",
        label = "Prismatic",
        text = {
            "{X:mult,C:white}x#1#{C:mult} Mult{}, {X:chips,C:white}x#2#{C:chips} Chips{}",
			'and {C:money}+$#3#{} when scored',
			'{C:dark_edition,s:0.7,E:2}Shader by : knockback1{}'
        }
    },
    shader = "prismatic",
    discovered = true,
    unlocked = true,
    config = {x_mult = 15, x_chips = 5, p_dollars = 5},
	sound = {
		sound = 'jen_e_prismatic',
		per = 1.2,
		vol = 0.5
	},
    in_shop = true,
    weight = 0.2,
    extra_cost = 12,
    apply_to_float = false,
	get_weight = function(self)
        return G.GAME.edition_rate * self.weight
    end,
    loc_vars = function(self)
        return { vars = { self.config.x_mult, self.config.x_chips, self.config.p_dollars } }
    end
})

SMODS.Edition({
    key = "ionized",
    loc_txt = {
        name = "Ionised",
        label = "Ionised",
        text = {
            "{C:blue}+#1# Chips{}, {C:red,s:1.2}BUT{}",
			"{X:red,C:white}x#2#{C:red} Mult{}",
			'{C:dark_edition,s:0.7,E:2}Shader by : knockback1{}'
        }
    },
    shader = "ionized",
    discovered = true,
    unlocked = true,
    config = {chips = 2000, x_mult = 0.5},
	sound = {
		sound = 'jen_e_ionized',
		per = 1,
		vol = 0.5
	},
    in_shop = true,
    weight = 3,
    extra_cost = 7,
    apply_to_float = false,
	get_weight = function(self)
        return G.GAME.edition_rate * self.weight
    end,
    loc_vars = function(self)
        return { vars = { self.config.chips, self.config.x_mult } }
    end
})

SMODS.Edition({
    key = "misprint",
    loc_txt = {
        name = "Misprint",
        label = "Misprint",
        text = {
			"{C:red,E:1,s:1.2}Rare Edition{}",
			" ",
            "Card has {C:attention}unknown, random bonus values{}",
            '{C:inactive}({C:purple}+{C:inactive}, {X:purple,C:white}x{C:inactive}, and {X:purple,C:dark_edition}^{C:inactive} Chips and/or Mult){}',
			'{C:dark_edition,s:0.7,E:2}Shader by : stupxd{}'
        }
    },
    shader = "misprint",
	override_base_shader = true,
	no_shadow = true,
    discovered = true,
    unlocked = true,
    config = {},
	sound = {
		sound = 'jen_e_misprint',
		per = 1,
		vol = 0.5
	},
    in_shop = true,
    weight = 1.5,
    extra_cost = 8,
    apply_to_float = false,
	get_weight = function(self)
        return G.GAME.edition_rate * self.weight
    end,
})

SMODS.Edition({
    key = "wee",
    loc_txt = {
        name = "Wee",
        label = "Wee",
        text = {
			"{C:red,E:1,s:1.2}Rare Edition{}",
			" ",
            "Values of card {C:attention}increase by 8%{}",
            'whenever a {C:attention}2{} scores',
			'{C:inactive}(If possible){}',
			' ',
			"{C:inactive,E:1,s:0.7}Haha, look; it's tiny!{}"
        }
    },
    shader = 'wee',
    discovered = true,
    unlocked = true,
    config = {twos_scored = 0},
	sound = {
		sound = 'jen_e_wee',
		per = 1,
		vol = 0.5
	},
    in_shop = true,
    weight = 2,
    extra_cost = 15,
    apply_to_float = false,
	get_weight = function(self)
        return G.GAME.edition_rate * self.weight
    end,
})

SMODS.Edition({
    key = "blaze",
    loc_txt = {
        name = "Blaze",
        label = "Blaze",
        text = {
			'Retrigger this card {C:attention}#1#{} time(s), {C:red,s:1.2}BUT{}',
            "{C:red}#2#{C:chips} Chips{} and {C:red}#3#{C:mult} Mult",
			'{C:dark_edition,s:0.7,E:2}Shader by : stupxd{}'
        }
    },
    shader = "blaze",
    discovered = true,
    unlocked = true,
    config = {retriggers = 5, chips = -5, mult = -1},
	sound = {
		sound = 'jen_e_blaze',
		per = 1,
		vol = 0.5
	},
    in_shop = true,
    weight = 5,
    extra_cost = 7,
    apply_to_float = false,
	get_weight = function(self)
        return G.GAME.edition_rate * self.weight
    end,
    loc_vars = function(self)
        return { vars = { self.config.retriggers, self.config.chips, self.config.mult } }
    end
})

SMODS.Edition({
    key = "wavy",
    loc_txt = {
        name = "Wavy",
        label = "Wavy",
        text = {
			"{C:red,E:1,s:1.2}Rare Edition{}",
			" ",
			'Retrigger this card {C:attention}#1#{} time(s)',
			'{C:dark_edition,s:0.7,E:2}Shader by : stupxd{}'
        }
    },
    shader = "wavy",
	override_base_shader = true,
	no_shadow = true,
    discovered = true,
    unlocked = true,
    config = {retriggers = 30},
	sound = {
		sound = 'jen_e_wavy',
		per = 1,
		vol = 0.5
	},
    in_shop = true,
    weight = 1,
    extra_cost = 13,
    apply_to_float = false,
	get_weight = function(self)
        return G.GAME.edition_rate * self.weight
    end,
    loc_vars = function(self)
        return { vars = { self.config.retriggers } }
    end
})

SMODS.Edition({
    key = "encoded",
    loc_txt = {
        name = "Encoded",
        label = "Encoded",
        text = {
			"{C:red,E:1,s:1.2}Rare Edition{}",
			" ",
			'Creates {C:attention}#1# {C:cry_code}Code{} cards when dissolved',
			'{C:inactive}(Does not require room, but may overflow){}',
			'{C:dark_edition,s:0.7,E:2}Shader by : knockback1{}'
        }
    },
    shader = "encoded",
    discovered = true,
    unlocked = true,
    config = {codes = 10},
	sound = {
		sound = 'jen_e_encoded',
		per = 1,
		vol = 0.5
	},
    in_shop = true,
    weight = 1,
    extra_cost = 9,
    apply_to_float = false,
	get_weight = function(self)
        return G.GAME.edition_rate * self.weight
    end,
    loc_vars = function(self)
        return { vars = { self.config.codes } }
    end
})

SMODS.Edition({
    key = "diplopia",
    loc_txt = {
        name = "Diplopia",
        label = "Diplopia",
        text = {
			'Retrigger this card {C:attention}#1#{} time(s)',
			'{C:attention}Resists{} being dissolved {C:attention}once{}, after which',
			'this edition is then removed from the card',
			"{C:inactive}I'm... seeing... double...!{}",
			'{C:dark_edition,s:0.7,E:2}Shader by : knockback1{}'
        }
    },
    shader = "diplopia",
    discovered = true,
    unlocked = true,
    config = {retriggers = 1},
	sound = {
		sound = 'jen_e_diplopia',
		per = 1,
		vol = 0.8
	},
    in_shop = true,
    weight = 3,
    extra_cost = 7,
    apply_to_float = true,
	get_weight = function(self)
        return G.GAME.edition_rate * self.weight
    end,
    loc_vars = function(self)
        return { vars = { self.config.retriggers } }
    end
})

SMODS.Edition({
    key = "sequin",
    loc_txt = {
        name = "Sequin",
        label = "Sequin",
        text = {
            "{C:chips}+#1#{} Chips",
            "{C:red}+#2#{} Mult",
			"{C:money}Sell value{} is {X:green,C:white}3x{} the {C:attention}buy value{}",
			"{C:money}Sell value{} is always at least {C:money}$6{} minimum",
			'{C:dark_edition,s:0.7,E:2}Shader by : knockback1{}'
        }
    },
    discovered = true,
    unlocked = true,
    shader = 'sequin',
    config = { chips = 25, mult = 2 },
	sound = {
		sound = 'jen_e_sequin',
		per = 1,
		vol = 0.4
	},
    in_shop = true,
    weight = 3,
    extra_cost = 0,
    apply_to_float = false,
	get_weight = function(self)
        return G.GAME.edition_rate * self.weight
    end,
    loc_vars = function(self)
        return { vars = {self.config.chips, self.config.mult}}
    end
})

local scr = Card.set_cost
function Card:set_cost()
	scr(self)
	if (self.edition or {}).jen_crystal then
		self.cost = 1
		self.sell_cost = 1
		self.sell_cost_label = self.facing == 'back' and '?' or self.sell_cost
	end
	if (self.edition or {}).jen_sequin then
		self.sell_cost = self.sell_cost * 6
		self.sell_cost_label = self.facing == 'back' and '?' or self.sell_cost
	end
end

SMODS.Edition({
    key = "laminated",
    loc_txt = {
        name = "Laminated",
        label = "Laminated",
        text = {
            "{C:blue}+#1# Chips{}, {C:red}+#2# Mult{}",
			"Card costs and sells for",
			"{C:purple}significantly less value{}"
        }
    },
    shader = "laminated",
    discovered = true,
    unlocked = true,
    config = {chips = 3, mult = 1},
	sound = {
		sound = 'jen_e_laminated',
		per = 1,
		vol = 0.4
	},
    in_shop = true,
    weight = 8,
    extra_cost = -5,
    apply_to_float = false,
	get_weight = function(self)
        return G.GAME.edition_rate * self.weight
    end,
    loc_vars = function(self)
        return { vars = { self.config.chips, self.config.mult } }
    end
})

SMODS.Edition({
    key = "crystal",
    loc_txt = {
        name = "Crystal",
        label = "Crystal",
        text = {
            "{C:chips}+#1# Chips{}",
			"Card costs and sells for {C:money}$1{}"
        }
    },
    shader = "laminated",
    discovered = true,
    unlocked = true,
	override_base_shader = true,
	no_shadow = true,
    config = {chips = 111},
	sound = {
		sound = 'jen_e_crystal',
		per = 1,
		vol = 0.4
	},
    in_shop = true,
    weight = 4,
    extra_cost = 0,
    apply_to_float = false,
	get_weight = function(self)
        return G.GAME.edition_rate * self.weight
    end,
    loc_vars = function(self)
        return { vars = { self.config.chips } }
    end
})

SMODS.Edition({
    key = "sepia",
    loc_txt = {
        name = "Sepia",
        label = "Sepia",
        text = {
            "{C:blue}+#1# Chips{}, {C:red}+#2# Mult{}",
            "Card costs and sells for",
			"{C:money}significantly more value{}",
			'{C:dark_edition,s:0.7,E:2}Shader by : stupxd{}'
        }
    },
    shader = "sepia",
    discovered = true,
    unlocked = true,
    config = {chips = 150, mult = 9},
	sound = {
		sound = 'jen_e_sepia',
		per = 1,
		vol = 0.5
	},
    in_shop = true,
    weight = 6,
    extra_cost = 20,
	get_weight = function(self)
        return G.GAME.edition_rate * self.weight
    end,
    apply_to_float = false,
    loc_vars = function(self)
        return { vars = { self.config.chips, self.config.mult } }
    end
})

SMODS.Edition({
    key = "ink",
    loc_txt = {
        name = "Ink",
        label = "Ink",
        text = {
            "{C:chips}+#1# Chips{}, {C:mult}+#2# Mult{}",
            "and {X:mult,C:white}X#3#{C:red} Mult{}",
			'{C:dark_edition,s:0.7,E:2}Shader by : knockback1{}'
        }
    },
    shader = "ink",
    discovered = true,
    unlocked = true,
    config = { chips = 200, mult = 10, x_mult = 2 },
	sound = {
		sound = 'jen_e_ink',
		per = 1.2,
		vol = 0.4
	},
    in_shop = true,
    weight = 4,
    extra_cost = 7,
    apply_to_float = false,
	get_weight = function(self)
        return G.GAME.edition_rate * self.weight
    end,
    loc_vars = function(self)
        return { vars = { self.config.chips, self.config.mult, self.config.x_mult } }
    end
})

SMODS.Edition({
    key = "polygloss",
    loc_txt = {
        name = "Polygloss",
        label = "Polygloss",
        text = {
            "{C:money}+$#1#{} when this",
            "card is scored",
			'{C:dark_edition,s:0.7,E:2}Shader by : knockback1{}'
        }
    },
    discovered = true,
    unlocked = true,
    shader = 'polygloss',
    config = { p_dollars = 3 },
    in_shop = true,
    weight = 8,
	sound = {
		sound = 'jen_e_polygloss',
		per = 1.2,
		vol = 0.4
	},
    extra_cost = 4,
    apply_to_float = false,
    loc_vars = function(self)
        return { vars = {self.config.p_dollars}}
    end
})

SMODS.Edition({
    key = "gilded",
    loc_txt = {
        name = "Gilded",
        label = "Gilded",
        text = {
			"{C:red,E:1,s:1.2}Rare Edition{}",
			" ",
            "Earns {C:money}$#1#{} when this",
            "card is scored",
			"Card has an {C:red}EXTREME{C:money} buy & sell value{}",
			'{C:dark_edition,s:0.7,E:2}Shader by : knockback1{}'
        }
    },
    discovered = true,
    unlocked = true,
    shader = 'gilded',
    config = { p_dollars = 20 },
    in_shop = true,
    weight = 2,
	sound = {
		sound = 'jen_e_gilded',
		per = 1,
		vol = 0.4
	},
    extra_cost = 200,
    apply_to_float = false,
    loc_vars = function(self)
        return { vars = {self.config.p_dollars}}
    end
})

SMODS.Edition({
    key = "chromatic",
    loc_txt = {
        name = "Chromatic",
        label = "Chromatic",
        text = {
            "{C:chips}+#1# Chips{}",
            "{C:mult}+#2# Mult{}",
			'{C:dark_edition,s:0.7,E:2}Shader by : stupxd{}'
        }
    },
    discovered = true,
    unlocked = true,
    shader = 'chromatic',
    config = { chips = 10, mult = 4 },
	sound = {
		sound = 'jen_e_chromatic',
		per = 1,
		vol = 0.5
	},
    in_shop = true,
    weight = 8,
    extra_cost = 4,
    apply_to_float = false,
    loc_vars = function(self)
        return { vars = {self.config.chips, self.config.mult}}
    end
})

SMODS.Edition({
    key = "watered",
    loc_txt = {
        name = "Watercoloured",
        label = "Watercoloured",
        text = {
            "Retrigger this card {C:attention}#1#{} times",
			'{C:dark_edition,s:0.7,E:2}Shader by : stupxd{}'
        }
    },
    discovered = true,
    unlocked = true,
    shader = 'watered',
    config = { retriggers = 2 },
	sound = {
		sound = 'jen_e_watered',
		per = 1,
		vol = 0.4
	},
    in_shop = true,
    weight = 8,
    extra_cost = 4,
    apply_to_float = false,
    loc_vars = function(self)
        return {vars = {self.config.retriggers}}
    end
})

local random_consumabletypes = {
	'Planet',
	'Tarot',
	'Spectral'
}

--dithered effect is currently placeholder until i can figure out how to make it spawn consumables on scoring

SMODS.Edition({
    key = "dithered",
    loc_txt = {
        name = "Dithered",
        label = "Dithered",
        text = {
            "{C:red}#1#{} Chips",
            "{C:mult}+#2#{} Mult",
			'{C:dark_edition,s:0.7,E:2}Shader by : stupxd{}'
        }
    },
    discovered = true,
    unlocked = true,
    shader = 'dithered',
    config = {chips = -50, mult = 33},
	sound = {
		sound = 'jen_e_dithered',
		per = 1,
		vol = 0.6
	},
    in_shop = true,
    weight = 8,
    extra_cost = 2,
    apply_to_float = false,
    loc_vars = function(self)
        return {vars = {self.config.chips, self.config.mult}}
    end
})

SMODS.Edition({
    key = "sharpened",
    loc_txt = {
        name = "Sharpened",
        label = "Sharpened",
        text = {
            "{C:chips}+#1#{} Chips",
            "{C:red}#2#{} Mult",
			'{C:dark_edition,s:0.7,E:2}Shader by : stupxd{}'
        }
    },
    discovered = true,
    unlocked = true,
    shader = 'sharpened',
    config = {chips = 333, mult = -25},
	sound = {
		sound = 'jen_e_sharpened',
		per = 1.2,
		vol = 0.6
	},
    in_shop = true,
    weight = 8,
    extra_cost = 2,
    apply_to_float = false,
    loc_vars = function(self)
        return {vars = {self.config.chips, self.config.mult}}
    end
})

SMODS.Edition({
    key = "reversed",
    loc_txt = {
        name = "Reversed",
        label = "Reversed",
        text = {
            '{C:chips}+#1#{} and {X:chips,C:white}x#2#{C:chips} Chips{},',
            '{C:mult}+#3#{} and {X:mult,C:white}x#4#{C:mult} Mult{}',
			'{C:dark_edition,s:0.7,E:2}Shader by : stupxd{}'
        }
    },
    discovered = true,
    unlocked = true,
	override_base_shader = true,
	no_shadow = true,
    shader = 'reversed',
    config = { chips = 300, x_chips = 3, mult = 300, x_mult = 3 },
	sound = {
		sound = 'jen_e_reversed',
		per = 1,
		vol = 0.4
	},
    in_shop = true,
    weight = 0.1,
    extra_cost = 7,
    apply_to_float = false,
    loc_vars = function(self)
        return { vars = { self.config.chips, self.config.x_chips, self.config.mult, self.config.x_mult } }
    end
})

SMODS.Edition({
    key = "missingtexture",
    loc_txt = {
        name = "Missing Textures",
        label = "Missing Textures",
        text = {
            "{X:red,C:white}x#1#{C:red} Mult{}, {C:red,s:1.2}BUT{}",
			"{C:red}lose {C:money}$#2#{} when scored",
			'{C:inactive,S:0.7}Someone forgot to install Counter-Strike: Source...{}',
			'{C:dark_edition,s:0.7,E:2}Shader by : stupxd{}'
        }
    },
    discovered = true,
    unlocked = true,
    shader = 'missingtexture',
    config = { x_mult = 25, p_dollars = -5 },
	sound = {
		sound = 'jen_e_missingtexture',
		per = 1,
		vol = 0.6
	},
    in_shop = true,
    weight = 3,
    extra_cost = 7,
    apply_to_float = false,
    loc_vars = function(self)
        return { vars = { self.config.x_mult, math.abs(self.config.p_dollars) } }
    end
})

SMODS.Edition({
    key = "bloodfoil",
    loc_txt = {
        name = "Bloodfoil",
        label = "Bloodfoil",
        text = {
			"{C:cry_exotic,E:1,s:1.2}Exotic Edition{}",
			" ",
            "{X:jen_RGB,C:white,s:1.5}^^#1#{C:chips} Chips"
        }
    },
    shader = "bloodfoil",
    discovered = true,
    unlocked = true,
    config = {ee_chips = 1.2},
	sound = {
		sound = 'negative',
		per = 0.5,
		vol = 1
	},
    weight = 0.04,
    extra_cost = 30,
    apply_to_float = false,
	get_weight = function(self)
        return G.GAME.edition_rate * self.weight
    end,
    loc_vars = function(self)
        return { vars = { self.config.ee_chips } }
    end
})

SMODS.Edition({
    key = "blood",
    loc_txt = {
        name = "Blood",
        label = "Blood",
        text = {
			"{C:cry_exotic,E:1,s:1.2}Exotic Edition{}",
			" ",
            "{X:jen_RGB,C:white,s:1.5}^^#1#{C:mult} Mult",
			'{C:dark_edition,s:0.7,E:2}Shader by : knockback1{}'
        }
    },
    shader = "cosmic",
    discovered = true,
    unlocked = true,
    config = {ee_mult = 1.2},
	sound = {
		sound = 'negative',
		per = 0.5,
		vol = 1
	},
    weight = 0.04,
    extra_cost = 30,
    apply_to_float = false,
	get_weight = function(self)
        return G.GAME.edition_rate * self.weight
    end,
    loc_vars = function(self)
        return { vars = { self.config.ee_mult } }
    end
})

SMODS.Edition({
    key = "moire",
    loc_txt = {
        name = "Moire",
        label = "Moire",
        text = {
            '{C:jen_RGB,s:2,E:1}Wondrous Edition{}',
			' ',
            '{C:chips}+#1#{}, {X:chips,C:white}x#2#{}, {X:dark_edition,C:chips}^#3#{}, {X:jen_RGB,C:white,s:1.5}^^#4#{}, and {X:black,C:red}^^^#5#{C:chips} Chips',
            '{C:mult}+#1#{}, {X:mult,C:white}x#2#{}, {X:dark_edition,C:mult}^#3#{}, {X:jen_RGB,C:white,s:1.5}^^#4#{}, and {X:black,C:red}^^^#5#{C:mult} Mult',
			'{C:dark_edition,s:0.7,E:2}Shader by : knockback1{}'
        }
    },
    discovered = true,
    unlocked = true,
    shader = 'moire',
    config = { chips = math.pi*1e4, x_chips = math.pi*1e3, e_chips = math.pi*100, ee_chips = math.pi*10, eee_chips = math.pi, mult = math.pi*1e4, x_mult = math.pi*1e3, e_mult = math.pi*100, ee_mult = math.pi*10, eee_mult = math.pi },
	sound = {
		sound = 'jen_e_moire',
		per = 1,
		vol = 0.4
	},
    in_shop = true,
    weight = 0.01,
    extra_cost = math.pi*1e3,
    apply_to_float = false,
    loc_vars = function(self)
        return { vars = { self.config.chips, self.config.x_chips, self.config.e_chips, self.config.ee_chips, self.config.eee_chips, self.config.mult, self.config.x_mult, self.config.e_mult, self.config.ee_mult, self.config.eee_mult } }
    end
})

local cs = Card.calculate_seal
function Card:calculate_seal(context)
	cs(self, context)
	if context.repetition and ((self.ability or {}).set or 'Joker') ~= 'Joker' then
		if self.edition then
			if self.edition.retriggers then
				return {
					message = localize('k_again_ex'),
					repetitions = self.edition.retriggers,
					card = self
				}
			end
		end
	end
end

--JOKER ATLASES
local atlases = {
	'rai',
	'jess',
	'spice',
	'kosmos',
	'lambert',
	'leshy',
	'heket',
	'kallamar',
	'shamura',
	'narinder',
	'clauneck',
	'kudaai',
	'chemach',
	'haro',
	'suzaku',
	'ayanami',
	'jen',
	'math',
	'rangers',
	'peppino',
	'noise',
	'doomguy',
	'freddy',
	'poppin',
	'godsmarble',
	'pawn',
	'knight',
	'jester',
	'arachnid',
	'reign',
	'feline',
	'fateeater',
	'foundry',
	'broken',
	'wondergeist',
	'wondergeist2',
	'survivor',
	'monk',
	'hunter',
	'spearmaster',
	'artificer',
	'saint',
	'gourmand',
	'rivulet',
	'rot',
	'guilduryn',
	'hydrangea',
	'heisei',
	'soryu',
	'shikigami',
	'leviathan',
	'behemoth',
	'inferno',
	'alexandra',
	'arin',
	'kyle',
	'johnny',
	'murphy',
	'luke',
	'7granddad',
	'aster',
	'landa',
	'bulwark',
	'urizyth',
	'vacuum',
	'nyx',
	'paragon',
	'jimbo',
	'betmma',
	'areyoufrightenedofthismodyet'
}

for k, v in pairs(atlases) do
	SMODS.Atlas {
		key = 'jen' .. v,
		px = 71,
		py = 95,
		path = 'j_jen_' .. v .. '.png'
	}
end

--MISCELLANEOUS ATLASES

SMODS.Atlas {
	key = 'jenfreddy_c',
	px = 71,
	py = 95,
	path = 'c_jen_freddy.png'
}
SMODS.Atlas {
	key = 'jenartificer_c',
	px = 71,
	py = 95,
	path = 'c_jen_artificer.png'
}
SMODS.Atlas {
	key = 'jenfateeater_c',
	px = 71,
	py = 95,
	path = 'c_jen_fateeater.png'
}
SMODS.Atlas {
	key = 'jenfoundry_c',
	px = 71,
	py = 95,
	path = 'c_jen_foundry.png'
}
SMODS.Atlas {
	key = 'jenbroken_c',
	px = 71,
	py = 95,
	path = 'c_jen_broken.png'
}

SMODS.Atlas {
	key = 'jenhoxxes',
	px = 71,
	py = 95,
	path = 'c_jen_hoxxes.png'
}

SMODS.Atlas {
	key = 'jenrtarots',
	px = 71,
	py = 95,
	path = 'c_jen_reversetarots.png'
}

SMODS.Atlas {
	key = 'jenacc',
	px = 71,
	py = 95,
	path = 'c_jen_acc.png'
}

SMODS.Atlas {
	key = 'jentokens',
	px = 71,
	py = 95,
	path = 'c_jen_tokens.png'
}

SMODS.Atlas {
	key = 'jenenhance',
	px = 71,
	py = 95,
	path = 'm_jen_enhancements.png'
}

SMODS.Atlas {
	key = 'jenexplanets',
	px = 71,
	py = 95,
	path = 'c_jen_explanets.png'
}

SMODS.Atlas {
	key = 'jenexspectrals',
	px = 71,
	py = 95,
	path = 'c_jen_exspectrals.png'
}

SMODS.Atlas {
	key = 'jenextarots',
	px = 71,
	py = 95,
	path = 'c_jen_extarots.png'
}

local csdr = Card.set_debuff

function Card:set_debuff(should_debuff)
	if self.ability.perishable then
		if not self.ability.perish_tally then self.ability.perish_tally = 5 end
	end
	csdr(self, should_debuff)
end

--ENHANCEMENTS

SMODS.Enhancement {
	key = 'astro',
	loc_txt = {
		name = 'Astro Card',
		text = {
			'When scored, create a random {C:planet}Planet{} card',
			'{C:inactive}(Must have room){}'
		}
	},
	pos = { x = 0, y = 0 },
	unlocked = true,
	discovered = true,
	atlas = 'jenenhance',
	calculate = function(self, card, context, effect)
		if scoringcard(context) then
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
				if G.consumeables.config.card_limit > #G.consumeables.cards then
					local card2 = create_card('Planet', G.consumeables, nil, nil, nil, nil, nil, 'astro_card')
					card2:add_to_deck()
					G.consumeables:emplace(card2)
				end
				return true
			end }))
		end
	end
}

SMODS.Enhancement {
	key = 'xchip',
	loc_txt = {
		name = 'Multichip Card',
		text = {
			'{X:chips,C:white}x#1#{} Chips'
		}
	},
	config = {Xchips = 1.5},
	pos = { x = 1, y = 0 },
	unlocked = true,
	discovered = true,
	atlas = 'jenenhance',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.Xchips}}
    end
}

SMODS.Enhancement {
	key = 'echip',
	loc_txt = {
		name = 'Powerchip Card',
		text = {
			'{X:chips,C:dark_edition}^#1#{} Chips'
		}
	},
	config = {Echips = 1.09},
	pos = { x = 2, y = 0 },
	unlocked = true,
	discovered = true,
	atlas = 'jenenhance',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.Echips}}
    end
}

SMODS.Enhancement {
	key = 'xmult',
	loc_txt = {
		name = 'Multimult Card',
		text = {
			'{X:mult,C:white}x#1#{} Mult'
		}
	},
	config = {Xmult = 2},
	pos = { x = 3, y = 0 },
	unlocked = true,
	discovered = true,
	atlas = 'jenenhance',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.Xmult}}
    end
}

SMODS.Enhancement {
	key = 'emult',
	loc_txt = {
		name = 'Powermult Card',
		text = {
			'{X:mult,C:dark_edition}^#1#{} Mult'
		}
	},
	config = {Emult = 1.13},
	pos = { x = 5, y = 0 },
	unlocked = true,
	discovered = true,
	atlas = 'jenenhance',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.Emult}}
    end
}

SMODS.Enhancement {
	key = 'power',
	loc_txt = {
		name = 'Supercharged Card',
		text = {
			'{X:chips,C:white}x#1#{} Chips',
			'{X:mult,C:white}x#2#{} Mult',
			'{X:chips,C:dark_edition}^#3#{} Chips',
			'{X:mult,C:dark_edition}^#4#{} Mult'
		}
	},
	config = {Xchips = 1.25, Xmult = 1.5, Echips = 1.08, Emult = 1.11},
	pos = { x = 4, y = 0 },
	unlocked = true,
	discovered = true,
	atlas = 'jenenhance',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.Xchips, center.ability.Xmult, center.ability.Echips, center.ability.Emult}}
    end
}

SMODS.Enhancement {
	key = 'surreal',
	loc_txt = {
		name = 'Surreal Card',
		text = {
			'{C:attention}Ignores{} card selection limit',
			'{C:inactive}(e.g. can be used to play 6+ cards){}'
		}
	},
	pos = { x = 6, y = 1 },
	unlocked = true,
	discovered = true,
	atlas = 'jenenhance',
}

local function faceinplay()
	if not G.play then return 0 end
	if not G.play.cards then return 0 end
	local qty = 0
	for k, v in pairs(G.play.cards) do
		if v:is_face() then qty = qty + 1 end
	end
	return qty
end

--[[

SMODS.Enhancement {
	key = 'canios',
	loc_txt = {
		name = "Canio's Card",
		text = {
			'{X:mult,C:white}x#1#{} Mult per',
			'{C:attention}face card{} in played hand'
		}
	},
	config = {extra = {mod = 1.5}},
	pos = { x = 0, y = 1 },
	unlocked = true,
	discovered = true,
	atlas = 'jenenhance',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.mod}}
    end,
	calculate = function(self, card, context, effect)
		card.ability.Xmult = (card.ability.extra.mod ^ faceinplay())
	end
}

local function faceinhand()
	if not G.hand then return 0 end
	if not G.hand.cards then return 0 end
	local qty = 0
	for k, v in pairs(G.hand.cards) do
		if v:is_face() then qty = qty + 1 end
	end
	return qty
end

SMODS.Enhancement {
	key = 'triboulet',
	loc_txt = {
		name = "Triboulet's Card",
		text = {
			'{X:mult,C:white}x#1#{} Mult per',
			'{C:attention}King or Queen{} held in hand'
		}
	},
	config = {extra = {mod = 3}},
	pos = { x = 1, y = 1 },
	unlocked = true,
	discovered = true,
	atlas = 'jenenhance',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.mod}}
    end,
	calculate = function(self, card, context, effect)
		card.ability.Xmult = (card.ability.extra.mod ^ faceinplay())
	end
}

]]

SMODS.Enhancement {
	key = 'fortune',
	loc_txt = {
		name = 'Fortune Card',
		text = {
			'When scored, create a {C:tarot}Tarot{} card',
			'{C:inactive}(Must have room){}'
		}
	},
	pos = { x = 6, y = 0 },
	atlas = 'jenenhance',
	unlocked = true,
	discovered = true,
	calculate = function(self, card, context, effect)
		if scoringcard(context) then
			G.E_MANAGER:add_event(Event({trigger = 'after', func = function()
				if G.consumeables.config.card_limit > #G.consumeables.cards then
					local card2 = create_card('Tarot', G.consumeables, nil, nil, nil, nil, nil, 'fortune_card')
					card2:add_to_deck()
					G.consumeables:emplace(card2)
				end
				return true
			end }))
		end
	end
}

SMODS.Enhancement {
	key = 'osmium',
	loc_txt = {
		name = 'Osmium Card',
		text = {
			'When scored, create a {C:spectral}Spectral{} card',
			'{C:inactive}(Must have room){}'
		}
	},
	pos = { x = 8, y = 0 },
	atlas = 'jenenhance',
	unlocked = true,
	discovered = true,
	calculate = function(self, card, context, effect)
		if scoringcard(context) then
			G.E_MANAGER:add_event(Event({trigger = 'after', func = function()
				if G.consumeables.config.card_limit > #G.consumeables.cards then
					local card2 = create_card('Spectral', G.consumeables, nil, nil, nil, nil, nil, 'osmium_card')
					card2:add_to_deck()
					G.consumeables:emplace(card2)
				end
				return true
			end }))
		end
	end
}

SMODS.Enhancement {
	key = 'fizzy',
	loc_txt = {
		name = 'Fizzy Card',
		text = {
			'Creates a {C:attention}Double Tag{} when scored'
		}
	},
	pos = { x = 8, y = 1 },
	atlas = 'jenenhance',
	unlocked = true,
	discovered = true,
	calculate = function(self, card, context, effect)
		if scoringcard(context) then
			G.E_MANAGER:add_event(Event({trigger = 'after', func = function()
				add_tag(Tag('tag_double'))
				return true
			end }))
		end
	end
}

SMODS.Enhancement {
	key = 'blue',
	loc_txt = {
		name = 'Blue Card',
		text = {
			'{C:green}Always scores{}'
		}
	},
	always_scores = true,
	pos = { x = 9, y = 0 },
	atlas = 'jenenhance'
}

SMODS.Enhancement {
	key = 'handy',
	loc_txt = {
		name = 'Handy Card',
		text = {
			'{C:blue}+1{} hand this round when scored'
		}
	},
	pos = { x = 1, y = 1 },
	atlas = 'jenenhance',
	unlocked = true,
	discovered = true,
	calculate = function(self, card, context, effect)
		if scoringcard(context) then
			ease_hands_played(1)
		end
	end
}

SMODS.Enhancement {
	key = 'tossy',
	loc_txt = {
		name = 'Tossy Card',
		text = {
			'{C:red}+1{} discard this round when scored'
		}
	},
	pos = { x = 3, y = 1 },
	atlas = 'jenenhance',
	unlocked = true,
	discovered = true,
	calculate = function(self, card, context, effect)
		if scoringcard(context) then
			ease_discard(1)
		end
	end
}

--JOKERS

SMODS.Joker {
	key = 'lambert',
	loc_txt = {
		name = '{C:dark_edition}Lambert{}',
		text = {
			'All {C:attention}Jokers{} to the {C:green}left{}',
			'of this {C:attention}Joker{} become {C:purple}Eternal{}',
			'All {C:attention}Jokers{} to the {C:green}right{}',
			'of this {C:attention}Joker{} {C:red}lose{} {C:purple}Eternal{}',
			'Removes {C:attention}all other stickers{}',
			'and {C:red}debuffs{} from all other {C:attention}Jokers{}',
			'{C:inactive}(Stickers update whenever jokers are calculated){}',
			' ',
			'{C:inactive,s:1.4,E:1}#1#{}',
			'{C:inactive,s:1.4,E:1}#2#{}',
			'{C:dark_edition,s:0.7,E:2}Face art by : raidoesthings{}',
		}
	},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 50,
	rarity = 'cry_exotic',
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = false,
	atlas = 'jenlambert',
    loc_vars = function(self, info_queue, center)
        return {vars = {hasgodsmarble() and "My skin burns... it's... I-IT'S" or 'I try to give my followers', hasgodsmarble() and 'MEEeeEEllLLttTTiiiNNNggGGG!!!' or 'a good life before death.'}}
    end,
    calculate = function(self, card, context)
		if not context.blueprint and card.added_to_deck and noretriggers(context) and G.jokers and G.jokers.cards then
			for i=1, #G.jokers.cards do
				local other_card = G.jokers.cards[i]
				if other_card and other_card ~= card then
					if card.T.x + card.T.w/2 > other_card.T.x + other_card.T.w/2 then
						other_card:set_eternal(true)
					else
						other_card:set_eternal(nil)
					end
					if other_card.ability then
						other_card.ability.perishable = nil
						other_card.ability.banana = nil
					end
					other_card.debuff = nil
					other_card:set_rental(nil)
					other_card.pinned = nil
				end
			end
		end
	end
}

SMODS.Joker {
	key = 'leshy',
	loc_txt = {
		name = '{C:green}Leshy{}',
		text = {
			'{C:clubs}Clubs{} give',
			'{X:dark_edition,C:red}^#1#{C:red} Mult{} when scored',
			' ',
			'{C:inactive,s:1.25,E:1}#2#{}',
			'{C:dark_edition,s:0.7,E:2}Face art by : raidoesthings{}',
		}
	},
	config = {extra = {power = 1.3}},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 50,
	rarity = 'cry_exotic',
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	atlas = 'jenleshy',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.power, hasgodsmarble() and "MY ARMS ARE MELTING!!!" or 'Hope is what led us this far, right?'}}
    end,
    calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
			if context.other_card:is_suit('Clubs') then
				return {
					e_mult = card.ability.extra.power,
					colour = G.C.DARK_EDITION,
					card = card
				}
			end
		end
	end
}

SMODS.Joker {
	key = 'heket',
	loc_txt = {
		name = '{C:money}Heket{}',
		text = {
			'{C:diamonds}Diamonds{} give',
			'{X:dark_edition,C:red}^#1#{C:red} Mult{} when scored',
			' ',
			'{C:inactive,s:1.25,E:1}#2#{}',
			'{C:inactive,s:1.25,E:1}#3#{}',
			'{C:dark_edition,s:0.7,E:2}Face art by : raidoesthings{}',
		}
	},
	config = {extra = {power = 1.3}},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 50,
	rarity = 'cry_exotic',
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	atlas = 'jenheket',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.power, hasgodsmarble() and 'What is happening to me...?!' or 'Sometimes, you have to do', hasgodsmarble() and "My spine... it's... FOLDIIIING...!" or 'things the hard way.'}}
    end,
    calculate = function(self, card, context)
		if context.individual then
			if context.cardarea == G.play then
				if context.other_card:is_suit('Diamonds') then
					return {
						e_mult = card.ability.extra.power,
						colour = G.C.DARK_EDITION,
						card = card
					}
				end
			end
		end
	end
}

SMODS.Joker {
	key = 'kallamar',
	loc_txt = {
		name = '{C:planet}Kallamar{}',
		text = {
			'{C:spades}Spades{} give',
			'{X:dark_edition,C:red}^#1#{C:red} Mult{} when scored',
			' ',
			"{C:inactive,s:1.25,E:1}#2#{}",
			'{C:dark_edition,s:0.7,E:2}Face art by : raidoesthings{}',
		}
	},
	config = {extra = {power = 1.3}},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 50,
	rarity = 'cry_exotic',
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	atlas = 'jenkallamar',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.power, hasgodsmarble() and 'MyyYyyYY hEeaDDd iSS BiiSEEecCttInGG...!!!' or "It's not too late to turn a new leaf."}}
    end,
    calculate = function(self, card, context)
		if context.individual then
			if context.cardarea == G.play then
				if context.other_card:is_suit('Spades') then
					return {
						e_mult = card.ability.extra.power,
						colour = G.C.DARK_EDITION,
						card = card
					}
				end
			end
		end
	end
}

SMODS.Joker {
	key = 'shamura',
	loc_txt = {
		name = '{C:tarot}Shamura{}',
		text = {
			'{C:hearts}Hearts{} give',
			'{X:dark_edition,C:red}^#1#{C:red} Mult{} when scored',
			' ',
			'{C:inactive,s:1.11,E:1}#2#{}',
			'{C:inactive,s:1.11,E:1}#3#{}',
			'{C:dark_edition,s:0.7,E:2}Face art by : raidoesthings{}',
		}
	},
	config = {extra = {power = 1.3}},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 50,
	rarity = 'cry_exotic',
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	atlas = 'jenshamura',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.power, hasgodsmarble() and 'My mind... my BRAIN...' or 'I wish to help create a', hasgodsmarble() and "IT'S FRACTURING MY CRANIUM!!!" or 'better future for everyone.'}}
    end,
    calculate = function(self, card, context)
		if context.individual then
			if context.cardarea == G.play then
				if context.other_card:is_suit('Hearts') then
					return {
						e_mult = card.ability.extra.power,
						colour = G.C.DARK_EDITION,
						card = card
					}
				end
			end
		end
	end
}

SMODS.Joker {
	key = 'narinder',
	loc_txt = {
		name = '{C:red}N{C:green}a{C:money}r{C:planet}i{C:tarot}n{C:red}d{C:dark_edition}e{C:red}r',
		text = {
			'{C:attention}Face cards{} give',
			'{X:dark_edition,C:red}^#1#{C:red} Mult{} when scored',
			' ',
			"{C:inactive,s:1.11,E:1}#2#{}",
			"{C:inactive,s:1.11,E:1}#3#{}",
			'{C:dark_edition,s:0.7,E:2}Face art by : raidoesthings{}',
		}
	},
	config = {extra = {power = 1.15}},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 50,
	rarity = 'cry_exotic',
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	atlas = 'jennarinder',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.power, hasgodsmarble() and 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' or 'Just keep moving forward;', hasgodsmarble() and 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' or "don't let any idiot stop you."}}
    end,
    calculate = function(self, card, context)
		if context.individual then
			if context.cardarea == G.play then
				if context.other_card:is_face() then
					return {
						e_mult = card.ability.extra.power,
						colour = G.C.DARK_EDITION,
						card = card
					}
				end
			end
		end
	end
}

local clauneck_blurbs = {
	"I bless thee!",
	"A good draw!",
	"Here's your reading...",
	"It's dangerous to go alone...",
	"Be careful.",
	"May the Fates bless you."
}

SMODS.Joker {
	key = 'clauneck',
	loc_txt = {
		name = 'Clauneck',
		text = {
			'{C:tarot}Tarot{} cards add',
			'either {X:blue,C:white}x#1#{} or {C:blue}+#2# Chips{}',
			'to all {C:attention}playing cards{} when used',
			'{C:inactive}(Uses whichever one that gives the better upgrade){}',
			'When any card reaches {C:attention}1e100 chips or more{},',
			'{C:red}reset it to zero{}, {C:planet}level up all hands #3# time(s){}',
			'and create a {C:dark_edition}Negative {C:spectral}Soul{}',
			' ',
			"{C:inactive,s:1.11,E:1}#4#{}",
			"{C:inactive,s:1.11,E:1}#5#{}",
			'{C:dark_edition,s:0.7,E:2}Face art by : raidoesthings{}',
		}
	},
	config = {extra = {chips_additive = 100, chips_mult = 2, levelup = 10}},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 50,
	rarity = 'cry_exotic',
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	immune_to_chemach = true,
	atlas = 'jenclauneck',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.chips_mult, center.ability.extra.chips_additive, center.ability.extra.levelup, hasgodsmarble() and 'A-Apollo... I have failed you...' or 'May the Fates guide', hasgodsmarble() and 'May... t-the F-F-Fates..... have... m-.....' or 'you to the best path.'}}
    end,
    calculate = function(self, card, context)
		if context.using_consumeable and context.consumeable and context.consumeable.ability.set == 'Tarot' and (#G.hand.cards > 0 or #G.deck.cards > 0) then
			card_eval_status_text(card, 'extra', nil, nil, nil, {message = clauneck_blurbs[math.random(#clauneck_blurbs)], colour = G.C.MULT})
			local e100cards = {}
			if #G.hand.cards > 0 then
				for k, v in pairs(G.hand.cards) do
					if not v.ability.perma_bonus then v.ability.perma_bonus = 0 end
					local res1 = 0
					local res2 = 0
					for i = 1, context.consumeable:getEvalQty() do
						res1 = v.ability.perma_bonus * card.ability.extra.chips_mult
						res2 = v.ability.perma_bonus + card.ability.extra.chips_additive
						v.ability.perma_bonus = math.max(res1, res2)
					end
					card_eval_status_text(v, 'extra', nil, nil, nil, {message = '+' .. v.ability.perma_bonus, colour = G.C.CHIPS})
					if v.ability.perma_bonus >= 1e100 then table.insert(e100cards, v) end
				end
			end
			if #G.deck.cards > 0 then
				for k, v in pairs(G.deck.cards) do
					if not v.ability.perma_bonus then v.ability.perma_bonus = 0 end
					local res1 = v.ability.perma_bonus * card.ability.extra.chips_mult
					local res2 = v.ability.perma_bonus + card.ability.extra.chips_additive
					v.ability.perma_bonus = math.max(res1, res2)
					if v.ability.perma_bonus >= 1e100 then table.insert(e100cards, v) end
				end
			end
			local ecs = #e100cards
			if ecs > 0 then
				card_status_text(card, '!!!', nil, 0.05*card.T.h, G.C.DARK_EDITION, 0.6, 0.6, 2, 2, 'bm', 'jen_enlightened')
				update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize('k_all_hands'),chips = '...', mult = '...', level=''})
				G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
					play_sound('tarot1')
					card:juice_up(0.8, 0.5)
					G.TAROT_INTERRUPT_PULSE = true
				return true end }))
				update_hand_text({sound = 'button', volume = 0.7, pitch = 0.9, delay = 0}, {chips = '+', mult = '+', StatusText = true, level='+' .. number_format(card.ability.extra.levelup * ecs)})
				delay(1.3)
				for k, v in pairs(G.GAME.hands) do
					level_up_hand(v, k, true, card.ability.extra.levelup * ecs)
				end
				for k, v in pairs(e100cards) do
					v.ability.perma_bonus = 0
				end
				update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
				G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
					local soul = create_card('Spectral', G.consumeables, nil, nil, nil, nil, 'c_soul', nil)
					soul:set_edition({negative = true})
					soul:setQty(ecs)
					if ecs > 1 then soul:create_stack_display() end
					soul:set_cost()
					soul:add_to_deck()
					G.consumeables:emplace(soul)
				return true end }))
			end
			return {calculated = true}
		end
	end
}

local random_editions = {
	'foil',
	'holo',
	'polychrome',
	'jen_chromatic',
	'jen_polygloss',
	'jen_gilded',
	'jen_sequin',
	'jen_laminated',
	'jen_ink',
	'jen_prismatic',
	'jen_watered',
	'jen_sepia',
	'jen_reversed',
	'jen_diplopia',
	'cry_mosaic',
	'cry_oversat',
	'cry_astral',
	'cry_blur'
}

local exotic_editions = {
	'jen_bloodfoil',
	'jen_blood'
}

local wondrous_editions = {
	'jen_moire'
}

function Card:is_exotic_edition(excludewondrous)
	if not self.edition then return false end
	local is_exotic = false
	for k, v in pairs(exotic_editions) do
		if self.edition[v] then
			is_exotic = true
			break
		end
	end
	if not excludewondrous then
		for k, v in pairs(wondrous_editions) do
			if self.edition[v] then
				is_exotic = true
				break
			end
		end
	end
	return is_exotic
end

function Card:is_wondrous_edition()
	if not self.edition then return false end
	local is_exotic = false
	for k, v in pairs(wondrous_editions) do
		if self.edition[v] then
			is_exotic = true
			break
		end
	end
	return is_exotic
end

local pending_applyingeditions = false

SMODS.Joker {
	key = 'kudaai',
	loc_txt = {
		name = 'Kudaai',
		text = {
			'Non-{C:dark_edition}editioned{} cards are',
			'{C:attention}given a random {C:dark_edition}Edition{}',
			'{C:inactive,s:0.8}(Some editions are excluded from the pool){}',
			' ',
			"{C:inactive,s:1.11,E:1}#1#{}",
			"{C:inactive,s:0.6,E:1}#2#{}",
			'{C:dark_edition,s:0.7,E:2}Face art by : raidoesthings{}',
		}
	},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 20,
	rarity = 4,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = false,
	immune_to_chemach = true,
	atlas = 'jenkudaai',
    loc_vars = function(self, info_queue, center)
        return {vars = {hasgodsmarble() and 'HELP! HEEEEeeeell-...' or "You'll need these...", hasgodsmarble() and '' or "...lest you wan'cha ass kicked."}}
    end,
	calculate = function(self, card, context)
		if not context.blueprint and noretriggers(context) and not pending_applyingeditions then
			pending_applyingeditions = true
			G.E_MANAGER:add_event(Event({func = function()
				G.E_MANAGER:add_event(Event({func = function()
					if card.added_to_deck then
						local iter = 0
						for k, v in pairs(G.jokers.cards) do
							if not v.edition or next(v.edition) == nil then
								iter = iter + 1
								v:set_edition({[random_editions[pseudorandom('kudaai_editions1', 1, #random_editions)]] = true}, iter > 50, iter > 50)
							end
						end
						iter = 0
						for k, v in pairs(G.hand.cards) do
							if not v.edition or next(v.edition) == nil then
								iter = iter + 1
								v:set_edition({[random_editions[pseudorandom('kudaai_editions2', 1, #random_editions)]] = true}, iter > 52, iter > 52)
							end
						end
						for k, v in pairs(G.deck.cards) do
							if not v.edition or next(v.edition) == nil then
								v:set_edition({[random_editions[pseudorandom('kudaai_editions3', 1, #random_editions)]] = true}, true, true)
							end
						end
						iter = 0
						for k, v in pairs(G.consumeables.cards) do
							if not v.edition or next(v.edition) == nil then
								iter = iter + 1
								v:set_edition({[random_editions[pseudorandom('kudaai_editions4', 1, #random_editions)]] = true}, iter > 20, iter > 20)
							end
						end
						iter = nil
						pending_applyingeditions = false
					end
				return true end }))
			return true end }))
		end
	end
}

local chemach_phrases = {
	'Another precious relic!',
	'A fine addition to my collection.',
	'A worthy antique!',
	'Oh, I love it!',
	'It looks so shiny!',
	'I am satisfied with this haul!',
	"Now that's going on display!",
	'I might need a bigger chest...'
}

local vars1plus = {'x_mult', 'e_mult', 'ee_mult', 'eee_mult', 'x_chips', 'e_chips', 'ee_chips', 'eee_chips'}

SMODS.Joker {
	key = 'chemach',
	loc_txt = {
		name = 'Chemach',
		text = {
			'{C:attention}Doubles{} the values of',
			'{C:attention}all Jokers{} whenever',
			'a Joker that is {C:red}not {C:blue}Common{} or {C:green}Uncommon{} is {C:money}sold{},',
			'then {C:attention}retrigger all add-to-inventory effects{} of {C:attention}all Jokers{}',
			'{C:inactive}(Not all values can be doubled, not all Jokers can be affected){}',
			' ',
			"{C:inactive,s:1.11,E:1}#1#{}",
			"{C:inactive,s:1.11,E:1}#2#{}",
			'{C:dark_edition,s:0.7,E:2}Face art by : raidoesthings{}',
		}
	},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 50,
	rarity = 'cry_exotic',
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	immune_to_chemach = true, --lol
	atlas = 'jenchemach',
    loc_vars = function(self, info_queue, center)
        return {vars = {hasgodsmarble() and 'No! NO! STOP! STOP IT!!' or "My treasures are remnants", hasgodsmarble() and 'THIS RELIC IS TOO MUCH!! NO!!! NOOOOOOooo-!!!' or "of tales old and new."}}
    end,
	calculate = function(self, card, context)
		if context.selling_card then
			if context.card.ability.set == 'Joker' and context.card.config.center.rarity ~= 1 and context.card.config.center.rarity ~= 2 then
				card_eval_status_text(card, 'extra', nil, nil, nil, {message = chemach_phrases[math.random(#chemach_phrases)], colour = G.C.PURPLE})
				for k, v in pairs(G.jokers.cards) do
					if v ~= card and v ~= context.card then
						if not v.config.center.immune_to_chemach then
							v:remove_from_deck()
							for a, b in pairs(v.ability) do
								if a == 'extra' then
									if type(v.ability.extra) == 'number' then
										v.ability.extra = v.ability.extra * 2
									elseif type(v.ability.extra) == 'table' and next(v.ability.extra) then
										for c, d in pairs(v.ability.extra) do
											if type(d) == 'number' then
												v.ability.extra[c] = d * 2
											end
										end
									end
								elseif a ~= 'order' and a ~= 'hyper_chips' and a ~= 'hyper_mult' and type(b) == 'number' and b > (batchfind(a, vars1plus) and 1 or 0) then
									v.ability[a] = b * 2
								end
							end
							v:add_to_deck()
						end
					end
				end
			end
		end
	end
}

local haro_blurbs = {
	"Once upon a time...",
	"Have I got a story for you!",
	"I remember one time...",
	"This tale of mine is relatively ancient...",
	"Let me tell you a story."
}

SMODS.Joker {
	key = 'haro',
	loc_txt = {
		name = 'Haro',
		text = {
			'{C:tarot}Tarots {C:planet}level up{}',
			'{C:attention}all hands{} when used',
			'{X:green,C:white}Synergy:{} {X:dark_edition,C:red}^#1#{C:red} Mult{} if',
			'you have {X:attention,C:black}Suzaku{}',
			' ',
			"{C:inactive,s:1.11,E:1}I live to tell tales,{}",
			"{C:inactive,s:1.11,E:1}both of old and of new.{}",
			'{C:dark_edition,s:0.7,E:2}Face art by : raidoesthings{}',
		}
	},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	config = {extra = {synergy_mult = 1.65}},
	cost = 15,
	rarity = 'cry_epic',
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	atlas = 'jenharo',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.synergy_mult}}
    end,
	calculate = function(self, card, context)
		if context.using_consumeable and context.consumeable and context.consumeable.ability.set == 'Tarot' then
			local quota = (context.consumeable:getEvalQty())
			card.cumulative_lvs = (card.cumulative_lvs or 0) + quota
			if noretriggers(context) then
				card_eval_status_text(card, 'extra', nil, nil, nil, {message = haro_blurbs[math.random(#haro_blurbs)], colour = G.C.SECONDARY_SET.Tarot})
				card:apply_cumulative_levels()
			end
			return {calculated = true}
		end
		if #SMODS.find_card('j_jen_suzaku') > 0 then
			if context.cardarea == G.jokers and not context.before and not context.after then
				return {
					message = 'Either with a sword, or a bullet! (^' .. card.ability.extra.synergy_mult .. ' Mult)',
					Emult_mod = card.ability.extra.synergy_mult,
					colour = G.C.DARK_EDITION
				}
			end
		end
	end
}

local suzaku_blurbs = {
	"More ammo!",
	"Bullets! Yes!",
	"Talk about a fine caliber.",
	"I can shoot with this...",
	"Let's fire a round, eh?"
}

SMODS.Joker {
	key = 'suzaku',
	loc_txt = {
		name = 'Suzaku',
		text = {
			'{C:spectral}Spectrals {C:planet}level up{}',
			'{C:attention}all hands{} when used',
			'{X:green,C:white}Synergy:{} {X:dark_edition,C:red}^#1#{C:red} Mult{} if',
			'you have {X:attention,C:black}Haro{}',
			' ',
			"{C:inactive,s:1.11,E:1}You gotta finish the job fast{}",
			"{C:inactive,s:1.11,E:1}sometimes, and you have me to help!{}",
			'{C:dark_edition,s:0.7,E:2}Face art by : raidoesthings{}',
		}
	},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	config = {extra = {synergy_mult = 1.65}},
	cost = 15,
	rarity = 'cry_epic',
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	atlas = 'jensuzaku',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.synergy_mult}}
    end,
	calculate = function(self, card, context)
		if context.using_consumeable and context.consumeable and context.consumeable.ability.set == 'Spectral' then
			local quota = (context.consumeable:getEvalQty())
			card.cumulative_lvs = (card.cumulative_lvs or 0) + quota
			if noretriggers(context) then
				card_eval_status_text(card, 'extra', nil, nil, nil, {message = suzaku_blurbs[math.random(#suzaku_blurbs)], colour = G.C.SECONDARY_SET.Spectral})
				card:apply_cumulative_levels()
			end
			return {calculated = true}
		end
		if #SMODS.find_card('j_jen_haro') > 0 then
			if context.cardarea == G.jokers and not context.before and not context.after then
				return {
					message = 'All it takes is one chance. (^' .. card.ability.extra.synergy_mult .. ' Mult)',
					Emult_mod = card.ability.extra.synergy_mult,
					colour = G.C.DARK_EDITION
				}
			end
		end
	end
}

local aster_blurbs = {
	'To the stars!',
	'I gotcha!',
	'Awesome!',
	'Ooooh...',
	'We have liftoff!',
	"Let's bring them ALL up!",
	"You're doing great!",
	'Let me help you with that!',
	'Boop!',
	'Hehe!'
}

SMODS.Joker {
	key = 'aster',
	loc_txt = {
		name = 'Aster',
		text = {
			'{C:planet}Planets level up{}',
			'{C:attention}all hands{} when used',
			' ',
			"{C:inactive,s:1.11,E:1}Hi! Nice to meet you!{}",
			'{C:dark_edition,s:0.7,E:2}Face art by : HexaCryonic{}',
		}
	},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 15,
	rarity = 'cry_epic',
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	atlas = 'jenaster',
	calculate = function(self, card, context)
		if context.using_consumeable and context.consumeable and context.consumeable.ability.set == 'Planet' then
			local quota = (context.consumeable:getEvalQty())
			card.cumulative_lvs = (card.cumulative_lvs or 0) + quota
			if noretriggers(context) then
				card_eval_status_text(card, 'extra', nil, nil, nil, {message = aster_blurbs[math.random(#aster_blurbs)], colour = G.C.SECONDARY_SET.Planet})
				card:apply_cumulative_levels()
			end
			return {calculated = true}
		end
	end
}

local astrophage_blurbs = {
	'M O R E . . .',
	'P O W E R   U P .',
	'A S C E N D .',
	'G L O R I O U S .',
	'S T R O N G E R . . .',
	"I   G R O W .",
	"S A V O U R   T H E   P O W E R .",
	'F U E L   T O   T H E   F I R E . . .',
	'C R U S H .',
	'A S S I M I L A T E .'
}

local ayanami_blurbs = {
	"Let the night sky reign!",
	"The zodiac aligns tonight.",
	"May the nebulae bring new life.",
	"Sing along with me!",
	"The galaxy shall be under my jurisdiction.",
	"Twinkle, twinkle, little star..."
}

SMODS.Joker {
	key = 'ayanami',
	loc_txt = {
		name = 'Ayanami',
		text = {
			'Using {C:attention}non-{C:dark_edition}Negative {C:planet}Planets',
			'creates {C:attention}#1# {C:dark_edition}Negative{} copies',
			'Using {C:dark_edition}Negative {C:planet}Planets',
			'creates {C:attention}#2# {C:dark_edition}Negative {C:spectral}Black Holes{}',
			' ',
			"{C:inactive,s:1.11,E:1}The throne of death is not for{}",
			"{C:inactive,s:1.11,E:1}a merciful fool like you.{}",
			'{C:dark_edition,s:0.7,E:2}Face art by : raidoesthings{}'
		}
	},
	config = {extra = {planets = 5, black_holes = 3}},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 50,
	rarity = 'cry_exotic',
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	immune_to_chemach = true,
	atlas = 'jenayanami',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.planets, center.ability.extra.black_holes}}
    end,
	calculate = function(self, card, context)
		if context.using_consumeable and context.consumeable and context.consumeable.ability.set == 'Planet' then
			local quota = (context.consumeable:getEvalQty())
			local card_key = context.consumeable.config.center.key
			local isnegative = (context.consumeable.edition or {}).negative
			card.cumulative_qty = (card.cumulative_qty or 0) + quota
			if noretriggers(context) then
				G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
					G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
						if card then
							local copies = math.floor(isnegative and card.ability.extra.black_holes or card.ability.extra.planets) * (card.cumulative_qty or 1)
							card_eval_status_text(card, 'extra', nil, nil, nil, {message = ayanami_blurbs[math.random(#ayanami_blurbs)], colour = G.C.SECONDARY_SET.Planet})
							local duplicate = create_card(isnegative and 'Spectral' or 'Planet', G.consumeables, nil, nil, nil, nil, isnegative and 'c_black_hole' or card_key, nil)
							duplicate:set_edition({negative = true}, true)
							duplicate:setQty(copies)
							duplicate:create_stack_display()
							duplicate:set_cost()
							duplicate:add_to_deck()
							G.consumeables:emplace(duplicate)
							card.cumulative_qty = nil
						end
					return true end }))
				return true end }))
			end
			return {calculated=true}
		end
	end
}

SMODS.Joker {
	key = 'murphy',
	loc_txt = {
		name = 'Murphy',
		text = {
			'{C:attention}9{}s give {X:jen_RGB,C:white,s:1.5}^^1.09{C:chips} Chips{}',
			'and {C:money}$99{} when scored',
			' ',
			"{C:inactive,s:1.4,E:1}That's just a bunch of balls!{}"
		}
	},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 50,
	rarity = 'cry_exotic',
	set_card_type_badge = twitch,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	immune_to_chemach = true,
	atlas = 'jenmurphy',
    calculate = function(self, card, context)
		if context.cardarea == G.play then
			if context.other_card and not context.other_card:norank() and context.other_card:get_id() == 9 then
				ease_dollars(99)
				return {
					message = '^^1.09 Chips & +$99',
					EEchip_mod = 1.09,
					colour = G.C.MONEY,
					card = card
				}
			end
		end
	end
}

local function numtags()
	if not G.GAME.tags then return 0 end
	local tags = 0
	for k, v in pairs(G.GAME.tags) do
		tags = tags + 1
	end
	return tags
end

SMODS.Joker {
	key = 'kyle',
	loc_txt = {
		name = 'Kyle Skreene',
		text = {
			'{X:jen_RGB,C:white,s:1.5}+^^#1#{C:mult} Mult{}',
			'for every currently-held {C:attention}Tag{}',
			'{C:inactive}(Currently {X:jen_RGB,C:white,s:1.5}^^#2#{C:inactive}){}',
			' ',
			"{C:inactive,s:1.11,E:1}The tags pile doesn't{}",
			"{C:inactive,s:1.11,E:1}stop from getting higher.{}",
			'{C:dark_edition,s:0.7,E:2}Face art by : Luigicat11{}'
		}
	},
	config = {extra = {tetration = 0.2}},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 50,
	rarity = 'cry_exotic',
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	atlas = 'jenkyle',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.tetration, 1 + (numtags() * center.ability.extra.tetration)}}
    end,
	calculate = function(self, card, context)
		if context.cardarea == G.jokers and not context.before and not context.after and context.scoring_name then
			local tags = numtags()
			if tags > 0 then
				local num = 1 + (tags*card.ability.extra.tetration)
				return {
					message = '^^' .. num .. ' Mult',
					colour = G.C.jen_RGB,
					EEmult_mod = num,
					card = card
				}
			end
		end
	end
}

SMODS.Joker {
	key = 'johnny',
	loc_txt = {
		name = 'Johnny',
		text = {
			'{X:dark_edition,C:mult}^#1#{C:mult} Mult{}',
			'Using {C:spectral}Black Holes {C:green}increases{} this by {C:attention}#2#{}',
			'Using {C:spectral}White Holes {C:purple}multiplies{} this by {C:attention}#3#{}',
			' ',
			"{C:inactive,s:1.11,E:1}Now, step into the hat.{}",
			"{C:inactive,s:1.11,E:1}Yes, just like that.{}",
			'{C:dark_edition,s:0.7,E:2}Face art by : BondageKat{}'
		}
	},
	config = {extra = {em = 1.5, blackhole_factor = 0.5, whitehole_factor = 3}},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 50,
	rarity = 'cry_exotic',
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	atlas = 'jenjohnny',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.em, center.ability.extra.blackhole_factor, center.ability.extra.whitehole_factor}}
    end,
	calculate = function(self, card, context)
		if not context.blueprint then
			if context.using_consumeable and context.consumeable then
				local improved = false
				if context.consumeable.config.center.key == 'c_black_hole' then
					card.ability.extra.em = card.ability.extra.em + (card.ability.extra.blackhole_factor * context.consumeable:getEvalQty())
					improved = true
					card_eval_status_text(card, 'extra', nil, nil, nil, {message = '+' .. tostring(card.ability.extra.blackhole_factor), colour = G.C.DARK_EDITION})
				elseif context.consumeable.config.center.key == 'c_cry_white_hole' then
					card.ability.extra.em = card.ability.extra.em * math.min(1e100, card.ability.extra.whitehole_factor ^ context.consumeable:getEvalQty())
					improved = true
					card_eval_status_text(card, 'extra', nil, nil, nil, {message = 'x' .. tostring(card.ability.extra.whitehole_factor), colour = G.C.DARK_EDITION})
				end
				if improved then
					card_eval_status_text(card, 'extra', nil, nil, nil, {message = '^' .. tostring(card.ability.extra.em) .. ' Mult', colour = G.C.FILTER})
					return {calculated = true}
				end
			end
		end
		if context.cardarea == G.jokers and not context.before and not context.after and context.scoring_name then
			if card.ability.extra.em > 1 then
				return {
					message = '^' .. card.ability.extra.em .. ' Mult',
					colour = G.C.DARK_EDITION,
					Emult_mod = card.ability.extra.em,
					card = card
				}
			end
		end
	end
}

SMODS.Joker {
	key = 'guilduryn',
	loc_txt = {
		name = 'Guilduryn',
		text = {
			'{C:attention}Gold 7{}s earn {C:money}$77{}',
			'and give {X:dark_edition,C:mult}^7{C:mult} Mult{} when scored',
			' ',
			"{C:inactive,s:1.11,E:1}Leader of the Seven Sins{}",
			"{C:inactive,s:1.11,E:1}at your service~!{}",
			'{C:dark_edition,s:0.7,E:2}Face art by : raidoesthings{}'
		}
	},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 50,
	rarity = 'cry_exotic',
	set_card_type_badge = sevensins,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	atlas = 'jenguilduryn',
    calculate = function(self, card, context)
		if context.cardarea == G.play then
			if context.other_card and context.other_card.ability.name == 'Gold Card' and context.other_card:get_id() == 7 then
				ease_dollars(77)
				return {
					message = '^7 Mult & +$77',
					Emult_mod = 7,
					colour = G.C.MONEY,
					card = card
				}
			end
		end
	end
}

SMODS.Joker {
	key = 'hydrangea',
	loc_txt = {
		name = 'Hydrangea',
		text = {
			'{C:attention}7{}s reduce the {C:attention}current Blind{}',
			'by {C:attention}7%{} when scored',
			' ',
			"{C:inactive,s:1.11,E:1}Whatever you're bugging me{}",
			"{C:inactive,s:1.11,E:1}about better be important.{}",
			'{C:dark_edition,s:0.7,E:2}Face art by : raidoesthings{}'
		}
	},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 50,
	rarity = 'cry_exotic',
	set_card_type_badge = sevensins,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	atlas = 'jenhydrangea',
    calculate = function(self, card, context)
		if context.cardarea == G.play then
			if context.other_card and not context.other_card:norank() and scoringcard(context) and context.other_card:get_id() == 7 then
				card_status_text(card, '-7% Blind Size', nil, 0.05*card.T.h, G.C.FILTER, 0.75, 1, 0.6, nil, 'bm', 'generic1')
				change_blind_size(bn(G.GAME.blind.chips) / bn(1.07))
			end
		end
	end
}

SMODS.Joker {
	key = 'heisei',
	loc_txt = {
		name = 'Heisei',
		text = {
			'{C:attention}7{}s raise {C:chips}Chips{} to the {X:dark_edition,C:white}power{} of',
			'{C:green}1 plus a tenth of your {C:money}money{} when scored,',
			'{C:red,E:1}but also takes half of your money{}',
			'{C:inactive}(No effect if you have $0 or less){}',
			' ',
			"{C:inactive,s:1.11,E:1}Enough about me, what{}",
			"{C:inactive,s:1.11,E:1}is it that you desire?{}",
			'{C:dark_edition,s:0.7,E:2}Face art by : raidoesthings{}'
		}
	},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 50,
	rarity = 'cry_exotic',
	set_card_type_badge = sevensins,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	atlas = 'jenheisei',
    calculate = function(self, card, context)
		if context.cardarea == G.play then
			if context.other_card and not context.other_card:norank() and scoringcard(context) and context.other_card:get_id() == 7 then
				local val = G.GAME.dollars
				if val > 0 then
					ease_dollars(-math.floor(G.GAME.dollars / 2))
					return {
						Echip_mod = (1 + (val/10)),
						card = card
					}
				end
			end
		end
	end
}

SMODS.Joker {
	key = 'soryu',
	loc_txt = {
		name = 'Soryu',
		text = {
			'{C:attention}Retrigger every Joker once{}',
			'for every {C:attention}7 of {C:hearts}Hearts{}',
			'in played hand',
			'{C:inactive}(Also considers Wilds and any Joker effects){}',
			' ',
			"{C:inactive,s:1.11,E:1}Patience is the key, dear.{}",
			"{C:inactive,s:1.11,E:1}I don't do my work in one day, after all.{}",
			'{C:dark_edition,s:0.7,E:2}Face art by : raidoesthings{}'
		}
	},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 20,
	rarity = 4,
	set_card_type_badge = sevensins,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = false,
	atlas = 'jensoryu',
    calculate = function(self, card, context)
		if not context.blueprint and not context.repetition then
			if context.retrigger_joker_check and not context.retrigger_joker then
				local reps = 0
				if G.play and G.play.cards and next(G.play.cards) then
					for k, v in pairs(G.play.cards) do
						if not v:norankorsuit() and v:get_id() == 7 and v:is_suit('Hearts') then
							reps = reps + 1
						end
					end
				end
				if reps > 0 then
					return {
						message = localize('k_again_ex'),
						repetitions = reps,
						card = card
					}
				end
			end
		end
	end
}

SMODS.Joker {
	key = 'shikigami',
	loc_txt = {
		name = 'Shikigami',
		text = {
			'Played {C:attention}7{}s create',
			'{C:attention}7 copies{} of themselves',
			' ',
			"{C:inactive,s:1.11,E:1}Why are we cards??{}",
			"{C:inactive,s:1.11,E:1}Where even are we?!{}",
			'{C:dark_edition,s:0.7,E:2}Face art by : raidoesthings{}'
		}
	},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 20,
	rarity = 4,
	set_card_type_badge = sevensins,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = false,
	atlas = 'jenshikigami',
    calculate = function(self, card, context)
		if not context.blueprint then
			if context.cardarea == G.play then
				if context.other_card and not context.other_card:norank() and not context.repetition and context.other_card:get_id() == 7 then
					local sevens = {}
					for i = 1, 7 do
						local seven = copy_card(context.other_card, nil, nil, G.playing_card)
						seven:add_to_deck()
						seven:start_materialize()
						table.insert(sevens, seven)
					end
					for k, seven in pairs(sevens) do
						if seven ~= context.other_card then
							table.insert(G.playing_cards, seven)
							G.deck:emplace(seven)
						end
					end
				end
			end
		end
	end
}

local leviathan_blurbs = {
	dull = {
		'My axe is dull!',
		"I can't cut through it!",
		"Axe's dull; can't slice this obstacle!",
		'I need a whetstone!',
		'Find me a grindstone, please.',
		'Need to sharpen my axe!',
		'You expecting me to slay this thing with a dull axe?',
		"I can't do anything if my axe will just bounce off!",
		'Grindstone, please?',
		'Stop trying to get me to use a dull axe and just GET A WHETSTONE ALREADY!',
		"Not now, axe's not ready.",
		'I blame Shikigami for this...'
	},
	sharpen = {
		'Good as new.',
		'Bring me more of those whetstones, yeah?',
		'Gotta keep my axe sharp.',
		'Sharpened!',
		'Looks ready to cut again.',
		'I kind of like that noise.',
		"Can't have my axe becoming dull!",
		'I prefer something sharp over something blunt.',
		'Ready for another swing.',
		"Thanks for the whetstone, Shikigami."
	}
}

local leviathan_maxsharpness = 3

SMODS.Joker {
	key = 'leviathan',
	loc_txt = {
		name = 'Leviathan',
		text = {
			'{X:inactive}Axe{} {X:inactive}Sharpness{} : {C:attention}#1#{C:inactive} / ' .. tostring(leviathan_maxsharpness) .. '{}',
			' ',
			'If played hand contains {C:attention}only one card{}, and that',
			'card is a {C:attention}Steel 7 of {C:spades}Spades{},',
			'{C:red}destroy it{} and then set the',
			'{C:attention}current Blind size{} to {C:attention}1{}',
			'If the only card is instead a {C:attention}Stone Card{},',
			"{C:red}destroy it{} and {C:attention}sharpen Leviathan's axe{} by {C:attention}1{} point",
			' ',
			"{C:inactive,s:1.11,E:1}Are you going to cooperate, or are{}",
			"{C:inactive,s:1.11,E:1}you just going to stand there?{}",
			'{C:dark_edition,s:0.7,E:2}Face art by : raidoesthings{}'
		}
	},
	config = {extra = {axesharpness = leviathan_maxsharpness}},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 50,
	rarity = 'cry_exotic',
	set_card_type_badge = sevensins,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = false,
	immune_to_chemach = true,
	atlas = 'jenleviathan',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.axesharpness}}
    end,
    calculate = function(self, card, context)
		if context.destroying_card and not context.blueprint and not context.retrigger_joker then
			if context.full_hand and #context.full_hand == 1 then
				if context.full_hand[1]:get_id() == 7 and context.full_hand[1].ability.name == 'Steel Card' then
					if card.ability.extra.axesharpness > 0 then
						G.E_MANAGER:add_event(Event({func = function()
							card:juice_up(0.8, 0.2)
							G.GAME.blind:juice_up(3,3)
							play_sound('slice1', 0.96+math.random()*0.08)
							change_blind_size(1)
						return true end }))
						card.ability.extra.axesharpness = math.max(0, card.ability.extra.axesharpness - 1)
						return true
					else
						local rng = math.random(#leviathan_blurbs.dull)
						if rng ~= 1 and #SMODS.find_card('j_jen_shikigami') <= 0 then
							rng = rng - 1
						end
						local blurb = leviathan_blurbs.dull[rng]
						card_status_text(card, blurb, nil, 0.05*card.T.h, G.C.RED, 0.6, 0.6, nil, nil, 'bm', 'cancel')
						if rng == #leviathan_blurbs.dull and #SMODS.find_card('j_jen_shikigami') > 0 then
							local shiki = SMODS.find_card('j_jen_shikigami')[1]
							if shiki then
								card_status_text(shiki, "What?! What did I do?", nil, 0.05*shiki.T.h, G.C.GREY, 0.6, 0.6, nil, nil, 'bm', 'generic1')
								card_status_text(card, "Nothing, I just like riling you up.", nil, 0.05*card.T.h, G.C.GREY, 0.6, 0.6, nil, nil, 'bm', 'generic1')
								card_status_text(shiki, "Oh, harr, harr, harr... real funny...", nil, 0.05*shiki.T.h, G.C.GREY, 0.6, 0.6, nil, nil, 'bm', 'generic1')
								card_status_text(card, "Although I might actually blame you if you don't shut up.", nil, 0.05*card.T.h, G.C.GREY, 0.6, 0.6, nil, nil, 'bm', 'generic1')
								card_status_text(shiki, "I'M NOT DOING ANYTHING WRONG-", nil, 0.05*shiki.T.h, G.C.RED, 0.6, 0.6, nil, nil, 'bm', 'generic1')
								card_status_text(card, "I said, shut up.", nil, 0.05*card.T.h, G.C.GREY, 0.6, 0.6, nil, nil, 'bm', 'generic1')
								card_status_text(shiki, "...Hmph...", nil, 0.05*shiki.T.h, G.C.GREY, 0.6, 0.6, nil, nil, 'bm', 'generic1')
								card_status_text(card, "Better.", nil, 0.05*card.T.h, G.C.GREY, 0.6, 0.6, nil, nil, 'bm', 'generic1')
							end
						end
					end
				elseif context.full_hand[1].ability.name == 'Stone Card' and card.ability.extra.axesharpness < leviathan_maxsharpness then
					card.ability.extra.axesharpness = math.min(card.ability.extra.axesharpness + 1, leviathan_maxsharpness)
					local rng = math.random(#leviathan_blurbs.sharpen)
					if rng ~= 1 and #SMODS.find_card('j_jen_shikigami') <= 0 then
						rng = rng - 1
					end
					local blurb = leviathan_blurbs.sharpen[rng]
					card_status_text(card, blurb, nil, 0.05*card.T.h, G.C.RED, 0.6, 0.6, nil, nil, 'bm', 'jen_grindstone')
					if rng == #leviathan_blurbs.sharpen and #SMODS.find_card('j_jen_shikigami') > 0 then
						local shiki = SMODS.find_card('j_jen_shikigami')[1]
						if shiki then
							card_status_text(shiki, "Huh? What whetstone?", nil, 0.05*shiki.T.h, G.C.GREY, 0.6, 0.6, nil, nil, 'bm', 'generic1')
							card_status_text(card, "This one.", nil, 0.05*card.T.h, G.C.GREY, 0.6, 0.6, nil, nil, 'bm', 'generic1')
							card_status_text(shiki, "What are you- I didn't get you that!", nil, 0.05*shiki.T.h, G.C.GREY, 0.6, 0.6, nil, nil, 'bm', 'generic1')
							card_status_text(card, "I know, that's the point.", nil, 0.05*card.T.h, G.C.GREY, 0.6, 0.6, nil, nil, 'bm', 'generic1')
							card_status_text(shiki, "...What?", nil, 0.05*shiki.T.h, G.C.GREY, 0.6, 0.6, nil, nil, 'bm', 'generic1')
							card_status_text(card, "The point is that you hardly help.", nil, 0.05*card.T.h, G.C.GREY, 0.6, 0.6, nil, nil, 'bm', 'generic1')
							card_status_text(shiki, "OH COME ON!", nil, 0.05*shiki.T.h, G.C.RED, 0.6, 0.6, nil, nil, 'bm', 'generic1')
							card_status_text(card, "Heheheh...", nil, 0.05*card.T.h, G.C.GREY, 0.6, 0.6, nil, nil, 'bm', 'generic1')
						end
					end
					return true
				end
			end
		end
	end
}

SMODS.Joker {
	key = 'behemoth',
	loc_txt = {
		name = 'Behemoth',
		text = {
			'{X:black,C:red,s:3}^^^#1#{C:purple} Chips & Mult{} if played hand',
			'contains {C:attention}four or more 7s{}',
			' ',
			"{C:inactive,s:1.11,E:1}Don't poke a tiger in its{}",
			"{C:inactive,s:1.11,E:1}rest; not even a cub...{}",
			'{C:dark_edition,s:0.7,E:2}Face art by : raidoesthings{}'
		}
	},
	config = {extra = {pentation = 1.77}},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 50,
	rarity = 'cry_exotic',
	set_card_type_badge = sevensins,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	immune_to_chemach = true,
	atlas = 'jenbehemoth',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.pentation}}
    end,
    calculate = function(self, card, context)
		if context.cardarea == G.jokers and not context.before and not context.after then
			local cards = G.play.cards
			local sevens = 0
			for k, v in pairs(cards) do
				if v:get_id() == 7 then
					sevens = sevens + 1
					if sevens >= 4 then break end
				end
			end
			if sevens >= 4 then
				return {
					message = 'Hrraaaaagh!!! (^^^' .. card.ability.extra.pentation .. ' Chips & Mult)',
					EEEmult_mod = card.ability.extra.pentation,
					EEEchip_mod = card.ability.extra.pentation,
					colour = G.C.BLACK,
					card = card
				}
			end
		end
	end
}

local cuc = Card.use_consumeable

function Card:use_consumeable(area, copier)
	for k, v in ipairs(G.handlist) do
		if math.ceil(G.GAME.hands[v].level) ~= G.GAME.hands[v].level then
			level_up_hand(nil, v, true, math.ceil(G.GAME.hands[v].level) - G.GAME.hands[v].level)
		end
		if G.GAME.hands[v].level < 1 then
			level_up_hand(nil, v, true, math.abs(G.GAME.hands[v].level) + 1)
		end
	end
	cuc(self, area, copier)
end

local food_jokers = {
	'egg',
	'popcorn',
	'ice_cream',
	'sdm_pizza',
	'sdm_burger',
	'turtle_bean',
	'ramen',
	'seltzer',
	'gros_michel',
	'cavendish',
	'cry_pickle',
	'cry_oldcandy',
	'cry_chili_pepper',
	'cry_caramel',
	'cry_crustulum'
}

local function numfoodjokers()
	if not G.jokers then return 0 end
	local amount = 0
	for k, v in pairs(food_jokers) do
		local amnt = #SMODS.find_card('j_' .. v)
		if amnt > 0 then
			amount = amount + (amnt * (v == 'sdm_pizza' and 3 or 1))
		end
	end
	return amount
end

local peppino_desc = (SMODS.Mods['sdm'] and
	{
		'{X:dark_edition,C:red}^x2{C:red} Mult{} for every',
		'{C:attention}food Joker{} in your possession',
		'{X:green,C:white}Synergy:{C:attention} Pizza{} counts as {C:blue}3{} food jokers',
		'{C:inactive}(Currently {X:dark_edition,C:red}^#1#{C:red} Mult{C:inactive}){}',
		' ',
		'{C:inactive,s:0.8,E:1}Okay, you look-a right-e here!{}',
		'{C:inactive,s:0.8,E:1}I baked that into a pizza ONCE-a, and-a nobody can ever know-a!{}',
		'{C:inactive,s:0.8,E:1}Not even the health inspector... Capeesh-e?{}'
	}
or
	{
		'{X:dark_edition,C:red}^x2{C:red} Mult{} for every',
		'{C:attention}food Joker{} in your possession',
		'{C:inactive}(Currently {X:dark_edition,C:red}^#1#{C:red} Mult{C:inactive}){}',
		' ',
		'{C:inactive,s:0.8,E:1}Okay, you look-a right-e here!{}',
		'{C:inactive,s:0.8,E:1}I baked that into a pizza ONCE-a, and-a nobody can ever know-a!{}',
		'{C:inactive,s:0.8,E:1}Not even the health inspector... Capeesh-e?{}'
	}
)

SMODS.Joker {
	key = 'peppino',
	loc_txt = {
		name = 'Peppino Spaghetti',
		text = peppino_desc
	},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 50,
	rarity = 'cry_exotic',
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	atlas = 'jenpeppino',
    loc_vars = function(self, info_queue, center)
        return {vars = {2 ^ numfoodjokers()}}
    end,
    calculate = function(self, card, context)
		local food = numfoodjokers()
		if context.cardarea == G.jokers and not context.before and not context.after and food > 0 then
			local power = 2 ^ food
			return {
				message = '^' .. power .. ' Mult',
				Emult_mod = power,
				colour = G.C.DARK_EDITION
			}
		end
	end
}

local function totalnoise()
	return #((G.jokers or {}).cards or {}) + #((G.hand or {}).cards or {})
end

SMODS.Joker {
	key = 'noise',
	loc_txt = {
		name = 'The Noise',
		text = {
			"{C:red}Warning : This Joker can easily cause crashes if you're not careful!",
			' ',
			'Retrigger {C:attention}all{} scored cards {C:attention}once{}',
			'for every {C:attention}Joker{} you have {C:green}plus{}',
			'{C:attention}once{} for every card in your hand',
			'{C:inactive}(Currently {C:attention}#1#{C:inactive} time(s)){}',
			' ',
			'{C:inactive,s:0.8,E:1}Hey-a! Howsabout a nice ride in this{}',
			'{C:inactive,s:0.8,E:1}washing machine here? Admission is freeeee!{}'
		}
	},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 50,
	rarity = 'cry_exotic',
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = false,
	atlas = 'jennoise',
    loc_vars = function(self, info_queue, center)
        return {vars = {totalnoise()}}
    end,
    calculate = function(self, card, context)
		if not context.blueprint_card then
			if context.repetition then
				if context.cardarea == G.play then
					return {
						message = 'Woag!',
						repetitions = totalnoise(),
						colour = G.C.YELLOW,
						nopeus_again = true,
						card = card
					}
				end
			end
		end
	end
}

local function sixesinhand()
	if not G.hand then return 0 end
	local amnt = 0
	if #G.hand.cards > 0 then
		for k, v in pairs(G.hand.cards) do
			if v:get_id() == 6 then
				amnt = amnt + 1
			end
		end
	end
	return amnt
end

SMODS.Joker {
	key = 'doomguy',
	loc_txt = {
		name = 'Doomguy',
		text = {
			'{X:red,C:white}x#1#{C:red} Mult{}',
			'Multiplied by {C:attention}x#2#{} for every {C:attention}6{}',
			'in your hand',
			'{C:inactive}(Currently {X:red,C:white}x#3#{C:red} Mult{C:inactive}){}',
			' ',
			"{C:inactive,s:1.2,E:1}Check out this big fucking gun.{}"
		}
	},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	config = {extra = {mul = 9000, mulmul = 2}},
	cost = 20,
	set_card_type_badge = gaming,
	rarity = 4,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = false,
	atlas = 'jendoomguy',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.mul, center.ability.extra.mulmul, center.ability.extra.mul * (center.ability.extra.mulmul ^ sixesinhand())}}
    end,
    calculate = function(self, card, context)
		if context.cardarea == G.jokers then
			local amnt = sixesinhand()
			local mult = card.ability.extra.mul * (card.ability.extra.mulmul ^ amnt)
			card.ability.x_mult = mult
		end
	end
}

SMODS.Joker {
	key = 'freddy',
	loc_txt = {
		name = 'Freddy Snowshoe',
		text = {
			'Gives a {C:attention}unique{}, {C:blue}reusable {C:green}Ability{}',
			'card that can {C:money}sell playing cards in hand{}',
			'{X:green,C:white}Synergy:{} {X:dark_edition,C:red}^#1#{C:red} Mult{} if',
			'you have {X:attention,C:black}Heket{}',
			' ',
			"{C:inactive,s:1.2,E:1}It's nice to be a guest here!{}",
			"{C:inactive,s:1.1,E:1}... So... where's the snack bar?{}",
		}
	},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	config = {extra = {synergy_mult = 1.25}},
	cost = 12,
	rarity = 'cry_epic',
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = false,
	atlas = 'jenfreddy',
	abilitycard = 'c_jen_freddy_c',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.synergy_mult}}
    end,
    calculate = function(self, card, context)
		if #SMODS.find_card('j_jen_heket') > 0 then
			if context.cardarea == G.jokers and not context.before and not context.after then
				return {
					message = 'Hey, babe! (^' .. card.ability.extra.synergy_mult .. ' Mult)',
					Emult_mod = card.ability.extra.synergy_mult,
					colour = G.C.DARK_EDITION
				}
			end
		end
	end
}

local function sellvalueofhighlightedhandcards()
	if not G.hand then return 0 end
	local value = 0
	for k, v in pairs(G.hand.highlighted) do
		value = value + (v.sell_cost or 0)
	end
	return value
end

SMODS.Consumable {
	key = 'freddy_c',
	loc_txt = {
		name = 'Possession Offering',
		text = {
			'{C:money}Sells{} all {C:blue}selected{}',
			'{C:attention}playing cards{}',
			'{X:dark_edition,C:white}Negative{} {X:dark_edition,C:white}Ability:{} Gain an additional {C:money}$5{}',
			'{C:inactive}(Selection value : {X:money,C:white}$#1#{C:inactive}){}'
		}
	},
	config = {},
	set = 'jen_jokerability',
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 0,
	unlocked = true,
	discovered = true,
	hidden = true,
	no_doe = true,
	soul_rate = 0,
	atlas = 'jenfreddy_c',
    loc_vars = function(self, info_queue, center)
        return {vars = {sellvalueofhighlightedhandcards()}}
    end,
	can_use = function(self, card)
		return ((card.edition or {}).negative or #G.hand.highlighted > 0) and (#G.hand.highlighted < #G.hand.cards) and abletouseabilities()
	end,
	keep_on_use = function(self, card)
		return #SMODS.find_card('j_jen_freddy') > 0 and not (card.edition or {}).negative
	end,
	use = function(self, card, area, copier)
		if #G.hand.highlighted > 0 then
			play_sound('coin2')
			card:juice_up(0.3, 0.4)
			for k, v in pairs(G.hand.highlighted) do
				if v ~= card then
					v:sell_card()
				end
			end
			if #G.hand.cards - #G.hand.highlighted < G.hand.config.card_limit and #G.deck.cards > 0 then
				for i = 1, math.min(G.hand.config.card_limit - (#G.hand.cards - #G.hand.highlighted), #G.deck.cards) do
					draw_card(G.deck,G.hand, 1, nil, true, nil, 0.07)
				end
			end
		end
		if (card.edition or {}).negative then
			ease_dollars(5)
		end
	end
}

SMODS.Joker {
	key = 'poppin',
	loc_txt = {
		name = 'Paupovlin Revere',
		text = {
			'You can choose {C:attention}any number of cards{}',
			'after opening {C:attention}any Booster Pack{}',
			'{C:attention}Booster Packs{} have {C:green}+#1#{} additional card(s)',
			' ',
			'{C:inactive,s:1.1,E:1}I am the most well-equipped{}',
			'{C:inactive,s:1.1,E:1}ladybug in all of Synnia!{}'
		}
	},
	config = {extra = {extrachoices = 1}},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 12,
	rarity = 'cry_epic',
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = false,
	immune_to_chemach = true,
	atlas = 'jenpoppin',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.extrachoices}}
    end
}

local cor = Card.open

function Card:open()
	local poppins = #SMODS.find_card('j_jen_poppin')
	if poppins > 0 then
		for k, v in pairs(SMODS.find_card('j_jen_poppin')) do
			self.ability.extra = (self.ability.extra or 1) + v.ability.extra.extrachoices
		end
		self.config.choose = self.ability.extra
	end
	cor(self)
	G.E_MANAGER:add_event(Event({delay = 0.5, timer = 'REAL', func = function()
		if poppins > 0 then
			G.GAME.pack_choices = self.ability.extra --fix for misprint, i'm hoping
		end
		return true
	end }))
end

local rai_desc = (SMODS.Mods['sdm'] and
	{
		'{C:attention}Jokers{} become {C:dark_edition}Negative{}',
		'when added to possession',
		'{X:green,C:white}Synergy:{} {X:jen_RGB,C:white,s:1.5}+^^#1#{C:mult} Mult{}',
		'for every {X:attention,C:black}Burger{} owned',
		'{C:inactive}(Currently {X:jen_RGB,C:white,s:1.5}^^#2#{C:inactive}){}',
		' ',
		'{C:inactive,s:1.8,E:1}I do things.{}',
		'{C:inactive,s:0.7,E:1}If I do not, then I will spontaneously combust.{}'
	}
or
	{
		'{C:attention}Jokers{} become {C:dark_edition}Negative{}',
		'when added to possession',
		' ',
		'{C:inactive,s:1.8,E:1}I do things.{}',
		'{C:inactive,s:0.7,E:1}If I do not, then I will spontaneously combust.{}'
	}
)

SMODS.Joker {
	key = 'rai',
	loc_txt = {
		name = 'Rai',
		text = rai_desc
	},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	config = {extra = {bouigah = 0.88}},
	cost = 50,
	rarity = 'cry_exotic',
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = false,
	atlas = 'jenrai',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.bouigah, 1 + (center.ability.extra.bouigah * #SMODS.find_card('j_sdm_burger'))}}
    end,
    calculate = function(self, card, context)
		if context.jen_adding_card and not context.blueprint_card then
			if context.card.ability.set == 'Joker' and not ((context.card or {}).edition or {}).negative then
				card_eval_status_text(card, 'extra', nil, nil, nil, {
					message = context.card.ability.name == 'Burger' and 'Bouigah!' or 'Negation!',
					colour = G.C.DARK_EDITION,
				})
				G.E_MANAGER:add_event(Event({
					func = function()
						context.card:set_edition({negative = true}, true)
						return true
					end
				}))
			end
		end
		if #SMODS.find_card('j_sdm_burger') > 0 then
			if context.cardarea == G.jokers and not context.before and not context.after then
				local num = 1 + (card.ability.extra.bouigah ^ #SMODS.find_card('sdm_burger'))
				return {
					message = 'Bouigah! (^^' .. num .. ' Mult)',
					colour = G.C.jen_RGB,
					EEmult_mod = num
				}
			end
		end
	end
}

local rangers_flavour = {'Bam!', 'Pow!', 'Boom!', 'Kapow!', 'Chik-bhwm!'}

SMODS.Joker {
	key = 'rangers',
	loc_txt = {
		name = 'Rangers',
		text = {
			'{C:attention}Retrigger{} scored {C:attention}8{}s',
			'{C:attention}88{} times',
			' ',
			"{C:inactive,s:1.2,E:1}Eighty-eight rounds. No compromise.{}",
			"{C:inactive,s:1.2,E:1}Any questions? Didn't think so.{}"
		}
	},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 20,
	rarity = 4,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = false,
	atlas = 'jenrangers',
    calculate = function(self, card, context)
		if not context.blueprint_card then
			if context.repetition then
				if context.cardarea == G.play then
					if context.other_card:get_id() == 8 then
						return {
							message = rangers_flavour[math.random(#rangers_flavour)],
							repetitions = 88,
							nopeus_again = true,
							colour = G.C.RED,
							card = card
						}
					end
				end
			end
		end
	end
}

SMODS.Joker {
	key = 'jen',
	loc_txt = {
		name = 'Jen Walter',
		text = {
			'{C:blue}+1 Chip{C:inactive,E:1}...?{}',
			' ',
			"{C:inactive,s:1.8,E:1}#1#{}"
		}
	},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 1,
	rarity = 1,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = false,
	atlas = 'jenjen',
    loc_vars = function(self, info_queue, center)
        return {vars = {hasgodsmarble() and 'i feel funny...' or "i'm trying..."}}
    end,
    calculate = function(self, card, context)
		if not context.blueprint_card then
			if context.cardarea == G.jokers and not context.before and not context.after then
				if #SMODS.find_card('j_jen_rai') > 0 and #SMODS.find_card('j_jen_rangers') > 0 then
					return {
						message = '^1e100 Mult',
						Emult_mod = 1e100,
						colour = G.C.DARK_EDITION
					}
				elseif #SMODS.find_card('j_jen_rai') > 0 or #SMODS.find_card('j_jen_rangers') > 0 then
					return {
						message = 'x777',
						Xchip_mod = 777,
						colour = G.C.CHIPS
					}
				else
					return {
						message = '+1',
						chip_mod = 1,
						colour = G.C.CHIPS
					}
				end
			end
		end
	end
}

--[[

SMODS.Joker {
	key = 'math',
	loc_txt = {
		name = 'Math Mathew',
		text = {
			'Provides a base of {C:chips}#1# Chips{} and {C:mult}#2# Mult{}',
			'Final amount is based on a {C:attention}mathematical operation{}',
			'using the {C:attention}scored cards{}',
			'{C:inactive}(Experiment with playing cards to learn more){}'
			"{C:inactive,s:1.8,E:1}Math is fun.{}"
		}
	},
	config = {extra = {basechips = 500, basemult = 50}},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 20,
	rarity = 4,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = false,
	atlas = 'jenmath',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.basechips, center.ability.extra.basemult}}
    end,
    calculate = function(self, card, context)
		if not context.blueprint_card then
			local equation = {
				text = '',
				add = {},
				subtract = {},
				multiply = {},
				exponentiate = {}
			}
			if context.cardarea == G.jokers and not context.before and not context.after then
				if #SMODS.find_card('j_jen_rai') > 0 and #SMODS.find_card('j_jen_rangers') > 0 then
					return {
						message = '^1e100 Mult',
						Emult_mod = 1e100,
						colour = G.C.DARK_EDITION
					}
				elseif #SMODS.find_card('j_jen_rai') > 0 or #SMODS.find_card('j_jen_rangers') > 0 then
					return {
						message = 'x777',
						Xchip_mod = 777,
						colour = G.C.CHIPS
					}
				else
					return {
						message = '+1',
						chip_mod = 1,
						colour = G.C.CHIPS
					}
				end
			end
		end
	end
}

]]

SMODS.Joker {
	key = 'jess',
	loc_txt = {
		name = 'Jess',
		text = {
			'Add {C:attention}#1#{} {C:dark_edition}Negative{}',
			'copies of {C:spectral}Spectral{} card(s)',
			'when adding {C:attention}non-{C:dark_edition}Negative{}',
			'versions to your possession',
			' ',
			"{C:inactive,s:1.3,E:1}Nice computer you've got there!{}",
			"{C:inactive,s:1.5,E:1}Can I have it?{}"
		}
	},
	config = {extra = {copies = 2}},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 20,
	rarity = 4,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = false,
	immune_to_chemach = true,
	atlas = 'jenjess',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.copies}}
    end,
    calculate = function(self, card, context)
		if context.jen_adding_card and not context.blueprint_card then
			if context.card.ability.set == 'Spectral' and not ((context.card or {}).edition or {}).negative and not context.card.created_from_split then
				local amount = math.floor(card.ability.extra.copies)
				if amount > 0 then
					card_eval_status_text(card, 'extra', nil, nil, nil, {
						message = 'Blep!',
						colour = G.C.BLUE,
					})
					G.E_MANAGER:add_event(Event({
						func = function()
							new_card = create_card('Spectral', G.consumeables, nil, nil, nil, nil, context.card.config.center.key, nil)
							new_card:set_edition({negative = true}, true)
							new_card:setQty(amount)
							new_card:add_to_deck()
							G.consumeables:emplace(new_card)
							return true
						end
					}))
				end
			end
			return {calculated=true}
		end
	end
}

SMODS.Joker {
	key = 'spice',
	loc_txt = {
		name = 'Spice',
		text = {
			'Add {C:attention}#1#{} {C:dark_edition}Negative{}',
			'copies of {C:tarot}Tarot{} card(s)',
			'when adding {C:attention}non-{C:dark_edition}Negative{}',
			'versions to your possession',
			' ',
			"{C:inactive,s:1.2,E:1}I can whack animals from behind.{}"
		}
	},
	config = {extra = {copies = 4}},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 20,
	rarity = 4,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = false,
	immune_to_chemach = true,
	atlas = 'jenspice',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.copies}}
    end,
    calculate = function(self, card, context)
		if context.jen_adding_card and not context.blueprint_card then
			if context.card.ability.set == 'Tarot' and not ((context.card or {}).edition or {}).negative and not context.card.created_from_split then
				local amount = math.floor(card.ability.extra.copies)
				if amount > 0 then
					card_eval_status_text(card, 'extra', nil, nil, nil, {
						message = 'Racking it up!',
						colour = G.C.PURPLE,
					})
					G.E_MANAGER:add_event(Event({
						func = function()
							new_card = create_card('Tarot', G.consumeables, nil, nil, nil, nil, context.card.config.center.key, nil)
							new_card:set_edition({negative = true}, true)
							new_card:setQty(amount)
							new_card:add_to_deck()
							G.consumeables:emplace(new_card)
							return true
						end
					}))
				end
			end
			return {calculated=true}
		end
	end
}	

local nyx_maxenergy = 4

SMODS.Joker {
	key = 'nyx',
	loc_txt = {
		name = 'Nyx Equinox',
		text = {
			'{X:inactive}Energy{} : {C:attention}#1#{C:inactive} / ' .. tostring(nyx_maxenergy) .. '{}',
			'Selling a {C:attention}Joker {C:inactive}(excluding this one){} or {C:attention}consumable{} will',
			'{C:attention}create a new random one{} of the {C:attention}same type/rarity{}',
			'{s:0.7}Drag to {C:attention,s:0.7}rightmost{s:0.7} position to manually disable{}',
			'{C:inactive}(Does not require slots, but may overflow, retains edition){}',
			'{C:inactive}(Does not work on fusions or jokers better than Exotic){}',
			' ',
			'Recharges {C:attention}' .. math.ceil(nyx_maxenergy/3) .. ' energy{} at',
			'the end of every {C:attention}Ante{}',
			' ',
			"{C:inactive,s:1.2,E:1}#2#{}",
			'{C:dark_edition,s:0.7,E:2}Face art by : ThreeCubed{}'
		}
	},
	config = {extra = {energy = nyx_maxenergy}},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 250,
	rarity = 'cry_exotic',
	set_card_type_badge = ritualistic,
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	immune_to_chemach = true,
	atlas = 'jennyx',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.energy, hasgodsmarble() and "Give me-... the marble. I-I've... earned it." or "Don't you wanna seem like you're divine?"}}
    end,
    calculate = function(self, card, context)
		if not context.individual and not context.repetition and not card.debuff and context.end_of_round and not context.blueprint and G.GAME.blind.boss and not (G.GAME.blind.config and G.GAME.blind.config.bonus) then
			card.ability.extra.energy = math.min(card.ability.extra.energy + math.ceil(nyx_maxenergy/3), nyx_maxenergy)
			card_status_text(card, card.ability.extra.energy .. '/' .. nyx_maxenergy, nil, 0.05*card.T.h, G.C.GREEN, 0.6, 0.6, nil, nil, 'bm', 'generic1')
		elseif context.selling_card and not context.selling_self then
			local targetslot = #G.jokers.cards
			if G.jokers.cards[targetslot] and G.jokers.cards[targetslot] ~= card and (G.jokers.cards[targetslot].ability.name == 'j_jen_nyx' or G.jokers.cards[targetslot].ability.name == 'j_jen_paragon') then
				while true do
					targetslot = targetslot - 1
					if targetslot <= 0 then
						break
					elseif G.jokers.cards[targetslot] then
						if G.jokers.cards[targetslot] == card or (G.jokers.cards[targetslot].ability.name ~= 'j_jen_nyx' or G.jokers.cards[targetslot].ability.name ~= 'j_jen_paragon') then
							break
						end
					end
				end
			end
			if card ~= G.jokers.cards[targetslot] then
				if card.ability.extra.energy > 0 then
					local c = context.card
					local valid = c.ability.set ~= 'Joker' or type(c.config.center.rarity) == 'string' or (c.config.center.rarity >= 1 and c.config.center.rarity <= 4)
					if not c.config.center.immune_to_nyx and valid and not c.playing_card then
						local new = 'n/a'
						if c.ability.set == 'Joker' then
							local rarity = c.config.center.rarity
							local legendary = false
							if rarity == 1 then
								rarity = 0
							elseif rarity == 2 then
								rarity = 0.9
							elseif rarity == 3 then
								rarity = 0.99
							elseif rarity == 4 then
								rarity = nil
								legendary = true
							elseif rarity == 'cry_epic' then
								rarity = 1
							end
							new = create_card(c.ability.set, c.area, legendary, rarity, nil, nil, nil, 'nyx_replacement')
						else
							new = create_card(c.ability.set, c.area, nil, nil, nil, nil, nil, 'nyx_replacement')
						end
						if c.edition then
							new:set_edition(c.edition)
						end
						if c.ability.set ~= 'Joker' and c:getQty() > 1 then
							new:setQty(c:getQty())
							new:create_stack_display()
						end
						new:add_to_deck()
						c.area:emplace(new)
						if noretriggers(context) then
							card.ability.extra.energy = card.ability.extra.energy - 1
							card_status_text(card, card.ability.extra.energy .. '/' .. nyx_maxenergy, nil, 0.05*card.T.h, G.C.FILTER, 0.6, 0.6, nil, nil, 'bm', 'generic1')
						end
						return {calculated=true}
					end
				elseif noretriggers(context) then
					card_status_text(card, 'No energy!', nil, 0.05*card.T.h, G.C.RED, 0.6, 0.6, nil, nil, 'bm', 'cancel')
				end
			end
		end
	end
}

SMODS.Joker {
	key = 'survivor',
	loc_txt = {
		name = 'The Survivor',
		text = {
			'{C:planet}Levels up{} the {C:attention}lowest level poker hand{}',
			'by the {C:attention}sum of your remaining{}',
			'{C:blue}hands {C:attention}and {C:red}discards{} at',
			'the {C:attention}end of the round{}',
			'{C:inactive}(Prioritises lower-ranking hands){}'
		}
	},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 12,
	rarity = 'cry_epic',
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	atlas = 'jensurvivor',
    calculate = function(self, card, context)
		if not context.individual and not context.repetition and not card.debuff and context.end_of_round then
			card.cumulative_lvs = (card.cumulative_lvs or 0) + (G.GAME.current_round.hands_left + G.GAME.current_round.discards_left)
			if noretriggers(context) then
				card:apply_cumulative_levels(get_lowest_level_hand())
			end
			return {calculated = true}
		end
	end
}

SMODS.Joker {
	key = 'monk',
	loc_txt = {
		name = 'The Monk',
		text = {
			'{C:attention}Retrigger{} scored cards,',
			"using the {C:attention}card's rank{}",
			'as the {C:attention}number of times to retrigger{}',
			'{C:inactive}(ex. 9 = 9 times, Jack = 11 times, Ace = 14 times, etc.){}'
		}
	},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 12,
	rarity = 'cry_epic',
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	atlas = 'jenmonk',
    calculate = function(self, card, context)
		if context.repetition then
			if context.cardarea == G.play then
				if context.other_card and context.other_card.ability.name ~= 'Stone Card' then
					return {
						message = localize('k_again_ex'),
						repetitions = context.other_card:get_id(),
						colour = G.C.ORANGE,
						card = card
					}
				end
			end
		end
	end
}

SMODS.Joker {
	key = 'hunter',
	loc_txt = {
		name = 'The Hunter',
		text = {
			'{C:dark_edition}Infinite {C:blue}hands',
			'{C:red,s,E:1}Succumbs to the Rot after #1#{}',
			'{C:inactive}(Selling this card at 7 rounds remaining or less also creates the Rot){}'
		}
	},
	config = {rounds_left = 10},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 20,
	rarity = 4,
	unlocked = true,
	discovered = true,
	immune_to_chemach = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = false,
	atlas = 'jenhunter',
    loc_vars = function(self, info_queue, center)
        return {vars = {tostring(center.ability.rounds_left) .. ' round' .. ((math.abs(center.ability.rounds_left) > 1 or math.abs(center.ability.rounds_left) == 0) and 's' or '') .. (center.ability.rounds_left <= 0 and '...?' or '')}}
    end,
    calculate = function(self, card, context)
		if not context.blueprint then
			if context.selling_self and card.ability.rounds_left < 8 then
					
			elseif not context.individual and not context.repetition and not context.retrigger_joker then
				if G.GAME.round_resets.hands <= 0 then G.GAME.round_resets.hands = 1 end
				if G.GAME.current_round.hands_left ~= G.GAME.round_resets.hands then
					G.GAME.current_round.hands_left = G.GAME.round_resets.hands
				end
				if context.end_of_round then
					card.ability.rounds_left = card.ability.rounds_left - 1
					local rl = card.ability.rounds_left
					card_status_text(card, tostring(card.ability.rounds_left), nil, nil, G.C.RED, nil, nil, nil, nil, nil, 'generic1')
					if rl > 7 then
						if card.children then
							if card.children.center then
								card.children.center:set_sprite_pos({x = 0, y = 0})
							end
							if card.children.floating_sprite then
								card.children.floating_sprite:set_sprite_pos({x = 1, y = 0})
							end
						end
					elseif rl > 5 then
						if card.children then
							if card.children.center then
								card.children.center:set_sprite_pos({x = 0, y = 1})
							end
							if card.children.floating_sprite then
								card.children.floating_sprite:set_sprite_pos({x = 1, y = 1})
							end
						end
					elseif rl > 3 then
						if card.children then
							if card.children.center then
								card.children.center:set_sprite_pos({x = 0, y = 2})
							end
							if card.children.floating_sprite then
								card.children.floating_sprite:set_sprite_pos({x = 1, y = 2})
							end
						end
					elseif rl > 1 then
						if card.children then
							if card.children.center then
								card.children.center:set_sprite_pos({x = 0, y = 3})
							end
							if card.children.floating_sprite then
								card.children.floating_sprite:set_sprite_pos({x = 1, y = 3})
							end
						end
						card:juice_up(0.6, 0.1)
						play_sound_q('jen_heartbeat')
					elseif rl > 0 then
						if card.children then
							if card.children.center then
								card.children.center:set_sprite_pos({x = 0, y = 4})
							end
							if card.children.floating_sprite then
								card.children.floating_sprite:set_sprite_pos({x = 1, y = 4})
							end
						end
						card:juice_up(1.8, 0.3)
						play_sound_q('jen_heartbeat')
					else
						if card.children then
							if card.children.center then
								card.children.center:set_sprite_pos({x = 0, y = 4})
							end
							if card.children.floating_sprite then
								card.children.floating_sprite:set_sprite_pos({x = 1, y = 4})
							end
						end
						local rolls = math.min(5, math.ceil(math.abs(rl) / 3)) + 2
						local DELAY = 270
						local CHANCE = math.max(10, 25.1 - (math.abs(rl) / 10))
						G.E_MANAGER:add_event(Event({
							trigger = 'after',
							func = function()
								if DELAY <= 0 then
									if chance('hunter_rot', CHANCE) then
										card:flip()
										card_status_text(card, 'Dead!', nil, 0.05*card.T.h, G.C.BLACK, 2, 0, 0, nil, 'bm', 'jen_hurt' .. math.random(3))
										G.E_MANAGER:add_event(Event({
											func = function()
												local card2 = create_card('Joker', G.jokers, nil, nil, nil, nil, 'j_jen_rot', 'hunter_rot_death')
												card2:add_to_deck()
												G.jokers:emplace(card2)
												card:set_eternal(nil)
												card2:set_eternal(true)
												card:start_dissolve()
												return true
											end
										}))
										rolls = 0
										DELAY = 270
									else
										if rolls == 1 then
											card:juice_up(0.6, 0.1)
											card_status_text(card, localize('k_safe_ex'), nil, 0.05*card.T.h, G.C.FILTER, math.min(1.5, 0.8 + (rolls / 10)), 0, 0, nil, 'bm', 'generic1')
										else
											card:juice_up(rolls/10, rolls/60)
											card_status_text(card, '...', nil, 0.05*card.T.h, G.C.RED, math.min(1.5, 0.8 + (rolls / 10)), 0, 0, nil, 'bm', 'jen_heartbeat')
										end
										rolls = rolls - 1
										DELAY = 270
									end
								else
									DELAY = DELAY - ((math.log(G.SETTINGS.GAMESPEED)+1)^2)
								end
							return rolls <= 0 and DELAY <= 0
						end} ))
					end
				end
			end
		end
	end
}

SMODS.Joker {
	key = 'gourmand',
	loc_txt = {
		name = 'The Gourmand',
		text = {
			'Retrigger the {C:attention}leftmost{} and',
			'{C:attention}rightmost{} Jokers {C:attention}#1#{} times',
			' ',
			'{C:inactive,s:1.5,E:1}Absolute unit!'
		}
	},
	config = {extra = {absolute_unit = 25}},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 20,
	rarity = 4,
	unlocked = true,
	discovered = true,
	immune_to_chemach = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	atlas = 'jengourmand',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.absolute_unit}}
    end,
	calculate = function(self, card, context)
        if context.retrigger_joker_check and not context.retrigger_joker and context.other_card ~= self then
			if context.other_card == G.jokers.cards[1] or context.other_card == G.jokers.cards[#G.jokers.cards] then
				return {
					message = localize('k_again_ex'),
					repetitions = card.ability.extra.absolute_unit,
					card = card
				}
			else
				return {calculated = true}
			end
        end
	end
}

SMODS.Joker {
	key = 'rivulet',
	loc_txt = {
		name = 'The Rivulet',
		text = {
			'Retrigger {C:attention}all Jokers{}, using its {C:attention}order {C:inactive}(left-to-right){}',
			'in the Joker tray as the {C:attention}number of times to retrigger{}',
			'{C:inactive}(ex. retrigger leftmost joker 1 time, next joker 2 times, one after 3 times, etc.){}'
		}
	},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 50,
	rarity = 'cry_exotic',
	unlocked = true,
	discovered = true,
	immune_to_chemach = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	atlas = 'jenrivulet',
	calculate = function(self, card, context)
        if context.retrigger_joker_check and not context.retrigger_joker and context.other_card ~= self then
			local retrigger_amount = 0
			for i = 1, #G.jokers.cards do
				if context.other_card == G.jokers.cards[i] then
					retrigger_amount = i
				end
			end
			if context.other_card == G.jokers.cards[retrigger_amount] then
				return {
					message = localize('k_again_ex'),
					repetitions = retrigger_amount,
					card = card
				}
			else
				return {calculated = true}
			end
        end
	end
}

local max_karma = 10

SMODS.Joker {
	key = 'saint',
	loc_txt = {
		name = 'The Saint',
		text = {
			'{C:spectral}Gateway{} will {C:attention}not destroy Jokers{} when used',
			'After using {C:attention}' .. tostring(max_karma) .. ' {C:spectral}Gateways{}, {C:jen_RGB}attune{} this Joker',
			'{C:inactive,s:1.5}[{C:attention,s:1.5}#1#{C:inactive,s:1.5}/' .. tostring(max_karma) .. ']{}'
		}
	},
	config = {extra = {karma = 0}},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 12,
	rarity = 'cry_epic',
	unlocked = true,
	discovered = true,
	immune_to_chemach = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = false,
	atlas = 'jensaint',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.karma}}
    end,
	calculate = function(self, card, context)
        if not context.blueprint and noretriggers(context) and context.using_consumeable and context.consumeable and context.consumeable.config.center.key == 'c_cry_gateway' then
			card.ability.extra.karma = card.ability.extra.karma + 1
			card_eval_status_text(card, 'extra', nil, nil, nil, {message = '+1 Karma', colour = G.C.PALE_GREEN})
			card_eval_status_text(card, 'extra', nil, nil, nil, {message = (tostring(card.ability.extra.karma) .. ' / ' .. tostring(max_karma)), colour = G.C.GREEN})
			if card.ability.extra.karma >= max_karma then
				card_status_text(card, '!!!', nil, 0.05*card.T.h, G.C.DARK_EDITION, 0.6, 0.6, 2, 2, 'bm', 'jen_enlightened')
				G.E_MANAGER:add_event(Event({
					delay = 0.1,
					func = function()
						card:flip()
						play_sound('card1')
						return true
					end
				}))
				G.E_MANAGER:add_event(Event({
					delay = 1,
					func = function()
						card:flip()
						card:juice_up(1, 1)
						play_sound('card1')
						card:set_ability(G.P_CENTERS['j_jen_saint_attuned'])
						return true
					end
				}))
			end
        end
	end
}

SMODS.Joker {
	key = 'saint_attuned',
	loc_txt = {
		name = 'The Saint {C:jen_RGB}(Attuned){}',
		text = {
			'{C:spectral}Gateway{} will {C:attention}not destroy Jokers{} when used',
			'{X:black,C:red,s:3}^^^#1#{C:purple} Chips & Mult{}'
		}
	},
	config = {extra = {ascension = 3}},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 2, y = 0 },
	cost = 100,
	rarity = 6,
	set_card_type_badge = transcendent,
	unlocked = true,
	discovered = true,
	no_doe = true,
	immune_to_chemach = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	atlas = 'jensaint',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.ascension}}
    end,
	calculate = function(self, card, context)
		if context.cardarea == G.jokers and not context.before and not context.after then
			return {
				message = '^^^' .. card.ability.extra.ascension .. ' Chips & Mult',
				EEEmult_mod = card.ability.extra.ascension,
				EEEchip_mod = card.ability.extra.ascension,
				colour = G.C.BLACK,
				card = card
			}
		end
	end
}

local totalownedcards_areastocheck = {
	'hand',
	'jokers',
	'consumeables',
	'deck',
	'discard',
	'play'
}

local function totalownedcards()
	local amnt = 0
	for k, v in pairs(totalownedcards_areastocheck) do
		if G[v] and G[v].cards then
			if G[v] == (G.consumeables or {}) then
				for kk, vv in pairs(G[v].cards) do
					amnt = amnt + vv:getQty()
				end
			else
				amnt = amnt + #G[v].cards
			end
		end
	end
	return amnt
end

--[[
SMODS.Joker {
	key = 'artificer',
	loc_txt = {
		name = 'The Artificer',
		text = {
			"Grants the {C:green}ability{} to {C:red}destroy{}",
			"selected {C:attention}playing cards{} or {C:attention}Jokers{}",
			"in exchange for {C:attention}varying benefits/upgrades{}"
		}
	},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 20,
	rarity = 4,
	unlocked = true,
	discovered = true,
	immune_to_chemach = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = false,
	atlas = 'jenartificer',
	abilitycard = 'c_jen_artificer_c',
    loc_vars = function(self, info_queue, center)
        return {vars = {totalownedcards()}}
    end,
	add_to_deck = function(self, card, from_debuff)
		card.ability.lvmod = totalownedcards()
		lvupallhands(card.ability.lvmod, card)
	end,
	remove_from_deck = function(self, card, from_debuff)
		if not card.ability.lvmod then card.ability.lvmod = 0 end
		if card.ability.lvmod > 0 then
			lvupallhands(-card.ability.lvmod, card)
		end
	end,
	calculate = function(self, card, context)
        if noretriggers(context) and not context.blueprint then
			if not card.ability.lvmod then card.ability.lvmod = 0 end
			local amnt = totalownedcards()
			if amnt ~= card.ability.lvmod then
				lvupallhands(amnt - card.ability.lvmod, card, true)
				card.ability.lvmod = amnt
			end
        end
	end
}

SMODS.Consumable {
	key = 'artificer_c',
	loc_txt = {
		name = 'Pyrotechnic Engineering',
		text = {
			'{C:red}Destroys{} all selected playing cards, giving various effects',
			"{C:inactive}(R = destroyed card's rank)",
			'{C:hearts}Hearts{} : All hands receive {X:mult,C:white}x(1 + (R/10)){} Mult',
			'{C:spades}Spades{} : All hands receive {X:chips,C:white}x(1 + (R/20)){} Chips',
			'{C:diamonds}Diamonds{} : Create {C:attention}R {C:tarot}Tarots{}/{C:spectral}Spectrals{}/{C:planet}Planets {C:inactive}(does not require room){}',
			'{C:clubs}Clubs{} : {C:planet}Level up{} all hands {C:attention}R{} times',
			'{C:jen_RGB}Wilds{} : {C:purple}Applies all of the above{}',
			'{X:inactive}Stones{} : All other {C:attention}playing cards{} gain {C:chips}+500{} bonus chips',
			' ',
			'{X:dark_edition,C:white}Negative{} {X:dark_edition,C:white}Ability:{} Applies efects {C:attention}without destroying{} selected cards'
		}
	},
	config = {},
	set = 'jen_jokerability',
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 0,
	unlocked = true,
	discovered = true,
	hidden = true,
	no_doe = true,
	soul_rate = 0,
	atlas = 'jenartificer_c',
	can_use = function(self, card)
		return ((card.edition or {}).negative or #G.hand.highlighted > 0) and (#G.hand.highlighted < #G.hand.cards) and abletouseabilities()
	end,
	keep_on_use = function(self, card)
		return #SMODS.find_card('j_jen_artificer') > 0 and not (card.edition or {}).negative
	end,
	use = function(self, card, area, copier)
		if #G.hand.highlighted > 0 then
			play_sound('coin2')
			card:juice_up(0.3, 0.4)
			for k, v in pairs(G.hand.highlighted) do
				if v ~= card then
					v:sell_card()
				end
			end
			if #G.hand.cards - #G.hand.highlighted < G.hand.config.card_limit and #G.deck.cards > 0 then
				for i = 1, math.min(G.hand.config.card_limit - (#G.hand.cards - #G.hand.highlighted), #G.deck.cards) do
					draw_card(G.deck,G.hand, 1, nil, true, nil, 0.07)
				end
			end
		end
		if (card.edition or {}).negative then
			ease_dollars(5)
		end
	end
}
]]

SMODS.Joker {
	key = 'rot',
	loc_txt = {
		name = 'The Rot',
		text = {
			'Clogs up your Joker slots',
			'{C:attention}Duplicates itself{} at the end of every {C:attention}Ante{}',
			' ',
			'{C:inactive,s:1.25,E:1}Better get rid of it before it starts killing your framerate...{}'
		}
	},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 1,
	rarity = 6,
	set_card_type_badge = junk,
	no_doe = true,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = false,
	debuff_immune = true,
	edition_immune = 'negative',
	atlas = 'jenrot',
    calculate = function(self, card, context)
        if not context.individual and not context.repetition and not card.debuff and context.end_of_round and not context.blueprint and G.GAME.blind.boss and not (G.GAME.blind.config and G.GAME.blind.config.bonus) then
			local rot = copy_card(card)
			rot:add_to_deck()
			G.jokers:emplace(rot)
		end
	end
}

local godsmarble_blurbs = {
	'What is this?',
	'This looks weird!',
	'What the heck is this...?',
	'Strange thing...',
	"I wonder if it's edible...?"
}

local randtext = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',' ','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','-','?','!','$','%','[',']','(',')'}

local function obfuscatedtext(length)
	local str = ''
	for i = 1, length do
		str = str .. randtext[math.random(#randtext)]
	end
	return str
end

SMODS.Joker {
	key = 'kosmos',
	loc_txt = {
		name = '{C:red}Kosmos{}',
		text = {
			'{C:attention}Retriggers{} all Jokers {C:attention}6{} times',
			'All cards in played hand give {X:dark_edition,C:mult}^6.66{C:mult} Mult {C:attention}6{} times',
			' ',
			"{C:inactive,s:1.5,E:1}#1#{}"
		}
	},
	config = {},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 250,
	rarity = 'cry_exotic',
	set_card_type_badge = ritualistic,
	unlocked = true,
	discovered = true,
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = false,
	immune_to_chemach = true,
	atlas = 'jenkosmos',
    loc_vars = function(self, info_queue, center)
        return {vars = {#SMODS.find_card('j_jen_wondergeist2') > 0 and "Now it's my turn." or 'Baa.'}}
    end,
    calculate = function(self, card, context)
		if not context.blueprint then
			if context.retrigger_joker_check and not context.retrigger_joker then
				return {
					message = 'B' .. string.rep('a', math.random(3,6)) .. '.',
					repetitions = 6,
					nopeus_again = true,
					card = card
				}
			elseif context.individual and (context.cardarea and context.cardarea == G.play) then
				return {
					message = 'B' .. string.rep('a', math.random(3,6)) .. '.',
					e_mult = 6.66,
					colour = G.C.DARK_EDITION
				}
			end
		end
	end
}

local function voucherscount()
	if not G.GAME.used_vouchers then return 0 end
	local count = 0
	for k, v in pairs(G.GAME.used_vouchers) do
		if v then
			count = count + 1
		end
	end
	return count
end

SMODS.Joker {
	key = 'betmma',
	loc_txt = {
		name = 'Betmma',
		text = {
			'{X:jen_RGB,C:white,s:1.5}+^^#1#{C:mult} Mult{} for every {C:attention}unique Voucher redeemed{}',
			'{C:inactive}(Currently {X:jen_RGB,C:white,s:1.5}^^#2#{C:inactive}){}',
			' ',
			"{C:inactive,s:1.5,E:1}It's time for redemption.{}"
		}
	},
	config = {extra = {tet = 0.02}},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 50,
	rarity = 'cry_exotic',
	unlocked = true,
	discovered = true,
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	atlas = 'jenbetmma',
    loc_vars = function(self, info_queue, center)
		local qty = voucherscount()
        return {vars = {center.ability.extra.tet, 1 + (qty * center.ability.extra.tet)}}
    end,
    calculate = function(self, card, context)
		if context.cardarea == G.jokers and not context.before and not context.after and context.scoring_name then
			local vouchers = voucherscount()
			if vouchers > 0 then
				local num = 1 + (vouchers*card.ability.extra.tet)
				return {
					message = '^^' .. num .. ' Mult',
					colour = G.C.jen_RGB,
					EEmult_mod = num,
					card = card
				}
			end
		end
	end
}

if FusionJokers then

	SMODS.Joker {
		key = 'godsmarble',
		loc_txt = {
			name = 'Godsmarble',
			text = {
				'{C:dark_edition,s:2.5,E:1}???',
				' ',
				"{C:inactive,s:1.8,E:1}#1#{}"
			}
		},
		pos = { x = 0, y = 0 },
		soul_pos = { x = 1, y = 0 },
		cost = 3,
		rarity = 3,
		unlocked = true,
		discovered = true,
		blueprint_compat = false,
		eternal_compat = true,
		perishable_compat = false,
		immune_to_chemach = true,
		atlas = 'jengodsmarble',
		loc_vars = function(self, info_queue, center)
			return {vars = {godsmarble_blurbs[math.random(#godsmarble_blurbs)]}}
		end
	}

	SMODS.Joker {
		key = 'pawn',
		loc_txt = {
			name = '{C:green}The Pawn of Pandemonium{}',
			text = {
				'{C:clubs}Clubs{} give',
				'{X:dark_edition,C:red}^#1#{C:red} Mult{} when scored',
				'{C:attention}All other suits{} give',
				'{X:dark_edition,C:red}^#2#{C:red} Mult{} when scored',
				'{C:attention}Numerical cards, Aces and Stone cards{} give',
				'{X:dark_edition,C:red}^#3#{C:red} Mult{} when scored',
				'{C:attention}Face cards{} give',
				'{X:dark_edition,C:red}^#4#{C:red} Mult{} when scored',
				'When {C:attention}any card{} scores,',
				'create {C:attention}#5#{C:dark_edition} Negative{C:tarot} Tarot{} cards',
				' ',
				'{C:inactive,s:1.25,E:1}See no evil.{}',
				'{C:dark_edition,s:0.7,E:2}Face art by : raidoesthings{}',
			}
		},
		config = {
			extra = {
				power_suit = 2,
				power_nonsuit = 1.3,
				power_number = 1.09,
				power_face = 1.13,
				special = 2
			}
		},
		pos = { x = 0, y = 0 },
		soul_pos = { x = 1, y = 0, extra = { x = 2, y = 0 }},
		set_card_type_badge = ritualistic,
		no_doe = true,
		cost = 125,
		rarity = 6,
		unlocked = true,
		discovered = true,
		blueprint_compat = true,
		eternal_compat = true,
		perishable_compat = false,
		immune_to_chemach = true,
		atlas = 'jenpawn',
		loc_vars = function(self, info_queue, center)
			return {vars = {
				center.ability.extra.power_suit,
				center.ability.extra.power_nonsuit,
				center.ability.extra.power_number,
				center.ability.extra.power_face,
				center.ability.extra.special
			}}
		end,
		calculate = function(self, card, context)
			if context.individual then
				if context.cardarea == G.play then
					local totalpower = 1
					if context.other_card:is_suit('Clubs') then
						totalpower = totalpower == 1 and card.ability.extra.power_suit or totalpower ^ card.ability.extra.power_suit
					end
					if not context.other_card:is_suit('Clubs') and context.other_card.ability.name ~= 'Stone Card' then
						totalpower = totalpower == 1 and card.ability.extra.power_nonsuit or totalpower ^ card.ability.extra.power_nonsuit
					end
					if not context.other_card:is_face() then
						totalpower = totalpower == 1 and card.ability.extra.power_number or totalpower ^ card.ability.extra.power_number
					end
					if context.other_card:is_face() then
						totalpower = totalpower == 1 and card.ability.extra.power_face or totalpower ^ card.ability.extra.power_face
					end
					for i = 1, card.ability.extra.special do
						G.E_MANAGER:add_event(Event({
							delay = 0.1,
							func = function()
								local card2 = create_card('Tarot', G.consumeables, nil, nil, nil, nil, nil, 'revenant')
								card2:set_edition({negative = true}, true, true)
								card2:add_to_deck()
								G.consumeables:emplace(card2)
								card:juice_up(0.3, 0.5)
								return true
							end
						}))
					end
					if totalpower > 1 then
						return {
							e_mult = totalpower,
							colour = G.C.DARK_EDITION,
							card = card
						}
					end
				end
			end
		end
	}

	SMODS.Joker {
		key = 'knight',
		loc_txt = {
			name = '{C:money}The Knight of Starvation{}',
			text = {
				'{C:diamonds}Diamonds{} give',
				'{X:dark_edition,C:red}^#1#{C:red} Mult{} when scored',
				'{C:attention}All other suits{} give',
				'{X:dark_edition,C:red}^#2#{C:red} Mult{} when scored',
				'{C:attention}Numerical cards, Aces and Stone cards{} give',
				'{X:dark_edition,C:red}^#3#{C:red} Mult{} when scored',
				'{C:attention}Face cards{} give',
				'{X:dark_edition,C:red}^#4#{C:red} Mult{} when scored',
				'When {C:attention}any card{} scores,',
				'create {C:attention}#5#{C:dark_edition} Negative{C:planet} Planet{} cards',
				' ',
				'{C:inactive,s:1.25,E:1}Speak no evil.{}',
				'{C:dark_edition,s:0.7,E:2}Face art by : raidoesthings{}',
			}
		},
		config = {
			extra = {
				power_suit = 2,
				power_nonsuit = 1.3,
				power_number = 1.09,
				power_face = 1.13,
				special = 2
			}
		},
		pos = { x = 0, y = 0 },
		soul_pos = { x = 1, y = 0, extra = { x = 2, y = 0 }},
		set_card_type_badge = ritualistic,
		no_doe = true,
		cost = 125,
		rarity = 6,
		unlocked = true,
		discovered = true,
		blueprint_compat = true,
		eternal_compat = true,
		perishable_compat = false,
		immune_to_chemach = true,
		atlas = 'jenknight',
		loc_vars = function(self, info_queue, center)
			return {vars = {
				center.ability.extra.power_suit,
				center.ability.extra.power_nonsuit,
				center.ability.extra.power_number,
				center.ability.extra.power_face,
				center.ability.extra.special
			}}
		end,
		calculate = function(self, card, context)
			if context.individual then
				if context.cardarea == G.play then
					local totalpower = 1
					if context.other_card:is_suit('Diamonds') then
						totalpower = totalpower == 1 and card.ability.extra.power_suit or totalpower ^ card.ability.extra.power_suit
					end
					if not context.other_card:is_suit('Diamonds') and context.other_card.ability.name ~= 'Stone Card' then
						totalpower = totalpower == 1 and card.ability.extra.power_nonsuit or totalpower ^ card.ability.extra.power_nonsuit
					end
					if not context.other_card:is_face() then
						totalpower = totalpower == 1 and card.ability.extra.power_number or totalpower ^ card.ability.extra.power_number
					end
					if context.other_card:is_face() then
						totalpower = totalpower == 1 and card.ability.extra.power_face or totalpower ^ card.ability.extra.power_face
					end
					for i = 1, card.ability.extra.special do
						G.E_MANAGER:add_event(Event({
							delay = 0.1,
							func = function()
								local card2 = create_card('Planet', G.consumeables, nil, nil, nil, nil, nil, 'revenant')
								card2:set_edition({negative = true}, true, true)
								card2:add_to_deck()
								G.consumeables:emplace(card2)
								card:juice_up(0.3, 0.5)
								return true
							end
						}))
					end
					if totalpower > 1 then
						return {
							e_mult = totalpower,
							colour = G.C.DARK_EDITION,
							card = card
						}
					end
				end
			end
		end
	}

	SMODS.Joker {
		key = 'jester',
		loc_txt = {
			name = '{C:planet}The Jester of Epidemics{}',
			text = {
				'{C:spades}Spades{} give',
				'{X:dark_edition,C:red}^#1#{C:red} Mult{} when scored',
				'{C:attention}All other suits{} give',
				'{X:dark_edition,C:red}^#2#{C:red} Mult{} when scored',
				'{C:attention}Numerical cards, Aces and Stone cards{} give',
				'{X:dark_edition,C:red}^#3#{C:red} Mult{} when scored',
				'{C:attention}Face cards{} give',
				'{X:dark_edition,C:red}^#4#{C:red} Mult{} when scored',
				'When {C:attention}any card{} scores,',
				'create {C:attention}#5#{C:dark_edition} Negative{C:spectral} Spectral{} cards',
				' ',
				'{C:inactive,s:1.25,E:1}Hear no evil.{}',
				'{C:dark_edition,s:0.7,E:2}Face art by : raidoesthings{}',
			}
		},
		config = {
			extra = {
				power_suit = 2,
				power_nonsuit = 1.3,
				power_number = 1.09,
				power_face = 1.13,
				special = 2
			}
		},
		pos = { x = 0, y = 0 },
		soul_pos = { x = 1, y = 0, extra = { x = 2, y = 0 }},
		set_card_type_badge = ritualistic,
		no_doe = true,
		cost = 125,
		rarity = 6,
		unlocked = true,
		discovered = true,
		blueprint_compat = true,
		eternal_compat = true,
		perishable_compat = false,
		immune_to_chemach = true,
		atlas = 'jenjester',
		loc_vars = function(self, info_queue, center)
			return {vars = {
				center.ability.extra.power_suit,
				center.ability.extra.power_nonsuit,
				center.ability.extra.power_number,
				center.ability.extra.power_face,
				center.ability.extra.special
			}}
		end,
		calculate = function(self, card, context)
			if context.individual then
				if context.cardarea == G.play then
					local totalpower = 1
					if context.other_card:is_suit('Spades') then
						totalpower = totalpower == 1 and card.ability.extra.power_suit or totalpower ^ card.ability.extra.power_suit
					end
					if not context.other_card:is_suit('Spades') and context.other_card.ability.name ~= 'Stone Card' then
						totalpower = totalpower == 1 and card.ability.extra.power_nonsuit or totalpower ^ card.ability.extra.power_nonsuit
					end
					if not context.other_card:is_face() then
						totalpower = totalpower == 1 and card.ability.extra.power_number or totalpower ^ card.ability.extra.power_number
					end
					if context.other_card:is_face() then
						totalpower = totalpower == 1 and card.ability.extra.power_face or totalpower ^ card.ability.extra.power_face
					end
					for i = 1, card.ability.extra.special do
						G.E_MANAGER:add_event(Event({
							delay = 0.1,
							func = function()
								local card2 = create_card('Spectral', G.consumeables, nil, nil, nil, nil, nil, 'revenant')
								card2:set_edition({negative = true}, true, true)
								card2:add_to_deck()
								G.consumeables:emplace(card2)
								card:juice_up(0.3, 0.5)
								return true
							end
						}))
					end
					if totalpower > 1 then
						return {
							e_mult = totalpower,
							colour = G.C.DARK_EDITION,
							card = card
						}
					end
				end
			end
		end
	}

	SMODS.Joker {
		key = 'arachnid',
		loc_txt = {
			name = '{C:tarot}The Arachnid of War{}',
			text = {
				'{C:hearts}Hearts{} give',
				'{X:dark_edition,C:red}^#1#{C:red} Mult{} when scored',
				'{C:attention}All other suits{} give',
				'{X:dark_edition,C:red}^#2#{C:red} Mult{} when scored',
				'{C:attention}Numerical cards, Aces and Stone cards{} give',
				'{X:dark_edition,C:red}^#3#{C:red} Mult{} when scored',
				'{C:attention}Face cards{} give',
				'{X:dark_edition,C:red}^#4#{C:red} Mult{} when scored',
				'{C:attention}Retrigger{} all scored cards {C:attention}#5#{} times',
				' ',
				'{C:inactive,s:1.25,E:1}Think no evil.{}',
				'{C:dark_edition,s:0.7,E:2}Face art by : raidoesthings{}',
			}
		},
		config = {
			extra = {
				power_suit = 2,
				power_nonsuit = 1.3,
				power_number = 1.09,
				power_face = 1.13,
				special = 5
			}
		},
		pos = { x = 0, y = 0 },
		soul_pos = { x = 1, y = 0, extra = { x = 2, y = 0 }},
		set_card_type_badge = ritualistic,
		no_doe = true,
		cost = 125,
		rarity = 6,
		unlocked = true,
		discovered = true,
		blueprint_compat = true,
		eternal_compat = true,
		perishable_compat = false,
		immune_to_chemach = true,
		atlas = 'jenarachnid',
		loc_vars = function(self, info_queue, center)
			return {vars = {
				center.ability.extra.power_suit,
				center.ability.extra.power_nonsuit,
				center.ability.extra.power_number,
				center.ability.extra.power_face,
				center.ability.extra.special
			}}
		end,
		calculate = function(self, card, context)
			if context.repetition then
				if context.cardarea == G.play then
					return {
						message = localize('k_again_ex'),
						repetitions = card.ability.extra.special,
						card = card
					}
				end
			elseif context.individual then
				if context.cardarea == G.play then
					local totalpower = 1
					if context.other_card:is_suit('Spades') then
						totalpower = totalpower == 1 and card.ability.extra.power_suit or totalpower ^ card.ability.extra.power_suit
					end
					if not context.other_card:is_suit('Spades') and context.other_card.ability.name ~= 'Stone Card' then
						totalpower = totalpower == 1 and card.ability.extra.power_nonsuit or totalpower ^ card.ability.extra.power_nonsuit
					end
					if not context.other_card:is_face() then
						totalpower = totalpower == 1 and card.ability.extra.power_number or totalpower ^ card.ability.extra.power_number
					end
					if context.other_card:is_face() then
						totalpower = totalpower == 1 and card.ability.extra.power_face or totalpower ^ card.ability.extra.power_face
					end
					if totalpower > 1 then
						return {
							e_mult = totalpower,
							colour = G.C.DARK_EDITION,
							card = card
						}
					end
				end
			end
		end
	}

	SMODS.Joker {
		key = 'reign',
		loc_txt = {
			name = '{C:dark_edition}The Reign of Regicide{}',
			text = {
				'All {C:attention}Jokers{} to the {C:green}left{}',
				'of this {C:attention}Joker{} become {C:purple}Eternal{}',
				'All {C:attention}Jokers{} to the {C:green}right{}',
				'of this {C:attention}Joker{} {C:red}lose{} {C:purple}Eternal{}',
				'Removes {C:blue}Perishable{}, {C:attention}Pinned{},',
				'{C:money}Rental{} and {C:red}Debuffs{} from all {C:attention}Jokers{}',
				'{C:dark_edition}+1e100{} Joker slots, {C:attention}retrigger{} all Jokers {C:attention}#1#{} times',
				'{C:inactive}(Stickers update whenever jokers are calculated){}',
				' ',
				'{C:inactive,s:1.25,E:1}Rule no evil.{}',
				'{C:dark_edition,s:0.7,E:2}Face art by : raidoesthings{}',
			}
		},
		config = {
			extra = {
				special = 3
			}
		},
		pos = { x = 0, y = 0 },
		soul_pos = { x = 1, y = 0, extra = { x = 2, y = 0 }},
		set_card_type_badge = ritualistic,
		no_doe = true,
		cost = 125,
		rarity = 6,
		unlocked = true,
		discovered = true,
		blueprint_compat = true,
		eternal_compat = true,
		perishable_compat = false,
		immune_to_chemach = true,
		atlas = 'jenreign',
		loc_vars = function(self, info_queue, center)
			return {vars = {
				center.ability.extra.special
			}}
		end,
		calculate = function(self, card, context)
			if not context.blueprint and card.added_to_deck and not context.retrigger_joker_check and not context.retrigger_joker and G.jokers and G.jokers.cards then
				for i=1, #G.jokers.cards do
					local other_card = G.jokers.cards[i]
					if other_card and other_card ~= card then
						if card.T.x + card.T.w/2 > other_card.T.x + other_card.T.w/2 then
							other_card:set_eternal(true)
						else
							other_card:set_eternal(nil)
						end
						if other_card.ability then
							other_card.ability.perishable = nil
						end
						other_card.debuff = nil
						other_card:set_rental(nil)
						other_card.pinned = nil
					end
				end
			end
			if context.retrigger_joker_check and not context.retrigger_joker then
				if context.other_card ~= card and context.other_card.ability.name ~= 'Kosmos' then
					return {
						message = localize('k_again_ex'),
						repetitions = card.ability.extra.special,
						card = card
					}
				end				
			end
		end,
		add_to_deck = function(self, card, from_debuff)
			G.jokers.config.card_limit_before_reign = G.jokers.config.card_limit
			G.jokers.config.card_limit = 1e100
		end,
		remove_from_deck = function(self, card, from_debuff)
			G.jokers.config.card_limit = (G.jokers.config.card_limit_before_reign or 5)
		end
	}

	SMODS.Joker {
		key = 'feline',
		loc_txt = {
			name = '{C:red}T{C:green}he {C:money}Feline {C:planet}of {C:tarot}Quietu{C:red}s{}',
			text = {
				'{C:attention}Enhanced cards{} give',
				'{X:dark_edition,C:red}^#1#{C:red} Mult{} when scored',
				'{C:attention}All cards{} give',
				'{X:dark_edition,C:red}^#2#{C:red} Mult{} when scored',
				'{C:attention}Numerical cards, Aces and Stone cards{} give',
				'{X:dark_edition,C:red}^#3#{C:red} Mult{} when scored',
				'{C:attention}Face cards{} give',
				'{X:dark_edition,C:red}^#4#{C:red} Mult{} when scored',
				'Scored cards {C:attention}level up hands{} based on their {C:attention}rank value{}',
				'{C:inactive}(Level-ups apply after scoring is finished){}',
				' ',
				'{C:inactive,s:1.25,E:1}Do no evil.{}',
				'{C:dark_edition,s:0.7,E:2}Face art by : raidoesthings{}',
			}
		},
		config = {
			extra = {
				power_suit = 2,
				power_nonsuit = 1.3,
				power_number = 1.09,
				power_face = 1.13
			}
		},
		pos = { x = 0, y = 0 },
		soul_pos = { x = 1, y = 0, extra = { x = 2, y = 0 }},
		set_card_type_badge = ritualistic,
		no_doe = true,
		cost = 125,
		rarity = 6,
		unlocked = true,
		discovered = true,
		blueprint_compat = true,
		eternal_compat = true,
		perishable_compat = false,
		immune_to_chemach = true,
		atlas = 'jenfeline',
		loc_vars = function(self, info_queue, center)
			return {vars = {
				center.ability.extra.power_suit,
				center.ability.extra.power_nonsuit,
				center.ability.extra.power_number,
				center.ability.extra.power_face
			}}
		end,
		calculate = function(self, card, context)
			if context.individual then
				if context.cardarea == G.play then
					local totalpower = 1
					local txt,dtxt = G.FUNCS.get_poker_hand_info(G.play.cards)
					if context.other_card.ability.name ~= 'Stone Card' then
						card.cumulative_lvs = (card.cumulative_lvs or 0) + math.ceil(math.max(1, context.other_card:get_id()))
						if noretriggers(context) then
							card:apply_cumulative_levels()
						end
					end
					if context.other_card.ability.name ~= 'Base Card' then
						totalpower = totalpower == 1 and card.ability.extra.power_suit or totalpower ^ card.ability.extra.power_suit
					else
						totalpower = totalpower == 1 and card.ability.extra.power_nonsuit or totalpower ^ card.ability.extra.power_nonsuit
					end
					if not context.other_card:is_face() then
						totalpower = totalpower == 1 and card.ability.extra.power_number or totalpower ^ card.ability.extra.power_number
					end
					if context.other_card:is_face() then
						totalpower = totalpower == 1 and card.ability.extra.power_face or totalpower ^ card.ability.extra.power_face
					end
					if totalpower > 1 then
						return {
							e_mult = totalpower,
							colour = G.C.DARK_EDITION,
							card = card
						}
					end
				end
			end
		end
	}

	SMODS.Joker {
		key = 'fateeater',
		loc_txt = {
			name = 'The Fateeater of Grim Nights',
			text = {
				'{C:tarot}Tarot{} cards permanently add',
				'either {X:blue,C:white}x#1#{} or {C:blue}+#2# Chips{}',
				'to all {C:attention}playing cards{} when used',
				'{C:inactive}(Uses whichever one that gives the better upgrade){}',
				'When any card reaches {C:attention}1e100 chips or more{},',
				'{C:red}reset it to zero{}, {C:planet}level up all hands #3# time(s){}',
				'and create a {C:dark_edition}Negative {C:spectral}Soul{}',
				'Grants an {C:green}ability{} which {C:red}devours {C:tarot}Tarot{} cards',
				'to {C:attention}provide a random amount of{}',
				'{C:planet}levels{}, {C:chips}+Chips{}, {C:mult}+Mult{},',
				'{X:chips,C:white}xChips{}, {X:mult,C:white}xMult{},',
				'{X:dark_edition,C:chips}^Chips{} and {X:dark_edition,C:red}^Mult{}',
				'to {C:attention}every poker hand, scaling with {C:attention}Ante{}',
				' ',
				'{C:inactive,s:1.25,E:1}Foretell no evil.{}',
				'{C:dark_edition,s:0.7,E:2}Face art by : raidoesthings{}',
			}
		},
		config = {extra = {chips_additive = 100, chips_mult = 2, levelup = 10}},
		pos = { x = 0, y = 0 },
		soul_pos = { x = 1, y = 0, extra = { x = 2, y = 0 }},
		set_card_type_badge = ritualistic,
		no_doe = true,
		cost = 125,
		rarity = 6,
		unlocked = true,
		discovered = true,
		blueprint_compat = true,
		eternal_compat = true,
		perishable_compat = false,
		immune_to_chemach = true,
		atlas = 'jenfateeater',
		abilitycard = 'c_jen_fateeater_c',
		loc_vars = function(self, info_queue, center)
			return {vars = {center.ability.extra.chips_mult, center.ability.extra.chips_additive, center.ability.extra.levelup}}
		end,
		calculate = function(self, card, context)
			if context.using_consumeable and context.consumeable and context.consumeable.ability.set == 'Tarot' and (#G.hand.cards > 0 or #G.deck.cards > 0) then
				card_eval_status_text(card, 'extra', nil, nil, nil, {message = '...', colour = G.C.MULT})
				local e100cards = {}
				if #G.hand.cards > 0 then
					for k, v in pairs(G.hand.cards) do
						if not v.ability.perma_bonus then v.ability.perma_bonus = 0 end
						local res1 = 0
						local res2 = 0
						for i = 1, context.consumeable:getEvalQty() do
							res1 = v.ability.perma_bonus * card.ability.extra.chips_mult
							res2 = v.ability.perma_bonus + card.ability.extra.chips_additive
							v.ability.perma_bonus = math.max(res1, res2)
						end
						card_eval_status_text(v, 'extra', nil, nil, nil, {message = '+' .. v.ability.perma_bonus, colour = G.C.CHIPS})
						if v.ability.perma_bonus >= 1e100 then table.insert(e100cards, v) end
					end
				end
				if #G.deck.cards > 0 then
					for k, v in pairs(G.deck.cards) do
						if not v.ability.perma_bonus then v.ability.perma_bonus = 0 end
						local res1 = v.ability.perma_bonus * card.ability.extra.chips_mult
						local res2 = v.ability.perma_bonus + card.ability.extra.chips_additive
						v.ability.perma_bonus = math.max(res1, res2)
						if v.ability.perma_bonus >= 1e100 then table.insert(e100cards, v) end
					end
				end
				local ecs = #e100cards
				if ecs > 0 then
					card_status_text(card, '!!!', nil, 0.05*card.T.h, G.C.DARK_EDITION, 0.6, 0.6, 2, 2, 'bm', 'jen_enlightened')
					update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize('k_all_hands'),chips = '...', mult = '...', level=''})
					G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
						play_sound('tarot1')
						card:juice_up(0.8, 0.5)
						G.TAROT_INTERRUPT_PULSE = true
					return true end }))
					update_hand_text({sound = 'button', volume = 0.7, pitch = 0.9, delay = 0}, {chips = '+', mult = '+', StatusText = true, level='+' .. number_format(card.ability.extra.levelup * ecs)})
					delay(1.3)
					for k, v in pairs(G.GAME.hands) do
						level_up_hand(v, k, true, card.ability.extra.levelup * ecs)
					end
					update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
					for k, v in pairs(e100cards) do
						v.ability.perma_bonus = 0
					end
					G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
						local soul = create_card('Spectral', G.consumeables, nil, nil, nil, nil, 'c_soul', nil)
						soul:set_edition({negative = true})
						soul:setQty(ecs)
						if ecs > 1 then soul:create_stack_display() end
						soul:set_cost()
						soul:add_to_deck()
						G.consumeables:emplace(soul)
					return true end }))
				end
				return {calculated = true}
			end
		end
	}
	
	SMODS.Consumable {
		key = 'fateeater_c',
		loc_txt = {
			name = 'Fateful Cuisine',
			text = {
				'{C:red}Warning : This ability can cause crashes if there are an extreme amount of targets!',
				'{C:red}Devours {C:tarot}Tarot{} cards',
				'to {C:attention}provide a random amount of{}',
				'{C:planet}levels{}, {C:chips}+Chips{}, {C:mult}+Mult{},',
				'{X:chips,C:white}xChips{}, {X:mult,C:white}xMult{},',
				'{X:dark_edition,C:chips}^Chips{} and {X:dark_edition,C:red}^Mult{}',
				'to {C:attention}every poker hand, scaling with {C:attention}Ante{}',
				'{X:dark_edition,C:white}Negative{} {X:dark_edition,C:white}Ability:{} Levels up all poker hands once',
			}
		},
		config = {},
		set = 'jen_jokerability',
		pos = { x = 0, y = 0 },
		soul_pos = { x = 1, y = 0, extra = { x = 2, y = 0 }},
		cost = 15,
		unlocked = true,
		discovered = true,
		hidden = true,
		no_doe = true,
		soul_rate = 0,
		atlas = 'jenfateeater_c',
		can_use = function(self, card)
			return abletouseabilities()
		end,
		keep_on_use = function(self, card)
			return #SMODS.find_card('j_jen_fateeater') > 0 and not (card.edition or {}).negative
		end,
		use = function(self, card, area, copier)
			if (card.edition or {}).negative then
					update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize('k_all_hands'),chips = '...', mult = '...', level=''})
					G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
						play_sound('tarot1')
						card:juice_up(0.8, 0.5)
						G.TAROT_INTERRUPT_PULSE = true
						return true end }))
					update_hand_text({delay = 0}, {mult = '+', StatusText = true})
					G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.9, func = function()
						play_sound('tarot1')
						card:juice_up(0.8, 0.5)
						return true end }))
					update_hand_text({delay = 0}, {chips = '+', StatusText = true})
					G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.9, func = function()
						play_sound('tarot1')
						card:juice_up(0.8, 0.5)
						G.TAROT_INTERRUPT_PULSE = nil
						return true end }))
					update_hand_text({sound = 'button', volume = 0.7, pitch = 0.9, delay = 0}, {level='+1'})
					delay(1.3)
					for k, v in pairs(G.GAME.hands) do
						level_up_hand(card, k, true, 1)
					end
			end
			local targets = {}
			for k, v in pairs(G.consumeables.cards) do
				if v.ability.set == 'Tarot' and not v.alrm then
					v.alrm = true
					table.insert(targets, v)
				end
			end
			if #targets > 0 then
				local intensity = 0
				for k, v in pairs(targets) do
					intensity = intensity + 1 + (v:getQty()/4) - 0.25
					G.consumeables:remove_card(v)
					G.play:emplace(v)
				end
				for _, hand in ipairs(G.handlist) do
					local fastforward = false
					update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(hand, 'poker_hands'),chips = G.GAME.hands[hand].chips, mult = G.GAME.hands[hand].mult, level=G.GAME.hands[hand].level})
					for k, v in pairs(targets) do
						local qty = v:getQty()
						fastforward = intensity > 5
						local ante = math.min(math.max(1, G.GAME.round_resets.ante), 1e9)
						local levels = pseudorandom(pseudoseed('fateeater_levels'), ante, ante * 5)
						local addchips = pseudorandom(pseudoseed('fateeater_chips'), 25 * ante, 50 * ante)
						local addmult = pseudorandom(pseudoseed('fateeater_mult'), 4 * ante, 30 * ante)
						local xchips = pseudorandom(pseudoseed('fateeater_xchips'), 20 * (ante/2), 50 * ante) / 10
						local xmult = pseudorandom(pseudoseed('fateeater_xmult'), 20 * (ante/2), 50 * ante) / 10
						local echips = pseudorandom(pseudoseed('fateeater_echips'))/3 + 1 + (ante / 50)
						local emult = pseudorandom(pseudoseed('fateeater_emult'))/3 + 1 + (ante / 50)
						if fastforward then
							for i = 1, qty do
								G.GAME.hands[hand].chips = ((G.GAME.hands[hand].chips + addchips) * xchips) ^ echips
								G.GAME.hands[hand].mult = ((G.GAME.hands[hand].mult + addmult) * xmult) ^ emult
							end
						else
							for i = 1, qty do
								level_up_hand(v, hand, nil, levels)
								G.GAME.hands[hand].chips = ((G.GAME.hands[hand].chips + addchips) * xchips) ^ echips
								G.GAME.hands[hand].mult = ((G.GAME.hands[hand].mult + addmult) * xmult) ^ emult
								G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
									play_sound('chips1')
									v:juice_up(0.8, 0.5)
								return true end }))
								update_hand_text({delay = 1.3}, {chips = '+' .. tostring(addchips), StatusText = true})
								G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
									play_sound('talisman_xchip')
									v:juice_up(0.8, 0.5)
								return true end }))
								update_hand_text({delay = 1.3}, {chips = 'x' .. tostring(xchips), StatusText = true})
								G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
									play_sound('talisman_echip')
									v:juice_up(0.8, 0.5)
								return true end }))
								update_hand_text({delay = 1.3}, {chips = '^' .. tostring(round(echips, 3)), StatusText = true})
								G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
									play_sound('multhit1')
									v:juice_up(0.8, 0.5)
								return true end }))
								update_hand_text({delay = 1.3}, {mult = '+' .. tostring(addmult), StatusText = true})
								G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
									play_sound('multhit2')
									v:juice_up(0.8, 0.5)
								return true end }))
								update_hand_text({delay = 1.3}, {mult = 'x' .. tostring(xmult), StatusText = true})
								G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
									play_sound('talisman_emult', 1)
									v:juice_up(0.8, 0.5)
								return true end }))
								update_hand_text({delay = 1.3}, {mult = '^' .. tostring(round(emult, 3)), StatusText = true})
							end
						end
					end
					if fastforward then
						G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
							play_sound('button')
						return true end }))
						update_hand_text({delay = 1.3}, {chips = '+++', mult = '+++', level = '+++', StatusText = true})
					end
					update_hand_text({sound = 'button', volume = 0.5, pitch = 1.1, delay = 3}, {handname=localize(hand, 'poker_hands'),chips = G.GAME.hands[hand].chips, mult = G.GAME.hands[hand].mult, level=G.GAME.hands[hand].level})
				end
				G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.5, func = function()
					for k, v in pairs(targets) do
						v:remove()
					end
					return true
				end}))
			else
				card_eval_status_text(card, 'extra', nil, nil, nil, {message = 'Nothing to devour!', colour = G.C.MULT})
			end
			update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
		end
	}

	SMODS.Joker {
		key = 'foundry',
		loc_txt = {
			name = 'The Foundry of Armaments',
			text = {
				'Non-{C:dark_edition}editioned{} cards are',
				'{C:attention}given a random {C:dark_edition}Edition{}',
				'{C:inactive,s:0.8}(Some editions are excluded from the pool){}',
				'Grants an {C:green}ability{} which {C:red}smelts {C:spectral}Spectral{} cards',
				'to {C:attention}provide a random amount of{}',
				'{C:planet}levels{}, {C:chips}+Chips{}, {C:mult}+Mult{},',
				'{X:chips,C:white}xChips{}, {X:mult,C:white}xMult{},',
				'{X:dark_edition,C:chips}^Chips{} and {X:dark_edition,C:red}^Mult{}',
				'to {C:attention}every poker hand, scaling with {C:attention}Ante{}',
				' ',
				'{C:inactive,s:1.25,E:1}Forge no evil.{}',
				'{C:dark_edition,s:0.7,E:2}Face art by : raidoesthings{}',
			}
		},
		config = {},
		pos = { x = 0, y = 0 },
		soul_pos = { x = 1, y = 0, extra = { x = 2, y = 0 }},
		set_card_type_badge = ritualistic,
		no_doe = true,
		cost = 125,
		rarity = 6,
		unlocked = true,
		discovered = true,
		blueprint_compat = true,
		eternal_compat = true,
		perishable_compat = false,
		immune_to_chemach = true,
		atlas = 'jenfoundry',
		abilitycard = 'c_jen_foundry_c',
		calculate = function(self, card, context)
			if not context.blueprint and noretriggers(context) and not pending_applyingeditions then
				pending_applyingeditions = true
				G.E_MANAGER:add_event(Event({func = function()
					G.E_MANAGER:add_event(Event({func = function()
						if card.added_to_deck then
							local iter = 0
							for k, v in pairs(G.jokers.cards) do
								if not v.edition or next(v.edition) == nil then
									iter = iter + 1
									v:set_edition({[random_editions[pseudorandom('kudaai_editions1', 1, #random_editions)]] = true}, iter > 50, iter > 50)
								end
							end
							iter = 0
							for k, v in pairs(G.hand.cards) do
								if not v.edition or next(v.edition) == nil then
									iter = iter + 1
									v:set_edition({[random_editions[pseudorandom('kudaai_editions2', 1, #random_editions)]] = true}, iter > 52, iter > 52)
								end
							end
							for k, v in pairs(G.deck.cards) do
								if not v.edition or next(v.edition) == nil then
									v:set_edition({[random_editions[pseudorandom('kudaai_editions3', 1, #random_editions)]] = true}, true, true)
								end
							end
							iter = 0
							for k, v in pairs(G.consumeables.cards) do
								if not v.edition or next(v.edition) == nil then
									iter = iter + 1
									v:set_edition({[random_editions[pseudorandom('kudaai_editions4', 1, #random_editions)]] = true}, iter > 20, iter > 20)
								end
							end
							iter = nil
							pending_applyingeditions = false
						end
					return true end }))
				return true end }))
			end
		end
	}
	
	SMODS.Consumable {
		key = 'foundry_c',
		loc_txt = {
			name = 'Paranormal Deliquesce',
			text = {
				'{C:red}Warning : This ability can cause crashes if there are an extreme amount of targets!',
				'{C:red}Smelts {C:spectral}Spectral{} cards',
				'to {C:attention}provide a random amount of{}',
				'{C:planet}levels{}, {C:chips}+Chips{}, {C:mult}+Mult{},',
				'{X:chips,C:white}xChips{}, {X:mult,C:white}xMult{},',
				'{X:dark_edition,C:chips}^Chips{} and {X:dark_edition,C:red}^Mult{}',
				'to {C:attention}every poker hand, scaling with {C:attention}Ante{}',
				'{X:dark_edition,C:white}Negative{} {X:dark_edition,C:white}Ability:{} Levels up all poker hands once',
			}
		},
		config = {},
		set = 'jen_jokerability',
		pos = { x = 0, y = 0 },
		soul_pos = { x = 1, y = 0, extra = { x = 2, y = 0 }},
		cost = 15,
		unlocked = true,
		discovered = true,
		hidden = true,
		no_doe = true,
		soul_rate = 0,
		atlas = 'jenfoundry_c',
		can_use = function(self, card)
			return abletouseabilities()
		end,
		keep_on_use = function(self, card)
			return #SMODS.find_card('j_jen_foundry') > 0 and not (card.edition or {}).negative
		end,
		use = function(self, card, area, copier)
			if (card.edition or {}).negative then
					update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize('k_all_hands'),chips = '...', mult = '...', level=''})
					G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
						play_sound('tarot1')
						card:juice_up(0.8, 0.5)
						G.TAROT_INTERRUPT_PULSE = true
						return true end }))
					update_hand_text({delay = 0}, {mult = '+', StatusText = true})
					G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.9, func = function()
						play_sound('tarot1')
						card:juice_up(0.8, 0.5)
						return true end }))
					update_hand_text({delay = 0}, {chips = '+', StatusText = true})
					G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.9, func = function()
						play_sound('tarot1')
						card:juice_up(0.8, 0.5)
						G.TAROT_INTERRUPT_PULSE = nil
						return true end }))
					update_hand_text({sound = 'button', volume = 0.7, pitch = 0.9, delay = 0}, {level='+1'})
					delay(1.3)
					for k, v in pairs(G.GAME.hands) do
						level_up_hand(card, k, true, 1)
					end
			end
			local targets = {}
			for k, v in pairs(G.consumeables.cards) do
				if v.ability.set == 'Spectral' and not v.alrm then
					v.alrm = true
					table.insert(targets, v)
				end
			end
			if #targets > 0 then
				local intensity = 0
				for k, v in pairs(targets) do
					intensity = intensity + 1 + (v:getQty()/4) - 0.25
					G.consumeables:remove_card(v)
					G.play:emplace(v)
				end
				for _, hand in ipairs(G.handlist) do
					local fastforward = false
					update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(hand, 'poker_hands'),chips = G.GAME.hands[hand].chips, mult = G.GAME.hands[hand].mult, level=G.GAME.hands[hand].level})
					for k, v in pairs(targets) do
						local qty = v:getQty()
						fastforward = intensity > 5
						local ante = math.min(math.max(1, G.GAME.round_resets.ante), 1e9)
						local levels = pseudorandom(pseudoseed('foundry_levels'), ante, ante * 5)
						local addchips = pseudorandom(pseudoseed('foundry_chips'), 25 * ante, 50 * ante)
						local addmult = pseudorandom(pseudoseed('foundry_mult'), 4 * ante, 30 * ante)
						local xchips = pseudorandom(pseudoseed('foundry_xchips'), 20 * (ante/2), 50 * ante) / 10
						local xmult = pseudorandom(pseudoseed('foundry_xmult'), 20 * (ante/2), 50 * ante) / 10
						local echips = pseudorandom(pseudoseed('foundry_echips'))/3 + 1 + (ante / 50)
						local emult = pseudorandom(pseudoseed('foundry_emult'))/3 + 1 + (ante / 50)
						if fastforward then
							for i = 1, qty do
								G.GAME.hands[hand].chips = ((G.GAME.hands[hand].chips + addchips) * xchips) ^ echips
								G.GAME.hands[hand].mult = ((G.GAME.hands[hand].mult + addmult) * xmult) ^ emult
							end
						else
							for i = 1, qty do
								level_up_hand(v, hand, nil, levels)
								G.GAME.hands[hand].chips = ((G.GAME.hands[hand].chips + addchips) * xchips) ^ echips
								G.GAME.hands[hand].mult = ((G.GAME.hands[hand].mult + addmult) * xmult) ^ emult
								G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
									play_sound('chips1')
									v:juice_up(0.8, 0.5)
								return true end }))
								update_hand_text({delay = 1.3}, {chips = '+' .. tostring(addchips), StatusText = true})
								G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
									play_sound('talisman_xchip')
									v:juice_up(0.8, 0.5)
								return true end }))
								update_hand_text({delay = 1.3}, {chips = 'x' .. tostring(xchips), StatusText = true})
								G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
									play_sound('talisman_echip')
									v:juice_up(0.8, 0.5)
								return true end }))
								update_hand_text({delay = 1.3}, {chips = '^' .. tostring(round(echips, 3)), StatusText = true})
								G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
									play_sound('multhit1')
									v:juice_up(0.8, 0.5)
								return true end }))
								update_hand_text({delay = 1.3}, {mult = '+' .. tostring(addmult), StatusText = true})
								G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
									play_sound('multhit2')
									v:juice_up(0.8, 0.5)
								return true end }))
								update_hand_text({delay = 1.3}, {mult = 'x' .. tostring(xmult), StatusText = true})
								G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
									play_sound('talisman_emult', 1)
									v:juice_up(0.8, 0.5)
								return true end }))
								update_hand_text({delay = 1.3}, {mult = '^' .. tostring(round(emult, 3)), StatusText = true})
							end
						end
					end
					if fastforward then
						G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
							play_sound('button')
						return true end }))
						update_hand_text({delay = 1.3}, {chips = '+++', mult = '+++', level = '+++', StatusText = true})
					end
					update_hand_text({sound = 'button', volume = 0.5, pitch = 1.1, delay = 3}, {handname=localize(hand, 'poker_hands'),chips = G.GAME.hands[hand].chips, mult = G.GAME.hands[hand].mult, level=G.GAME.hands[hand].level})
				end
				G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.5, func = function()
					for k, v in pairs(targets) do
						v:remove()
					end
					return true
				end}))
			else
				card_eval_status_text(card, 'extra', nil, nil, nil, {message = 'Nothing to devour!', colour = G.C.MULT})
			end
			update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
		end
	}

	SMODS.Joker {
		key = 'broken',
		loc_txt = {
			name = 'The Broken Collector of the Fragile',
			text = {
				'{C:attention}Doubles{} the values of',
				'{C:attention}all Jokers{} whenever',
				'a Joker that is {C:red}not {C:blue}Common{} or {C:green}Uncommon{} is {C:money}sold{},',
				'then {C:attention}retrigger all add-to-inventory effects{} of {C:attention}all Jokers{}',
				'{C:inactive}(Not all values can be doubled, not all Jokers can be affected){}',
				'Grants an {C:green}ability{} which {C:red}shatters {C:planet}Planet{} cards',
				'to {C:attention}provide a random amount of{}',
				'{C:planet}levels{}, {C:chips}+Chips{}, {C:mult}+Mult{},',
				'{X:chips,C:white}xChips{}, {X:mult,C:white}xMult{},',
				'{X:dark_edition,C:chips}^Chips{} and {X:dark_edition,C:red}^Mult{}',
				'to {C:attention}every poker hand, scaling with {C:attention}Ante{}',
				' ',
				'{C:inactive,s:1.25,E:1}Collect no evil.{}',
				'{C:dark_edition,s:0.7,E:2}Face art by : raidoesthings{}',
			}
		},
		config = {},
		pos = { x = 0, y = 0 },
		soul_pos = { x = 1, y = 0, extra = { x = 2, y = 0 }},
		set_card_type_badge = ritualistic,
		no_doe = true,
		cost = 125,
		rarity = 6,
		unlocked = true,
		discovered = true,
		blueprint_compat = true,
		eternal_compat = true,
		perishable_compat = false,
		immune_to_chemach = true,
		atlas = 'jenbroken',
		abilitycard = 'c_jen_broken_c',
		calculate = function(self, card, context)
			if context.selling_card and context.card.ability.set == 'Joker' and context.card ~= card and context.card.config.center.rarity ~= 1 and context.card.config.center.rarity ~= 2 then
				card_eval_status_text(card, 'extra', nil, nil, nil, {message = '...', colour = G.C.PURPLE})
				for k, v in pairs(G.jokers.cards) do
					if v ~= card and v ~= context.card then
						if not v.config.center.immune_to_chemach then
							v:remove_from_deck()
							for a, b in pairs(v.ability) do
								if a == 'extra' then
									if type(v.ability.extra) == 'number' then
										v.ability.extra = v.ability.extra * 2
									elseif type(v.ability.extra) == 'table' and next(v.ability.extra) then
										for c, d in pairs(v.ability.extra) do
											if type(d) == 'number' then
												v.ability.extra[c] = d * 2
											end
										end
									end
								elseif a ~= 'order' and type(b) == 'number' and ((a == 'x_mult' and b > 1) or b > 0 ) then
									v.ability[a] = b * 2
								end
							end
							v:add_to_deck()
						end
					end
				end
			end
		end
	}
	
	SMODS.Consumable {
		key = 'broken_c',
		loc_txt = {
			name = 'Extraterrestrial Rend',
			text = {
				'{C:red}Warning : This ability can cause crashes if there are an extreme amount of targets!',
				'{C:red}Shatters {C:planet}Planet{} cards',
				'to {C:attention}provide a random amount of{}',
				'{C:planet}levels{}, {C:chips}+Chips{}, {C:mult}+Mult{},',
				'{X:chips,C:white}xChips{}, {X:mult,C:white}xMult{},',
				'{X:dark_edition,C:chips}^Chips{} and {X:dark_edition,C:red}^Mult{}',
				'to {C:attention}every poker hand, scaling with {C:attention}Ante{}',
				'{X:dark_edition,C:white}Negative{} {X:dark_edition,C:white}Ability:{} Levels up all poker hands once',
			}
		},
		config = {},
		set = 'jen_jokerability',
		pos = { x = 0, y = 0 },
		soul_pos = { x = 1, y = 0, extra = { x = 2, y = 0 }},
		cost = 15,
		unlocked = true,
		discovered = true,
		hidden = true,
		no_doe = true,
		soul_rate = 0,
		atlas = 'jenbroken_c',
		can_use = function(self, card)
			return abletouseabilities()
		end,
		keep_on_use = function(self, card)
			return #SMODS.find_card('j_jen_broken') > 0 and not (card.edition or {}).negative
		end,
		use = function(self, card, area, copier)
			if (card.edition or {}).negative then
					update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize('k_all_hands'),chips = '...', mult = '...', level=''})
					G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
						play_sound('tarot1')
						card:juice_up(0.8, 0.5)
						G.TAROT_INTERRUPT_PULSE = true
						return true end }))
					update_hand_text({delay = 0}, {mult = '+', StatusText = true})
					G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.9, func = function()
						play_sound('tarot1')
						card:juice_up(0.8, 0.5)
						return true end }))
					update_hand_text({delay = 0}, {chips = '+', StatusText = true})
					G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.9, func = function()
						play_sound('tarot1')
						card:juice_up(0.8, 0.5)
						G.TAROT_INTERRUPT_PULSE = nil
						return true end }))
					update_hand_text({sound = 'button', volume = 0.7, pitch = 0.9, delay = 0}, {level='+1'})
					delay(1.3)
					for k, v in pairs(G.GAME.hands) do
						level_up_hand(card, k, true, 1)
					end
			end
			local targets = {}
			for k, v in pairs(G.consumeables.cards) do
				if v.ability.set == 'Planet' and not v.alrm then
					v.alrm = true
					table.insert(targets, v)
				end
			end
			if #targets > 0 then
				local intensity = 0
				for k, v in pairs(targets) do
					intensity = intensity + 1 + (v:getQty()/4) - 0.25
					G.consumeables:remove_card(v)
					G.play:emplace(v)
				end
				for _, hand in ipairs(G.handlist) do
					local fastforward = false
					update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(hand, 'poker_hands'),chips = G.GAME.hands[hand].chips, mult = G.GAME.hands[hand].mult, level=G.GAME.hands[hand].level})
					for k, v in pairs(targets) do
						local qty = v:getQty()
						fastforward = intensity > 5
						local ante = math.min(math.max(1, G.GAME.round_resets.ante), 1e9)
						local levels = pseudorandom(pseudoseed('broken_levels'), ante, ante * 5)
						local addchips = pseudorandom(pseudoseed('broken_chips'), 25 * ante, 50 * ante)
						local addmult = pseudorandom(pseudoseed('broken_mult'), 4 * ante, 30 * ante)
						local xchips = pseudorandom(pseudoseed('broken_xchips'), 20 * (ante/2), 50 * ante) / 10
						local xmult = pseudorandom(pseudoseed('broken_xmult'), 20 * (ante/2), 50 * ante) / 10
						local echips = pseudorandom(pseudoseed('broken_echips'))/3 + 1 + (ante / 50)
						local emult = pseudorandom(pseudoseed('broken_emult'))/3 + 1 + (ante / 50)
						if fastforward then
							for i = 1, qty do
								G.GAME.hands[hand].chips = ((G.GAME.hands[hand].chips + addchips) * xchips) ^ echips
								G.GAME.hands[hand].mult = ((G.GAME.hands[hand].mult + addmult) * xmult) ^ emult
							end
						else
							for i = 1, qty do
								level_up_hand(v, hand, nil, levels)
								G.GAME.hands[hand].chips = ((G.GAME.hands[hand].chips + addchips) * xchips) ^ echips
								G.GAME.hands[hand].mult = ((G.GAME.hands[hand].mult + addmult) * xmult) ^ emult
								G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
									play_sound('chips1')
									v:juice_up(0.8, 0.5)
								return true end }))
								update_hand_text({delay = 1.3}, {chips = '+' .. tostring(addchips), StatusText = true})
								G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
									play_sound('talisman_xchip')
									v:juice_up(0.8, 0.5)
								return true end }))
								update_hand_text({delay = 1.3}, {chips = 'x' .. tostring(xchips), StatusText = true})
								G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
									play_sound('talisman_echip')
									v:juice_up(0.8, 0.5)
								return true end }))
								update_hand_text({delay = 1.3}, {chips = '^' .. tostring(round(echips, 3)), StatusText = true})
								G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
									play_sound('multhit1')
									v:juice_up(0.8, 0.5)
								return true end }))
								update_hand_text({delay = 1.3}, {mult = '+' .. tostring(addmult), StatusText = true})
								G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
									play_sound('multhit2')
									v:juice_up(0.8, 0.5)
								return true end }))
								update_hand_text({delay = 1.3}, {mult = 'x' .. tostring(xmult), StatusText = true})
								G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
									play_sound('talisman_emult', 1)
									v:juice_up(0.8, 0.5)
								return true end }))
								update_hand_text({delay = 1.3}, {mult = '^' .. tostring(round(emult, 3)), StatusText = true})
							end
						end
					end
					if fastforward then
						G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
							play_sound('button')
						return true end }))
						update_hand_text({delay = 1.3}, {chips = '+++', mult = '+++', level = '+++', StatusText = true})
					end
					update_hand_text({sound = 'button', volume = 0.5, pitch = 1.1, delay = 3}, {handname=localize(hand, 'poker_hands'),chips = G.GAME.hands[hand].chips, mult = G.GAME.hands[hand].mult, level=G.GAME.hands[hand].level})
				end
				G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.5, func = function()
					for k, v in pairs(targets) do
						v:remove()
					end
					return true
				end}))
			else
				card_eval_status_text(card, 'extra', nil, nil, nil, {message = 'Nothing to devour!', colour = G.C.MULT})
			end
			update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
		end
	}

	SMODS.Joker {
		key = 'wondergeist',
		loc_txt = {
			name = 'Jen Walter the Wondergeist',
			text = {
				'{C:attention}Poker hands{} gain',
				'{X:jen_RGB,C:white,s:3}^^2{C:chips} Chips{} and {X:jen_RGB,C:white,s:3}^^2{C:mult} Mult',
				'when leveled up',
				' ',
				'{C:inactive,s:1.25,E:1}i feel... otherworldly...!{}'
			}
		},
		config = {},
		pos = { x = 0, y = 0 },
		soul_pos = { x = 1, y = 0, extra = { x = 2, y = 0 }},
		set_card_type_badge = transcendent,
		no_doe = true,
		cost = 5e5,
		rarity = 6,
		unlocked = true,
		discovered = true,
		blueprint_compat = false,
		eternal_compat = true,
		perishable_compat = false,
		immune_to_chemach = true,
		atlas = 'jenwondergeist'
	}

	SMODS.Joker {
		key = 'wondergeist2',
		loc_txt = {
			name = 'Jen Walter, Wondergeist of Omegaomnipotence',
			text = {
				'{C:attention}Poker hands{} gain',
				'{X:black,C:red,s:4}^^^3{C:purple} Chips & Mult{}',
				'when leveled up',
				' ',
				"{C:inactive,s:1.25,E:1}my body feels so... delicate, but strong at the same time...?{}"
			}
		},
		pos = { x = 0, y = 0 },
		soul_pos = { x = 1, y = 0, extra = { x = 2, y = 0 }},
		set_card_type_badge = hypertranscendent,
		no_doe = true,
		cost = 5e8,
		rarity = 6,
		unlocked = true,
		discovered = true,
		blueprint_compat = false,
		eternal_compat = true,
		perishable_compat = false,
		immune_to_chemach = true,
		atlas = 'jenwondergeist2'
	}

	SMODS.Joker {
		key = 'paragon',
		loc_txt = {
			name = 'The {C:dark_edition}Paragon{} of {C:cry_epic}Darkness{}',
			text = {
				'{X:inactive}Energy{} : {C:attention}#1#{C:inactive} / ' .. tostring(nyx_maxenergy*3) .. '{}',
				'Selling a {C:attention}Joker {C:inactive}(excluding this one){} or {C:attention}consumable{} will',
				'{C:attention}create a new random one{} of the {C:attention}same type/rarity{}',
				'{C:inactive}(Does not require slots, but may overflow, retains edition){}',
				'{C:inactive}(Does not work on fusions or jokers better than Exotic){}',
				' ',
				'Recharges {C:attention}' .. math.ceil(nyx_maxenergy) .. ' energy{} at',
				'the end of every {C:attention}Ante{}',
				' ',
				"{C:inactive,s:1.2,E:1}-Wo--r-sh-ip y--ou---r g--o-ddess---...{}",
				'{C:dark_edition,s:0.7,E:2}Face art by : ThreeCubed{}'
			}
		},
		config = {extra = {energy = nyx_maxenergy * 3}},
		pos = { x = 0, y = 0 },
		soul_pos = { x = 1, y = 0, extra = { x = 2, y = 0 }},
		cost = 400,
		rarity = 6,
		set_card_type_badge = transcendent,
		unlocked = true,
		discovered = true,
		no_doe = true,
		blueprint_compat = true,
		eternal_compat = true,
		perishable_compat = false,
		immune_to_chemach = true,
		atlas = 'jenparagon',
		loc_vars = function(self, info_queue, center)
			return {vars = {center.ability.extra.energy}}
		end,
		calculate = function(self, card, context)
			if not context.individual and not context.repetition and not card.debuff and context.end_of_round and not context.blueprint and G.GAME.blind.boss and not (G.GAME.blind.config and G.GAME.blind.config.bonus) then
				card.ability.extra.energy = math.min(card.ability.extra.energy + nyx_maxenergy, nyx_maxenergy*3)
				card_status_text(card, card.ability.extra.energy .. '/' .. nyx_maxenergy*3, nil, 0.05*card.T.h, G.C.GREEN, 0.6, 0.6, nil, nil, 'bm', 'generic1')
			elseif context.selling_card and not context.selling_self then
				local targetslot = #G.jokers.cards
				if G.jokers.cards[targetslot] and G.jokers.cards[targetslot] ~= card and (G.jokers.cards[targetslot].ability.name == 'j_jen_nyx' or G.jokers.cards[targetslot].ability.name == 'j_jen_paragon') then
					while true do
						targetslot = targetslot - 1
						if targetslot <= 0 then
							break
						elseif G.jokers.cards[targetslot] then
							if G.jokers.cards[targetslot] == card or (G.jokers.cards[targetslot].ability.name ~= 'j_jen_nyx' or G.jokers.cards[targetslot].ability.name ~= 'j_jen_paragon') then
								break
							end
						end
					end
				end
				if card ~= G.jokers.cards[targetslot] then
					if card.ability.extra.energy > 0 then
						local c = context.card
						local valid = c.ability.set ~= 'Joker' or type(c.config.center.rarity) == 'string' or (c.config.center.rarity >= 1 and c.config.center.rarity <= 4)
						if not c.config.center.immune_to_nyx and valid and not c.playing_card then
							local new = 'n/a'
							if c.ability.set == 'Joker' then
								local rarity = c.config.center.rarity
								local legendary = false
								if rarity == 1 then
									rarity = 0
								elseif rarity == 2 then
									rarity = 0.9
								elseif rarity == 3 then
									rarity = 0.99
								elseif rarity == 4 then
									rarity = nil
									legendary = true
								elseif rarity == 'cry_epic' then
									rarity = 1
								end
								new = create_card(c.ability.set, c.area, legendary, rarity, nil, nil, nil, 'nyx_replacement')
							else
								new = create_card(c.ability.set, c.area, nil, nil, nil, nil, nil, 'nyx_replacement')
							end
							if c.edition then
								new:set_edition(c.edition)
							end
							if c.ability.set ~= 'Joker' and c:getQty() > 1 then
								new:setQty(c:getQty())
								new:create_stack_display()
							end
							new:add_to_deck()
							c.area:emplace(new)
							if noretriggers(context) then
								card.ability.extra.energy = card.ability.extra.energy - 1
								card_status_text(card, card.ability.extra.energy .. '/' .. nyx_maxenergy*3, nil, 0.05*card.T.h, G.C.FILTER, 0.6, 0.6, nil, nil, 'bm', 'generic1')
							end
							return {calculated=true}
						end
					elseif noretriggers(context) then
						card_status_text(card, 'No energy!', nil, 0.05*card.T.h, G.C.RED, 0.6, 0.6, nil, nil, 'bm', 'cancel')
					end
				end
			end
		end
	}

	SMODS.Joker {
		key = 'godsmos',
		loc_txt = {
			name = 'Godsmos',
			text = {
				'{C:attention}Retrigger{} all Jokers {C:attention}6{} times',
				'All cards in hand and play give {X:black,C:red,s:5}#1#666{C:mult} Mult{C:attention} 66{} times',
				'{C:attention}Poker hands{} gain {X:black,C:red,s:5}#1#666{C:chips} Chips{} and{C:mult} Mult{} when leveled up',
				'',
				' ',
				"{C:inactive,s:1.25,E:1}Do I make you feel uneasy?{}"
			}
		},
		pos = { x = 0, y = 0 },
		soul_pos = { x = 1, y = 0, extra = { x = 2, y = 0 }},
		set_card_type_badge = omegatranscendent,
		no_doe = true,
		cost = 6.66e66,
		rarity = 6,
		unlocked = true,
		discovered = true,
		blueprint_compat = false,
		eternal_compat = true,
		perishable_compat = false,
		immune_to_chemach = true,
		debuff_immune = true,
		dissolve_immune = true,
		atlas = 'jenareyoufrightenedofthismodyet',
		loc_vars = function(self, info_queue, center)
			return {vars = {'{66}'}}
		end,
		calculate = function(self, card, context)
			card:set_eternal(true)
			if not context.blueprint then
				if context.retrigger_joker_check and not context.retrigger_joker then
					return {
						message = obfuscatedtext(math.random(5,20)),
						repetitions = 6,
						nopeus_again = true,
						card = card
					}
				elseif context.individual and (context.cardarea and context.cardarea == G.hand or context.cardarea == G.play) then
					return {
						message = obfuscatedtext(math.random(5,20)),
						hyper_mult = {66, 666},
						colour = G.C.DARK_EDITION
					}
				end
			end
		end
	}

	FusionJokers.fusions:add_fusion('j_jen_godsmarble', nil, nil, 'j_jen_leshy', nil, nil, 'j_jen_pawn', 100)
	FusionJokers.fusions:add_fusion('j_jen_godsmarble', nil, nil, 'j_jen_heket', nil, nil, 'j_jen_knight', 100)
	FusionJokers.fusions:add_fusion('j_jen_godsmarble', nil, nil, 'j_jen_kallamar', nil, nil, 'j_jen_jester', 100)
	FusionJokers.fusions:add_fusion('j_jen_godsmarble', nil, nil, 'j_jen_shamura', nil, nil, 'j_jen_arachnid', 100)
	FusionJokers.fusions:add_fusion('j_jen_godsmarble', nil, nil, 'j_jen_lambert', nil, nil, 'j_jen_reign', 100)
	FusionJokers.fusions:add_fusion('j_jen_godsmarble', nil, nil, 'j_jen_narinder', nil, nil, 'j_jen_feline', 100)
	FusionJokers.fusions:add_fusion('j_jen_godsmarble', nil, nil, 'j_jen_clauneck', nil, nil, 'j_jen_fateeater', 100)
	FusionJokers.fusions:add_fusion('j_jen_godsmarble', nil, nil, 'j_jen_kudaai', nil, nil, 'j_jen_foundry', 100)
	FusionJokers.fusions:add_fusion('j_jen_godsmarble', nil, nil, 'j_jen_chemach', nil, nil, 'j_jen_broken', 100)
	FusionJokers.fusions:add_fusion('j_jen_godsmarble', nil, nil, 'j_jen_nyx', nil, nil, 'j_jen_paragon', 1e4)
	FusionJokers.fusions:add_fusion('j_jen_godsmarble', nil, nil, 'j_jen_jen', nil, nil, 'j_jen_wondergeist', 1e6)
	FusionJokers.fusions:add_fusion('j_jen_godsmarble', nil, nil, 'j_jen_wondergeist', nil, nil, 'j_jen_wondergeist2', 1e9)
	FusionJokers.fusions:add_fusion('j_jen_kosmos', nil, nil, 'j_jen_wondergeist2', nil, nil, 'j_jen_godsmos', 6.66e66)
end

local dissolve_ref = Card.start_dissolve
function Card:start_dissolve(dissolve_colours, silent, dissolve_time_fac, no_juice)
	if ((self.config or {}).center or {}).dissolve_immune then
		card_status_text(card, 'Immune', nil, 0.05*card.T.h, G.C.RED, nil, 0.6, nil, nil, 'bm', 'cancel')
		if not self.added_to_deck then
			self:add_to_deck()
			if self.ability.set == 'Joker' then G.jokers:emplace(self) else G.consumeables:emplace(self) end
		end
		return
	else
		if self.ability.set ~= 'Voucher' then
			if (self.edition or {}).jen_diplopia then
				card_status_text(self, 'Resist!', nil, 0.05*self.T.h, G.C.RED, nil, 0.6, nil, nil, 'bm', 'cancel')
				self:set_edition(nil, true)
				if self.area then self.area:remove_card(self) end
				if not self.added_to_deck then self:add_to_deck() end
				if self.playing_card then
					local still_in_playingcard_table = false
					for k, v in pairs(G.playing_cards) do
						if v == self then
							still_in_playingcard_table = true
							break
						end
					end
					if not still_in_playingcard_table then
						G.playing_card = (G.playing_card and G.playing_card + 1) or 1
						table.insert(G.playing_cards, self)
					end
					G.deck:emplace(self)
				else
					(self.ability.set == 'Joker' and G.jokers or G.consumeables):emplace(self)
					if self.ability.set ~= 'Joker' then
						self:setQty(self.OverrideBulkUseLimit or (self.ability or {}).qty_initial or 1)
					end
				end
				return
			else
				if (self.edition or {}).jen_encoded then
					for i = 1, (self.edition or {}).jen_codes or 10 do
						local _card = create_card('Code', G.consumeables, nil, nil, nil, nil, nil, 'encoded_cards')
						_card:add_to_deck()
						G.consumeables:emplace(_card)
					end
				end
				dissolve_ref(self, dissolve_colours, silent, dissolve_time_fac, no_juice)
			end
		else
			dissolve_ref(self, dissolve_colours, silent, dissolve_time_fac, no_juice)
		end
	end
end

local shatter_ref = Card.shatter
function Card:shatter()
	if ((self.config or {}).center or {}).dissolve_immune then
		card_status_text(card, 'Immune', nil, 0.05*card.T.h, G.C.RED, nil, 0.6, nil, nil, 'bm', 'cancel')
		if not self.added_to_deck then
			self:add_to_deck()
			if self.ability.set == 'Joker' then G.jokers:emplace(self) else G.consumeables:emplace(self) end
		end
		return
	else
		if self.ability.set ~= 'Voucher' then
			if (self.edition or {}).almanac_dissolve then
				self.edition:almanac_dissolve(self)
			end
			if (self.edition or {}).jen_diplopia then
				card_status_text(self, 'Resist!', nil, 0.05*self.T.h, G.C.RED, nil, 0.6, nil, nil, 'bm', 'cancel')
				self:set_edition(nil, true)
				if self.area then self.area:remove_card(self) end
				if not self.added_to_deck then self:add_to_deck() end
				if self.playing_card then
					local still_in_playingcard_table = false
					for k, v in pairs(G.playing_cards) do
						if v == self then
							still_in_playingcard_table = true
							break
						end
					end
					if not still_in_playingcard_table then
						G.playing_card = (G.playing_card and G.playing_card + 1) or 1
						table.insert(G.playing_cards, self)
					end
					G.deck:emplace(self)
				else
					(self.ability.set == 'Joker' and G.jokers or G.consumeables):emplace(self)
					if self.ability.set ~= 'Joker' then
						self:setQty((self.ability or {}).qty_initial or 1)
					end
				end
				return
			else
				if (self.edition or {}).jen_encoded then
					for i = 1, (self.edition or {}).codes or 10 do
						local _card = create_card('Code', G.consumeables, nil, nil, nil, nil, nil, 'encoded_cards')
						_card:add_to_deck()
						G.consumeables:emplace(_card)
					end
				end
				shatter_ref(self)
			end
		else
			shatter_ref(self)
		end
	end
end

local csdr = Card.set_debuff
function Card:set_debuff(should_debuff)
	if ((self.config or {}).center or {}).debuff_immune and should_debuff == true then
		card_status_text(card, 'Immune', nil, 0.05*card.T.h, G.C.RED, nil, 0.6, nil, nil, 'bm', 'cancel')
		return false
	else
		csdr(self, should_debuff)
	end
end

local misprintedition_config = {
	additive = {0, 50},
	multiplicative = 15,
	exponential = 2
}

function Card:wee_apply()
	if not self.originalsize then self.originalsize = {self.T.w, self.T.h} end
	self.T.w = self.T.w / Jen.config.wee_sizemod
	self.T.h = self.T.h / Jen.config.wee_sizemod
end

function Card:wee_revert()
	if self.originalsize then
		self.T.w = self.originalsize[1]
		self.T.h = self.originalsize[2]
	end
end

local ser = Card.set_edition
function Card:set_edition(edition, immediate, silent)
	if (((self.config or {}).center or {}).set or '') == 'jen_jokerability' and not (edition or {}).negative then
		return
	elseif ((self.config or {}).center or {}).edition_immune then
		local immunity = self.config.center.edition_immune
		if type(immunity) ~= 'string' or edition[immunity] then
			card_status_text(card, localize('k_nope_ex'), nil, 0.05*card.T.h, G.C.RED, nil, 0.6, nil, nil, 'bm', 'cancel')
			return
		else
			self:wee_revert()
			ser(self, edition, immediate, silent)
			if self.edition then
				if self.edition.jen_wee then
					self:wee_apply()
				elseif self.edition.jen_misprint then
					self.edition.chips = pseudorandom('misprintedition_1', misprintedition_config.additive[1], misprintedition_config.additive[2])
					self.edition.mult = pseudorandom('misprintedition_2', misprintedition_config.additive[1], misprintedition_config.additive[2])
					self.edition.x_chips = 1 + (round(pseudorandom('misprintedition_3'), 2) * (misprintedition_config.multiplicative - 1))
					self.edition.x_mult = 1 + (round(pseudorandom('misprintedition_4'), 2) * (misprintedition_config.multiplicative - 1))
					self.edition.e_chips = 1 + (round(pseudorandom('misprintedition_5'), 3) * (misprintedition_config.exponential - 1))
					self.edition.e_mult = 1 + (round(pseudorandom('misprintedition_6'), 3) * (misprintedition_config.exponential - 1))
				end
			end
			self:align()
		end
	else
		self:wee_revert()
		ser(self, edition, immediate, silent)
		if self.edition then
			if self.edition.jen_wee and self.T and self.T.w and self.T.h then
				self:wee_apply()
			elseif self.edition.jen_misprint then
				self.edition.chips = pseudorandom('misprintedition_1', misprintedition_config.additive[1], misprintedition_config.additive[2])
				self.edition.mult = pseudorandom('misprintedition_2', misprintedition_config.additive[1], misprintedition_config.additive[2])
				self.edition.x_chips = 1 + (round(pseudorandom('misprintedition_3'), 2) * (misprintedition_config.multiplicative - 1))
				self.edition.x_mult = 1 + (round(pseudorandom('misprintedition_4'), 2) * (misprintedition_config.multiplicative - 1))
				self.edition.e_chips = 1 + (round(pseudorandom('misprintedition_5'), 3) * (misprintedition_config.exponential - 1))
				self.edition.e_mult = 1 + (round(pseudorandom('misprintedition_6'), 3) * (misprintedition_config.exponential - 1))
			end
		end
		self:align()
	end
end

local luhr = level_up_hand
function level_up_hand(card, hand, instant, amount)
	amount = amount or 1
	local origchips = G.GAME.hands[hand].chips
	local origmult = G.GAME.hands[hand].mult
	local levelchips = G.GAME.hands[hand].l_chips
	local levelmult = G.GAME.hands[hand].l_mult
	luhr(card, hand, instant, amount)
	if card then
		amount = math.min(2500, amount)
		if #SMODS.find_card('j_jen_wondergeist') > 0 and amount > 0 then
			local poltercloths = SMODS.find_card('j_jen_wondergeist')
			if next(poltercloths) then
				for k, v in pairs(poltercloths) do
					for i = 1, amount do
						origchips = (origchips + levelchips) ^ (origchips + levelchips)
						origmult = (origmult + levelmult) ^ (origmult + levelmult)
					end
					G.GAME.hands[hand].chips = origchips
					G.GAME.hands[hand].mult = origmult
					if not instant then
						G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
							play_sound('talisman_eechip')
							v:juice_up(3, 3)
						return true end }))
						update_hand_text({delay = 3}, {chips = '^^' .. tostring(2 ^ amount), StatusText = true})
						G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
							play_sound('talisman_eemult')
							v:juice_up(3, 3)
						return true end }))
						update_hand_text({delay = 3}, {mult = '^^' .. tostring(2 ^ amount), StatusText = true})
						update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 3}, {handname=localize(hand, 'poker_hands'),chips = G.GAME.hands[hand].chips, mult = G.GAME.hands[hand].mult})
					end
				end
			end
		end
		if #SMODS.find_card('j_jen_wondergeist2') > 0 and amount > 0 then
			local poltercloths = SMODS.find_card('j_jen_wondergeist2')
			if next(poltercloths) then
				for k, v in pairs(poltercloths) do
					for i = 1, amount do
						origchips = (origchips + levelchips):arrow(3, 3)
						origmult = (origmult + levelmult):arrow(3, 3)
					end
					G.GAME.hands[hand].chips = origchips
					G.GAME.hands[hand].mult = origmult
					if not instant then
						G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
							play_sound('talisman_eeechip')
							v:juice_up(5, 5)
						return true end }))
						update_hand_text({delay = 5}, {chips = '^^^3', StatusText = true})
						G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
							play_sound('talisman_eeemult')
							v:juice_up(5, 5)
						return true end }))
						update_hand_text({delay = 5}, {mult = '^^^3', StatusText = true})
						update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 3}, {handname=localize(hand, 'poker_hands'),chips = G.GAME.hands[hand].chips, mult = G.GAME.hands[hand].mult})
					end
				end
			end
		end
		if #SMODS.find_card('j_jen_godsmos') > 0 and amount > 0 then
			local pandemonium = SMODS.find_card('j_jen_godsmos')
			if next(pandemonium) then
				for k, v in pairs(pandemonium) do
					for i = 1, amount do
						origchips = (origchips + levelchips):arrow(66, 666)
						origmult = (origmult + levelmult):arrow(66, 666)
					end
					G.GAME.hands[hand].chips = origchips
					G.GAME.hands[hand].mult = origmult
					if not instant then
						G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
							play_sound('talisman_eeechip')
							v:juice_up(10, 10)
						return true end }))
						update_hand_text({delay = 5}, {chips = str, StatusText = true})
						G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
							play_sound('talisman_eeemult')
							v:juice_up(10, 10)
						return true end }))
						update_hand_text({delay = 5}, {mult = str, StatusText = true})
						update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 3}, {handname=localize(hand, 'poker_hands'),chips = G.GAME.hands[hand].chips, mult = G.GAME.hands[hand].mult})
					end
				end
			end
		end
	end
end

--CONSUMABLES

local supported_tags = {
	{'tag_uncommon', 'Uncommon', 4, 4, 3},
	{'tag_rare', 'Rare', 0, 4, 5},
	{'tag_negative', 'Negative', 3, 3, 10},
	{'tag_foil', 'Foil', 2, 2, 3},
	{'tag_holo', 'Holographic', 5, 2, 3},
	{'tag_polychrome', 'Polychrome', 5, 3, 5},
	{'tag_investment', 'Investment', 0, 3, 8},
	{'tag_voucher', 'Voucher', 5, 4, 5},
	{'tag_standard', 'Standard', 2, 4, 3},
	{'tag_charm', 'Charm', 1, 0, 5},
	{'tag_meteor', 'Meteor', 2, 3, 5},
	{'tag_buffoon', 'Buffoon', 0, 0, 8},
	{'tag_handy', 'Handy', 4, 2, 8},
	{'tag_garbage', 'Garbage', 3, 2, 6},
	{'tag_ethereal', 'Ethereal', 1, 2, 5},
	{'tag_coupon', 'Coupon', 2, 0, 10},
	{'tag_double', 'Double', 5, 1, 6},
	{'tag_juggle', 'Juggle', 1, 3, 2},
	{'tag_d_six', 'D6', 4, 1, 2},
	{'tag_top_up', 'Top-up', 3, 4, 2},
	{'tag_skip', 'Speed', 1, 4, 7},
	{'tag_economy', 'Economy', 0, 2, 10},
	{'tag_cry_epic', 'Epic', 4, 0, 8},
	{'tag_cry_bundle', 'Bundle', 3, 0, 7},
	{'tag_cry_triple', 'Triple', 3, 1, 8},
	{'tag_cry_quadruple', 'Quadruple', 1, 1, 10},
	{'tag_cry_quintuple', 'Quintuple', 2, 1, 13},
	{'tag_cry_memory', 'Memory', 5, 0, 8}
}

for k, v in pairs(supported_tags) do
	SMODS.Consumable {
		key = 'token_' .. v[1],
		set = 'jen_tokens',
		loc_txt = {
			name = v[2] .. ' Token',
			text = {
				'Use to create a',
				('{C:attention}' .. v[2] .. ' Tag{}')
			},
		},
		pos = {x = v[3], y = v[4]},
		cost = v[5],
		unlocked = true,
		discovered = true,
		atlas = 'jentokens',
		can_stack = true,
		can_divide = true,
		can_use = function(self, card)
			return abletouseconsumables()
		end,
		use = function(self, card, area, copier)
			play_sound('jen_e_gilded', 1.25, 0.4)
			add_tag(Tag(v[1]))
		end,
		bulk_use = function(self, card, area, copier, number)
			play_sound('jen_e_gilded', 1.25, 0.4)
			for i = 1, number do
				add_tag(Tag(v[1]))
			end
		end
	}
end

local function rfoolconsumables()
	if not G.consumeables then return 0 end
	return #G.consumeables.cards - #SMODS.find_card('c_jen_reverse_fool')
end

local torat = function(self, card, badges)
	badges[#badges + 1] = create_badge("Torat", get_type_colour(self or card.config, card), G.C.RED, 1.2)
end

SMODS.Consumable {
	key = 'reverse_fool',
	set = 'Spectral',
	loc_txt = {
		name = 'The Genius',
		text = {
			'Recreate {C:attention}all consumables{}',
			'you have {C:attention}used throughout the run{} as {C:dark_edition}Negatives{}',
			'{C:inactive,s:0.7}(The Genius excluded){}',
			'{X:attention,C:white,s:2}x2{C:red,s:2} Ante{}'
		}
	},
	set_card_type_badge = torat,
	pos = { x = 9, y = 2 },
	cost = 50,
	unlocked = true,
	discovered = true,
	hidden = true,
	soul_rate = 0.001,
	atlas = 'jenrtarots',
	can_use = function(self, card)
		return abletouseconsumables() and next(G.GAME.consumeable_usage or {})
	end,
	use = function(self, card, area, copier)
		for k, v in pairs(G.GAME.consumeable_usage) do
			if k ~= 'c_jen_reverse_fool' then
				G.E_MANAGER:add_event(Event({
					delay = 0.1,
					func = function()
						local neg = create_card(v.set, G.consumeables, nil, nil, nil, nil, k, nil)
						neg:set_edition({negative = true})
						neg:setQty(v.count)
						neg:add_to_deck()
						G.consumeables:emplace(neg)
						return true
					end
				}))
			end
		end
		multante()
	end,
	bulk_use = function(self, card, area, copier, number)
		for k, v in pairs(G.GAME.consumeable_usage) do
			if k ~= 'c_jen_reverse_fool' then
				G.E_MANAGER:add_event(Event({
					delay = 0.1,
					func = function()
						local neg = create_card(v.set, G.consumeables, nil, nil, nil, nil, k, nil)
						neg:set_edition({negative = true})
						neg:setQty(v.count * number)
						neg:add_to_deck()
						G.consumeables:emplace(neg)
						return true
					end
				}))
			end
		end
		multante(number)
	end
}

local function createfulldeck(enhancement, edition, amount, emplacement)
	for k, v in pairs(G.P_CARDS) do
		G.E_MANAGER:add_event(Event({
			delay = 0.1,
			func = function()
				local front = v
				local cards = {}
				for i = 1, (amount or 1) do
					cards[i] = true
					G.playing_card = (G.playing_card and G.playing_card + 1) or 1
					local card = Card(G.play.T.x + G.play.T.w/2, G.play.T.y, G.CARD_W, G.CARD_H, v, enhancement or G.P_CENTERS.c_base, {playing_card = G.playing_card})
					if edition then
						card:set_edition(type(edition) == 'table' and edition or {[edition] = true}, true, true)
					end
					play_sound('card1')
					table.insert(G.playing_cards, card)
					if emplacement then emplacement:emplace(card) else G.deck:emplace(card) end
				end
				playing_card_joker_effects(cards)
				return true
			end
		}))
	end
end

local function createcardset(needle, enhancement, edition, amount, emplacement)
	for k, v in pairs(G.P_CARDS) do
		if string.find(k, needle) then
			G.E_MANAGER:add_event(Event({
				delay = 0.1,
				func = function()
					local front = v
					local cards = {}
					for i = 1, (amount or 1) do
						cards[i] = true
						G.playing_card = (G.playing_card and G.playing_card + 1) or 1
						local card = Card(G.play.T.x + G.play.T.w/2, G.play.T.y, G.CARD_W, G.CARD_H, v, enhancement or G.P_CENTERS.c_base, {playing_card = G.playing_card})
						if edition then
							card:set_edition(type(edition) == 'table' and edition or {[edition] = true}, true, true)
						end
						play_sound('card1')
						table.insert(G.playing_cards, card)
						if emplacement then emplacement:emplace(card) else G.deck:emplace(card) end
					end
					playing_card_joker_effects(cards)
					return true
				end
			}))
		end
	end
end

local enhancereversetarots = {
	{
		b = 'magician',
		n = 'The Scientist',
		c = 'Lucky',
		e = G.P_CENTERS.m_lucky,
		p = { x = 8, y = 2 }
	},
	{
		b = 'empress',
		n = 'The Peasant',
		c = 'Mult',
		e = G.P_CENTERS.m_mult,
		p = { x = 6, y = 2 }
	},
	{
		b = 'hierophant',
		n = 'The Adversary',
		c = 'Bonus',
		e = G.P_CENTERS.m_bonus,
		p = { x = 4, y = 2 }
	},
	{
		b = 'lovers',
		n = 'The Rivals',
		c = 'Wild',
		e = G.P_CENTERS.m_wild,
		p = { x = 3, y = 2 }
	},
	{
		b = 'chariot',
		n = 'The Hitchhiker',
		c = 'Steel',
		e = G.P_CENTERS.m_steel,
		p = { x = 2, y = 2 }
	},
	{
		b = 'justice',
		n = 'Injustice',
		c = 'Glass',
		e = G.P_CENTERS.m_glass,
		p = { x = 1, y = 2 }
	},
	{
		b = 'devil',
		n = 'The Angel',
		c = 'Gold',
		e = G.P_CENTERS.m_gold,
		p = { x = 4, y = 1 }
	},
	{
		b = 'tower',
		n = 'The Collapse',
		c = 'Stone',
		e = G.P_CENTERS.m_stone,
		p = { x = 3, y = 1 }
	}
}

for k, v in ipairs(enhancereversetarots) do
	SMODS.Consumable {
		key = 'reverse_' .. v.b,
		set = 'Spectral',
		loc_txt = {
			name = v.n,
			text = {
				'Creates a {C:green}full deck{} of {C:attention}' .. v.c .. '{}',
				'cards and {C:blue}adds them to your deck{}'
			}
		},
		set_card_type_badge = torat,
		config = {},
		pos = v.p,
		cost = 13,
		aurinko = true,
		unlocked = true,
		discovered = true,
		hidden = true,
		soul_rate = 0.002,
		atlas = 'jenrtarots',
		can_use = function(self, card)
			return abletouseconsumables()
		end,
		use = function(self, card, area, copier)
			createfulldeck(v.e, not (card.edition or {}).negative and card.edition or nil)
		end,
		bulk_use = function(self, card, area, copier, number)
			createfulldeck(v.e, not (card.edition or {}).negative and card.edition or nil, number)
		end
	}
end

SMODS.Consumable {
	key = 'reverse_high_priestess',
	set = 'Spectral',
	loc_txt = {
		name = 'The Low Laywoman',
		text = {
			'Create {C:attention}#1#{}',
			'{C:planet}Meteor {C:attention}Tags{}'
		}
	},
	set_card_type_badge = torat,
	config = {extra = {planetpacks = 10}},
	pos = { x = 7, y = 2 },
	cost = 13,
	unlocked = true,
	discovered = true,
	hidden = true,
	soul_rate = 0.002,
	atlas = 'jenrtarots',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.planetpacks}}
    end,
	can_use = function(self, card)
		return abletouseconsumables()
	end,
	use = function(self, card, area, copier)
		for i = 1, card.ability.extra.planetpacks do
			add_tag(Tag('tag_meteor'))
		end
	end,
	bulk_use = function(self, card, area, copier, number)
		for i = 1, card.ability.extra.planetpacks * number do
			add_tag(Tag('tag_meteor'))
		end
	end
}

SMODS.Consumable {
	key = 'reverse_emperor',
	set = 'Spectral',
	loc_txt = {
		name = 'The Servant',
		text = {
			'Gives {C:attention}#1#{C:spectral} Ethereal{}',
			'and {C:tarot}Charm{C:attention} Tags',
			'{C:attention}+1{C:red} Ante{}'
		}
	},
	set_card_type_badge = torat,
	config = {extra = {tags = 5}},
	pos = { x = 5, y = 2 },
	cost = 13,
	unlocked = true,
	discovered = true,
	hidden = true,
	soul_rate = 0.002,
	atlas = 'jenrtarots',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.tags}}
    end,
	can_use = function(self, card)
		return abletouseconsumables()
	end,
	use = function(self, card, area, copier)
		for i = 1, card.ability.extra.tags do
			add_tag(Tag('tag_ethereal'))
			add_tag(Tag('tag_charm'))
		end
		ease_ante_autoraisewinante(1)
	end,
	bulk_use = function(self, card, area, copier, number)
		for i = 1, card.ability.extra.tags * number do
			add_tag(Tag('tag_ethereal'))
			add_tag(Tag('tag_charm'))
		end
		ease_ante_autoraisewinante(number)
	end
}

local function rhermittotal()
	if not G.jokers or not G.hand or not G.consumeables or not G.deck then return 0 end
	local value = 0
	for k, v in pairs(G.hand.cards) do
		value = value + (v.sell_cost or 0)
	end
	for k, v in pairs(G.jokers.cards) do
		value = value + (v.sell_cost or 0)
	end
	for k, v in pairs(G.consumeables.cards) do
		value = value + (v.sell_cost or 0)
	end
	for k, v in pairs(G.deck.cards) do
		value = value + (v.sell_cost or 0)
	end
	return value
end

local function rtemperancemult()
	if not G.jokers then return 2 end
	return 2 + #G.jokers.cards
end

SMODS.Consumable {
	key = 'reverse_hermit',
	set = 'Spectral',
	loc_txt = {
		name = 'The Extrovert',
		text = {
			'Gives you {C:money}money{} equal to the',
			'{C:money}net sell value{} of {C:attention,s:1.5}ALL{} cards you have',
			'{C:inactive}(Currently {C:money}$#1#{C:inactive}){}',
			'{C:attention}+2{C:red} Ante{}'
		}
	},
	set_card_type_badge = torat,
	pos = { x = 0, y = 2 },
	cost = 30,
	unlocked = true,
	discovered = true,
	hidden = true,
	soul_rate = 0.002,
	atlas = 'jenrtarots',
    loc_vars = function(self, info_queue, center)
        return {vars = {rhermittotal()}}
    end,
	can_use = function(self, card)
		return abletouseconsumables()
	end,
	use = function(self, card, area, copier)
		ease_dollars(rhermittotal())
		ease_ante_autoraisewinante(2)
	end,
	bulk_use = function(self, card, area, copier, number)
		ease_dollars(rhermittotal() * number)
		ease_ante_autoraisewinante(2 * number)
	end
}

SMODS.Consumable {
	key = 'reverse_wheel',
	set = 'Spectral',
	loc_txt = {
		name = 'The Disc of Penury',
		text = {
			'{C:attention}Randomises{} the {C:dark_edition}editions{} of',
			'your {C:attention}Jokers{}, {C:attention}consumables{} and {C:attention}playing cards{}',
			'{C:attention}+1{C:red} Ante{}',
			'{C:inactive,s:0.8}(Some editions are excluded from the pool){}',
			'{C:inactive,s:0.8}(Does not randomise Negative cards){}'
		}
	},
	set_card_type_badge = torat,
	pos = { x = 9, y = 1 },
	cost = 25,
	unlocked = true,
	discovered = true,
	hidden = true,
	soul_rate = 0.002,
	atlas = 'jenrtarots',
	can_use = function(self, card)
		return abletouseconsumables()
	end,
	use = function(self, card, area, copier)
		for k, v in pairs(G.jokers.cards) do
			if not (v.edition or {}).negative and not v:is_exotic_edition() then
				v:set_edition({[random_editions[pseudorandom('disc1', 1, #random_editions)]] = true}, k > 50, k > 50)
			end
		end
		for k, v in pairs(G.hand.cards) do
			if not (v.edition or {}).negative and not v:is_exotic_edition() then
				v:set_edition({[random_editions[pseudorandom('disc2', 1, #random_editions)]] = true}, k > 52, k > 52)
			end
		end
		for k, v in pairs(G.deck.cards) do
			if not (v.edition or {}).negative and not v:is_exotic_edition() then
				v:set_edition({[random_editions[pseudorandom('disc3', 1, #random_editions)]] = true}, true, true)
			end
		end
		for k, v in pairs(G.consumeables.cards) do
			if not (v.edition or {}).negative and not v:is_exotic_edition() and v.ability.set ~= 'jen_jokerability' then
				v:set_edition({[random_editions[pseudorandom('disc4', 1, #random_editions)]] = true}, k > 20, k > 20)
			end
		end
		ease_ante_autoraisewinante(1)
	end
}

SMODS.Consumable {
	key = 'reverse_strength',
	set = 'Spectral',
	loc_txt = {
		name = 'Infirmity',
		text = {
			'{C:attention}+#1#{} hand size',
			'{C:attention}+#1#{} maximum selectable cards',
			'{C:attention}+1{C:red} Ante{}'
		}
	},
	set_card_type_badge = torat,
	pos = { x = 8, y = 1 },
	config = {extra = {increase = 1}},
	cost = 20,
	unlocked = true,
	discovered = true,
	hidden = true,
	soul_rate = 0.002,
	atlas = 'jenrtarots',
    loc_vars = function(self, info_queue, center)
        return {vars = {math.ceil(center.ability.extra.increase)}}
    end,
	can_use = function(self, card)
		return abletouseconsumables()
	end,
	use = function(self, card, area, copier)
		G.hand:change_size(math.ceil(card.ability.extra.increase))
		G.hand:change_max_highlight(math.ceil(card.ability.extra.increase))
		ease_ante_autoraisewinante(1)
	end,
	bulk_use = function(self, card, area, copier, number)
		G.hand:change_size(math.ceil(card.ability.extra.increase) * number)
		G.hand:change_max_highlight(math.ceil(card.ability.extra.increase) * number)
		ease_ante_autoraisewinante(number)
	end
}

SMODS.Consumable {
	key = 'reverse_hanged_man',
	set = 'Spectral',
	loc_txt = {
		name = 'Zen',
		text = {
			'{C:attention}Randomly {C:money}sell {C:red}half {C:inactive,s:0.6}(rounded up){} of',
			'your {C:attention}playing cards{}, deck and hand alike'
		}
	},
	set_card_type_badge = torat,
	pos = { x = 7, y = 1 },
	cost = 15,
	unlocked = true,
	discovered = true,
	hidden = true,
	soul_rate = 0.002,
	atlas = 'jenrtarots',
	can_use = function(self, card)
		return abletouseconsumables() and (#G.hand.cards + #G.deck.cards > 1)
	end,
	use = function(self, card, area, copier)
		local tosell = 0
		local value = 0
		local targets = {}
		if #G.hand.cards > 1 then
			tosell = math.ceil(#G.hand.cards / 2)
			while tosell > 0 do
				local sel = G.hand.cards[pseudorandom('zen1', 1, #G.hand.cards)]
				if not sel.rhm then
					sel.rhm = true
					G.hand:remove_card(sel)
					table.insert(targets, sel)
					value = value + (sel.sell_cost or 1)
					tosell = tosell - 1
				end
			end
		end
		if #G.deck.cards > (#G.hand.cards > 0 and 0 or 1) then
			tosell = math.ceil(#G.deck.cards / 2)
			if tosell >= #G.deck.cards then
				for k, v in pairs(G.deck.cards) do
					G.deck:remove_card(v)
					table.insert(targets, v)
					value = value + (v.sell_cost or 1)
				end
				tosell = 0
			else
				while tosell > 0 do
					local sel = G.deck.cards[pseudorandom('zen2', 1, #G.deck.cards)]
					if not sel.rhm then
						sel.rhm = true
						G.deck:remove_card(sel)
						table.insert(targets, sel)
						value = value + (sel.sell_cost or 1)
						tosell = tosell - 1
					end
				end
			end
		end
		local tally = 0
		if #targets > 0 then
			for k, v in pairs(targets) do
				G.play:emplace(v)
				if #targets <= 150 then
					tally = tally + (v.sell_cost or 1)
					card_eval_status_text(v, 'extra', nil, nil, nil, {message = '$' .. tostring(tally), colour = G.C.DARK_EDITION})
				end
			end
			card_eval_status_text(card, 'extra', nil, nil, nil, {message = 'Total : $' .. value, colour = G.C.DARK_EDITION})
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.1, func = function()
				play_sound('coin2')
				ease_dollars(value)
				return true
			end}))
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.5, func = function()
				for k, v in pairs(targets) do
					v.rhm = false
					v:start_dissolve()
				end
				return true
			end}))
		end
	end
}

SMODS.Consumable {
	key = 'reverse_death',
	set = 'Spectral',
	loc_txt = {
		name = 'Life',
		text = {
			'Duplicate {C:attention}every card{} in',
			'{C:blue}your hand'
		}
	},
	set_card_type_badge = torat,
	pos = { x = 6, y = 1 },
	cost = 10,
	unlocked = true,
	discovered = true,
	hidden = true,
	soul_rate = 0.002,
	atlas = 'jenrtarots',
	can_use = function(self, card)
		return abletouseconsumables() and #G.hand.cards > 0
	end,
	use = function(self, card, area, copier)
		local cards = {}
		for k, v in pairs(G.hand.cards) do
			G.playing_card = (G.playing_card and G.playing_card + 1) or 1
			local copy = copy_card(v, nil, nil, G.playing_card)
			copy:add_to_deck()
			copy:start_materialize()
			table.insert(cards, copy)
		end
		for k, v in pairs(cards) do
			if v ~= card then
				table.insert(G.playing_cards, v)
				G.hand:emplace(v)
			end
		end
		playing_card_joker_effects(cards)
	end
}

SMODS.Consumable {
	key = 'reverse_temperance',
	set = 'Spectral',
	loc_txt = {
		name = 'Prodigality',
		text = {
			'Multiplies your {C:money}money{} by',
			'{C:attention}the number of Jokers{} you have {C:green}plus two{}',
			'{C:inactive}(Currently {X:money,C:white}$x#1#{C:tarot} = {C:money}$#2#{C:inactive}){}',
			'{X:attention,C:white,s:2}x2{C:red,s:2} Ante{}'
		}
	},
	set_card_type_badge = torat,
	pos = { x = 5, y = 1 },
	cost = 30,
	unlocked = true,
	discovered = true,
	hidden = true,
	soul_rate = 0.002,
	atlas = 'jenrtarots',
    loc_vars = function(self, info_queue, center)
        return {vars = {rtemperancemult(), math.min(1e308, (G.GAME.dollars or 0) * rtemperancemult())}}
    end,
	can_use = function(self, card)
		return abletouseconsumables()
	end,
	use = function(self, card, area, copier)
		ease_dollars(math.min(1e308, G.GAME.dollars * (rtemperancemult()) - G.GAME.dollars))
		multante()
	end,
	bulk_use = function(self, card, area, copier, number)
		ease_dollars(math.min(1e308, G.GAME.dollars * (rtemperancemult()^number) - G.GAME.dollars))
		multante(number)
	end
}

local suitreversetarots = {
	{
		b = 'star',
		n = 'The Flash',
		s = 'Diamonds',
		p = { x = 2, y = 1 }
	},
	{
		b = 'moon',
		n = 'The Eclipse',
		s = 'Clubs',
		p = { x = 1, y = 1 }
	},
	{
		b = 'sun',
		n = 'The Darkness',
		s = 'Hearts',
		p = { x = 0, y = 1 }
	},
	{
		b = 'world',
		n = 'The Void',
		s = 'Spades',
		p = { x = 8, y = 0 }
	}
}

for kk, vv in pairs(suitreversetarots) do
	SMODS.Consumable {
		key = 'reverse_' .. vv.b,
		set = 'Spectral',
		loc_txt = {
			name = vv.n,
			text = {
				'Duplicate {C:attention}all{} of your',
				'{C:' .. string.lower(vv.s) .. '}' .. string.sub(vv.s, 1, string.len(vv.s) - 1) .. '{} card(s)',
				'{s:0.7}Also considers {C:attention,s:0.7}Wilds{}',
				'{s:0.7}and any {C:attention,s:0.7}Joker effects{s:0.7},{}',
				'{s:0.7}bypasses {C:red,s:0.7}debuffs{}'
			}
		},
		set_card_type_badge = torat,
		pos = vv.p,
		cost = 30,
		unlocked = true,
		discovered = true,
		hidden = true,
		soul_rate = 0.002,
		atlas = 'jenrtarots',
		can_use = function(self, card)
			return abletouseconsumables()
		end,
		use = function(self, card, area, copier)
			local cards = {}
			local handcards = {}
			local deckcards = {}
			if next(G.hand.cards) then
				for k, v in pairs(G.hand.cards) do
					if v:is_suit(vv.s, true) then
						cards[#cards + 1] = true
						G.playing_card = (G.playing_card and G.playing_card + 1) or 1
						local copy = copy_card(v, nil, nil, G.playing_card)
						copy:add_to_deck()
						copy:start_materialize()
						table.insert(handcards, copy)
					end
				end
			end
			if next(G.deck.cards) then
				for k, v in pairs(G.deck.cards) do
					if v:is_suit(vv.s, true) then
						cards[#cards + 1] = true
						G.playing_card = (G.playing_card and G.playing_card + 1) or 1
						local copy = copy_card(v, nil, nil, G.playing_card)
						copy:add_to_deck()
						copy:start_materialize()
						table.insert(deckcards, copy)
					end
				end
			end
			if next(handcards) then
				for k, v in pairs(handcards) do
					if v ~= card then
						table.insert(G.playing_cards, v)
						G.hand:emplace(v)
					end
				end
			end
			if next(deckcards) then
				for k, v in pairs(deckcards) do
					if v ~= card then
						table.insert(G.playing_cards, v)
						G.deck:emplace(v)
					end
				end
			end
			if #cards > 0 then playing_card_joker_effects(cards) end
		end
	}
end

SMODS.Consumable {
	key = 'reverse_judgement',
	set = 'Spectral',
	loc_txt = {
		name = 'Cunctation',
		text = {
			'Gives {C:attention}#1# {X:inactive}Buffoon{}',
			'and {C:attention}Standard Tags{}'
		}
	},
	set_card_type_badge = torat,
	config = {extra = {tags = 5}},
	pos = { x = 9, y = 0 },
	cost = 13,
	unlocked = true,
	discovered = true,
	hidden = true,
	soul_rate = 0.002,
	atlas = 'jenrtarots',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.tags}}
    end,
	can_use = function(self, card)
		return abletouseconsumables()
	end,
	use = function(self, card, area, copier)
		for i = 1, card.ability.extra.tags do
			add_tag(Tag('tag_buffoon'))
			add_tag(Tag('tag_standard'))
		end
	end,
	bulk_use = function(self, card, area, copier, number)
		for i = 1, card.ability.extra.tags * number do
			add_tag(Tag('tag_buffoon'))
			add_tag(Tag('tag_standard'))
		end
	end
}

SMODS.Consumable {
	key = 'chance',
	set = 'Spectral',
	loc_txt = {
		name = 'Chance',
		text = {
			'{C:green}Randomises{} all cards in hand',
			'{C:inactive}(Rank, seal, edition, enhancement and suit){}'
		}
	},
	pos = { x = 0, y = 4 },
	cost = 4,
	unlocked = true,
	discovered = true,
	atlas = 'jenacc',
	can_use = function(self, card)
		return abletouseconsumables() and #((G.hand or {}).cards or {}) > 0
	end,
	use = function(self, card, area, copier)
		G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
			play_sound('other1')
			card:juice_up(0.3, 0.5)
			return true
		end }))
		for i=1, #G.hand.cards do
			local percent = 1.15 - (i-0.999)/(#G.hand.cards-0.998)*0.3
			G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.15,func = function() G.hand.cards[i]:flip();play_sound('card1', percent);G.hand.cards[i]:juice_up(0.3, 0.3);return true end }))
		end
		delay(0.2)
		for i=1, #G.hand.cards do
			local percent = 0.85 + (i-0.999)/(#G.hand.cards-0.998)*0.3
			G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.1,func = function()	
				local card = G.hand.cards[i]
				card:set_base(pseudorandom_element(G.P_CARDS))	
				if pseudorandom(pseudoseed('chancetime')) > 1 / (#G.P_CENTER_POOLS['Enhanced']+1) then
					card:set_ability(pseudorandom_element(G.P_CENTER_POOLS['Enhanced'], pseudoseed('spectral_chance')))
				else
					card:set_ability(G.P_CENTERS['c_base'])
				end	
				local edition_rate = 2
				card:set_edition(poll_edition('standard_edition'..G.GAME.round_resets.ante, edition_rate, true))
				local seal_rate = 10
				local seal_poll = pseudorandom(pseudoseed('stdseal'..G.GAME.round_resets.ante))
				if seal_poll > 1 - 0.02*seal_rate then
					local seal_type = pseudorandom(pseudoseed('stdsealtype'..G.GAME.round_resets.ante))
					local seal_list = {}
					for k, _ in pairs(G.P_SEALS) do
						table.insert(seal_list, k)
					end
					seal_type = math.floor(seal_type * #seal_list)
					card:set_seal(seal_list[seal_type])
				else
					card:set_seal()
				end
				card:flip()
				play_sound('other1', percent, 0.6)
				card:juice_up(0.3, 0.3)
				return true 
			end }))
		end
		delay(0.5)
	end
}

SMODS.Consumable {
	key = 'offering',
	set = 'Spectral',
	loc_txt = {
		name = 'Offering',
		text = {
			'{C:green}Randomly {C:red}destroy {C:attention}half{} of your cards,',
			'{C:attention}+#1#{} Joker slot(s)'
		}
	},
	config = {extra = {slots = 1}},
	pos = { x = 1, y = 4 },
	cost = 5,
	unlocked = true,
	discovered = true,
	atlas = 'jenacc',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.slots}}
    end,
	can_use = function(self, card)
		return abletouseconsumables() and (#G.hand.cards + #G.deck.cards > 1)
	end,
	use = function(self, card, area, copier)
		local todestroy = 0
		local value = 0
		local targets = {}
		if #G.hand.cards > 1 then
			todestroy = math.ceil(#G.hand.cards / 2)
			while todestroy > 0 do
				local sel = G.hand.cards[pseudorandom('offering1', 1, #G.hand.cards)]
				if not sel.rhm then
					sel.rhm = true
					G.hand:remove_card(sel)
					table.insert(targets, sel)
					value = value + (sel.sell_cost or 1)
					todestroy = todestroy - 1
				end
			end
		end
		if #G.deck.cards > (#G.hand.cards > 0 and 0 or 1) then
			todestroy = math.ceil(#G.deck.cards / 2)
			if todestroy >= #G.deck.cards then
				for k, v in pairs(G.deck.cards) do
					G.deck:remove_card(sel)
					table.insert(targets, sel)
				end
			else
				while todestroy > 0 do
					local sel = G.deck.cards[pseudorandom('offering2', 1, #G.deck.cards)]
					if not sel.rhm then
						sel.rhm = true
						G.deck:remove_card(sel)
						table.insert(targets, sel)
						value = value + (sel.sell_cost or 1)
						todestroy = todestroy - 1
					end
				end
			end
		end
		if #targets > 0 then
			for k, v in pairs(targets) do
				v.rhm = false
				v:start_dissolve()
			end
		end
		delay(0.5)
		G.E_MANAGER:add_event(Event({func = function()
			if G.jokers then 
				G.jokers:change_size_absolute(card.ability.extra.slots)
			end
		return true end }))
	end
}

SMODS.Consumable {
	key = 'scry',
	set = 'Spectral',
	loc_txt = {
		name = 'Scry',
		text = {
			'Creates up to {C:attention}#1#{}',
			'{C:spectral}Spectral{} card(s)',
			'{C:inactive}(Must have room){}'
		}
	},
	config = {extra = {spectrals = 2}},
	pos = { x = 2, y = 4 },
	cost = 4,
	unlocked = true,
	discovered = true,
	atlas = 'jenacc',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.spectrals}}
    end,
	can_use = function(self, card)
		return abletouseconsumables()
	end,
	use = function(self, card, area, copier)
		for i = 1, math.min(card.ability.extra.spectrals, G.consumeables.config.card_limit - #G.consumeables.cards) do
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
				if G.consumeables.config.card_limit > #G.consumeables.cards then
					play_sound('button', 0.5)
					local card2 = create_card('Spectral', G.consumeables, nil, nil, nil, nil, nil, 'pri')
					card2:add_to_deck()
					G.consumeables:emplace(card2)
					card:juice_up(0.3, 0.5)
				end
				return true
			end }))
		end
		delay(0.6)
	end,
	bulk_use = function(self, card, area, copier, number)
		for i = 1, math.min(card.ability.extra.spectrals * number, G.consumeables.config.card_limit - #G.consumeables.cards) do
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
				if G.consumeables.config.card_limit > #G.consumeables.cards then
					play_sound('button', 0.5)
					local card2 = create_card('Spectral', G.consumeables, nil, nil, nil, nil, nil, 'pri')
					card2:add_to_deck()
					G.consumeables:emplace(card2)
					card:juice_up(0.3, 0.5)
				end
				return true
			end }))
		end
		delay(0.6)
	end
}

SMODS.Consumable {
	key = 'phantom',
	set = 'Spectral',
	loc_txt = {
		name = 'Phantom',
		text = {
			'Create {C:attention}#1#{} {C:green}random{}',
			'{C:dark_edition}Negative {C:attention}Perishable {C:attention}Joker(s){},',
			'set {C:money}sell value{} of {C:attention}all Jokers{} to {C:money}$0{}'
		}
	},
	config = {extra = {phantoms = 2}},
	pos = { x = 3, y = 4 },
	cost = 4,
	unlocked = true,
	discovered = true,
	atlas = 'jenacc',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.phantoms}}
    end,
	can_use = function(self, card)
		return abletouseconsumables()
	end,
	use = function(self, card, area, copier)
		for i = 1, card.ability.extra.phantoms do
			local card = create_card("Joker", G.jokers, nil, nil, nil, nil, nil, 'phantom')
			card:set_edition({negative = true})
			card:set_eternal(false)
			card:set_perishable(true)
			card:add_to_deck()
			G.jokers:emplace(card)
		end
		delay(0.6)
		for i=1, #G.jokers.cards do
			G.jokers.cards[i].base_cost = 0
			G.jokers.cards[i].extra_cost = 0
			G.jokers.cards[i].cost = 0
			G.jokers.cards[i].sell_cost = 0
			G.jokers.cards[i].sell_cost_label = G.jokers.cards[i].facing == 'back' and '?' or G.jokers.cards[i].sell_cost
		end
	end,
	bulk_use = function(self, card, area, copier, number)
		for i = 1, card.ability.extra.phantoms * number do
			local card = create_card("Joker", G.jokers, nil, nil, nil, nil, nil, 'phantom')
			card:set_edition({negative = true})
			card:set_eternal(false)
			card:set_perishable(true)
			card:add_to_deck()
			G.jokers:emplace(card)
		end
		delay(0.6)
		for i=1, #G.jokers.cards do
			G.jokers.cards[i].base_cost = 0
			G.jokers.cards[i].extra_cost = 0
			G.jokers.cards[i].cost = 0
			G.jokers.cards[i].sell_cost = 0
			G.jokers.cards[i].sell_cost_label = G.jokers.cards[i].facing == 'back' and '?' or G.jokers.cards[i].sell_cost
		end
	end
}

SMODS.Consumable {
	key = 'mischief',
	set = 'Spectral',
	loc_txt = {
		name = 'Mischief',
		text = {
			'Create {C:attention}#1#{} random {C:attention}consumables{}',
			'that {C:attention}also act as playing cards{},',
			'and shuffle them into your deck',
			'{C:inactive}(Suit and rank will be random){}'
		}
	},
	config = {extra = {mischief = 5}},
	pos = { x = 4, y = 4 },
	cost = 4,
	unlocked = true,
	discovered = true,
	atlas = 'jenacc',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.mischief}}
    end,
	can_use = function(self, card)
		return abletouseconsumables()
	end,
	use = function(self, card, area, copier)
		local cards = {}
		local objects = {}
		for i = 1, card.ability.extra.mischief do
			cards[i] = true
			local new = create_playing_card(nil, G.play, nil, i ~= 1, {G.C.SECONDARY_SET.Spectral})
			if card.edition and not card.edition.negative then
				new:set_edition(card.edition)
			end
			table.insert(objects, new)
		end
		delay_realtime(0.5)
		for k, v in ipairs(objects) do
			G.E_MANAGER:add_event(Event({delay = 0.2, timer = 'REAL', func = function()
				play_sound('card1')
				v:juice_up(0.3, 0.3)
				v:flip()
				return true
			end }))
		end
		delay_realtime(1)
		for k, v in ipairs(objects) do
			G.E_MANAGER:add_event(Event({delay = 0.2, timer = 'REAL', func = function()
				play_sound('card1', 0.85)
				v:set_ability(G.P_CENTERS[pseudorandom_element(G.P_CENTER_POOLS.Consumeables, pseudoseed('jen_mischief')).key], true, nil)
				v:juice_up(0.3, 0.3)
				v:flip()
				return true
			end }))
		end
		delay_realtime(3)
		for k, v in ipairs(objects) do
			G.E_MANAGER:add_event(Event({delay = 0.2, timer = 'REAL', func = function()
				play_sound('card1')
				v:add_to_deck()
				G.play:remove_card(v)
				G.deck:emplace(v)
				return true
			end }))
		end
	end,
	bulk_use = function(self, card, area, copier, number)
		local cards = {}
		local objects = {}
		for i = 1, card.ability.extra.mischief * number do
			cards[i] = true
			local new = create_playing_card(nil, G.play, nil, i ~= 1, {G.C.SECONDARY_SET.Spectral})
			table.insert(objects, new)
			if card.edition and not card.edition.negative then
				new:set_edition(card.edition)
			end
		end
		delay_realtime(0.5)
		for k, v in ipairs(objects) do
			G.E_MANAGER:add_event(Event({delay = 0.2, timer = (number < 4 and 'REAL' or 'TOTAL'), func = function()
				play_sound('card1')
				v:juice_up(0.3, 0.3)
				v:flip()
				return true
			end }))
		end
		delay_realtime(1)
		for k, v in ipairs(objects) do
			G.E_MANAGER:add_event(Event({delay = 0.2, timer = (number < 4 and 'REAL' or 'TOTAL'), func = function()
				play_sound('card1', 0.85)
				v:set_ability(G.P_CENTERS[pseudorandom_element(G.P_CENTER_POOLS.Consumeables, pseudoseed('jen_mischief')).key], true, nil)
				v:juice_up(0.3, 0.3)
				v:flip()
				return true
			end }))
		end
		delay_realtime(3)
		for k, v in ipairs(objects) do
			G.E_MANAGER:add_event(Event({delay = 0.2, timer = (number < 4 and 'REAL' or 'TOTAL'), func = function()
				play_sound('card1')
				v:add_to_deck()
				G.play:remove_card(v)
				G.deck:emplace(v)
				return true
			end }))
		end
	end
}
local maskcard = function(self, card, badges)
	badges[#badges + 1] = create_badge("Mask", get_type_colour(self or card.config, card), G.C.DARK_EDITION, 1.2)
end

SMODS.Consumable {
	key = 'comedy',
	set = 'Spectral',
	loc_txt = {
		name = '{C:blue}Comedy{}',
		text = {
			'{C:blue}+#1#{} hand(s)'
		}
	},
	set_card_type_badge = maskcard,
	config = {extra = {add = 1}},
	pos = { x = 5, y = 4 },
	cost = 15,
	unlocked = true,
	discovered = true,
	atlas = 'jenacc',
	hidden = true,
	soul_rate = 0.02,
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.add}}
    end,
	can_use = function(self, card)
		return abletouseconsumables()
	end,
	use = function(self, card, area, copier)
		local additive = card.ability.extra.add
        G.GAME.round_resets.hands = G.GAME.round_resets.hands + additive
        ease_hands_played(additive)
	end,
	bulk_use = function(self, card, area, copier, number)
		local additive = card.ability.extra.add * number
        G.GAME.round_resets.hands = G.GAME.round_resets.hands + additive
        ease_hands_played(additive)
	end
}

SMODS.Consumable {
	key = 'tragedy',
	set = 'Spectral',
	loc_txt = {
		name = '{C:red}Tragedy{}',
		text = {
			'{C:red}+#1#{} discard(s)'
		}
	},
	set_card_type_badge = maskcard,
	config = {extra = {add = 1}},
	pos = { x = 6, y = 4 },
	cost = 15,
	unlocked = true,
	discovered = true,
	atlas = 'jenacc',
	hidden = true,
	soul_rate = 0.02,
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.add}}
    end,
	can_use = function(self, card)
		return abletouseconsumables()
	end,
	use = function(self, card, area, copier)
		local additive = card.ability.extra.add
        G.GAME.round_resets.discards = G.GAME.round_resets.discards + additive
        ease_discard(additive)
	end,
	bulk_use = function(self, card, area, copier, number)
		local additive = card.ability.extra.add * number
        G.GAME.round_resets.discards = G.GAME.round_resets.discards + additive
        ease_discard(additive)
	end
}

SMODS.Consumable {
	key = 'whimsy',
	set = 'Spectral',
	loc_txt = {
		name = '{C:attention}Whimsy{}',
		text = {
			'{C:attention}+#1#{} hand size, Joker slot(s) & consumable slot(s)'
		}
	},
	set_card_type_badge = maskcard,
	config = {extra = {add = 1}},
	pos = { x = 7, y = 4 },
	cost = 20,
	unlocked = true,
	discovered = true,
	atlas = 'jenacc',
	hidden = true,
	soul_rate = 0.02,
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.add}}
    end,
	can_use = function(self, card)
		return abletouseconsumables()
	end,
	use = function(self, card, area, copier)
		local additive = card.ability.extra.add
		G.hand:change_size(additive)
		G.jokers:change_size_absolute(additive)
		G.consumeables:change_size_absolute(additive)
	end,
	bulk_use = function(self, card, area, copier, number)
		local additive = card.ability.extra.add * number
		G.hand:change_size(additive)
		G.jokers:change_size_absolute(additive)
		G.consumeables:change_size_absolute(additive)
	end
}

SMODS.Consumable {
	key = 'entropy',
	set = 'Spectral',
	loc_txt = {
		name = '{C:dark_edition}Entropy{}',
		text = {
			'{C:attention}-#1#{} Ante'
		}
	},
	set_card_type_badge = maskcard,
	config = {extra = {add = 1}},
	pos = { x = 8, y = 4 },
	cost = 20,
	unlocked = true,
	discovered = true,
	atlas = 'jenacc',
	hidden = true,
	soul_rate = 0.02,
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.add}}
    end,
	can_use = function(self, card)
		return abletouseconsumables()
	end,
	use = function(self, card, area, copier)
		local additive = card.ability.extra.add
		ease_ante(-additive)
	end,
	bulk_use = function(self, card, area, copier, number)
		local additive = card.ability.extra.add * number
		ease_ante(-additive)
	end
}

SMODS.Consumable {
	key = 'wonder',
	set = 'Spectral',
	loc_txt = {
		name = '{C:tarot}Wonder{}',
		text = {
			'Gives {C:attention}#1# {C:tarot}Charm{},',
			'{X:inactive}Buffoon{}, {C:planet}Meteor{},',
			'{C:attention}Standard{} and {C:spectral}Ethereal {C:attention}Tags{}'
		}
	},
	set_card_type_badge = maskcard,
	config = {extra = {add = 2}},
	pos = { x = 9, y = 4 },
	cost = 12,
	unlocked = true,
	discovered = true,
	hidden = true,
	soul_rate = 0.02,
	atlas = 'jenacc',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.add}}
    end,
	can_use = function(self, card)
		return abletouseconsumables()
	end,
	use = function(self, card, area, copier)
		local additive = card.ability.extra.add
		for i = 1, additive do
			add_tag(Tag('tag_charm'))
			add_tag(Tag('tag_buffoon'))
			add_tag(Tag('tag_meteor'))
			add_tag(Tag('tag_standard'))
			add_tag(Tag('tag_ethereal'))
		end
	end,
	bulk_use = function(self, card, area, copier, number)
		local additive = card.ability.extra.add * number
		for i = 1, additive do
			add_tag(Tag('tag_charm'))
			add_tag(Tag('tag_buffoon'))
			add_tag(Tag('tag_meteor'))
			add_tag(Tag('tag_standard'))
			add_tag(Tag('tag_ethereal'))
		end
	end
}

local sssb = function(self, card, badges)
	badges[#badges + 1] = create_badge('S.S.S.B.', get_type_colour(self or card.config, card), nil, 1.2)
end

local spacedebris = function(self, card, badges)
	badges[#badges + 1] = create_badge('Space Debris', get_type_colour(self or card.config, card), nil, 1.2)
end

local spacecraft = function(self, card, badges)
	badges[#badges + 1] = create_badge('Spacecraft', get_type_colour(self or card.config, card), nil, 1.2)
end

local natsat = function(self, card, badges)
	badges[#badges + 1] = create_badge('Natural Satellite', get_type_colour(self or card.config, card), nil, 1.2)
end

local hoxxesplanet = function(self, card, badges)
	badges[#badges + 1] = create_badge("Karl's Hellhole", get_type_colour(self or card.config, card), nil, 1.2)
end

local hoxxesblurbs = {
	'Rock and Stone!',
	'Like that; Rock and Stone!',
	'Stone and Rock! ...Oh, wait-?',
	'Rock solid!',
	"Rock'n'roll'n'stone!",
	'Rock on!',
	'For Rock and Stone!',
	'Rock and Stone forever!',
	'By the Beard!',
	'Stone.',
	'Yeah, yeah, Rock and Stone...',
	'We fight, for Rock and Stone!',
	'Did I hear a Rock and Stone?',
	'Rock and Stone, brotha!',
	'Leave no dwarf behind!',
	"If y'don't Rock 'n' Stone; you ain't comin' home!",
	'Karl would approve of this!',
	'For Karl!',
	'To Karl!',
	'Skal!',
	"We're rich!"
}

local hoxxes_max = 1000

SMODS.Consumable {
	key = 'hoxxes',
	loc_txt = {
		name = 'Hoxxes',
		text = {
			'{C:attention}Mines{} each {C:attention}playing card{} in hand, {C:attention}downgrading{} its {C:attention}rank{} by {C:attention}1{}',
			'Repeat this by its {C:attention}max number of self-retriggers{} if it has any{}',
			'Apply {C:attention}various bonuses {C:inactive}(chip, mult, dollars){} to {C:attention}most-played hand{} for each hit',
			'If card is a {C:attention}2{} or {C:attention}Stone{}, {C:red}destroy it{} and {C:planet}level up the hand{}',
			'{C:attention}Glass{} cards have a {C:green}#1# in 4 chance{} to {C:red}be destroyed instantly{} with each hit',
			'{C:inactive}(Most played hand : {C:attention}#2#{C:inactive}){}',
			'{C:inactive}(Max limit of ' .. number_format(hoxxes_max) .. ' cards){}'
		}
	},
	set = 'Spectral',
    hidden = true,
	soul_rate = 0.02,
    soul_set = "Planet",
	set_card_type_badge = hoxxesplanet,
	pos = { x = 0, y = 0 },
	cost = 15,
	unlocked = true,
	discovered = true,
	atlas = 'jenhoxxes',
    loc_vars = function(self, info_queue, center)
        return {vars = {G.GAME.probabilities.normal, get_favourite_hand()}}
    end,
	can_use = function(self, card)
		return abletouseconsumables() and (G.STATE == G.STATES.SELECTING_HAND or ((G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.PLANET_PACK or G.STATE == G.STATES.TAROT_PACK) and (card.area or {} ~= G.consumeables)))
	end,
	use = function(self, card, area, copier)
		if #G.hand.cards > 0 then
			local hand = get_favourite_hand()
			local exhausted = {}
			update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(hand, 'poker_hands'),chips = G.GAME.hands[hand].chips, mult = G.GAME.hands[hand].mult, level=G.GAME.hands[hand].level})
			for k, v in ipairs(G.hand.cards) do
				if k <= 300 then
					local iterations = 1
					local extrachips = v.ability.name == 'Stone Card' and 0 or v.base.nominal
					local extramult = 0
					local xm = 1
					local xc = 1
					local em = 1
					local money = 0
					local willbreak = -1
					local predictedrank = v.base.id
					local obj = v.edition or {}
					local levelup = false
					if v.ability.retriggers or v.ability.repetitions then
						iterations = iterations + (v.ability.retriggers or v.ability.repetitions)
					end
					if obj.retriggers or obj.repetitions then
						iterations = iterations + (obj.retriggers or obj.repetitions)
					end
						local obj2 = v.config.center.config
						if obj2.retriggers or obj2.repetitions then
							iterations = iterations + (obj2.retriggers or obj2.repetitions)
						end
						for i = 1, iterations do
							if i ~= 1 then
								extrachips = extrachips + predictedrank
							end
							if obj2.mult and obj2.mult > 0 then
								extramult = extramult + obj2.mult
							end
							if obj2.bonus and obj2.bonus > 0 then
								extrachips = extrachips + obj2.bonus
							end
							if obj2.p_dollars and obj2.p_dollars > 0 then
								money = money + obj2.p_dollars
							end
							if obj2.h_dollars and obj2.h_dollars > 0 then
								money = money + obj2.h_dollars
							end
							if v.ability.perma_bonus and v.ability.perma_bonus > 0 then
								extrachips = extrachips + v.ability.perma_bonus
							end
							if obj2.h_x_mult and obj2.h_x_mult > 1 then
								xm = xm * obj2.h_x_mult
							end
							if obj2.Xmult and obj2.Xmult > 1 then
								xm = xm * obj2.Xmult
							end
							if obj and next(obj) ~= nil and not obj.negative then
								if obj.chips then
									extrachips = extrachips + obj.chips
								end
								if obj.mult then
									extramult = extramult + obj.mult
								end
								if obj.p_dollars then
									money = money + obj.p_dollars
								end
								if obj.x_mult then
									xm = xm * obj.x_mult
								end
								if obj.x_chips then
									xc = xc * obj.x_chips
								end
								if obj.e_mult then
									em = (em <= 1 and obj.e_mult or (em ^ obj.e_mult))
								end
							end
							predictedrank = predictedrank - 1
							if (v.ability.name == 'Glass Card' and chance('mining_glass', 4)) or predictedrank < 2 or v.ability.name == 'Stone Card' then
								willbreak = i
								levelup = true
								break
							end
						end
					G.E_MANAGER:add_event(Event({delay = 1, func = function()
						card:juice_up(0.5, 0.2)
						v:juice_up(1, 1)
						if v:get_id() <= 2 or iterations == willbreak then
							iterations = 0
							play_sound(v.ability.name == 'Glass Card' and 'jen_crystalbreak' or ('jen_metalbreak' .. math.random(2)), 1, 0.4)
							if v.facing == 'front' then v:flip() end
							local suit_prefix = string.sub(v.base.suit, 1, 1)..'_'
							v:set_base(G.P_CARDS[suit_prefix..'2'])
							table.insert(exhausted, v)
						else
							iterations = iterations - 1
							local suit_prefix = string.sub(v.base.suit, 1, 1)..'_'
							local rank_suffix = math.max(v.base.id-1, 2)
							if rank_suffix < 10 then rank_suffix = tostring(rank_suffix)
							elseif rank_suffix == 10 then rank_suffix = 'T'
							elseif rank_suffix == 11 then rank_suffix = 'J'
							elseif rank_suffix == 12 then rank_suffix = 'Q'
							elseif rank_suffix == 13 then rank_suffix = 'K'
							end
							v:set_base(G.P_CARDS[suit_prefix..rank_suffix])
							play_sound(v.ability.name == 'Glass Card' and ('jen_crystalhit' .. math.random(3)) or 'jen_metalhit', 1, 0.4)
						end
					return iterations < 1 end }))
						if levelup then
							level_up_hand(v, hand, nil, 1)
						end
						if extrachips > 0 then
							G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
								play_sound('chips1')
								v:juice_up(0.8, 0.5)
							return true end }))
							update_hand_text({delay = 0}, {chips = '+' .. number_format(extrachips), StatusText = true})
							G.GAME.hands[hand].chips = G.GAME.hands[hand].chips + extrachips
						end
						if extramult > 0 then
							G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
								play_sound('multhit1')
								v:juice_up(0.8, 0.5)
							return true end }))
							update_hand_text({delay = 0}, {mult = '+' .. number_format(extramult), StatusText = true})
							G.GAME.hands[hand].mult = G.GAME.hands[hand].mult + extramult
						end
						if xc > 1 then
							G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
								play_sound('talisman_xchip')
								v:juice_up(0.8, 0.5)
							return true end }))
							update_hand_text({delay = 0}, {chips = 'x' .. tostring(round(xc, 3)), StatusText = true})
							G.GAME.hands[hand].chips = G.GAME.hands[hand].chips * xc
						end
						if xm > 1 then
							G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
								play_sound('multhit2')
								v:juice_up(0.8, 0.5)
							return true end }))
							update_hand_text({delay = 0}, {mult = 'x' .. tostring(round(xm, 3)), StatusText = true})
							G.GAME.hands[hand].mult = G.GAME.hands[hand].mult * xm
						end
						if em > 1 then
							G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
								play_sound('talisman_emult')
								v:juice_up(0.8, 0.5)
							return true end }))
							update_hand_text({delay = 0}, {mult = '^' .. tostring(round(em, 3)), StatusText = true})
							G.GAME.hands[hand].mult = G.GAME.hands[hand].mult ^ em
						end
						if money > 0 then
							ease_dollars(money)
						end
					delay(1)
					update_hand_text({sound = 'button', volume = 0.5, pitch = 1.1, delay = 0.3}, {handname=localize(hand, 'poker_hands'),chips = G.GAME.hands[hand].chips, mult = G.GAME.hands[hand].mult, level=G.GAME.hands[hand].level})
				end
			end
			delay_realtime(2)
			update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
			G.E_MANAGER:add_event(Event({trigger = 'after', func = function()
				for k, v in pairs(exhausted) do
					v:start_dissolve()
				end
			return true end }))
			local rnd = math.random(#hoxxesblurbs)
			if rnd == #hoxxesblurbs then
				G.E_MANAGER:add_event(Event({trigger = 'after', func = function()
					play_sound('jen_wererich')
				return true end }))
			end
			card_eval_status_text(card, 'extra', nil, nil, nil, {message = hoxxesblurbs[rnd], colour = G.C.PURPLE})
		else
			local card2 = create_card('Spectral', G.consumeables, nil, nil, nil, nil, card.config.center.key, 'hoxxesreturn')
			card2:add_to_deck()
			G.consumeables:emplace(card2)
		end
	end
}

SMODS.Consumable {
	key = 'wonder',
	set = 'Spectral',
	loc_txt = {
		name = '{C:tarot}Wonder{}',
		text = {
			'Gives {C:attention}#1# {C:tarot}Charm{},',
			'{X:inactive}Buffoon{}, {C:planet}Meteor{},',
			'{C:attention}Standard{} and {C:spectral}Ethereal {C:attention}Tags{}'
		}
	},
	set_card_type_badge = maskcard,
	config = {extra = {add = 2}},
	pos = { x = 9, y = 4 },
	cost = 12,
	unlocked = true,
	discovered = true,
	hidden = true,
	soul_rate = 0.02,
	atlas = 'jenacc',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.add}}
    end,
	can_use = function(self, card)
		return abletouseconsumables()
	end,
	use = function(self, card, area, copier)
		local additive = card.ability.extra.add
		for i = 1, additive do
			add_tag(Tag('tag_charm'))
			add_tag(Tag('tag_buffoon'))
			add_tag(Tag('tag_meteor'))
			add_tag(Tag('tag_standard'))
			add_tag(Tag('tag_ethereal'))
		end
	end,
	bulk_use = function(self, card, area, copier, number)
		local additive = card.ability.extra.add * number
		for i = 1, additive do
			add_tag(Tag('tag_charm'))
			add_tag(Tag('tag_buffoon'))
			add_tag(Tag('tag_meteor'))
			add_tag(Tag('tag_standard'))
			add_tag(Tag('tag_ethereal'))
		end
	end
}

SMODS.Consumable {
	key = 'comet',
	loc_txt = {
		name = 'Comet',
		text = {
			'Upgrade a {C:green}random{}',
			'poker hand {C:attention}#1#{} time(s)'
		}
	},
	config = {extra = {levels = 2}},
	set = 'Planet',
	set_card_type_badge = sssb,
	pos = { x = 0, y = 2 },
	cost = 3,
	unlocked = true,
	discovered = true,
	atlas = 'jenacc',
    loc_vars = function(self, info_queue, center)
        return {vars = {(((center or {}).ability or {}).extra or {}).levels or 2}}
    end,
	can_use = function(self, card)
		return abletouseconsumables()
	end,
	use = function(self, card, area, copier)
		local hand = get_random_hand()
		update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(hand, 'poker_hands'),chips = G.GAME.hands[hand].chips, mult = G.GAME.hands[hand].mult, level=G.GAME.hands[hand].level})
		level_up_hand(card, hand, nil, math.ceil(card.ability.extra.levels))
		update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
	end,
	bulk_use = function(self,card,area,copier,number)
		local hands = {}
		for i = 1, number do
			local hand = get_random_hand()
			hands[hand] = (hands[hand] or 0) + card.ability.extra.levels
		end
		for k, v in pairs(hands) do
			update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(k, 'poker_hands'),chips = G.GAME.hands[k].chips, mult = G.GAME.hands[k].mult, level=G.GAME.hands[k].level})
			card_eval_status_text(card, 'extra', nil, nil, nil, {message = tostring(v), colour = G.C.BLUE})
			level_up_hand(card, k, nil, math.ceil(v))
			delay(0.6)
		end
		update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
	end
}

SMODS.Consumable {
	key = 'meteor',
	loc_txt = {
		name = 'Meteor',
		text = {
			'Upgrade a {C:green}random{}',
			'poker hand {C:attention}#1#{} time(s),',
			'{C:red,s:1.2}BUT{} downgrade a {C:attention}different{}',
			'{C:green}random{} poker hand {C:red}#2#{} time(s)',
			'{C:inactive}(Level cannot go below 1){}'
		}
	},
	config = {extra = {levels = 3, downgrades = 1}},
	set = 'Planet',
	set_card_type_badge = spacedebris,
	pos = { x = 1, y = 2 },
	cost = 3,
	unlocked = true,
	discovered = true,
	atlas = 'jenacc',
    loc_vars = function(self, info_queue, center)
        return {vars = {(((center or {}).ability or {}).extra or {}).levels or 3, (((center or {}).ability or {}).extra or {}).downgrades or 1}}
    end,
	can_use = function(self, card)
		return abletouseconsumables()
	end,
	use = function(self, card, area, copier)
		local hand = get_random_hand()
		update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(hand, 'poker_hands'),chips = G.GAME.hands[hand].chips, mult = G.GAME.hands[hand].mult, level=G.GAME.hands[hand].level})
		level_up_hand(card, hand, nil, math.ceil(card.ability.extra.levels))
		delay(0.6)
		hand = get_random_hand(hand)
		local downgradefactor = math.ceil(card.ability.extra.downgrades)
		if G.GAME.hands[hand].level - downgradefactor < 1 then
			downgradefactor = math.max(0, G.GAME.hands[hand].level - 1)
		end
		update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(hand, 'poker_hands'),chips = G.GAME.hands[hand].chips, mult = G.GAME.hands[hand].mult, level=G.GAME.hands[hand].level})
		if downgradefactor < 1 then
			card_eval_status_text(card, 'extra', nil, nil, nil, {message = 'Safe!', colour = G.C.PURPLE})
		else
			level_up_hand(card, hand, nil, -downgradefactor)
		end
		update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
	end,
	bulk_use = function(self,card,area,copier,number)
		local hands = {}
		for i = 1, number do
			local hand = get_random_hand()
			hands[hand] = (hands[hand] or 0) + math.ceil(card.ability.extra.levels)
			hand = get_random_hand(hand)
			hands[hand] = (hands[hand] or 0) - math.floor(card.ability.extra.downgrades)
		end
		for k, v in pairs(hands) do
			local downgradefactor = v
			if G.GAME.hands[k].level - downgradefactor < 1 then
				downgradefactor = math.max(0, G.GAME.hands[k].level - 1)
			end
			update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(k, 'poker_hands'),chips = G.GAME.hands[k].chips, mult = G.GAME.hands[k].mult, level=G.GAME.hands[k].level})
			if v == 0 then
				card_eval_status_text(card, 'extra', nil, nil, nil, {message = '0', colour = G.C.PURPLE})
			else
				card_eval_status_text(card, 'extra', nil, nil, nil, {message = tostring(v), colour = (v < 0 and G.C.RED or G.C.BLUE)})
				level_up_hand(card, k, nil, v)
			end
			delay(0.6)
		end
		update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
	end
}

SMODS.Consumable {
	key = 'satellite',
	loc_txt = {
		name = 'Satellite',
		text = {
			'Creates up to {C:attention}#1#{}',
			'random {C:planet}Planet{} card(s)',
			'{C:inactive}(Copies edition of this card if it has one){}',
			'{C:inactive}(Must have room){}'
		}
	},
	config = {extra = {planets = 2}},
	set = 'Planet',
	set_card_type_badge = spacecraft,
	pos = { x = 2, y = 2 },
	cost = 3,
	aurinko = true,
	unlocked = true,
	discovered = true,
	atlas = 'jenacc',
    loc_vars = function(self, info_queue, center)
        return {vars = {(((center or {}).ability or {}).extra or {}).planets or 2}}
    end,
	can_use = function(self, card)
		return abletouseconsumables()
	end,
	use = function(self, card, area, copier)
		local isnegative = (card.edition or {}).negative
		for i = 1, isnegative and card.ability.extra.planets or math.min(card.ability.extra.planets, G.consumeables.config.card_limit - #G.consumeables.cards) do
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
				if G.consumeables.config.card_limit > #G.consumeables.cards then
					play_sound('button', 0.5)
					local card2 = create_card('Planet', G.consumeables, nil, nil, nil, nil, nil, 'pri')
					if card.edition then
						card2:set_edition(card.edition, true)
					end
					card2:add_to_deck()
					G.consumeables:emplace(card2)
					card:juice_up(0.3, 0.5)
				end
				return true
			end }))
		end
		delay(0.6)
	end,
	bulk_use = function(self, card, area, copier, number)
		local isnegative = (card.edition or {}).negative
		for i = 1, isnegative and (card.ability.extra.planets * number) or math.min(card.ability.extra.planets * number, G.consumeables.config.card_limit - #G.consumeables.cards) do
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
				if G.consumeables.config.card_limit > #G.consumeables.cards then
					play_sound('button', 0.5)
					local card2 = create_card('Planet', G.consumeables, nil, nil, nil, nil, nil, 'pri')
					if card.edition then
						card2:set_edition(card.edition, true)
					end
					card2:add_to_deck()
					G.consumeables:emplace(card2)
					card:juice_up(0.3, 0.5)
				end
				return true
			end }))
		end
		delay(0.6)
	end
}

SMODS.Consumable {
	key = 'moon',
	loc_txt = {
		name = 'Moon',
		text = {
			'Creates up to {C:attention}#1#{}',
			'random {C:tarot}Tarot{}/{C:planet}Planet{}/{C:spectral}Spectral{} card(s)',
			'{C:inactive}(Copies edition of this card if it has one){}',
			'{C:inactive}(Must have room){}'
		}
	},
	config = {extra = {extraconsumables = 1}},
	set = 'Planet',
	set_card_type_badge = natsat,
	pos = { x = 3, y = 2 },
	cost = 3,
	aurinko = true,
	unlocked = true,
	discovered = true,
	atlas = 'jenacc',
    loc_vars = function(self, info_queue, center)
        return {vars = {(((center or {}).ability or {}).extra or {}).extraconsumables or 1}}
    end,
	can_use = function(self, card)
		return abletouseconsumables()
	end,
	use = function(self, card, area, copier)
		local isnegative = (card.edition or {}).negative
		for i = 1, isnegative and card.ability.extra.extraconsumables or math.min(card.ability.extra.extraconsumables, G.consumeables.config.card_limit - #G.consumeables.cards) do
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
				if G.consumeables.config.card_limit > #G.consumeables.cards then
					play_sound('button', 0.5)
					local card2 = create_card(pseudorandom_element(random_consumabletypes, pseudoseed("moon_planet_type")), G.consumeables, nil, nil, nil, nil, nil, 'moon_planet')
					if card.edition then
						card2:set_edition(card.edition, true)
					end
					card2:add_to_deck()
					G.consumeables:emplace(card2)
					card:juice_up(0.3, 0.5)
				end
				return true
			end }))
		end
		delay(0.6)
	end,
	bulk_use = function(self, card, area, copier, number)
		local isnegative = (card.edition or {}).negative
		for i = 1, isnegative and (card.ability.extra.extraconsumables * number) or math.min(card.ability.extra.extraconsumables * number, G.consumeables.config.card_limit - #G.consumeables.cards) do
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
				if G.consumeables.config.card_limit > #G.consumeables.cards then
					play_sound('button', 0.5)
					local card2 = create_card(pseudorandom_element(random_consumabletypes, pseudoseed("moon_planet_type")), G.consumeables, nil, nil, nil, nil, nil, 'moon_planet')
					if card.edition then
						card2:set_edition(card.edition, true)
					end
					card2:add_to_deck()
					G.consumeables:emplace(card2)
					card:juice_up(0.3, 0.5)
				end
				return true
			end }))
		end
		delay(0.6)
	end
}

SMODS.Consumable {
	key = 'spacestation',
	loc_txt = {
		name = 'Space Station',
		text = {
			'Upgrade your {C:attention}most played poker hand{}',
			'by {C:attention}#1#{} level(s)',
			'{C:inactive}(#2#){}'
		}
	},
	config = {extra = {levels = 1}},
	set = 'Planet',
	set_card_type_badge = spacecraft,
	pos = { x = 4, y = 2 },
	cost = 3,
	aurinko = true,
	unlocked = true,
	discovered = true,
	atlas = 'jenacc',
    loc_vars = function(self, info_queue, center)
        return {vars = {(((center or {}).ability or {}).extra or {}).levels or 1, get_favourite_hand()}}
    end,
	can_use = function(self, card)
		return abletouseconsumables()
	end,
	use = function(self, card, area, copier)
		local hand = get_favourite_hand()
		update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(hand, 'poker_hands'),chips = G.GAME.hands[hand].chips, mult = G.GAME.hands[hand].mult, level=G.GAME.hands[hand].level})
		level_up_hand(card, hand, nil, math.ceil(card.ability.extra.levels))
		update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
	end,
	bulk_use = function(self, card, area, copier, number)
		local hand = get_favourite_hand()
		update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(hand, 'poker_hands'),chips = G.GAME.hands[hand].chips, mult = G.GAME.hands[hand].mult, level=G.GAME.hands[hand].level})
		level_up_hand(card, hand, nil, math.ceil(card.ability.extra.levels) * number)
		update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
	end
}

SMODS.Consumable {
	key = 'dysnomia',
	loc_txt = {
		name = 'Dysnomia',
		text = {
			'{C:green}Randomly{} shifts the level of',
			'{C:attention}all poker hands{} by',
			'{C:red}#1#{} to {C:attention}#2#{} level(s)',
			'{C:inactive}(Level cannot go below 1){}'
		}
	},
	config = {extra = {down = -1, up = 2}},
	set = 'Planet',
	set_card_type_badge = natsat,
	pos = { x = 5, y = 2 },
	cost = 3,
	aurinko = true,
	unlocked = true,
	discovered = true,
	atlas = 'jenacc',
    loc_vars = function(self, info_queue, center)
        return {vars = {(((center or {}).ability or {}).extra or {}).down or -1, (((center or {}).ability or {}).extra or {}).up or 2}}
    end,
	can_use = function(self, card)
		return abletouseconsumables()
	end,
	use = function(self, card, area, copier)
		for _, hand in ipairs(G.handlist) do
			local shift = pseudorandom('dysnomia', math.floor(card.ability.extra.down), math.ceil(card.ability.extra.up))
			if G.GAME.hands[hand].level + shift < 1 then
				shift = math.max(0, G.GAME.hands[hand].level - 1)
			end
			update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(hand, 'poker_hands'),chips = G.GAME.hands[hand].chips, mult = G.GAME.hands[hand].mult, level=G.GAME.hands[hand].level})
			if shift == 0 then
				card_eval_status_text(card, 'extra', nil, nil, nil, {message = '0', colour = G.C.PURPLE})
			else
				card_eval_status_text(card, 'extra', nil, nil, nil, {message = tostring(shift), colour = (shift < 0 and G.C.RED or G.C.BLUE)})
				level_up_hand(card, hand, nil, shift)
			end
			delay(0.6)
		end
		update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
	end,
	bulk_use = function(self, card, area, copier, number)
		for _, hand in ipairs(G.handlist) do
			local shift = pseudorandom('dysnomia', math.floor(card.ability.extra.down) * number, math.ceil(card.ability.extra.up) * number)
			if G.GAME.hands[hand].level + shift < 1 then
				shift = math.max(0, G.GAME.hands[hand].level - 1)
			end
			update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(hand, 'poker_hands'),chips = G.GAME.hands[hand].chips, mult = G.GAME.hands[hand].mult, level=G.GAME.hands[hand].level})
			if shift == 0 then
				card_eval_status_text(card, 'extra', nil, nil, nil, {message = '0', colour = G.C.PURPLE})
			else
				card_eval_status_text(card, 'extra', nil, nil, nil, {message = tostring(shift), colour = (shift < 0 and G.C.RED or G.C.BLUE)})
				level_up_hand(card, hand, nil, shift)
			end
			delay(0.6)
		end
		update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
	end
}

--EX CONSUMABLES

local exconsumables = {
	'ankh',
	'aura',
	'black_hole',
	'ceres',
	'chariot',
	'cryptid',
	'death',
	'deja_vu',
	'devil',
	'earth',
	'ectoplasm',
	'emperor',
	'empress',
	'eris',
	'familiar',
	'fool',
	'grim',
	'hanged_man',
	'hermit',
	'hex',
	'hierophant',
	'high_priestess',
	'immolate',
	'incantation',
	'judgement',
	'jupiter',
	'justice',
	'lovers',
	'magician',
	'mars',
	'medium',
	'mercury',
	'moon',
	'neptune',
	'ouija',
	'planet_x',
	'pluto',
	'saturn',
	'sigil',
	'soul',
	'star',
	'strength',
	'sun',
	'talisman',
	'temperance',
	'tower',
	'trance',
	'uranus',
	'venus',
	'wheel_of_fortune',
	'world',
	'wraith'
}

local explanets = {
	{
		n = 'Pluto',
		c = 'pluto',
		h = 'High Card',
		y = 9
	},
	{
		n = 'Mercury',
		c = 'mercury',
		h = 'Pair',
		y = 6
	},
	{
		n = 'Uranus',
		c = 'uranus',
		h = 'Two Pair',
		y = 11
	},
	{
		n = 'Venus',
		c = 'venus',
		h = 'Three of a Kind',
		y = 12
	},
	{
		n = 'Saturn',
		c = 'saturn',
		h = 'Straight',
		y = 10
	},
	{
		n = 'Jupiter',
		c = 'jupiter',
		h = 'Flush',
		y = 4
	},
	{
		n = 'Earth',
		c = 'earth',
		h = 'Full House',
		y = 2
	},
	{
		n = 'Mars',
		c = 'mars',
		h = 'Four of a Kind',
		y = 5
	},
	{
		n = 'Neptune',
		c = 'neptune',
		h = 'Straight Flush',
		y = 7
	},
	{
		n = 'Planet X',
		c = 'planet_x',
		h = 'Five of a Kind',
		y = 8
	},
	{
		n = 'Ceres',
		c = 'ceres',
		h = 'Flush House',
		y = 1
	},
	{
		n = 'Eris',
		c = 'eris',
		h = 'Flush Five',
		y = 3,
	}
}

for k, v in pairs(explanets) do
	SMODS.Consumable {
		key = v.c .. '_ex',
		loc_txt = {
			name = v.n .. ' {C:dark_edition}EX{}',
			text = {
				'{C:attention,s:1.5,E:1}' .. v.h .. '{}',
				' ',
				'{C:attention}Triples {C:chips}Chips{}, {C:chips}Level Chips{}, {C:mult}Mult{}, and {C:mult}Level Mult{},',
				'and then {C:attention}doubles{} current {C:planet}level{}'
			}
		},
		set = 'jen_exconsumable',
		pos = { x = 0, y = v.y },
		soul_pos = { x = 1, y = v.y },
		cost = 15,
		aurinko = true,
		unlocked = true,
		discovered = true,
		atlas = 'jenexplanets',
		can_stack = true,
		can_divide = true,
		can_bulk_use = true,
		can_use = function(self, card)
			return abletouseconsumables()
		end,
		use = function(self, card, area, copier)
			local hand = v.h
			update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(hand, 'poker_hands'),chips = number_format(G.GAME.hands[hand].l_chips) .. '/Lv.', mult = number_format(G.GAME.hands[hand].l_mult) .. '/Lv.', level=G.GAME.hands[hand].level})
			G.GAME.hands[hand].l_chips = G.GAME.hands[hand].l_chips * 3
			G.GAME.hands[hand].l_mult = G.GAME.hands[hand].l_mult * 3
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 1, func = function()
				play_sound('jen_boost1', 1, 0.4)
				card:juice_up(0.8, 0.5)
			return true end }))
			update_hand_text({delay = 1}, {chips = 'x3', StatusText = true})
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 1, func = function()
				play_sound('jen_boost2', 1, 0.4)
				card:juice_up(0.8, 0.5)
			return true end }))
			update_hand_text({delay = 1}, {mult = 'x3', StatusText = true})
			update_hand_text({sound = 'button', volume = 0.7, pitch = 1, delay = 1}, {chips = number_format(G.GAME.hands[hand].l_chips) .. '/Lv.', mult = number_format(G.GAME.hands[hand].l_mult) .. '/Lv.'})
			delay(1)
			update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 1}, {chips = G.GAME.hands[hand].chips, mult = G.GAME.hands[hand].mult})
			G.GAME.hands[hand].chips = G.GAME.hands[hand].chips * 3
			G.GAME.hands[hand].mult = G.GAME.hands[hand].mult * 3
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 1, func = function()
				play_sound('jen_boost3', 1, 0.4)
				card:juice_up(0.8, 0.5)
			return true end }))
			update_hand_text({delay = 1}, {chips = 'x3', StatusText = true})
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 1, func = function()
				play_sound('jen_boost4', 1, 0.4)
				card:juice_up(0.8, 0.5)
			return true end }))
			update_hand_text({delay = 1}, {mult = 'x3', StatusText = true})
			update_hand_text({sound = 'button', volume = 0.7, pitch = 1, delay = 1}, {chips = G.GAME.hands[hand].chips, mult = G.GAME.hands[hand].mult})
			level_up_hand(card, hand, false, G.GAME.hands[hand].level)
			update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
		end,
		bulk_use = function(self, card, area, copier, number)
			local hand = v.h
			local factor = (3 ^ number)
			update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(hand, 'poker_hands'),chips = number_format(G.GAME.hands[hand].l_chips) .. '/Lv.', mult = number_format(G.GAME.hands[hand].l_mult) .. '/Lv.', level=G.GAME.hands[hand].level})
			G.GAME.hands[hand].l_chips = G.GAME.hands[hand].l_chips * factor
			G.GAME.hands[hand].l_mult = G.GAME.hands[hand].l_mult * factor
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 1, func = function()
				play_sound('jen_boost1', 1, 0.4)
				card:juice_up(0.8, 0.5)
			return true end }))
			update_hand_text({delay = 0.3}, {chips = 'x' .. number_format(factor), StatusText = true})
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 1, func = function()
				play_sound('jen_boost2', 1, 0.4)
				card:juice_up(0.8, 0.5)
			return true end }))
			update_hand_text({delay = 0.3}, {mult = 'x' .. number_format(factor), StatusText = true})
			update_hand_text({sound = 'button', volume = 0.7, pitch = 1, delay = 1}, {chips = number_format(G.GAME.hands[hand].l_chips) .. '/Lv.', mult = number_format(G.GAME.hands[hand].l_mult) .. '/Lv.'})
			delay(1)
			update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 1}, {chips = G.GAME.hands[hand].chips, mult = G.GAME.hands[hand].mult})
			G.GAME.hands[hand].chips = G.GAME.hands[hand].chips * 3
			G.GAME.hands[hand].mult = G.GAME.hands[hand].mult * 3
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 1, func = function()
				play_sound('jen_boost3', 1, 0.4)
				card:juice_up(0.8, 0.5)
			return true end }))
			update_hand_text({delay = 0.3}, {chips = 'x' .. number_format(factor), StatusText = true})
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 1, func = function()
				play_sound('jen_boost4', 1, 0.4)
				card:juice_up(0.8, 0.5)
			return true end }))
			update_hand_text({delay = 0.3}, {mult = 'x' .. number_format(factor), StatusText = true})
			update_hand_text({sound = 'button', volume = 0.7, pitch = 1, delay = 1}, {chips = G.GAME.hands[hand].chips, mult = G.GAME.hands[hand].mult})
			level_up_hand(card, hand, false, G.GAME.hands[hand].level * (number <= 1 and number or (2 ^ number)) - (number <= 1 and 0 or G.GAME.hands[hand].level))
			update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
		end
	}
end

	SMODS.Consumable {
		key = 'black_hole_ex',
		loc_txt = {
			name = '{C:dark_edition}Sagittarius A*{}',
			text = {
				'{C:attention}Nonuples {C:chips}Chips{}, {C:chips}Level Chips{}, {C:mult}Mult{}, and {C:mult}Level Mult{},',
				'and then {C:attention}quadruples{} current {C:planet}level{} of {C:purple}all poker hands{}'
			}
		},
		set = 'jen_exconsumable',
		pos = { x = 0, y = 0 },
		soul_pos = { x = 1, y = 0 },
		cost = 15,
		aurinko = true,
		unlocked = true,
		discovered = true,
		atlas = 'jenexplanets',
		can_stack = true,
		can_divide = true,
		can_bulk_use = true,
		can_use = function(self, card)
			return abletouseconsumables()
		end,
		use = function(self, card, area, copier)
			update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize('k_all_hands'),chips = '.../Lv.', mult = '.../Lv.', level=''})
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 1, func = function()
				play_sound('jen_boost1', 1, 0.4)
				card:juice_up(0.8, 0.5)
			return true end }))
			update_hand_text({delay = 1}, {chips = 'x9', StatusText = true})
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 1, func = function()
				play_sound('jen_boost2', 1, 0.4)
				card:juice_up(0.8, 0.5)
			return true end }))
			update_hand_text({delay = 1}, {mult = 'x9', StatusText = true})
			update_hand_text({sound = 'button', volume = 0.7, pitch = 1, delay = 1}, {chips = '+/Lv.', mult = '+/Lv.'})
			delay(1)
			update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 1}, {chips = '...', mult = '...'})
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 1, func = function()
				play_sound('jen_boost3', 1, 0.4)
				card:juice_up(0.8, 0.5)
			return true end }))
			update_hand_text({delay = 1}, {chips = 'x9', StatusText = true})
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 1, func = function()
				play_sound('jen_boost4', 1, 0.4)
				card:juice_up(0.8, 0.5)
			return true end }))
			update_hand_text({delay = 1}, {mult = 'x9', StatusText = true})
			update_hand_text({sound = 'button', volume = 0.7, pitch = 1, delay = 1}, {chips = '+', mult = '+'})
			update_hand_text({sound = 'button', volume = 0.7, pitch = 1, delay = 1}, {level = 'x4'})
			for k, v in pairs(G.handlist) do
				local hand = v
				G.GAME.hands[hand].l_chips = G.GAME.hands[hand].l_chips * 9
				G.GAME.hands[hand].l_mult = G.GAME.hands[hand].l_mult * 9
				G.GAME.hands[hand].chips = G.GAME.hands[hand].chips * 9
				G.GAME.hands[hand].mult = G.GAME.hands[hand].mult * 9
				level_up_hand(card, hand, true, G.GAME.hands[hand].level * 3)
			end
			update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
		end,
		bulk_use = function(self, card, area, copier, number)
			local factor = (9 ^ number)
			update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize('k_all_hands'),chips = '.../Lv.', mult = '.../Lv.', level=''})
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 1, func = function()
				play_sound('jen_boost1', 1, 0.4)
				card:juice_up(0.8, 0.5)
			return true end }))
			update_hand_text({delay = 1}, {chips = 'x' .. number_format(factor), StatusText = true})
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 1, func = function()
				play_sound('jen_boost2', 1, 0.4)
				card:juice_up(0.8, 0.5)
			return true end }))
			update_hand_text({delay = 1}, {mult = 'x' .. number_format(factor), StatusText = true})
			update_hand_text({sound = 'button', volume = 0.7, pitch = 1, delay = 1}, {chips = '+/Lv.', mult = '+/Lv.'})
			delay(1)
			update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 1}, {chips = '...', mult = '...'})
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 1, func = function()
				play_sound('jen_boost3', 1, 0.4)
				card:juice_up(0.8, 0.5)
			return true end }))
			update_hand_text({delay = 1}, {chips = 'x' .. number_format(factor), StatusText = true})
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 1, func = function()
				play_sound('jen_boost4', 1, 0.4)
				card:juice_up(0.8, 0.5)
			return true end }))
			update_hand_text({delay = 1}, {mult = 'x' .. number_format(factor), StatusText = true})
			update_hand_text({sound = 'button', volume = 0.7, pitch = 1, delay = 1}, {chips = '+', mult = '+'})
			update_hand_text({sound = 'button', volume = 0.7, pitch = 1, delay = 1}, {level = 'x' .. number_format(4^number)})
			for k, v in pairs(G.handlist) do
				local hand = v
				G.GAME.hands[hand].l_chips = G.GAME.hands[hand].l_chips * factor
				G.GAME.hands[hand].l_mult = G.GAME.hands[hand].l_mult * factor
				G.GAME.hands[hand].chips = G.GAME.hands[hand].chips * factor
				G.GAME.hands[hand].mult = G.GAME.hands[hand].mult * factor
				level_up_hand(card, hand, true, (G.GAME.hands[hand].level * (number <= 1 and 4 or (4^number))) - G.GAME.hands[hand].level)
			end
			update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
		end
	}

SMODS.Consumable {
	key = 'ankh_ex',
	set = 'jen_exconsumable',
	loc_txt = {
		name = 'Ankh {C:dark_edition}EX{}',
		text = {
			'Create {C:attention}#1#{} copies',
			'of a {C:attention}selected Joker{}',
			'{C:inactive}(Chooses randomly if no Joker is chosen){}',
			'{C:inactive}(Does not require room, but may overflow)'
		}
	},
	config = {extra = {copies = 4}},
	pos = { x = 0, y = 0 },
	soul_pos = { x = 1, y = 0 },
	cost = 20,
	unlocked = true,
	discovered = true,
	atlas = 'jenexspectrals',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.copies}}
    end,
	can_use = function(self, card)
		return abletouseconsumables() and #((G.jokers or {}).cards or {}) > 0
	end,
	use = function(self, card, area, copier)
		local joker = G.jokers.highlighted[1]
		if not joker then
			joker = G.jokers.cards[pseudorandom('ankhexrandom', 1, #G.jokers.cards)]
		end
		if joker then
			for i = 1, card.ability.extra.copies do	
				local ankhcard = copy_card(joker)
				ankhcard:start_materialize()
				ankhcard:add_to_deck()
				G.jokers:emplace(ankhcard)
			end
		end
	end,
	bulk_use = function(self, card, area, copier, number)
		local joker = G.jokers.highlighted[1]
		if not joker then
			joker = G.jokers.cards[pseudorandom('ankhexrandom', 1, #G.jokers.cards)]
		end
		if joker then
			for i = 1, card.ability.extra.copies * number do	
				local ankhcard = copy_card(joker)
				ankhcard:start_materialize()
				ankhcard:add_to_deck()
				G.jokers:emplace(ankhcard)
			end
		end
	end
}

SMODS.Consumable {
	key = 'aura_ex',
	set = 'jen_exconsumable',
	loc_txt = {
		name = 'Aura {C:dark_edition}EX{}',
		text = {
			'Apply a random {C:cry_exotic}Exotic Edition{}',
			'to any {C:attention}selected Joker{} and/or to',
			'{C:attention}any number{} of {C:attention}selected playing cards{}',
			'{C:inactive}(Can overwrite editions)'
		}
	},
	pos = { x = 0, y = 1 },
	soul_pos = { x = 1, y = 1 },
	cost = 20,
	unlocked = true,
	discovered = true,
	atlas = 'jenexspectrals',
	can_use = function(self, card)
		return abletouseconsumables() and (#((G.jokers or {}).highlighted or {}) + #((G.hand or {}).highlighted or {})) > 0
	end,
	use = function(self, card, area, copier)
		local joker = G.jokers.highlighted[1]
		if joker then
			joker:set_edition({[exotic_editions[pseudorandom('auraexrandom', 1, #exotic_editions)]] = true})
		end
		if #G.hand.highlighted > 0 then
			for k, v in pairs(G.hand.highlighted) do
				v:set_edition({[exotic_editions[pseudorandom('auraexrandom', 1, #exotic_editions)]] = true})
			end
		end
	end
}

SMODS.Consumable {
	key = 'cryptid_ex',
	set = 'jen_exconsumable',
	loc_txt = {
		name = 'Cryptid {C:dark_edition}EX{}',
		text = {
			'Create {C:attention}#1#{} copies of',
			'{C:attention}any number{} of {C:attention}selected playing cards{}'
		}
	},
	config = {extra = {copies = 19}},
	pos = { x = 0, y = 2 },
	soul_pos = { x = 1, y = 2 },
	cost = 20,
	unlocked = true,
	discovered = true,
	atlas = 'jenexspectrals',
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.copies}}
    end,
	can_use = function(self, card)
		return abletouseconsumables() and (#((G.jokers or {}).highlighted or {}) + #((G.hand or {}).highlighted or {})) > 0
	end,
	use = function(self, card, area, copier)
		if #G.hand.highlighted > 0 then
			for k, v in ipairs(G.hand.highlighted) do
				for i = 1, card.ability.extra.copies do	
					local cryptidcard = copy_card(v)
					cryptidcard:start_materialize()
					cryptidcard:add_to_deck()
					G.hand:emplace(cryptidcard)
					G.playing_card = (G.playing_card and G.playing_card + 1) or 1
					table.insert(G.playing_cards, cryptidcard)
				end
			end
		end
	end,
	bulk_use = function(self, card, area, copier, number)
		if #G.hand.highlighted > 0 then
			for k, v in ipairs(G.hand.highlighted) do
				for i = 1, card.ability.extra.copies * number do	
					local cryptidcard = copy_card(v)
					cryptidcard:start_materialize()
					cryptidcard:add_to_deck()
					G.hand:emplace(cryptidcard)
					G.playing_card = (G.playing_card and G.playing_card + 1) or 1
					table.insert(G.playing_cards, cryptidcard)
				end
			end
		end
	end
}

local exsealcards = {
	{
		n = 'Deja Vu',
		c = 'deja_vu',
		s = 'Red',
		y = 3
	},
	{
		n = 'Medium',
		c = 'medium',
		s = 'Purple',
		y = 10
	},
	{
		n = 'Talisman',
		c = 'talisman',
		s = 'Gold',
		y = 13
	},
	{
		n = 'Trance',
		c = 'trance',
		s = 'Blue',
		y = 14
	}
}

for k, v in pairs(exsealcards) do
	SMODS.Consumable {
		key = v.c .. '_ex',
		set = 'jen_exconsumable',
		loc_txt = {
			name = v.n .. ' {C:dark_edition}EX{}',
			text = {
				'Apply a {C:attention}' .. v.s .. ' Seal{} to',
				'{C:attention}all playing cards{} you currently have'
			}
		},
		pos = { x = 0, y = v.y },
		soul_pos = { x = 1, y = v.y },
		cost = 20,
		unlocked = true,
		discovered = true,
		atlas = 'jenexspectrals',
		can_use = function(self, card)
			return abletouseconsumables()
		end,
		use = function(self, card, area, copier)
			if G.hand and G.hand.cards then
				for _, card in pairs(G.hand.cards) do
					card:set_seal(v.s, k > 50, k > 50)
				end
			end
			if G.deck and G.deck.cards then
				for _, card in pairs(G.deck.cards) do
					card:set_seal(v.s, true, true)
				end
			end
		end
	}
end

SMODS.Consumable {
	key = 'ectoplasm_ex',
	set = 'jen_exconsumable',
	loc_txt = {
		name = 'Ectoplasm {C:dark_edition}EX{}',
		text = {
			'Apply {C:dark_edition}Negative{} to {C:attention}every Joker{}',
			'{C:inactive}(Overwrites any existing edition, except for Exotic+ editions){}'
		}
	},
	pos = { x = 0, y = 4 },
	soul_pos = { x = 1, y = 4 },
	cost = 100,
	unlocked = true,
	discovered = true,
	atlas = 'jenexspectrals',
	can_use = function(self, card)
		return abletouseconsumables() and #((G.jokers or {}).cards or {}) > 0
	end,
	use = function(self, card, area, copier)
		for k, v in pairs(G.jokers.cards) do
			if not v:is_exotic_edition() then
				v:set_edition({negative = true}, k > 200, k > 200)
			end
		end
	end
}

SMODS.Consumable {
	key = 'familiar_ex',
	set = 'jen_exconsumable',
	loc_txt = {
		name = 'Familiar {C:dark_edition}EX{}',
		text = {
			'Add a {C:attention}full set{} of {C:jen_RGB,E:1}Moire {C:attention}Kings{},',
			'{C:cry_exotic,E:1}Blood {C:attention}Queens{} and {C:cry_exotic,E:1}Bloodfoil {C:attention}Jacks{}',
			'to your deck'
		}
	},
	pos = { x = 0, y = 5 },
	soul_pos = { x = 1, y = 5 },
	cost = 100,
	unlocked = true,
	discovered = true,
	atlas = 'jenexspectrals',
	can_use = function(self, card)
		return abletouseconsumables()
	end,
	use = function(self, card, area, copier)
		createcardset('_K', nil, 'jen_moire', 1)
		createcardset('_Q', nil, 'jen_blood', 1)
		createcardset('_J', nil, 'jen_bloodfoil', 1)
	end,
	bulk_use = function(self, card, area, copier, number)
		createcardset('_K', nil, 'jen_moire', number)
		createcardset('_Q', nil, 'jen_blood', number)
		createcardset('_J', nil, 'jen_bloodfoil', number)
	end
}

SMODS.Consumable {
	key = 'grim_ex',
	set = 'jen_exconsumable',
	loc_txt = {
		name = 'Grim {C:dark_edition}EX{}',
		text = {
			'Add two {C:attention}full sets{} of',
			'{C:jen_RGB,E:1}Moire {C:attention}Aces{} to your deck'
		}
	},
	pos = { x = 0, y = 6 },
	soul_pos = { x = 1, y = 6 },
	cost = 80,
	unlocked = true,
	discovered = true,
	atlas = 'jenexspectrals',
	can_use = function(self, card)
		return abletouseconsumables()
	end,
	use = function(self, card, area, copier)
		createcardset('_A', nil, 'jen_moire', 2)
	end,
	bulk_use = function(self, card, area, copier, number)
		createcardset('_A', nil, 'jen_moire', 2 * number)
	end
}

SMODS.Consumable {
	key = 'hex_ex',
	set = 'jen_exconsumable',
	loc_txt = {
		name = 'Hex {C:dark_edition}EX{}',
		text = {
			'Apply a random {C:cry_exotic,E:1}Exotic Edition{} to',
			'a {C:green}random selection{} of {C:attention}half{}',
			'of your {C:attention}Jokers{} that {C:attention}do not already have an {C:cry_exotic,E:1}Exotic Edition{}'
		}
	},
	pos = { x = 0, y = 7 },
	soul_pos = { x = 1, y = 7 },
	cost = 150,
	unlocked = true,
	discovered = true,
	atlas = 'jenexspectrals',
	can_use = function(self, card)
		return abletouseconsumables()
	end,
	use = function(self, card, area, copier)
		local possible_selections = {}
		for k, v in pairs(G.jokers.cards) do
			if not v:is_exotic_edition() then
				table.insert(possible_selections, v)
			end
		end
		if #possible_selections > 0 then
			local selections = {}
			local toselect = math.ceil(#possible_selections / 2)
			local tries = 1e4
			local choice
			while toselect > 0 and tries > 0 do
				choice = possible_selections[pseudorandom('hex_ex_selection', 1, #possible_selections)]
				if not choice.selectedbyhexex then
					choice.selectedbyhexex = true
					table.insert(selections, choice)
					toselect = toselect - 1
				end
				tries = tries - 1
			end
			if #selections > 0 then
				for k, v in pairs(selections) do
					v:set_edition({[exotic_editions[pseudorandom('hexexrandom', 1, #exotic_editions)]] = true})
				end
			else
				card_status_text(card, 'No targets!', nil, 0.05*card.T.h, G.C.RED, nil, 0.6, nil, nil, 'bm', 'cancel')
			end
		else
			card_status_text(card, 'No targets!', nil, 0.05*card.T.h, G.C.RED, nil, 0.6, nil, nil, 'bm', 'cancel')
		end
	end
}

local ccr = create_card

function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
	local card = ccr(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
	for k, v in pairs(exconsumables) do
		if card.config.center.key == ('c_' .. v) and G.P_CENTERS['c_jen_' .. v .. '_ex'] and chance('ex_replacement', 75, true) then
			G.E_MANAGER:add_event(Event({trigger = 'after', func = function()
				if card and not (card.added_to_deck or card.no_ex) then
					card:set_ability(G.P_CENTERS['c_jen_' .. v .. '_ex'])
					card:set_cost()
					play_sound('jen_excard', 1, 0.4)
					card:juice_up(1.5, 1.5)
				end
				return true
			end }))
			break
		end
	end
	return card
end

--OVERRIDES AND OTHER FUNCTIONS
G.FUNCS.can_skip_booster = function(e)
	e.config.colour = G.C.GREY
	e.config.button = 'skip_booster'
end

function G.FUNCS.text_super_juice(e, _amount, unlimited)
	if e and e.config and e.config.object and next(e.config.object) then
		e.config.object:set_quiver(unlimited and (0.002*_amount) or math.min(1, 0.002*_amount))
		e.config.object:pulse(unlimited and (0.3 + 0.003*_amount) or math.min(10, 0.3 + 0.003*_amount))
		e.config.object:update_text()
		e.config.object:align_letters()
		e:update_object()
	end
end

function G.FUNCS.tsj_specific(e, quiver, pulse)
	if e and e.config and e.config.object and next(e.config.object) then
		e.config.object:set_quiver(quiver)
		e.config.object:pulse(pulse)
		e.config.object:update_text()
		e.config.object:align_letters()
		e:update_object()
	end
end

G.FUNCS.hand_mult_UI_set = function(e)
	local new_mult_text = number_format(G.GAME.current_round.current_hand.mult)
	if new_mult_text ~= G.GAME.current_round.current_hand.mult_text then
		G.GAME.current_round.current_hand.mult_text = new_mult_text
		e.config.object.scale = scale_number(G.GAME.current_round.current_hand.mult, 0.9, 1000)
		e.config.object:update_text()
		local comparison = G.GAME.current_round.current_hand.mult
		if type(comparison) == 'number' then
			comparison = Big:create(comparison)
		elseif type(comparison) == 'string' then
			comparison = Big:create(1)
		end
		if not G.TAROT_INTERRUPT_PULSE then
			if comparison > Big:create(1e308):arrow(3, 3) then
				G.FUNCS.tsj_specific(e, 2, 20)
			elseif comparison > Big:create(1e308) ^ Big:create(1e308) then
				G.FUNCS.tsj_specific(e, 1.35, 9)
			elseif comparison > Big:create(1e308) ^ 2 then
				G.FUNCS.tsj_specific(e, 1, 5)
			elseif comparison > Big:create(1e308) then
				G.FUNCS.tsj_specific(e, 0.75, 3)
			else
				G.FUNCS.text_super_juice(e, math.max(0,math.floor(math.log10((type(G.GAME.current_round.current_hand.mult) == 'number' or type(G.GAME.current_round.current_hand.mult) == 'table') and G.GAME.current_round.current_hand.mult or 1))))
			end
		end
	end
end

G.FUNCS.hand_chip_UI_set = function(e)
	local new_chip_text = number_format(G.GAME.current_round.current_hand.chips)
	if new_chip_text ~= G.GAME.current_round.current_hand.chip_text then
		G.GAME.current_round.current_hand.chip_text = new_chip_text
		e.config.object.scale = scale_number(G.GAME.current_round.current_hand.chips, 0.9, 1000)
		e.config.object:update_text()
		local comparison = G.GAME.current_round.current_hand.chips
		if type(comparison) == 'number' then
			comparison = Big:create(comparison)
		elseif type(comparison) == 'string' then
			comparison = Big:create(1)
		end
		if not G.TAROT_INTERRUPT_PULSE then
			if comparison > Big:create(1e308):arrow(3, 3) then
				G.FUNCS.tsj_specific(e, 2, 20)
			elseif comparison > Big:create(1e308) ^ Big:create(1e308) then
				G.FUNCS.tsj_specific(e, 1.35, 9)
			elseif comparison > Big:create(1e308) ^ 2 then
				G.FUNCS.tsj_specific(e, 1, 5)
			elseif comparison > Big:create(1e308) then
				G.FUNCS.tsj_specific(e, 0.75, 3)
			else
				G.FUNCS.text_super_juice(e, math.max(0,math.floor(math.log10((type(G.GAME.current_round.current_hand.chips) == 'number' or type(G.GAME.current_round.current_hand.chips) == 'table') and G.GAME.current_round.current_hand.chips or 1))))
			end
		end
    end
end

G.FUNCS.hand_chip_total_UI_set = function(e)
	if bn(G.GAME.current_round.current_hand.chip_total) < bn(1) then
		G.GAME.current_round.current_hand.chip_total_text = ''
	else
		local new_chip_total_text = number_format(G.GAME.current_round.current_hand.chip_total)
		if new_chip_total_text ~= G.GAME.current_round.current_hand.chip_total_text then 
			e.config.object.scale = scale_number(G.GAME.current_round.current_hand.chip_total, 0.95, 100000000)
			
			G.GAME.current_round.current_hand.chip_total_text = new_chip_total_text
			if not G.ARGS.hand_chip_total_UI_set or bn(G.ARGS.hand_chip_total_UI_set) < bn(G.GAME.current_round.current_hand.chip_total) then
				local comparison = G.GAME.current_round.current_hand.chip_total
				if type(comparison) == 'number' then
					comparison = Big:create(comparison)
				elseif type(comparison) == 'string' then
					comparison = Big:create(1)
				end
				if comparison > Big:create(1e308):arrow(3, 3) then
					G.FUNCS.tsj_specific(e, 2, 20)
				elseif comparison > Big:create(1e308) ^ Big:create(1e308) then
					G.FUNCS.tsj_specific(e, 1.35, 9)
				elseif comparison > Big:create(1e308) ^ 2 then
					G.FUNCS.tsj_specific(e, 1, 5)
				elseif comparison > Big:create(1e308) then
					G.FUNCS.tsj_specific(e, 0.75, 3)
				else
					G.FUNCS.text_super_juice(e, math.max(0,math.floor(math.log10((type(G.GAME.current_round.current_hand.chip_total) == 'number' or type(G.GAME.current_round.current_hand.chip_total) == 'table') and G.GAME.current_round.current_hand.chip_total or 1))))
				end
			end
			G.ARGS.hand_chip_total_UI_set = G.GAME.current_round.current_hand.chip_total
		end
	end
end

local add_to_deckref = Card.add_to_deck
function Card.add_to_deck(self, from_debuff)
    if not self.added_to_deck then
		if G.consumeables and self.config and self.config.center and self.config.center.abilitycard and type(self.config.center.abilitycard) == 'string' and #SMODS.find_card(self.config.center.abilitycard) <= 0 then
			local traysize = G.consumeables.config.card_limit + 1
			G.consumeables.config.card_limit = #G.consumeables.cards + 1
			local abi = create_card('Joker Ability', G.consumeables, nil, nil, nil, nil, self.config.center.abilitycard, nil)
			abi:add_to_deck()
			G.consumeables:emplace(abi)
			abi.ability.eternal = true
			G.consumeables.config.card_limit = traysize
		end
		if ((self.ability or {}).name or '') == 'Godsmarble' then
			ease_ante(1)
		end
        if G.jokers and #G.jokers.cards > 0 then
            for i = 1, #G.jokers.cards do
                G.jokers.cards[i]:calculate_joker({jen_adding_card = true, card = self})
            end
        end
    end
    add_to_deckref(self, from_debuff)
end

local rfd = Card.remove_from_deck
function Card.remove_from_deck(self, from_debuff)
	if G.jokers and G.consumeables then
		if self.added_to_deck and self.config and self.config.center and self.config.center.abilitycard and type(self.config.center.abilitycard) == 'string' then
			if #SMODS.find_card(self.config.center.key) <= 0 then
				G.consumeables.config.card_limit = G.consumeables.config.card_limit - 1
				for k, v in pairs(SMODS.find_card(self.config.center.abilitycard)) do
					v.ability.eternal = nil
					v:start_dissolve()
				end
			end
		end
	end
	rfd(self, from_debuff)
end

local ten = to_big(10)
local gbar = get_blind_amount
local defaultblindsize = to_big(100)
function get_blind_amount(ante)
	local cfg = Jen.config
	local amnt = gbar(ante)
	local overante = math.max(0, ante - Jen.config.ante_threshold)
	if not amnt then amnt = defaultblindsize end
	if type(amnt) ~= 'table' then amnt = to_big(amnt) end
	if overante > 0 then
		local scalar = Jen.config.blind_scalar[math.min(overante, #Jen.config.blind_scalar)] or 1
		amnt = amnt * scalar
		if overante >= Jen.config.ante_pow10_4 then
			amnt = ten:arrow(4, ten)^amnt
		elseif overante >= Jen.config.ante_pow10_3 then
			amnt = ten:arrow(3, ten)^amnt
		elseif overante >= Jen.config.ante_pow10_2 then
			amnt = ten^ten^amnt
		elseif overante >= Jen.config.ante_pow10 then
			amnt = ten^amnt
		end
		if overante >= Jen.config.ante_exponentiate then
			amnt = amnt ^ amnt
		end
		if overante >= Jen.config.ante_tetrate then
			amnt = amnt:arrow(2, 2)
		end
		if overante >= Jen.config.ante_pentate then
			amnt = amnt:arrow(3, 2)
		end
		if overante >= Jen.config.ante_polytate then
			local arrows = 4 + math.floor((overante - Jen.config.ante_polytate + 1) / Jen.config.polytate_factor)
			local operand = 2 + math.max(0, arrows - 4 - Jen.config.polytate_factor)
			amnt = amnt:arrow(math.min(1e3, arrows), operand)
		end
	end
	return amnt
end

local athr=CardArea.add_to_highlighted
function CardArea:add_to_highlighted(card, silent)
	if self.config.type ~= 'shop' and self.config.type ~= 'joker' and self.config.type ~= 'consumeable' then
		local surreals = 0
		for k, v in ipairs(self.highlighted) do
			if v.ability.name == 'm_jen_surreal' then surreals = surreals + 1 end
		end
		if #self.highlighted < surreals + self.config.highlighted_limit or card.ability.name == 'm_jen_surreal' then
			self.highlighted[#self.highlighted+1] = card
			card:highlight(true)
			if not silent then play_sound('cardSlide1') end
			self:parse_highlighted()
			return
		end
	end
	athr(self,card,silent)
end

--derived from Cryptid
local cj = Card.calculate_joker --CJ? Ooohhhh, my DOG!!
function Card:calculate_joker(context)
    local ret = cj(self, context)
    if ret and not context.megatrigger and not context.megatrigger_check and not context.retrigger_joker and not context.retrigger_joker_check then
        if type(ret) ~= 'table' then ret = {joker_megarepetitions = {0}} end
        ret.joker_megarepetitions = {0}
        for i = 1, #G.jokers.cards do
            local check = G.jokers.cards[i]:calculate_joker{megatrigger_check = true, other_card = self}
            if type(check) == 'table' then 
                ret.joker_megarepetitions[i] = check and check.megarepetitions and check or 0
            else
                ret.joker_megarepetitions[i] = 0
            end
        end
    end
    return ret
end
