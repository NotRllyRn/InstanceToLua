local InstanceAPI = require(script.Parent:WaitForChild("InstanceAPI"))
local DataTypeAPI = require(script.Parent:WaitForChild("DataTypeAPI"))

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