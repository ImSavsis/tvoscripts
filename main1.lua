local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Config = {
    Visuals = {
        Enabled = true,
        Boxes = true,
        Names = true,
        Health = true,
        Skeletons = true,
        TeamCheck = true,
        Color = Color3.fromRGB(170, 0, 255),
        Thickness = 2,
        TextSize = 16,
        Hue = 0.75
    },
    Aimbot = {
        Enabled = true,
        Key = Enum.UserInputType.MouseButton2,
        LockPart = "Head",
        FOV = 300,
        Prediction = 0.165, -- Коэффициент предсказания (подходит для большинства пушек)
        Smoothness = 1 -- 1 = жесткий лок, выше = плавнее
    },
    Crosshair = {
        Enabled = false,
        Size = 10,
        Thickness = 2,
        Color = Color3.fromRGB(0, 255, 0)
    },
    Movement = {
        Fly = false,
        Noclip = false,
        FlySpeed = 60,
        Wallbang = false
    }
}

local Active = true
local ESPObjects = {}
local Connections = {}
local AimRunning = false

local function CreateLine(color, thickness)
    local l = Drawing.new("Line")
    l.Color = color or Color3.new(1,1,1)
    l.Thickness = thickness or 2
    l.Visible = false
    return l
end

local function CreateText(text, color, size)
    local t = Drawing.new("Text")
    t.Text = text or ""
    t.Color = color or Color3.new(1,1,1)
    t.Size = size or 16
    t.Center = true
    t.Outline = true
    t.Visible = false
    return t
end

local function CreateSquare(color, thickness)
    local s = Drawing.new("Square")
    s.Color = color or Color3.new(1,1,1)
    s.Thickness = thickness or 2
    s.Filled = false
    s.Visible = false
    return s
end

local CrosshairL1 = CreateLine(Config.Crosshair.Color, Config.Crosshair.Thickness)
local CrosshairL2 = CreateLine(Config.Crosshair.Color, Config.Crosshair.Thickness)

local function GetClosestPlayerToMouse()
    local closest = nil
    local shortestDist = Config.Aimbot.FOV
    local mousePos = UserInputService:GetMouseLocation()

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild(Config.Aimbot.LockPart) then
            if Config.Visuals.TeamCheck and plr.Team == LocalPlayer.Team then continue end
            local hum = plr.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local part = plr.Character[Config.Aimbot.LockPart]
                local pos, vis = Camera:WorldToViewportPoint(part.Position)
                if vis then
                    local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if dist < shortestDist then
                        closest = plr
                        shortestDist = dist
                    end
                end
            end
        end
    end
    return closest
end

local function DrawESP(plr)
    local conn = RunService.RenderStepped:Connect(function()
        if not Active then return end
        if not ESPObjects[plr.Name] then
            ESPObjects[plr.Name] = {
                box = CreateSquare(Config.Visuals.Color, Config.Visuals.Thickness),
                name = CreateText(plr.Name, Color3.new(1,1,1), Config.Visuals.TextSize),
                health = CreateLine(Color3.fromRGB(0, 255, 0), 2),
                skel = {
                    h_t = CreateLine(Config.Visuals.Color, 1),
                    t_la = CreateLine(Config.Visuals.Color, 1),
                    t_ra = CreateLine(Config.Visuals.Color, 1),
                    t_ll = CreateLine(Config.Visuals.Color, 1),
                    t_rl = CreateLine(Config.Visuals.Color, 1)
                }
            }
        end

        local data = ESPObjects[plr.Name]
        local char = plr.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local isTeam = (plr.Team == LocalPlayer.Team)
        local shouldShow = Config.Visuals.Enabled and (not Config.Visuals.TeamCheck or not isTeam)

        if not char or not hum or hum.Health <= 0 or not hrp or not shouldShow then
            data.box.Visible = false; data.name.Visible = false; data.health.Visible = false
            for _, v in pairs(data.skel) do v.Visible = false end
            return
        end

        local head = char:FindFirstChild("Head")
        if not head then return end
        
        local pos, vis = Camera:WorldToViewportPoint(hrp.Position)
        if vis then
            local t = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
            local la = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm")
            local ra = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm")
            local ll = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg")
            local rl = char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg")

            if Config.Visuals.Boxes or Config.Visuals.Names or Config.Visuals.Health then
                local headPos = Camera:WorldToViewportPoint(head.Position)
                local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,3.5,0))
                local h = math.abs(headPos.Y - legPos.Y)
                local w = h / 2
                data.box.Size = Vector2.new(w, h)
                data.box.Position = Vector2.new(headPos.X - w/2, headPos.Y)
                data.box.Visible = Config.Visuals.Boxes
                data.box.Color = Config.Visuals.Color
                data.name.Position = Vector2.new(headPos.X, headPos.Y - (Config.Visuals.TextSize + 2))
                data.name.Visible = Config.Visuals.Names
                data.name.Size = Config.Visuals.TextSize
                if Config.Visuals.Health then
                    local hr = hum.Health / hum.MaxHealth
                    data.health.From = Vector2.new(headPos.X - w/2 - 5, legPos.Y)
                    data.health.To = Vector2.new(headPos.X - w/2 - 5, headPos.Y + (h * (1-hr)))
                    data.health.Visible = true
                else data.health.Visible = false end
            end

            if Config.Visuals.Skeletons and head and t and la and ra and ll and rl then
                local function s(p1, p2, l)
                    local p1v, v1 = Camera:WorldToViewportPoint(p1.Position)
                    local p2v, v2 = Camera:WorldToViewportPoint(p2.Position)
                    if v1 and v2 then
                        l.Visible = true; l.From = Vector2.new(p1v.X, p1v.Y); l.To = Vector2.new(p2v.X, p2v.Y); l.Color = Config.Visuals.Color
                    else l.Visible = false end
                end
                s(head, t, data.skel.h_t); s(t, la, data.skel.t_la); s(t, ra, data.skel.t_ra); s(t, ll, data.skel.t_ll); s(t, rl, data.skel.t_rl)
            else
                for _, v in pairs(data.skel) do v.Visible = false end
            end
        else
            data.box.Visible = false; data.name.Visible = false; data.health.Visible = false
            for _, v in pairs(data.skel) do v.Visible = false end
        end
    end)
    table.insert(Connections, conn)
