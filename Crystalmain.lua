-- ╔══════════════════════════════════════════════════════════════════╗
-- ║              Crystal UI Library  —  v1.0                        ║
-- ║  Light Blue × Dark Purple  |  Tabs · Checkboxes · Multiboxes   ║
-- ║  Animations · Descriptions · Loading Screen                     ║
-- ╚══════════════════════════════════════════════════════════════════╝
--
-- USAGE:
--   local UI = loadstring(...)()       -- or paste directly
--   local window = UI:CreateWindow({ Title = "My Script", Subtitle = "v1.0" })
--   local tab    = window:Tab("Combat")
--   tab:Checkbox({ Label="Silent Aim", Desc="Snaps bullets to target", Default=false, Callback=function(v) end })
--   tab:Multibox({ Label="Weapons", Desc="Select active weapons", Options={"Gun","Knife","Bow"}, Callback=function(t) end })
--   tab:Slider({ Label="Speed", Desc="Walk speed value", Min=0, Max=100, Default=16, Callback=function(v) end })
--   tab:Dropdown({ Label="Team", Desc="Choose your team", Options={"Red","Blue","Green"}, Callback=function(v) end })
--   tab:Button({ Label="Teleport", Desc="TP to waypoint", Callback=function() end })
--   tab:Toggle({ Label="ESP", Desc="Show player outlines", Default=false, Callback=function(v) end })
--   tab:Keybind({ Label="Panic Key", Desc="Hide the GUI", Default=Enum.KeyCode.RightShift, Callback=function(k) end })
--   tab:Textbox({ Label="Player Name", Desc="Target username", Callback=function(s) end })

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local player = Players.LocalPlayer
repeat task.wait() until player:FindFirstChild("PlayerGui")

-- ── destroy old instance ──────────────────────────────────────────────────
local oldGui = player.PlayerGui:FindFirstChild("CrystalUI")
if oldGui then oldGui:Destroy() end

-- ═══════════════════════════════════════════════════════════════════════════
-- PALETTE
-- ═══════════════════════════════════════════════════════════════════════════
local P = {
    -- Backgrounds
    bg      = Color3.fromRGB(10,  10,  20 ),   -- deepest panel
    bgCard  = Color3.fromRGB(15,  15,  32 ),   -- card surface
    bgElem  = Color3.fromRGB(20,  20,  44 ),   -- element bg
    bgHover = Color3.fromRGB(28,  28,  58 ),   -- hover state

    -- Purples
    purpDark = Color3.fromRGB(46,  20,  90 ),
    purpMid  = Color3.fromRGB(78,  38, 148 ),
    purpBrt  = Color3.fromRGB(110, 60, 200 ),

    -- Blues
    blueDeep = Color3.fromRGB(10,  80, 160 ),
    blueMid  = Color3.fromRGB(30, 140, 220 ),
    blueBrt  = Color3.fromRGB(80, 185, 255 ),
    blueGlow = Color3.fromRGB(140,210, 255 ),

    -- Text
    txtPrim  = Color3.fromRGB(225, 235, 255 ),
    txtSub   = Color3.fromRGB(140, 155, 195 ),
    txtDim   = Color3.fromRGB(80,  90, 130 ),

    -- Accents
    green    = Color3.fromRGB(60, 220, 140 ),
    greenDim = Color3.fromRGB(20,  70,  45 ),
    stroke   = Color3.fromRGB(55,  40, 110 ),
    strokeBrt= Color3.fromRGB(90,  70, 170 ),
    white    = Color3.fromRGB(255, 255, 255),
}

-- ═══════════════════════════════════════════════════════════════════════════
-- HELPERS
-- ═══════════════════════════════════════════════════════════════════════════
local function tw(obj, goal, t, style, dir)
    style = style or Enum.EasingStyle.Quad
    dir   = dir   or Enum.EasingDirection.Out
    local ti = TweenInfo.new(t, style, dir)
    local t2 = TweenService:Create(obj, ti, goal)
    t2:Play()
    return t2
end

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color = color or P.stroke
    s.Thickness = thick or 1
    s.Transparency = trans or 0
    s.Parent = parent
    return s
end

local function grad(parent, colorSeq, rot)
    local g = Instance.new("UIGradient")
    g.Color = colorSeq
    g.Rotation = rot or 0
    g.Parent = parent
    return g
end

local function label(parent, txt, size, color, font, xa)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextSize = size or 14
    l.TextColor3 = color or P.txtPrim
    l.Font = font or Enum.Font.GothamMedium
    l.TextXAlignment = xa or Enum.TextXAlignment.Left
    l.TextWrapped = true
    l.Parent = parent
    return l
end

local function frame(parent, size, pos, color, trans)
    local f = Instance.new("Frame")
    f.Size = size
    f.Position = pos or UDim2.new(0,0,0,0)
    f.BackgroundColor3 = color or P.bgCard
    f.BackgroundTransparency = trans or 0
    f.BorderSizePixel = 0
    f.Parent = parent
    return f
end

local function btn(parent, size, pos, color)
    local b = Instance.new("TextButton")
    b.Size = size
    b.Position = pos or UDim2.new(0,0,0,0)
    b.BackgroundColor3 = color or P.bgElem
    b.BorderSizePixel = 0
    b.Text = ""
    b.AutoButtonColor = false
    b.Parent = parent
    return b
end

local gradSeq = function(...)
    local kps = {}
    local args = {...}
    for i=1,#args,2 do
        table.insert(kps, ColorSequenceKeypoint.new(args[i], args[i+1]))
    end
    return ColorSequence.new(kps)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- NOTIFICATION
-- ═══════════════════════════════════════════════════════════════════════════
local notifGui = Instance.new("ScreenGui")
notifGui.Name = "CrystalNotifs"
notifGui.ResetOnSpawn = false
notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
notifGui.IgnoreGuiInset = true
notifGui.Parent = player.PlayerGui

