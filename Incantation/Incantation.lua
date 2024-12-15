--- STEAMODDED HEADER

--- MOD_NAME: Incantation
--- MOD_ID: incantation
--- MOD_AUTHOR: [jenwalter666, MathIsFun_]
--- MOD_DESCRIPTION: Enables the ability to stack identical consumables.
--- PRIORITY: 89999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
--- BADGE_COLOR: 000000
--- PREFIX: inc
--- VERSION: 0.5.10
--- LOADER_VERSION_GEQ: 1.0.0

Incantation = {consumable_in_use = false, accelerate = false} --will port more things over to this global later, but for now it's going to be mostly empty

local CFG = SMODS.current_mod.config

local MaxStack = 9999
local BulkUseLimit = 9999
local NaiveBulkUseCancel = 100
local AccelerateThreshold = 3

local HardLimit = 9007199254740992

SMODS.current_mod.config_tab = function()
    return {n = G.UIT.ROOT, config = {r = 0.1, align = "cm", padding = 0.1, colour = G.C.BLACK, minw = 8, minh = 4}, nodes = {
        {n = G.UIT.R, config = {align = "cl", padding = 0}, nodes = {
            {n = G.UIT.C, config = { align = "cl", padding = 0.05 }, nodes = {
                create_toggle{ col = true, label = "", scale = 0.85, w = 0, shadow = true, ref_table = CFG, ref_value = "NegativesOnly" },
            }},
            {n = G.UIT.C, config = { align = "c", padding = 0 }, nodes = {
                { n = G.UIT.T, config = { text = localize('incant_negatives_only'), scale = 0.35, colour = G.C.UI.TEXT_LIGHT }},
            }},
        }},
		{n = G.UIT.R, config = {align = "cl", padding = 0}, nodes = {
            {n = G.UIT.C, config = { align = "cl", padding = 0.05 }, nodes = {
                create_toggle{ col = true, label = "", scale = 0.85, w = 0, shadow = true, ref_table = CFG, ref_value = "StackAnything" },
            }},
            {n = G.UIT.C, config = { align = "c", padding = 0 }, nodes = {
                { n = G.UIT.T, config = { text = localize('incant_stack_anything'), scale = 0.35, colour = G.C.RED }},
            }},
        }},
        {n = G.UIT.R, config = {align = "cl", padding = 0}, nodes = {
            {n = G.UIT.C, config = { align = "cl", padding = 0.05 }, nodes = {
                create_toggle{ col = true, label = "", scale = 0.85, w = 0, shadow = true, ref_table = CFG, ref_value = "UnsafeMode" },
            }},
            {n = G.UIT.C, config = { align = "c", padding = 0 }, nodes = {
                { n = G.UIT.T, config = { text = localize('incant_unsafe_mode'), scale = 0.35, colour = G.C.RED }},
            }},
        }}
    }}
end

local function tablecontains(haystack, needle)
	for k, v in pairs(haystack) do
		if v == needle then
			return true
		end
	end
	return false
end

local Stackable = {
	'Planet',
	'Tarot',
	'Spectral'
}

local StackableIndividual = {
	'c_black_hole',
	'c_cry_white_hole'
}

local Divisible = {
	'Planet',
	'Tarot',
	'Spectral'
}

local DivisibleIndividual = {
	'c_black_hole',
	'c_cry_white_hole'
}

local BulkUsable = {
	'Planet'
}

local BulkUsableIndividual = {
	'c_black_hole',
	'c_cry_white_hole'
}

--Allow mods to add/remove their own card types to the list

function AllowStacking(set)
	if not tablecontains(Stackable, set) then
		table.insert(Stackable, set)
	end
end

function AllowStackingIndividual(key)
	if not tablecontains(StackableIndividual, key) then
		table.insert(StackableIndividual, key)
	end
end

function AllowDividing(set)
	AllowStacking(set)
	if not tablecontains(Divisible, set) then
		table.insert(Divisible, set)
	end
end

function AllowDividingIndividual(key)
	AllowStackingIndividual(key)
	if not tablecontains(DivisibleIndividual, key) then
		table.insert(DivisibleIndividual, key)
	end
end

function AllowBulkUse(set)
	AllowStacking(set)
	AllowDividing(set)
	if not tablecontains(BulkUsable, set) then
		table.insert(BulkUsable, set)
	end
end

