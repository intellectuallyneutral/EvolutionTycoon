-- Server bootstrap: initializes Knit framework and loads all Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Dynamically load all Services in this directory
Knit.AddServices(script.Parent.Services)

Knit.Start():andThen(function()
	print("[PROMETHEUS] Knit Server initialized successfully")
end):catch(function(err)
	warn("[PROMETHEUS] Knit Server failed to start:", err)
end)
