--- STEAMODDED HEADER

--- MOD_NAME: Nopeus
--- MOD_ID: nopeus
--- MOD_AUTHOR: [jenwalter666, stupxd]
--- MOD_DESCRIPTION: An extension of MoreSpeeds which includes more options, including a new speed which makes the event manager run as fast as it can.
--- PRIORITY: 999999999
--- BADGE_COLOR: ff3c3c
--- PREFIX: nopeus
--- VERSION: 2.0.0
--- LOADER_VERSION_GEQ: 1.0.0

Nopeus = {
	Off = 'Off',
	On = 'On',
	Unsafe = 'Unsafe',
	AllText = 'All',
	NoAgain = 'No "Again!"',
	NoMisc = 'No Misc.',
	NoText = 'None'
}

G.FUNCS.change_fastforward = function(args)
  G.SETTINGS.FASTFORWARD = (args.to_val == Nopeus.On and 1 or args.to_val == Nopeus.Unsafe and 2 or 0)
end

G.FUNCS.change_statustext = function(args)
  G.SETTINGS.STATUSTEXT = (args.to_val == Nopeus.NoAgain and 1 or args.to_val == Nopeus.NoMisc and 2 or args.to_val == Nopeus.NoText and 3 or 0)
end

function G.UIDEF.nopeus_options()
	local speeds = create_option_cycle({label = localize('b_set_gamespeed'), scale = 0.8, options = {0.25, 0.5, 1, 2, 3, 4, 8, 16, 32, 64}, opt_callback = 'change_gamespeed', current_option = (
		G.SETTINGS.GAMESPEED == 0.25 and 1 or
		G.SETTINGS.GAMESPEED == 0.5 and 2 or 
		G.SETTINGS.GAMESPEED == 1 and 3 or 
		G.SETTINGS.GAMESPEED == 2 and 4 or
		G.SETTINGS.GAMESPEED == 3 and 5 or
		G.SETTINGS.GAMESPEED == 4 and 6 or 
		G.SETTINGS.GAMESPEED == 8 and 7 or 
		G.SETTINGS.GAMESPEED == 16 and 8 or 
		G.SETTINGS.GAMESPEED == 32 and 9 or 
		G.SETTINGS.GAMESPEED == 64 and 10 or 
		3 -- Default to 1 if none match, adjust as necessary
	)})
	
	return speeds
end

function G.UIDEF.nopeus_fastforward_options()
	local ff = create_option_cycle({label = 'Fast-Forward', colour = G.C.PURPLE, scale = 0.8, options = {Nopeus.Off, Nopeus.On, Nopeus.Unsafe}, opt_callback = 'change_fastforward', current_option = (
		G.SETTINGS.FASTFORWARD + 1
	)})
	
	return ff
end

function G.UIDEF.nopeus_statustext_options()
	local st = create_option_cycle({label = 'Card Text Popups', colour = G.C.FILTER, w = 4, scale = 0.8, options = {Nopeus.AllText, Nopeus.NoAgain, Nopeus.NoMisc, Nopeus.NoText}, opt_callback = 'change_statustext', current_option = (
		G.SETTINGS.STATUSTEXT + 1
	)})
	
	return st
end

local cest = card_eval_status_text
function card_eval_status_text(card, eval_type, amt, percent, dir, extra)
	if G.SETTINGS.STATUSTEXT == 3 then
		return
	elseif G.SETTINGS.STATUSTEXT == 2 then
		if eval_type == 'extra' then return end
		local msg = ((extra or {}).message or '')
		local is_again_msg = ((extra or {}).nopeus_again)
		if is_again_msg or msg == localize('k_again_ex') or msg == 'Again?' then
			return
		end
	elseif G.SETTINGS.STATUSTEXT == 1 then
		local msg = ((extra or {}).message or '')
		local is_again_msg = ((extra or {}).nopeus_again)
		if is_again_msg or msg == localize('k_again_ex') or msg == 'Again?' then
			return
		end
	end
	return cest(card, eval_type, amt, percent, dir, extra)