function AllowBulkUseIndividual(key)
	AllowStackingIndividual(key)
	AllowDividingIndividual(key)
	if not tablecontains(BulkUsableIndividual, key) then
		table.insert(BulkUsableIndividual, key)
	end
end

--[[

+++ MOD SUPPORT SKELETON : ALWAYS INCLUDE THIS IN YOUR MOD'S INITIALISATION SOMEWHERE +++

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

then you can use table.insert() to insert sets/keys into the subtables contained within IncantationAddons

]]

if IncantationAddons then
	if #IncantationAddons.Stacking > 0 then
		for _, v in pairs(IncantationAddons.Stacking) do
			AllowStacking(v)
		end
	end
	if #IncantationAddons.StackingIndividual > 0 then
		for _, v in pairs(IncantationAddons.StackingIndividual) do
			AllowStackingIndividual(v)
		end
	end
	if #IncantationAddons.Dividing > 0 then
		for _, v in pairs(IncantationAddons.Dividing) do
			AllowDividing(v)
		end
	end
	if #IncantationAddons.DividingIndividual > 0 then
		for _, v in pairs(IncantationAddons.DividingIndividual) do
			AllowDividingIndividual(v)
		end
	end
	if #IncantationAddons.BulkUse > 0 then
		for _, v in pairs(IncantationAddons.BulkUse) do
			AllowBulkUse(v)
		end
	end
	if #IncantationAddons.BulkUseIndividual > 0 then
		for _, v in pairs(IncantationAddons.BulkUseIndividual) do
			AllowBulkUseIndividual(v)
		end
	end
end

function Card:getQty()
	return (self.ability or {}).qty or 1
end

function Card:setQty(quantity, dontupdatecost)
	if not quantity then quantity = 1 end
	if self:CanStack() then
		if self.ability then
			self.ability.qty = math.min(HardLimit, math.floor(quantity))
			self:create_stack_display()
			if not dontupdatecost then self:set_cost() end
		end
	end
end

function Card:addQty(quantity, dontupdatecost)
	self:setQty(self:getQty() + math.floor(quantity), dontupdatecost)
end

function Card:subQty(quantity, dont_dissolve, dontupdatecost)
	if quantity >= self:getQty() and not dont_dissolve then
		self:setQty(0)
		self.ignorestacking = true
		self:start_dissolve()
	else
		self:setQty(math.max(0, self:getQty() - math.ceil(quantity)), dontupdatecost)
	end
end

function Card:CanStack()
	if self.area and G.consumeables and self.area ~= G.consumeables then
		return false
	elseif self.ability and (self.ability.set == 'Booster' or self.ability.set == 'Voucher') then
		return false
	elseif CFG.NegativesOnly and not (self.edition and self.edition.negative) then
		return false
	elseif CFG.StackAnything then
		return true
	end

	return (self.config.center and (type(self.config.center.can_stack) == 'function' and self.config.center:can_stack() or self.config.center.can_stack)) or tablecontains(Stackable, self.ability.set) or tablecontains(StackableIndividual, self.config.center_key)
end

function Card:CanDivide()
	if CFG.StackAnything then
		return true
	end
	return (self.config.center and (type(self.config.center.can_divide) == 'function' and self.config.center:can_divide() or self.config.center.can_divide)) or tablecontains(Divisible, self.ability.set) or tablecontains(DivisibleIndividual, self.config.center_key)
end

function Card:CanBulkUse(ignoreunsafe)
	return (not ignoreunsafe and CFG.UnsafeMode) or not self.config.center.no_bulkuse and ((self.config.center and (type(self.config.center.can_bulk_use) == 'function' and self.config.center:can_bulk_use() or (self.config.center.can_bulk_use or (self.config.center.bulk_use and (type(self.config.center.bulk_use) == 'function'))))) or tablecontains(BulkUsable, self.ability.set) or tablecontains(BulkUsableIndividual, self.config.center_key))
end

function Card:getmaxuse()
	--let modders define their own bulk-use limit in case of concerns with performance
	return (self.config.center.bulk_use_limit or UseBulkCap) and math.min((self.config.center.bulk_use_limit or BulkUseLimit), self:getQty()) or (self:getQty())
end

