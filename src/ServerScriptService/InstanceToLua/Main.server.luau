local header = [[-- // paste this somewhere at the top of your script (you only need one of these)
local _CI = function(class, properties, children)
	local instance, children, properties = Instance.new(class), children or {}, properties or {}
	for property, value in properties do
		if property == "Parent" then
			continue
		end
		instance[property] = value
	end
	for _, child in pairs(children) do
		child.Parent = instance
	end
	return instance
end\n\n]]

-- // get some values
local pluginFolder = script.Parent
local Shared = require(pluginFolder.Shared)

local dataConstructor = Shared.DataConstructor
local dumpParser = Shared.DumpParser
local dump = dumpParser.fetchFromServer()

local ignoreProperties = {
	["Parent"] = true,
	["AssemblyRootPart"] = true,
	["BrickColor"] = { "Color" },
	["ExtentsCFrame"] = true,
	["Position"] = { "CFrame" },
	["ExtentsSize"] = true,
	["AssemblyMass"] = true,
	["AssemblyCenterOfMass"] = true,
}

local createString: (object: Instance, created: any, child: number) -> string?
function createString(object, created, child)
	local isAScript = table.find({"Script", "LocalScript", "ModuleScript"}, object.ClassName)
	if isAScript and userValues.ignoreScripts then
		return
	end
	if userValues.ignoreScripts and table.find({"Script", "LocalScript", "ModuleScript"}, object.ClassName) then
		return
	end
	created = created or {}
	child = child or 1
	
	local lindent = string.rep("\t", child - 1)
	local indent = lindent .. "\t"
	
	local objName = object.ClassName
	if userValues.definedBy ~= "ClassName" then
		objName = object.Name
	end

	if created[object] then
		objName = objName .. "_" .. tostring(created[object])
		created[object] += 1
	else
		created[objName] = 1
	end
	
	local base = userValues.creationFunction .. '("' .. object.ClassName .. '", {'
	if child == 1 then
		base =  'local ' .. objName .. ' = ' .. base
	elseif userValues.defineChildrenInTable then
		base = objName .. " = " .. base
	end
	
	local properties = dump:GetChangedProperties(object)
	if isAScript and object.Source ~= "" then
		properties.Source = { MemberType = "Property" }
	end
	
	for name, check in ignoreProperties do
		if check == true then
			properties[name] = nil
		elseif type(check) == "table" then
			local pass = true
			for _, prop in check do
				if not properties[prop] then
					pass = false
					break
				end
			end
			
			if pass then
				properties[name] = nil
			end
		end
	end
	
	local base_check = false
	local stringProperties = {}
	
	for name, data in properties do
		base_check = true
		if data.MemberType == "Property" then
			table.insert(stringProperties, name .. ' = ' .. dataConstructor(object[name]))
		end
	end
	
	if base_check then
		base = base .. "\n" .. indent
	end
	base = base .. table.concat(stringProperties, ",\n" .. indent)
	if base_check then
		base = base .. "\n" .. lindent .. "}, {"
	else
		base = base .. "}, {"
	end
	
	local children = object:GetChildren()
	if #children > 0 then
		base = base .. "\n" .. indent
		local stringChildren = {}
		local childrenCreated = {}
		
		for _, c in children do
			local stringified = createString(c, childrenCreated, child + 1)
			if stringified then
				table.insert(stringChildren, stringified)
			end
		end
		
		base = base .. table.concat(stringChildren, ",\n" .. indent) .. "\n" .. lindent .. "})"
	else
		base = base .. "})"
	end

	return base
end

-- // services for the plugin to use
local changeHistoryService = game:GetService("ChangeHistoryService")
local selection = game:GetService("Selection")

local function onCreate()
	local selectedObjects = selection:Get()
	if #selectedObjects == 0 then
		warn("No objects selected")
		return
	else
		-- // get the first object selected
		-- // TODO: make it so that multiple objects can be selected and printed out instead of just 1
		-- // TODO: also detect scripts for ignoreScript
		local object = selectedObjects[1]

		local stringified = createString(object)
		local output_script = Instance.new("LocalScript")
		output_script.Source = header .. stringified
		output_script.Name = "InstanceToLuauOutput"

		output_script.Parent = object.Parent

		changeHistoryService:SetWaypoint()
	end
end

-- // loading the ui
local ui = pluginFolder.Ui

local toolBar = plugin:CreateToolbar("Instance To Luau")
local button = toolBar:CreateButton("Open Gui", "Opens the InstanceToLuau ui", "rbxassetid://4458901886")
button.ClickableWhenViewportHidden = true

button.Click:Connect(function()
	if ui.Parent == pluginFolder then
		ui.Parent = game:GetService("CoreGui")
	else
		ui.Parent = pluginFolder
	end
end)

print("loaded")