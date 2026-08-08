local fs = require("@lune/fs")
local luau = require("@lune/luau")
local roblox = require("@lune/roblox")
local serde = require("@lune/serde")
local task = require("@lune/task")
local process = require("@lune/process")

print("Initializing Headless Testing Environment via Lune with Custom Require Interceptor...")
local executionEnv = getfenv()

-- Initialize the virtual DataModel
local game = roblox.Instance.new("DataModel")
local success = pcall(function()
	game.GameId = 12345
end)
local success2 = pcall(function()
	game.PlaceId = 12345
end)
local ReplicatedStorage = roblox.Instance.new("ReplicatedStorage")
ReplicatedStorage.Parent = game
local ServerScriptService = roblox.Instance.new("ServerScriptService")
ServerScriptService.Parent = game

-- Deserialize the compiled project into the DataModel
local placeFile = fs.readFile("EvolutionTest.rbxl")
local loadedPlace = roblox.deserializePlace(placeFile)

-- Map Services
for _, child in loadedPlace:GetService("ReplicatedStorage"):GetChildren() do
	child.Parent = ReplicatedStorage
end
for _, child in loadedPlace:GetService("ServerScriptService"):GetChildren() do
	child.Parent = ServerScriptService
end

-- Load the Rojo sourcemap for path resolution
local sourcemapFile = fs.readFile("sourcemap.json")
local sourcemap = serde.decode("json", sourcemapFile)

local function findPathInSourcemap(targetInstance, rootMapNode)
	local path = {}
	local curr = targetInstance
	while curr and curr.Parent do -- Assuming root has no Parent or we stop before it
		table.insert(path, 1, curr.Name)
		curr = curr.Parent
	end

	local currentNode = rootMapNode
	-- Root node is usually the project name, path[1] is ReplicatedStorage etc.
	for i = 1, #path do
		local found = false
		for _, child in pairs(currentNode.children or {}) do
			if child.name == path[i] then
				currentNode = child
				found = true
				break
			end
		end
		if not found then
			return nil
		end
	end

	if currentNode.filePaths and #currentNode.filePaths > 0 then
		return currentNode.filePaths[1]
	end
	return nil
end

local originalRequire = require
local moduleCache = {}

-- Custom require interceptor to handle userdata Instances
local function robloxAwareRequire(target)
	if typeof(target) == "Instance" and target.ClassName == "ModuleScript" then
		if moduleCache[target] then
			return moduleCache[target]
		end

		local resolvedPath = findPathInSourcemap(target, sourcemap)
		if resolvedPath then
			-- Fallback extensions for Luau projects
			local fileSource
			local success = pcall(function()
				if fs.isFile(resolvedPath) then
					fileSource = fs.readFile(resolvedPath)
				elseif fs.isFile(resolvedPath .. ".luau") then
					fileSource = fs.readFile(resolvedPath .. ".luau")
				elseif fs.isFile(resolvedPath .. ".lua") then
					fileSource = fs.readFile(resolvedPath .. ".lua")
				elseif fs.isFile(resolvedPath .. "/init.luau") then
					fileSource = fs.readFile(resolvedPath .. "/init.luau")
				elseif fs.isFile(resolvedPath .. "/init.lua") then
					fileSource = fs.readFile(resolvedPath .. "/init.lua")
				else
					error("Not found")
				end
			end)
			if not success or not fileSource then
				error(
					"Source file missing for Instance: "
						.. target:GetFullName()
						.. " at path "
						.. tostring(resolvedPath)
				)
			end

			local bytecode = luau.compile(fileSource, { optimizationLevel = 1, debugLevel = 1 })

			local moduleEnv = setmetatable({
				script = target,
			}, { __index = executionEnv })

			local moduleWrapper = luau.load(bytecode, {
				environment = moduleEnv,
				debugName = target.Name,
			})
			local result = moduleWrapper()
			moduleCache[target] = result
			return result
		else
			error("Unmapped ModuleScript in sourcemap: " .. target:GetFullName())
		end
	elseif type(target) == "string" then
		return originalRequire(target)
	else
		error("bad argument #1 to 'require' (string or Instance expected)")
	end
end

-- Inject the environment and execute the TestEZ Bootstrap
local testRunnerSource = [[
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local ServerScriptService = game:GetService("ServerScriptService")
    local TestEZ = require(ReplicatedStorage.Packages.TestEZ)
    
    print("Executing TestEZ Suite for EvolutionTycoon...")
    local results = TestEZ.TestBootstrap:run({
        ReplicatedStorage.Shared,
        ServerScriptService.Server
    })
    
    if results.failureCount > 0 then
        print("\nCritical Failure: Testing suite identified unresolved errors.")
        process.exit(1)
    else
        process.exit(0)
    end
]]

