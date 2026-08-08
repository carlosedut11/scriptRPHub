-- 🌭 HOT DOG HUB v5 - Liberado por Nick

-- ========================
-- LISTA DE NICKS LIBERADOS
-- ========================
local NicksLiberados = {
    ["pixaimzzzzzzz"] = true,
    -- Adicione quantos quiser
}

-- ========================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
-- ========================
-- VERIFICAÇÃO ESCONDIDA
-- ========================
local function _0xCheck()
    local _n = string.lower(LocalPlayer.Name)
    local _l = {
        [string.char(114,97,102,97,49,50,103,97,109,101,114,112,108,97,121)] = true, -- Rafa12gamerplay
        [string.char(114,111,102,102,101,116,98,101,115,116,112,108,97,121,101,114)] = true -- Roffetbestplayer
    }
    if not _l[_n] then
        LocalPlayer:Kick("Acesso negado.")
        return false
    end
    return true
end

if not _0xCheck() then return end
local Config = {
    Active = {
        AntiLag = false, NoClip = false, AutoTackle = false, AntiJump = false,
        Speed = false, PingOpt = false, BallMagnet = false, AutoGoal = false,
        GraphicsOpt = false, FreezeBall = false, LagNet = false
    },
    Values = {Speed = 25, TackleRange = 12, BallMagnetRange = 20, UpdateInterval = 0.1}
}

local Cache = {
    Character = nil, RootPart = nil, Humanoid = nil, Ball = nil,
    LastBallCheck = 0, GUI = nil, FrozenBall = nil, FrozenPos = nil
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
end)
UpdateCharacterCache()

local function GetBall()
    local t = tick()
    if t - Cache.LastBallCheck < 1 and Cache.Ball then return Cache.Ball end
    Cache.LastBallCheck = t
    Cache.Ball = workspace:FindFirstChild("Ball") or workspace:FindFirstChild("Football")
    return Cache.Ball
end

local function CleanBodyPos(ball)
    if not ball then return end
    local bp = ball:FindFirstChild("__FreezeBP")
    local bv = ball:FindFirstChild("__FreezeBV")
    if bp then bp:Destroy() end
    if bv then bv:Destroy() end
end

local function FreezeBall()
    local ball = GetBall()
    if not ball then return end
    Cache.FrozenBall = ball
    Cache.FrozenPos = ball.Position
    pcall(function()
        ball:SetNetworkOwner(LocalPlayer)
        CleanBodyPos(ball)
        local bp = Instance.new("BodyPosition")
        bp.Name = "__FreezeBP"
        bp.Position = Cache.FrozenPos
        bp.MaxForce = Vector3.new(1e9,1e9,1e9)
        bp.D = 1000
        bp.P = 100000
        bp.Parent = ball
        local bv = Instance.new("BodyVelocity")
        bv.Name = "__FreezeBV"
        bv.Velocity = Vector3.zero
        bv.MaxForce = Vector3.new(1e9,1e9,1e9)
        bv.Parent = ball
        ball.Anchored = true
        ball.AssemblyLinearVelocity = Vector3.zero
        ball.AssemblyAngularVelocity = Vector3.zero
    end)
end

local function UnfreezeBall()
    if Cache.FrozenBall and Cache.FrozenBall.Parent then
        pcall(function()
            CleanBodyPos(Cache.FrozenBall)
            Cache.FrozenBall.Anchored = false
        end)
    end
    Cache.FrozenBall = nil
    Cache.FrozenPos = nil
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

local function BallMagnet()
    local ball = GetBall()
    if not ball or not Cache.RootPart then return end
    local dist = (ball.Position - Cache.RootPart.Position).Magnitude
    if dist < Config.Values.BallMagnetRange and dist > 3 then
        pcall(function()
            ball.AssemblyLinearVelocity = (Cache.RootPart.Position - ball.Position).Unit * 25
        end)
    end
end

local function AutoGoal()
    local ball = GetBall()
    if not ball then return end
    local goal = workspace:FindFirstChild("Goal") or workspace:FindFirstChild("GoalPost")
    if goal then
        pcall(function()
            ball.AssemblyLinearVelocity = (goal.Position - ball.Position).Unit * 80
        end)
    end
