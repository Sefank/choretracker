local _, Addon = ...
local L = Addon.L


Addon.data.timers.warWithin = {
    key = 'warWithin',
    name = EXPANSION_NAME10,
    timers = {
        {
            key = 'nightfallScenario',
            minimumLevel = 70,
            interval = 60 * 60,
            duration = 10 * 60,
            offset = 0,
        },
        {
            key = 'surgePricing',
            minimumLevel = 80,
            interval = 60 * 60,
            duration = 10 * 60,
            offset = 30 * 60,
        },
        {
            key = 'beledarsShadow',
            minimumLevel = 70,
            interval = 3 * 60 * 60,
            duration = 30 * 60,
            offset = 60 * 60,
        },
        {
            key = 'theaterTroupe',
            minimumLevel = 70,
            interval = 60 * 60,
            duration = 10 * 60,
            offset = 60, -- starts at xx:01
        },
    },
}
