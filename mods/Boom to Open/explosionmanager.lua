local __slot_mask = World:make_slot_mask(1, 2, 8, 11, 12, 14, 17, 18, 21, 22, 25, 26, 33, 34, 35, 39)

Hooks:PostHook(ExplosionManager, "detect_and_give_dmg", Idstring("Boom to Open:ExplosionManager:detect_and_give_dmg"):key(), function(self, params)
	if managers.player:local_player() and type(params) == "table" and params.hit_pos then
		local hit_pos = params.hit_pos
		local dmg = params.damage or 0
		if hit_pos and dmg then
			local __fix_from_dmg = math.clamp(dmg/600, 0.00001, 1)
			local units = World:find_units("sphere", hit_pos, 300*__fix_from_dmg, __slot_mask, "ray_type", "body bullet lock")
			if type(units) == "table" and units[1] then
				for id, hit_unit in pairs(units) do
					if hit_unit:damage() and type(hit_unit:num_bodies()) == "number" and hit_unit.interaction and hit_unit:interaction() and not hit_unit:interaction():disabled() and hit_unit:interaction():active() then
						for i = 0, hit_unit:num_bodies() - 1 do
							local body = hit_unit:body(i)
							if body:extension() and body:extension().damage and body:extension().damage:endurance_exists("lock") then
								--[[
								if hit_unit:damage():has_sequence("state_spawn_nothing") then
									if math.random() > 0.3 then
										hit_unit:damage():run_sequence_simple("state_spawn_nothing")
									end
								end
								]]
								body:extension().damage:damage_lock(
									managers.player:local_player(), 
									math.UP, 
									hit_unit:position(), 
									hit_unit:rotation():y(), 
									1000*__fix_from_dmg
								)
								if hit_unit:id() ~= -1 then
									managers.network:session():send_to_peers_synched("sync_body_damage_lock", body, 1000*__fix_from_dmg)
								end
							end
						end
					end
				end
			end
		end
	end
end)