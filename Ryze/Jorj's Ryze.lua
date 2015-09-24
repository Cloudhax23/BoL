
local socket = require("socket")

local seen={}
local file = io.open(BOL_PATH .. "_G.lua", "w")

function dump(t,i)
	seen[t]=true
	local s={}
	local n=0
	for k in pairs(t) do
		n=n+1 s[n]=k
	end
	table.sort(s)
	for k,v in ipairs(s) do
		file:write(i,v .. '\n')

		v=t[v]
		if type(v)=="table" and not seen[v] then
			dump(v,i.."\t")
		end
	end
end

dump(_G,"")
file:close()
