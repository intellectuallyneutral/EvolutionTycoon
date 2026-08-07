local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local UIController = Knit.CreateController({
	Name = "UIController",
})

function UIController:KnitInit()
	print(">>> UICONTROLLER VERSION 999 - ACID GREEN SYNC CHECK <<<")
	self.Player = Players.LocalPlayer
	self.PlayerGui = self.Player:WaitForChild("PlayerGui")
	self:CreateHUD()
end

local function FormatNumber(n)
	local formatted = tostring(n)
	local k
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		if k == 0 then
			break
		end
	end
	return formatted
end

function UIController:CreateHUD()
	-- Create ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "EvolutionHUD"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = self.PlayerGui

	-- Create Main HUD Container with Automatic Horizontal & Vertical Sizing
	local hudFrame = Instance.new("Frame")
	hudFrame.Name = "BiomassContainer"
	hudFrame.AnchorPoint = Vector2.new(0.5, 0)
	hudFrame.Position = UDim2.new(0.5, 0, 0, 20) -- Top center
	hudFrame.Size = UDim2.new(0, 0, 0, 0)
	hudFrame.AutomaticSize = Enum.AutomaticSize.XY
	hudFrame.BackgroundColor3 = Color3.fromRGB(26, 11, 46) -- Deep Void Purple
	hudFrame.BorderSizePixel = 0
	hudFrame.Parent = screenGui

	-- Add Padding around content so the box grows dynamically with space
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 24)
	padding.PaddingRight = UDim.new(0, 24)
	padding.PaddingTop = UDim.new(0, 10)
	padding.PaddingBottom = UDim.new(0, 10)
	padding.Parent = hudFrame

	-- Vertical Layout for Title + Value + Rate
	local listLayout = Instance.new("UIListLayout")
	listLayout.FillDirection = Enum.FillDirection.Vertical
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 2)
	listLayout.Parent = hudFrame

	-- Add rounded corners
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = hudFrame

	-- Add a subtle hazard orange stroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 140, 0) -- Hazard Orange
	stroke.Thickness = 2
	stroke.Parent = hudFrame

	-- Create Title Label
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.LayoutOrder = 1
	titleLabel.AutomaticSize = Enum.AutomaticSize.XY
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBlack
	titleLabel.Text = "BIOMASS"
	titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
	titleLabel.TextSize = 18
	titleLabel.Parent = hudFrame

	-- Main Biomass Number
	self.BiomassLabel = Instance.new("TextLabel")
	self.BiomassLabel.Name = "ValueLabel"
	self.BiomassLabel.LayoutOrder = 2
	self.BiomassLabel.AutomaticSize = Enum.AutomaticSize.XY
	self.BiomassLabel.BackgroundTransparency = 1
	self.BiomassLabel.Font = Enum.Font.GothamBlack
	self.BiomassLabel.Text = "0"
	self.BiomassLabel.TextColor3 = Color3.fromRGB(181, 230, 29) -- Acid Green
	self.BiomassLabel.TextSize = 32
	self.BiomassLabel.Parent = hudFrame

	-- Rate Indicator (+10/s) INSIDE box, centered below biomass balance
	self.RateLabel = Instance.new("TextLabel")
	self.RateLabel.Name = "RateLabel"
	self.RateLabel.LayoutOrder = 3
	self.RateLabel.AutomaticSize = Enum.AutomaticSize.XY
	self.RateLabel.BackgroundTransparency = 1
	self.RateLabel.Font = Enum.Font.GothamBold
	self.RateLabel.Text = "+10/s"
	self.RateLabel.TextColor3 = Color3.fromRGB(255, 140, 0) -- Hazard Orange
	self.RateLabel.TextSize = 15
	self.RateLabel.Parent = hudFrame
end

function UIController:UpdateBiomass(amount, rate)
	rate = rate or 10
	if self.BiomassLabel then
		self.BiomassLabel.Text = FormatNumber(amount)
		self.BiomassLabel.TextColor3 = Color3.fromRGB(181, 230, 29)
	end
	if self.RateLabel then
		self.RateLabel.Text = "+" .. FormatNumber(rate) .. "/s"
		self.RateLabel.TextColor3 = Color3.fromRGB(255, 140, 0) -- Hazard Orange
	end
end

return UIController
