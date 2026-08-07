local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UILabs = require(ReplicatedStorage.Packages.UI_Labs)
local UpgradeMenu = require(script.Parent.Parent.components.UpgradeMenu)

local CreateGenericStory = UILabs.CreateGenericStory

local story = CreateGenericStory({
	controls = {
		PlayerBalance = UILabs.Number(1000, 0, 10000, 100),
		UpgradeCost = UILabs.Number(250, 0, 5000, 50),
		ThemeColor = UILabs.Color(Color3.fromRGB(45, 120, 255)),
		IsMaxLevel = UILabs.Boolean(false),
	},
}, function(props)
	-- The props.subscribe method listens for real-time changes from the UI Labs control panel
	local componentInstance = UpgradeMenu.new({
		balance = props.controls.PlayerBalance,
		cost = props.controls.UpgradeCost,
		theme = props.controls.ThemeColor,
		isMax = props.controls.IsMaxLevel,
	})

	props.subscribe(function(values)
		if componentInstance.Update then
			componentInstance:Update(values)
		end
	end)

	componentInstance.Instance.Parent = props.target

	-- Return a cleanup function for the hot-reloader to execute prior to remounting
	return function()
		componentInstance:Destroy()
	end
end)

return story
