local _, Addon = ...


Addon.data.professions.enchanting = {
    skillLineId = 333,
    texture = GetSpellTexture(7411),
    expansions = {
        -- Dragon Isles
        dragonflight = {
            name = EXPANSION_NAME9,
            skillLineId = 2825,
            drops = {
                {
                    key = 'mob',
                    entries = {
                        { quest=70514, item=198967, desc='Arcane' }, -- Primordial Aether
                        { quest=70515, item=198968, desc='Primalist' }, -- Primalist Charm
                    },
                },
                {
                    key = 'treasure',
                    entries = {
                        { quest=66377, item=193900 }, -- Prismatic Focusing Shard
                        { quest=66378, item=193901 }, -- Primal Dust
                    },
                },
                {
                    key = 'forbiddenReach',
                    defaultEnabled = false,
                    entries = {
                        { quest=74927, item=204224, level=70, desc='Manathema' }, -- Speck of Arcane Awareness
                    },
                },
            },
            quests = {
                {
                    key = 'craft',
                    entries = {
                        { quest=72155 }, -- Spread the Enchantment
                        { quest=72172 }, -- Essence, Shards, and Chromatic Dust
                        { quest=72173 }, -- Braced for Enchantment
                        { quest=72175 }, -- A Secpt-acular Time
                    },
                },
                {
                    key = 'gather',
                    entries = {
                        { quest=66884 }, -- Fireproof Gear
                        { quest=66900 }, -- Enchanted Relics
                        { quest=66935 }, -- Crystal Quill Pens
                        { quest=72423 }, -- Weathering the Storm
                        { quest=75150, level=70 }, -- Incandescence [ZC]
                        { quest=75865, level=70 }, -- Relic Rustler [ZC]
                    },
                },
                {
                    key = 'treatise',
                    entries = {
                        { quest=74110, item=184702 }, -- Draconic Treatise on Enchanting
                    },
                },
            },
        },
    },
}