-- 🛡️ PAINEL ZAGA v1
-- ========================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- ========================
-- VERIFICAÇÃO POR USERID
-- ========================
local IDsLiberados = {
    [10717684124] = true,
    [10601498397] = true,
}

local function _0xCheck()
    if not IDsLiberados[LocalPlayer.UserId] then
        LocalPlayer:Kick("Acesso negado.")
        return false
    end
    return true
end
if not _0xCheck() then return end

local Config = {
    Active = {
        AntiLag = false,
        NoClip = false,
        AutoTackle = false,
        Speed = false,
        LagNet = false
    },
    Values = {
        Speed = 25,
        TackleRange = 12,
        UpdateInterval = 0.1
    }
}

local Cache = {
    Character = nil,
    RootPart = nil,
    Humanoid = nil,
    Ball = nil,
    LastBallCheck = 0
}

local function UpdateCharacterCache()
    Cache.Character = LocalPlayer.Character
    if Cache.Character then
        Cache.RootPart = Cache.Character:FindFirstChild("HumanoidRootPart")
        Cache.Humanoid = Cache.Character:FindFirstChildOfClass("Humanoid")
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    UpdateCharacterCache()
    if Config.Active.Speed and Cache.Humanoid then
        Cache.Humanoid.WalkSpeed = Config.Values.Speed
    end
end)

UpdateCharacterCache()

local function GetBall()
    local t = tick()
    if t - Cache.LastBallCheck < 1 and Cache.Ball then return Cache.Ball end
    Cache.LastBallCheck = t
    Cache.Ball = workspace:FindFirstChild("Ball") or workspace:FindFirstChild("Football")
    return Cache.Ball
end

local function AtivarLag()
    pcall(function()
        settings().Network.IncomingReplicationLag = 0.5
        settings().Physics.AllowSleep = true
    end)
end

local function DesativarLag()
    pcall(function()
        settings().Network.IncomingReplicationLag = 0
        settings().Physics.AllowSleep = false
    end)
end

local function OptimizeBall()
    local ball = GetBall()
    if not ball then return end
    pcall(function()
        ball:SetNetworkOwner(LocalPlayer)
        if ball.AssemblyLinearVelocity.Magnitude > 100 then
            ball.AssemblyLinearVelocity = ball.AssemblyLinearVelocity * 0.85
        end
    end)
end

