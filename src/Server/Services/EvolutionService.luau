local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage.Packages.Knit)

local EvolutionService = Knit.CreateService {
    Name = "EvolutionService",
    Client = {},
}

function EvolutionService:KnitStart()
    local DataService = Knit.GetService("DataService")

    task.spawn(function()
        while task.wait(1) do
            for _, player in ipairs(Players:GetPlayers()) do
                local profile = DataService:GetProfile(player)
                if profile then
                    profile.Data.Biomass += 10
                    DataService.Client.DataUpdated:Fire(player, profile.Data)
                end
            end
        end
    end)
end

return EvolutionService