local gameProxy = setmetatable({}, {
	__index = function(_, key)
		if key == "GameId" or key == "PlaceId" then
			return 0
		end
		if key == "BindToClose" then
			return function(self, fn)
				-- Mock BindToClose (no-op)
			end
		end
		if key == "GetService" then
			return function(self, serviceName)
				if serviceName == "Players" then
					return {
						GetPlayers = function()
							return {}
						end,
						PlayerAdded = { Connect = function() end },
						PlayerRemoving = { Connect = function() end },
					}
				end
				if serviceName == "RunService" then
					return {
						IsStudio = function()
							return true
						end,
						IsServer = function()
							return true
						end,
						IsClient = function()
							return false
						end,
					}
				end
				if serviceName == "TestService" then
					return {
						Error = function(self, str)
							print("ERROR:", str)
						end,
					}
				end
				if serviceName == "HttpService" then
					return {
						JSONEncode = function(self, obj)
							local success, res = pcall(function()
								return serde.encode("json", obj)
							end)
							if not success then
								return "{}"
							end
							return res
						end,
						JSONDecode = function(self, str)
							local success, res = pcall(function()
								return serde.decode("json", str)
							end)
							if not success then
								return {}
							end
							return res
						end,
						GenerateGUID = function(self)
							return "mock-guid-" .. tostring(math.random(1000, 9999))
						end,
					}
				end
				return game:GetService(serviceName)
			end
		end
		local val = game[key]
		if type(val) == "function" then
			return function(self, ...)
				return val(game, ...)
			end
		end
		return val
	end,
})
executionEnv.require = robloxAwareRequire
executionEnv.game = gameProxy
executionEnv.task = {
	wait = task.wait,
	spawn = function(f, ...)
		local co = coroutine.create(f)
		coroutine.resume(co, ...)
		return co
	end,
	defer = function(f, ...)
		local co = coroutine.create(f)
		coroutine.resume(co, ...)
		return co
	end,
	delay = function(t, f, ...)
		local co = coroutine.create(f)
		coroutine.resume(co, ...)
		return co
	end,
}
executionEnv.tick = os.clock
executionEnv.Random = {
	new = function()
		return {
			NextNumber = function(self, min, max)
				if min and max then
					return min + math.random() * (max - min)
				else
					return math.random()
				end
			end,
			NextInteger = function(self, min, max)
				return math.random(min, max)
			end,
		}
	end,
}
executionEnv.Instance = setmetatable({}, {
	__index = function(_, key)
		if key == "new" then
			return function(className)
				if className == "BindableEvent" then
					return {
						ClassName = "BindableEvent",
						Name = "BindableEvent",
						Fire = function() end,
						Event = {
							Connect = function()
								return { Disconnect = function() end }
							end,
						},
					}
				end
				return roblox.Instance.new(className)
			end
		end
		return roblox.Instance[key]
	end,
})
executionEnv.Color3 = roblox.Color3
executionEnv.Vector3 = roblox.Vector3
executionEnv.UDim2 = roblox.UDim2
executionEnv.DateTime = roblox.DateTime
executionEnv.process = process
local realEnum = roblox.Enum
local cachedDSRT = nil
executionEnv.Enum = setmetatable({}, {
	__index = function(_, key)
		if key == "DataStoreRequestType" then
			if cachedDSRT then
				return cachedDSRT
			end
			local dsrt = {}
			for _, name in ipairs({
				"GetAsync",
				"GetSortedAsync",
				"OnUpdate",
				"SetIncrementAsync",
				"SetIncrementSortedAsync",
				"UpdateAsync",
			}) do
				dsrt[name] = { Name = name, Value = #name }
			end
			dsrt.GetEnumItems = function()
				local items = {}
				for k, v in pairs(dsrt) do
					if type(v) == "table" then
						table.insert(items, v)
					end
				end
				return items
			end
			cachedDSRT = dsrt
			return dsrt
		end
		return realEnum[key]
	end,
})
local bytecode = luau.compile(testRunnerSource)
local testClosure = luau.load(bytecode, {
	environment = executionEnv,
	injectGlobals = true,
})

testClosure()
print("✅ System Verification Complete: All Tycoon mechanics are functioning within defined parameters.")
