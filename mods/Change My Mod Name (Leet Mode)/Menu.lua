local function EN2LEET(message)
	local Convert_List = {
		a = "4", b = "8", c = "C", d = "D", e = "3",
		f = "f", g = "9", h = "H", i = "|", j = "j",
		k = "k", l = "1", m = "M", n = "n", o = "0",
		p = "p", q = "q", r = "R", s = "$", t = "7",
		u = "u", v = "v", w = "w", x = "x", y = "y",
		z = "z"
	}
	for en, leet in pairs(Convert_List) do
		message = message:gsub(en, leet)
	end
	local message_len = string.len(message)
	local message_buff = (message_len + 9) / 3
	local i = 0
	local z = 1
	if message_buff < message_len then
		while i < message_len and z < 20 do
			z = z + 1
			local r = math.round(math.random() * message_buff)
			if i + r > message_len then
				r = message_len - i
			end
			if r > 0 then
				local s_s = string.sub(message, 1, i - 1)
				local pick = string.sub(message, i, i + r)
				local e_s = string.sub(message, i + r + 1, message_len)
				if r%2 == 1 then
					pick = string.upper(pick)
				else
					pick = string.lower(pick)
				end
				message = s_s .. pick .. e_s
				i = i + r
			end
		end
	end
	return message
end

local old_build_mods_list = MenuCallbackHandler.build_mods_list

function MenuCallbackHandler:build_mods_list(...)
    local __ans_mod = old_build_mods_list(self, ...)
	if self:is_modded_client() then
		for __key, __data in pairs(__ans_mod) do
			__ans_mod[__key] = {
				EN2LEET(tostring(__ans_mod[1])),
				EN2LEET(tostring(__ans_mod[2]))
			}
		end
	end
	return __ans_mod
end