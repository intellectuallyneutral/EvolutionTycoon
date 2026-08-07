local DataManager = {}
DataManager.__index = DataManager

-- Constructor accepts any object adhering to the DataStoreService interface
function DataManager.new(dataStoreService, player)
	local self = setmetatable({}, DataManager)
	-- Isolates the datastore per player using their UserId
	self.store = dataStoreService:GetDataStore("PlayerEvolutionData", tostring(player.UserId))
	self.player = player
	return self
end

function DataManager:LoadData()
	local success, data = pcall(function()
		return self.store:GetAsync("SaveSlot1")
	end)

	if success and data then
		return data
	end
	-- Fallback to default tycoon state upon failure or first-time load
	return { cash = 0, evolutionTier = 1 }
end

function DataManager:SaveData(cash, evolutionTier)
	local success, err = pcall(function()
		self.store:SetAsync("SaveSlot1", {
			cash = cash,
			evolutionTier = evolutionTier,
		})
	end)

	if not success then
		warn("Data Persistence Failure for Player " .. tostring(self.player.UserId) .. ": " .. tostring(err))
	end

	return success
end

return DataManager
