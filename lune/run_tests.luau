local fs = require("@lune/fs")
local luau = require("@lune/luau")
local roblox = require("@lune/roblox")
local serde = require("@lune/serde")

print("Initializing Headless Testing Environment via Lune with Custom Require Interceptor...")

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

-- Recursive search algorithm to map virtual Instances to physical file paths
local function findPathInSourcemap(targetInstance, currentMapNode)
	if currentMapNode.name == targetInstance.Name then
		if currentMapNode.filePaths and #currentMapNode.filePaths > 0 then
			return currentMapNode.filePaths[1]
		end
	end
	for _, childNode in pairs(currentMapNode.children or {}) do
		local childPath = findPathInSourcemap(targetInstance, childNode)
		if childPath then
			return childPath
		end
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
			}, { __index = getfenv() })

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
        error("Critical Failure: Testing suite identified unresolved errors.")
    end
]]

local gameProxy = setmetatable({}, {
	__index = function(_, key)
		if key == "GameId" or key == "PlaceId" then
			return 12345
		end
		if key == "GetService" then
			return function(self, serviceName)
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
local executionEnv = getfenv()
executionEnv.require = robloxAwareRequire
executionEnv.game = gameProxy
executionEnv.task = {
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

local bytecode = luau.compile(testRunnerSource)
local testClosure = luau.load(bytecode, {
	environment = executionEnv,
	injectGlobals = true,
})

testClosure()
print("✅ System Verification Complete: All Tycoon mechanics are functioning within defined parameters.")
