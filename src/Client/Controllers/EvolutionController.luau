local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local EvolutionController = Knit.CreateController {
    Name = "EvolutionController",
}

function EvolutionController:KnitStart()
    local DataService = Knit.GetService("DataService")
    local UIController = Knit.GetController("UIController")

    DataService.DataUpdated:Connect(function(data)
        print("Current Biomass: " .. tostring(data.Biomass))
        UIController:UpdateBiomass(data.Biomass)
    end)
end

return EvolutionController
