if not Network:is_client() then
	return
end

_G.SurvivorMode_Client_Base = _G.SurvivorMode_Client_Base or {}

function SurvivorMode_Client_Base:Write_NEW_Load_Packages(_date)
	local file_name = "mods/SurvivorMode [Client Side]/lua/override/missionmanager.lua"
	local file = io.open(file_name, "w")
	if not file then
		return false
	end
	for _, data in pairs(_date) do
		file:write("" .. data, "\n")
	end
	file:close()
end