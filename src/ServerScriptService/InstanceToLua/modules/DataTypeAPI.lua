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