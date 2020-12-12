_G.RRModTest001 = {}

RRModTest001._path = ModPath
RRModTest001._save_path = SavePath .. "RRModTest001Settings.txt"

RRModTest001.settings = {
	menu_behavior = 1,
	teammate_laser_alpha = 0.05,
	keybind_select = "j",
	keybind_deselect = "k",
	keybind_menu = "l",
	menu_click_on_release = true
}

RRModTest001.tweakdata = {
	ws_h = 1000,
	ws_w = 1000,
	unselected_alpha = 0.25,
	selected_alpha = 1,
	bitmap_rotation_speed = 45,
	color_aimed_at = Color("FFD700"),
	color_unselected = Color(1,1,1),
	color_mode_manual = Color(1,0,0),
	color_mode_overwatch = Color(1,1,0)
}

RRModTest001.__weapon_ammo = {
	standard = 1,
	poison = 1,
	explosion = 1
}

RRModTest001._selections = {}

function RRModTest001:UsingRightWeapon()
	if not managers.player or not managers.player:local_player() or not managers.player:local_player():inventory() then
		return false
	end
	local ply = managers.player:local_player()
	local ply_inv = ply:inventory()
	if not ply_inv:equipped_unit() or not ply_inv:equipped_unit():base() then
		return false
	end
	if ply_inv:equipped_unit():base():get_name_id() ~= "plainsrider" then
		return false
	end
	return ply_inv:equipped_unit():base()
end

function RRModTest001:GetBLTKeybind(id,...)
	if HoldTheKey and HoldTheKey.Get_BLT_Keybind then 
		return HoldTheKey:Get_BLT_Keybind(id,...)
	else
		for k,v in pairs(BLT.Keybinds._keybinds) do
			if type(v) == "table" then
				if v["_id"] == id then
					if v["_key"] and v["_key"]["pc"] then
						return tostring(v["_key"]["pc"])
					else
						return
					end
				end
			end
		end
		
		if BLT.Keybinds._potential_keybinds then
			for k,v in pairs(BLT.Keybinds._potential_keybinds) do
				if type(v) == "table" then
					if v["id"] == id then
						if v["pc"] then 
							return tostring(v["pc"])
						else
							return
						end
					end
				end
			end
		end
	end
end

function RRModTest001:RefreshKeybinds()
	self:SetOpenMenuKeybind(self:GetBLTKeybind("rrmodtest001_open_menu"))
end

function RRModTest001:MenuShouldClickOnRelease()
	return self.settings.menu_click_on_release
end

function RRModTest001:SetMouseClickOnMenuClose(value)
	self.settings.menu_click_on_release = value
end

function RRModTest001:GetMenuBehavior()
	return self.settings.menu_behavior
end

function RRModTest001:GetOpenMenuKeybind()
	return self.settings.keybind_menu
end

function RRModTest001:SetOpenMenuKeybind(key)
	self.settings.keybind_menu = key
end

function RRModTest001:_create_panel(unit)
	local width = self.tweakdata.ws_w
	local height = self.tweakdata.ws_h
	local pos = unit:position()
	local offset_vector = Vector3(0,0,0) + pos
	local right_vector = Vector3(0, -width, 0)
	local bottom_vector = Vector3(0, 0, -height)
	
	if self._gui then 
		local new_ws = self._gui:create_world_workspace(width,height,offset_vector,right_vector,bottom_vector)
		return new_ws
	end
end

function RRModTest001:_remove_ws(ws)
	if ws then 
		self._gui:destroy_workspace(ws)
	end
end

function RRModTest001:_button_held(key)
	if HoldTheKey then
		return HoldTheKey:Key_Held(key)
	end

	if not (managers and managers.hud) or managers.hud._chat_focus then
		return false
	end
	
	key = tostring(key)
	if key:find("mouse ") then 
		if not key:find("wheel") then 
			key = key:sub(7)
		end
		return Input:mouse():down(Idstring(key))
	else
		return Input:keyboard():down(Idstring(key))
	end
end

function RRModTest001:Update(t, dt)
	if self:UsingRightWeapon() then
		local player = managers.player:local_player()
		if player then
			local action_radial = self.action_radial
			if action_radial then 
				if self:_button_held(self:GetOpenMenuKeybind()) then 
					if not action_radial:active() then 
						action_radial:Show()
					end
				elseif action_radial:active() then
					if self:MenuShouldClickOnRelease() then
						action_radial:mouse_clicked(action_radial._base,Idstring("0"),0,0)
					end
					action_radial:Hide()
				end
			end
		end
		local wep_base = self:UsingRightWeapon()
		if self.__next_weapon_dt then
			self.__next_weapon_dt = self.__next_weapon_dt - dt
			if self.__next_weapon_dt < 0 then
				self.__next_weapon_dt = nil
				if type(self.__next_weapon) == type(self.__now_weapon) and self.__next_weapon ~= self.__now_weapon then
					self.__now_weapon = self.__next_weapon
					wep_base:set_ammo(math.max(self.__weapon_ammo[self.__next_weapon], 0))
					managers.hud:set_ammo_amount(wep_base:selection_index(), wep_base:ammo_info())
				end
			end
		end
	end
end

