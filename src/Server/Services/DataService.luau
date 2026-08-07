local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage.Packages.Knit)
local ProfileStore = require(game:GetService("ServerScriptService").Server.ProfileStore)

local DataService = Knit.CreateService {
    Name = "DataService",
    Client = {
        DataUpdated = Knit.CreateSignal(),
    },
}

local PlayerProfileTemplate = {
    Biomass = 600000000,
    Stage = 1,
}

local GameProfileStore = ProfileStore.New("PlayerData_v1", PlayerProfileTemplate)
DataService.Profiles = {}

function DataService:KnitStart()
    local function PlayerAdded(player)
        local profile = GameProfileStore:StartSessionAsync("Player_" .. player.UserId)
        if profile ~= nil then
            profile:AddUserId(player.UserId)
            profile:Reconcile()
            profile.OnSessionEnd:Connect(function()
                self.Profiles[player] = nil
                player:Kick("Profile was loaded on another Roblox server.")
            end)
            if player:IsDescendantOf(Players) then
                self.Profiles[player] = profile
                self.Client.DataUpdated:Fire(player, profile.Data)
            else
                profile:EndSession()
            end
        else
            player:Kick("Failed to load data. Please rejoin.")
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        task.spawn(PlayerAdded, player)
    end
    Players.PlayerAdded:Connect(PlayerAdded)

    Players.PlayerRemoving:Connect(function(player)
        local profile = self.Profiles[player]
        if profile ~= nil then
            profile:EndSession()
        end
    end)
end

function DataService:GetProfile(player)
    return self.Profiles[player]
end

return DataService
