my_blindfold = {}

local blindfolded_players = {}
local hud_ids = {}

local storage = minetest.get_mod_storage()

-- load blindfolded players from storage
local stored = storage:get_string("blindfolded_players")
if stored ~= "" then
    blindfolded_players = minetest.deserialize(stored) or {}
end

local function save_blindfolds()
    storage:set_string("blindfolded_players", minetest.serialize(blindfolded_players))
end

-- blindfold item
minetest.register_tool("my_blindfold:blindfold", {
    description = "Blindfold Strip",
    inventory_image = "blindfold_strip.png",
    stack_max = 1,

    on_use = function(itemstack, user, pointed_thing)
        if pointed_thing and pointed_thing.type == "object" then
            local target = pointed_thing.ref
            if not target:is_player() then return itemstack end

            local tname = target:get_player_name()
            local uname = user:get_player_name()

            if vector.distance(user:get_pos(), target:get_pos()) > 1 then
                minetest.chat_send_player(uname, "Too far to blindfold!")
                return itemstack
            end

            -- REMOVE blindfold
            if blindfolded_players[tname] then
                if hud_ids[tname] then
                    target:hud_remove(hud_ids[tname])
                end
                blindfolded_players[tname] = nil
                hud_ids[tname] = nil
                save_blindfolds()
                minetest.chat_send_player(uname, tname .. " is no longer blindfolded")
            else
                -- ADD blindfold
                hud_ids[tname] = target:hud_add({
                    hud_elem_type = "image",
                    position = {x = 0.5, y = 0.5},
                    scale = {x = -100, y = -100},
                    text = "black.png",
                    alignment = {x = 0, y = 0},
                })
                blindfolded_players[tname] = true
                save_blindfolds()
                minetest.chat_send_player(uname, tname .. " is now blindfolded")
            end
        end
        return itemstack
    end,
})

-- reapply blindfold on join
minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()

    if blindfolded_players[name] then
        hud_ids[name] = player:hud_add({
            hud_elem_type = "image",
            position = {x = 0.5, y = 0.5},
            scale = {x = -100, y = -100},
            text = "black.png",
            alignment = {x = 0, y = 0},
        })
        minetest.chat_send_player(name, "You are still blindfolded.")
    end
end)

-- craft recipe: all black wool
minetest.register_craft({
    output = "my_blindfold:blindfold",
    recipe = {
        {"wool:black", "wool:black", "wool:black"},
    }
})
