Xeer = {
	Version = 0.00001,
	Branch = 'BETA',
	Interface = {
		addonColor = 'ADFF2F',
		Logo = NeP.Interface.Logo -- Temp until i get a logo
	},
}

-- Core version check
if NeP.Info.Version >= 70.8 then
	NeP.Core.Print('Loaded |T'..Xeer.Interface.Logo..':10:10|t[|cff'..Xeer.Interface.addonColor..'Xeer|r] Combat-Routines v:'..Xeer.Version)
else
	NeP.Core.Print('Failed to load Xeer Combat Routines.\nYour Core is outdated.')
	return
end

local Parse = NeP.DSL.Parse
local Fetch = NeP.Interface.fetchKey

-- Temp Hack
function Xeer.Splash()
	NeP.Interface.CreateToggle(
		'autotarget', 
		'Interface\\Icons\\ability_hunter_snipershot', 
		'Auto Target', 
		'Automatically target the nearest enemy when target dies or does not exist')	
end

function Xeer.ClassSetting(key)
	local name = '|cff'..NeP.Core.classColor('player')..'Class Settings'
	NeP.Interface.CreateSetting(name, function() NeP.Interface.ShowGUI(key) end)
end

function Xeer.dynEval(condition, spell)
	return Parse(condition, spell or '')
end

NeP.library.register('Xeer', {

	Targeting = function()
		local exists = UnitExists('target')
		local hp = UnitHealth('target')
		if exists == false or (exists == true and hp < 1) then
			for i=1,#NeP.OM.unitEnemie do
				local Obj = NeP.OM.unitEnemie[i]	
				if Obj.distance <= 10 then
					RunMacroText('/tar ' .. Obj.key)
					return true
				end
			end
		end
	end,

	AutoTaunt = function()
		local _,_,class = UnitClass('player')
		if class == 1 then 
			--Warrior		
			spell = 'Taunt'
		elseif class == 2 then 
			--Paladin
			spell = 'Hand of Reckoning'
		elseif class == 6 then 
			--Death Knight
			spell = 'Dark Command'
		elseif class == 10 then 
			--Monk
			spell = 'Provoke'
		elseif class == 11 then 
			--Druid
			spell = 'Growl'
		elseif class == 12 then
			--Demon Hunter
			spell = 'Torment'
		else
		return false
		end
		local spellCooldown = NeP.DSL.Conditions['spell.cooldown']('player', spell)
		if spellCooldown > 0 then
			return false
		end
		for i=1,#NeP.OM.unitEnemie do
			local Obj = NeP.OM.unitEnemie[i]	
			local Threat = UnitThreatSituation('player', Obj.key)
			if Threat ~= nil and Threat >= 0 and Threat < 3 and Obj.distance <= 30 then
				NeP.Engine.Cast_Queue(spell, Obj.key)
				return true
			end
		end
	end
})	

NeP.DSL.RegisterConditon('ragedeficit', function(target, spell)
	local max = UnitPowerMax(target, SPELL_POWER_RAGE)
	local curr = UnitPower(target, SPELL_POWER_RAGE)
	return (max - curr)
end)

NeP.DSL.RegisterConditon('equipped', function(target, item)
	if IsEquippedItem(item) == true then return true else return false end
end)

NeP.DSL.RegisterConditon('execute_time', function(target, spell)
	local GCD = math.floor((1.5 / ((GetHaste() / 100) + 1)) * 10^3 ) / 10^3	
	local name, rank, icon, cast_time, min_range, max_range = GetSpellInfo(spell)
		if cast_time < GCD then
			return cast_time
		else
			return GCD
		end
end)
