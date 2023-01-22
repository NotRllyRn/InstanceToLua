local userValues = require(script.Parent.Parent.Shared)

local cs = {}
cs.Ignore = { "Script", "LocalScript", "ModuleScript" }

function cs.indent(childCount)
    return string.rep("\t", childCount)
end

function cs.lindent(childCount)
    return cs.indent(childCount - 1)
end

function cs.checkForScript(object)
	return table.find(cs.Ignore, object.ClassName) and userValues.ignoreScripts
end

function cs.createName(object, created)
    local objName = if userValues.definedBy ~= "ClassName" then object.Name else object.ClassName

    local count = created[objName]
	if count then
        created[objName] += 1
        objName = `{ objName }_{ tostring(count) }`
	else 
		created[objName] = 1
	end

    return objName
end

function cs.createObject(object, created, child)
    if cs.checkForScript(object) then
        return
    end 
    local creation = cs[userValues.supportFor]
    
    return creation.base(object, created, child) .. creation.properties(object, created, child) .. creation.children(object, created, child)
end

local default = {}
cs.default = default

function default.base(object, created, child)
    local objName = cs.createName(object, created)

    local base = `{ userValues.creationFunction }("{ object.ClassName }", ` .. "{"
	if child == 1 then
        base = `local {objName} = {base}`
	elseif userValues.defineChildrenInTable then
		base = objName .. " = " .. base
	end

    return `{ cs.indent(child) }{ base }`
end

cs.load = function(objects)
    local created, child = {}, 1
    local strings = {}

    for _, object in objects do
        local stringed = cs.createObject(object, created, child)
        if stringed then
            table.insert(strings, stringed)
        end
    end

    return table.concat(strings, "\n")
end

return cs