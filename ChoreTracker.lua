local addonName, addonTable = ...
local Addon = LibStub('AceAddon-3.0'):NewAddon(
    addonTable,
    addonName,
    'AceBucket-3.0',
    'AceConsole-3.0',
    'AceEvent-3.0'
)

Addon:SetDefaultModuleLibraries('AceBucket-3.0', 'AceEvent-3.0')

Addon.data = {
    chores = {},
    delves = {},
    timers = {},
}
Addon.L = LibStub('AceLocale-3.0'):GetLocale(addonName)

local ADB = LibStub('AceDB-3.0')
local LSM = LibStub('LibSharedMedia-3.0')
local LDB = LibStub('LibDataBroker-1.1')
local DBIcon = LibStub('LibDBIcon-1.0')

local DEFAULT_SECTION_ORDER = {
    'timers',
    'anniversary',
    'events',
    'hallowfallFishingDerby',
    'delves',
    'warWithin',
    'professions',
    'pvp',
    'dragonflight',
}

local defaultDb = {
    char = {
        skillLines = {},
    },
    global = {
        questWeeks = {},
    },
    profile = {
        modules = {
            ['**'] = {
                enabled = true,
            }
        },
        minimap = {
            hide = false,
        },
        general = {
            appearance = {
                backgroundColor = { r = 0, g = 0, b = 0, a = 0.7 },
                borderColor = { r = 63 / 255, g = 63 / 255, b = 63 / 255, a = 0.7 },
                strata = 'LOW',
            },
            automation = {
                acceptQuests = false,
            },
            display = {
                awakenedTimers = false,
                showAnniversaryAccount = false,
                showCompleted = false,
                showCompletedSections = true,
                showObjectives = 'ALL',
                statusIcons = true,
            },
            order = {
                sections = DEFAULT_SECTION_ORDER,
            },
            text = {
                font = LSM:GetDefault('font'),
                fontSize = 12,
                fontStyle = '',
            },
        },
        delves = {
            bountiful = {
                onlyWithKeys = false,
                showDelves = true,
                showKeys = true,
            },
        },
        window = {
            height = nil,
            width = nil,
            left = nil,
            top = nil,
            locked = false,
            minimized = false,
        },
        desiredShown = true,
        seenAutoAcceptMessage = false,
        chores = {},
        timers = {},
    }
}

function Addon:ToggleMinimapIcon(show)
    if show then
        DBIcon:Show(addonName)
    else
        DBIcon:Hide(addonName)
    end
end

-- LibDataBroker plugin
local CT_LDB = LDB:NewDataObject(addonName, {
    type = "data source",
    text = "?/?",
    icon = "Interface\\AddOns\\ChoreTracker\\Assets\\icon.tga",
    OnTooltipShow = function(tooltip)
        tooltip:SetText("ChoreTracker")
        tooltip:AddLine(Addon.L['tooltip:toggleWindow'], 1, 1, 1)
        tooltip:AddLine(Addon.L['tooltip:showOptions'], 1, 1, 1)
        tooltip:Show()
    end,
    OnClick = function(_, button)
        if(button=="LeftButton")then
            Addon:GetModule('Display'):ToggleShown(true)
        else
            Settings.OpenToCategory(addonName)
        end
    end,
})

function Addon:UpdateLdb()
    local completed = 0
    local total = 0
    local displayModule = Addon:GetModule('Display')
    local sections = displayModule:GetSections()
    for _, section in ipairs(sections) do
        completed = completed + section.completed
        total = total + section.total
    end

    local prefix = displayModule:GetPercentColor(completed, total)
    CT_LDB.text = prefix .. completed ..'|r|cFF888888/|r' .. prefix .. total .. '|r'
end

