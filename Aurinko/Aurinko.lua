--- STEAMODDED HEADER

--- MOD_NAME: Aurinko
--- MOD_ID: aurinko
--- MOD_AUTHOR: [jenwalter666]
--- MOD_DESCRIPTION: Lets planets naturally appear with editions, applies editions to hands when leveling
--- PRIORITY: 98999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
--- BADGE_COLOR: 009cff
--- PREFIX: aurinko
--- VERSION: 0.4.4
--- LOADER_VERSION_GEQ: 1.0.0

--[[

+++ MOD SUPPORT SKELETON : ALWAYS INCLUDE THIS IN YOUR MOD'S INITIALISATION SOMEWHERE +++

if not AurinkoAddons then
	AurinkoAddons = {}
end

then do AurinkoAddons.<edition key> = function(card, hand, instant, amount) <code> end

When level up caused by card, if function exists in AurinkoAddons with matching key, will execute it passing same arguments in level_up_hand through it

You can also make it a table if you want functions that execute before or after native edition effects:

AurinkoAddons.<edition key> = {before = function(card, hand, instant, amount) <code> end, after = function(card, hand, instant, amount) <code> end}

Your edition's key is usually <mod prefix>_<edition's definition key>


-- WHITELIST

if not AurinkoWhitelist then
	AurinkoWhitelist = {}
end

You can use the whitelist to add cards you want to be affected by Aurinko's edition-applying system
]]

if not AurinkoAddons then
	AurinkoAddons = {}
end

if not AurinkoWhitelist then
	AurinkoWhitelist = {}
end

AurinkoWhitelist.c_black_hole = true

local function round( num, idp )

	local mult = 10 ^ ( idp or 0 )
	return math.floor( num * mult + 0.5 ) / mult

end

local HoldDelay = 1.3

local function get_s_chips(hand)
	if SMODS.Mods['Talisman'] and type(G.GAME.hands[hand].s_chips) ~= 'table' then
		G.GAME.hands[hand].s_chips = to_big(G.GAME.hands[hand].s_chips or 1)
	end
	return G.GAME.hands[hand].s_chips
end

local function get_s_mult(hand)
	if SMODS.Mods['Talisman'] and type(G.GAME.hands[hand].s_mult) ~= 'table' then
		G.GAME.hands[hand].s_mult = to_big(G.GAME.hands[hand].s_mult or 1)
	end
	return G.GAME.hands[hand].s_mult
end

local function repeated_hyper(arrows, operand, repetitions)
	local amnt = to_big(operand)
	for i = 1, repetitions do
		if arrows == 1 then
			amnt = amnt ^ operand
		else
			amnt = amnt:arrow(math.min(1e3, arrows), operand)
		end
	end
	return amnt
end