end

function Event:init(config)
    self.trigger = config.trigger or 'immediate'
	if G.SETTINGS.FASTFORWARD > 1 then
		self.blocking = false
    elseif config.blocking ~= nil then 
        self.blocking = config.blocking
    else
        self.blocking = true
    end
	if G.SETTINGS.FASTFORWARD > 1 then
		self.blockable = false
    elseif config.blockable ~= nil then 
        self.blockable = config.blockable
    else
        self.blockable = true
    end
    self.complete = false
    self.start_timer = config.start_timer or false
    self.func = config.func or function() return true end
    self.no_delete = config.no_delete
    self.created_on_pause = config.pause_force or G.SETTINGS.paused
    self.timer = config.timer or (self.created_on_pause and 'REAL') or 'TOTAL'
    self.delay = (self.timer == 'REAL' or G.SETTINGS.FASTFORWARD < 1) and config.delay or (self.trigger == 'ease' and 0.0001 or 0)
    
    if self.trigger == 'ease' then
        self.ease = {
            type = config.ease or 'lerp',
            ref_table = config.ref_table,
            ref_value = config.ref_value,
            start_val = config.ref_table[config.ref_value],
            end_val = config.ease_to,
            start_time = nil,
            end_time = nil,
        }
    self.func = config.func or function(t) return t end
    end
    if self.trigger == 'condition' then
        self.condition = {
            ref_table = config.ref_table,
            ref_value = config.ref_value,
            stop_val = config.stop_val,
        }
    self.func = config.func or function() return self.condition.ref_table[self.condition.ref_value] == self.condition.stop_val end
    end
    self.time = G.TIMERS[self.timer]
end

local ccr = create_card

function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
	if G.SETTINGS.FASTFORWARD > 0 and _type == 'Joker' and area ~= G.jokers then
		local eternal_perishable_poll = pseudorandom((area == G.pack_cards and 'packetper' or 'etperpoll')..G.GAME.round_resets.ante)
		local eternal = G.GAME.modifiers.all_eternal or (G.GAME.modifiers.enable_eternals_in_shop and eternal_perishable_poll > 0.7)
		local perish = G.GAME.modifiers.enable_perishables_in_shop and ((eternal_perishable_poll > 0.4) and (eternal_perishable_poll <= 0.7)) and not eternal
		local rental = G.GAME.modifiers.enable_rentals_in_shop and pseudorandom((area == G.pack_cards and 'packssjr' or 'ssjr')..G.GAME.round_resets.ante) > 0.7
		local card = ccr(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
		if card then
			if eternal then
				card:set_eternal(true)
			elseif perish then
				card:set_perishable(true)
			end
			if rental then
				card:set_rental(true)
			end
		end
		return card
	else
		return ccr(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
	end
end

local gfecr = G.FUNCS.end_consumeable
G.FUNCS.end_consumeable = function(e, delayfac)
	delayfac = delayfac or 1
	gfecr(e, delayfac)
	G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.2*delayfac,
		blocking = true,
		blockable = false,
		func = function()
			G.pack_cards:remove()
			G.pack_cards = nil
		return true
	end}))
end

-- Instant reshuffle at end of round

local hand_to_discard = G.FUNCS.draw_from_hand_to_discard

G.FUNCS.draw_from_hand_to_discard = function (e)
    if G.SETTINGS.FASTFORWARD < 1 then
        return hand_to_discard(e)
    end
    
    for _ = 1, #G.hand.cards do
        G.discard:draw_card_from(G.hand)
    end
end

local discard_to_deck = G.FUNCS.draw_from_discard_to_deck

G.FUNCS.draw_from_discard_to_deck = function (e)
    if G.SETTINGS.FASTFORWARD < 1 then
        return discard_to_deck(e)
    end
    
    for _ = 1, #G.discard.cards do
        G.deck:draw_card_from(G.discard)
    end
end
