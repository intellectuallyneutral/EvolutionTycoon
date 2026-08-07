local CashMechanics = require(script.Parent.CashMechanics)

return function()
    describe("Tycoon Cash Generation Algorithmic Integrity", function()
        it("should accurately apply scalar evolution tier multipliers", function()
            local baseCash = 10
            local tier1Yield = CashMechanics.calculateGeneration(baseCash, 1)
            local tier2Yield = CashMechanics.calculateGeneration(baseCash, 2)
            
            expect(tier1Yield).to.equal(10)
            expect(tier2Yield).to.equal(25) 
        end)
        
        it("should trigger fatal assertions upon encountering negative financial inputs", function()
            expect(function()
                CashMechanics.calculateGeneration(-50, 1)
            end).to.throw()
        end)
        
        it("should safely default to a 1.0 multiplier for undocumented evolution tiers", function()
            local anomalousTierYield = CashMechanics.calculateGeneration(10, 999)
            expect(anomalousTierYield).to.equal(10)
        end)
    end)
end