function Addon:OnInitialize()
    for sectionKey, sectionData in pairs(self.data.chores) do
        defaultDb.profile.chores[sectionKey] = {}
        
        for _, catData in ipairs(sectionData.categories or {}) do
            defaultDb.profile.chores[sectionKey][catData.key] = {}

            local defaultEnabled = sectionData.defaultEnabled ~= false and
                catData.defaultEnabled ~= false

            if catData.drops ~= nil then
                local drops = {}
                for _, dropData in ipairs(catData.drops) do
                    drops[dropData.key] = dropData.defaultEnabled ~= false and defaultEnabled
                end
                defaultDb.profile.chores[sectionKey][catData.key].drops = drops
            end

            if catData.dungeons ~= nil then
                local dungeons = {}
                for _, dungeonData in ipairs(catData.dungeons) do
                    dungeons[dungeonData.key] = dungeonData.defaultEnabled ~= false and defaultEnabled
                end
                defaultDb.profile.chores[sectionKey][catData.key].dungeons = dungeons
            end

            if catData.quests ~= nil then
                local quests = {}
                for _, questData in ipairs(catData.quests) do
                    if quests[questData.key] == nil then
                        quests[questData.key] = questData.defaultEnabled ~= false and defaultEnabled
                    end
                end
                defaultDb.profile.chores[sectionKey][catData.key].quests = quests
            end
        end
    end

    for _, category in pairs(self.data.timers) do
        defaultDb.profile.timers[category.key] = {}
        for _, timer in ipairs(category.timers) do
            defaultDb.profile.timers[category.key][timer.key] = category.key == 'warWithin'
        end
    end

    -- DevTools_Dump(defaultDb)

    self:RegisterChatCommand('chores', 'SlashCommand')
    self:RegisterChatCommand('choretracker', 'SlashCommand')

    self.db = ADB:New('ChoreTrackerDB', defaultDb, true) -- default global profile

    -- Fix section order
    local ughSections = {}
    local seenSections = {}
    for _, section in ipairs(self.db.profile.general.order.sections) do
        if section ~= nil and not seenSections[section] then
            seenSections[section] = true
            tinsert(ughSections, section)
        end
    end

    for _, section in ipairs(DEFAULT_SECTION_ORDER) do
        if not seenSections[section] then
            tinsert(ughSections, 1, section)
        end
    end

    self.db.profile.general.order.sections = ughSections

    -- Clean up old weekly data
    local cutoff = time() - (14 * 24 * 60 * 60)
    for weekEnd, _ in pairs(self.db.global.questWeeks) do
        if weekEnd < cutoff then
            self.db.global.questWeeks[weekEnd] = nil
        end
    end

    -- register events, etc
    self:RegisterEvent('PLAYER_ENTERING_WORLD')

    -- register minimap icon
    DBIcon:Register(addonName, CT_LDB, self.db.profile.minimap)

    -- update LDB data
    self:RegisterBucketMessage({ 'ChoreTracker_Data_Updated' }, 2, 'UpdateLdb')
end

function Addon:PLAYER_ENTERING_WORLD()
    for _, module in Addon:IterateModules() do
        if module.OnEnteringWorld ~= nil then
            module:OnEnteringWorld()
        end
    end

    if not Addon.db.global.seenAutoAcceptMessage then
        C_Timer.After(5, function() print(Addon.L['auto_accept_message']) end)
        Addon.db.global.seenAutoAcceptMessage = true
    end
end

function Addon:TableKeys(tbl)
    local keys = {}
    for key in pairs(tbl) do
        keys[#keys + 1] = key
    end
    return keys
end

function Addon:SlashCommand(command, editbox)
    if command == 'show' then
        local displayModule = self:GetModule('Display')
        displayModule:SetDesiredShown(true)
    
    elseif command == 'hide' then
        local displayModule = self:GetModule('Display')
        displayModule:SetDesiredShown(false)
    
    elseif command == 'toggle' then
        local displayModule = self:GetModule('Display')
        displayModule:ToggleShown(true)

    elseif command == '' or command == nil then
        Settings.OpenToCategory(addonName)

    else
        print('ChoreTracker: unknown command')
        print()
        print('  hide: hide the window')
        print('  show: show the window')
        print('  toggle: toggle the window')

    end
end

function ChoreTracker_OnAddonCompartmentClick()
    Addon:SlashCommand('toggle', _)
end