function set_consumeable_usage(card, qty)
	qty = math.floor(qty or 1)
    if card.config.center_key and card.ability.consumeable then
      if G.PROFILES[G.SETTINGS.profile].consumeable_usage[card.config.center_key] then
        G.PROFILES[G.SETTINGS.profile].consumeable_usage[card.config.center_key].count = G.PROFILES[G.SETTINGS.profile].consumeable_usage[card.config.center_key].count + qty
      else
        G.PROFILES[G.SETTINGS.profile].consumeable_usage[card.config.center_key] = {count = 1, order = card.config.center.order}
      end
      if G.GAME.consumeable_usage[card.config.center_key] then
        G.GAME.consumeable_usage[card.config.center_key].count = G.GAME.consumeable_usage[card.config.center_key].count + qty
      else
        G.GAME.consumeable_usage[card.config.center_key] = {count = 1, order = card.config.center.order, set = card.ability.set}
      end
      G.GAME.consumeable_usage_total = G.GAME.consumeable_usage_total or {tarot = 0, planet = 0, spectral = 0, tarot_planet = 0, all = 0}
      if card.config.center.set == 'Tarot' then
        G.GAME.consumeable_usage_total.tarot = G.GAME.consumeable_usage_total.tarot + qty  
        G.GAME.consumeable_usage_total.tarot_planet = G.GAME.consumeable_usage_total.tarot_planet + qty
      elseif card.config.center.set == 'Planet' then
        G.GAME.consumeable_usage_total.planet = G.GAME.consumeable_usage_total.planet + qty
        G.GAME.consumeable_usage_total.tarot_planet = G.GAME.consumeable_usage_total.tarot_planet + qty
      elseif card.config.center.set == 'Spectral' then  G.GAME.consumeable_usage_total.spectral = G.GAME.consumeable_usage_total.spectral + qty
      end

      G.GAME.consumeable_usage_total.all = G.GAME.consumeable_usage_total.all + qty

      if not card.config.center.discovered then
        discover_card(card)
      end

      if card.config.center.set == 'Tarot' or card.config.center.set == 'Planet' then 
        G.E_MANAGER:add_event(Event({
          trigger = 'immediate',
          func = function()
            G.E_MANAGER:add_event(Event({
              trigger = 'immediate',
              func = function()
                G.GAME.last_tarot_planet = card.config.center_key
                  return true
              end
            }))
              return true
          end
        }))
      end

    end
    G:save_settings()
end

function Card:split(amount, forced, fullmax)
	if not amount then amount = math.floor((self:getQty()) / 2) end
	amount = math.max(1, amount)
	if (self.ability.qty or 0) > (fullmax and 0 or 1) and (self:CanDivide() or forced) and not self.ignorestacking then
		local traysize = G.consumeables.config.card_limit
		if (self.edition or {}).negative then
			traysize = traysize + 1
		end
		local split = copy_card(self)
		local qty2 = math.min(self.ability.qty - (fullmax and 0 or 1), amount)
		G.consumeables.config.card_limit = #G.consumeables.cards + 1
		split.ignorestacking = true
		split.created_from_split = true
		split:add_to_deck()
		G.consumeables:emplace(split, nil, nil, true)
		split.ability.qty = qty2
		self.ability.qty = self.ability.qty - qty2
		G.consumeables.config.card_limit = traysize
		if qty2 > 1 then
			split:create_stack_display()
		end
		split:set_cost()
		self:set_cost()
		play_sound('card1')
		return split
	end
end

function Card:try_merge()
	if self:CanStack() and not self.ignorestacking then
		for _, v in pairs(G.consumeables.cards) do

			if CFG.NegativesOnly and not (v.edition or {}).negative then
				-- Ignore this
			elseif v ~= self and not v.nomerging and not v.ignorestacking and v.config.center_key == self.config.center_key and (((v.edition or {}).type or '') == ((self.edition or {}).type or '')) and (v:getQty() < (UseStackCap and MaxStack or HardLimit)) then
				local space = (UseStackCap and MaxStack or HardLimit) - (v:getQty())
				v.ability.qty = (v:getQty()) + math.min((self:getQty()), space)
				v:create_stack_display()
				v:juice_up(0.5, 0.5)
				play_sound('card1')
				v:set_cost()
				if (self:getQty()) - space < 1 then
					self.ignorestacking = true
					self.area:remove_card(self)
					self:remove()
					return true
				else
					self.ability.qty = (self:getQty()) - space
					self:set_cost()
				end
			end
		end
	end
