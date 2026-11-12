--[[
Cozy Hub v9.8  |  Delta / Xeno
Ключ меняется в переменной KEY.
Открыть/закрыть меню: RightShift или тап по иконке.
Двойной тап по иконке: закрепить / открепить.
Флай: колесо мыши (средняя кнопка) или переключатель во вкладке "Игрок".
]]
local KEY = "2222"
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting     = game:GetService("Lighting")
local CoreGui      = game:GetService("CoreGui")
local HttpService  = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local LP     = Players.LocalPlayer
local Camera = workspace.CurrentCamera
pcall(function()
if getgenv and getgenv().CozyHubUnload then getgenv().CozyHubUnload() end
end)
local S = {
aim = false, aimHold = true, aimTeam = true, aimWall = true, aimShowFov = true,
aimPartSel = "Голова", aimFov = 120, aimSmooth = 35, aimPred = 0,
esp = false, espBox = true, espName = true, espHealth = true, espTracer = false,
espChams = true, espTeamCol = false, espColor = "Красный", espDist = 1000,
halo = false, trail = false, selfGlow = false,
fullbright = false, nofog = false, fov = false, fovVal = 90,
speed = false, speedVal = 50, jump = false, jumpVal = 100, infJump = false,
fly = false, flySpeed = 60,
fpsMode = "Выкл", showFps = false,
espStyle = "Бокс", espHpStyle = "Полоска", espTracerPos = "Снизу", espTracerStyle = "Линия",
espArrows = false, espArrowAlways = false, arrowRadius = 28,
espGhost = false, espGhostStyle = "Призраки",
shaderPreset = "Выкл", shaderInt = 100,
hitbox = false, hitboxSize = 4, hitboxTrans = 70, hitboxTeam = true, hitboxHl = true,
bodyHitbox = false, bodySize = 7, bodyTrans = 75, bodyHl = true,
tgt = false, tgtStyle = "Кольцо", tgtColor = "Тема", tgtSel = "К прицелу", tgtRange = 300, tgtFov = 250,
stretch = false, stretchVal = 75, stretchX = 100, stretchMode = "4:3",
tgtTeam = true, tgtHud = true, tgtSize = 100, tgtSpeed = 100,
xh = false, xhStyle = "Крест", xhColor = "Белый", xhSize = 10, xhThick = 2, xhGap = 4, xhAlpha = 100,
xhSpin = 0, xhOffX = 0, xhOffY = 0, xhOutline = true, xhDot = false, xhDyn = false, xhHit = false,
theme = "Чёрно-белая", bgAnim = true, esp3d = "Выкл",
}
local unlocked = false
local fpsLevel = 0
local Shaders = { active = nil, fx = {}, saved = nil, t0 = 0 }
local Theme = { dir = -1, tw = 1, cards = {} }
local Toggles, Sliders, Selectors = {}, {}, {}
local Conns = {}
local function conn(sig, fn)
local c = sig:Connect(fn)
table.insert(Conns, c)
return c
end
local WHITE = Color3.fromRGB(245, 245, 245)
local T = {
bg     = Color3.fromRGB(8, 8, 10),
side   = Color3.fromRGB(14, 14, 17),
card   = Color3.fromRGB(22, 22, 26),
hover  = Color3.fromRGB(40, 40, 46),
text   = WHITE,
accent = WHITE,
sub    = Color3.fromRGB(150, 150, 158),
off    = Color3.fromRGB(58, 58, 66),
}
local CSK, NSK = ColorSequenceKeypoint.new, NumberSequenceKeypoint.new
local function new(class, props, parent)
local o = Instance.new(class)
if o:IsA("GuiObject") then o.BorderSizePixel = 0 end
if o:IsA("TextButton") then o.AutoButtonColor = false end
for k, v in pairs(props or {}) do o[k] = v end
if parent then o.Parent = parent end
return o
end
local function corner(o, r) return new("UICorner", { CornerRadius = UDim.new(0, r) }, o) end
local function tw(o, t, props, style, dir)
local tr = TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
tr:Play()
return tr
end
local Gui = new("ScreenGui", {
Name = "CozyHub", ResetOnSpawn = false, IgnoreGuiInset = true,
ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999,
})
do
pcall(function() if syn and syn.protect_gui then syn.protect_gui(Gui) end end)
local ok = pcall(function() Gui.Parent = (gethui and gethui()) or CoreGui end)
if not ok or not Gui.Parent then Gui.Parent = LP:WaitForChild("PlayerGui") end
end
local ESPLayer = new("Frame", { Name = "ESP", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1) }, Gui)
local VigLayer = new("Frame", { Name = "Vig", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false }, Gui)
local VigFrames, VigGrads = {}, {}
do
local function vf(pos, size, anchor, rot)
local f = new("Frame", { AnchorPoint = anchor, Position = pos, Size = size, BackgroundColor3 = Color3.new(0, 0, 0) }, VigLayer)
local g = new("UIGradient", { Rotation = rot }, f)
table.insert(VigFrames, f); table.insert(VigGrads, g)
end
vf(UDim2.fromScale(0, 0), UDim2.new(1, 0, .24, 0), Vector2.new(0, 0), 90)
vf(UDim2.fromScale(0, 1), UDim2.new(1, 0, .24, 0), Vector2.new(0, 1), 270)
vf(UDim2.fromScale(0, 0), UDim2.new(.2, 0, 1, 0), Vector2.new(0, 0), 0)
vf(UDim2.fromScale(1, 0), UDim2.new(.2, 0, 1, 0), Vector2.new(1, 0), 180)
end
local function Notify(text)
local f = new("Frame", {
AnchorPoint = Vector2.new(.5, 1), Position = UDim2.new(.5, 0, 1, 40),
Size = UDim2.fromOffset(280, 34), BackgroundColor3 = T.bg, BackgroundTransparency = 1, ZIndex = 100,
}, Gui)
corner(f, 10)
local st = new("UIStroke", { Color = T.accent, Transparency = 1, Thickness = 1.2 }, f)
local l = new("TextLabel", {
BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = text, TextTransparency = 1,
Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = T.text, ZIndex = 101,
}, f)
tw(f, .3, { Position = UDim2.new(.5, 0, 1, -24), BackgroundTransparency = .05 }, Enum.EasingStyle.Back)
tw(st, .3, { Transparency = .4 }); tw(l, .3, { TextTransparency = 0 })
task.delay(2, function()
tw(f, .3, { Position = UDim2.new(.5, 0, 1, 40), BackgroundTransparency = 1 })
tw(st, .3, { Transparency = 1 }); tw(l, .3, { TextTransparency = 1 })
task.wait(.35); f:Destroy()
end)
end
local baseScale = math.clamp(Camera.ViewportSize.Y / 460, .6, 1)
local Main = new("CanvasGroup", {
Name = "Main", AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
Size = UDim2.fromOffset(540, 360), BackgroundColor3 = T.bg, GroupTransparency = 1, Visible = false,
}, Gui)
corner(Main, 14)
new("UIStroke", { Color = WHITE, Transparency = .6, Thickness = 1.3 }, Main)
local MainScale = new("UIScale", { Scale = baseScale * .85 }, Main)
local BG = new("Frame", { Name = "BG", Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 0 }, Main)
local BGGrad = new("UIGradient", {
Color = ColorSequence.new({ CSK(0, Color3.fromRGB(4, 4, 6)), CSK(.5, Color3.fromRGB(52, 52, 60)), CSK(1, Color3.fromRGB(4, 4, 6)) }),
Rotation = 30,
}, BG)
local Sweep = new("Frame", {
AnchorPoint = Vector2.new(.5, .5), Size = UDim2.new(0, 140, 1.8, 0), Rotation = 18,
BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 0,
}, BG)
new("UIGradient", { Transparency = NumberSequence.new({ NSK(0, 1), NSK(.5, .93), NSK(1, 1) }) }, Sweep)
local Dust = {}
do
local rng = Random.new(7)
for i = 1, 30 do
local sz = rng:NextInteger(2, 4)
local f = new("Frame", { Size = UDim2.fromOffset(sz, sz), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = .6, ZIndex = 0 }, BG)
corner(f, 4)
Dust[i] = {
f = f, x = rng:NextNumber(), y = rng:NextNumber(), sp = rng:NextNumber(.01, .045),
dr = rng:NextNumber(-.01, .01), ph = rng:NextNumber(0, 6.28), tw = rng:NextNumber(1, 3),
}
end
end
local menuOpen = false
local function bgStep(dt)
if not (menuOpen and Main.Visible) or not S.bgAnim then return end
local t = os.clock()
BGGrad.Rotation = (t * 10) % 360
BGGrad.Offset = Vector2.new(math.sin(t * .35) * .25, math.cos(t * .27) * .25)
Sweep.Position = UDim2.fromScale(((t / 6) % 1) * 1.6 - .3, .5)
for _, d in ipairs(Dust) do
d.y = d.y + d.sp * dt * Theme.dir
d.x = d.x + d.dr * dt
if d.y < -.05 then d.y = 1.05; d.x = math.random()
elseif d.y > 1.05 then d.y = -.05; d.x = math.random() end
d.f.Position = UDim2.fromScale(d.x, d.y)
d.f.BackgroundTransparency = .55 + .35 * math.sin(t * d.tw * Theme.tw + d.ph)
end
end
local Top = new("Frame", { Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = T.side, BackgroundTransparency = .35 }, Main)
new("TextLabel", {
BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 0), Size = UDim2.new(0, 200, 1, 0),
Text = "Cozy Hub", Font = Enum.Font.GothamBold, TextSize = 17, TextColor3 = T.text, TextXAlignment = Enum.TextXAlignment.Left,
}, Top)
new("TextLabel", {
BackgroundTransparency = 1, Position = UDim2.fromOffset(100, 2), Size = UDim2.new(0, 200, 1, 0),
Text = "Delta / Xeno", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T.sub, TextXAlignment = Enum.TextXAlignment.Left,
}, Top)
local CloseBtn = new("TextButton", {
AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -10, .5, 0), Size = UDim2.fromOffset(26, 26),
BackgroundColor3 = T.card, Text = "X", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = T.text,
}, Top)
corner(CloseBtn, 8)
CloseBtn.MouseEnter:Connect(function() tw(CloseBtn, .15, { BackgroundColor3 = T.accent, TextColor3 = Color3.new(0, 0, 0) }) end)
CloseBtn.MouseLeave:Connect(function() tw(CloseBtn, .15, { BackgroundColor3 = T.card, TextColor3 = T.text }) end)
local Side = new("ScrollingFrame", {
Position = UDim2.fromOffset(0, 42), Size = UDim2.new(0, 128, 1, -42), BackgroundColor3 = T.side, BackgroundTransparency = .45,
ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollingDirection = Enum.ScrollingDirection.Y,
}, Main)
new("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, Side)
new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, Side)
local Indicator = new("Frame", { Position = UDim2.fromOffset(0, 60), Size = UDim2.fromOffset(3, 22), BackgroundColor3 = WHITE, Visible = false }, Main)
corner(Indicator, 2)
do
local dragging, startPos, startInput
Top.InputBegan:Connect(function(i)
if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
dragging, startPos, startInput = true, Main.Position, i.Position
end
end)
conn(UIS.InputChanged, function(i)
if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
local d = i.Position - startInput
Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
end
end)
conn(UIS.InputEnded, function(i)
if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
end
local pages, tabs, bars = {}, {}, {}
local function selectTab(idx, instant)
for i, p in ipairs(pages) do
local active = i == idx
if active then
p.Visible = true
if not instant then
p.Position = UDim2.fromOffset(138, 64)
tw(p, .3, { Position = UDim2.fromOffset(138, 52) })
end
else
p.Visible = false
end
tw(tabs[i], .2, { BackgroundTransparency = active and .1 or 1, TextColor3 = active and T.text or T.sub })
end
for i2, bar in ipairs(bars) do
tw(bar, .25, { Size = UDim2.fromOffset(3, i2 == idx and 20 or 0) }, Enum.EasingStyle.Back)
end
end
local function Tab(name)
local idx = #pages + 1
local b = new("TextButton", {
Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = T.card, BackgroundTransparency = 1,
Text = name, Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = T.sub, LayoutOrder = idx,
}, Side)
corner(b, 8)
local bar = new("Frame", { AnchorPoint = Vector2.new(0, .5), Position = UDim2.new(0, -8, .5, 0), Size = UDim2.fromOffset(3, 0), BackgroundColor3 = T.accent }, b)
corner(bar, 2)
local page = new("ScrollingFrame", {
Position = UDim2.fromOffset(138, 52), Size = UDim2.new(1, -148, 1, -62), BackgroundTransparency = 1,
ScrollBarThickness = 3, ScrollBarImageColor3 = WHITE, CanvasSize = UDim2.new(),
AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false,
}, Main)
new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, page)
new("UIPadding", { PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6) }, page)
pages[idx], tabs[idx], bars[idx] = page, b, bar
b.MouseButton1Click:Connect(function() selectTab(idx) end)
return page
end
local function Section(page, text)
new("TextLabel", {
Size = UDim2.new(1, -6, 0, 20), BackgroundTransparency = 1, Text = string.upper(text),
Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = T.sub, TextXAlignment = Enum.TextXAlignment.Left,
}, page)
end
local function Card(page, h)
local f = new("Frame", { Size = UDim2.new(1, -6, 0, h), BackgroundColor3 = T.card, BackgroundTransparency = .2 }, page)
corner(f, 8)
new("UIStroke", { Color = WHITE, Transparency = .93, Thickness = 1 }, f)
f.MouseEnter:Connect(function() tw(f, .15, { BackgroundColor3 = T.hover }) end)
f.MouseLeave:Connect(function() tw(f, .15, { BackgroundColor3 = T.card }) end)
return f
end
local function cardLabel(f, text, w)
return new("TextLabel", {
BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, w or -70, 1, 0),
Text = text, Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = T.text, TextXAlignment = Enum.TextXAlignment.Left,
}, f)
end
local function InfoCard(page, text, h)
local f = Card(page, h)
return new("TextLabel", {
BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -24, 1, 0), TextWrapped = true,
Text = text, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = T.sub, TextXAlignment = Enum.TextXAlignment.Left,
}, f)
end
local function Input(page, placeholder)
local f = Card(page, 34)
local box = new("TextBox", {
BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -24, 1, 0), Text = "",
PlaceholderText = placeholder, PlaceholderColor3 = T.sub, TextColor3 = T.text, Font = Enum.Font.GothamMedium,
TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false,
}, f)
return box, f
end
local function Toggle(page, text, key, cb)
local f = Card(page, 36)
cardLabel(f, text)
local sw = new("Frame", {
AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -10, .5, 0), Size = UDim2.fromOffset(40, 20), BackgroundColor3 = T.off,
}, f)
corner(sw, 10)
local knob = new("Frame", { Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(3, 3), BackgroundColor3 = WHITE }, sw)
corner(knob, 7)
local btn = new("TextButton", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "" }, f)
local function set(v, silent)
S[key] = v
tw(sw, .2, { BackgroundColor3 = v and T.accent or T.off })
tw(knob, .25, { Position = v and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3), BackgroundColor3 = v and Color3.new(0, 0, 0) or T.text }, Enum.EasingStyle.Back)
if cb and not silent then task.spawn(cb, v) end
end
btn.MouseButton1Click:Connect(function() set(not S[key]) end)
set(S[key], true)
Toggles[key] = function(v) set(v) end
end
local function Slider(page, text, key, min, max, step, suffix, cb)
local f = Card(page, 52)
new("TextLabel", {
BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 6), Size = UDim2.new(1, -90, 0, 16),
Text = text, Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = T.text, TextXAlignment = Enum.TextXAlignment.Left,
}, f)
local val = new("TextLabel", {
BackgroundTransparency = 1, Position = UDim2.new(1, -78, 0, 6), Size = UDim2.fromOffset(66, 16),
Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = WHITE, TextXAlignment = Enum.TextXAlignment.Right,
}, f)
local bar = new("Frame", { Position = UDim2.new(0, 12, 0, 34), Size = UDim2.new(1, -24, 0, 6), BackgroundColor3 = T.off }, f)
corner(bar, 3)
local fill = new("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = WHITE }, bar)
corner(fill, 3)
local knob = new("Frame", {
AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(0, .5), Size = UDim2.fromOffset(14, 14), BackgroundColor3 = WHITE,
}, bar)
corner(knob, 7)
local function setv(v, anim, silent)
v = math.clamp(math.floor(v / step + .5) * step, min, max)
S[key] = v
local a = (v - min) / (max - min)
val.Text = tostring(v) .. (suffix or "")
if anim then
tw(fill, .08, { Size = UDim2.fromScale(a, 1) }); tw(knob, .08, { Position = UDim2.fromScale(a, .5) })
else
fill.Size = UDim2.fromScale(a, 1); knob.Position = UDim2.fromScale(a, .5)
end
if cb and not silent then cb(v) end
end
local dragging = false
local function fromInput(i)
local a = math.clamp((i.Position.X - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
setv(min + (max - min) * a, true)
end
local hit = new("TextButton", { BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 24), Size = UDim2.new(1, 0, 0, 28), Text = "" }, f)
hit.InputBegan:Connect(function(i)
if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
dragging = true; fromInput(i)
end
end)
conn(UIS.InputChanged, function(i)
if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then fromInput(i) end
end)
conn(UIS.InputEnded, function(i)
if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
setv(S[key], false, true)
Sliders[key] = function(v) setv(v, true) end
end
local function Selector(page, text, key, options, cb)
local f = Card(page, 36)
cardLabel(f, text, -150)
local b = new("TextButton", {
AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -8, .5, 0), Size = UDim2.fromOffset(130, 24),
BackgroundColor3 = T.off, Text = S[key], Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = T.text,
}, f)
corner(b, 6)
Selectors[key] = function(v, fire) S[key] = v; b.Text = v; if fire and cb then task.spawn(cb, v) end end
b.MouseButton1Click:Connect(function()
local idx = table.find(options, S[key]) or 1
idx = idx % #options + 1
S[key] = options[idx]
b.Text = S[key]
b.Size = UDim2.fromOffset(120, 24)
tw(b, .25, { Size = UDim2.fromOffset(130, 24) }, Enum.EasingStyle.Back)
if cb then task.spawn(cb, S[key]) end
end)
end
local function Button(page, text, cb)
local f = Card(page, 36)
local b = new("TextButton", {
Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = text,
Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = T.text,
}, f)
b.MouseButton1Click:Connect(function()
tw(f, .1, { BackgroundColor3 = T.accent })
tw(b, .1, { TextColor3 = Color3.new(0, 0, 0) })
task.delay(.12, function() tw(f, .25, { BackgroundColor3 = T.card }); tw(b, .25, { TextColor3 = T.text }) end)
task.spawn(cb)
end)
end
local function setMenu(v)
if not unlocked then return end
menuOpen = v
if v then
Main.Visible = true
MainScale.Scale = baseScale * .85
Main.GroupTransparency = 1
tw(MainScale, .3, { Scale = baseScale }, Enum.EasingStyle.Back)
tw(Main, .18, { GroupTransparency = 0 })
else
tw(MainScale, .18, { Scale = baseScale * .88 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
tw(Main, .18, { GroupTransparency = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
task.delay(.2, function() if not menuOpen then Main.Visible = false end end)
end
end
CloseBtn.MouseButton1Click:Connect(function() setMenu(false) end)
conn(UIS.InputBegan, function(i, gp)
if not gp and unlocked and i.KeyCode == Enum.KeyCode.RightShift then setMenu(not menuOpen) end
if unlocked and i.UserInputType == Enum.UserInputType.MouseButton3 and Toggles.fly then
Toggles.fly(not S.fly)
end
end)
local Fab = new("TextButton", {
AnchorPoint = Vector2.new(.5, .5), Position = UDim2.new(0, 40, .5, 0), Size = UDim2.fromOffset(0, 0),
BackgroundColor3 = Color3.fromRGB(8, 8, 10), Text = "", Visible = false, ZIndex = 20,
}, Gui)
corner(Fab, 28)
local FabStroke = new("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, Fab)
local FabGrad = new("UIGradient", {
Color = ColorSequence.new({ CSK(0, Color3.new(1, 1, 1)), CSK(.5, Color3.fromRGB(60, 60, 66)), CSK(1, Color3.new(1, 1, 1)) }),
}, FabStroke)
new("TextLabel", {
BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "CH", Font = Enum.Font.GothamBlack,
TextSize = 16, TextColor3 = WHITE, ZIndex = 21,
}, Fab)
local LockDot = new("Frame", {
AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.84, .16), Size = UDim2.fromOffset(0, 0),
BackgroundColor3 = WHITE, ZIndex = 22,
}, Fab)
corner(LockDot, 8)
new("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 2 }, LockDot)
local fabLocked = false
local FAB = 50
do
local dragging, dragged, dragStart, startAbs = false, false, nil, nil
local lastTap, prevMenu = 0, false
Fab.InputBegan:Connect(function(i)
if not unlocked then return end
if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
dragging, dragged = true, false
dragStart = Vector2.new(i.Position.X, i.Position.Y)
startAbs = Fab.AbsolutePosition + Fab.AbsoluteSize / 2
end
end)
conn(UIS.InputChanged, function(i)
if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
local d = Vector2.new(i.Position.X, i.Position.Y) - dragStart
if d.Magnitude > 8 then dragged = true end
if dragged and not fabLocked then
local vp = Camera.ViewportSize
local np = startAbs + d
Fab.Position = UDim2.fromOffset(math.clamp(np.X, 26, vp.X - 26), math.clamp(np.Y, 26, vp.Y - 26))
end
end
end)
conn(UIS.InputEnded, function(i)
if dragging and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
dragging = false
if dragged then return end
local now = os.clock()
if now - lastTap < .3 then
lastTap = 0
setMenu(prevMenu)
fabLocked = not fabLocked
tw(LockDot, .3, { Size = fabLocked and UDim2.fromOffset(14, 14) or UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Back)
Notify(fabLocked and "Иконка закреплена" or "Иконка откреплена — можно двигать")
else
lastTap = now
prevMenu = menuOpen
setMenu(not menuOpen) -- сразу, без ожидания
end
end
end)
end
task.spawn(function()
while Fab.Parent do
if Fab.Visible then
tw(Fab, 1.3, { Size = UDim2.fromOffset(FAB + 4, FAB + 4) }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut); task.wait(1.3)
tw(Fab, 1.3, { Size = UDim2.fromOffset(FAB, FAB) }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut); task.wait(1.3)
else
task.wait(.3)
end
end
end)
local ESPColors = {
["Красный"] = Color3.fromRGB(255, 70, 70), ["Зелёный"] = Color3.fromRGB(80, 255, 120),
["Синий"] = Color3.fromRGB(80, 150, 255), ["Фиолетовый"] = Color3.fromRGB(170, 110, 255),
["Белый"] = Color3.fromRGB(255, 255, 255), ["Жёлтый"] = Color3.fromRGB(255, 225, 80),
}
local ESPColorNames = { "Красный", "Зелёный", "Синий", "Фиолетовый", "Белый", "Жёлтый" }
local function getAimPart(char)
if S.aimPartSel == "Голова" then return char:FindFirstChild("Head") end
if S.aimPartSel == "Торс" then return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") end
return char:FindFirstChild("HumanoidRootPart")
end
local function isEnemy(plr)
if plr.Team and LP.Team and plr.Team == LP.Team then return false end
return true
end
local function aliveChar(plr)
local c = plr.Character
local h = c and c:FindFirstChildOfClass("Humanoid")
if c and h and h.Health > 0 then return c, h end
end
local FovCircle = new("Frame", {
AnchorPoint = Vector2.new(.5, .5), BackgroundTransparency = 1, Visible = false, Size = UDim2.fromOffset(240, 240),
}, ESPLayer)
corner(FovCircle, 999)
local FovStroke = new("UIStroke", { Color = WHITE, Thickness = 1.5, Transparency = .3 }, FovCircle)
local function aimCenter()
if UIS.TouchEnabled and not UIS.MouseEnabled then return Camera.ViewportSize / 2 end
return UIS:GetMouseLocation()
end
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
local function visibleCheck(part, char)
rayParams.FilterDescendantsInstances = { LP.Character, char }
local o = Camera.CFrame.Position
return workspace:Raycast(o, part.Position - o, rayParams) == nil
end
local function closestTarget()
local center = aimCenter()
local best, bestD = nil, S.aimFov
for _, plr in ipairs(Players:GetPlayers()) do
if plr ~= LP and (not S.aimTeam or isEnemy(plr)) then
local char = aliveChar(plr)
local part = char and getAimPart(char)
if part then
local p, on = Camera:WorldToViewportPoint(part.Position)
if on then
local d = (Vector2.new(p.X, p.Y) - center).Magnitude
if d < bestD and (not S.aimWall or visibleCheck(part, char)) then best, bestD = part, d end
end
end
end
end
return best
end
local function aimStep()
local center = aimCenter()
FovCircle.Visible = unlocked and S.aim and S.aimShowFov
FovCircle.Size = UDim2.fromOffset(S.aimFov * 2, S.aimFov * 2)
FovCircle.Position = UDim2.fromOffset(center.X, center.Y)
if not S.aim then return end
local touchOnly = UIS.TouchEnabled and not UIS.MouseEnabled
if S.aimHold and not touchOnly and not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
FovStroke.Color = T.accent
return
end
local part = closestTarget()
FovStroke.Color = part and Color3.fromRGB(255, 90, 110) or T.accent
if part then
local pos = part.Position + part.AssemblyLinearVelocity * (S.aimPred / 100)
local alpha = math.clamp(1 - S.aimSmooth / 100, .03, 1)
Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, pos), alpha)
end
end
local espObjs = {}
local GHOST_N = 24
local BLACK = Color3.new(0, 0, 0)
local HP_LOW, HP_HIGH = Color3.fromRGB(255, 70, 70), Color3.fromRGB(80, 255, 120)
local function makeESP(plr)
local o = { guis = {}, shown = false }
local fo = new("Folder", { Name = plr.Name }, ESPLayer)
o.folder = fo
local ANCH = Vector2.new(.5, .5)
local function G(class, props, track)
local g = new(class, props, fo)
if track ~= false then table.insert(o.guis, g) end
return g
end
o.box = G("Frame", { BackgroundTransparency = 1, Visible = false })
o.boxStroke = new("UIStroke", { Thickness = 1.5 }, o.box)
o.corners = {}
for i = 1, 8 do o.corners[i] = G("Frame", { Visible = false }) end
o.diamond = G("Frame", { AnchorPoint = ANCH, BackgroundTransparency = 1, Rotation = 45, Visible = false })
o.diamondStroke = new("UIStroke", { Thickness = 1.8 }, o.diamond)
o.circle = G("Frame", { AnchorPoint = ANCH, BackgroundTransparency = 1, Visible = false })
corner(o.circle, 999)
o.circleStroke = new("UIStroke", { Thickness = 1.8 }, o.circle)
o.tracer = G("Frame", { AnchorPoint = ANCH, Visible = false })
o.tracerGrad = new("UIGradient", { Enabled = false, Transparency = NumberSequence.new({ NSK(0, 1), NSK(1, 0) }) }, o.tracer)
o.name = G("TextLabel", {
BackgroundTransparency = 1, AnchorPoint = Vector2.new(.5, 1), Size = UDim2.fromOffset(220, 16),
Font = Enum.Font.GothamBold, TextSize = 12, TextStrokeTransparency = .4, Visible = false,
})
o.hpBg = G("Frame", { BackgroundColor3 = Color3.fromRGB(15, 15, 15), Visible = false })
o.hp = new("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.fromScale(1, 1) }, o.hpBg)
o.hbFrame = G("Frame", { AnchorPoint = Vector2.new(.5, 1), BackgroundTransparency = 1, Size = UDim2.fromOffset(130, 12), Visible = false })
o.hbScale = new("UIScale", {}, o.hbFrame)
o.hbCells = {}
for i = 1, 10 do
local c = new("Frame", { Size = UDim2.fromOffset(11, 11), Position = UDim2.fromOffset((i - 1) * 13, 0) }, o.hbFrame)
new("UIStroke", { Color = BLACK, Thickness = 1.5 }, c)
o.hbCells[i] = c
end
o.pill = G("Frame", { AnchorPoint = Vector2.new(.5, 1), Size = UDim2.fromOffset(96, 12), BackgroundColor3 = Color3.fromRGB(12, 12, 14), BackgroundTransparency = .15, Visible = false })
corner(o.pill, 6)
new("UIStroke", { Color = Color3.new(1, 1, 1), Transparency = .6, Thickness = 1 }, o.pill)
o.pillScale = new("UIScale", {}, o.pill)
o.pillFill = new("Frame", { Size = UDim2.fromScale(1, 1) }, o.pill)
corner(o.pillFill, 6)
o.pillText = new("TextLabel", {
BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Font = Enum.Font.GothamBold, TextSize = 9,
TextColor3 = Color3.new(1, 1, 1), TextStrokeTransparency = .5, ZIndex = 2,
}, o.pill)
o.hearts = G("TextLabel", {
BackgroundTransparency = 1, AnchorPoint = Vector2.new(.5, 1), Size = UDim2.fromOffset(180, 18),
Font = Enum.Font.GothamBold, TextSize = 14, RichText = true, TextStrokeTransparency = .5, Visible = false,
})
o.hpText = G("TextLabel", {
BackgroundTransparency = 1, AnchorPoint = Vector2.new(.5, 1), Size = UDim2.fromOffset(120, 16),
Font = Enum.Font.GothamBold, TextSize = 13, TextStrokeTransparency = .4, Visible = false,
})
o.arrow = G("TextLabel", {
AnchorPoint = ANCH, Size = UDim2.fromOffset(28, 28), BackgroundTransparency = 1, Text = "▲",
Font = Enum.Font.GothamBlack, TextSize = 24, TextStrokeTransparency = .35, Visible = false,
}, false)
o.arrowTxt = G("TextLabel", {
AnchorPoint = ANCH, Size = UDim2.fromOffset(70, 14), BackgroundTransparency = 1,
Font = Enum.Font.GothamBold, TextSize = 11, TextStrokeTransparency = .35, Visible = false,
}, false)
espObjs[plr] = o
return o
end
local function hideGuis(o)
if o.shown then
for _, g in ipairs(o.guis) do g.Visible = false end
o.shown = false
end
end
local function hideAll(o)
hideGuis(o)
o.arrow.Visible = false
o.arrowTxt.Visible = false
if o.hl then o.hl.Enabled = false end
end
local function destroyESP(plr)
local o = espObjs[plr]
if not o then return end
if o.folder then pcall(function() o.folder:Destroy() end) end
if o.hl then pcall(function() o.hl:Destroy() end) end
espObjs[plr] = nil
end
local function arrowUpdate(o, root, col, dist, onScreen)
if not S.espArrows or (onScreen and not S.espArrowAlways) then
o.arrow.Visible = false; o.arrowTxt.Visible = false
return
end
local rel = Camera.CFrame:PointToObjectSpace(root.Position)
local v = Vector2.new(rel.X, rel.Z)
if v.Magnitude < 1e-3 then
o.arrow.Visible = false; o.arrowTxt.Visible = false
return
end
v = v.Unit
local vp = Camera.ViewportSize
local R = math.min(vp.X, vp.Y) * (S.arrowRadius / 100)
local c = vp / 2 + v * R
o.arrow.Visible = true
o.arrow.Position = UDim2.fromOffset(c.X, c.Y)
o.arrow.Rotation = math.deg(math.atan2(v.X, -v.Y))
o.arrow.TextColor3 = col
local lp = c - v * 26
o.arrowTxt.Visible = true
o.arrowTxt.Position = UDim2.fromOffset(lp.X, lp.Y)
o.arrowTxt.TextColor3 = col
o.arrowTxt.Text = string.format("%dm", dist)
end
local function ghostUpdate(o, root, col, dist)
if true or dist > math.min(S.espDist, 350) then
if o.dots then for _, d in ipairs(o.dots) do d.Visible = false end end
return
end
if not o.dots then
o.dots = {}
for i = 1, GHOST_N do
local d = new("Frame", { AnchorPoint = Vector2.new(.5, .5), Visible = false, Size = UDim2.fromOffset(6, 6) }, o.folder)
corner(d, 14)
table.insert(o.guis, d)
o.dots[i] = d
end
end
local t = os.clock()
local base = root.Position
local used = 0
local function dot(wp, size, tr)
used = used + 1
local d = o.dots[used]
if not d then return end
local p, on = Camera:WorldToViewportPoint(wp)
if on then
local sz = math.clamp(size * 300 / math.max(p.Z, 1), 2, 28)
d.Size = UDim2.fromOffset(sz, sz)
d.Position = UDim2.fromOffset(p.X, p.Y)
d.BackgroundColor3 = col
d.BackgroundTransparency = tr
d.Visible = true
else
d.Visible = false
end
end
local style = S.espGhostStyle
if style == "Призраки" then
for i = 0, 2 do
for k = 0, 6 do
local tt = t - k * .07
local a = tt * (1.5 + i * .35) + i * 2.1
local r = 2.8 + i * .45
local h = math.sin(tt * 1.7 + i * 1.3) * 1.5 + .4
dot(base + Vector3.new(math.cos(a) * r, h, math.sin(a) * r), .95 * (1 - k / 9), .05 + k / 7 * .85)
end
end
elseif style == "Таргет-кольцо" then
local y = -2.6 + (math.sin(t * 1.8) * .5 + .5) * 5.2
for j = 0, 23 do
local a = j / 24 * math.pi * 2 + t * 2
dot(base + Vector3.new(math.cos(a) * 2.5, y, math.sin(a) * 2.5), .34, .15 + .55 * (math.sin(a * 2 - t * 3) * .5 + .5))
end
else
for j = 0, 23 do
local a = t * 2.5 + j * .55
dot(base + Vector3.new(math.cos(a) * 2.2, -2.8 + j / 23 * 5.6, math.sin(a) * 2.2), .32, j / 23 * .75)
end
end
for i = used + 1, GHOST_N do o.dots[i].Visible = false end
end
local LINE_N = 40
local R15BONES = {
{ "Head", "UpperTorso" }, { "UpperTorso", "LowerTorso" },
{ "UpperTorso", "LeftUpperArm" }, { "LeftUpperArm", "LeftLowerArm" }, { "LeftLowerArm", "LeftHand" },
{ "UpperTorso", "RightUpperArm" }, { "RightUpperArm", "RightLowerArm" }, { "RightLowerArm", "RightHand" },
{ "LowerTorso", "LeftUpperLeg" }, { "LeftUpperLeg", "LeftLowerLeg" }, { "LeftLowerLeg", "LeftFoot" },
{ "LowerTorso", "RightUpperLeg" }, { "RightUpperLeg", "RightLowerLeg" }, { "RightLowerLeg", "RightFoot" },
}
local R6BONES = {
{ "Head", "Torso" }, { "Torso", "Left Arm" }, { "Torso", "Right Arm" }, { "Torso", "Left Leg" }, { "Torso", "Right Leg" },
}
local function shapeSegs(st, cf, size, char)
local segs = {}
local function add(a, b) segs[#segs + 1] = { a, b } end
local hx, hy, hz = size.X / 2, size.Y / 2, size.Z / 2
local R = math.max(hx, hz)
local t = os.clock()
local TAU = math.pi * 2
if st == "3D бокс" or st == "3D углы" then
local c = {}
for i = 0, 7 do
c[i] = Vector3.new((i % 2 == 0) and -hx or hx, (math.floor(i / 2) % 2 == 0) and -hy or hy, (i >= 4) and hz or -hz)
end
for i = 0, 7 do
for _, bit in ipairs({ 1, 2, 4 }) do
local j = bit32.bxor(i, bit)
if st == "3D бокс" then
if i < j then add(cf * c[i], cf * c[j]) end
else
add(cf * c[i], cf * (c[i] + (c[j] - c[i]) * .3))
end
end
end
elseif st == "Октаэдр" then
local r, ang = R * 1.15, t * 1.2
local top, bot = Vector3.new(0, hy * 1.1, 0), Vector3.new(0, -hy * 1.1, 0)
local mid = {}
for k = 0, 3 do
local a = ang + k * math.pi / 2
mid[k] = Vector3.new(math.cos(a) * r, 0, math.sin(a) * r)
end
for k = 0, 3 do
add(cf * top, cf * mid[k])
add(cf * bot, cf * mid[k])
add(cf * mid[k], cf * mid[(k + 1) % 4])
end
elseif st == "Шестигранник" then
local r = R * 1.3
local top, bot = {}, {}
for k = 0, 5 do
local a = k * math.pi / 3 + math.pi / 6
top[k] = Vector3.new(math.cos(a) * r, hy, math.sin(a) * r)
bot[k] = Vector3.new(math.cos(a) * r, -hy, math.sin(a) * r)
end
for k = 0, 5 do
local n = (k + 1) % 6
add(cf * top[k], cf * top[n])
add(cf * bot[k], cf * bot[n])
add(cf * top[k], cf * bot[k])
end
elseif st == "Цилиндр" then
local r, n = R * 1.25, 16
for k = 0, n - 1 do
local a1, a2 = k / n * TAU, (k + 1) / n * TAU
local t1 = Vector3.new(math.cos(a1) * r, hy, math.sin(a1) * r)
local t2 = Vector3.new(math.cos(a2) * r, hy, math.sin(a2) * r)
local b1 = Vector3.new(math.cos(a1) * r, -hy, math.sin(a1) * r)
local b2 = Vector3.new(math.cos(a2) * r, -hy, math.sin(a2) * r)
add(cf * t1, cf * t2)
add(cf * b1, cf * b2)
if k % 4 == 0 then add(cf * t1, cf * b1) end
end
elseif st == "Сфера" then
local rx, ry = R * 1.35, hy * 1.08
local spin = CFrame.Angles(0, t * .8, 0)
local n = 12
local function pt(circle, k)
local a = k / n * TAU
if circle == 1 then return Vector3.new(math.cos(a) * rx, 0, math.sin(a) * rx) end
if circle == 2 then return Vector3.new(math.cos(a) * rx, math.sin(a) * ry, 0) end
return Vector3.new(0, math.sin(a) * ry, math.cos(a) * rx)
end
for circle = 1, 3 do
for k = 0, n - 1 do
add(cf * (spin * pt(circle, k)), cf * (spin * pt(circle, k + 1)))
end
end
else
local bones = char:FindFirstChild("UpperTorso") and R15BONES or R6BONES
for _, b in ipairs(bones) do
local p1, p2 = char:FindFirstChild(b[1]), char:FindFirstChild(b[2])
if p1 and p2 then add(p1.Position, p2.Position) end
end
end
return segs
end
local function drawLines(o, segs, col)
if not o.lines then
o.lines = {}
for i = 1, LINE_N do
local l = new("Frame", { AnchorPoint = Vector2.new(.5, .5), Visible = false }, o.folder)
table.insert(o.guis, l)
o.lines[i] = l
end
end
local inv = Camera.CFrame:Inverse()
local vp = Camera.ViewportSize
local sc = (vp.Y / 2) / math.tan(math.rad(Camera.FieldOfView) / 2)
local function proj(wp)
local cp = inv * wp
local depth = -cp.Z
if depth < .1 then return nil end
return Vector2.new(vp.X / 2 + cp.X / depth * sc, vp.Y / 2 - cp.Y / depth * sc)
end
local n = math.min(#segs, LINE_N)
for i = 1, n do
local a, b = proj(segs[i][1]), proj(segs[i][2])
local l = o.lines[i]
if a and b then
local d = b - a
l.Visible = true
l.BackgroundColor3 = col
l.Size = UDim2.fromOffset(d.Magnitude + 1, 1.6)
l.Position = UDim2.fromOffset((a.X + b.X) / 2, (a.Y + b.Y) / 2)
l.Rotation = math.deg(math.atan2(d.Y, d.X))
else
l.Visible = false
end
end
for i = n + 1, LINE_N do o.lines[i].Visible = false end
end
local function updateESP(plr, o)
local char, hum = aliveChar(plr)
local root = char and char:FindFirstChild("HumanoidRootPart")
if not S.esp or not root then return hideAll(o) end
local dist = (Camera.CFrame.Position - root.Position).Magnitude
if dist > S.espDist then return hideAll(o) end
local col = (S.espTeamCol and plr.Team) and plr.TeamColor.Color or ESPColors[S.espColor]
if S.espChams then
if not o.hl or o.hl.Parent ~= char then
if o.hl then o.hl:Destroy() end
o.hl = new("Highlight", { Name = "CozyHL", DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, FillTransparency = .55, OutlineTransparency = 0 }, char)
end
o.hl.FillColor = col; o.hl.OutlineColor = col; o.hl.Enabled = true
elseif o.hl then
o.hl.Enabled = false
end
local rp, on = Camera:WorldToViewportPoint(root.Position)
arrowUpdate(o, root, col, dist, on)
if not on then return hideGuis(o) end
local cf, size = char:GetBoundingBox()
local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
local behind = false
for x = -1, 1, 2 do for y = -1, 1, 2 do for z = -1, 1, 2 do
local p = Camera:WorldToViewportPoint((cf * CFrame.new(size.X / 2 * x, size.Y / 2 * y, size.Z / 2 * z)).Position)
if p.Z < 0 then behind = true end
minX, minY = math.min(minX, p.X), math.min(minY, p.Y)
maxX, maxY = math.max(maxX, p.X), math.max(maxY, p.Y)
end end end
if behind then return hideGuis(o) end
local w, h = maxX - minX, maxY - minY
local cx, cy = minX + w / 2, minY + h / 2
o.shown = true
local st = S.espStyle
o.box.Visible = st == "Бокс"
if st == "Бокс" then
o.box.Position = UDim2.fromOffset(minX, minY)
o.box.Size = UDim2.fromOffset(w, h)
o.boxStroke.Color = col
end
local isCorner = st == "Углы"
local L = math.clamp(math.min(w, h) * .28, 6, 22)
local cr = {
{ minX, minY, L, 2 }, { minX, minY, 2, L },
{ minX + w - L, minY, L, 2 }, { minX + w - 2, minY, 2, L },
{ minX, minY + h - 2, L, 2 }, { minX, minY + h - L, 2, L },
{ minX + w - L, minY + h - 2, L, 2 }, { minX + w - 2, minY + h - L, 2, L },
}
for i, c in ipairs(o.corners) do
c.Visible = isCorner
if isCorner then
local d = cr[i]
c.Position = UDim2.fromOffset(d[1], d[2])
c.Size = UDim2.fromOffset(d[3], d[4])
c.BackgroundColor3 = col
end
end
o.diamond.Visible = st == "Ромб"
if st == "Ромб" then
local side = math.max(h, w * 1.2) / 1.4142
o.diamond.Position = UDim2.fromOffset(cx, cy)
o.diamond.Size = UDim2.fromOffset(side, side)
o.diamondStroke.Color = col
end
o.circle.Visible = st == "Круг"
if st == "Круг" then
local dm = math.max(h * .95, w)
o.circle.Position = UDim2.fromOffset(cx, cy)
o.circle.Size = UDim2.fromOffset(dm, dm)
o.circleStroke.Color = col
end
if S.esp3d ~= "Выкл" then
drawLines(o, shapeSegs(S.esp3d, cf, size, char), col)
o.linesOn = true
elseif o.linesOn then
for _, l in ipairs(o.lines) do l.Visible = false end
o.linesOn = false
end
o.name.Visible = S.espName
o.name.Position = UDim2.fromOffset(cx, minY - 2)
o.name.TextColor3 = col
o.name.Text = string.format("%s  [%dm]", plr.DisplayName, dist)
local frac = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
local hpCol = HP_LOW:Lerp(HP_HIGH, frac)
local hs = S.espHpStyle
local topY = minY - 4 - (S.espName and 16 or 0)
o.hpBg.Visible = hs == "Полоска"
if hs == "Полоска" then
o.hpBg.Position = UDim2.fromOffset(minX - 6, minY)
o.hpBg.Size = UDim2.fromOffset(3, h)
o.hp.Size = UDim2.fromScale(1, frac)
o.hp.BackgroundColor3 = hpCol
end
o.hbFrame.Visible = hs == "Хотбар"
if hs == "Хотбар" then
o.hbFrame.Position = UDim2.fromOffset(cx, topY)
o.hbScale.Scale = math.clamp(w / 75, .55, 1.25)
local full = math.floor(frac * 10 + .5)
for i, c in ipairs(o.hbCells) do
local fill = i <= full
c.BackgroundColor3 = fill and hpCol or Color3.fromRGB(30, 30, 34)
c.BackgroundTransparency = fill and 0 or .35
end
end
o.pill.Visible = hs == "Плашка"
if hs == "Плашка" then
o.pill.Position = UDim2.fromOffset(cx, topY)
o.pillScale.Scale = math.clamp(w / 75, .6, 1.25)
o.pillFill.Size = UDim2.fromScale(math.max(frac, .02), 1)
o.pillFill.BackgroundColor3 = hpCol
o.pillText.Text = tostring(math.floor(hum.Health))
end
o.hearts.Visible = hs == "Сердца"
if hs == "Сердца" then
local n = math.floor(frac * 10 + .5)
o.hearts.Position = UDim2.fromOffset(cx, topY + 2)
o.hearts.TextSize = math.clamp(w / 4.5, 11, 19)
o.hearts.Text = string.format('<font color="rgb(255,70,90)">%s</font><font color="rgb(60,60,68)">%s</font>',
string.rep("♥", n), string.rep("♥", 10 - n))
end
o.hpText.Visible = hs == "Цифры"
if hs == "Цифры" then
o.hpText.Position = UDim2.fromOffset(cx, topY + 2)
o.hpText.TextColor3 = hpCol
o.hpText.Text = string.format("%d HP", hum.Health)
end
if S.espTracer then
local vp = Camera.ViewportSize
local from
if S.espTracerPos == "Центр" then from = vp / 2
elseif S.espTracerPos == "Сверху" then from = Vector2.new(vp.X / 2, 0)
else from = Vector2.new(vp.X / 2, vp.Y) end
local to = Vector2.new(rp.X, rp.Y)
local d = to - from
local th = (S.espTracerStyle == "Толстая") and 3 or 1.5
o.tracerGrad.Enabled = S.espTracerStyle == "Градиент"
o.tracer.Visible = true
o.tracer.BackgroundColor3 = col
o.tracer.Size = UDim2.fromOffset(d.Magnitude, th)
o.tracer.Position = UDim2.fromOffset((from.X + to.X) / 2, (from.Y + to.Y) / 2)
o.tracer.Rotation = math.deg(math.atan2(d.Y, d.X))
else
o.tracer.Visible = false
end
ghostUpdate(o, root, col, dist)
end
conn(Players.PlayerRemoving, destroyESP)
local function espStep()
for _, plr in ipairs(Players:GetPlayers()) do
if plr ~= LP then
local o = espObjs[plr] or makeESP(plr)
updateESP(plr, o)
end
end
end
local PO = {}
local function playerStep()
local char = LP.Character
local hum = char and char:FindFirstChildOfClass("Humanoid")
if not hum then return end
if PO.hum ~= hum then PO = { hum = hum } end
if S.speed then
if PO.ws == nil then PO.ws = hum.WalkSpeed end
hum.WalkSpeed = S.speedVal
elseif PO.ws ~= nil then
hum.WalkSpeed = PO.ws; PO.ws = nil
end
if S.jump then
if PO.jp == nil then PO.jp, PO.ujp = hum.JumpPower, hum.UseJumpPower end
hum.UseJumpPower = true
hum.JumpPower = S.jumpVal
elseif PO.jp ~= nil then
hum.UseJumpPower = PO.ujp; hum.JumpPower = PO.jp; PO.jp = nil
end
end
conn(UIS.JumpRequest, function()
if S.infJump and unlocked then
local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end
end)
local Fly = { vel = Vector3.zero }
local function flyStop()
if Fly.bv then Fly.bv:Destroy() end
if Fly.bg then Fly.bg:Destroy() end
Fly.bv, Fly.bg = nil, nil
local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
if hum then hum.PlatformStand = false end
end
local function flyStart()
local char = LP.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
local hum = char and char:FindFirstChildOfClass("Humanoid")
if not root or not hum then return end
Fly.bv = new("BodyVelocity", { MaxForce = Vector3.new(1e6, 1e6, 1e6), Velocity = Vector3.zero, P = 1e4 }, root)
Fly.bg = new("BodyGyro", { MaxTorque = Vector3.new(1e6, 1e6, 1e6), P = 1e4, D = 500, CFrame = root.CFrame }, root)
hum.PlatformStand = true
Fly.vel = Vector3.zero
if not Fly.controls then
pcall(function()
local pm = require(LP.PlayerScripts:WaitForChild("PlayerModule", 2))
Fly.controls = pm:GetControls()
end)
end
end
local function flyStep(dt)
if not S.fly then return end
local char = LP.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
local hum = char and char:FindFirstChildOfClass("Humanoid")
if not root or not hum then return end
if not Fly.bv or Fly.bv.Parent ~= root then
flyStop(); flyStart()
if not Fly.bv then return end
end
local cf = Camera.CFrame
local move, got = Vector3.zero, false
if Fly.controls then
local ok, mv = pcall(function() return Fly.controls:GetMoveVector() end)
if ok and typeof(mv) == "Vector3" then
move = cf.RightVector * mv.X + cf.LookVector * (-mv.Z)
got = true
end
end
if not got then
local md = hum.MoveDirection
local flat = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z)
if flat.Magnitude > 0 then flat = flat.Unit end
move = md + Vector3.new(0, cf.LookVector.Y * md:Dot(flat), 0)
end
local vert = 0
local typing = UIS:GetFocusedTextBox() ~= nil
if Fly.up or (not typing and UIS:IsKeyDown(Enum.KeyCode.Space)) then vert = vert + 1 end
if Fly.down or (not typing and (UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.Q))) then vert = vert - 1 end
local target = (move + Vector3.new(0, vert, 0)) * S.flySpeed
Fly.vel = Fly.vel:Lerp(target, math.min(dt * 8, 1))
Fly.bv.Velocity = Fly.vel
local look = Vector3.new(cf.LookVector.X, 0, cf.LookVector.Z)
if look.Magnitude > 0 then
local tilt = math.clamp(Fly.vel.Magnitude / math.max(S.flySpeed, 1), 0, 1) * .45
Fly.bg.CFrame = CFrame.lookAt(root.Position, root.Position + look) * CFrame.Angles(-tilt, 0, 0)
end
end
local FlyPanel = new("CanvasGroup", {
AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, 160, .62, 0), Size = UDim2.fromOffset(132, 150),
BackgroundColor3 = Color3.fromRGB(8, 8, 10), GroupTransparency = 1, Visible = false, ZIndex = 30,
}, Gui)
corner(FlyPanel, 14)
new("UIStroke", { Color = WHITE, Transparency = .5, Thickness = 1.3 }, FlyPanel)
new("TextLabel", {
BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 6), Size = UDim2.fromOffset(60, 22),
Text = "FLY", Font = Enum.Font.GothamBlack, TextSize = 15, TextColor3 = WHITE, TextXAlignment = Enum.TextXAlignment.Left,
}, FlyPanel)
local FlyClose = new("TextButton", {
Position = UDim2.new(1, -34, 0, 6), Size = UDim2.fromOffset(24, 22), BackgroundColor3 = T.card,
Text = "X", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = WHITE,
}, FlyPanel)
corner(FlyClose, 6)
local function flyBtn(text, x, y, w, h)
local b = new("TextButton", {
Position = UDim2.fromOffset(x, y), Size = UDim2.fromOffset(w, h), BackgroundColor3 = T.card,
Text = text, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = WHITE,
}, FlyPanel)
corner(b, 8)
return b
end
local UpBtn   = flyBtn("ВВЕРХ", 10, 34, 112, 32)
local DownBtn = flyBtn("ВНИЗ", 10, 70, 112, 32)
local MinusBtn = flyBtn("-", 10, 108, 34, 32)
local PlusBtn  = flyBtn("+", 88, 108, 34, 32)
local SpeedLbl = new("TextLabel", {
BackgroundTransparency = 1, Position = UDim2.fromOffset(44, 108), Size = UDim2.fromOffset(44, 32),
Text = tostring(S.flySpeed), Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = WHITE,
}, FlyPanel)
local function holdBtn(b, key)
b.InputBegan:Connect(function(i)
if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
Fly[key] = true
tw(b, .1, { BackgroundColor3 = T.accent, TextColor3 = Color3.new(0, 0, 0) })
end
end)
b.InputEnded:Connect(function(i)
if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
Fly[key] = false
tw(b, .15, { BackgroundColor3 = T.card, TextColor3 = T.text })
end
end)
end
holdBtn(UpBtn, "up"); holdBtn(DownBtn, "down")
local function setFlySpeed(v)
v = math.clamp(v, 10, 250)
S.flySpeed = v
SpeedLbl.Text = tostring(v)
if Sliders.flySpeed then Sliders.flySpeed(v) end
end
MinusBtn.MouseButton1Click:Connect(function() setFlySpeed(S.flySpeed - 10) end)
PlusBtn.MouseButton1Click:Connect(function() setFlySpeed(S.flySpeed + 10) end)
FlyClose.MouseButton1Click:Connect(function() if Toggles.fly then Toggles.fly(false) end end)
local function flyPanelShow(v)
if v then
FlyPanel.Visible = true
tw(FlyPanel, .4, { Position = UDim2.new(1, -12, .62, 0), GroupTransparency = 0 }, Enum.EasingStyle.Back)
else
tw(FlyPanel, .25, { Position = UDim2.new(1, 160, .62, 0), GroupTransparency = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
task.delay(.27, function() if not S.fly then FlyPanel.Visible = false end end)
end
end
local FpsLabel = new("TextLabel", {
AnchorPoint = Vector2.new(.5, 0), Position = UDim2.new(.5, 0, 0, 4), Size = UDim2.fromOffset(84, 22),
BackgroundColor3 = Color3.fromRGB(8, 8, 10), BackgroundTransparency = .25, Text = "FPS --",
Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = WHITE, Visible = false, ZIndex = 40,
}, Gui)
corner(FpsLabel, 8)
new("UIStroke", { Color = WHITE, Transparency = .7, Thickness = 1 }, FpsLabel)
local fpsAcc, fpsFrames = 0, 0
local function fpsCounterStep(dt)
FpsLabel.Visible = unlocked and S.showFps
if not FpsLabel.Visible then fpsAcc, fpsFrames = 0, 0 return end
fpsAcc = fpsAcc + dt; fpsFrames = fpsFrames + 1
if fpsAcc >= .5 then
local fps = math.floor(fpsFrames / fpsAcc + .5)
FpsLabel.Text = "FPS " .. fps
FpsLabel.TextColor3 = fps < 30 and Color3.fromRGB(255, 100, 110) or T.text
fpsAcc, fpsFrames = 0, 0
end
end
local revertFps, applyFps
do
local FpsLevels = { ["Выкл"] = 0, ["Простой"] = 1, ["Сильный"] = 2, ["Картошка"] = 3 }
local FO = setmetatable({}, { __mode = "k" })
local fpsToken, fpsConn = 0, nil
local origRender = {}
local function setp(inst, prop, val)
local rec = FO[inst]
if not rec then rec = {}; FO[inst] = rec end
if rec[prop] == nil then
local ok, cur = pcall(function() return inst[prop] end)
if not ok then return end
rec[prop] = cur
end
pcall(function() inst[prop] = val end)
end
local function skipInst(i)
if i:IsDescendantOf(Gui) then return true end
if i:FindFirstAncestor("CozyHalo") then return true end
if string.sub(i.Name, 1, 6) == "CozyFX" then return true end
return false
end
local function applyInst(inst, level)
if skipInst(inst) then return end
if inst:IsA("PostEffect") then
setp(inst, "Enabled", false)
elseif inst:IsA("BasePart") then
if level >= 2 and not inst:IsA("Terrain") then
setp(inst, "Material", Enum.Material.SmoothPlastic)
setp(inst, "Reflectance", 0)
setp(inst, "CastShadow", false)
end
if level >= 3 and inst:IsA("MeshPart") then
setp(inst, "TextureID", "")
setp(inst, "RenderFidelity", Enum.RenderFidelity.Performance)
end
elseif level >= 2 and (inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Beam")
or inst:IsA("Fire") or inst:IsA("Smoke") or inst:IsA("Sparkles")) then
setp(inst, "Enabled", false)
elseif level >= 2 and inst:IsA("Light") then
setp(inst, "Enabled", false)
elseif level >= 3 and inst:IsA("Decal") then
setp(inst, "Transparency", 1)
elseif level >= 3 and inst:IsA("SpecialMesh") then
setp(inst, "TextureId", "")
elseif level >= 3 and inst:IsA("SurfaceAppearance") then
setp(inst, "Parent", nil)
end
end
function revertFps()
fpsToken = fpsToken + 1
if fpsConn then fpsConn:Disconnect(); fpsConn = nil end
for inst, rec in pairs(FO) do
for prop, val in pairs(rec) do
pcall(function() inst[prop] = val end)
end
end
FO = setmetatable({}, { __mode = "k" })
pcall(function()
local r = settings().Rendering
if origRender.q ~= nil then r.QualityLevel = origRender.q end
if origRender.m ~= nil then r.MeshPartDetailLevel = origRender.m end
end)
if origRender.tech and sethiddenproperty then
pcall(function() sethiddenproperty(Lighting, "Technology", origRender.tech) end)
end
fpsLevel = 0
end
local function applyGlobals(level)
setp(Lighting, "GlobalShadows", false)
pcall(function()
local r = settings().Rendering
if origRender.q == nil then origRender.q = r.QualityLevel; origRender.m = r.MeshPartDetailLevel end
r.QualityLevel = level == 1 and Enum.QualityLevel.Level05 or (level == 2 and Enum.QualityLevel.Level03 or Enum.QualityLevel.Level01)
r.MeshPartDetailLevel = level >= 3 and Enum.MeshPartDetailLevel.Level04 or Enum.MeshPartDetailLevel.Level02
end)
pcall(function()
local tr = workspace.Terrain
setp(tr, "Decoration", false)
setp(tr, "WaterWaveSize", 0)
setp(tr, "WaterWaveSpeed", 0)
setp(tr, "WaterReflectance", 0)
end)
if level >= 2 then
setp(Lighting, "EnvironmentDiffuseScale", 0)
setp(Lighting, "EnvironmentSpecularScale", 0)
end
if level >= 3 and sethiddenproperty and gethiddenproperty then
pcall(function()
if origRender.tech == nil then origRender.tech = gethiddenproperty(Lighting, "Technology") end
sethiddenproperty(Lighting, "Technology", Enum.Technology.Legacy)
end)
end
end
function applyFps(name)
local level = FpsLevels[name] or 0
revertFps()
if level == 0 then Notify("FPS буст выключен") return end
fpsLevel = level
local my = fpsToken
Notify("FPS буст: " .. name .. " — применяю...")
applyGlobals(level)
fpsConn = workspace.DescendantAdded:Connect(function(d)
if fpsLevel > 0 then pcall(applyInst, d, fpsLevel) end
end)
task.spawn(function()
local n = 0
local function pass(root)
for _, d in ipairs(root:GetDescendants()) do
if fpsToken ~= my then return end
pcall(applyInst, d, level)
n = n + 1
if n % 400 == 0 then task.wait() end
end
end
pass(workspace); pass(Lighting)
if fpsToken == my then Notify("FPS буст применён: " .. name) end
end)
end
end -- do (FPS boost)
local function mkPart(parent, size, color, mat, transp)
local p = Instance.new("Part")
p.Size = size; p.Color = color or Color3.new(1, 1, 1); p.Material = mat or Enum.Material.SmoothPlastic
p.Transparency = transp or 0
p.CanCollide = false; p.CanQuery = false; p.CanTouch = false; p.Massless = true; p.CastShadow = false
p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
p.Parent = parent
return p
end
local function mkWeld(p0, p1, c0)
local w = Instance.new("Weld")
w.Part0, w.Part1, w.C0 = p0, p1, c0
w.Parent = p1
return w
end
local Halo = {}
function Halo.clear() if Halo.model then Halo.model:Destroy() end Halo.model, Halo.weld = nil, nil end
function Halo.build()
Halo.clear()
local char = LP.Character
local head = char and char:FindFirstChild("Head")
if not head then return end
local model = Instance.new("Model"); model.Name = "CozyHalo"
local hub = mkPart(model, Vector3.new(.2, .2, .2), nil, nil, 1)
Halo.weld = mkWeld(head, hub, CFrame.new(0, 1.1, 0))
local n, r = 16, .75
for kk = 0, n - 1 do
local th = kk / n * math.pi * 2
local seg = mkPart(model, Vector3.new(.5, .09, .09), Color3.fromRGB(255, 240, 200), Enum.Material.Neon)
mkWeld(hub, seg, CFrame.new(math.cos(th) * r, 0, math.sin(th) * r) * CFrame.Angles(0, -(th + math.pi / 2), 0))
end
model.Parent = char
Halo.model = model
end
function Halo.update()
if Halo.weld and Halo.weld.Parent then
local t = os.clock()
Halo.weld.C0 = CFrame.new(0, 1.1 + math.sin(t * 2) * .08, 0) * CFrame.Angles(0, t * 1.5, 0)
end
end
local TrailObj
local function setTrail(on)
if TrailObj then TrailObj:Destroy() TrailObj = nil end
local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
if on and root then
local a0 = new("Attachment", { Name = "CozyA0", Position = Vector3.new(0, 1, 0) }, root)
local a1 = new("Attachment", { Name = "CozyA1", Position = Vector3.new(0, -1, 0) }, root)
TrailObj = new("Trail", {
Attachment0 = a0, Attachment1 = a1, Lifetime = .8, LightEmission = 1, FaceCamera = true,
Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(120, 120, 130)),
Transparency = NumberSequence.new({ NSK(0, .2), NSK(1, 1) }),
}, root)
TrailObj.Destroying:Connect(function() a0:Destroy(); a1:Destroy() end)
end
end
local GlowHL
local function setGlow(on)
if GlowHL then GlowHL:Destroy() GlowHL = nil end
if on and LP.Character then
GlowHL = new("Highlight", { Name = "CozySelf", FillTransparency = .7, OutlineTransparency = 0, DepthMode = Enum.HighlightDepthMode.Occluded }, LP.Character)
end
end
local origLight = {
Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime, FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart,
GlobalShadows = Lighting.GlobalShadows, Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
}
local origFov = Camera.FieldOfView
local origAtmo = {}
for _, v in ipairs(Lighting:GetChildren()) do
if v:IsA("Atmosphere") then origAtmo[v] = v.Density end
end
local function restoreLight()
if not S.fullbright and not Shaders.active then
Lighting.Brightness, Lighting.ClockTime = origLight.Brightness, origLight.ClockTime
Lighting.GlobalShadows = (fpsLevel > 0) and false or origLight.GlobalShadows
Lighting.Ambient, Lighting.OutdoorAmbient = origLight.Ambient, origLight.OutdoorAmbient
end
if not S.nofog then
Lighting.FogEnd, Lighting.FogStart = origLight.FogEnd, origLight.FogStart
for a, dd in pairs(origAtmo) do if a.Parent then a.Density = dd end end
end
end
local function lightStep()
if S.fullbright then
Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.GlobalShadows = false
Lighting.Ambient = Color3.fromRGB(190, 190, 190); Lighting.OutdoorAmbient = Color3.fromRGB(190, 190, 190)
end
if S.nofog then
Lighting.FogEnd = 1e6; Lighting.FogStart = 1e6
for a in pairs(origAtmo) do if a.Parent then a.Density = 0 end end
end
if S.fov then Camera.FieldOfView = S.fovVal end
end
local function rebuildVisuals()
if S.halo then pcall(Halo.build) else Halo.clear() end
setTrail(S.trail)
setGlow(false)
end
conn(LP.CharacterAdded, function(char)
char:WaitForChild("HumanoidRootPart", 10)
char:WaitForChild("Head", 10)
task.wait(.4)
rebuildVisuals()
end)
do
local LIGHT_PROPS = {
"Brightness", "ClockTime", "Ambient", "OutdoorAmbient", "ColorShift_Top", "ColorShift_Bottom",
"ExposureCompensation", "EnvironmentDiffuseScale", "EnvironmentSpecularScale", "GlobalShadows",
"FogColor", "FogStart", "FogEnd", "ShadowSoftness",
}
local ATMO_PROPS = { "Density", "Offset", "Color", "Decay", "Glare", "Haze" }
local NEUTRAL = {
cc    = { Brightness = 0, Contrast = 0, Saturation = 0, TintColor = Color3.new(1, 1, 1) },
bloom = { Intensity = 0, Size = 24, Threshold = 2 },
sun   = { Intensity = 0, Spread = .3 },
dof   = { FarIntensity = 0, NearIntensity = 0, FocusDistance = 0, InFocusRadius = 10 },
}
local FX_CLASS = { cc = "ColorCorrectionEffect", bloom = "BloomEffect", sun = "SunRaysEffect", dof = "DepthOfFieldEffect" }
local RGB = Color3.fromRGB
local ShaderPresets = {
["Реалистичный"] = {
light = { Brightness = 2.6, ExposureCompensation = .15, Ambient = RGB(70, 72, 80), OutdoorAmbient = RGB(120, 125, 135),
ColorShift_Top = RGB(255, 236, 205), ColorShift_Bottom = RGB(60, 70, 90),
EnvironmentDiffuseScale = 1, EnvironmentSpecularScale = 1, GlobalShadows = true, ShadowSoftness = .25 },
cc = { Brightness = .02, Contrast = .12, Saturation = .18, TintColor = RGB(255, 248, 240) },
bloom = { Intensity = .35, Size = 28, Threshold = 1.6 },
sun = { Intensity = .18, Spread = .7 },
dof = { FarIntensity = .12, NearIntensity = 0, FocusDistance = 55, InFocusRadius = 45 },
atmo = { Density = .3, Offset = .2, Color = RGB(199, 215, 235), Decay = RGB(130, 150, 175), Glare = .25, Haze = 1.1 },
vig = .3, vigColor = RGB(0, 0, 0), tech = "Future",
},
["Кибер-панк"] = {
light = { Brightness = 1.4, ClockTime = 22, ExposureCompensation = .1, Ambient = RGB(48, 14, 82), OutdoorAmbient = RGB(88, 26, 140),
ColorShift_Top = RGB(255, 40, 190), ColorShift_Bottom = RGB(0, 200, 255),
EnvironmentDiffuseScale = 1, EnvironmentSpecularScale = 1, FogColor = RGB(40, 10, 70), ShadowSoftness = .15 },
cc = { Brightness = .02, Contrast = .3, Saturation = .55, TintColor = RGB(255, 215, 255) },
bloom = { Intensity = 1.1, Size = 42, Threshold = .85 },
sun = { Intensity = .08, Spread = 1 },
dof = { FarIntensity = .2, NearIntensity = 0, FocusDistance = 60, InFocusRadius = 55 },
atmo = { Density = .38, Offset = .1, Color = RGB(150, 60, 210), Decay = RGB(40, 10, 90), Glare = .6, Haze = 1.8 },
vig = .55, vigColor = RGB(10, 0, 25), pulse = RGB(190, 255, 255),
},
["Закат"] = {
light = { Brightness = 2.2, ClockTime = 17.7, ExposureCompensation = .1, Ambient = RGB(95, 70, 70), OutdoorAmbient = RGB(160, 105, 90),
ColorShift_Top = RGB(255, 150, 70), ColorShift_Bottom = RGB(120, 70, 110),
EnvironmentDiffuseScale = 1, EnvironmentSpecularScale = 1, ShadowSoftness = .3 },
cc = { Brightness = .01, Contrast = .15, Saturation = .3, TintColor = RGB(255, 225, 200) },
bloom = { Intensity = .55, Size = 32, Threshold = 1.2 },
sun = { Intensity = .35, Spread = .85 },
dof = { FarIntensity = .08, NearIntensity = 0, FocusDistance = 60, InFocusRadius = 50 },
atmo = { Density = .36, Offset = .25, Color = RGB(255, 180, 130), Decay = RGB(190, 90, 70), Glare = .8, Haze = 1.6 },
vig = .35, vigColor = RGB(30, 5, 0),
},
["Холодный"] = {
light = { Brightness = 2, ExposureCompensation = .05, Ambient = RGB(60, 75, 95), OutdoorAmbient = RGB(100, 125, 155),
ColorShift_Top = RGB(170, 205, 255), ColorShift_Bottom = RGB(40, 60, 90),
EnvironmentDiffuseScale = 1, EnvironmentSpecularScale = 1, ShadowSoftness = .3 },
cc = { Brightness = 0, Contrast = .18, Saturation = -.05, TintColor = RGB(215, 232, 255) },
bloom = { Intensity = .3, Size = 26, Threshold = 1.5 },
sun = { Intensity = .1, Spread = .6 },
dof = { FarIntensity = .1, NearIntensity = 0, FocusDistance = 55, InFocusRadius = 45 },
atmo = { Density = .42, Offset = .1, Color = RGB(190, 210, 235), Decay = RGB(100, 125, 160), Glare = .1, Haze = 2.2 },
vig = .4, vigColor = RGB(0, 0, 0),
},
}
local ShaderNames = { "Выкл", "Реалистичный", "Кибер-панк", "Закат", "Холодный" }
Shaders.names = ShaderNames
local function mixv(a, b, k)
local t = typeof(b)
if t == "number" then return a + (b - a) * k end
if t == "Color3" then return a:Lerp(b, k) end
if k > .5 then return b end
return a
end
local function tweenProps(inst, props, t)
for k, v in pairs(props) do
pcall(function()
local tv = typeof(v)
if t > 0 and (tv == "number" or tv == "Color3") then
TweenService:Create(inst, TweenInfo.new(t, Enum.EasingStyle.Sine), { [k] = v }):Play()
else
inst[k] = v
end
end)
end
end
function Shaders.save()
if Shaders.saved then return end
local sv = { light = {} }
for _, p in ipairs(LIGHT_PROPS) do
local ok, v = pcall(function() return Lighting[p] end)
if ok then sv.light[p] = v end
end
for _, a in ipairs(Lighting:GetChildren()) do
if a:IsA("Atmosphere") and string.sub(a.Name, 1, 6) ~= "CozyFX" then
sv.atmo = { inst = a, vals = {} }
for _, p in ipairs(ATMO_PROPS) do sv.atmo.vals[p] = a[p] end
break
end
end
if gethiddenproperty then pcall(function() sv.tech = gethiddenproperty(Lighting, "Technology") end) end
Shaders.saved = sv
end
local function getFx(key)
local e = Shaders.fx[key]
if e and e.Parent then return e end
e = Instance.new(FX_CLASS[key])
e.Name = "CozyFX_" .. key
for k, v in pairs(NEUTRAL[key]) do pcall(function() e[k] = v end) end
e.Parent = Lighting
Shaders.fx[key] = e
return e
end
local function getAtmo()
local sv = Shaders.saved
if sv.atmo and sv.atmo.inst.Parent then return sv.atmo.inst, sv.atmo.vals end
local a = Shaders.fx.atmo
if not a or not a.Parent then
a = Instance.new("Atmosphere")
a.Name = "CozyFX_atmo"
a.Density = 0; a.Offset = 0; a.Glare = 0; a.Haze = 0
a.Parent = Lighting
Shaders.fx.atmo = a
end
return a, { Density = 0, Offset = 0, Color = a.Color, Decay = a.Decay, Glare = 0, Haze = 0 }
end
function Shaders.vignette(a, color)
if a <= .01 then
VigLayer.Visible = false
return
end
VigLayer.Visible = true
for i, f in ipairs(VigFrames) do
f.BackgroundColor3 = color or BLACK
VigGrads[i].Transparency = NumberSequence.new({ NSK(0, 1 - math.clamp(a, 0, .95)), NSK(1, 1) })
end
end
function Shaders.apply(name)
local p = ShaderPresets[name]
if not p then return Shaders.reset() end
Shaders.save()
Shaders.active = name
Shaders.t0 = os.clock()
local k = S.shaderInt / 100
local TT = 1.1
local props = {}
for prop, target in pairs(p.light) do
local base = Shaders.saved.light[prop]
if base ~= nil then props[prop] = mixv(base, target, k) end
end
tweenProps(Lighting, props, TT)
for key in pairs(FX_CLASS) do
local target = p[key]
if target then
local e = getFx(key)
local pr = {}
for prop, v in pairs(target) do pr[prop] = mixv(NEUTRAL[key][prop], v, k) end
tweenProps(e, pr, TT)
elseif Shaders.fx[key] and Shaders.fx[key].Parent then
tweenProps(Shaders.fx[key], NEUTRAL[key], TT)
end
end
if p.atmo then
local a, vals = getAtmo()
local pr = {}
for prop, v in pairs(p.atmo) do pr[prop] = mixv(vals[prop], v, k) end
tweenProps(a, pr, TT)
end
Shaders.vignette((p.vig or 0) * k, p.vigColor)
if sethiddenproperty then
local tgt = (p.tech and k > .5) and Enum.Technology[p.tech] or Shaders.saved.tech
if tgt then pcall(function() sethiddenproperty(Lighting, "Technology", tgt) end) end
end
end
function Shaders.reset(instant)
local sv = Shaders.saved
Shaders.active = nil
VigLayer.Visible = false
if not sv then return end
local TT = instant and 0 or .9
tweenProps(Lighting, sv.light, TT)
if sv.atmo and sv.atmo.inst.Parent then tweenProps(sv.atmo.inst, sv.atmo.vals, TT) end
for key, e in pairs(Shaders.fx) do
if e and e.Parent then
if key == "atmo" then tweenProps(e, { Density = 0, Haze = 0, Glare = 0, Offset = 0 }, TT)
else tweenProps(e, NEUTRAL[key], TT) end
if instant then
e:Destroy()
else
task.delay(TT + .1, function() if e.Parent and not Shaders.active then e:Destroy() end end)
end
end
end
if sv.tech and sethiddenproperty then pcall(function() sethiddenproperty(Lighting, "Technology", sv.tech) end) end
if instant then
Shaders.fx, Shaders.saved = {}, nil
else
task.delay(TT + .15, function() if not Shaders.active then Shaders.saved = nil end end)
end
end
function Shaders.step()
local p = Shaders.active and ShaderPresets[Shaders.active]
if not p or not p.pulse then return end
local el = os.clock() - Shaders.t0 - 1.5
if el < 0 then return end
local cc = Shaders.fx.cc
if not (cc and cc.Parent) then return end
local k = S.shaderInt / 100
local base = Color3.new(1, 1, 1):Lerp(p.cc.TintColor, k)
local alt = Color3.new(1, 1, 1):Lerp(p.pulse, k)
cc.TintColor = base:Lerp(alt, (1 - math.cos(el * .7)) / 2)
end
Shaders.token = 0
local function applyShaderPreset(name)
if name == "Выкл" then
Shaders.reset()
Notify("Шейдеры выключены")
else
Shaders.apply(name)
Notify("Шейдер: " .. name)
end
end
Shaders.applyPreset = applyShaderPreset
end -- do (шейдеры)
local FS = { root = "CozyHub" }
FS.ok = type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
FS.mem = (getgenv and getgenv().CozyHubMem) or {}
if getgenv then getgenv().CozyHubMem = FS.mem end
local function fsFolder(path)
if type(isfolder) == "function" and type(makefolder) == "function" then
pcall(function() if not isfolder(path) then makefolder(path) end end)
end
end
function FS.init()
fsFolder(FS.root); fsFolder(FS.root .. "/configs"); fsFolder(FS.root .. "/music")
end
function FS.write(rel, data)
if FS.ok then
local ok = pcall(writefile, FS.root .. "/" .. rel, data)
if ok then FS.mem[rel] = nil return true end
end
FS.mem[rel] = data
return false
end
function FS.read(rel)
if FS.ok then
local ok, d = pcall(function()
local p = FS.root .. "/" .. rel
if isfile(p) then return readfile(p) end
end)
if ok and d then return d end
end
return FS.mem[rel]
end
function FS.delete(rel)
if FS.ok and type(delfile) == "function" then
pcall(function()
local p = FS.root .. "/" .. rel
if isfile(p) then delfile(p) end
end)
end
FS.mem[rel] = nil
end
function FS.list(dirRel)
local out, seen = {}, {}
if FS.ok and type(listfiles) == "function" then
pcall(function()
for _, p in ipairs(listfiles(FS.root .. "/" .. dirRel)) do
local name = string.match(p, "([^/\\]+)$")
if name and not seen[name] then seen[name] = true; table.insert(out, name) end
end
end)
end
for rel in pairs(FS.mem) do
local d, name = string.match(rel, "^(.-)/([^/]+)$")
if d == dirRel and not seen[name] then seen[name] = true; table.insert(out, name) end
end
table.sort(out)
return out
end
FS.init()
local HB = setmetatable({}, { __mode = "k" })
local HB_HEAD_COL, HB_BODY_COL = Color3.fromRGB(255, 80, 110), Color3.fromRGB(90, 200, 255)
local function hbRestoreOne(part, rec)
if rec.sel then pcall(function() rec.sel:Destroy() end) end
if part and part.Parent then
pcall(function()
part.Size = rec.size; part.Transparency = rec.trans; part.CanCollide = rec.cc; part.Massless = rec.ml
end)
end
end
local function hitboxRestore()
for part, rec in pairs(HB) do hbRestoreOne(part, rec); HB[part] = nil end
end
local function hbApply(part, size, transPct, hl, color)
local rec = HB[part]
if not rec then
rec = { size = part.Size, trans = part.Transparency, cc = part.CanCollide, ml = part.Massless }
HB[part] = rec
end
local want = Vector3.new(size, size, size)
if part.Size ~= want then part.Size = want end
local tt = math.max(rec.trans, transPct / 100)
if part.Transparency ~= tt then part.Transparency = tt end
if part.CanCollide then part.CanCollide = false end
if not part.Massless then part.Massless = true end
if hl then
if not rec.sel or rec.sel.Parent == nil then
local sb = Instance.new("SelectionBox")
sb.Name = "CozyFX_hb"
sb.LineThickness = .04
sb.SurfaceTransparency = .82
sb.Adornee = part
sb.Parent = part
rec.sel = sb
end
rec.sel.Color3 = color
rec.sel.SurfaceColor3 = color
elseif rec.sel then
rec.sel:Destroy()
rec.sel = nil
end
end
local function hitboxStep()
if not (S.hitbox or S.bodyHitbox) then
if next(HB) then hitboxRestore() end
return
end
for _, plr in ipairs(Players:GetPlayers()) do
if plr ~= LP then
local char = plr.Character
local skip = S.hitboxTeam and not isEnemy(plr)
local head = char and char:FindFirstChild("Head")
local root = char and char:FindFirstChild("HumanoidRootPart")
if head and head:IsA("BasePart") then
if S.hitbox and not skip then
hbApply(head, S.hitboxSize, S.hitboxTrans, S.hitboxHl, HB_HEAD_COL)
elseif HB[head] then
hbRestoreOne(head, HB[head]); HB[head] = nil
end
end
if root and root:IsA("BasePart") then
if S.bodyHitbox and not skip then
hbApply(root, S.bodySize, S.bodyTrans, S.bodyHl, HB_BODY_COL)
elseif HB[root] then
hbRestoreOne(root, HB[root]); HB[root] = nil
end
end
end
end
end
local Target = { cur = nil, active = false, hudOn = false, hpFill = 1 }
do
local TAU = math.pi * 2
local Layer = new("Folder", { Name = "Target" }, ESPLayer)
local dots, lines = {}, {}
local usedD, usedL = 0, 0
local P = { inv = CFrame.new(), vp = Vector2.new(1, 1), sc = 1 }
local TGT_COLORS = {
["Красный"] = Color3.fromRGB(255, 70, 90), ["Белый"] = Color3.fromRGB(255, 255, 255),
["Голубой"] = Color3.fromRGB(90, 210, 255), ["Розовый"] = Color3.fromRGB(255, 110, 200),
["Зелёный"] = Color3.fromRGB(90, 255, 140), ["Золотой"] = Color3.fromRGB(255, 205, 70),
}
local function colAt(j)
local m = S.tgtColor
if m == "Радуга" then return Color3.fromHSV((os.clock() * .25 + j * .03) % 1, .75, 1) end
return TGT_COLORS[m] or T.accent
end
local function getDot(i)
local d = dots[i]
if not d then
d = new("Frame", { AnchorPoint = Vector2.new(.5, .5), Visible = false, Size = UDim2.fromOffset(6, 6) }, Layer)
corner(d, 14)
dots[i] = d
end
return d
end
local function getLine(i)
local l = lines[i]
if not l then
l = new("Frame", { AnchorPoint = Vector2.new(.5, .5), Visible = false }, Layer)
lines[i] = l
end
return l
end
local function proj(wp)
local cp = P.inv * wp
local depth = -cp.Z
if depth < .1 then return nil end
return Vector2.new(P.vp.X / 2 + cp.X / depth * P.sc, P.vp.Y / 2 - cp.Y / depth * P.sc), depth
end
local function dot(wp, size, tr, col)
if usedD >= 40 then return end
usedD = usedD + 1
local d = getDot(usedD)
local p, depth = proj(wp)
if p then
local sz = math.clamp(size * P.sc / depth, 2, 30)
d.Size = UDim2.fromOffset(sz, sz)
d.Position = UDim2.fromOffset(p.X, p.Y)
d.BackgroundColor3 = col
d.BackgroundTransparency = tr
d.Visible = true
else
d.Visible = false
end
end
local function seg2(a, b, th, col, tr)
if usedL >= 40 then return end
usedL = usedL + 1
local l = getLine(usedL)
local d = b - a
l.Visible = true
l.BackgroundColor3 = col
l.BackgroundTransparency = tr or 0
l.Size = UDim2.fromOffset(d.Magnitude + 1, th)
l.Position = UDim2.fromOffset((a.X + b.X) / 2, (a.Y + b.Y) / 2)
l.Rotation = math.deg(math.atan2(d.Y, d.X))
end
local function seg3(a, b, th, col, tr)
local pa, pb = proj(a), proj(b)
if pa and pb then seg2(pa, pb, th, col, tr) end
end
local function nz(a, b)
local x = math.sin(a * 12.9898 + b * 78.233) * 43758.5453
return x - math.floor(x)
end
local function hideEffects()
for i = 1, #dots do dots[i].Visible = false end
for i = 1, #lines do lines[i].Visible = false end
end
local function draw(style, cf, size, char)
local c = cf.Position
local H = size.Y
local sz = S.tgtSize / 100
local R = (math.max(size.X, size.Z) / 2 + 1.3) * sz
local t = os.clock() * (S.tgtSpeed / 100)
local cos, sin = math.cos, math.sin
local function level(k) return c.Y - H / 2 + (sin(t * 1.8 + k) * .5 + .5) * H end
if style == "Кольцо" then
local y = level(0)
for j = 0, 23 do
local a = j / 24 * TAU + t * 2
dot(Vector3.new(c.X + cos(a) * R, y, c.Z + sin(a) * R), .34 * sz, .15 + .55 * (sin(a * 2 - t * 3) * .5 + .5), colAt(j))
end
elseif style == "Двойное кольцо" then
for k = 0, 1 do
local y = level(k * math.pi)
local r = R * (k == 0 and 1 or .82)
for j = 0, 15 do
local a = j / 16 * TAU + t * (k == 0 and 2 or -2)
dot(Vector3.new(c.X + cos(a) * r, y, c.Z + sin(a) * r), .3 * sz, .1 + .5 * (sin(a * 2 - t * 3) * .5 + .5), colAt(j + k * 16))
end
end
elseif style == "Спираль" then
for j = 0, 27 do
local a = t * 2.5 + j * .5
dot(Vector3.new(c.X + cos(a) * R, c.Y - H / 2 + j / 27 * H, c.Z + sin(a) * R), .32 * sz, j / 27 * .7, colAt(j))
end
elseif style == "Призраки" then
for i = 0, 2 do
for k = 0, 5 do
local tt = t - k * .07
local a = tt * (1.5 + i * .35) + i * 2.1
local r = R * (1 + i * .15)
local h = sin(tt * 1.7 + i * 1.3) * H * .3
dot(Vector3.new(c.X + cos(a) * r, c.Y + h, c.Z + sin(a) * r), .95 * sz * (1 - k / 8), .05 + k / 6 * .85, colAt(i * 6 + k))
end
end
elseif style == "Орбиты" then
for k = 0, 2 do
local rot = CFrame.Angles(k * 1.05 + .4, t * (1 + k * .35), k * .7)
for j = 0, 11 do
local a = j / 12 * TAU
dot(c + rot * Vector3.new(cos(a) * R * 1.05, 0, sin(a) * R * 1.05), .26 * sz, j / 12 * .6, colAt(j + k * 12))
end
end
elseif style == "Пульс" then
for k = 0, 1 do
local p = (t * .7 + k * .5) % 1
local r = R * .5 + R * 1.7 * p
for j = 0, 19 do
local a = j / 20 * TAU
dot(Vector3.new(c.X + cos(a) * r, c.Y - H / 2 + .25, c.Z + sin(a) * r), .3 * sz * (1 - p * .4), .1 + .85 * p, colAt(j))
end
end
elseif style == "Торнадо" then
for j = 0, 29 do
local l = j / 29
local a = t * 3 + j * .9
local r = R * (.4 + 1.1 * l)
dot(Vector3.new(c.X + cos(a) * r, c.Y - H / 2 + l * H * 1.3, c.Z + sin(a) * r), .3 * sz, l * .6, colAt(j))
end
elseif style == "Звёзды" then
for j = 1, 16 do
local a = nz(j, 1) * TAU + t * .5
local r = R * (.5 + nz(j, 2) * .9)
local y = c.Y - H / 2 + ((t * .35 + nz(j, 3)) % 1) * H * 1.2
local tw2 = sin(t * 4 + j) * .5 + .5
dot(Vector3.new(c.X + cos(a) * r, y, c.Z + sin(a) * r), (.1 + .3 * tw2) * sz, .1 + .5 * (1 - tw2), colAt(j))
end
elseif style == "Нимб" then
local y = c.Y + H / 2 + .9 * sz + sin(t * 2) * .1
for j = 0, 17 do
local a = j / 18 * TAU + t * 2
dot(Vector3.new(c.X + cos(a) * .85 * sz, y, c.Z + sin(a) * .85 * sz), .26 * sz, .05, colAt(j))
end
elseif style == "Квадрат" then
for k = 0, 1 do
local y = level(-k * .6)
local pts = {}
for m = 0, 3 do
local a = t * 1.2 + math.pi / 4 + m * math.pi / 2
pts[m] = Vector3.new(c.X + cos(a) * R * 1.2, y, c.Z + sin(a) * R * 1.2)
end
for m = 0, 3 do seg3(pts[m], pts[(m + 1) % 4], k == 0 and 2.2 or 1.2, colAt(m + k * 4), k == 0 and 0 or .5) end
end
elseif style == "Октаэдр" or style == "Клетка" or style == "Сфера" then
local shape = style == "Клетка" and "3D бокс" or style
local segs = shapeSegs(shape, cf, size * sz, char)
for i = 1, math.min(#segs, 40) do seg3(segs[i][1], segs[i][2], 1.8, colAt(i), 0) end
elseif style == "Прицел" then
local x0, y0, x1, y1 = math.huge, math.huge, -math.huge, -math.huge
for x = -1, 1, 2 do for y = -1, 1, 2 do for z = -1, 1, 2 do
local p = proj((cf * CFrame.new(size.X / 2 * x, size.Y / 2 * y, size.Z / 2 * z)).Position)
if not p then return end
x0, y0, x1, y1 = math.min(x0, p.X), math.min(y0, p.Y), math.max(x1, p.X), math.max(y1, p.Y)
end end end
local pad = 4 + 7 * (sin(t * 3) * .5 + .5)
x0, y0, x1, y1 = x0 - pad, y0 - pad, x1 + pad, y1 + pad
local L = math.clamp(math.min(x1 - x0, y1 - y0) * .3, 8, 26)
local col = colAt(0)
local V = Vector2.new
seg2(V(x0, y0), V(x0 + L, y0), 2.2, col); seg2(V(x0, y0), V(x0, y0 + L), 2.2, col)
seg2(V(x1, y0), V(x1 - L, y0), 2.2, col); seg2(V(x1, y0), V(x1, y0 + L), 2.2, col)
seg2(V(x0, y1), V(x0 + L, y1), 2.2, col); seg2(V(x0, y1), V(x0, y1 - L), 2.2, col)
seg2(V(x1, y1), V(x1 - L, y1), 2.2, col); seg2(V(x1, y1), V(x1, y1 - L), 2.2, col)
end
end
local function scoreOf(plr)
local char = aliveChar(plr)
if not char then return nil end
local root = char:FindFirstChild("HumanoidRootPart")
if not root then return nil end
local dist = (root.Position - Camera.CFrame.Position).Magnitude
if dist > S.tgtRange then return nil end
if S.tgtSel == "По дистанции" then return dist end
local p, on = Camera:WorldToViewportPoint(root.Position)
if not on then return nil end
local sd = (Vector2.new(p.X, p.Y) - aimCenter()).Magnitude
if sd > S.tgtFov then return nil end
return sd
end
local hud = new("CanvasGroup", {
AnchorPoint = Vector2.new(.5, 1), Position = UDim2.new(.5, 0, .84, 0), Size = UDim2.fromOffset(240, 66),
BackgroundColor3 = T.bg, GroupTransparency = 1, Visible = false, ZIndex = 30,
}, Gui)
corner(hud, 12)
new("UIStroke", { Color = T.accent, Transparency = .5, Thickness = 1.3 }, hud)
local hudScale = new("UIScale", { Scale = .85 }, hud)
local hudName = new("TextLabel", {
BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 7), Size = UDim2.new(1, -28, 0, 18), Text = "",
Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = T.text, TextXAlignment = Enum.TextXAlignment.Left,
TextTruncate = Enum.TextTruncate.AtEnd,
}, hud)
local hudInfo = new("TextLabel", {
BackgroundTransparency = 1, Position = UDim2.fromOffset(14, 27), Size = UDim2.new(1, -28, 0, 14), Text = "",
Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = T.sub, TextXAlignment = Enum.TextXAlignment.Left,
}, hud)
local hudBar = new("Frame", { Position = UDim2.new(0, 14, 0, 47), Size = UDim2.new(1, -28, 0, 8), BackgroundColor3 = T.off }, hud)
corner(hudBar, 4)
local hudFill = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(80, 255, 120) }, hudBar)
corner(hudFill, 4)
Target.hud = hud
local function setHud(on)
if on == Target.hudOn then return end
Target.hudOn = on
if on then
hud.Visible = true
tw(hud, .2, { GroupTransparency = 0 })
tw(hudScale, .35, { Scale = 1 }, Enum.EasingStyle.Back)
else
tw(hud, .2, { GroupTransparency = 1 })
tw(hudScale, .2, { Scale = .85 })
task.delay(.22, function() if not Target.hudOn then hud.Visible = false end end)
end
end
function Target.step(dt)
if not (unlocked and S.tgt) then
if Target.active then hideEffects(); Target.active = false end
Target.cur = nil
setHud(false)
return
end
local best, bestScore
for _, plr in ipairs(Players:GetPlayers()) do
if plr ~= LP and (not S.tgtTeam or isEnemy(plr)) then
local sc = scoreOf(plr)
if sc and (not bestScore or sc < bestScore) then best, bestScore = plr, sc end
end
end
local cur = Target.cur
if cur and cur ~= best and cur.Parent == Players and cur ~= LP and (not S.tgtTeam or isEnemy(cur)) then
local cs = scoreOf(cur)
if cs and bestScore and cs <= bestScore * 1.3 + 15 then best = cur end
end
Target.cur = best
local char, hum
if best then char, hum = aliveChar(best) end
local root = char and char:FindFirstChild("HumanoidRootPart")
if not (best and root and hum) then
if Target.active then hideEffects(); Target.active = false end
setHud(false)
return
end
P.inv = Camera.CFrame:Inverse()
P.vp = Camera.ViewportSize
P.sc = (P.vp.Y / 2) / math.tan(math.rad(Camera.FieldOfView) / 2)
usedD, usedL = 0, 0
local cf, size = char:GetBoundingBox()
pcall(draw, S.tgtStyle, cf, size, char)
for i = usedD + 1, #dots do dots[i].Visible = false end
for i = usedL + 1, #lines do lines[i].Visible = false end
Target.active = true
if S.tgtHud then
setHud(true)
local frac = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
Target.hpFill = Target.hpFill + (frac - Target.hpFill) * math.min((dt or .016) * 8, 1)
hudFill.Size = UDim2.fromScale(math.max(Target.hpFill, .01), 1)
hudFill.BackgroundColor3 = Color3.fromRGB(255, 70, 70):Lerp(Color3.fromRGB(80, 255, 120), Target.hpFill)
hudName.Text = best.DisplayName
hudInfo.Text = string.format("%d / %d HP  ·  %dm", hum.Health, hum.MaxHealth, (root.Position - Camera.CFrame.Position).Magnitude)
else
setHud(false)
end
end
end
local function stretchStep()
if not S.stretch then return end
local kx, ky = 1, 1
local m = S.stretchMode
if m == "Своя" then
kx, ky = S.stretchX / 100, S.stretchVal / 100
else
local a, b = m:match("^(%d+):(%d+)$")
local vp = Camera.ViewportSize
if a and vp.Y > 0 then
local r, t = vp.X / vp.Y, tonumber(a) / tonumber(b)
if t < r then ky = t / r else kx = r / t end
end
end
Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, kx, 0, 0, 0, ky, 0, 0, 0, 1)
end
local Xhair = { dyn = 0 }
do
local C3 = Color3.fromRGB
local XH_COLORS = {
["Белый"] = C3(255, 255, 255), ["Красный"] = C3(255, 60, 70), ["Зелёный"] = C3(70, 255, 120),
["Голубой"] = C3(80, 210, 255), ["Розовый"] = C3(255, 110, 200), ["Жёлтый"] = C3(255, 225, 80),
}
Xhair.styles = { "Крест", "Т-образный", "Крест + точка", "Точка", "Круг", "Круг + риски", "Квадрат", "Ромб", "Углы", "Х-крест", "Звезда", "Стрелки", "Треугольник" }
Xhair.colors = { "Белый", "Тема", "Красный", "Зелёный", "Голубой", "Розовый", "Жёлтый", "Радуга" }
local layer = new("Frame", { Name = "Xhair", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false, ZIndex = 0 }, Gui)
local function build(parent)
local o = { segs = {} }
for i = 1, 16 do
local f = new("Frame", { AnchorPoint = Vector2.new(.5, .5), Visible = false }, parent)
local st = new("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1, Enabled = false }, f)
o.segs[i] = { f = f, st = st }
end
o.ring = new("Frame", { AnchorPoint = Vector2.new(.5, .5), BackgroundTransparency = 1, Visible = false }, parent)
corner(o.ring, 999)
o.ringStroke = new("UIStroke", { Thickness = 2 }, o.ring)
o.dot = new("Frame", { AnchorPoint = Vector2.new(.5, .5), Visible = false }, parent)
corner(o.dot, 999)
o.dotStroke = new("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1, Enabled = false }, o.dot)
return o
end
local function draw(o, c, gapExtra, col, rot)
local L, th = S.xhSize, S.xhThick
local g = S.xhGap + gapExtra
local alpha = 1 - S.xhAlpha / 100
local style = S.xhStyle
local cosr, sinr = math.cos(rot), math.sin(rot)
local n = 0
local function rotp(x, y) return Vector2.new(c.X + x * cosr - y * sinr, c.Y + x * sinr + y * cosr) end
local function seg(x1, y1, x2, y2)
n = n + 1
local sg = o.segs[n]
if not sg then return end
local a, b = rotp(x1, y1), rotp(x2, y2)
local d = b - a
local f = sg.f
f.Visible = true
f.BackgroundColor3 = col
f.BackgroundTransparency = alpha
f.Size = UDim2.fromOffset(d.Magnitude + th, th)
f.Position = UDim2.fromOffset((a.X + b.X) / 2, (a.Y + b.Y) / 2)
f.Rotation = math.deg(math.atan2(d.Y, d.X))
sg.st.Enabled = S.xhOutline
sg.st.Transparency = alpha
end
local function cross()
seg(0, -g, 0, -g - L); seg(0, g, 0, g + L); seg(-g, 0, -g - L, 0); seg(g, 0, g + L, 0)
end
local showDot, ringR = S.xhDot, nil
if style == "Крест" then cross()
elseif style == "Т-образный" then
seg(0, g, 0, g + L); seg(-g, 0, -g - L, 0); seg(g, 0, g + L, 0)
elseif style == "Крест + точка" then cross(); showDot = true
elseif style == "Точка" then showDot = true
elseif style == "Круг" then ringR = L
elseif style == "Круг + риски" then
ringR = L + g
local r2, r1 = ringR + L * .6, ringR
seg(0, -r1, 0, -r2); seg(0, r1, 0, r2); seg(-r1, 0, -r2, 0); seg(r1, 0, r2, 0)
elseif style == "Квадрат" then
local h = L
seg(-h, -h, h, -h); seg(h, -h, h, h); seg(h, h, -h, h); seg(-h, h, -h, -h)
elseif style == "Ромб" then
local h = L * 1.25
seg(0, -h, h, 0); seg(h, 0, 0, h); seg(0, h, -h, 0); seg(-h, 0, 0, -h)
elseif style == "Углы" then
local h, a = L, math.max(3, L * .55)
seg(-h, -h, -h + a, -h); seg(-h, -h, -h, -h + a)
seg(h, -h, h - a, -h); seg(h, -h, h, -h + a)
seg(-h, h, -h + a, h); seg(-h, h, -h, h - a)
seg(h, h, h - a, h); seg(h, h, h, h - a)
elseif style == "Х-крест" then
local d1, e = g * .7, (g + L) * .7
seg(-d1, -d1, -e, -e); seg(d1, -d1, e, -e); seg(-d1, d1, -e, e); seg(d1, d1, e, e)
elseif style == "Звезда" then
cross()
local d1, e = g * .7, (g + L) * .7
seg(-d1, -d1, -e, -e); seg(d1, -d1, e, -e); seg(-d1, d1, -e, e); seg(d1, d1, e, e)
elseif style == "Стрелки" then
local a = L * .6
seg(0, -g, -a, -g - a); seg(0, -g, a, -g - a)
seg(0, g, -a, g + a); seg(0, g, a, g + a)
seg(-g, 0, -g - a, -a); seg(-g, 0, -g - a, a)
seg(g, 0, g + a, -a); seg(g, 0, g + a, a)
elseif style == "Треугольник" then
seg(0, -L, L * .87, L * .5); seg(L * .87, L * .5, -L * .87, L * .5); seg(-L * .87, L * .5, 0, -L)
end
for i = n + 1, #o.segs do o.segs[i].f.Visible = false end
if ringR then
o.ring.Visible = true
o.ring.Position = UDim2.fromOffset(c.X, c.Y)
o.ring.Size = UDim2.fromOffset(ringR * 2, ringR * 2)
o.ringStroke.Color = col
o.ringStroke.Thickness = th
o.ringStroke.Transparency = alpha
else
o.ring.Visible = false
end
if showDot then
local ds = math.max(2, th * 1.6)
o.dot.Visible = true
o.dot.Position = UDim2.fromOffset(c.X, c.Y)
o.dot.Size = UDim2.fromOffset(ds, ds)
o.dot.BackgroundColor3 = col
o.dot.BackgroundTransparency = alpha
o.dotStroke.Enabled = S.xhOutline
o.dotStroke.Transparency = alpha
else
o.dot.Visible = false
end
end
local main = build(layer)
Xhair.preview = nil
local rp = RaycastParams.new()
rp.FilterType = Enum.RaycastFilterType.Exclude
local function overPlayer()
rp.FilterDescendantsInstances = { LP.Character }
local vp = Camera.ViewportSize
local ray = Camera:ViewportPointToRay(vp.X / 2, vp.Y / 2)
local res = workspace:Raycast(ray.Origin, ray.Direction * 1000, rp)
if res and res.Instance then
local m = res.Instance:FindFirstAncestorOfClass("Model")
if m and m:FindFirstChildOfClass("Humanoid") and Players:GetPlayerFromCharacter(m) then return true end
end
return false
end
local function pickColor()
local m = S.xhColor
if m == "Радуга" then return Color3.fromHSV((os.clock() * .3) % 1, .8, 1) end
if m == "Тема" then return T.accent end
return XH_COLORS[m] or XH_COLORS["Белый"]
end
function Xhair.makePreview(parent)
Xhair.preview = build(parent)
Xhair.previewFrame = parent
end
function Xhair.step(dt)
local on = unlocked and S.xh
layer.Visible = on and true or false
local col = pickColor()
local rot = math.rad((os.clock() * S.xhSpin) % 360)
if S.xhDyn then
local char = LP.Character
local root = char and char:FindFirstChild("HumanoidRootPart")
local sp = root and root.AssemblyLinearVelocity.Magnitude or 0
Xhair.dyn = Xhair.dyn + (math.min(sp * .25, 14) - Xhair.dyn) * math.min((dt or .016) * 10, 1)
else
Xhair.dyn = 0
end
if on then
local vp = Camera.ViewportSize
local c = Vector2.new(vp.X / 2 + S.xhOffX, vp.Y / 2 + S.xhOffY)
local mc = col
if S.xhHit and overPlayer() then mc = XH_COLORS["Красный"] end
draw(main, c, Xhair.dyn, mc, rot)
end
if Xhair.preview and Xhair.page and Xhair.page.Visible and Main.Visible then
local sz = Xhair.previewFrame.AbsoluteSize / math.max(MainScale.Scale, .01)
draw(Xhair.preview, sz / 2, Xhair.dyn, col, rot)
end
end
end
local function CC(r, g, b) return Color3.fromRGB(r, g, b) end
local Themes = {
["Чёрно-белая"] = { bg = CC(8, 8, 10), side = CC(14, 14, 17), card = CC(22, 22, 26), hover = CC(40, 40, 46), off = CC(58, 58, 66),
accent = WHITE, text = WHITE, sub = CC(150, 150, 158), g1 = CC(4, 4, 6), g2 = CC(52, 52, 60), dust = CC(255, 255, 255), dir = -1, tw = 1 },
["Лавандовая"] = { bg = CC(24, 18, 38), side = CC(32, 24, 52), card = CC(46, 36, 72), hover = CC(62, 50, 96), off = CC(80, 68, 114),
accent = CC(190, 160, 255), text = CC(242, 235, 255), sub = CC(176, 160, 212), g1 = CC(14, 10, 26), g2 = CC(92, 62, 150), dust = CC(224, 204, 255), dir = -1, tw = 1 },
["Космическая"] = { bg = CC(6, 8, 20), side = CC(10, 14, 32), card = CC(18, 24, 54), hover = CC(28, 38, 80), off = CC(44, 54, 104),
accent = CC(110, 170, 255), text = CC(228, 236, 255), sub = CC(132, 152, 204), g1 = CC(3, 4, 14), g2 = CC(46, 30, 120), dust = CC(210, 225, 255), dir = -1, tw = 2.4 },
["Хэллоуин"] = { bg = CC(14, 8, 4), side = CC(22, 13, 6), card = CC(38, 22, 8), hover = CC(58, 33, 10), off = CC(88, 52, 16),
accent = CC(255, 132, 24), text = CC(255, 238, 216), sub = CC(204, 152, 102), g1 = CC(8, 4, 2), g2 = CC(110, 44, 0), dust = CC(255, 150, 40), dir = -1, tw = 1.4 },
["Сакура"] = { bg = CC(30, 16, 22), side = CC(40, 22, 30), card = CC(60, 34, 46), hover = CC(82, 47, 64), off = CC(106, 64, 84),
accent = CC(255, 160, 200), text = CC(255, 240, 246), sub = CC(214, 164, 188), g1 = CC(20, 10, 16), g2 = CC(136, 62, 100), dust = CC(255, 205, 228), dir = 1, tw = 1 },
["Океан"] = { bg = CC(6, 18, 26), side = CC(8, 26, 38), card = CC(14, 42, 60), hover = CC(22, 62, 86), off = CC(36, 88, 116),
accent = CC(80, 210, 230), text = CC(228, 249, 255), sub = CC(124, 174, 194), g1 = CC(3, 12, 20), g2 = CC(0, 90, 114), dust = CC(176, 242, 255), dir = -1, tw = 1.2 },
["Неон"] = { bg = CC(10, 6, 22), side = CC(16, 10, 34), card = CC(28, 16, 56), hover = CC(44, 24, 84), off = CC(70, 36, 120),
accent = CC(255, 60, 200), text = CC(255, 235, 252), sub = CC(190, 140, 220), g1 = CC(6, 2, 16), g2 = CC(0, 120, 150), dust = CC(80, 255, 255), dir = -1, tw = 1.8 },
["Матрица"] = { bg = CC(2, 10, 4), side = CC(4, 16, 8), card = CC(8, 28, 14), hover = CC(12, 44, 22), off = CC(20, 70, 34),
accent = CC(40, 255, 110), text = CC(214, 255, 226), sub = CC(96, 170, 120), g1 = CC(0, 6, 2), g2 = CC(0, 70, 26), dust = CC(60, 255, 120), dir = 1, tw = 1.6 },
["Закат"] = { bg = CC(24, 10, 12), side = CC(34, 14, 16), card = CC(56, 22, 22), hover = CC(80, 32, 28), off = CC(112, 48, 38),
accent = CC(255, 120, 80), text = CC(255, 238, 228), sub = CC(214, 150, 130), g1 = CC(16, 6, 10), g2 = CC(170, 56, 70), dust = CC(255, 190, 120), dir = -1, tw = 1 },
["Мята"] = { bg = CC(8, 24, 22), side = CC(10, 34, 30), card = CC(16, 54, 46), hover = CC(24, 78, 66), off = CC(38, 110, 92),
accent = CC(110, 255, 200), text = CC(230, 255, 248), sub = CC(130, 190, 176), g1 = CC(4, 16, 14), g2 = CC(20, 110, 90), dust = CC(190, 255, 235), dir = -1, tw = 1 },
["Кровавая"] = { bg = CC(16, 4, 6), side = CC(24, 6, 8), card = CC(42, 10, 14), hover = CC(64, 14, 20), off = CC(98, 22, 30),
accent = CC(255, 50, 70), text = CC(255, 226, 230), sub = CC(200, 120, 130), g1 = CC(8, 2, 3), g2 = CC(120, 10, 24), dust = CC(255, 80, 90), dir = -1, tw = 1.2 },
["Золото"] = { bg = CC(18, 14, 6), side = CC(26, 20, 8), card = CC(44, 34, 12), hover = CC(66, 50, 16), off = CC(100, 76, 22),
accent = CC(255, 205, 70), text = CC(255, 246, 222), sub = CC(206, 184, 130), g1 = CC(10, 8, 2), g2 = CC(120, 86, 10), dust = CC(255, 226, 140), dir = -1, tw = 1.2 },
}
local ThemeOrder = { "Чёрно-белая", "Лавандовая", "Космическая", "Хэллоуин", "Сакура", "Океан", "Неон", "Матрица", "Закат", "Мята", "Кровавая", "Золото" }
local function nearC(a, b)
return math.abs(a.R - b.R) < .004 and math.abs(a.G - b.G) < .004 and math.abs(a.B - b.B) < .004
end
function Theme.remap(old, new)
local fills = { "bg", "side", "card", "hover", "off", "accent" }
local function mapFill(c)
for _, r in ipairs(fills) do if nearC(c, old[r]) then return new[r] end end
end
local function mapText(c)
if nearC(c, old.text) then return new.text end
if nearC(c, old.sub) then return new.sub end
end
local function proc(d)
if d:GetAttribute("NoTheme") then return end
local par = d.Parent
if par and par:GetAttribute("NoTheme") then return end
if d:IsA("GuiObject") then
local n = mapFill(d.BackgroundColor3)
if n then d.BackgroundColor3 = n end
if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
local tc = mapText(d.TextColor3)
if tc then d.TextColor3 = tc end
if d:IsA("TextBox") then
local pc = mapText(d.PlaceholderColor3)
if pc then d.PlaceholderColor3 = pc end
end
end
if d:IsA("ScrollingFrame") then
local sc = mapFill(d.ScrollBarImageColor3)
if sc then d.ScrollBarImageColor3 = sc end
end
elseif d:IsA("UIStroke") then
local n = mapFill(d.Color)
if n then d.Color = n end
end
end
for _, root in ipairs({ Main, FlyPanel, FpsLabel, Fab, Target.hud }) do
proc(root)
for _, d in ipairs(root:GetDescendants()) do proc(d) end
end
end
function Theme.apply(name)
local th = Themes[name]
if not th then return end
local old = { bg = T.bg, side = T.side, card = T.card, hover = T.hover, off = T.off, accent = T.accent, text = T.text, sub = T.sub }
Theme.remap(old, th)
for k in pairs(old) do T[k] = th[k] end
S.theme = name
BGGrad.Color = ColorSequence.new({ CSK(0, th.g1), CSK(.5, th.g2), CSK(1, th.g1) })
Sweep.BackgroundColor3 = th.dust
for _, d in ipairs(Dust) do d.f.BackgroundColor3 = th.dust end
Theme.dir, Theme.tw = th.dir or -1, th.tw or 1
FabGrad.Color = ColorSequence.new({ CSK(0, th.accent), CSK(.5, th.off), CSK(1, th.accent) })
for nm, lbl in pairs(Theme.cards) do lbl.Text = (nm == name and "• " or "") .. nm end
end
conn(RunService.RenderStepped, function(dt)
Camera = workspace.CurrentCamera
FabGrad.Rotation = (os.clock() * 90) % 360
pcall(bgStep, dt)
pcall(fpsCounterStep, dt)
if not unlocked then return end
pcall(aimStep)
pcall(stretchStep)
pcall(espStep)
pcall(lightStep)
pcall(playerStep)
pcall(flyStep, dt)
pcall(Shaders.step)
pcall(hitboxStep)
pcall(Target.step, dt)
pcall(Xhair.step, dt)
if S.halo then pcall(Halo.update) end
if GlowHL then GlowHL.FillColor = Color3.fromHSV((os.clock() * .25) % 1, .7, 1); GlowHL.OutlineColor = GlowHL.FillColor end
end)
local AimPage     = Tab("Аим")
local EspPage     = Tab("ESP")
local XhairPage   = Tab("Прицел")
local StretchPage = Tab("Растяг")
local VisualsPage = Tab("Визуалы")
local ShadersPage = Tab("Шейдеры")
local PlayerPage  = Tab("Игрок")
local FpsPage     = Tab("FPS")
local ThemePage   = Tab("Темы")
local ConfigPage  = Tab("Конфиги")
local SetPage     = Tab("Настройки")
Section(AimPage, "Аимбот")
Toggle(AimPage, "Включить аим", "aim", function(v) Notify(v and "Аим включён" or "Аим выключен") end)
Toggle(AimPage, "Только при зажатом ПКМ (ПК)", "aimHold")
Selector(AimPage, "Цель", "aimPartSel", { "Голова", "Торс", "Центр" })
Section(AimPage, "Параметры")
Slider(AimPage, "Радиус FOV", "aimFov", 30, 400, 5, " px")
Slider(AimPage, "Плавность", "aimSmooth", 0, 95, 1, "%")
Slider(AimPage, "Упреждение", "aimPred", 0, 30, 1)
Section(AimPage, "Проверки")
Toggle(AimPage, "Не целиться в своих", "aimTeam")
Toggle(AimPage, "Проверка стен", "aimWall")
Toggle(AimPage, "Показывать круг FOV", "aimShowFov")
Section(AimPage, "Хитбокс головы")
Toggle(AimPage, "Увеличить хитбокс головы", "hitbox", function(v)
if not v then hitboxRestore() end
Notify(v and "Хитбокс головы включён" or "Хитбокс головы выключен")
end)
Slider(AimPage, "Размер головы", "hitboxSize", 1.5, 15, .5, "")
Slider(AimPage, "Прозрачность хитбокса", "hitboxTrans", 0, 100, 5, "%")
Toggle(AimPage, "Подсветка хитбокса головы", "hitboxHl")
Section(AimPage, "Хитбокс тела (квадрат)")
Toggle(AimPage, "Увеличить хитбокс тела", "bodyHitbox", function(v)
if not v then hitboxRestore() end
Notify(v and "Хитбокс тела включён" or "Хитбокс тела выключен")
end)
Slider(AimPage, "Размер тела", "bodySize", 2, 20, .5, "")
Slider(AimPage, "Прозрачность тела", "bodyTrans", 0, 100, 5, "%")
Toggle(AimPage, "Подсветка хитбокса тела", "bodyHl")
Toggle(AimPage, "Не трогать своих", "hitboxTeam")
Section(EspPage, "ESP")
Toggle(EspPage, "Включить ESP", "esp", function(v) Notify(v and "ESP включён" or "ESP выключен") end)
Selector(EspPage, "Вид рамки", "espStyle", { "Бокс", "Углы", "Ромб", "Круг", "Выкл" })
Selector(EspPage, "3D вид", "esp3d", { "Выкл", "3D бокс", "3D углы", "Октаэдр", "Шестигранник", "Цилиндр", "Сфера", "Скелет" })
Toggle(EspPage, "Имя и дистанция", "espName")
Selector(EspPage, "Вид здоровья", "espHpStyle", { "Полоска", "Хотбар", "Плашка", "Сердца", "Цифры", "Выкл" })
Toggle(EspPage, "Подсветка (чамсы)", "espChams")
Section(EspPage, "Линии")
Toggle(EspPage, "Линии (трейсеры)", "espTracer")
Selector(EspPage, "Откуда", "espTracerPos", { "Снизу", "Центр", "Сверху" })
Selector(EspPage, "Вид линии", "espTracerStyle", { "Линия", "Толстая", "Градиент" })
Section(EspPage, "Стрелки у центра экрана")
Toggle(EspPage, "Стрелки + расстояние", "espArrows")
Toggle(EspPage, "Показывать всегда", "espArrowAlways")
Slider(EspPage, "Радиус стрелок", "arrowRadius", 10, 45, 1, "%")
Section(EspPage, "Внешний вид")
Selector(EspPage, "Цвет", "espColor", ESPColorNames)
Toggle(EspPage, "Цвет по команде", "espTeamCol")
Slider(EspPage, "Макс. дистанция", "espDist", 100, 3000, 50, " m")
Section(VisualsPage, "Персонаж")
Toggle(VisualsPage, "Нимб", "halo", function(v) if v then pcall(Halo.build) else Halo.clear() end end)
Toggle(VisualsPage, "Шлейф", "trail", setTrail)
Section(VisualsPage, "Мир и камера")
Toggle(VisualsPage, "Фулбрайт", "fullbright", function() restoreLight() end)
Toggle(VisualsPage, "Без тумана", "nofog", function() restoreLight() end)
Toggle(VisualsPage, "Свой FOV камеры", "fov", function(v) if not v then Camera.FieldOfView = origFov end end)
Slider(VisualsPage, "FOV камеры", "fovVal", 50, 120, 1)
Section(ShadersPage, "Шейдеры")
Selector(ShadersPage, "Пресет", "shaderPreset", Shaders.names, Shaders.applyPreset)
Slider(ShadersPage, "Интенсивность", "shaderInt", 20, 100, 5, "%", function()
Shaders.token = Shaders.token + 1
local my = Shaders.token
task.delay(.2, function()
if my == Shaders.token and Shaders.active then Shaders.apply(Shaders.active) end
end)
end)
Button(ShadersPage, "Вернуть всё на место", function()
Shaders.reset()
if Selectors.shaderPreset then Selectors.shaderPreset("Выкл") end
Notify("Освещение возвращено")
end)
InfoCard(ShadersPage, "Реалистичный: мягкий свет, блум, дымка, глубина резкости.\nКибер-панк: ночь, неон, фиолетовый туман, пульсирующий оттенок.\nЗакат и Холодный — кинематографичные цветокоррекции. Кнопка выше возвращает освещение игры как было.", 88)
Section(VisualsPage, "Таргет-режим")
Toggle(VisualsPage, "Включить таргет", "tgt", function(v) Notify(v and "Таргет включён" or "Таргет выключен") end)
Selector(VisualsPage, "Вид эффекта", "tgtStyle", {
"Кольцо", "Двойное кольцо", "Спираль", "Призраки", "Орбиты", "Пульс", "Торнадо",
"Звёзды", "Нимб", "Квадрат", "Октаэдр", "Клетка", "Сфера", "Прицел",
})
Selector(VisualsPage, "Цвет эффекта", "tgtColor", { "Тема", "Красный", "Белый", "Голубой", "Розовый", "Зелёный", "Золотой", "Радуга" })
Toggle(VisualsPage, "Панель цели (HP, дистанция)", "tgtHud")
Section(VisualsPage, "Выбор цели")
Selector(VisualsPage, "Кого брать", "tgtSel", { "К прицелу", "По дистанции" })
Slider(VisualsPage, "Дальность", "tgtRange", 50, 1000, 10, " m")
Slider(VisualsPage, "Радиус от прицела", "tgtFov", 50, 600, 10, " px")
Toggle(VisualsPage, "Не выбирать своих", "tgtTeam")
Section(VisualsPage, "Настройка эффекта")
Slider(VisualsPage, "Размер", "tgtSize", 50, 200, 5, "%")
Slider(VisualsPage, "Скорость", "tgtSpeed", 50, 250, 5, "%")
InfoCard(VisualsPage, "Эффект крутится вокруг ближайшей к прицелу цели, а панель показывает её имя, здоровье и расстояние. Цель не прыгает между игроками, пока прежняя остаётся рядом с прицелом.", 76)
Xhair.page = XhairPage
Section(XhairPage, "Прицел по центру")
Toggle(XhairPage, "Включить прицел", "xh", function(v) Notify(v and "Прицел включён" or "Прицел выключен") end)
Selector(XhairPage, "Вид прицела", "xhStyle", Xhair.styles)
Selector(XhairPage, "Цвет", "xhColor", Xhair.colors)
Section(XhairPage, "Предпросмотр")
do
local card = Card(XhairPage, 116)
local pf = new("Frame", { Position = UDim2.fromOffset(6, 6), Size = UDim2.new(1, -12, 1, -12), BackgroundColor3 = T.bg, ClipsDescendants = true }, card)
corner(pf, 8)
Xhair.makePreview(pf)
end
Section(XhairPage, "Редактор")
Slider(XhairPage, "Размер", "xhSize", 2, 40, 1, " px")
Slider(XhairPage, "Толщина", "xhThick", 1, 8, 1, " px")
Slider(XhairPage, "Зазор в центре", "xhGap", 0, 30, 1, " px")
Slider(XhairPage, "Непрозрачность", "xhAlpha", 10, 100, 5, "%")
Slider(XhairPage, "Вращение", "xhSpin", 0, 360, 10, "°/с")
Slider(XhairPage, "Смещение по X", "xhOffX", -150, 150, 1, " px")
Slider(XhairPage, "Смещение по Y", "xhOffY", -150, 150, 1, " px")
Toggle(XhairPage, "Чёрная обводка", "xhOutline")
Toggle(XhairPage, "Точка в центре", "xhDot")
Toggle(XhairPage, "Расширяется при движении", "xhDyn")
Toggle(XhairPage, "Краснеет на игроке", "xhHit")
InfoCard(XhairPage, "Любые изменения видны сразу в предпросмотре. Настройки прицела сохраняются в конфигурациях.", 48)
Section(StretchPage, "Растяжка экрана")
Toggle(StretchPage, "Включить растяг", "stretch", function(v) Notify(v and "Растяг включён" or "Растяг выключен") end)
Selector(StretchPage, "Формат", "stretchMode", { "4:3", "5:4", "3:2", "16:10", "Своя" })
Section(StretchPage, "Свой растяг (формат «Своя»)")
Slider(StretchPage, "Сжатие по вертикали", "stretchVal", 30, 100, 1, "%")
Slider(StretchPage, "Сжатие по горизонтали", "stretchX", 30, 100, 1, "%")
InfoCard(StretchPage, "4:3 и 5:4 считаются автоматически под твой экран. Для своего растяга выбери формат «Своя» и двигай ползунки: чем меньше значение, тем шире выглядят игроки. Привычно 65–80% по вертикали.", 78)
Section(PlayerPage, "Скорость")
Toggle(PlayerPage, "Своя скорость", "speed")
Slider(PlayerPage, "Скорость бега", "speedVal", 16, 250, 1)
Section(PlayerPage, "Прыжок")
Toggle(PlayerPage, "Свой прыжок", "jump")
Slider(PlayerPage, "Сила прыжка", "jumpVal", 50, 300, 5)
Toggle(PlayerPage, "Бесконечный прыжок", "infJump")
Section(PlayerPage, "Полёт")
Toggle(PlayerPage, "Флай", "fly", function(v)
if v then flyStart() else flyStop() end
flyPanelShow(v)
Notify(v and "Флай включён" or "Флай выключен")
end)
Slider(PlayerPage, "Скорость полёта", "flySpeed", 10, 250, 5, "", function(v) SpeedLbl.Text = tostring(v) end)
InfoCard(PlayerPage, "Флай: средняя кнопка мыши (колесо) включает и выключает полёт. На телефоне — переключатель выше и мини-меню на экране (ВВЕРХ / ВНИЗ / скорость). На ПК: Space — вверх, Ctrl или Q — вниз.", 76)
Section(FpsPage, "FPS буст")
Selector(FpsPage, "Режим", "fpsMode", { "Выкл", "Простой", "Сильный", "Картошка" }, applyFps)
InfoCard(FpsPage, "Простой: без теней, эффектов и волн воды.\nСильный: + простые материалы, без частиц, лучей и источников света.\nКартошка: + без текстур и декалей, самое низкое качество и мыло.", 76)
Section(FpsPage, "Счётчик")
Toggle(FpsPage, "Показывать FPS", "showFps")
local Config = { selected = nil, autoName = nil }
do
Section(ThemePage, "Тема меню")
for _, name in ipairs(ThemeOrder) do
local th = Themes[name]
local f = Card(ThemePage, 40)
local lbl = cardLabel(f, (name == S.theme and "• " or "") .. name, -140)
local cols = { th.bg, th.card, th.off, th.accent, th.g2 }
for i, c in ipairs(cols) do
local sw = new("Frame", {
AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -12 - (#cols - i) * 20, .5, 0),
Size = UDim2.fromOffset(16, 16), BackgroundColor3 = c,
}, f)
sw:SetAttribute("NoTheme", true)
corner(sw, 8)
new("UIStroke", { Color = Color3.new(1, 1, 1), Transparency = .75, Thickness = 1 }, sw)
end
local btn = new("TextButton", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "" }, f)
btn.MouseButton1Click:Connect(function()
Theme.apply(name)
Notify("Тема: " .. name)
end)
Theme.cards[name] = lbl
end
Section(ThemePage, "Фон")
Toggle(ThemePage, "Анимированный фон", "bgAnim")
InfoCard(ThemePage, "Тема меняет цвета меню, иконки и фона. Космическая — мерцающие звёзды, Хэллоуин — оранжевые угли, Сакура — падающие лепестки, Океан — пузырьки.", 62)
local CONFIG_SKIP = { fly = true }
local function cleanName(n)
n = tostring(n or "")
n = n:gsub('[\\/:%*%?"<>|%.%c]', "")
n = n:gsub("^%s+", ""):gsub("%s+$", "")
return string.sub(n, 1, 40)
end
local autoRaw = FS.read("autoload.txt")
if autoRaw then
autoRaw = autoRaw:gsub("^%s+", ""):gsub("%s+$", "")
if autoRaw ~= "" then Config.autoName = autoRaw end
end
function Config.snapshot()
local d = {}
for k, v in pairs(S) do
if not CONFIG_SKIP[k] then d[k] = v end
end
return d
end
function Config.list()
local out = {}
for _, f in ipairs(FS.list("configs")) do
local n = string.match(f, "^(.+)%.json$")
if n then table.insert(out, n) end
end
return out
end
function Config.updateStatus()
if Config.statusLbl then
Config.statusLbl.Text = Config.autoName and ("★ Авто-загрузка: " .. Config.autoName) or "Авто-загрузка выключена"
end
end
function Config.apply(data)
for k, v in pairs(data) do
if not CONFIG_SKIP[k] and S[k] ~= nil and type(S[k]) == type(v) and S[k] ~= v then
if k == "theme" then Theme.apply(v)
elseif Toggles[k] then Toggles[k](v)
elseif Sliders[k] then Sliders[k](v)
elseif Selectors[k] then Selectors[k](v, true)
else S[k] = v end
end
end
end
function Config.load(name, silent)
local raw = FS.read("configs/" .. name .. ".json")
if not raw then Notify("Конфигурация не найдена") return end
local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
if not ok or type(data) ~= "table" then Notify("Файл конфигурации повреждён") return end
Config.apply(data)
if not silent then Notify("Загружена: " .. name) end
end
function Config.save(name)
name = cleanName(name)
if name == "" then Notify("Введи название конфигурации") return end
local disk = FS.write("configs/" .. name .. ".json", HttpService:JSONEncode(Config.snapshot()))
Config.selected = name
if Config.refresh then Config.refresh() end
Notify(disk and ("Сохранено: " .. name) or ("Сохранено в памяти (файлы недоступны): " .. name))
end
function Config.autoload()
if Config.autoName then
Config.load(Config.autoName, true)
Notify("Авто-загрузка: " .. Config.autoName)
end
end
Section(ConfigPage, "Новая конфигурация")
local cfgName = Input(ConfigPage, "Название конфигурации")
Button(ConfigPage, "Сохранить текущие настройки", function()
Config.save(cfgName.Text)
cfgName.Text = ""
end)
Section(ConfigPage, "Мои конфигурации")
local CfgList = new("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 }, ConfigPage)
new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, CfgList)
function Config.refresh()
for _, c in ipairs(CfgList:GetChildren()) do
if c:IsA("Frame") then c:Destroy() end
end
local names = Config.list()
if #names == 0 then
local f = Card(CfgList, 34)
cardLabel(f, "Пока нет сохранённых конфигураций", -24).TextColor3 = T.sub
return
end
for i, name in ipairs(names) do
local f = Card(CfgList, 36)
f.LayoutOrder = i
if Config.selected == name then
local st = f:FindFirstChildOfClass("UIStroke")
if st then st.Color = T.accent; st.Transparency = .15 end
end
cardLabel(f, (Config.autoName == name and "★ " or "") .. name, -20)
local hit = new("TextButton", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "" }, f)
hit.MouseButton1Click:Connect(function()
Config.selected = name
Config.refresh()
end)
end
end
Section(ConfigPage, "Выбранная конфигурация")
Button(ConfigPage, "Загрузить", function()
if Config.selected then Config.load(Config.selected) else Notify("Выбери конфигурацию в списке") end
end)
Button(ConfigPage, "Перезаписать текущими настройками", function()
if Config.selected then Config.save(Config.selected) else Notify("Выбери конфигурацию в списке") end
end)
Button(ConfigPage, "Удалить", function()
if not Config.selected then Notify("Выбери конфигурацию в списке") return end
FS.delete("configs/" .. Config.selected .. ".json")
if Config.autoName == Config.selected then
Config.autoName = nil
FS.delete("autoload.txt")
end
Notify("Удалено: " .. Config.selected)
Config.selected = nil
Config.refresh()
Config.updateStatus()
end)
Section(ConfigPage, "Авто-загрузка")
Config.statusLbl = InfoCard(ConfigPage, "", 34)
Button(ConfigPage, "★ Авто-загрузка выбранной", function()
if not Config.selected then Notify("Выбери конфигурацию в списке") return end
Config.autoName = Config.selected
FS.write("autoload.txt", Config.selected)
Config.refresh()
Config.updateStatus()
Notify("Будет загружаться при запуске: " .. Config.selected)
end)
Button(ConfigPage, "Отключить авто-загрузку", function()
Config.autoName = nil
FS.delete("autoload.txt")
Config.refresh()
Config.updateStatus()
Notify("Авто-загрузка выключена")
end)
InfoCard(ConfigPage, "Конфигурации лежат в папке CozyHub/configs твоего эксплойта. Если файлы недоступны, они хранятся в памяти до перезахода.", 62)
Config.refresh()
Config.updateStatus()
end -- do (Темы / Конфиги)
Section(SetPage, "Управление")
InfoCard(SetPage, "RightShift или тап по иконке — открыть/закрыть меню.\nДвойной тап по иконке — закрепить её на месте (повторный двойной тап — открепить и снова двигать).", 74)
local function Unload()
for _, c in ipairs(Conns) do pcall(function() c:Disconnect() end) end
S.fullbright, S.nofog, S.speed, S.jump, S.fly, S.hitbox = false, false, false, false, false, false
pcall(hitboxRestore)
pcall(playerStep)
flyStop()
pcall(Shaders.reset, true)
revertFps()
restoreLight()
Camera.FieldOfView = origFov
for plr in pairs(espObjs) do destroyESP(plr) end
Halo.clear(); setTrail(false); setGlow(false)
if Gui then Gui:Destroy() end
if getgenv then getgenv().CozyHubUnload = nil end
end
if getgenv then getgenv().CozyHubUnload = Unload end
Section(SetPage, "Скрипт")
Button(SetPage, "Выгрузить скрипт", function()
setMenu(false)
task.wait(.3)
Unload()
end)
local function confettiBurst()
local vp = Camera.ViewportSize
local cols = {
Color3.fromRGB(255, 80, 100), Color3.fromRGB(255, 200, 60), Color3.fromRGB(90, 220, 140),
Color3.fromRGB(90, 170, 255), Color3.fromRGB(200, 120, 255), Color3.fromRGB(255, 255, 255),
}
local layer = new("Frame", { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 60, Active = false }, Gui)
local ps = {}
for side = 0, 1 do
local ox = side == 0 and 0 or vp.X
for _ = 1, 45 do
local ang = math.rad(side == 0 and math.random(-80, -35) or math.random(-145, -100))
local sp = math.random(500, 1100)
local w, h = math.random(6, 11), math.random(4, 8)
local f = new("Frame", {
AnchorPoint = Vector2.new(.5, .5), Size = UDim2.fromOffset(w, h), BorderSizePixel = 0,
BackgroundColor3 = cols[math.random(#cols)], Rotation = math.random(0, 360), ZIndex = 61,
}, layer)
ps[#ps + 1] = {
f = f, x = ox, y = vp.Y + 10, vx = math.cos(ang) * sp, vy = math.sin(ang) * sp,
vr = math.random(-500, 500), sway = math.random() * 6, life = 2.6 + math.random() * 1.2,
}
end
end
local t0 = os.clock()
local conn
conn = RunService.RenderStepped:Connect(function(dt)
local el = os.clock() - t0
for _, p in ipairs(ps) do
p.vy = p.vy + 900 * dt
p.vx = p.vx * (1 - math.min(dt * 1.2, 1))
p.vy = p.vy * (1 - math.min(dt * .6, 1))
p.x = p.x + (p.vx + math.sin(el * 4 + p.sway) * 40) * dt
p.y = p.y + p.vy * dt
p.f.Position = UDim2.fromOffset(p.x, p.y)
p.f.Rotation = p.f.Rotation + p.vr * dt
p.f.BackgroundTransparency = math.clamp((el - (p.life - .8)) / .8, 0, 1)
end
if el > 4 then
conn:Disconnect()
layer:Destroy()
end
end)
table.insert(Conns, conn)
end
local function runKeyScreen(onSuccess)
local blocker = new("Frame", {
Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1,
Active = true, ZIndex = 50,
}, Gui)
new("TextButton", { BackgroundTransparency = 1, Size = UDim2.fromOffset(0, 0), Text = "", Modal = true }, blocker)
tw(blocker, .5, { BackgroundTransparency = .12 })
local bgFlakes, bgOrbs = {}, {}
local vp0 = Camera.ViewportSize
for i = 1, 3 do
local sz = math.random(260, 420)
local o = new("Frame", {
AnchorPoint = Vector2.new(.5, .5), Size = UDim2.fromOffset(sz, sz), BackgroundColor3 = Color3.new(1, 1, 1),
BackgroundTransparency = .94, BorderSizePixel = 0, ZIndex = 50,
}, blocker)
corner(o, 999)
bgOrbs[i] = { f = o, ph = math.random() * 6, sx = .15 + i * .3, sy = .3 + (i % 2) * .4 }
end
for i = 1, 70 do
local sz = math.random(2, 7)
local f = new("Frame", {
Size = UDim2.fromOffset(sz, sz), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
BackgroundTransparency = .1 + (7 - sz) * .08, ZIndex = 50,
}, blocker)
corner(f, 999)
bgFlakes[i] = {
f = f, x = math.random() * vp0.X, y = math.random() * vp0.Y, sp = 25 + sz * 9 + math.random() * 20,
sw = math.random() * 6, amp = 12 + math.random() * 22,
}
end
local snowConn = RunService.RenderStepped:Connect(function(dt)
local vp = Camera.ViewportSize
local t = os.clock()
for _, p in ipairs(bgFlakes) do
p.y = p.y + p.sp * dt
if p.y > vp.Y + 10 then p.y = -10; p.x = math.random() * vp.X end
p.f.Position = UDim2.fromOffset(p.x + math.sin(t * .9 + p.sw) * p.amp, p.y)
end
for _, o in ipairs(bgOrbs) do
o.f.Position = UDim2.fromOffset(
vp.X * o.sx + math.sin(t * .25 + o.ph) * 80, vp.Y * o.sy + math.cos(t * .2 + o.ph) * 60)
o.f.BackgroundTransparency = .93 + math.sin(t * .6 + o.ph) * .03
end
end)
table.insert(Conns, snowConn)
local card = new("CanvasGroup", {
AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5), Size = UDim2.fromOffset(340, 216),
BackgroundColor3 = Color3.fromRGB(8, 8, 10), GroupTransparency = 1, ZIndex = 51,
}, blocker)
corner(card, 16)
local cs = new("UIStroke", { Color = Color3.new(1, 1, 1), Thickness = 1.6 }, card)
local cg = new("UIGradient", {
Color = ColorSequence.new({ CSK(0, Color3.new(1, 1, 1)), CSK(.5, Color3.fromRGB(50, 50, 56)), CSK(1, Color3.new(1, 1, 1)) }),
}, cs)
local cscale = new("UIScale", { Scale = .8 }, card)
tw(cscale, .5, { Scale = 1 }, Enum.EasingStyle.Back)
tw(card, .4, { GroupTransparency = 0 })
local spin = RunService.RenderStepped:Connect(function() cg.Rotation = (os.clock() * 90) % 360 end)
table.insert(Conns, spin)
new("TextLabel", {
BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 14), Size = UDim2.new(1, 0, 0, 30),
Text = "Cozy Hub", Font = Enum.Font.GothamBlack, TextSize = 24, TextColor3 = WHITE,
}, card)
new("TextLabel", {
BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 46), Size = UDim2.new(1, 0, 0, 18),
Text = "Введи ключ, чтобы войти", Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = T.sub,
}, card)
local box = new("TextBox", {
Position = UDim2.fromOffset(24, 78), Size = UDim2.new(1, -48, 0, 40), BackgroundColor3 = Color3.fromRGB(22, 22, 26),
Text = "", PlaceholderText = "Ключ", PlaceholderColor3 = T.sub, TextColor3 = WHITE, Font = Enum.Font.GothamBold,
TextSize = 18, ClearTextOnFocus = true,
}, card)
corner(box, 10)
local bs = new("UIStroke", { Color = Color3.new(1, 1, 1), Transparency = .8, Thickness = 1 }, box)
box.Focused:Connect(function() tw(bs, .2, { Transparency = .2 }) end)
box.FocusLost:Connect(function() tw(bs, .2, { Transparency = .8 }) end)
local btn = new("TextButton", {
Position = UDim2.fromOffset(24, 130), Size = UDim2.new(1, -48, 0, 40), BackgroundColor3 = WHITE,
Text = "Войти", Font = Enum.Font.GothamBold, TextSize = 15, TextColor3 = Color3.new(0, 0, 0),
}, card)
corner(btn, 10)
btn.MouseEnter:Connect(function() tw(btn, .15, { BackgroundColor3 = Color3.fromRGB(200, 200, 205) }) end)
btn.MouseLeave:Connect(function() tw(btn, .15, { BackgroundColor3 = WHITE }) end)
local status = new("TextLabel", {
BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 180), Size = UDim2.new(1, 0, 0, 22),
Text = "", Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = WHITE,
}, card)
local busy = false
local function submit()
if busy then return end
busy = true
local txt = (box.Text or ""):gsub("%s+", "")
if txt == KEY then
status.Text = "Доступ разрешён"
pcall(confettiBurst)
task.wait(.4)
tw(cscale, .3, { Scale = 1.1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
tw(card, .3, { GroupTransparency = 1 })
tw(blocker, .4, { BackgroundTransparency = 1 })
task.wait(.45)
spin:Disconnect()
snowConn:Disconnect()
blocker:Destroy()
onSuccess()
else
status.Text = "Неверный ключ. Выход..."
status.TextColor3 = Color3.fromRGB(255, 90, 100)
for n = 1, 8 do
tw(card, .05, { Position = UDim2.new(.5, (n % 2 == 0) and 12 or -12, .5, 0) })
task.wait(.05)
end
tw(card, .1, { Position = UDim2.fromScale(.5, .5) })
task.wait(1)
local ok = pcall(function() LP:Kick("Неверный ключ") end)
if not ok then pcall(function() game:Shutdown() end) end
end
end
btn.MouseButton1Click:Connect(submit)
box.FocusLost:Connect(function(enter) if enter then submit() end end)
end
local function runWelcome(done)
local bl = new("Frame", {
Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = .12,
Active = true, ZIndex = 50,
}, Gui)
local sc = new("UIScale", { Scale = .85 }, bl)
local top = new("TextLabel", {
AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .45), Size = UDim2.fromOffset(400, 28),
BackgroundTransparency = 1, Text = "Добро пожаловать в", Font = Enum.Font.GothamMedium, TextSize = 20,
TextColor3 = WHITE, TextTransparency = 1, ZIndex = 51,
}, bl)
local big = new("TextLabel", {
AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .53), Size = UDim2.fromOffset(400, 60),
BackgroundTransparency = 1, Text = "Cozy Hub", Font = Enum.Font.GothamBlack, TextSize = 46,
TextColor3 = WHITE, TextTransparency = 1, ZIndex = 51,
}, bl)
local line = new("Frame", {
AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .6), Size = UDim2.fromOffset(0, 2),
BackgroundColor3 = WHITE, BorderSizePixel = 0, ZIndex = 51,
}, bl)
corner(line, 2)
tw(sc, .7, { Scale = 1 }, Enum.EasingStyle.Back)
tw(top, .5, { TextTransparency = 0 })
task.wait(.25)
tw(big, .6, { TextTransparency = 0 })
tw(line, .8, { Size = UDim2.fromOffset(220, 2) })
task.wait(1.7)
tw(top, .4, { TextTransparency = 1 })
tw(big, .4, { TextTransparency = 1 })
tw(line, .4, { Size = UDim2.fromOffset(0, 2) })
tw(bl, .5, { BackgroundTransparency = 1 })
task.wait(.55)
bl:Destroy()
done()
end
selectTab(1, true)
runKeyScreen(function()
runWelcome(function()
unlocked = true
Fab.Visible = true
Fab.Size = UDim2.fromOffset(0, 0)
tw(Fab, .5, { Size = UDim2.fromOffset(FAB, FAB) }, Enum.EasingStyle.Back)
setMenu(true)
task.delay(.9, function() pcall(Config.autoload) end)
end)
end)