end

for _, plr in pairs(Players:GetPlayers()) do if plr ~= LocalPlayer then DrawESP(plr) end end
table.insert(Connections, Players.PlayerAdded:Connect(function(plr) if plr ~= LocalPlayer then DrawESP(plr) end end))

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 240, 0, 500); Main.Position = UDim2.new(0.05, 0, 0.2, 0); Main.BackgroundColor3 = Color3.fromRGB(15, 10, 20); Main.BorderSizePixel = 2; Main.BorderColor3 = Config.Visuals.Color; Main.Active = true; Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35); Title.Text = "TVOS SCRIPTS V17"; Title.BackgroundColor3 = Color3.fromRGB(30, 0, 60); Title.TextColor3 = Color3.new(1,1,1); Title.Font = Enum.Font.GothamBold

local Content = Instance.new("ScrollingFrame", Main)
Content.Position = UDim2.new(0,0,0,40); Content.Size = UDim2.new(1,0,1,-40); Content.BackgroundTransparency = 1; Content.CanvasSize = UDim2.new(0,0,3.0,0); Content.ScrollBarThickness = 4
Instance.new("UIListLayout", Content).HorizontalAlignment = "Center"; Content.UIListLayout.Padding = UDim.new(0, 5)

local function AddToggle(text, configTable, configValue)
    local btn = Instance.new("TextButton", Content)
    btn.Size = UDim2.new(0.9, 0, 0, 30); btn.Text = text; btn.BackgroundColor3 = configTable[configValue] and Config.Visuals.Color or Color3.fromRGB(40, 40, 40); btn.TextColor3 = Color3.new(1,1,1)
    btn.MouseButton1Click:Connect(function() 
        configTable[configValue] = not configTable[configValue] 
        btn.BackgroundColor3 = configTable[configValue] and Config.Visuals.Color or Color3.fromRGB(40, 40, 40)
        if text == "Wallbang" then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v:IsDescendantOf(LocalPlayer.Character) and not Players:GetPlayerFromCharacter(v.Parent) then
                    v.CanQuery = not configTable[configValue]
                end
            end
        end
    end)
end