end

function Card:getEvalQty()
	return self.cardinuse and math.min(self:getQty(), (self.bulkuse and not self.naivebulkuse) and self:getQty() or (self.OverrideBulkUseLimit or NaiveBulkUseCancel)) or self:getQty()
end

local useconsumeref = Card.use_consumeable

function Card:use_consumeable(area, copier)
	local obj = self.config.center
	local uselim = self.OverrideBulkUseLimit or NaiveBulkUseCancel
	local qty = self:getQty()
	if qty <= 0 then
		self:setQty(1, true)
		qty = 1
	end
	if self.ability then
		self.ability.qty_initial = qty
	end
	if not self.naivebulkuse and self.bulkuse and obj.bulk_use and type(obj.bulk_use) == 'function' then
		set_consumeable_usage(self, qty)
		return obj:bulk_use(self, area, copier, qty)
	elseif not self.naivebulkuse and self.ability.consumeable.hand_type then
		update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize(self.ability.consumeable.hand_type, 'poker_hands'),chips = G.GAME.hands[self.ability.consumeable.hand_type].chips, mult = G.GAME.hands[self.ability.consumeable.hand_type].mult, level=G.GAME.hands[self.ability.consumeable.hand_type].level})
        level_up_hand(copier or self, self.ability.consumeable.hand_type, nil, qty)
        update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
		set_consumeable_usage(self, qty)
	elseif not self.naivebulkuse and self.ability.name == 'Black Hole' then
        update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize('k_all_hands'),chips = '...', mult = '...', level=''})
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
            play_sound('tarot1')
            self:juice_up(0.8, 0.5)
            G.TAROT_INTERRUPT_PULSE = true
            return true end }))
        update_hand_text({delay = 0}, {mult = '+', StatusText = true})
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.9, func = function()
            play_sound('tarot1')
            self:juice_up(0.8, 0.5)
            return true end }))
        update_hand_text({delay = 0}, {chips = '+', StatusText = true})
        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.9, func = function()
            play_sound('tarot1')
            self:juice_up(0.8, 0.5)
            G.TAROT_INTERRUPT_PULSE = nil
            return true end }))
        update_hand_text({sound = 'button', volume = 0.7, pitch = 0.9, delay = 0}, {level='+' .. qty})
        delay(1.3)
        for k, v in pairs(G.GAME.hands) do
            level_up_hand(self, k, true, qty)
        end
        update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
		set_consumeable_usage(self, qty)
	else
		Incantation.accelerate = qty > AccelerateThreshold or self.force_incantation_acceleration
		self.cardinuse = true
		Incantation.consumable_in_use = true
		local lim = math.min(qty, uselim)
		local newqty = math.max(0, qty - lim)
		if not self.ability.qty then self.ability.qty = 1 end
		for i = 1, lim do
			useconsumeref(self,area,copier)
			G.E_MANAGER:add_event(Event({
				trigger = 'immediate',
				delay = 0.1,
				blockable = true,
				func = function()
					self.ability.qty = self.ability.qty - 1
					play_sound('button', self.ability.qty <= 0 and 1 or 0.85, 0.7)
					return true
				end
			}))
		end
		G.E_MANAGER:add_event(Event({
			trigger = 'after',
			delay = 0.1,
			blockable = true,
			func = function()
				Incantation.consumable_in_use = false
				Incantation.accelerate = false
				self.cardinuse = nil
				self.bulkuse = nil
				self.naivebulkuse = nil
				self.OverrideBulkUseLimit = nil
				if obj.keep_on_use and obj:keep_on_use(self) then
					self.ignorestacking = false
					self.ability.qty = obj.keep_on_use_retain_stack and qty or (newqty + 1)
				else
					if newqty > 0 then
						self:split(newqty, true, true)
					end
				end
				return true
			end
		}))
	end
end

local startdissolveref = Card.start_dissolve
function Card:start_dissolve(a,b,c,d)
	if self.ability.qty and self.ability.qty > 1 and Incantation.consumable_in_use and self.cardinuse and not self.ignore_incantation_consumable_in_use then return end
	self.ignorestacking = true
	return startdissolveref(self,a,b,c,d)
end

local usecardref = G.FUNCS.use_card

