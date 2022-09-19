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