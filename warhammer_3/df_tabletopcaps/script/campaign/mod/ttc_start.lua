---@param t string
local out = function(t)
  ModLog("DRUNKFLAMINGO: "..tostring(t).." (ttc_start.lua)")
end

local mod = core:get_static_object("tabletopcaps")

local mct = core:get_static_object("mod_configuration_tool")

function ttc_mct_init()
  core:add_listener(
    "ttc_MctFinalized",
    "MCTFinalized",
    true,
    function (context)
      local ttc_settings = mct:get_mod_by_key("ttc")
      local enable_ttc = ttc_settings:get_option_by_key("a_enable")
      if enable_ttc:get_finalized_setting() == true then
        --set up the special points
        local special_point_setting = ttc_settings:get_option_by_key("b_special_points")
        local special_points = special_point_setting:get_finalized_setting()
        local rare_point_setting = ttc_settings:get_option_by_key("b_rare_points")
        local rare_points = rare_point_setting:get_finalized_setting()
        cm:add_first_tick_callback(function()
          local humans = cm:get_human_factions()
          for i = 1, #humans do
            --remove any effect bundle we have
            cm:remove_effect_bundle("ttc_mct_settings", humans[i])
            --construct a new bundle with the current settings                
            local bundle = cm:create_new_custom_effect_bundle("ttc_mct_settings")
            if special_points then
              bundle:add_effect("ttc_capacity_special", "faction_to_faction_own_unseen", special_points)
            end
            if rare_points then
              bundle:add_effect("ttc_capacity_rare", "faction_to_faction_own_unseen", rare_points)
            end
          end
        end)
      end
    end,
    true)

  core:add_listener(
    "ttc_MctInitialized",
    "MctInitialized",
    true,
    function(context)
        local ttc_settings = mct:get_mod_by_key("ttc")
        local enable_ttc = ttc_settings:get_option_by_key("a_enable")
        enable_ttc:set_read_only(true)

        if enable_ttc:get_finalized_setting() == true then
            --enable the mod
            cm:add_first_tick_callback(function ()
              core:trigger_event("ModScriptEventTabletopCapsSetup")
              mod.finish_setup()
              mod.add_listeners()
              mod.add_ui_meter_listeners()
              mod.add_exchange_listeners() 
              mod.unit_browser_listeners()
            end)


            --check if AI enforcement is enabled
            local enforce_for_ai = ttc_settings:get_option_by_key("c_ai")
            enforce_for_ai:set_read_only(true)
            if enforce_for_ai then
              cm:add_first_tick_callback(function ()
                mod.add_ai_listeners()
              end)
            end

            --set up the special points
            local special_point_setting = ttc_settings:get_option_by_key("b_special_points")
            local special_points = special_point_setting:get_finalized_setting()
            local rare_point_setting = ttc_settings:get_option_by_key("b_rare_points")
            local rare_points = rare_point_setting:get_finalized_setting()
            cm:add_first_tick_callback(function()
              local humans = cm:get_human_factions()
              for i = 1, #humans do
                --remove any effect bundle we have
                cm:remove_effect_bundle("ttc_mct_settings", humans[i])
                --construct a new bundle with the current settings                
                local bundle = cm:create_new_custom_effect_bundle("ttc_mct_settings")
                if special_points then
                  bundle:add_effect("ttc_capacity_special", "faction_to_faction_own_unseen", special_points)
                end
                if rare_points then
                  bundle:add_effect("ttc_capacity_rare", "faction_to_faction_own_unseen", rare_points)
                end
              end
            end)
        else
            --do nothing
            out("TTC disabled from MCT")
        end
    end,
    true)
end


function ttc_start()
  if mct then
    return
  end
  core:trigger_event("ModScriptEventTabletopCapsSetup")
  mod.finish_setup()

  mod.add_listeners()
  mod.add_ai_listeners()
  mod.add_ui_meter_listeners()
  mod.add_exchange_listeners() 
  mod.unit_browser_listeners()
  return mod
end

if mct then
  ttc_mct_init()
end