local function OptimizedNoClip()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            for _, part in ipairs(plr.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end

local function SmartAutoTackle()
    local ball = GetBall()
    if not ball or not Cache.RootPart then return end
    local myPos = Cache.RootPart.Position
    local closestDist = Config.Values.TackleRange
    local target = nil
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local theirRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            if theirRoot then
                local dist = (theirRoot.Position - myPos).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    target = theirRoot
                end
            end
        end
    end
    if target then
        pcall(function()
            ball.CFrame = Cache.RootPart.CFrame * CFrame.new(0, 2, -3)
            ball.AssemblyLinearVelocity = Vector3.zero
        end)
    end
end

-- GUI
local function CreateGUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "PainelZaga"
    sg.ResetOnSpawn = false
    sg.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 300, 0, 380)
    main.Position = UDim2.new(0.5, -150, 0.5, -190)
    main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    main.Active = true
    main.Draggable = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, 0, 0, 45)
    title.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    title.Text = "🛡️ PAINEL ZAGA v1"
    title.TextColor3 = Color3.fromRGB(0, 255, 150)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)

    local container = Instance.new("ScrollingFrame", main)
    container.Size = UDim2.new(1, -16, 0, 260)
    container.Position = UDim2.new(0, 8, 0, 55)
    container.BackgroundTransparency = 1
    container.ScrollBarThickness = 4
    container.AutomaticCanvasSize = Enum.AutomaticSize.Y
    container.CanvasSize = UDim2.new(0, 0, 0, 0)

    local layout = Instance.new("UIListLayout", container)
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    local function CreateButton(text, key, order)
        local btn = Instance.new("TextButton", container)
        btn.Size = UDim2.new(1, -8, 0, 36)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        btn.Text = text .. " [OFF]"
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 13
        btn.LayoutOrder = order
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        btn.MouseButton1Click:Connect(function()
            Config.Active[key] = not Config.Active[key]
            local state = Config.Active[key]
            btn.Text = text .. " [" .. (state and "ON" or "OFF") .. "]"
            btn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 120) or Color3.fromRGB(35, 35, 45)

            if key == "Speed" and Cache.Humanoid then
                Cache.Humanoid.WalkSpeed = state and Config.Values.Speed or 16
            elseif key == "LagNet" then
                if state then
                    AtivarLag()
                else
                    DesativarLag()
                end
            end
        end)
    end

    -- Speed com seletor de valor
    local speedFrame = Instance.new("Frame", container)
    speedFrame.Size = UDim2.new(1, -8, 0, 70)
    speedFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    speedFrame.LayoutOrder = 1
    Instance.new("UICorner", speedFrame).CornerRadius = UDim.new(0, 8)

    local speedBtn = Instance.new("TextButton", speedFrame)
    speedBtn.Size = UDim2.new(1, 0, 0, 36)
    speedBtn.BackgroundTransparency = 1
    speedBtn.Text = "⚡ Speed [OFF]"
    speedBtn.TextColor3 = Color3.new(1, 1, 1)
    speedBtn.Font = Enum.Font.GothamSemibold
    speedBtn.TextSize = 13

    local speedBox = Instance.new("TextBox", speedFrame)
    speedBox.Size = UDim2.new(1, -16, 0, 26)
    speedBox.Position = UDim2.new(0, 8, 0, 38)
    speedBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    speedBox.Text = tostring(Config.Values.Speed)
    speedBox.PlaceholderText = "Valor do Speed (ex: 25)"
    speedBox.TextColor3 = Color3.fromRGB(0, 255, 150)
    speedBox.Font = Enum.Font.Gotham
    speedBox.TextSize = 13
    speedBox.ClearTextOnFocus = false
    Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 6)

    speedBox.FocusLost:Connect(function()
        local num = tonumber(speedBox.Text)
        if num and num > 0 then
            Config.Values.Speed = math.clamp(num, 1, 200)
            speedBox.Text = tostring(Config.Values.Speed)
            if Config.Active.Speed and Cache.Humanoid then
                Cache.Humanoid.WalkSpeed = Config.Values.Speed
            end
        else
            speedBox.Text = tostring(Config.Values.Speed)
        end
    end)

    speedBtn.MouseButton1Click:Connect(function()
        Config.Active.Speed = not Config.Active.Speed
        local state = Config.Active.Speed
        speedBtn.Text = "⚡ Speed [" .. (state and "ON" or "OFF") .. "]"
        speedFrame.BackgroundColor3 = state and Color3.fromRGB(0, 200, 120) or Color3.fromRGB(35, 35, 45)
        if Cache.Humanoid then
            Cache.Humanoid.WalkSpeed = state and Config.Values.Speed or 16
        end
    end)

    CreateButton("🚀 Anti-Lag", "AntiLag", 2)
    CreateButton("⚽ Chute Penalti e Falta", "NoClip", 3)
    CreateButton("⚔ Desarme Alto", "AutoTackle", 4)
    CreateButton("💥 Super Desarme Alto", "LagNet", 5)

    local toggle = Instance.new("TextButton", sg)
    toggle.Size = UDim2.new(0, 50, 0, 50)
    toggle.Position = UDim2.new(0.02, 0, 0.5, -25)
    toggle.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    toggle.Text = "🛡️"
    toggle.TextSize = 22
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)

    toggle.MouseButton1Click:Connect(function()
        main.Visible = not main.Visible
    end)
end

-- Loop
local lastUpdate = 0
RunService.Heartbeat:Connect(function()
    if Config.Active.AntiLag then
        OptimizeBall()
    end

    local now = tick()
    if now - lastUpdate >= Config.Values.UpdateInterval then
        lastUpdate = now
        if Config.Active.NoClip then
            OptimizedNoClip()
        end
        if Config.Active.AutoTackle then
            SmartAutoTackle()
        end
    end
end)

CreateGUI()
print("✅ Painel Zaga v1 carregado!")
