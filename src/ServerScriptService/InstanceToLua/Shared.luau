local userValues = {
	decimalPrecision = 3,
	creationFunction = "_CI",
	supportFor = "default",
	definedBy = "classname",
	ignoreScripts = true,
	getScriptSource = false,
	defineChildrenInTable = false
}

local pluginFolder = script.Parent
local modules = pluginFolder.Modules

return {
	userValues = userValues,
	pluginFolder = pluginFolder,
	modules = modules,
	DumpParser = require(modules.DumpParser),
	DataConstructor = require(modules.DataConstructor),
}