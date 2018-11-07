local classes = {}

local function import(name)
	return setmetatable( {name = name}, {__call = function(t, ... )
		local obj = {}
		local classDef = classes[t.name]
		if classDef.extends then
			local superClass = import(classDef.extends)
			obj.super = superClass(...)

			for k, v in pairs(obj.super) do
				obj[k] = v
			end

		end

		for k, v in pairs(classDef.members) do
			obj[k] = v
		end

		if obj.constructor then
			obj:constructor(...)
		end

		return obj
	end} )
end

local function extends(name)
	classes[classes.currentDefName].extends = name
end

local function class(name)
	classes.currentDefName = name
	classes[name] = {
		members = {},
		extends = nil
	}

	return function(body)
		local currentClassDef = classes[classes.currentDefName]

		for k, v in pairs(body) do
			if type(v) == "function" then
				currentClassDef.members[k] = v
			end
		end

		classes.currentDefName = nil
	end
end


return {
	import = import,
	extends = extends,
	class = class
}
