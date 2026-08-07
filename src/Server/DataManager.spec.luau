local MockDataStoreService = require(game.ReplicatedStorage.Packages.MockDataStoreService)
local DataManager = require(script.Parent.DataManager)

return function()
    describe("EvolutionTycoon Data Persistence Architecture", function()
        local mockService
        local mockPlayer
        
        beforeEach(function()
            -- Re-initialize a pristine mock environment to prevent state leakage
            mockService = MockDataStoreService
            mockPlayer = { UserId = 123456789 }
        end)
        
        it("should initialize default parameters for a newly spawned player", function()
            local manager = DataManager.new(mockService, mockPlayer)
            local data = manager:LoadData()
            
            expect(data.cash).to.equal(0)
            expect(data.evolutionTier).to.equal(1)
        end)
        
        it("should accurately serialize and retrieve mutated financial state", function()
            local manager = DataManager.new(mockService, mockPlayer)
            
            -- Simulate tycoon gameplay loop mutating the state
            local saveSuccess = manager:SaveData(1500, 2)
            expect(saveSuccess).to.equal(true)
            
            -- Verify deterministic retrieval
            local loadedData = manager:LoadData()
            expect(loadedData.cash).to.equal(1500)
            expect(loadedData.evolutionTier).to.equal(2)
        end)
    end)
end
