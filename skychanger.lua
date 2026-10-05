local Lighting = game:GetService("Lighting")

local button = Instance.new("Part")
button.Name = "SkyButton"
button.Size = Vector3.new(6, 1, 4)
button.Position = Vector3.new(0, 3, 0)
button.Anchored = true
button.Color = Color3.fromRGB(0, 0, 255)
button.Parent = workspace

local click = Instance.new("ClickDetector")
click.MaxActivationDistance = 32
click.Parent = button

click.MouseClick:Connect(function()
	local oldSky = Lighting:FindFirstChildOfClass("Sky")
	if oldSky then
		oldSky:Destroy()
	end

	local sky = Instance.new("Sky")
	local id = "rbxassetid://111612590176617"

	sky.SkyboxBk = id
	sky.SkyboxDn = id
	sky.SkyboxFt = id
	sky.SkyboxLf = id
	sky.SkyboxRt = id
	sky.SkyboxUp = id
	sky.Parent = Lighting
end)
