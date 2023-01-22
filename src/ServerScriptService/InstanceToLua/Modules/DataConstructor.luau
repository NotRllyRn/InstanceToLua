local decimal_precision = 10^3
local cframe = CFrame.new()

local t = {
	["ConstructData"] = function(self, data)
		local dataType = data and typeof(data)
		if dataType then
			if dataType == "table" then
				for i, v in pairs(data) do
					data[i] = self:ConstructData(v)
				end
				return data
			elseif self[dataType] then
				return self[dataType](self, data)
			else
				warn(`DataConstructor: Unknown data type: {dataType}`)
				return nil
			end
		end
	end,
	["string"] = function(_, data)
		local c1, c2 = data:match('"'), data:match("'")
		if c1 then
			return `"{data}"`
		elseif c2 then
			return `'{data}'`
		else
			local check = ""
			while data:match(`[{check}[`) do
				check = check .. string.char(math.random(65,122))
			end
			return `[{check}[{data}]{check}]`
		end
	end,
	["number"] = function(_, data)
		local nData = tostring(math.floor(data * decimal_precision) / decimal_precision)
		if nData == "inf" then
			nData = "math.huge"
		end
		return nData
	end,
	["boolean"] = function(_, data)
		return if data == true then "true" else "false"
	end,
	["nil"] = function()
		return "nil"
	end,
	["Axes"] = function(self, data)
		local tupleData = self:ConstructData{ data.X, data.Y, data.Z,
			data.Top, data.Bottom, data.Left,
			data.Right, data.Back, data.Front }
		return `Axes.new({ table.concat(tupleData, ", ") })`
	end,
	["BrickColor"] = function(self, data)
		local tupleData = self:ConstructData{ tostring(data) }
		return `BrickColor.new({ table.concat(tupleData, ", ") })`
	end,
	["CatalogSearchParams"] = function()
		return "CatalogSearchParams.new()"
	end,
	["CFrame"] = function(self, data)
		local xVector, yVector, zVector = data.XVector, data.YVector, data.ZVector
		local tupleData = self:ConstructData{ data.X, data.Y, data.Z,
			xVector.X, xVector.Y, xVector.Z,
			yVector.X, yVector.Y, yVector.Z,
			zVector.X, zVector.Y, zVector.Z }
		
		if data.Rotation == cframe.Rotation then
			tupleData = {tupleData[1], tupleData[2], tupleData[3]}
		end
		return `CFrame.new({ table.concat(tupleData, ", ") })`
	end,
	["Color3"] = function(self, data)
		local tupleData = self:ConstructData{ data.R, data.G, data.B }
		return `Color3.new({ table.concat(tupleData, ", ") })`
	end,
	["ColorSequence"] = function(self, data)
		local keyPointData = self:ConstructData(data.Keypoints)
		return "ColorSequence.new({ " .. table.concat(keyPointData, ", ") .. " })"
	end,
	["ColorSequenceKeypoint"] = function(self, data)
		local tupleData = self:ConstructData{ data.Time, data.Value }
		return `ColorSequenceKeypoint.new({ table.concat(tupleData, ", ") })`
	end,
	["DateTime"] = function(_, data)
		return `DateTime.fromUnixTimestamp({ data.UnixTimestamp })`
	end,
	["DockWidgetPluginGuiInfo"] = function(self, data)
		local tupleData = self:ConstructData{ data.initDockState or Enum.InitialDockState.Right,
			data.InitialEnabled, data.InitialEnabledShouldOverrideRestore,
			data.floatXSize, data.floatYSize, data.minWidth,
			data.minHeight, data.maxWidth, data.minHeight }
		return `DockWidgetPluginGuiInfo.new({ table.concat(tupleData, ", ") })`
	end,
	["Enum"] = function(self, data)
		local tupleData = self:ConstructData{ tostring(data) }
		return `Enum[{ table.concat(tupleData, ", ") }]`
	end,
	["EnumItem"] = function(self, data)
		local tupleData = self:ConstructData{ data.Name }
		return `{ self:ConstructData(data.EnumType) }[{ table.concat(tupleData, ", ") }]`
	end,
	["Enums"] = function()
		return "Enum"
	end,
	["Faces"] = function(self, data)
		local tupleData = self:ConstructData{ data.Top and Enum.NormalId.Top, data.Bottom and Enum.NormalId.Bottom,
			data.Left and Enum.NormalId.Left, data.Right and Enum.NormalId.Right, 
			data.Back and Enum.NormalId.Back, data.Front and Enum.NormalId.Front }
		return `Faces.new({ table.concat(tupleData, ", ") })`
	end,
	["FloatCurveKey"] = function(self, data)
		local tupleData = self:ConstructData{ data.Time, data.Value, data.Interpolation }
		return `FlatCurveKey.new({ table.concat(tupleData, ", ") })`
	end,
	["Instance"] = function(self, data)
		local tupleData = self:ConstructData{ data.ClassName }
		return `Instance.new({ table.concat(tupleData, ", ") })`
	end,
	["NumberRange"] = function(self, data)
		local tupleData = self:ConstructData{ data.Min, data.Max }
		return `NumberRange.new({ table.concat(tupleData, ", ") })`
	end,
	["NumberSequence"] = function(self, data)
		local keyDataPoints = self:ConstructData(data.Keypoints)
		return "NumberSequence.new({ " .. table.concat(keyDataPoints, ", ") .. " })"
	end,
	["NumberSequenceKeypoint"] = function(self, data)
		local tupleData = self:ConstructData{ data.Time, data.Value, data.Envelope }
		return `NumberSequenceKeypoint.new({ table.concat(tupleData, ", ") })`
	end,
	["OverlapParams"] = function()
		return "OverlapParams.new()"
	end,
	["PathWaypoint"] = function(self, data)
		local tupleData = self:ConstructData{ data.Position, data.Action }
		return `PathWaypoint.new({ table.concat(tupleData, ", ") })`
	end,
	["PhysicalProperties"] = function(self, data)
		local tupleData = self:ConstructData{ data.Density, data.Friction, data.Elasticity, data.FrictionWeight, data.ElasticityWeight }
		return `PhysicalProperties.new({ table.concat(tupleData, ", ") })`
	end,
	["Random"] = function()
		return "Random"
	end,
	["Ray"] = function(self, data)
		local tupleData = self:ConstructData{ data.Origin, data.Direction }
		return `Ray.new({ table.concat(tupleData, ", ") })`
	end, 
	["RaycastParams"] = function()
		return "RaycastParams.new()"
	end,
	-- // ray cast result cannot be created
	-- // same goes for rbxscriptconnection
	-- // and rbxscriptsignal
	["Rect"] = function(self, data)
		local tupleData = self:ConstructData{ data.Min, data.Max }
		return `Rect.new({ table.concat(tupleData, ", ") })`
	end,
	["Region3"] = function(self, data)
		local Position, halfSize = data.CFrame.Position, data.Size / 2

		local tupleData = self:ConstructData{ Position + halfSize, Position - halfSize }
		return `Region3.new({ table.concat(tupleData, ", ") })`
	end,
	["Region3int16"] = function(self, data)
		local tupleData = self:ConstructData{ data.Min, data.Max }
		return `Region3int16.new({ table.concat(tupleData, ", ") })`
	end,
	["TweenInfo"] = function(self, data)
		local tupleData = self:ConstructData{ data.Time, data.EasingStyle, data.EasingDirection, data.RepeatCount, data.Reverses, data.DelayTime }
		return `TweenInfo.new({ table.concat(tupleData, ", ") })`
	end,
	["UDim"] = function(self, data)
		local tupleData = self:ConstructData{ data.Scale, data.Offset }
		return `UDim.new({ table.concat(tupleData, ", ") })`
	end,
	["UDim2"] = function(self, data)
		local tupleData = self:ConstructData{ data.X.Scale, data.X.Offset, data.Y.Scale, data.Y.Offset }
		return `UDim2.new({ table.concat(tupleData, ", ") })`
	end,
	["Vector2"] = function(self, data)
		local tupleData = self:ConstructData{ data.X, data.Y }
		return `Vector2.new({ table.concat(tupleData, ", ") })`
	end,
	["Vector2int16"] = function(self, data)
		local tupleData = self:ConstructData{ data.X, data.Y }
		return `Vector2int16.new({ table.concat(tupleData, ", ") })`
	end,
	["Vector3"] = function(self, data)
		local tupleData = self:ConstructData{ data.X, data.Y, data.Z }
		return `Vector3.new({ table.concat(tupleData, ", ") })`
	end,
	["Vector3int16"] = function(self, data)
		local tupleData = self:ConstructData{ data.X, data.Y, data.Z }
		return `Vector3int16.new({ table.concat(tupleData, ", ") })`
	end,
}

return function(data)
	return t:ConstructData(data)
end