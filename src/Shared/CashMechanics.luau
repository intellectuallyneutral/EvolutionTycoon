local CashMechanics = {}

-- Defines the scalar multiplier applied per evolution tier
local TIER_MULTIPLIERS = {
    [1] = 1.0,
    [2] = 2.5,
    [3] = 5.0,
    [4] = 15.0
}

function CashMechanics.calculateGeneration(baseCash, currentTier)
    assert(type(baseCash) == "number", "baseCash must be a numerical value")
    assert(baseCash >= 0, "baseCash cannot be a negative integer")
    
    local multiplier = TIER_MULTIPLIERS[currentTier] or 1.0
    return math.floor(baseCash * multiplier)
end

return CashMechanics
