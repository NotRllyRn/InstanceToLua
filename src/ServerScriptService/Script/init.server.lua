local versionURL = "https://setup.rbxcdn.com/versionQTStudio"
local dumpURL = "https://setup.rbxcdn.com/%s-API-Dump.json"
local HttpService = game:GetService("HttpService")
function LoadAPI()
	local resp = HttpService:RequestAsync({Url = versionURL})
	if resp.StatusCode < 200 or resp.StatusCode >= 300 then
		error("failed to get latest build data", 2)
	end
	local version = resp.Body
	local resp = HttpService:RequestAsync({Url = string.format(dumpURL, version)})
	if resp.StatusCode < 200 or resp.StatusCode >= 300 then
		error("failed to get latest dump data", 2)
	end
	return HttpService:JSONDecode(resp.Body)
end

local API = LoadAPI()

local toolbar = plugin:CreateToolbar("Instance To Lua")
local button = toolbar:CreateButton("Open Gui", "Opens the InstanceToLua ui", "rbxassetid://4458901886")
button.ClickableWhenViewportHidden = true

button.Click:Connect(function()
	table.foreach(API.Classes, function(i, v)
		if v.Name == "Instance" then
			print(game:GetService("HttpService"):JSONEncode(v.Members))
			--[[table.foreach(v.Members, function(i, v)
				if v.Name == "new" then
					table.foreach(v, print)
				end
			end)]]
		end
	end)

end)