------------------------------------------------------------------------------------------------
-- CHARACTER TOOLS NPC
------------------------------------------------------------------------------------------------

local EnableModule = true
local AnnounceModule = true   -- Announce module on player login ?
local UnitEntry = 601077

------------------------------------------------------------------------------------------------
-- END CONFIG
------------------------------------------------------------------------------------------------

if (not EnableModule) then return end
local FILE_NAME = string.match(debug.getinfo(1,'S').source, "[^/\\]*.lua$")
local AT_LOGIN_NONE              = 0x000
local AT_LOGIN_RENAME            = 0x001
local AT_LOGIN_CUSTOMIZE         = 0x008
local AT_LOGIN_CHANGE_FACTION    = 0x040
local AT_LOGIN_CHANGE_RACE       = 0x080

NPCCharacterTools = {guids = {}}

local function OnGossipHello(event, player, unit) 
    player:GossipMenuAddItem(4, "|TInterface/Icons/Ability_Paladin_BeaconofLight:50:50|tChange My Race", 1, 1, false, "Are you sure you want to change your race?")
    player:GossipMenuAddItem(4, "|TInterface/Icons/INV_BannerPVP_01:50:50|tChange My Faction", 1, 2, false, "Are you sure you want to change your faction?")
    player:GossipMenuAddItem(4, "|TInterface/Icons/Achievement_BG_returnXflags_def_WSG:50:50|tChange My Appearance", 1, 3, false, "Are you sure you want to change your appearance?")
    player:GossipMenuAddItem(4, "|TInterface/Icons/INV_Inscription_Scroll:50:50|tChange My Name", 1, 4, false, "Are you sure you want to change your name?")
    if (player:HasAtLoginFlag(AT_LOGIN_RENAME) or player:HasAtLoginFlag(AT_LOGIN_CUSTOMIZE) or player:HasAtLoginFlag(AT_LOGIN_CHANGE_FACTION) or player:HasAtLoginFlag(AT_LOGIN_CHANGE_RACE)) then
		player:GossipMenuAddItem(4, "|TInterface/Icons/Ability_GhoulFrenzy:50:50|tCancel all customizations", 1, 5, false, "Are you sure you want to cancel all customizations?\nYou will be disconnected.")
   	end
    player:GossipSendMenu(1, unit)
    return true
end    

local function OnGossipSelect(event, player, unit, sender, intid, code)
    if (intid == 1) then
        player:SetAtLoginFlag(AT_LOGIN_CHANGE_RACE);
        player:SendBroadcastMessage("Please log out for race change.");
    elseif (intid == 2) then
        player:SetAtLoginFlag(AT_LOGIN_CHANGE_FACTION);
        player:SendBroadcastMessage("Please log out for faction change.");
    elseif (intid == 3) then
        player:SetAtLoginFlag(AT_LOGIN_CUSTOMIZE);
        player:SendBroadcastMessage("Please log out for character customize.");
    elseif (intid == 4) then
        player:SetAtLoginFlag(AT_LOGIN_RENAME);
        player:SendBroadcastMessage("Please log out for name change.");
    elseif (intid == 5) then
    	NPCCharacterTools.guids[player:GetGUIDLow()] = 1
    	player:KickPlayer()
   	else
   		return true
    end
    
    player:GossipComplete()
    return true
end

local function OnPlayerLogout(event, player)
	local pGUID = player:GetGUIDLow()
	if (NPCCharacterTools.guids[pGUID]) then
		NPCCharacterTools.guids[pGUID] = nil
		CharDBExecute("UPDATE characters SET at_login = 0 WHERE guid = "..pGUID..";")
		PrintInfo("["..FILE_NAME.."] SQL: \"UPDATE characters SET at_login = 0 WHERE guid = "..pGUID..";\"")
	end
end

local function moduleAnnounce(event, player)
	player:SendBroadcastMessage("This server is running the |cff4CFF00CharacterToolsNPC|r module.")
end

RegisterCreatureGossipEvent(UnitEntry, 1, OnGossipHello)
RegisterCreatureGossipEvent(UnitEntry, 2, OnGossipSelect)
RegisterPlayerEvent(4, OnPlayerLogout)
if (AnnounceModule) then
	RegisterPlayerEvent(3, moduleAnnounce)   -- PLAYER_EVENT_ON_LOGIN
end

PrintInfo("["..FILE_NAME.."] CharacterToolsNPC module loaded. NPC ID: "..UnitEntry)