local luhr = level_up_hand
function level_up_hand(card, hand, instant, amount)
	local talisman = SMODS.Mods['Talisman']
	amount = amount or 1
	luhr(card, hand, instant, amount)
		if card and card.ability and amount ~= 0 then
			if card.edition then
				local factor = 0
				local op = ''
				if card.edition.holo then
					factor = G.P_CENTERS.e_holo.config.extra * amount
					G.GAME.hands[hand].s_mult = math.max(get_s_mult(hand) + factor, 1)
					G.GAME.hands[hand].mult = math.max(G.GAME.hands[hand].mult + factor, 1)
					if not instant then
						G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
							play_sound('multhit1')
							card:juice_up(0.8, 0.5)
						return true end }))
						update_hand_text({delay = HoldDelay}, {mult = G.GAME.hands[hand].mult, StatusText = true})
					end
				elseif card.edition.foil then
					factor = G.P_CENTERS.e_foil.config.extra * amount
					G.GAME.hands[hand].s_chips = math.max(get_s_chips(hand) + factor, 0)
					G.GAME.hands[hand].chips = math.max(G.GAME.hands[hand].chips + factor, 0)
					if not instant then
						G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
							play_sound('chips1')
							card:juice_up(0.8, 0.5)
						return true end }))
						update_hand_text({delay = HoldDelay}, {chips = G.GAME.hands[hand].chips, StatusText = true})
					end
				elseif card.edition.polychrome then
					factor = (talisman and to_big(G.P_CENTERS.e_polychrome.config.extra) or G.P_CENTERS.e_polychrome.config.extra) ^ math.abs(amount)
					if amount > 0 then
						op = 'x'
						G.GAME.hands[hand].s_mult = math.floor(math.max(get_s_mult(hand) * factor, 1))
						G.GAME.hands[hand].mult = math.floor(math.max(G.GAME.hands[hand].mult * factor, 1))
					else
						op = '/'
						G.GAME.hands[hand].s_mult = math.floor(math.max(get_s_mult(hand) / factor, 1))
						G.GAME.hands[hand].mult = math.floor(math.max(G.GAME.hands[hand].mult / factor, 1))
					end
					if not instant then
						G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
							play_sound('multhit2')
							card:juice_up(0.8, 0.5)
						return true end }))
						update_hand_text({delay = 0}, {mult = op .. number_format(factor), StatusText = true})
						update_hand_text({delay = HoldDelay}, {mult = G.GAME.hands[hand].mult})
					end
				elseif not card.edition.negative then
					local obj = card.edition
					if type(AurinkoAddons[card.edition.type]) == 'table' and type(AurinkoAddons[card.edition.type].before) == 'function' then
						AurinkoAddons[card.edition.type].before(card, hand, instant, amount)
					elseif type(AurinkoAddons[card.edition.type]) == 'function' then
						AurinkoAddons[card.edition.type](card, hand, instant, amount)
					end
					if obj.chips then
						factor = obj.chips * amount
						G.GAME.hands[hand].s_chips = math.floor(math.max(get_s_chips(hand) + factor, 1))
						G.GAME.hands[hand].chips = math.floor(math.max(G.GAME.hands[hand].chips + factor, 1))
						if not instant then
							G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
								play_sound('chips1')
								card:juice_up(0.8, 0.5)
							return true end }))
							update_hand_text({delay = HoldDelay}, {chips = G.GAME.hands[hand].chips, StatusText = true})
						end
					end
					if obj.mult then
						factor = obj.mult * amount
						G.GAME.hands[hand].s_mult = math.floor(math.max(get_s_mult(hand) + factor, 1))
						G.GAME.hands[hand].mult = math.floor(math.max(G.GAME.hands[hand].mult + factor, 1))
						if not instant then
							G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
								play_sound('multhit1')
								card:juice_up(0.8, 0.5)
							return true end }))
							update_hand_text({delay = HoldDelay}, {mult = G.GAME.hands[hand].mult, StatusText = true})
						end
					end
					if talisman then
						if obj.x_chips then
							factor = to_big(obj.x_chips) ^ math.abs(amount)
							if amount > 0 then
								op = 'x'
								G.GAME.hands[hand].s_chips = math.floor(math.max(get_s_chips(hand) * factor, 1))
								G.GAME.hands[hand].chips = math.floor(math.max(G.GAME.hands[hand].chips * factor, 1))
							else
								op = '/'
								G.GAME.hands[hand].s_chips = math.floor(math.max(get_s_chips(hand) / factor, 1))
								G.GAME.hands[hand].chips = math.floor(math.max(G.GAME.hands[hand].chips / factor, 1))
							end
							if not instant then
								G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
									play_sound('talisman_xchip')
									card:juice_up(0.8, 0.5)
								return true end }))
								update_hand_text({delay = 0}, {chips = op .. number_format(factor), StatusText = true})
								update_hand_text({delay = HoldDelay}, {chips = G.GAME.hands[hand].chips})
							end
						end
						if obj.e_chips then
							factor = math.abs(amount) == 1 and obj.e_chips or repeated_hyper(1, to_big(obj.e_chips), math.abs(amount))
							if amount > 0 then
								op = '^'
								G.GAME.hands[hand].s_chips = math.floor(math.max(get_s_chips(hand) ^ factor, 1))
								G.GAME.hands[hand].chips = math.floor(math.max(G.GAME.hands[hand].chips ^ factor, 1))
							else
								op = '^1/'
								G.GAME.hands[hand].s_chips = math.floor(math.max(get_s_chips(hand) ^ (1 / factor), 1))
								G.GAME.hands[hand].chips = math.floor(math.max(G.GAME.hands[hand].chips ^ (1 / factor), 1))
							end
							if not instant then
								G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
									play_sound('talisman_echip')
									card:juice_up(0.8, 0.5)
								return true end }))
								update_hand_text({delay = 0}, {chips = op .. number_format(factor), StatusText = true})
								update_hand_text({delay = HoldDelay}, {chips = G.GAME.hands[hand].chips})
							end
						end
						if obj.ee_chips then
							factor = math.abs(amount) == 1 and obj.ee_chips or repeated_hyper(2, to_big(obj.ee_chips), math.abs(amount))
							if amount > 0 then
								op = '^^'
								G.GAME.hands[hand].s_chips = math.floor(math.max(get_s_chips(hand):arrow(2, factor), 1))
								G.GAME.hands[hand].chips = math.floor(math.max(G.GAME.hands[hand].chips:arrow(2, factor), 1))
							else
								op = '^^1/'
								G.GAME.hands[hand].s_chips = math.floor(math.max(get_s_chips(hand):arrow(2, to_big(1) / factor), 1))
								G.GAME.hands[hand].chips = math.floor(math.max(G.GAME.hands[hand].chips:arrow(2, to_big(1) / factor), 1))
							end
							if not instant then
								G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
									play_sound('talisman_eechip')
									card:juice_up(0.8, 0.5)
								return true end }))
								update_hand_text({delay = 0}, {chips = op .. number_format(factor), StatusText = true})
								update_hand_text({delay = HoldDelay}, {chips = G.GAME.hands[hand].chips})
							end
						end
						if obj.eee_chips then
							factor = math.abs(amount) == 1 and obj.eee_chips or repeated_hyper(3, to_big(obj.eee_chips), math.abs(amount))
							if amount > 0 then
								op = '^^^'
								G.GAME.hands[hand].s_chips = math.floor(math.max(get_s_chips(hand):arrow(3, factor), 1))
								G.GAME.hands[hand].chips = math.floor(math.max(G.GAME.hands[hand].chips:arrow(3, factor), 1))
							else
								op = '^^^1/'
								G.GAME.hands[hand].s_chips = math.floor(math.max(get_s_chips(hand):arrow(3, to_big(1) / factor), 1))
								G.GAME.hands[hand].chips = math.floor(math.max(G.GAME.hands[hand].chips:arrow(3, to_big(1) / factor), 1))
							end
							if not instant then
								G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
									play_sound('talisman_eeechip')
									card:juice_up(0.8, 0.5)
								return true end }))
								update_hand_text({delay = 0}, {chips = op .. number_format(factor), StatusText = true})
								update_hand_text({delay = HoldDelay}, {chips = G.GAME.hands[hand].chips})
							end
						end
						if obj.hyper_chips and type(obj.hyper_chips) == 'table' then
							factor = math.abs(amount) == 1 and {obj.hyper_chips[1], to_big(obj.hyper_chips[2])} or {obj.hyper_chips[1], repeated_hyper(obj.hyper_chips[1], to_big(obj.hyper_chips[2]), math.abs(amount))}
							if amount > 0 then
								op = obj.hyper_chips[1] > 5 and ('{' .. obj.hyper_chips[1] .. '}') or string.rep('^', obj.hyper_chips[1])
								G.GAME.hands[hand].s_chips = math.floor(math.max(get_s_chips(hand):arrow(factor[1], factor[2]), 1))
								G.GAME.hands[hand].chips = math.floor(math.max(G.GAME.hands[hand].chips:arrow(factor[1], factor[2]), 1))
							else
								op = (obj.hyper_chips[1] > 5 and ('{' .. obj.hyper_chips[1] .. '}') or string.rep('^', obj.hyper_chips[1])) .. '1/'
								G.GAME.hands[hand].chips = math.floor(math.max(get_s_chips(hand):arrow(factor[1], to_big(1) / factor[2]), 1))
								G.GAME.hands[hand].chips = math.floor(math.max(G.GAME.hands[hand].chips:arrow(factor[1], to_big(1) / factor[2]), 1))
							end
							if not instant then
								G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
									play_sound('talisman_eeechip')
									card:juice_up(0.8, 0.5)
								return true end }))
								update_hand_text({delay = 0}, {chips = op .. number_format(factor), StatusText = true})
								update_hand_text({delay = HoldDelay}, {chips = G.GAME.hands[hand].chips})
							end
						end
					end
					if obj.x_mult then
						factor = (talisman and to_big(obj.x_mult) or obj.x_mult) ^ math.abs(amount)
						if amount > 0 then
							op = 'x'
							G.GAME.hands[hand].s_mult = math.floor(math.max(get_s_mult(hand) * factor, 1))
							G.GAME.hands[hand].mult = math.floor(math.max(G.GAME.hands[hand].mult * factor, 1))
						else
							op = '/'
							G.GAME.hands[hand].s_mult = math.floor(math.max(get_s_mult(hand) / factor, 1))
							G.GAME.hands[hand].mult = math.floor(math.max(G.GAME.hands[hand].mult / factor, 1))
						end
						if not instant then
							G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
								play_sound('multhit2')
								card:juice_up(0.8, 0.5)
							return true end }))
							update_hand_text({delay = 0}, {mult = op .. number_format(factor), StatusText = true})
							update_hand_text({delay = HoldDelay}, {mult = G.GAME.hands[hand].mult})
						end
					end
					if SMODS.Mods['Talisman'] then
						if obj.e_mult then
							factor = math.abs(amount) == 1 and obj.e_mult or repeated_hyper(1, to_big(obj.e_mult), math.abs(amount))
							if amount > 0 then
								op = '^'
								G.GAME.hands[hand].s_mult = math.floor(math.max(get_s_mult(hand) ^ factor, 1))
								G.GAME.hands[hand].mult = math.floor(math.max(G.GAME.hands[hand].mult ^ factor, 1))
							else
								op = '^1/'
								G.GAME.hands[hand].s_mult = math.floor(math.max(get_s_mult(hand) ^ (1 / factor), 1))
								G.GAME.hands[hand].mult = math.floor(math.max(G.GAME.hands[hand].mult ^ (1 / factor), 1))
							end
							if not instant then
								G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
									play_sound('talisman_emult')
									card:juice_up(0.8, 0.5)
								return true end }))
								update_hand_text({delay = 0}, {mult = op .. number_format(factor), StatusText = true})
								update_hand_text({delay = HoldDelay}, {mult = G.GAME.hands[hand].mult})
							end
						end
						if obj.ee_mult then
							factor = math.abs(amount) == 1 and obj.ee_mult or repeated_hyper(2, to_big(obj.ee_mult), math.abs(amount))
							if amount > 0 then
								op = '^^'
								G.GAME.hands[hand].s_mult = math.floor(math.max(get_s_mult(hand):arrow(2, factor), 1))
								G.GAME.hands[hand].mult = math.floor(math.max(G.GAME.hands[hand].mult:arrow(2, factor), 1))
							else
								op = '^^1/'
								G.GAME.hands[hand].s_mult = math.floor(math.max(get_s_mult(hand):arrow(2, to_big(1) / factor), 1))
								G.GAME.hands[hand].mult = math.floor(math.max(G.GAME.hands[hand].mult:arrow(2, to_big(1) / factor), 1))
							end
							if not instant then
								G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
									play_sound('talisman_eechip')
									card:juice_up(0.8, 0.5)
								return true end }))
								update_hand_text({delay = 0}, {mult = op .. number_format(factor), StatusText = true})
								update_hand_text({delay = HoldDelay}, {mult = G.GAME.hands[hand].mult})
							end
						end
						if obj.eee_mult then
							factor = math.abs(amount) == 1 and obj.eee_mult or repeated_hyper(3, to_big(obj.eee_mult), math.abs(amount))
							if amount > 0 then
								op = '^^^'
								G.GAME.hands[hand].s_mult = math.floor(math.max(get_s_mult(hand):arrow(3, factor), 1))
								G.GAME.hands[hand].mult = math.floor(math.max(G.GAME.hands[hand].mult:arrow(3, factor), 1))
							else
								op = '^^^1/'
								G.GAME.hands[hand].s_mult = math.floor(math.max(get_s_mult(hand):arrow(3, to_big(1) / factor), 1))
								G.GAME.hands[hand].mult = math.floor(math.max(G.GAME.hands[hand].mult:arrow(3, to_big(1) / factor), 1))
							end
							if not instant then
								G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
									play_sound('talisman_eeechip')
									card:juice_up(0.8, 0.5)
								return true end }))
								update_hand_text({delay = 0}, {mult = op .. number_format(factor), StatusText = true})
								update_hand_text({delay = HoldDelay}, {mult = G.GAME.hands[hand].mult})
							end
						end
						if obj.hyper_mult and type(obj.hyper_mult) == 'table' then
							factor = math.abs(amount) == 1 and {obj.hyper_mult[1], to_big(obj.hyper_mult[2])} or {obj.hyper_mult[1], repeated_hyper(obj.hyper_mult[1], to_big(obj.hyper_mult[2]), math.abs(amount))}
							if amount > 0 then
								op = obj.hyper_mult[1] > 5 and ('{' .. obj.hyper_mult[1] .. '}') or string.rep('^', obj.hyper_mult[1])
								G.GAME.hands[hand].s_mult = math.floor(math.max(get_s_mult(hand):arrow(factor[1], factor[2]), 1))
								G.GAME.hands[hand].mult = math.floor(math.max(G.GAME.hands[hand].mult:arrow(factor[1], factor[2]), 1))
							else
								op = (obj.hyper_mult[1] > 5 and ('{' .. obj.hyper_mult[1] .. '}') or string.rep('^', obj.hyper_mult[1])) .. '1/'
								G.GAME.hands[hand].s_mult = math.floor(math.max(get_s_mult(hand):arrow(factor[1], to_big(1) / factor[2]), 1))
								G.GAME.hands[hand].mult = math.floor(math.max(G.GAME.hands[hand].mult:arrow(factor[1], to_big(1) / factor[2]), 1))
							end
							if not instant then
								G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, func = function()
									play_sound('talisman_eeechip')
									card:juice_up(0.8, 0.5)
								return true end }))
								update_hand_text({delay = 0}, {mult = op .. number_format(factor), StatusText = true})
								update_hand_text({delay = HoldDelay}, {mult = G.GAME.hands[hand].mult})
							end
						end
					end
					if obj.p_dollars then
						ease_dollars(obj.p_dollars * amount)
					end
					if type(AurinkoAddons[card.edition.type]) == 'table' and type(AurinkoAddons[card.edition.type].after) == 'function' then
						AurinkoAddons[card.edition.type].after(card, hand, instant, amount)
					end
					if (obj.repetitions or obj.retriggers) and not card.aurinko_already_repeated then
						card.aurinko_already_repeated = true
						local quota = (obj.repetitions or obj.retriggers) * amount
						local predicted_level = G.GAME.hands[hand].level + quota
						if predicted_level < 1 then
							quota = quota + math.abs(predicted_level) + 1
						end
						level_up_hand(card, hand, instant, quota)
					end
					card.aurinko_already_repeated = false
				end
			end
		end
		G.E_MANAGER:add_event(Event({
			trigger = 'immediate',
			func = (function() check_for_unlock{type = 'upgrade_hand', hand = hand, level = G.GAME.hands[hand].level} return true end)
		}))
end

local ccr = create_card
function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
	local card = ccr(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
	G.E_MANAGER:add_event(Event({
		blocking = false,
		blockable = false,
		func = function()
			local obj = card.config.center
			if not card.edition and (((_type == 'Planet' or _type == 'Planet_dx') and (obj.aurinko or (card.ability.consumeable and card.ability.consumeable.hand_type))) or AurinkoWhitelist[obj.key]) then
				local edition = poll_edition('edi'..(key_append or '')..tostring(G.GAME.round_resets.ante), math.max(1, math.min(1 + ((G.GAME.round_resets.ante / 2) - 0.5), 10)), true)
				if edition and not edition.aurinko_blacklist then
					card:set_edition(edition)
				end
				check_for_unlock({type = 'have_edition'})
			end
		return true end
	}))
	return card
end

