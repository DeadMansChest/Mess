local ThisModPath = ModPath
local ThisModPathIds = Idstring(ThisModPath):key()
local Hook1 = "F_"..Idstring("Hook1::"..ThisModPathIds):key()

Hooks:PostHook(WeaponFactoryTweakData, "create_ammunition", Hook1, function(self, ...)
	if self.parts and self.parts.wpn_fps_upg_a_rip then
		self.parts.wpn_fps_upg_a_rip.custom_stats.dot_data.custom_data.dot_trigger_max_distance = 1400
	end
end)