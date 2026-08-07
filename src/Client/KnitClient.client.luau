-- Client bootstrap: initializes Knit framework and loads all Controllers
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Dynamically load all Controllers in this directory
Knit.AddControllers(script.Parent.Controllers)

Knit.Start()
	:andThen(function()
		print("[PROMETHEUS] Knit Client initialized successfully")
	end)
	:catch(function(err)
		warn("[PROMETHEUS] Knit Client failed to start:", err)
	end)