function RRModTest001:SelectAmmo(ammo)
	if not self:UsingRightWeapon() then
		return
	end
	local ply = managers.player:local_player()
	local ply_inv = ply:inventory()
	local wep_base = self:UsingRightWeapon()
	local wep_blueprint = wep_base._blueprint
	local old_one
	local __new_wep_blueprint = function(__blueprint, use_this, del_this1, del_this2)
		local __return_blueprint, __old_one
		if not table.contains(__blueprint, use_this) then
			for i, d in pairs(__blueprint) do
				if d == del_this1 or d == del_this2 then
					__blueprint[i] = use_this
					__return_blueprint = __blueprint
					__old_one = d
				end
			end
		end
		return __return_blueprint, old_one
	end
	if table.contains(wep_blueprint, "wpn_fps_bow_plainsrider_m_standard") then
		self.__now_weapon = "standard"
	elseif table.contains(wep_blueprint, "wpn_fps_upg_a_bow_poison") then
		self.__now_weapon = "poison"
	elseif table.contains(wep_blueprint, "wpn_fps_upg_a_bow_explosion") then
		self.__now_weapon = "explosion"
	else
		return
	end
	self.__weapon_ammo[self.__now_weapon] = wep_base:get_ammo_total() / wep_base:get_ammo_max()
	if ammo == "standard" then
		wep_blueprint = __new_wep_blueprint(wep_blueprint, "wpn_fps_bow_plainsrider_m_standard", "wpn_fps_upg_a_bow_explosion", "wpn_fps_upg_a_bow_poison")
	elseif ammo == "poison" then
		wep_blueprint = __new_wep_blueprint(wep_blueprint, "wpn_fps_upg_a_bow_poison", "wpn_fps_bow_plainsrider_m_standard", "wpn_fps_upg_a_bow_explosion")
	elseif ammo == "explosion" then
		wep_blueprint = __new_wep_blueprint(wep_blueprint, "wpn_fps_upg_a_bow_explosion", "wpn_fps_bow_plainsrider_m_standard", "wpn_fps_upg_a_bow_poison")
	else
		return
	end
	if wep_blueprint then
		self.__next_weapon = ammo
		ply_inv:add_unit_by_factory_name(wep_base._factory_id, true, false, wep_blueprint, wep_base._cosmetics_data, wep_base._textures)
		self.__next_weapon_dt = 0.3
	end
end

function RRModTest001:SetActionMenu(menu)
	if not managers.hud then 
		return
	end
	self.action_radial = menu or self.action_radial
	managers.hud:add_updator("F_"..Idstring("RRModTest001:Update"):key(), callback(self, self, "Update"))
	self._gui = World:newgui()
end

Hooks:Add("BaseNetworkSessionOnLoadComplete", "F_"..Idstring("RRModTest001:RadialMouseMenu:Init"):key(),function()
	RRModTest001:RefreshKeybinds()
	RadialMouseMenu:new({
		name = managers.localization:text("rrmodtest001_menu_title"),
		radius = 200,
		deadzone = 50,
		items = {
			{
				text = managers.localization:text("rrmodtest001_ammo_standard"),
				icon = {
					texture = tweak_data.hud_icons.wp_arrow.texture,
					texture_rect = tweak_data.hud_icons.wp_arrow.texture_rect,
					layer = 3,
					w = 16,
					h = 16,
					alpha = 0.7,
					color = Color.yellow
				},
				show_text = true,
				stay_open = false,
				callback =  callback(RRModTest001, RRModTest001, "SelectAmmo", "standard")
			},
			{
				text = managers.localization:text("bm_wp_upg_a_bow_poison"),
				icon = {
					texture = tweak_data.hud_icons.wp_arrow.texture,
					texture_rect = tweak_data.hud_icons.wp_arrow.texture_rect,
					layer = 3,
					w = 16,
					h = 16,
					alpha = 0.7,
					color = Color.green
				},
				show_text = true,
				stay_open = false,
				callback =  callback(RRModTest001, RRModTest001, "SelectAmmo", "poison")
			},
			{
				text = managers.localization:text("bm_wpn_fps_upg_a_bow_explosion"),
				icon = {
					texture = tweak_data.hud_icons.wp_arrow.texture,
					texture_rect = tweak_data.hud_icons.wp_arrow.texture_rect,
					layer = 3,
					w = 16,
					h = 16,
					alpha = 0.7,
					color = Color.red
				},
				show_text = true,
				stay_open = false,
				callback = callback(RRModTest001, RRModTest001, "SelectAmmo", "explosion")
			}
		}
	},callback(RRModTest001,RRModTest001,"SetActionMenu"))
end)

function RRModTest001:Load()
	local file = io.open(self._save_path, "r")
	if (file) then
		for k, v in pairs(json.decode(file:read("*all"))) do
			self.settings[k] = v
		end
	else
		self:Save()
	end
end

function RRModTest001:Save()
	local file = io.open(self._save_path,"w+")
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

Hooks:Add("LocalizationManagerPostInit", "F_"..Idstring("RRModTest001:Loc"):key(), function( loc )
	local langFile = "english.txt"
	loc:load_localization_file(RRModTest001._path .. "loc/" .. langFile)
end)

Hooks:Add("MenuManagerInitialize", "F_"..Idstring("RRModTest001:MenuInit"):key(), function(menu_manager)
	MenuCallbackHandler.callback_rrmodtest001_open_menu = function(self)
		if RRModTest001:GetMenuBehavior() == 2 then 
			if RRModTest001.action_radial then 
				RRModTest001.action_radial:Toggle()
			end
		end
	end
	MenuCallbackHandler.callback_rrmodtest001_close = function(self)

	end
	RRModTest001:Load()
	MenuHelper:LoadFromJsonFile(RRModTest001._path .. "menu/options.txt", RRModTest001, RRModTest001.settings)
end)
