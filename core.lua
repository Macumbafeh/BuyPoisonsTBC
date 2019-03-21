local addon = LibStub("AceAddon-3.0"):NewAddon("BuyPoisons", "AceEvent-3.0", "AceConsole-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

BuyPoisonsAPI = addon

local playerLevel = UnitLevel('player')
local poisons = {
	['woundPoison'] = {
		[10918] = {['level']=32, ['reagent']={{['id']=2930,['count']=1},{['id']=3372,['count']=1}}},
		[10920] = {['level']=40, ['reagent']={{['id']=2930,['count']=1},{['id']=5173,['count']=1},{['id']=3372,['count']=1}}},
		[10921] = {['level']=48, ['reagent']={{['id']=8923,['count']=1},{['id']=8925,['count']=1}}},
		[10922] = {['level']=56, ['reagent']={{['id']=8923,['count']=1},{['id']=5173,['count']=1},{['id']=8925,['count']=1}}},
		[22055] = {['level']=64, ['reagent']={{['id']=8923,['count']=2},{['id']=8925,['count']=1}}},
	},
	['deadlyPoison'] = {
		[2892] = {['level']=30, ['reagent']={{['id']=5173,['count']=1},{['id']=3372,['count']=1}}},
		[2893] = {['level']=38, ['reagent']={{['id']=5173,['count']=2},{['id']=3372,['count']=1}}},
		[8984] = {['level']=46, ['reagent']={{['id']=5173,['count']=1},{['id']=8925,['count']=1}}},
		[8985] = {['level']=54, ['reagent']={{['id']=5173,['count']=2},{['id']=8925,['count']=1}}},
		[20844] = {['level']=60, ['reagent']={{['id']=5173,['count']=2},{['id']=8925,['count']=1}}},
		[22053] = {['level']=62, ['reagent']={{['id']=2931,['count']=1},{['id']=8925,['count']=1}}},
		[22054] = {['level']=70, ['reagent']={{['id']=2931,['count']=1},{['id']=8925,['count']=1}}},
	},
	['instantPoison'] = {
		[6947] = {['level']=20, ['reagent']={{['id']=2928,['count']=1},{['id']=3372,['count']=1}}},
		[6949] = {['level']=28, ['reagent']={{['id']=2928,['count']=1},{['id']=3372,['count']=1}}},
		[6950] = {['level']=36, ['reagent']={{['id']=8924,['count']=2},{['id']=3372,['count']=1}}},
		[8926] = {['level']=44, ['reagent']={{['id']=8924,['count']=1},{['id']=8925,['count']=1}}},
		[8927] = {['level']=52, ['reagent']={{['id']=8924,['count']=2},{['id']=8925,['count']=1}}},
		[8928] = {['level']=60, ['reagent']={{['id']=8924,['count']=2},{['id']=8925,['count']=1}}},
		[21927] = {['level']=68, ['reagent']={{['id']=2931,['count']=1},{['id']=8925,['count']=1}}},
	},
	['cripplingPoison'] = {
		[3775] = {['level']=20, ['reagent']={{['id']=2930,['count']=1},{['id']=3371,['count']=1}}},
		[3776] = {['level']=50, ['reagent']={{['id']=8923,['count']=1},{['id']=8925,['count']=1}}},
	},
	['mindNumbingPoison'] = {
		[5237] = {['level']=24, ['reagent']={{['id']=2928,['count']=1},{['id']=3371,['count']=1}}},
		[6951] = {['level']=38, ['reagent']={{['id']=8923,['count']=1},{['id']=3372,['count']=1}}},
		[9186] = {['level']=52, ['reagent']={{['id']=8923,['count']=1},{['id']=8925,['count']=1}}},
	},
	['flashPowder'] = {
		[5140] = {['level']=1, ['reagent']={{['id']=5140,['count']=1}}},
	},
}
local poisonID = {}
BuyPoisonsAPI.poisonID = poisonID

local optFrame

local defaults = {
	profile = {
		enabled = true,
		restock = {
			flashPowder = {
				enabled = true,
				count = 20,
			},
			instantPoison = {},
			deadlyPoison = {},
			cripplingPoison = {},
			woundPoison = {},
			mindNumbingPoison = {},
		}
	}
}

local options = {
	type = "group",
	args = {
		enable = {
			name = "Enable",
			desc = "Enables / disables the addon",
			type = "toggle",
			set = function(info,val) addon.db.profile.enabled = val end,
			get = function(info) return addon.db.profile.enabled end
		},
		restock={
			name = "Restock",
			type = "group",
			args={
				flashPowder = {
					name = "Flash Powder",
					type = "group",
					args = {
						enabled = {
							order = 0,
							name = "Enable",
							desc = "Restock flashpowder for you?",
							type = "toggle",
							set = function(info,val) addon.db.profile.restock.flashPowder.enabled = val end,
							get = function(info) return addon.db.profile.restock.flashPowder.enabled end
						},
						count = {
							name = "Amount",
							desc = "Amount of Flash Powder to restock",
							type = "range",
							step = 1,
							min = 1,
							max = 120,
							set = function(info,val) addon.db.profile.restock.flashPowder.count = val end,
							get = function(info) return addon.db.profile.restock.flashPowder.count end
						},
					},
				},
				instantPoison = {
					name = "Instant Poison",
					type = "group",
					args = {
						enabled = {
							order = 0,
							name = "Enable",
							desc = "Restock Instant Poison reagents for you?",
							type = "toggle",
							set = function(info,val) addon.db.profile.restock.instantPoison.enabled = val end,
							get = function(info) return addon.db.profile.restock.instantPoison.enabled end
						},
						count = {
							name = "Amount",
							desc = "Amount of Instant Poison to restock",
							type = "range",
							step = 5,
							min = 5,
							max = 120,
							set = function(info,val) addon.db.profile.restock.instantPoison.count = val end,
							get = function(info) return addon.db.profile.restock.instantPoison.count end
						},
						overstock = {
							disabled = true,
							name = "Overstock",
							desc = "Buy more to not waste vials",
							type = "toggle",
							set = function(info,val) addon.db.profile.restock.instantPoison.overstock = val end,
							get = function(info) return addon.db.profile.restock.instantPoison.overstock end
						},
					},
				},
				deadlyPoison = {
					name = "Deadly Poison",
					type = "group",
					args = {
						enabled = {
							order = 0,
							name = "Enable",
							desc = "Restock Deadly Poison reagents for you?",
							type = "toggle",
							set = function(info,val) addon.db.profile.restock.deadlyPoison.enabled = val end,
							get = function(info) return addon.db.profile.restock.deadlyPoison.enabled end
						},
						count = {
							name = "Amount",
							desc = "Amount of Deadly Poison to restock",
							type = "range",
							step = 5,
							min = 5,
							max = 120,
							set = function(info,val) addon.db.profile.restock.deadlyPoison.count = val end,
							get = function(info) return addon.db.profile.restock.deadlyPoison.count end
						},
						overstock = {
							disabled = true,
							name = "Overstock",
							desc = "Buy more to not waste vials",
							type = "toggle",
							set = function(info,val) addon.db.profile.restock.instantPoison.overstock = val end,
							get = function(info) return addon.db.profile.restock.instantPoison.overstock end
						},
					},
				},
				woundPoison = {
					name = "Wound Poison",
					type = "group",
					args = {
						enabled = {
							order = 0,
							name = "Enable",
							desc = "Restock Wound Poison reagents for you?",
							type = "toggle",
							set = function(info,val) addon.db.profile.restock.woundPoison.enabled = val end,
							get = function(info) return addon.db.profile.restock.woundPoison.enabled end
						},
						count = {
							name = "Amount",
							desc = "Amount of Wound Poison to restock",
							type = "range",
							step = 5,
							min = 5,
							max = 120,
							set = function(info,val) addon.db.profile.restock.woundPoison.count = val end,
							get = function(info) return addon.db.profile.restock.woundPoison.count end
						},
						overstock = {
							disabled = true,
							name = "Overstock",
							desc = "Buy more to not waste vials",
							type = "toggle",
							set = function(info,val) addon.db.profile.restock.instantPoison.overstock = val end,
							get = function(info) return addon.db.profile.restock.instantPoison.overstock end
						},
					},
				},
				cripplingPoison = {
					name = "Crippling Poison",
					type = "group",
					args = {
						enabled = {
							order = 0,
							name = "Enable",
							desc = "Restock Crippling Poison reagents for you?",
							type = "toggle",
							set = function(info,val) addon.db.profile.restock.cripplingPoison.enabled = val end,
							get = function(info) return addon.db.profile.restock.cripplingPoison.enabled end
						},
						count = {
							name = "Amount",
							desc = "Amount of Crippling Poison to restock",
							type = "range",
							step = 5,
							min = 5,
							max = 120,
							set = function(info,val) addon.db.profile.restock.cripplingPoison.count = val end,
							get = function(info) return addon.db.profile.restock.cripplingPoison.count end
						},
						overstock = {
							disabled = true,
							name = "Overstock",
							desc = "Buy more to not waste vials",
							type = "toggle",
							set = function(info,val) addon.db.profile.restock.instantPoison.overstock = val end,
							get = function(info) return addon.db.profile.restock.instantPoison.overstock end
						},
					},
				},
				mindNumbingPoison = {
					name = "Mind-numbing Poison",
					type = "group",
					args = {
						enabled = {
							order = 0,
							name = "Enable",
							desc = "Restock Mind-numbing Poison reagents for you?",
							type = "toggle",
							set = function(info,val) addon.db.profile.restock.mindNumbingPoison.enabled = val end,
							get = function(info) return addon.db.profile.restock.mindNumbingPoison.enabled end
						},
						count = {
							name = "Amount",
							desc = "Amount of Mind-numbing Poison to restock",
							type = "range",
							step = 5,
							min = 5,
							max = 120,
							set = function(info,val) addon.db.profile.restock.mindNumbingPoison.count = val end,
							get = function(info) return addon.db.profile.restock.mindNumbingPoison.count end
						},
						overstock = {
							disabled = true,
							name = "Overstock",
							desc = "Buy more to not waste vials",
							type = "toggle",
							set = function(info,val) addon.db.profile.restock.instantPoison.overstock = val end,
							get = function(info) return addon.db.profile.restock.instantPoison.overstock end
						},
					},
				},
			}
		}
	}
}

AceConfig:RegisterOptionsTable("BuyPoisons", options)

function addon:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("BuyPoisonsDB", defaults, "Default")
	optFrame = AceConfigDialog:AddToBlizOptions("BuyPoisons", "BuyPoisons")
	self:RegisterChatCommand("buypoisons", "OpenConfig")
end

function addon:OpenConfig(input)
	AceConfigDialog:Open("BuyPoisons")
end

function addon:OnEnable()
	self:RegisterEvent('MERCHANT_SHOW')
	self:RegisterEvent('MERCHANT_CLOSED')
	self:PopulatePoisons()
end

function addon:OnDisable()
	self:UnregisterEvent('MERCHANT_SHOW')
	self:UnregisterEvent('MERCHANT_CLOSED')
end

function addon:MERCHANT_SHOW()
	self:CheckMerchantItems()
end

function addon:MERCHANT_CLOSED()

end

function addon:ParseLink(link)
    local _, _, item_id, enchant_id, suffix_id, unique_id, name = strfind(link, '|c%x%x%x%x%x%x%x%x|Hitem:(%d*):(%d*):%d*:%d*:%d*:%d*:(-?%d*):(-?%d*)[:0-9]*|h%[(.-)%]|h|r')
    return tonumber(item_id) or 0, tonumber(suffix_id) or 0, tonumber(unique_id) or 0, tonumber(enchant_id) or 0, name
end

function addon:ToLink(itemID)
	local _, link = GetItemInfo(itemID)
	return link
end

function addon:PopulatePoisons()
	for poisonName, data in pairs(poisons) do
		local lastPoison
		local lastLevel = 1
		for _poisonID, poisonData in pairs(data) do
			if poisonData.level <= playerLevel and poisonData.level >= lastLevel then
				lastPoison = _poisonID
				lastLevel = poisonData.level
			end
		end
		if lastPoison then
			tinsert(poisonID, {['id']=lastPoison, ['name']=poisonName, ['reagent']=data[lastPoison].reagent})
		end
	end
end

function addon:FindPoison(id)
	for key, value in ipairs(poisonID) do
		if value.id == id then
			return value
		end
	end
end

function addon:CheckMerchantItems()
	local buylist = self:ComputeAmount()
	local items = GetMerchantNumItems()
	local id, _, price, quantity, stackCount
	local buyIndex
	local slots = 0
	
	local merchantList = {}
	
	for i = 1, items, 1 do
		if GetMerchantItemLink(i) then
			id = self:ParseLink(GetMerchantItemLink(i))
			_, _, price, quantity = GetMerchantItemInfo(i)
			_, _, _, _, _, _, _, stackCount = GetItemInfo(id)
			buyIndex = self:contains(buylist, id)
			if buyIndex then
				if quantity > 1 then
					buylist[buyIndex].count = buylist[buyIndex].count / quantity
				end
				tinsert(merchantList, {i, buylist[buyIndex].count})
				--print('need to buy '..buylist[buyIndex].count..'x '..self:ToLink(buylist[buyIndex].id))
				slots = slots + (ceil(buylist[buyIndex].count / stackCount))
			end
		end
	end
	
	if slots > 0 and self:EmptySlots() < slots then
		DEFAULT_CHAT_FRAME:AddMessage('Not enough bag space to buy reagent')
		return
	end
	
	for i = 1, #merchantList, 1 do
		BuyMerchantItem(merchantList[i][1], merchantList[i][2])
	end
end

function addon:CountPlayerItem(id)
	local count = 0
	local link
	
	for bagID = 0,4 do
		for slotID = 1, GetContainerNumSlots(bagID) do
			link = GetContainerItemLink(bagID, slotID)
			if link and id == self:ParseLink(link) then
				local _, itemCount = GetContainerItemInfo(bagID, slotID)
				if (itemCount) then
					count = count + itemCount
				end
			end
		end
	end
	
	return count
end

function addon:EmptySlots()
	local count = 0
	
	for bagID = 0,4 do
		for slotID = 1, GetContainerNumSlots(bagID) do
			link = GetContainerItemLink(bagID, slotID)
			if not link then
				count = count + 1
			end
		end
	end
	
	return count
end


function addon:contains(t, id)
	for i = 1, #t, 1 do
		if t[i].id == id then
			return i
		end
	end
end

function addon:ComputeAmount()
	local buylist = {}
	local buyIndex
	local have = {}
	
	for index, value in ipairs(poisonID) do
		local haveCount, desiredCount, moreCount
		if addon.db.profile.restock[value.name].enabled then
			haveCount = self:CountPlayerItem(value.id)
			desiredCount = addon.db.profile.restock[value.name].count
			moreCount = (desiredCount-haveCount)
			
			-- ignore flash powder
			if value.id ~= 5140 and (moreCount % 5) ~= 0 then
				moreCount = moreCount - (moreCount % 5)
			end
				
			if moreCount > 0 then
				--print('we want '..desiredCount..' '..value.name..', need '..moreCount..' more')
				
				for k,v in ipairs(value.reagent) do
					buyIndex = self:contains(buylist, v.id)
					if buyIndex then
						buylist[buyIndex].count = buylist[buyIndex].count + (v.count * moreCount)
					else
						tinsert(buylist, {['id']=v.id, ['count']=(v.count * moreCount)})
					end
				end
				
				-- check if we have any reagents already
				for i = #buylist, 1, -1 do
					if not have[buylist[i].id] then
						have[buylist[i].id] = self:CountPlayerItem(buylist[i].id)
					end
					haveCount = have[buylist[i].id]
					if haveCount > 0 then
						if buylist[i].id == value.id then -- flash powder is a reagent itself
							buylist[i].count = (desiredCount - haveCount)
						else
							buylist[i].count = (buylist[i].count - haveCount)
						end
						if buylist[i].count <= 0 then
							have[buylist[i].id] = abs(buylist[i].count)
							tremove(buylist, i)
						else
							have[buylist[i].id] = 0
						end
					end
				end

			end
		end
	end
	
	return buylist
end
