--// Script: Bug do Pirulito (Local)
--// Autor: você :)

-- ========================
-- VERIFICAÇÃO POR USERID
-- ========================
local IDsLiberados = {
    [7679445236] = true,
}

local function _0xCheck()
    if not IDsLiberados[game.Players.LocalPlayer.UserId] then
        game.Players.LocalPlayer:Kick("Acesso negado.")
        return false
    end
    return true
end

if not _0xCheck() then return end

-- Cria a interface simples
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BugPirulito_Menu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 200)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = ScreenGui
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Text = "🍭 Bug do Pirulito"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = frame
-- Função util para criar botões
local function criarBotao(nome, ordem)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -20, 0, 40)
	btn.Position = UDim2.new(0, 10, 0, 40 + (ordem * 45))
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 16
	btn.Text = nome
	btn.Parent = frame
	return btn
end
-- Botões
local tpBtn = criarBotao("TP (Efeito Lag)", 0)
local optBtn = criarBotao("Otimização", 1)
local headBtn = criarBotao("Tira Cabeça", 2)
--// Funções
-- Simula "lag visual" local (efeito de delay de movimentação)
tpBtn.MouseButton1Click:Connect(function()
	local char = game.Players.LocalPlayer.Character
	if not char then return end
	print("Ativando TP visual (simulação de lag)...")
	for _, plr in pairs(game.Players:GetPlayers()) do
		if plr ~= game.Players.LocalPlayer and plr.Character then
			local humanoidRoot = plr.Character:FindFirstChild("HumanoidRootPart")
			if humanoidRoot then
				-- Pequeno efeito de "teleporte visual"
				local tween = game:GetService("TweenService"):Create(
					humanoidRoot,
					TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
					{CFrame = humanoidRoot.CFrame * CFrame.new(math.random(-2,2), 0, math.random(-2,2))}
				)
				tween:Play()
			end
		end
	end
end)
-- Otimização: reduz efeitos visuais locais
optBtn.MouseButton1Click:Connect(function()
	print("Otimização ativada!")
	local lp = game.Players.LocalPlayer
	local char = lp.Character
	if char then
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") then
				obj.Enabled = false
			elseif obj:IsA("Decal") then
				obj.Transparency = 1
			end
		end
	end
end)
-- Remove a cabeça visualmente (local)
headBtn.MouseButton1Click:Connect(function()
	local char = game.Players.LocalPlayer.Character
	if not char then return end
	local head = char:FindFirstChild("Head")
	if head and not head:FindFirstChild("TransparencyTag") then
		head.Transparency = 1
		local tag = Instance.new("BoolValue")
		tag.Name = "TransparencyTag"
		tag.Parent = head
		print("Cabeça escondida visualmente.")
	else
		head.Transparency = 0
		if head:FindFirstChild("TransparencyTag") then
			head.TransparencyTag:Destroy()
		end
		print("Cabeça restaurada.")
	end
end)