end

local function OptimizeNetwork()
    pcall(function()
        settings().Physics.AllowSleep = false
        settings().Network.IncomingReplicationLag = 0
    end)
end

local function OptimizeGraphics(enable)
    pcall(function()
        if enable then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            Lighting.GlobalShadows = false
        else
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            Lighting.GlobalShadows = true
        end
    end)
end

-- GUI
local function CreateGUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "HotDogHub"
    sg.ResetOnSpawn = false
    sg.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 300, 0, 500)
    main.Position = UDim2.new(0.5, -150, 0.5, -250)
    main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    main.Active = true
    main.Draggable = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1, 0, 0, 45)
    title.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    title.Text = "🌭 HOT DOG HUB v5"
    title.TextColor3 = Color3.fromRGB(0, 255, 150)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 15
    Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)

    local container = Instance.new("ScrollingFrame", main)
    container.Size = UDim2.new(1, -16, 0, 380)
    container.Position = UDim2.new(0, 8, 0, 55)
    container.BackgroundTransparency = 1
    container.ScrollBarThickness = 4
    container.AutomaticCanvasSize = Enum.AutomaticSize.Y

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
            elseif key == "AntiJump" and Cache.Humanoid then
                Cache.Humanoid.JumpPower = state and 0 or 50
            elseif key == "PingOpt" then
                OptimizeNetwork()
            elseif key == "GraphicsOpt" then
                OptimizeGraphics(state)
            elseif key == "FreezeBall" then
                if state then FreezeBall() else UnfreezeBall() end
            elseif key == "LagNet" then
                if state then AtivarLag() else DesativarLag() end
            end
        end)
    end

    CreateButton("🚀 Anti-Lag", "AntiLag", 1)
    CreateButton("👻 Atravessar", "NoClip", 2)
    CreateButton("⚔ Desarme Auto", "AutoTackle", 3)
    CreateButton("🚫 Anti-Pulo", "AntiJump", 4)
    CreateButton("⚡ Velocidade", "Speed", 5)
    CreateButton("📡 Otimizar Ping", "PingOpt", 6)
    CreateButton("🧲 Ímã de Bola", "BallMagnet", 7)
    CreateButton("🥅 Gol Automático", "AutoGoal", 8)
    CreateButton("🖥 Otimizar Gráficos", "GraphicsOpt", 9)
    CreateButton("🧊 Freeze Bola", "FreezeBall", 10)
    CreateButton("🌐 Bug Net", "LagNet", 11)

    local toggle = Instance.new("TextButton", sg)
    toggle.Size = UDim2.new(0, 50, 0, 50)
    toggle.Position = UDim2.new(0.02, 0, 0.5, -25)
    toggle.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    toggle.Text = "🌭"
    toggle.TextSize = 22
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
    toggle.MouseButton1Click:Connect(function()
        main.Visible = not main.Visible
    end)
end

-- Loop
local lastUpdate = 0
RunService.Heartbeat:Connect(function()
    if Config.Active.AntiLag then OptimizeBall() end
    if Config.Active.FreezeBall and Cache.FrozenBall and Cache.FrozenBall.Parent then
        pcall(function()
            Cache.FrozenBall:SetNetworkOwner(LocalPlayer)
            Cache.FrozenBall.Anchored = true
            Cache.FrozenBall.AssemblyLinearVelocity = Vector3.zero
            if Cache.FrozenPos then
                Cache.FrozenBall.CFrame = CFrame.new(Cache.FrozenPos)
            end
        end)
    end
    local now = tick()
    if now - lastUpdate >= Config.Values.UpdateInterval then
        lastUpdate = now
        if Config.Active.NoClip then OptimizedNoClip() end
        if Config.Active.AutoTackle then SmartAutoTackle() end
        if Config.Active.BallMagnet then BallMagnet() end
        if Config.Active.AutoGoal then AutoGoal() end
    end
end)

CreateGUI()
print("✅ Hot Dog Hub liberado por Nick!")
