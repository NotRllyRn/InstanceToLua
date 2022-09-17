local toolbar = plugin:CreateToolbar("Instance To Lua")
local button = toolbar:CreateButton("Open Gui", "Opens the InstanceToLua ui", "rbxassetid://4458901886")
button.ClickableWhenViewportHidden = true

local a = Instance.new("Attachment")

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Selection = game:GetService("Selection")
local PropertyAPI = (function()
	local InstanceAPI = (function()
		local HttpService = game:GetService("HttpService")
		local APIData = (function()
			local resp = HttpService:RequestAsync({Url = "https://setup.rbxcdn.com/versionQTStudio"})
			if resp.StatusCode < 200 or resp.StatusCode >= 300 then
				error("failed to get latest build data", 2)
			end
			local version = resp.Body
			local resp = HttpService:RequestAsync({Url = string.format("https://setup.rbxcdn.com/%s-API-Dump.json", version)})
			if resp.StatusCode < 200 or resp.StatusCode >= 300 then
				error("failed to get latest dump data", 2)
			end
			return HttpService:JSONDecode(resp.Body)
		end)()
		
		local skipTags = {
			"NotScriptable",
			"Deprecated",
			"ReadOnly",
			"Hidden",
			"NotCreatable",
		}
		local skipInstances = {
			"DebuggerWatch",
			"ChannelSelectorSoundEffect",
		}

		local Toolset = {
			SortedData = {},
			GetClassDataFromAPI = function(self, class)
				if table.find(skipInstances, class.Name) then
					return nil
				end
				local success, instance = pcall(function()
					local instance = class.Name == "Instance" and Instance or class.Name == "DebuggerWatch" and error("wow", 2) or Instance.new(class.Name)
					return instance
				end)
				if not success then return end
				if class.Tags then
					for _, tag in ipairs(skipTags) do
						if table.find(class.Tags, tag) then
							return
						end
					end
				end
				local data = {
					Name = class.Name,
					ExampleInstance = instance,
					Properties = {},
					Methods = {},
					Events = {},
				}

				for _, property in ipairs(class.Members) do
					local type = property.MemberType
					if type == "Property" then
						if property.Security and property.Security.Read ~= "None" then
							continue
						end
						if property.Tags then
							local stop
							for _, tag in ipairs(skipTags) do
								if table.find(property.Tags, tag) then
									stop = true
									break
								end
							end
							if stop then
								continue
							end
						end

						data.Properties[property.Name] = {
							Name = property.Name,
							DefaultValue = data.ExampleInstance[property.Name]
						}
					end
				end
				return data
			end,
			FindClass = function(self, ClassName)
				ClassName = ClassName and (type(ClassName) == "string" and ClassName or typeof(ClassName) == "Instance" and ClassName.ClassName)

				for _, class in ipairs(APIData.Classes) do
					if class.Name == ClassName then
						return class
					end
				end
			end,
			ConstructClass = function(self, ClassName, Class)
				ClassName = ClassName and (type(ClassName) == "string" and ClassName or typeof(ClassName) == "Instance" and ClassName.ClassName)
				Class = Class or self:FindClass(ClassName)
				
				if ClassName and Class and not self.SortedData[ClassName] then
					local SuperClass = Class.Superclass
					if not self.SortedData[SuperClass] then
						self:ConstructClass(SuperClass)
					end
					
					local classData = self:GetClassDataFromAPI(Class)
					if classData then
						if self.SortedData[SuperClass] then
							classData.Superclass = self.SortedData[SuperClass]
						end

						if ClassName == "FormFactorPart" then
							print(Class)
						end
						if self.SortedData[SuperClass] then
							for property, data in pairs(self.SortedData[SuperClass].Properties) do
								classData.Properties[property] = data
							end
						end
			
						self.SortedData[ClassName] = classData
					end
				end
			end,
		}

		for i, class in ipairs(APIData.Classes) do
			Toolset:ConstructClass(class.Name)
		end
		
		return {
			CheckClassInput = function(self, class)
				return class ~= nil and (table.find({"string", "table"}, type(class)) and class or typeof(class) == "Instance" and class.ClassName)
			end,
			GetClassData = function(self, class)
				class = self:CheckClassInput(class)
				if class then
					return Toolset.SortedData[class]
				end
			end,
			GetClassProperties = function(self, class)
				class = self:GetClassData(class)
				if class then
					return class.Properties
				end
			end,
			GetObjectProperties = function(self, instance)
				local class = self:GetClassData(instance)
				print(class)
				if class then
					local values = {}
					for property, _ in pairs(class.Properties) do
						values[property] = instance[property]
					end
					return values
				end
			end,
			RemoveDefaultProperties = function(self, class, properties)
				class = self:GetClassData(class)
				if class then
					for property, value in pairs(properties) do
						if self:CheckDefaultProperty(class.Name, property, value) then
							properties[property] = nil
						end
					end
					return properties
				end
			end,
			CheckTableDefault = function(self, instance, properties)
				local class = self:GetClassData(instance)
				if class then
					local default = true
					for property, value in pairs(properties) do
						if not self:CheckDefaultProperty(instance, property, value) then
							default = false
							break
						end
					end
					return default
				end
			end,
			CheckDefaultProperty = function(self, class, property, value)
				class = self:GetClassData(class)
				if class and value ~= nil then
					return value == class.Properties[property].DefaultValue
				end
			end,
		}
	end)()
	local DataTypeAPI = (function()
		return {
				["ConstructData"] = function(self, data)
					local dataType = data and typeof(data)
					if dataType then
						if dataType == "table" then
							for i, v in pairs(data) do
								self[i] = self:ConstructData(v)
							end
							return data
						else
							return self[dataType](self, data)
						end
					end
				end,
				["string"] = function(self, data)
					return data
				end,
				["number"] = function(self, data)
					return tostring(data)
				end,
				["boolean"] = function(self, data)
					return data == true and "true" or "false"
				end,
				["nil"] = function(self, data)
					return "nil"
				end,
				["Axes"] = function(self, data)
					local tupleTable = self:ConstructData{ data.X, data.Y, data.Z,
						data.Top, data.Bottom, data.Left,
						data.Right, data.Back, data.Front }
					return "Axes.new(" .. table.concat(tupleTable, ", ") .. ")"
				end,
				["BrickColor"] = function(self, data)
					return 'BrickColor.new("' .. data.Name .. '")'
				end,
				["CatalogSearchParams"] = function(data)
					return "CatalogSearchParams.new()"
				end,
				["CFrame"] = function(self, data)
					local xVector, yVector, zVector = data.XVector, data.YVector, data.ZVector
					local tupleTable = self:DataConstruct{ data.X, data.Y, data.Z,
						xVector.X, xVector.Y, xVector.Z,
						yVector.X, yVector.Y, yVector.Z,
						zVector.X, zVector.Y, zVector.Z }
					return "CFrame.new(" .. table.concat(tupleTable, ", ") .. ")"
				end,
				["Color3"] = function(self, data)
					local tupleData = self:ConstructData{ data.R, data.Y, data.Z }
					return "Color3.new(" .. table.concat(tupleData, ", ") .. ")"
				end,
				["ColorSequence"] = function(self, data)
					local keyPointData = self:ConstructData(data.Keypoints)
					return "ColorSequence.new({ " .. table.concat(keyPointData, ",\n") .. " })"
				end,
				["ColorSequenceKeypoint"] = function(self, data)
					local tupleData = self:ConstructData{ data.Time, data.Value }
					return "ColorSequenceKeypoint.new(" .. table.concat(tupleData, ", ") .. ")"
				end,
				["DateTime"] = function(self, data)
					return "DateTime.fromUnixTimestamp(" .. data.UnixTimestamp .. ")"
				end,
				["DockWidgetPluginGuiInfo"] = function(self, data)
					local tupleData = self:ConstructData{ data.initDockState or Enum.InitialDockState.Right,
					data.InitialEnabled, data.InitialEnabledShouldOverrideRestore,
					data.floatXSize, data.floatYSize, data.minWidth,
					data.minHeight, data.maxWidth, data.minHeight }
					return "DockWidgetPluginGuiInfo.new(" .. table.concat(tupleData, ", ") .. ")"
				end,
				["Enum"] = function(self, data)
					return 'Enum["' .. tostring(data) .. '"]'
				end,
				["EnumItem"] = function(self, data)
					return self:ConstructData(data.EnumType) .. '["' .. data.Name .. '"]'
				end,
				["Enums"] = function(self, data)
					return "Enum"
				end,
				["Faces"] = function(self, data)
					local tupleData = self:ConstructData{ data.Top and Enum.NormalId.Top, data.Bottom and Enum.NormalId.Bottom,
						data.Left and Enum.NormalId.Left, data.Right and Enum.NormalId.Right, 
						data.Back and Enum.NormalId.Back, data.Front and Enum.NormalId.Front }
					return "Faces.new(" .. table.concat(tupleData, ", ") .. ")"
				end,
				["FloatCurveKey"] = function(self, data)
					local tupleData = self:ConstructData{ data.Time, data.Value, data.Interpolation }
					return "FloatCurveKey.new(" .. table.concat(tupleData, ", ") .. ")"
				end,
				["Instance"] = function(self, data)
					local tupleData = self:ConstructData{ data.ClassName }
					return 'Instance.new("' .. table.concat(tupleData, ", ") .. '")'
				end,
				["NumberRange"] = function(self, data)
					local tupleData = self:ConstructData{ data.Min, data.Max }
					return "NumberRange.new(" .. table.concat(tupleData, ", ") .. ")"
				end,
				["NumberSequence"] = function(self, data)
					local keyDataPoints = self:ConstructData(data.Keypoints)
					return "NumberSequence.new({ " .. table.concat(keyDataPoints, ",\n") .. " })"
				end,
				["NumberSequenceKeypoint"] = function(self, data)
					local tupleData = self:ConstructData{ data.Time, data.Value, data.Envelope }
					return "NumberSequenceKeypoint.new(" .. table.concat(tupleData, ", ") .. ")"
				end,
				["OverlapParams"] = function(self, data)
					return "OverlapParams.new()"
				end,
				["PathWaypoint"] = function(self, data)
					local tupleData = self:ConstructData{ data.Position, data.Action }
					return "PathWaypoint.new(" .. table.concat(tupleData, ", ") .. ")"
				end,
				["PhysicalProperties"] = function(self, data)
					local tupleData = self:ConstructData{ data.Density, data.Friction, data.Elasticity, data.FrictionWeight, data.ElasticityWeight }
					return "PhysicalProperties.new(" .. table.concat(tupleData, ", ") .. ")"
				end,
				["Random"] = function(self, data)
					return "Random"
				end,
				["Ray"] = function(self, data)
					local tupleData = self:ConstructData{ data.Origin, data.Direction }
					return "Ray.new(" .. table.concat(tupleData, ", ") .. ")"
				end, 
				["RaycastParams"] = function(self, data)
					return "RaycastParams.new()"
				end,
				-- // ray cast result cannot be created
				-- // same goes for rbxscriptconnection
				-- // and rbxscriptsignal
				["Rect"] = function(self, data)
					local tupleData = self:ConstructData{ data.Min, data.Max }
					return "Rect.new(" .. table.concat(tupleData, ", ") .. ")"
				end,
				["Region3"] = function(self, data)
					local tupleData = self:ConstructData{ data.CFrame.Position + data.Size / 2, data.CFrame.Position + data.Size / -2 }
					return "Region3.new(" .. table.concat(tupleData, ", ") .. ")"
				end,
				["Region3int16"] = function(self, data)
					local tupleData = self:ConstructData{ data.Min, data.Max }
					return "Region3int16.new(" .. table.concat(tupleData, ", ") .. ")"
				end,
				["TweenInfo"] = function(self, data)
					local tupleData = self:ConstructData{ data.Time, data.EasingStyle, data.EasingDirection, data.RepeatCount, data.Reverses, data.DelayTime }
					return "TweenInfo.new(" .. table.concat(tupleData, ", ") .. ")"
				end,
				["UDim"] = function(self, data)
					local tupleData = self:ConstructData{ data.Scale, data.Offset }
					return "UDim.new(" .. table.concat(tupleData, ", ") .. ")"
				end,
				["UDim2"] = function(self, data)
					local tupleData = self:ConstructData{ data.X, data.Y }
					return "UDim2.new(" .. table.concat(tupleData, ", ") .. ")"
				end,
				["Vector2"] = function(self, data)
					local tupleData = self:ConstructData{ data.X, data.Y }
					return "Vector2.new(" .. table.concat(tupleData, ", ") .. ")"
				end,
				["Vector2int16"] = function(self, data)
					local tupleData = self:ConstructData{ data.X, data.Y }
					return "Vector2int16.new(" .. table.concat(tupleData, ", ") .. ")"
				end,
				["Vector3"] = function(self, data)
					local tupleData = self:ConstructData{ data.X, data.Y, data.Z }
					return "Vector3.new(" .. table.concat(tupleData, ", ") .. ")"
				end,
				["Vector3int16"] = function(self, data)
					local tupleData = self:ConstructData{ data.X, data.Y, data.Z }
					return "Vector3int16.new(" .. table.concat(tupleData, ", ") .. ")"
				end,
			}
	end)()
	
	return {
		ToString = function(self, instance, created, child)
			local InstanceName = instance.Name
			if not child then
				if created[InstanceName] then
					InstanceName = InstanceName .. "_" .. tostring(created[InstanceName])
					created[InstanceName] += 1
				else
					created[InstanceName] = 1
				end
			end
			local base = '_CI("' .. instance.ClassName .. '", {\n\t'
			if not child then
				base =  'local ' .. InstanceName .. ' = ' .. base
			end
			local InstanceProperties = InstanceAPI:GetObjectProperties(instance)
			print(InstanceProperties)
			if not InstanceAPI:CheckTableDefault(instance, InstanceProperties) then
				local properties = InstanceAPI:RemoveDefaultProperties(instance, InstanceProperties)
				local StringifiedProperties = {}
				for property, value in pairs(properties) do
					table.insert(StringifiedProperties, property .. ' = ' .. DataTypeAPI:ConstructData(value))
				end
	
				base = base .. table.concat(StringifiedProperties, ",\n\t")
			end
			base = base .. " }, {\n\t})\n"
	
			return base
		end,
	}
end)()

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