function CanUseStackButtons()
	if ((G.play and #G.play.cards > 0) or (G.CONTROLLER.locked) or (G.GAME.STOP_USE and G.GAME.STOP_USE > 0)) and G.STATE ~= G.STATES.HAND_PLAYED and G.STATE ~= G.STATES.DRAW_TO_HAND and G.STATE ~= G.STATES.PLAY_TAROT then
		return false
	end
	return true
end

G.FUNCS.use_card = function(e, mute, nosave)
    local card = e.config.ref_table
	local useamount = card.bulkuse and card:getmaxuse() or 1
	if ((card.ability or {}).qty or 1) > useamount then
		card.highlighted = false
		card.bulkuse = false
		card.OverrideBulkUseLimit = useamount
	end
	usecardref(e, mute, nosave)
end

G.FUNCS.can_split_card = function(e)
	local card = e.config.ref_table
	local splitone = e.config.issplitone
	if (card:getQty()) > 1 and card.highlighted and CanUseStackButtons() and not card.ignorestacking then
        e.config.colour = splitone and G.C.GREEN or G.C.PURPLE
        e.config.button = splitone and 'split_one' or 'split_half'
		e.states.visible = true
	else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
		e.states.visible = false
	end
end

function Card:MergeAvailable()
	if ((self.config or {}).center or {}).set ~= 'Joker' and ((self.config or {}).center or {}).set ~= 'Booster' then
		for k, v in pairs(G.consumeables.cards) do
			if v then
				if v ~= self and (v.config or {}).center_key == (self.config or {}).center_key and ((v.edition or {}).type or '') == ((self.edition or {}).type or '') then
					return true
				end
			end
		end
	end
end

G.FUNCS.can_merge_card = function(e)
	local card = e.config.ref_table
	if card:CanStack() and card.highlighted and not card.ignorestacking and CanUseStackButtons() and card:MergeAvailable() then
        e.config.colour = G.C.BLUE
        e.config.button = 'merge_card'
		e.states.visible = true
	else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
		e.states.visible = false
	end
end

G.FUNCS.can_use_all = function(e)
	local card = e.config.ref_table
	local obj = card.config.center
	if card:CanBulkUse() and ((tablecontains(BulkUsable, card.ability.set) or tablecontains(BulkUsableIndividual, card.config.center_key)) or (obj.bulk_use and type(obj.bulk_use) == 'function')) and (card:getQty()) > 1 and card.highlighted and CanUseStackButtons() and not card.ignorestacking then
        e.config.colour = G.C.DARK_EDITION
        e.config.button = 'use_all'
		e.states.visible = true
	else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
		e.states.visible = false
	end
end

G.FUNCS.can_use_every_planet = function(e)
	local card = e.config.ref_table
	local obj = card.config.center
	if (((card.config or {}).center or {}).set or '') == 'Planet' and card:CanBulkUse() and CanUseStackButtons() and not card.ignorestacking and not obj.ignore_allplanets then
        e.config.colour = G.C.SECONDARY_SET.Planet
        e.config.button = 'use_every_planet'
		e.states.visible = true
	else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
		e.states.visible = false
	end
end

G.FUNCS.can_use_naivebulk = function(e)
	local card = e.config.ref_table
	local obj = card.config.center
	if (card:CanBulkUse() or CFG.UnsafeMode) and (CFG.UnsafeMode or not obj.bulk_use or type(obj.bulk_use) ~= 'function') and (card:getQty()) > 1 and card.highlighted and CanUseStackButtons() and not card.ignorestacking then
        e.config.colour = G.C.BLACK
        e.config.button = 'use_naivebulk'
		e.states.visible = true
	else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
		e.states.visible = false
	end
end

G.FUNCS.split_half = function(e)
	local card = e.config.ref_table
	card:split(math.floor(card.ability.qty / 2))
end

G.FUNCS.split_one = function(e)
	local card = e.config.ref_table
	card:split(1)
end

G.FUNCS.merge_card = function(e)
	local card = e.config.ref_table
	card:try_merge()
end

G.FUNCS.use_all = function(e)
	local card = e.config.ref_table
	local obj = card.config.center
	if card:CanBulkUse() and (not obj.can_use or obj:can_use(card)) and (card:getQty()) > 1 and card.highlighted then
		card.bulkuse = true
		G.FUNCS.use_card(e, false, true)
	end
end

function runthrough_planets()
	for i = 1, #G.play.cards do
		local card = G.play.cards[i]
		if card then
			local obj = card.config.center
			if (((card.config or {}).center or {}).set or '') == 'Planet' then
				card.bulkuse = card:CanBulkUse() and math.max(1, card:getQty()) > 1
				card.force_incantation_acceleration = true
				card:use_consumeable(G.consumeables)
				if G.betmma_abilities then
					for i = 1, #G.betmma_abilities.cards do
						G.betmma_abilities.cards[i]:calculate_joker({using_consumeable = true, consumeable = card})
					end
				end
				for i = 1, #G.jokers.cards do
					local effects = G.jokers.cards[i]:calculate_joker({using_consumeable = true, consumeable = card})
					if effects and effects.joker_repetitions then
						rep_list = effects.joker_repetitions
						for z=1, #rep_list do
							if type(rep_list[z]) == 'table' and rep_list[z].repetitions then
								for r=1, rep_list[z].repetitions do
									card_eval_status_text(rep_list[z].card, 'jokers', nil, nil, nil, rep_list[z])
									G.jokers.cards[i]:calculate_joker({using_consumeable = true, consumeable = card, retrigger_joker = true})
								end
							end
						end
					end
				end
				G.E_MANAGER:add_event(Event({func = function()
					card.ignore_incantation_consumable_in_use = true
					card:start_dissolve()
					return true
				end}))
			end
		end
		G.E_MANAGER:add_event(Event({
			trigger = 'after',
			delay = 0.1,
			blockable = true,
			func = function()
				Incantation.consumable_in_use = false
				Incantation.accelerate = false
				return true
			end
		}))
	end
end

G.FUNCS.use_every_planet = function(e)
	local targets = {}
	for i = 1, #G.consumeables.cards do
		local card = G.consumeables.cards[i]
		if card then
			local obj = card.config.center
			if (((card.config or {}).center or {}).set or '') == 'Planet' and (not obj.can_use or obj:can_use(card)) and not obj.ignore_allplanets then
				table.insert(targets, card)
			end
		end
	end
	for i = 1, #targets do
		local card = targets[i]
		G.E_MANAGER:add_event(Event({func = function()
			if math.ceil(i/2) == i/2 then play_sound('card1') end
			card.area:remove_card(card)
			G.play:emplace(card)
			return true
		end}))
	end
	G.E_MANAGER:add_event(Event({func = function()
		runthrough_planets()
		return true
	end}))
end

G.FUNCS.use_naivebulk = function(e)
	local card = e.config.ref_table
	local obj = card.config.center
	if card:CanBulkUse() and (not obj.can_use or obj:can_use(card)) and (card:getQty()) > 1 and card.highlighted and CFG.UnsafeMode then
		card.naivebulkuse = true
		card.bulkuse = true
		G.FUNCS.use_card(e, false, true)
	end
end

G.FUNCS.disablestackdisplay = function(e)
	local card = e.config.ref_table
	e.states.visible = ((card:getQty()) > 1 and not card.ignorestacking) or card.cardinuse
end

function Card:create_stack_display()
	if not self.children.stackdisplay and self:CanStack() and not self.playing_card then
		self.children.stackdisplay = UIBox {
			definition = {
				n = G.UIT.ROOT,
				config = {
					minh = 0.6,
					maxh = 1.2,
					minw = 0.5,
					maxw = 2,
					r = 0.001,
					padding = 0.1,
					align = 'cm',
					colour = adjust_alpha(darken(G.C.BLACK, 0.2), 0.6),
					shadow = false,
					func = 'disablestackdisplay',
					ref_table = self
				},
				nodes = {
					{
						n = G.UIT.T,
						config = {
							text = 'x',
							scale = 0.4,
							colour = G.C.MULT
						}
					},
					{
						n = G.UIT.T,
						config = {
							ref_table = self.ability,
							ref_value = 'qty',
							scale = 0.4,
							colour = G.C.UI.TEXT_LIGHT
						}
					}
				}
			},
			config = {
				align = 'cm',
				bond = 'Strong',
				parent = self
			},
			states = {
				collide = { can = false },
				drag = { can = true }
			}
		}
	end
end

local card_load_ref = Card.load
function Card:load(cardTable, other_card)
	card_load_ref(self, cardTable, other_card)
	if self.ability then
		if self.ability.qty then
			self:create_stack_display()
		end
	end
end

local deckadd = Card.add_to_deck
function Card:add_to_deck(from_debuff)
	deckadd(self, from_debuff)
	if G.consumeables then
		if self:CanStack() then
			if not self.ignorestacking then
				G.E_MANAGER:add_event(Event({
					trigger = 'after',
					delay = 0.1,
					blocking = false,
					func = function()
						if self and self.area and self.area ~= 'shop' and self.area ~= 'pack_cards' then
							self:try_merge()
						end
						return true
					end
				}))
			end
			self.ignorestacking = nil
		end
	end
end

local hlref = Card.highlight

function Card:highlight(is_highlighted)
	local isplanet = ((self.ability or {}).set or '') == 'Planet'
	if self:CanStack() and self.added_to_deck and not self.ignorestacking then
		if is_highlighted then
			if isplanet then
				self.children.everyplanetbutton = UIBox {
					definition = {
						n = G.UIT.ROOT,
						config = {
							minh = 0.3,
							maxh = 0.6,
							minw = 0.3,
							maxw = 4,
							r = 0.08,
							padding = 0.1,
							align = 'cm',
							colour = G.C.SECONDARY_SET.Planet,
							shadow = true,
							button = 'use_every_planet',
							func = 'can_use_every_planet',
							ref_table = self
						},
						nodes = {
							{
								n = G.UIT.T,
								config = {
									text = 'MASS-USE PLANETS',
									scale = 0.3,
									colour = G.C.UI.TEXT_LIGHT
								}
							}
						}
					},
					config = {
						align = 'bmi',
						offset = {
							x = 0,
							y = 1
						},
						bond = 'Strong',
						parent = self
					}
				}
			end
			self.children.useallbutton = UIBox {
				definition = {
					n = G.UIT.ROOT,
					config = {
						minh = 0.3,
						maxh = 0.6,
						minw = 0.3,
						maxw = 4,
						r = 0.08,
						padding = 0.1,
						align = 'cm',
						colour = G.C.DARK_EDITION,
						shadow = true,
						button = 'use_all',
						func = 'can_use_all',
						ref_table = self
					},
					nodes = {
						{
							n = G.UIT.T,
							config = {
								text = 'BULK USE' .. (CFG.UnsafeMode and ' (NORMAL)' or ''),
								scale = 0.3,
								colour = G.C.UI.TEXT_LIGHT
							}
						}
					}
				},
				config = {
					align = 'bmi',
					offset = {
						x = 0,
						y = 0.5
					},
					bond = 'Strong',
					parent = self
				}
			}
			self.children.mergebutton = UIBox {
				definition = {
					n = G.UIT.ROOT,
					config = {
						minh = 0.3,
						maxh = 0.6,
						minw = 0.3,
						maxw = 4,
						r = 0.08,
						padding = 0.1,
						align = 'cm',
						colour = G.C.BLUE,
						shadow = true,
						button = 'merge_card',
						func = 'can_merge_card',
						ref_table = self
					},
					nodes = {
						{
							n = G.UIT.T,
							config = {
								text = 'MERGE',
								scale = 0.3,
								colour = G.C.UI.TEXT_LIGHT
							}
						}
					}
				},
				config = {
					align = 'bmi',
					offset = {
						x = 0,
						y = 1 + (isplanet and 0.5 or 0)
					},
					bond = 'Strong',
					parent = self
				}
			}
			self.children.splithalfbutton = UIBox {
				definition = {
					n = G.UIT.ROOT,
					config = {
						minh = 0.3,
						maxh = 0.6,
						minw = 0.3,
						maxw = 4,
						r = 0.08,
						padding = 0.1,
						align = 'cm',
						colour = G.C.PURPLE,
						shadow = true,
						button = 'split_half',
						func = 'can_split_card',
						ref_table = self
					},
					nodes = {
						{
							n = G.UIT.T,
							config = {
								text = 'SPLIT HALF',
								scale = 0.3,
								colour = G.C.UI.TEXT_LIGHT
							}
						}
					}
				},
				config = {
					align = 'bmi',
					offset = {
						x = 0,
						y = 1.5 + (isplanet and 0.5 or 0)
					},
					bond = 'Strong',
					parent = self
				}
			}
			self.children.splitonebutton = UIBox {
				definition = {
					n = G.UIT.ROOT,
					config = {
						minh = 0.3,
						maxh = 0.6,
						minw = 0.3,
						maxw = 4,
						r = 0.08,
						padding = 0.1,
						align = 'cm',
						issplitone = true,
						colour = G.C.GREEN,
						shadow = true,
						button = 'split_one',
						func = 'can_split_card',
						ref_table = self
					},
					nodes = {
						{
							n = G.UIT.T,
							config = {
								text = 'SPLIT ONE',
								scale = 0.3,
								colour = G.C.UI.TEXT_LIGHT
							}
						}
					}
				},
				config = {
					align = 'bmi',
					offset = {
						x = 0,
						y = 2 + (isplanet and 0.5 or 0)
					},
					bond = 'Strong',
					parent = self
				}
			}
			if CFG.UnsafeMode then
				self.children.useallnaivebutton = UIBox {
					definition = {
						n = G.UIT.ROOT,
						config = {
							minh = 0.3,
							maxh = 0.6,
							minw = 0.3,
							maxw = 4,
							r = 0.08,
							padding = 0.1,
							align = 'cm',
							colour = G.C.BLACK,
							shadow = true,
							button = 'use_naivebulk',
							func = 'can_use_naivebulk',
							ref_table = self
						},
						nodes = {
							{
								n = G.UIT.T,
								config = {
									text = 'BULK USE (ONE-AT-A-TIME)',
									scale = 0.3,
									colour = G.C.RED
								}
							}
						}
					},
					config = {
						align = 'bmi',
						offset = {
							x = 0,
							y = 2.5 + (isplanet and 0.5 or 0)
						},
						bond = 'Strong',
						parent = self
					}
				}
			end
		else
			if isplanet then
				if self.children.everyplanetbutton then self.children.everyplanetbutton:remove();self.children.everyplanetbutton = nil end
			end
			if self.children.splithalfbutton then self.children.splithalfbutton:remove();self.children.splithalfbutton = nil end
			if self.children.splitonebutton then self.children.splitonebutton:remove();self.children.splitonebutton = nil end
			if self.children.mergebutton then self.children.mergebutton:remove();self.children.mergebutton = nil end
			if self.children.useallbutton then self.children.useallbutton:remove();self.children.useallbutton = nil end
			if CFG.UnsafeMode then
				if self.children.useallnaivebutton then self.children.useallnaivebutton:remove();self.children.useallnaivebutton = nil end
			end
		end
	end
	return hlref(self,is_highlighted)
end

local ccr = copy_card

function copy_card(other, new_card, card_scale, playing_card, strip_edition)
	local card = ccr(other, new_card, card_scale, playing_card, strip_edition)
	if card then
		if card:getQty() <= 0 then card:setQty(1) end
	end
	card.OverrideBulkUseLimit = nil
	card.bulkuse = nil
	card.naivebulkuse = nil
	card.cardinuse = nil
	card.eval_qty = nil
	return card
end

local costref = Card.set_cost
function Card:set_cost()
	costref(self)
	self.sell_cost = self.sell_cost * math.max(1, (self.ability or {}).qty or 1)
    self.sell_cost_label = self.facing == 'back' and '?' or self.sell_cost
end

if not (SMODS.Mods['jen'] or {}).can_load then
	SMODS.Joker:take_ownership('perkeo', {
		name = "Perkeo (Incantation)",
		loc_vars = function(self, info_queue, center)
			info_queue[#info_queue+1] = {key = 'e_negative_consumable', set = 'Edition', config = {extra = 1}}
			return {vars = {center.ability.extra}}
		end,
		calculate = function(self, card, context)
			if context.ending_shop then
				if G.consumeables.cards[1] then
					G.E_MANAGER:add_event(Event({
						func = function() 
							local total, checked, center = 0, 0, nil
							for i = 1, #G.consumeables.cards do
								total = total + (G.consumeables.cards[i]:getQty())
							end
							local poll = pseudorandom(pseudoseed('perkeo'))*total
							for i = 1, #G.consumeables.cards do
								checked = checked + (G.consumeables.cards[i]:getQty())
								if checked >= poll then
									center = G.consumeables.cards[i]
									break
								end
							end
							local card = copy_card(center, nil)
							card.ability.qty = 1
							card:set_edition({negative = true}, true)
							card:add_to_deck()
							G.consumeables:emplace(card) 
							return true
						end}))
					card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_duplicated_ex')})
					return {calculated = true}
				end
			end
		end
	})
end
