if not Network:is_server()  then
	return
end

_G.Safe4Stealth = _G.Safe4Stealth or {}

local WeaponCheck = {}

Hooks:PreHook(HuskPlayerInventory, "synch_equipped_weapon", "Safe2Stealth_WeaponCheak", function(self, weap_index, blueprint_string)
	local peer = managers.network:session():peer_by_unit(self._unit)
	local mask_off = false
	if self._unit:movement() and tostring(self._unit:movement()._current_state_name) == "mask_off" then
		mask_off = true
	end
	if peer and not mask_off and managers.groupai:state():whisper_mode() then
		local blueprint = nil
		local silencer = -1
		local part_name = ''
		local weapon_id = ''
		local key = self._unit:key()
		WeaponCheck[key] = WeaponCheck[key] or {}
		local factory_id = ''
		factory_id = tostring(self._get_weapon_name_from_sync_index(weap_index) or '')
		local n_factory_id = tostring(factory_id):gsub('_npc', '')
		weapon_id = tostring(managers.weapon_factory:get_weapon_id_by_factory_id(n_factory_id) or '')
		part_name = tostring(managers.weapon_factory:get_weapon_name_by_factory_id(n_factory_id) or '')

		blueprint = blueprint_string and blueprint_string ~= "" and managers.weapon_factory:unpack_blueprint_from_string(factory_id, blueprint_string) or managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)
		if tweak_data.weapon[weapon_id] then
			local wp = tweak_data.weapon[weapon_id]
			if table.contains(wp.categories, "bow") then
				silencer = 2
			elseif weapon_id == "wpn_fps_fla_mk2" then
				silencer = 4
			end
		end
		local bkey = Idstring(tostring(json.encode({blueprint = blueprint}))):key()
		if blueprint and type(blueprint) == "table" and blueprint[1] and tweak_data.blackmarket.projectiles and tweak_data.weapon.factory and tweak_data.weapon.factory.parts then
			for _, _fid in pairs(blueprint) do
				if tweak_data.weapon.factory.parts[_fid] then
					local fp = tweak_data.weapon.factory.parts[_fid]
					local fp_name = managers.localization:text(tostring(fp.name_id))
					if fp_name:find("ERROR") then
						fp_name = _fid
					end
					if fp.custom_stats then
						if fp.custom_stats.bullet_class == "FlameBulletBase" or fp.custom_stats.bullet_class == "PoisonBulletBase" or fp.custom_stats.bullet_class == "InstantExplosiveBulletBase" then
							silencer = -2
							part_name = fp_name
							break
						end
						if fp.custom_stats.launcher_grenade then
							local pid = fp.custom_stats.launcher_grenade
							if (tweak_data.blackmarket.projectiles[pid] and (tweak_data.blackmarket.projectiles[pid].is_explosive or tweak_data.blackmarket.projectiles[pid].is_a_grenade)) or (tweak_data.projectiles[pid] and (tweak_data.projectiles[pid].bullet_class == "PoisonBulletBase" or tweak_data.projectiles[pid].bullet_class == "InstantExplosiveBulletBase" or tweak_data.projectiles[pid].bullet_class == "ProjectilesPoisonBulletBase")) then
								silencer = -2
								part_name = fp_name
								break
							end
						end
					end
					if (fp.perks and fp.perks[1] == "silencer") or (fp.sound_switch and fp.sound_switch.suppressed) then
						silencer = 1
						break
					end
					if _fid == "wpn_fps_saw_body_silent" then
						silencer = 3
						break
					end
				end
			end
		end
		if silencer < 0 then
			local identifier = "cheater_banned_" .. tostring(peer:id())
			if silencer == -1 then
				managers.chat:feed_system_message(1, peer:name() .. " has been marked because using non-silenced weapon ("..part_name..")")
			elseif silencer == -2 then
				managers.chat:feed_system_message(1, peer:name() .. " has been marked because using loud noise weapon ("..part_name..")")
			end
			Safe4Stealth:Kick_Peer("weapon", peer)
		elseif not WeaponCheck[key][bkey] then
			if silencer > 1 then
				WeaponCheck[key][bkey] = true			
			end
			if silencer == 2 then
				managers.chat:feed_system_message(1, peer:name() .. " use Bow Weapon.")
			elseif silencer == 3 then
				managers.chat:feed_system_message(1, peer:name() .. " use Saw Weapon.")
			elseif silencer == 4 then
				managers.chat:feed_system_message(1, peer:name() .. " use Flame Weapon.")
			end
		end
	end
end)