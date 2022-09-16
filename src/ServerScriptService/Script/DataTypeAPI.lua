return {
	DataTypes = {
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
			local items = data:GetEnumItems()
			local enumName = items[1].EnumType.Name
		end
	}
}