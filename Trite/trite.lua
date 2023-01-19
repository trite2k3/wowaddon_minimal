-----------------------------
-- Trite's Addon
--
-- Hide gryphon artwork + some backgrounds.
-- Autosell gray items to vendor.
-- Autorepair gear in vendor.
-- Modified CritCommander which triggers on heals. With anime "wow" sound or orig.
--
-- /Trite's Addon
-----------------------------



-----------------------------
-- Toggles
-----------------------------
-- hide ui stuff (gryphons, bgs)
MainMenuBarLeftEndCap:Hide()
MainMenuBarRightEndCap:Hide()
-- hide xp bar
MainMenuMaxLevelBar0:Hide()
MainMenuMaxLevelBar1:Hide()
MainMenuMaxLevelBar2:Hide()
MainMenuMaxLevelBar3:Hide()
--
MainMenuBarTexture0:Hide()
MainMenuBarTexture1:Hide()
MainMenuBarTexture2:Hide()
MainMenuBarTexture3:Hide()
-- /hide ui stuff (gryphons, bgs)
-----------------------------
-- /Toggles
-----------------------------



-----------------------------
-- Variables
-----------------------------
-- ez
local ADDON_NAME = ...;
-- /ez
-- sellgray
local A, L = ...
-- /sellgray
-- critcommander player var
local playerGUID = UnitGUID("player")
-- /critcommander player var
-----------------------------
-- /Variables
-----------------------------



-----------------------------
-- Functions
-----------------------------

-- sellgray sell loop
local stop = true
local list = {}

local function sellGray()
    if stop then
        return
    end
    for bag=0,4 do
        for slot=0,C_Container.GetContainerNumSlots(bag) do
            if stop then 
                return
            end
            local link = C_Container.GetContainerItemLink(bag, slot)
            if link and select(3, GetItemInfo(link)) == 0 and not list["b"..bag.."s"..slot] then
                ChatFrame1:AddMessage("Selling: " .. link)
                list["b"..bag.."s"..slot] = true
                C_Container.UseContainerItem(bag, slot)
                C_Timer.After(0.2, sellGray)
                return
            end
        end
    end
end
-- /sellgray sell loop

-- autorepair repair loop
local function autoRepair()
    if CanMerchantRepair() then
        local cost = GetRepairAllCost()
        if GetMoney() > cost then
            RepairAllItems()
            ChatFrame1:AddMessage(("Repair:  %dg %ds %dc"):format(cost / 100 / 100, (cost / 100) % 100, cost % 100))
        else
            ChatFrame1:AddMessage(("Cant afford repair: %dg %ds %dc"):format(cost / 100 / 100, (cost / 100) % 100, cost % 100))
        end
    end
end
-- /autorepair repair loop

-- critCommanderHeal soundfunc
function playSound()
	PlaySoundFile("Interface\\AddOns\\Trite\\Sounds\\wow1.mp3", "Dialog")
end
-- /critCommanderHeal soundfunc

-- critCommanderHeal
function critCommanderHeal(event, ...)
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
    local spellId, spellName, spellSchool
    local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand
    
    if subevent == "SWING_DAMAGE" then
        amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, ...)
    elseif subevent == "SPELL_DAMAGE" or subevent == "RANGE_DAMAGE" then
        spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, ...)
    elseif subevent == "SPELL_HEAL" then
        spellId, spellName, spellSchool, amount, overhealing, absorbed, critical = select(12, ...)
    end

    if critical and sourceGUID == playerGUID then
        C_Timer.After(.2, playSound)
        -- for the orig. "wow" sound you need 0.5 delay
        -- C_Timer.After(.5, playSound)
    end
end
-- /critCommanderHeal

-- eventHandler function
local function OnEvent(self, event)
    -- autorepair and autosell eventhandling
    if event == "MERCHANT_SHOW" then
        stop = false
        wipe(list)
        autoRepair()
        sellGray()
    elseif event == "MERCHANT_CLOSED" then
        stop = true
    -- /autorepair and autosell eventhandling
    -- critCommanderHeal eventhandling
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        critCommanderHeal(event, CombatLogGetCurrentEventInfo())
    -- /critCommanderHeal eventhandling
    end
end
-- /eventHandler function
-----------------------------
-- /Functions
-----------------------------



-----------------------------
-- Init
-----------------------------
-- eventHandler
-- default frame
local eventHandler = CreateFrame("Frame")
-- /default frame

-- sellgray and autorepair registerevents
eventHandler:RegisterEvent("MERCHANT_SHOW")
eventHandler:RegisterEvent("MERCHANT_CLOSED")
-- /sellgray and autorepair registerevents

-- critCommanderHeal registerevents
eventHandler:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
-- /critCommanderHeal registerevents

-- default eventHandler function
eventHandler:SetScript("OnEvent", OnEvent)
-- /default eventHandler function
-- /eventHandler
-----------------------------
-- /Init
-----------------------------