local function AddSlider(text, min, max, configTable, configValue)
    local container = Instance.new("Frame", Content); container.Size = UDim2.new(0.9, 0, 0, 45); container.BackgroundTransparency = 1
    local label = Instance.new("TextLabel", container); label.Size = UDim2.new(1, 0, 0, 20); label.Text = text .. ": " .. configTable[configValue]; label.TextColor3 = Color3.new(1,1,1); label.BackgroundTransparency = 1
    local sliderBar = Instance.new("Frame", container); sliderBar.Size = UDim2.new(1, 0, 0, 8); sliderBar.Position = UDim2.new(0, 0, 0, 25); sliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    local sliderBtn = Instance.new("TextButton", sliderBar); sliderBtn.Size = UDim2.new(0, 10, 1, 0); sliderBtn.BackgroundColor3 = Config.Visuals.Color; sliderBtn.Text = ""
    sliderBtn.MouseButton1Down:Connect(function()
        local move; move = RunService.RenderStepped:Connect(function()
            local rel = math.clamp((UserInputService:GetMouseLocation().X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (rel * (max - min)))
            configTable[configValue] = val
            label.Text = text .. ": " .. val
            sliderBtn.Position = UDim2.new(rel, -5, 0, 0)
            if text == "ESP Color" then Config.Visuals.Color = Color3.fromHSV(val/100, 1, 1); Main.BorderColor3 = Config.Visuals.Color end
        end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then move:Disconnect() end end)
    end)
end

AddToggle("ESP Enabled", Config.Visuals, "Enabled")
AddToggle("ESP Boxes", Config.Visuals, "Boxes")
AddToggle("ESP Skeleton", Config.Visuals, "Skeletons")
AddToggle("Team Check", Config.Visuals, "TeamCheck")
AddToggle("Crosshair", Config.Crosshair, "Enabled")
AddToggle("AimLock (RMB)", Config.Aimbot, "Enabled")
AddToggle("Wallbang", Config.Movement, "Wallbang")
AddToggle("Fly Mode", Config.Movement, "Fly")
AddSlider("ESP Color", 0, 100, Config.Visuals, "Hue")
AddSlider("ESP Text Size", 10, 30, Config.Visuals, "TextSize")
AddSlider("Fly Speed", 20, 300, Config.Movement, "FlySpeed")

local UnloadBtn = Instance.new("TextButton", Content)
UnloadBtn.Size = UDim2.new(0.9, 0, 0, 35); UnloadBtn.Text = "UNLOAD"; UnloadBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0); UnloadBtn.TextColor3 = Color3.new(1,1,1)
UnloadBtn.MouseButton1Click:Connect(function()
    Active = false
    ScreenGui:Destroy()
    CrosshairL1:Remove(); CrosshairL2:Remove()
    for _, obj in pairs(ESPObjects) do
        obj.box:Remove(); obj.name:Remove(); obj.health:Remove()
        for _, l in pairs(obj.skel) do l:Remove() end
    end
    for _, c in pairs(Connections) do c:Disconnect() end
end)

local mainLoop = RunService.RenderStepped:Connect(function()
    if not Active then return end
    
    if Config.Crosshair.Enabled then
        local center = Camera.ViewportSize / 2
        CrosshairL1.Visible = true; CrosshairL1.From = Vector2.new(center.X - Config.Crosshair.Size, center.Y); CrosshairL1.To = Vector2.new(center.X + Config.Crosshair.Size, center.Y)
        CrosshairL2.Visible = true; CrosshairL2.From = Vector2.new(center.X, center.Y - Config.Crosshair.Size); CrosshairL2.To = Vector2.new(center.X, center.Y + Config.Crosshair.Size)
    else CrosshairL1.Visible = false; CrosshairL2.Visible = false end

    if AimRunning and Config.Aimbot.Enabled then
        local target = GetClosestPlayerToMouse()
        if target and target.Character and target.Character:FindFirstChild(Config.Aimbot.LockPart) then
            local targetPart = target.Character[Config.Aimbot.LockPart]
            local visualPos = targetPart.Position
            
            -- Prediction (Учет скорости цели)
            if target.Character:FindFirstChild("HumanoidRootPart") then
                visualPos = visualPos + (target.Character.HumanoidRootPart.Velocity * Config.Aimbot.Prediction)
            end

            if Config.Aimbot.Smoothness <= 1 then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, visualPos)
            else
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, visualPos), 1 / Config.Aimbot.Smoothness)
            end
        end
    end

    if Config.Movement.Fly and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bv = hrp:FindFirstChild("TvosFly") or Instance.new("BodyVelocity", hrp)
            bv.MaxForce = Vector3.new(1e6, 1e6, 1e6); bv.Name = "TvosFly"
            local dir = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
            bv.Velocity = dir * Config.Movement.FlySpeed
            LocalPlayer.Character.Humanoid.PlatformStand = true
        end
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local bv = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("TvosFly")
            if bv then bv:Destroy() end
            LocalPlayer.Character.Humanoid.PlatformStand = false
        end
    end
end)
table.insert(Connections, mainLoop)

table.insert(Connections, UserInputService.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.Home then Main.Visible = not Main.Visible end
    if i.UserInputType == Config.Aimbot.Key then AimRunning = true end
end))

table.insert(Connections, UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Config.Aimbot.Key then AimRunning = false end
end))
