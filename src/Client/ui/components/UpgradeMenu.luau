local UpgradeMenu = {}
UpgradeMenu.__index = UpgradeMenu

function UpgradeMenu.new(props)
	local self = setmetatable({}, UpgradeMenu)

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 300, 0, 400)
	frame.BackgroundColor3 = props.theme or Color3.fromRGB(45, 120, 255)
	frame.Position = UDim2.new(0.5, -150, 0.5, -200)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 50)
	title.Text = "Evolution Upgrade"
	title.TextSize = 24
	title.TextColor3 = Color3.new(1, 1, 1)
	title.BackgroundTransparency = 1
	title.Parent = frame

	local costLabel = Instance.new("TextLabel")
	costLabel.Size = UDim2.new(1, 0, 0, 50)
	costLabel.Position = UDim2.new(0, 0, 0, 100)
	costLabel.Text = "Cost: " .. tostring(props.cost)
	costLabel.TextSize = 20
	costLabel.BackgroundTransparency = 1
	costLabel.Parent = frame

	self.Instance = frame
	self.CostLabel = costLabel
	return self
end

function UpgradeMenu:Update(props)
	if props.controls.ThemeColor then
		self.Instance.BackgroundColor3 = props.controls.ThemeColor
	end
	if props.controls.UpgradeCost then
		self.CostLabel.Text = "Cost: " .. tostring(props.controls.UpgradeCost)
	end
end

function UpgradeMenu:Destroy()
	if self.Instance then
		self.Instance:Destroy()
	end
end

return UpgradeMenu
