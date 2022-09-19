local toolbar = plugin:CreateToolbar("Instance To Lua")
local button = toolbar:CreateButton("Open Gui", "Opens the InstanceToLua ui", "rbxassetid://4458901886")
button.ClickableWhenViewportHidden = true

local a = Instance.new("Attachment")

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")
local PropertyAPI = require(script.Parent:WaitForChild("modules"):WaitForChild("PropertyAPI"))
local helperString = [[-- // paste this somewhere at the top of your script (you only need one of these)
local _CI\n_CI = function(class, properties, children)
	local instance, children, properties = Instance.new(class), children or {}, properties or {}
	for property, value in pairs(properties) do
		if property == "Parent" then
			continue
		end
		instance[property] = value
	end
	for _, child in pairs(children) do
		child.Parent = instance
	end
	return { Instance = instance, Children = children }
end
]]

button.Click:Connect(function()
	local selectedObjects = Selection:Get()
	if #selectedObjects == 0 then
		warn("No objects selected")
		return
	else
		local created = {}
		local output = PropertyAPI:ToString(selectedObjects[1], created)
		print(output)
	end
end)