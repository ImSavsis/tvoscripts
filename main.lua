--[[ TVOS V17 - PROTECTED | ds: https://discord.gg/6mkPrSdgVa ]]--
local _0x5F2A = "Players"; local _0x1A2B = "RunService"; local _0x99C2 = "UserInputService"; local _0xCC11 = "CurrentCamera"
local llllIIIIllll = game:GetService(_0x5F2A)
local IIlIlIlIlIll = game:GetService(_0x1A2B)
local lIlIlIlIlIlI = game:GetService(_0x99C2)
local lllIIlllIIII = workspace[_0xCC11]
local lIIIIllllIIl = llllIIIIllll.LocalPlayer

local _v = {V = {E = true, B = true, N = true, H = true, S = true, TC = true, C = Color3.fromRGB(170,0,255), T = 2, TS = 16}, A = {E = true, K = Enum.UserInputType.MouseButton2, P = "Head", F = 300, PR = 0.165, SM = 1}, M = {F = false, S = 60, W = false}}
local _a = true; local _eo = {}; local _c = {}; local _ar = false

local function _f1(c, t) local l = Drawing.new("Line") l.Color = c or Color3.new(1,1,1) l.Thickness = t or 2 l.Visible = false return l end
local function _f2(tx, c, s) local t = Drawing.new("Text") t.Text = tx or "" t.Color = c or Color3.new(1,1,1) t.Size = s or 16 t.Center = true t.Outline = true t.Visible = false return t end
local function _f3(c, t) local s = Drawing.new("Square") s.Color = c or Color3.new(1,1,1) s.Thickness = t or 2 s.Filled = false s.Visible = false return s end

local _ch1 = _f1(Color3.fromRGB(0,255,0), 2); local _ch2 = _f1(Color3.fromRGB(0,255,0), 2)

local function _get() local cl = nil; local sd = _v.A.F; local mp = lIlIlIlIlIlI:GetMouseLocation()
for _, p in pairs(llllIIIIllll:GetPlayers()) do if p ~= lIIIIllllIIl and p.Character and p.Character:FindFirstChild(_v.A.P) then
if _v.V.TC and p.Team == lIIIIllllIIl.Team then continue end
local h = p.Character:FindFirstChild("Humanoid") if h and h.Health > 0 then
local pt = p.Character[_v.A.P] local ps, vs = lllIIlllIIII:WorldToViewportPoint(pt.Position)
if vs then local d = (Vector2.new(ps.X, ps.Y) - mp).Magnitude if d < sd then cl = p; sd = d end end end end end return cl end

local function _esp(p) local cn = IIlIlIlIlIll.RenderStepped:Connect(function() if not _a then return end
if not _eo[p.Name] then _eo[p.Name] = {b = _f3(_v.V.C, _v.V.T), n = _f2(p.Name, Color3.new(1,1,1), _v.V.TS), h = _f1(Color3.fromRGB(0,255,0), 2), s = {h_t = _f1(_v.V.C, 1), t_la = _f1(_v.V.C, 1), t_ra = _f1(_v.V.C, 1), t_ll = _f1(_v.V.C, 1), t_rl = _f1(_v.V.C, 1)}} end
local d = _eo[p.Name]; local ch = p.Character; local hm = ch and ch:FindFirstChild("Humanoid") local hr = ch and ch:FindFirstChild("HumanoidRootPart")
local it = (p.Team == lIIIIllllIIl.Team) local ss = _v.V.E and (not _v.V.TC or not it)
if not ch or not hm or hm.Health <= 0 or not hr or not ss then d.b.Visible = false; d.n.Visible = false; d.h.Visible = false for _, v in pairs(d.s) do v.Visible = false end return end
local hd = ch:FindFirstChild("Head") if not hd then return end
local ps, vs = lllIIlllIIII:WorldToViewportPoint(hr.Position) if vs then
local headPos = lllIIlllIIII:WorldToViewportPoint(hd.Position) local legPos = lllIIlllIIII:WorldToViewportPoint(hr.Position - Vector3.new(0,3.5,0))
local h = math.abs(headPos.Y - legPos.Y) local w = h / 2
d.b.Size = Vector2.new(w, h); d.b.Position = Vector2.new(headPos.X - w/2, headPos.Y); d.b.Visible = _v.V.B; d.b.Color = _v.V.C
d.n.Position = Vector2.new(headPos.X, headPos.Y - (_v.V.TS + 2)); d.n.Visible = _v.V.N; d.n.Size = _v.V.TS
if _v.V.H then local h_r = hm.Health / hm.MaxHealth d.h.From = Vector2.new(headPos.X - w/2 - 5, legPos.Y) d.h.To = Vector2.new(headPos.X - w/2 - 5, headPos.Y + (h * (1-h_r))) d.h.Visible = true else d.h.Visible = false end
else d.b.Visible = false; d.n.Visible = false; d.h.Visible = false end end) table.insert(_c, cn) end

for _, p in pairs(llllIIIIllll:GetPlayers()) do if p ~= lIIIIllllIIl then _esp(p) end end
table.insert(_c, llllIIIIllll.PlayerAdded:Connect(function(p) if p ~= lIIIIllllIIl then _esp(p) end end))

-- [ UI Block simplified to save space and obfuscate intent ]
local SG = Instance.new("ScreenGui", game.CoreGui); local M = Instance.new("Frame", SG)
M.Size = UDim2.new(0, 240, 0, 500); M.Position = UDim2.new(0.05, 0, 0.2, 0); M.BackgroundColor3 = Color3.fromRGB(15, 10, 20); M.Active = true; M.Draggable = true
local T = Instance.new("TextLabel", M); T.Size = UDim2.new(1, 0, 0, 35); T.Text = "TVOS PROTECT"; T.BackgroundColor3 = Color3.fromRGB(30, 0, 60); T.TextColor3 = Color3.new(1,1,1)

IIlIlIlIlIll.RenderStepped:Connect(function() if not _a then return end
if _ar and _v.A.E then local tg = _get() if tg then local tp = tg.Character[_v.A.P].Position
if tg.Character:FindFirstChild("HumanoidRootPart") then tp = tp + (tg.Character.HumanoidRootPart.Velocity * _v.A.PR) end
lllIIlllIIII.CFrame = CFrame.new(lllIIlllIIII.CFrame.Position, tp) end end
if _v.M.F and lIIIIllllIIl.Character then
local h = lIIIIllllIIl.Character:FindFirstChild("HumanoidRootPart") if h then
local b = h:FindFirstChild("TF") or Instance.new("BodyVelocity", h) b.Name = "TF"; b.MaxForce = Vector3.new(1e6,1e6,1e6)
local d = Vector3.new(0,0,0) if lIlIlIlIlIlI:IsKeyDown(Enum.KeyCode.W) then d += lllIIlllIIII.CFrame.LookVector end
b.Velocity = d * _v.M.S; lIIIIllllIIl.Character.Humanoid.PlatformStand = true end end end)

lIlIlIlIlIlI.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.Home then M.Visible = not M.Visible end if i.UserInputType == _v.A.K then _ar = true end end)
lIlIlIlIlIlI.InputEnded:Connect(function(i) if i.UserInputType == _v.A.K then _ar = false end end)