local notifHolder = frame(notifGui, UDim2.new(0,320,1,-20), UDim2.new(1,-340,0,10), Color3.new(), 1)
local notifLayout = Instance.new("UIListLayout")
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifLayout.Padding = UDim.new(0,6)
notifLayout.Parent = notifHolder

local notifQueue = {}
local notifBusy  = false

local function notify(title, desc, duration)
    duration = duration or 3
    table.insert(notifQueue, {title=title, desc=desc, duration=duration})
    if notifBusy then return end
    notifBusy = true
    task.spawn(function()
        while #notifQueue > 0 do
            local n = table.remove(notifQueue, 1)
            local h = 52 + (n.desc and 18 or 0)

            local card = frame(notifHolder, UDim2.new(1,0,0,0), UDim2.new(0,0,0,0), P.bgCard)
            card.ClipsDescendants = true
            corner(card, 12)
            stroke(card, P.strokeBrt, 1, 0.3)
            grad(card, gradSeq(0,P.purpDark, 1,P.bgCard), 135)

            local accent = frame(card, UDim2.new(0,3,1,-8), UDim2.new(0,0,0,4), P.blueMid)
            corner(accent, 2)
            grad(accent, gradSeq(0,P.blueBrt,1,P.purpBrt), 90)

            local tl = label(card, n.title, 13, P.txtPrim, Enum.Font.GothamBold)
            tl.Size = UDim2.new(1,-16,0,18)
            tl.Position = UDim2.new(0,12,0,8)

            if n.desc then
                local dl = label(card, n.desc, 11, P.txtSub, Enum.Font.Gotham)
                dl.Size = UDim2.new(1,-16,0,16)
                dl.Position = UDim2.new(0,12,0,28)
            end

            tw(card, {Size=UDim2.new(1,0,0,h)}, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            task.wait(n.duration)
            tw(card, {Size=UDim2.new(1,0,0,0), BackgroundTransparency=1}, 0.2)
            task.wait(0.25)
            card:Destroy()
            task.wait(0.05)
        end
        notifBusy = false
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════
-- LIBRARY
-- ═══════════════════════════════════════════════════════════════════════════
local CrystalUI = {}
CrystalUI.__index = CrystalUI

function CrystalUI:Notify(title, desc, duration)
    notify(title, desc, duration)
end

-- ───────────────────────────────────────────────────────────────────────────
-- CREATE WINDOW
-- ───────────────────────────────────────────────────────────────────────────
function CrystalUI:CreateWindow(opts)
    opts = opts or {}
    local WIN_W = opts.Width  or 620
    local WIN_H = opts.Height or 540

    -- ── ScreenGui ──────────────────────────────────────────────────────────
    local sg = Instance.new("ScreenGui")
    sg.Name = "CrystalUI"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.IgnoreGuiInset = true
    sg.Parent = player.PlayerGui

    -- ── Main window frame ──────────────────────────────────────────────────
    local main = frame(sg, UDim2.new(0,WIN_W,0,WIN_H),
        UDim2.new(0.5,-WIN_W/2, 0.5,-WIN_H/2), P.bg)
    main.ClipsDescendants = true
    main.Visible = false
    corner(main, 18)
    stroke(main, P.stroke, 1, 0.2)

    -- Gradient background
    grad(main, gradSeq(
        0,   Color3.fromRGB(14,10,34),
        0.45,Color3.fromRGB(10,10,22),
        1,   Color3.fromRGB(10,20,38)
    ), 145)

    -- Top glow bar
    local glowBar = frame(main, UDim2.new(1,0,0,2), UDim2.new(0,0,0,0), P.blueMid)
    glowBar.ZIndex = 5
    grad(glowBar, gradSeq(
        0,   Color3.fromRGB(0,0,0),
        0.25,P.purpBrt,
        0.5, P.blueBrt,
        0.75,P.purpBrt,
        1,   Color3.fromRGB(0,0,0)
    ), 0)

    -- ── Loading screen ─────────────────────────────────────────────────────
    local loadScreen = frame(sg,
        UDim2.new(0,WIN_W,0,WIN_H),
        UDim2.new(0.5,-WIN_W/2, 0.5,-WIN_H/2),
        Color3.fromRGB(8,8,18))
    loadScreen.ZIndex = 50
    corner(loadScreen, 18)
    stroke(loadScreen, P.stroke, 1, 0.1)
    grad(loadScreen, gradSeq(
        0, Color3.fromRGB(18,8,40),
        1, Color3.fromRGB(8,15,35)
    ), 135)

    -- Crystal logo mark
    local logoFrame = frame(loadScreen,
        UDim2.new(0,72,0,72),
        UDim2.new(0.5,-36,0.5,-80),
        P.purpDark)
    corner(logoFrame, 20)
    grad(logoFrame, gradSeq(0,P.purpBrt,1,P.blueDeep), 135)
    stroke(logoFrame, P.blueBrt, 1, 0.3)

    local logoText = label(logoFrame, "C", 36, P.white, Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
    logoText.Size = UDim2.new(1,0,1,0)
    logoText.TextYAlignment = Enum.TextYAlignment.Center

    local loadTitle = label(loadScreen, opts.Title or "Crystal UI", 22, P.txtPrim, Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
    loadTitle.Size = UDim2.new(1,0,0,28)
    loadTitle.Position = UDim2.new(0,0,0.5,8)
    grad(Instance.new("UIGradient"), gradSeq(0,P.blueBrt,0.5,P.blueGlow,1,P.purpBrt), 0).Parent = loadTitle

    local loadSub = label(loadScreen, opts.Subtitle or "Loading...", 13, P.txtSub, Enum.Font.Gotham, Enum.TextXAlignment.Center)
    loadSub.Size = UDim2.new(1,0,0,18)
    loadSub.Position = UDim2.new(0,0,0.5,42)

    -- Progress bar
    local barBg = frame(loadScreen, UDim2.new(0,260,0,4), UDim2.new(0.5,-130,0.5,75), P.bgElem)
    corner(barBg, 2)
    local barFill = frame(barBg, UDim2.new(0,0,1,0), UDim2.new(0,0,0,0), P.blueMid)
    corner(barFill, 2)
    grad(barFill, gradSeq(0,P.purpBrt,1,P.blueBrt), 0)

    local loadPct = label(loadScreen, "0%", 11, P.txtDim, Enum.Font.GothamMedium, Enum.TextXAlignment.Center)
    loadPct.Size = UDim2.new(1,0,0,14)
    loadPct.Position = UDim2.new(0,0,0.5,86)

    -- Animate loading
    task.spawn(function()
        local steps = {"Initializing...", "Building UI...", "Loading modules...", "Almost ready..."}
        for i,s in ipairs(steps) do
            loadSub.Text = s
            local pct = i / #steps
            tw(barFill, {Size=UDim2.new(pct,0,1,0)}, 0.35)
            loadPct.Text = math.floor(pct*100).."%"
            task.wait(0.28)
        end
        loadPct.Text = "100%"
        tw(barFill, {Size=UDim2.new(1,0,1,0)}, 0.2)
        task.wait(0.35)
        -- Fade out load screen, reveal main
        main.Visible = true
        main.BackgroundTransparency = 1
        main.Size = UDim2.new(0, WIN_W*0.92, 0, WIN_H*0.92)
        main.Position = UDim2.new(0.5, -(WIN_W*0.92)/2, 0.5, -(WIN_H*0.92)/2)
        tw(loadScreen, {BackgroundTransparency=1}, 0.3)
        tw(logoFrame,  {BackgroundTransparency=1}, 0.3)
        tw(barBg,      {BackgroundTransparency=1}, 0.3)
        tw(main, {
            BackgroundTransparency = 0,
            Size     = UDim2.new(0,WIN_W,0,WIN_H),
            Position = UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2)
        }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        task.wait(0.38)
        loadScreen:Destroy()
    end)

    -- ── Header ─────────────────────────────────────────────────────────────
    local header = frame(main, UDim2.new(1,0,0,56), UDim2.new(0,0,0,2), Color3.new(), 1)

    -- Gradient title text using a frame + labels
    local titleLbl = label(header, opts.Title or "Crystal UI", 20, P.white, Enum.Font.GothamBlack)
    titleLbl.Size = UDim2.new(0,300,0,26)
    titleLbl.Position = UDim2.new(0,18,0,12)
    -- Simulate gradient by overlaying a semi-transparent gradient frame
    local titleGradFrame = frame(header, UDim2.new(0,300,0,26), UDim2.new(0,18,0,12), Color3.new(), 1)
    titleGradFrame.ZIndex = 3
    local tg = Instance.new("UIGradient")
    tg.Color = gradSeq(0,P.blueGlow,0.4,P.blueBrt,1,P.purpBrt)
    tg.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0,0),
        NumberSequenceKeypoint.new(1,0.2),
    }
    tg.Parent = titleGradFrame

    local subLbl = label(header, opts.Subtitle or "", 12, P.txtSub, Enum.Font.Gotham)
    subLbl.Size = UDim2.new(0,300,0,16)
    subLbl.Position = UDim2.new(0,19,0,38)

    -- Close & minimize buttons
    local closeBtn = btn(header, UDim2.new(0,28,0,28), UDim2.new(1,-42,0,14), Color3.fromRGB(180,50,60))
    corner(closeBtn, 8)
    local closeX = label(closeBtn, "×", 18, P.white, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    closeX.Size = UDim2.new(1,0,1,0)
    closeX.TextYAlignment = Enum.TextYAlignment.Center
    closeBtn.MouseButton1Click:Connect(function()
        tw(main, {Size=UDim2.new(0,WIN_W*0.88,0,WIN_H*0.88), BackgroundTransparency=1}, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.25)
        sg:Destroy()
    end)

    local minBtn = btn(header, UDim2.new(0,28,0,28), UDim2.new(1,-76,0,14), Color3.fromRGB(200,155,20))
    corner(minBtn, 8)
    local minL = label(minBtn, "–", 18, P.white, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    minL.Size = UDim2.new(1,0,1,0)
    minL.TextYAlignment = Enum.TextYAlignment.Center

    local minimized = false
    local fullH = WIN_H
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            tw(main, {Size=UDim2.new(0,WIN_W,0,56)}, 0.28, Enum.EasingStyle.Quart)
        else
            tw(main, {Size=UDim2.new(0,WIN_W,0,fullH)}, 0.28, Enum.EasingStyle.Back)
        end
    end)

    -- Header divider
    local hdiv = frame(main, UDim2.new(1,-36,0,1), UDim2.new(0,18,0,57), P.stroke)
    grad(hdiv, gradSeq(0,Color3.new(),0.3,P.strokeBrt,0.7,P.strokeBrt,1,Color3.new()), 0)

    -- ── Dragging ──────────────────────────────────────────────────────────
    local dragging, ds, dp = false, nil, nil
    header.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            ds = inp.Position
            dp = main.Position
        end
    end)
    header.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - ds
            local nx = dp.X.Offset + d.X
            local ny = dp.Y.Offset + d.Y
            main.Position = UDim2.new(dp.X.Scale, nx, dp.Y.Scale, ny)
        end
    end)

    -- ── Tab bar ────────────────────────────────────────────────────────────
    local TAB_BAR_W = 140
    local tabBar = frame(main,
        UDim2.new(0,TAB_BAR_W,1,-60),
        UDim2.new(0,0,0,60),
        Color3.fromRGB(8,8,20))
    tabBar.ZIndex = 2
    grad(tabBar, gradSeq(0,Color3.fromRGB(14,8,32),1,Color3.fromRGB(8,10,24)), 180)
    stroke(tabBar, P.stroke, 1, 0.5) -- right border via UIStroke hack
    local tabStrokeLine = frame(tabBar, UDim2.new(0,1,1,0), UDim2.new(1,-1,0,0), P.strokeBrt)

    local tabList = Instance.new("UIListLayout")
    tabList.SortOrder = Enum.SortOrder.LayoutOrder
    tabList.Padding = UDim.new(0,2)
    tabList.Parent = tabBar
    local tabPad = Instance.new("UIPadding")
    tabPad.PaddingTop = UDim.new(0,8)
    tabPad.PaddingLeft = UDim.new(0,6)
    tabPad.PaddingRight = UDim.new(0,6)
    tabPad.Parent = tabBar

    -- Content area
    local contentArea = frame(main,
        UDim2.new(1,-TAB_BAR_W,1,-62),
        UDim2.new(0,TAB_BAR_W,0,60),
        Color3.new(), 1)

    -- ── Active tab indicator bar (animates) ───────────────────────────────
    local tabIndicator = frame(tabBar, UDim2.new(0,3,0,34), UDim2.new(1,-3,0,8), P.blueBrt)
    corner(tabIndicator, 2)
    grad(tabIndicator, gradSeq(0,P.blueGlow,1,P.purpBrt), 90)
    tabIndicator.ZIndex = 4

    -- ── Window object ──────────────────────────────────────────────────────
    local Window = {}
    Window._tabs    = {}
    Window._tabBtns = {}
    Window._active  = nil
    Window._sg      = sg
    Window._main    = main

    function Window:Notify(t,d,dur) notify(t,d,dur) end

    -- ── Tab creation ───────────────────────────────────────────────────────
    function Window:Tab(name)
        local idx = #self._tabs + 1

        -- Tab button
        local tabBtn2 = btn(tabBar,
            UDim2.new(1,0,0,36),
            UDim2.new(0,0,0,0),
            Color3.new())
        tabBtn2.BackgroundTransparency = 1
        tabBtn2.ZIndex = 3
        tabBtn2.LayoutOrder = idx
        corner(tabBtn2, 8)

        local tabBg = frame(tabBtn2, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), P.bgHover)
        tabBg.BackgroundTransparency = 1
        corner(tabBg, 8)

        local tabTxt = label(tabBtn2, name, 13, P.txtSub, Enum.Font.GothamMedium)
        tabTxt.Size = UDim2.new(1,-10,1,0)
        tabTxt.Position = UDim2.new(0,10,0,0)
        tabTxt.TextYAlignment = Enum.TextYAlignment.Center
        tabTxt.ZIndex = 4

        -- Content scroll frame for this tab
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1,0,1,0)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 3
        scroll.ScrollBarImageColor3 = P.purpBrt
        scroll.CanvasSize = UDim2.new(0,0,0,0)
        scroll.Visible = false
        scroll.ClipsDescendants = true
        scroll.Parent = contentArea

        local itemList = Instance.new("UIListLayout")
        itemList.SortOrder = Enum.SortOrder.LayoutOrder
        itemList.Padding = UDim.new(0,8)
        itemList.Parent = scroll
        local itemPad = Instance.new("UIPadding")
        itemPad.PaddingTop    = UDim.new(0,12)
        itemPad.PaddingLeft   = UDim.new(0,14)
        itemPad.PaddingRight  = UDim.new(0,14)
        itemPad.PaddingBottom = UDim.new(0,14)
        itemPad.Parent = scroll

        -- Auto canvas size
        itemList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll.CanvasSize = UDim2.new(0,0,0,itemList.AbsoluteContentSize.Y+28)
        end)

        local Tab = { _scroll=scroll, _order=0 }
        table.insert(self._tabs, Tab)
        table.insert(self._tabBtns, {btn=tabBtn2, bg=tabBg, txt=tabTxt})

        local function activate()
            -- Deactivate all
            for i,tb in ipairs(self._tabBtns) do
                local isActive = (tb.btn == tabBtn2)
                tw(tb.bg,  {BackgroundTransparency = isActive and 0.6 or 1}, 0.2)
                tw(tb.txt, {TextColor3 = isActive and P.blueBrt or P.txtSub}, 0.2)
                self._tabs[i]._scroll.Visible = isActive
                if isActive then
                    -- Fade in
                    self._tabs[i]._scroll.GroupTransparency = 1
                    tw(self._tabs[i]._scroll, {GroupTransparency=0}, 0.22)
                end
            end
            -- Move indicator
            local absY = tabBtn2.AbsolutePosition.Y - tabBar.AbsolutePosition.Y
            tw(tabIndicator, {Position=UDim2.new(1,-3,0,absY+1)}, 0.22, Enum.EasingStyle.Quart)
            self._active = Tab
        end

        tabBtn2.MouseButton1Click:Connect(activate)
        tabBtn2.MouseEnter:Connect(function()
            if self._active ~= Tab then
                tw(tabBg, {BackgroundTransparency=0.85}, 0.15)
            end
        end)
        tabBtn2.MouseLeave:Connect(function()
            if self._active ~= Tab then
                tw(tabBg, {BackgroundTransparency=1}, 0.15)
            end
        end)

        -- Activate first tab automatically
        if idx == 1 then
            task.defer(activate)
        end

        -- ── ITEM CARD BASE ─────────────────────────────────────────────────
        local function makeCard(h)
            Tab._order = Tab._order + 1
            local card = frame(scroll, UDim2.new(1,0,0,h), UDim2.new(0,0,0,0), P.bgCard)
            card.LayoutOrder = Tab._order
            corner(card, 12)
            stroke(card, P.stroke, 1, 0.4)
            grad(card, gradSeq(0,Color3.fromRGB(22,18,48),1,Color3.fromRGB(14,14,32)), 135)
            -- Glass sheen
            local sheen = frame(card, UDim2.new(1,0,0,1), UDim2.new(0,0,0,0), P.white)
            sheen.BackgroundTransparency = 0.85
            corner(sheen, 12)
            return card
        end

        -- ── LABEL + DESC helper ────────────────────────────────────────────
        local function addLabelDesc(card, ltext, dtext)
            local main2 = label(card, ltext, 13, P.txtPrim, Enum.Font.GothamSemibold)
            main2.Size = UDim2.new(1,-16,0,18)
            main2.Position = UDim2.new(0,12,0,10)
            if dtext and dtext ~= "" then
                local desc = label(card, dtext, 11, P.txtDim, Enum.Font.Gotham)
                desc.Size = UDim2.new(1,-16,0,14)
                desc.Position = UDim2.new(0,12,0,28)
            end
        end

        -- ══════════════════════════════════════════════════════════════════
        -- CHECKBOX
        -- ══════════════════════════════════════════════════════════════════
        function Tab:Checkbox(opts2)
            opts2 = opts2 or {}
            local h = (opts2.Desc and opts2.Desc~="") and 62 or 46
            local card = makeCard(h)

            addLabelDesc(card, opts2.Label or "Checkbox", opts2.Desc)

            local val = opts2.Default == true

            -- Track
            local track = frame(card, UDim2.new(0,44,0,24), UDim2.new(1,-56,0.5,-12), val and P.blueDeep or P.bgElem)
            corner(track, 12)
            stroke(track, val and P.blueMid or P.stroke, 1, val and 0.4 or 0.3)

            grad(track, val and
                gradSeq(0,P.blueBrt,1,P.purpBrt) or
                gradSeq(0,P.bgElem,1,P.bgElem), 0)

            local knob = frame(track, UDim2.new(0,18,0,18), val and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9), P.white)
            corner(knob, 9)

            local hitbox2 = btn(card, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), Color3.new())
            hitbox2.BackgroundTransparency = 1

            local function setVal(v, silent)
                val = v
                tw(knob,  {Position = v and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)}, 0.18, Enum.EasingStyle.Back)
                tw(track, {BackgroundColor3 = v and P.blueDeep or P.bgElem}, 0.18)
                if not silent and opts2.Callback then opts2.Callback(v) end
                if not silent then
                    notify(opts2.Label or "Option", v and "Enabled" or "Disabled")
                end
            end

            hitbox2.MouseButton1Click:Connect(function() setVal(not val) end)
            hitbox2.MouseEnter:Connect(function()
                tw(card, {BackgroundColor3=P.bgHover}, 0.15)
            end)
            hitbox2.MouseLeave:Connect(function()
                tw(card, {BackgroundColor3=P.bgCard}, 0.15)
            end)

            return { Set = function(v) setVal(v, true) end, Get = function() return val end }
        end

        -- ══════════════════════════════════════════════════════════════════
        -- TOGGLE  (similar to checkbox, different visual style)
        -- ══════════════════════════════════════════════════════════════════
        function Tab:Toggle(opts2)
            opts2 = opts2 or {}
            local h = (opts2.Desc and opts2.Desc~="") and 62 or 46
            local card = makeCard(h)

            addLabelDesc(card, opts2.Label or "Toggle", opts2.Desc)

            local val = opts2.Default == true

            local pill = frame(card, UDim2.new(0,52,0,28), UDim2.new(1,-64,0.5,-14), val and P.blueDeep or P.bgElem)
            corner(pill, 14)
            stroke(pill, val and P.blueMid or P.stroke, 1, 0.3)

            local indicator = frame(pill, UDim2.new(0,20,0,20),
                val and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10), P.white)
            corner(indicator, 10)
            if val then
                grad(indicator, gradSeq(0,P.blueBrt,1,P.white), 135)
            end

            local hitbox2 = btn(card, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), Color3.new())
            hitbox2.BackgroundTransparency = 1

            local function setVal(v, silent)
                val = v
                tw(indicator, {Position = v and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10)}, 0.2, Enum.EasingStyle.Back)
                tw(pill, {BackgroundColor3 = v and P.blueDeep or P.bgElem}, 0.2)
                if not silent and opts2.Callback then opts2.Callback(v) end
                if not silent then notify(opts2.Label or "Option", v and "Enabled" or "Disabled") end
            end

            hitbox2.MouseButton1Click:Connect(function() setVal(not val) end)
            hitbox2.MouseEnter:Connect(function() tw(card,{BackgroundColor3=P.bgHover},0.15) end)
            hitbox2.MouseLeave:Connect(function() tw(card,{BackgroundColor3=P.bgCard},0.15) end)

            return { Set=function(v) setVal(v,true) end, Get=function() return val end }
        end

        -- ══════════════════════════════════════════════════════════════════
        -- MULTIBOX  (multi-select with animated chips)
        -- ══════════════════════════════════════════════════════════════════
        function Tab:Multibox(opts2)
            opts2 = opts2 or {}
            local options = opts2.Options or {}
            local selected = {}

            -- Closed height (label+desc+chips row), expanded adds chip grid
            local CLOSED_H = (opts2.Desc and opts2.Desc~="") and 105 or 90
            local EXPANDED_H = CLOSED_H + math.ceil(#options/3)*38 + 12

            local card = makeCard(CLOSED_H)
            local expanded = false

            addLabelDesc(card, opts2.Label or "Multibox", opts2.Desc)

            -- Selected count badge
            local countBadge = frame(card, UDim2.new(0,24,0,20), UDim2.new(1,-84,0.5,-36), P.purpMid)
            corner(countBadge, 6)
            local countLbl = label(countBadge, "0", 11, P.white, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
            countLbl.Size = UDim2.new(1,0,1,0)
            countLbl.TextYAlignment = Enum.TextYAlignment.Center

            -- Expand button
            local expandBtn2 = btn(card, UDim2.new(0,60,0,28), UDim2.new(1,-74,0.5,-14), P.bgElem)
            corner(expandBtn2, 8)
            stroke(expandBtn2, P.stroke, 1, 0.4)
            local expandLbl = label(expandBtn2, "Select", 11, P.txtSub, Enum.Font.GothamMedium, Enum.TextXAlignment.Center)
            expandLbl.Size = UDim2.new(1,0,1,0)
            expandLbl.TextYAlignment = Enum.TextYAlignment.Center

            -- Options container (hidden until expanded)
            local optFrame = frame(card, UDim2.new(1,-24,0,0), UDim2.new(0,12,0,CLOSED_H-4), Color3.new(), 1)
            local optLayout = Instance.new("UIListLayout")
            optLayout.FillDirection = Enum.FillDirection.Horizontal
            optLayout.Wraps = true
            optLayout.Padding = UDim.new(0,6)
            optLayout.SortOrder = Enum.SortOrder.LayoutOrder
            optLayout.Parent = optFrame

            -- Build option chips
            local chips = {}
            for i,opt in ipairs(options) do
                local chip = btn(optFrame, UDim2.new(0,0,0,28), UDim2.new(0,0,0,0), P.bgElem)
                chip.LayoutOrder = i
                chip.AutomaticSize = Enum.AutomaticSize.X
                corner(chip, 8)
                stroke(chip, P.stroke, 1, 0.4)

                local chipLbl = label(chip, opt, 11, P.txtSub, Enum.Font.GothamMedium)
                chipLbl.Size = UDim2.new(0,0,1,0)
                chipLbl.AutomaticSize = Enum.AutomaticSize.X
                chipLbl.TextYAlignment = Enum.TextYAlignment.Center
                local chipPad = Instance.new("UIPadding")
                chipPad.PaddingLeft=UDim.new(0,8); chipPad.PaddingRight=UDim.new(0,8)
                chipPad.Parent = chip

                chips[opt] = {btn=chip, lbl=chipLbl, active=false}

                chip.MouseButton1Click:Connect(function()
                    local c = chips[opt]
                    c.active = not c.active
                    if c.active then
                        selected[opt] = true
                        tw(chip, {BackgroundColor3=P.blueDeep}, 0.15)
                        tw(chipLbl, {TextColor3=P.blueBrt}, 0.15)
                    else
                        selected[opt] = nil
                        tw(chip, {BackgroundColor3=P.bgElem}, 0.15)
                        tw(chipLbl, {TextColor3=P.txtSub}, 0.15)
                    end
                    local count = 0
                    for _ in pairs(selected) do count=count+1 end
                    countLbl.Text = tostring(count)
                    tw(countBadge, {BackgroundColor3=count>0 and P.purpBrt or P.purpMid}, 0.15)
                    if opts2.Callback then opts2.Callback(selected) end
                end)
            end

            -- Toggle expand
            expandBtn2.MouseButton1Click:Connect(function()
                expanded = not expanded
                local newH = expanded and EXPANDED_H or CLOSED_H
                tw(card, {Size=UDim2.new(1,0,0,newH)}, 0.25, Enum.EasingStyle.Quart)
                tw(optFrame, {BackgroundTransparency = expanded and 1 or 1}, 0.15)
                expandLbl.Text = expanded and "Close" or "Select"
                tw(expandBtn2, {BackgroundColor3=expanded and P.purpDark or P.bgElem}, 0.15)
            end)
            expandBtn2.MouseEnter:Connect(function() tw(expandBtn2,{BackgroundColor3=P.bgHover},0.12) end)
            expandBtn2.MouseLeave:Connect(function() tw(expandBtn2,{BackgroundColor3=expanded and P.purpDark or P.bgElem},0.12) end)

            return {
                GetSelected = function() return selected end,
                SetSelected = function(tbl)
                    for _,c in pairs(chips) do c.active=false; c.btn.BackgroundColor3=P.bgElem; c.lbl.TextColor3=P.txtSub end
                    selected={}
                    for _,opt in ipairs(tbl) do
                        if chips[opt] then
                            chips[opt].active=true
                            chips[opt].btn.BackgroundColor3=P.blueDeep
                            chips[opt].lbl.TextColor3=P.blueBrt
                            selected[opt]=true
                        end
                    end
                end
            }
        end

        -- ══════════════════════════════════════════════════════════════════
        -- SLIDER
        -- ══════════════════════════════════════════════════════════════════
        function Tab:Slider(opts2)
            opts2 = opts2 or {}
            local h = (opts2.Desc and opts2.Desc~="") and 80 or 64
            local card = makeCard(h)
            addLabelDesc(card, opts2.Label or "Slider", opts2.Desc)

            local minV = opts2.Min or 0
            local maxV = opts2.Max or 100
            local val  = math.clamp(opts2.Default or minV, minV, maxV)

            local valLbl = label(card, tostring(val), 12, P.blueBrt, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
            valLbl.Size = UDim2.new(0,60,0,18)
            valLbl.Position = UDim2.new(1,-74,0,10)

            local trackY = (opts2.Desc and opts2.Desc~="") and 54 or 38
            local trackBg = frame(card, UDim2.new(1,-24,0,8), UDim2.new(0,12,0,trackY), P.bgElem)
            corner(trackBg, 4)

            local fill = frame(trackBg, UDim2.new((val-minV)/(maxV-minV),0,1,0), UDim2.new(0,0,0,0), P.blueMid)
            corner(fill, 4)
            grad(fill, gradSeq(0,P.purpBrt,1,P.blueBrt), 0)

            local thumb2 = frame(trackBg, UDim2.new(0,14,0,14),
                UDim2.new((val-minV)/(maxV-minV),-7,0.5,-7), P.white)
            corner(thumb2, 7)
            stroke(thumb2, P.blueBrt, 1, 0.3)

            local sliderHit = btn(trackBg, UDim2.new(1,0,0,24), UDim2.new(0,0,0.5,-12), Color3.new())
            sliderHit.BackgroundTransparency=1

            local draggingSlider = false
            local function setSlider(v, silent)
                v = math.clamp(v, minV, maxV)
                if opts2.Step then v = math.floor(v/opts2.Step+0.5)*opts2.Step end
                val = v
                local pct = (v-minV)/(maxV-minV)
                fill.Size = UDim2.new(pct,0,1,0)
                thumb2.Position = UDim2.new(pct,-7,0.5,-7)
                valLbl.Text = tostring(math.floor(v*100+0.5)/100)
                if not silent and opts2.Callback then opts2.Callback(v) end
            end

            sliderHit.MouseButton1Down:Connect(function()
                draggingSlider=true
                tw(thumb2,{Size=UDim2.new(0,16,0,16)},0.1)
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 then
                    draggingSlider=false
                    tw(thumb2,{Size=UDim2.new(0,14,0,14)},0.1)
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if draggingSlider and i.UserInputType==Enum.UserInputType.MouseMovement then
                    local mx = UserInputService:GetMouseLocation()
                    local pct = math.clamp((mx.X-trackBg.AbsolutePosition.X)/trackBg.AbsoluteSize.X,0,1)
                    setSlider(minV+(maxV-minV)*pct)
                end
            end)

            return { Set=function(v) setSlider(v,true) end, Get=function() return val end }
        end

        -- ══════════════════════════════════════════════════════════════════
        -- DROPDOWN
        -- ══════════════════════════════════════════════════════════════════
        function Tab:Dropdown(opts2)
            opts2 = opts2 or {}
            local options2 = opts2.Options or {}
            local CLOSED_H2 = (opts2.Desc and opts2.Desc~="") and 66 or 50
            local ITEM_H    = 32
            local EXPANDED_H2 = CLOSED_H2 + #options2*ITEM_H + 8

            local card = makeCard(CLOSED_H2)
            local expanded2 = false
            local selected2 = opts2.Default or (options2[1] or "Select...")
            card.ClipsDescendants = true

            addLabelDesc(card, opts2.Label or "Dropdown", opts2.Desc)

            local selBtn = btn(card, UDim2.new(1,-24,0,28), UDim2.new(0,12,0,CLOSED_H2-36), P.bgElem)
            corner(selBtn, 8)
            stroke(selBtn, P.stroke, 1, 0.4)

            local selTxt = label(selBtn, selected2, 12, P.txtPrim, Enum.Font.GothamMedium)
            selTxt.Size = UDim2.new(1,-28,1,0)
            selTxt.Position = UDim2.new(0,10,0,0)
            selTxt.TextYAlignment = Enum.TextYAlignment.Center

            local arrow = label(selBtn, "▾", 12, P.txtSub, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
            arrow.Size = UDim2.new(0,24,1,0)
            arrow.Position = UDim2.new(1,-26,0,0)
            arrow.TextYAlignment = Enum.TextYAlignment.Center

            -- Options list (rendered below button)
            local optList = frame(card, UDim2.new(1,-24,0,0), UDim2.new(0,12,0,CLOSED_H2-4), P.bgElem)
            corner(optList, 8)
            stroke(optList, P.stroke, 1, 0.4)
            optList.ClipsDescendants = true

            local ol = Instance.new("UIListLayout"); ol.SortOrder=Enum.SortOrder.LayoutOrder; ol.Parent=optList

            for i,opt in ipairs(options2) do
                local optBtn2 = btn(optList, UDim2.new(1,0,0,ITEM_H), UDim2.new(0,0,0,0), Color3.new())
                optBtn2.BackgroundTransparency=1
                optBtn2.LayoutOrder=i
                local optTxt2 = label(optBtn2, opt, 12, opt==selected2 and P.blueBrt or P.txtSub, Enum.Font.GothamMedium)
                optTxt2.Size=UDim2.new(1,-16,1,0)
                optTxt2.Position=UDim2.new(0,10,0,0)
                optTxt2.TextYAlignment=Enum.TextYAlignment.Center

                optBtn2.MouseEnter:Connect(function() tw(optBtn2,{BackgroundTransparency=0.7},0.1); optBtn2.BackgroundColor3=P.bgHover end)
                optBtn2.MouseLeave:Connect(function() tw(optBtn2,{BackgroundTransparency=1},0.1) end)
                optBtn2.MouseButton1Click:Connect(function()
                    selected2 = opt
                    selTxt.Text = opt
                    for _,c in optList:GetChildren() do
                        if c:IsA("TextButton") then
                            local lt = c:FindFirstChildOfClass("TextLabel")
                            if lt then lt.TextColor3 = lt.Text==opt and P.blueBrt or P.txtSub end
                        end
                    end
                    expanded2=false
                    tw(card,{Size=UDim2.new(1,0,0,CLOSED_H2)},0.22,Enum.EasingStyle.Quart)
                    tw(optList,{Size=UDim2.new(1,-24,0,0)},0.22,Enum.EasingStyle.Quart)
                    arrow.Text="▾"
                    if opts2.Callback then opts2.Callback(opt) end
                    notify(opts2.Label or "Dropdown", opt.." selected")
                end)
            end

            selBtn.MouseButton1Click:Connect(function()
                expanded2 = not expanded2
                local newH = expanded2 and EXPANDED_H2 or CLOSED_H2
                local newOptH = expanded2 and (#options2*ITEM_H) or 0
                tw(card,{Size=UDim2.new(1,0,0,newH)},0.25,Enum.EasingStyle.Quart)
                tw(optList,{Size=UDim2.new(1,-24,0,newOptH)},0.25,Enum.EasingStyle.Quart)
                arrow.Text = expanded2 and "▴" or "▾"
                tw(arrow,{TextColor3=expanded2 and P.blueBrt or P.txtSub},0.15)
            end)

            return {
                Set=function(v)
                    selected2=v; selTxt.Text=v
                    if opts2.Callback then opts2.Callback(v) end
                end,
                Get=function() return selected2 end
            }
        end

        -- ══════════════════════════════════════════════════════════════════
        -- BUTTON
        -- ══════════════════════════════════════════════════════════════════
        function Tab:Button(opts2)
            opts2 = opts2 or {}
            local h = (opts2.Desc and opts2.Desc~="") and 62 or 46
            local card = makeCard(h)

            addLabelDesc(card, opts2.Label or "Button", opts2.Desc)

            local execBtn = btn(card, UDim2.new(0,70,0,28), UDim2.new(1,-82,0.5,-14), P.blueDeep)
            corner(execBtn, 8)
            stroke(execBtn, P.blueMid, 1, 0.3)
            grad(execBtn, gradSeq(0,P.purpMid,1,P.blueDeep), 135)
            local execLbl = label(execBtn, "Run", 12, P.white, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
            execLbl.Size = UDim2.new(1,0,1,0)
            execLbl.TextYAlignment = Enum.TextYAlignment.Center

            execBtn.MouseButton1Click:Connect(function()
                tw(execBtn,{Size=UDim2.new(0,66,0,26)},0.08)
                task.wait(0.1)
                tw(execBtn,{Size=UDim2.new(0,70,0,28)},0.12,Enum.EasingStyle.Back)
                if opts2.Callback then opts2.Callback() end
                notify(opts2.Label or "Button", "Executed")
            end)
            execBtn.MouseEnter:Connect(function()
                tw(execBtn,{BackgroundColor3=P.blueMid},0.15)
                tw(card,{BackgroundColor3=P.bgHover},0.15)
            end)
            execBtn.MouseLeave:Connect(function()
                tw(execBtn,{BackgroundColor3=P.blueDeep},0.15)
                tw(card,{BackgroundColor3=P.bgCard},0.15)
            end)
        end

        -- ══════════════════════════════════════════════════════════════════
        -- KEYBIND
        -- ══════════════════════════════════════════════════════════════════
        function Tab:Keybind(opts2)
            opts2 = opts2 or {}
            local h = (opts2.Desc and opts2.Desc~="") and 62 or 46
            local card = makeCard(h)
            addLabelDesc(card, opts2.Label or "Keybind", opts2.Desc)

            local currentKey = opts2.Default or Enum.KeyCode.Unknown
            local listening2 = false

            local keyBtn = btn(card, UDim2.new(0,90,0,28), UDim2.new(1,-102,0.5,-14), P.bgElem)
            corner(keyBtn, 8)
            stroke(keyBtn, P.stroke, 1, 0.4)
            local keyLbl = label(keyBtn, currentKey.Name, 11, P.txtPrim, Enum.Font.GothamMedium, Enum.TextXAlignment.Center)
            keyLbl.Size = UDim2.new(1,0,1,0)
            keyLbl.TextYAlignment = Enum.TextYAlignment.Center

            keyBtn.MouseButton1Click:Connect(function()
                if listening2 then return end
                listening2=true
                keyLbl.Text="..."
                tw(keyBtn,{BackgroundColor3=P.purpDark},0.15)
            end)

            UserInputService.InputBegan:Connect(function(inp,gp)
                if listening2 and not gp and inp.UserInputType==Enum.UserInputType.Keyboard then
                    listening2=false
                    currentKey=inp.KeyCode
                    keyLbl.Text=inp.KeyCode.Name
                    tw(keyBtn,{BackgroundColor3=P.bgElem},0.15)
                    if opts2.Callback then opts2.Callback(inp.KeyCode) end
                    notify(opts2.Label or "Keybind", "Set to "..inp.KeyCode.Name)
                end
            end)

            return { Get=function() return currentKey end }
        end

        -- ══════════════════════════════════════════════════════════════════
        -- TEXTBOX
        -- ══════════════════════════════════════════════════════════════════
        function Tab:Textbox(opts2)
            opts2 = opts2 or {}
            local h = (opts2.Desc and opts2.Desc~="") and 80 or 64
            local card = makeCard(h)
            addLabelDesc(card, opts2.Label or "Textbox", opts2.Desc)

            local inputY = (opts2.Desc and opts2.Desc~="") and 48 or 32
            local box = Instance.new("TextBox")
            box.Size = UDim2.new(1,-24,0,28)
            box.Position = UDim2.new(0,12,0,inputY)
            box.BackgroundColor3 = P.bgElem
            box.BorderSizePixel=0
            box.Text = opts2.Default or ""
            box.PlaceholderText = opts2.Placeholder or "Type here..."
            box.TextColor3 = P.txtPrim
            box.PlaceholderColor3 = P.txtDim
            box.TextSize = 12
            box.Font = Enum.Font.GothamMedium
            box.TextXAlignment = Enum.TextXAlignment.Left
            box.ClearTextOnFocus = opts2.ClearOnFocus ~= false
            box.Parent = card
            corner(box, 8)
            local boxStroke2 = stroke(box, P.stroke, 1, 0.4)
            local boxPad2 = Instance.new("UIPadding")
            boxPad2.PaddingLeft=UDim.new(0,8); boxPad2.PaddingRight=UDim.new(0,8)
            boxPad2.Parent=box

            box.Focused:Connect(function()
                tw(boxStroke2,{Color=P.blueMid,Transparency=0},0.15)
            end)
            box.FocusLost:Connect(function(ep)
                tw(boxStroke2,{Color=P.stroke,Transparency=0.4},0.15)
                if ep and opts2.Callback then opts2.Callback(box.Text) end
            end)

            return { Get=function() return box.Text end, Set=function(v) box.Text=v end }
        end

        -- ══════════════════════════════════════════════════════════════════
        -- SECTION LABEL (divider)
        -- ══════════════════════════════════════════════════════════════════
        function Tab:Section(name)
            Tab._order = Tab._order + 1
            local sec = frame(scroll, UDim2.new(1,0,0,24), UDim2.new(0,0,0,0), Color3.new(), 1)
            sec.LayoutOrder = Tab._order

            local line = frame(sec, UDim2.new(0.35,0,0,1), UDim2.new(0,0,0.5,0), P.strokeBrt)
            line.BackgroundTransparency = 0.6
            grad(line, gradSeq(0,Color3.new(),1,P.strokeBrt), 0)

            local secLbl = label(sec, name:upper(), 10, P.txtDim, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
            secLbl.Size = UDim2.new(1,0,1,0)

            local lineR = frame(sec, UDim2.new(0.35,0,0,1), UDim2.new(0.65,0,0.5,0), P.strokeBrt)
            lineR.BackgroundTransparency = 0.6
            grad(lineR, gradSeq(0,P.strokeBrt,1,Color3.new()), 0)
        end

        return Tab
    end

    return Window
end

return CrystalUI
