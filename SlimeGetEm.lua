-- ╔══════════════════════════════════════════════════════════════════╗
-- ║              SlimeGetEm UI Library  —  v1.0                     ║
-- ║  Gray × White theme  |  Tabs · Toggle · Checkbox · Multibox    ║
-- ║  Slider · Dropdown · Button · Keybind · Textbox · Section      ║
-- ╚══════════════════════════════════════════════════════════════════╝
--
-- QUICKSTART:
--   local UI  = loadstring(...)()
--   local win = UI:Window({ Title="SlimeGetEm", Sub="v1.0" })
--   local tab = win:Tab("Combat")
--   tab:Toggle({ Label="Silent Aim", Desc="...", Default=false, Callback=function(v) end })
--   tab:Checkbox({ Label="Triggerbot", Desc="...", Default=false, Callback=function(v) end })
--   tab:Multibox({ Label="Weapons", Desc="...", Options={"A","B"}, Callback=function(tbl) end })
--   tab:Slider({ Label="FOV", Desc="...", Min=0, Max=500, Default=120, Step=5, Callback=function(v) end })
--   tab:Dropdown({ Label="Team", Desc="...", Options={"Red","Blue"}, Callback=function(v) end })
--   tab:Button({ Label="Run", Desc="...", Callback=function() end })
--   tab:Keybind({ Label="Hotkey", Desc="...", Default=Enum.KeyCode.Q, Callback=function(k) end })
--   tab:Textbox({ Label="Name", Desc="...", Placeholder="...", Callback=function(s) end })
--   tab:Section("Category Name")

local TS  = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local PL  = game:GetService("Players")

local lp = PL.LocalPlayer
repeat task.wait() until lp:FindFirstChild("PlayerGui")

-- cleanup
for _,g in ipairs({"SlimeGetEm","SlimeNotifs"}) do
    local old = lp.PlayerGui:FindFirstChild(g)
    if old then old:Destroy() end
end

-- ═══════════════════════════════════════════════════════════════════
--  PALETTE  —  Gray / White / Transparent
-- ═══════════════════════════════════════════════════════════════════
local C = {
    -- Panel backgrounds (dark gray, semi-transparent)
    win      = Color3.fromRGB(22, 22, 26),   -- outermost window
    panel    = Color3.fromRGB(28, 28, 33),   -- sidebar / sections
    card     = Color3.fromRGB(34, 34, 40),   -- element cards
    cardHov  = Color3.fromRGB(42, 42, 50),   -- card hover
    elem     = Color3.fromRGB(44, 44, 52),   -- inputs / tracks
    elemHov  = Color3.fromRGB(56, 56, 66),   -- input hover

    -- Borders
    border   = Color3.fromRGB(60, 60, 72),
    borderBrt= Color3.fromRGB(90, 90, 108),

    -- Text
    txtW     = Color3.fromRGB(245, 245, 250), -- primary white
    txtG     = Color3.fromRGB(165, 165, 180), -- secondary gray
    txtD     = Color3.fromRGB(100, 100, 115), -- dim / placeholder

    -- Accent  (cool gray-blue, used sparingly)
    acc      = Color3.fromRGB(130, 140, 165), -- accent gray-blue
    accBrt   = Color3.fromRGB(200, 210, 230), -- bright accent
    accDim   = Color3.fromRGB(50,  52,  62),  -- accent dim bg

    -- Status
    on       = Color3.fromRGB(80, 220, 140),  -- green ON
    onDim    = Color3.fromRGB(20, 60,  38),
    off      = Color3.fromRGB(55, 55, 66),

    -- Util
    white    = Color3.fromRGB(255,255,255),
    black    = Color3.fromRGB(0,0,0),
    red      = Color3.fromRGB(210,60,60),
    amber    = Color3.fromRGB(210,155,20),
}

-- ═══════════════════════════════════════════════════════════════════
--  HELPERS
-- ═══════════════════════════════════════════════════════════════════
local function tw(obj, goal, t, sty, dir)
    sty = sty or Enum.EasingStyle.Quad
    dir = dir  or Enum.EasingDirection.Out
    local t2 = TS:Create(obj, TweenInfo.new(t,sty,dir), goal)
    t2:Play(); return t2
end

local function rnd(p,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 10); c.Parent=p; return c end
local function str(p,col,th,tr) local s=Instance.new("UIStroke"); s.Color=col or C.border; s.Thickness=th or 1; s.Transparency=tr or 0; s.Parent=p; return s end
local function pad(p,t,b,l,r) local u=Instance.new("UIPadding"); u.PaddingTop=UDim.new(0,t or 0); u.PaddingBottom=UDim.new(0,b or 0); u.PaddingLeft=UDim.new(0,l or 0); u.PaddingRight=UDim.new(0,r or 0); u.Parent=p end

local function frm(par,sz,pos,col,tr)
    local f=Instance.new("Frame"); f.Size=sz; f.Position=pos or UDim2.new(0,0,0,0)
    f.BackgroundColor3=col or C.card; f.BackgroundTransparency=tr or 0; f.BorderSizePixel=0; f.Parent=par; return f
end

local function lbl(par,txt,sz,col,fnt,xa,ya)
    local l=Instance.new("TextLabel"); l.BackgroundTransparency=1; l.Text=txt
    l.TextSize=sz or 13; l.TextColor3=col or C.txtW; l.Font=fnt or Enum.Font.GothamMedium
    l.TextXAlignment=xa or Enum.TextXAlignment.Left; l.TextYAlignment=ya or Enum.TextYAlignment.Center
    l.TextWrapped=true; l.Parent=par; return l
end

local function tbtn(par,sz,pos,col,tr)
    local b=Instance.new("TextButton"); b.Size=sz; b.Position=pos or UDim2.new(0,0,0,0)
    b.BackgroundColor3=col or C.elem; b.BackgroundTransparency=tr or 0; b.BorderSizePixel=0
    b.Text=""; b.AutoButtonColor=false; b.Parent=par; return b
end

-- ═══════════════════════════════════════════════════════════════════
--  NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════════════════════
local nsg=Instance.new("ScreenGui"); nsg.Name="SlimeNotifs"; nsg.ResetOnSpawn=false
nsg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; nsg.IgnoreGuiInset=true; nsg.Parent=lp.PlayerGui

local nHolder=frm(nsg,UDim2.new(0,300,1,-20),UDim2.new(1,-316,0,10),C.black,1)
local nLayout=Instance.new("UIListLayout"); nLayout.SortOrder=Enum.SortOrder.LayoutOrder
nLayout.VerticalAlignment=Enum.VerticalAlignment.Bottom; nLayout.Padding=UDim.new(0,6); nLayout.Parent=nHolder

local nQueue,nBusy={},false
local function notify(title,desc,dur)
    dur=dur or 2.8
    table.insert(nQueue,{t=title,d=desc,dur=dur})
    if nBusy then return end
    nBusy=true
    task.spawn(function()
        while #nQueue>0 do
            local n=table.remove(nQueue,1)
            local h=n.d and 58 or 42
            local card=frm(nHolder,UDim2.new(1,0,0,0),nil,C.panel)
            card.ClipsDescendants=true; rnd(card,10); str(card,C.borderBrt,1,0.3)
            -- accent left bar
            local ab=frm(card,UDim2.new(0,3,1,-8),UDim2.new(0,0,0,4),C.accBrt); rnd(ab,2)
            local tl=lbl(card,n.t,12,C.txtW,Enum.Font.GothamSemibold)
            tl.Size=UDim2.new(1,-14,0,16); tl.Position=UDim2.new(0,10,0,6)
            if n.d then
                local dl=lbl(card,n.d,11,C.txtG,Enum.Font.Gotham)
                dl.Size=UDim2.new(1,-14,0,14); dl.Position=UDim2.new(0,10,0,24)
            end
            tw(card,{Size=UDim2.new(1,0,0,h)},0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
            task.wait(n.dur)
            tw(card,{Size=UDim2.new(1,0,0,0),BackgroundTransparency=1},0.18)
            task.wait(0.22); card:Destroy(); task.wait(0.05)
        end
        nBusy=false
    end)
end

-- ═══════════════════════════════════════════════════════════════════
--  LIBRARY
-- ═══════════════════════════════════════════════════════════════════
local Lib={} ; Lib.__index=Lib

function Lib:Notify(title,desc,dur) notify(title,desc,dur) end

-- ─────────────────────────────────────────────────────────────────
--  WINDOW
-- ─────────────────────────────────────────────────────────────────
function Lib:Window(opts)
    opts=opts or {}
    local WW = opts.Width  or 640
    local WH = opts.Height or 560
    local SIDEBAR = 148

    -- ScreenGui
    local sg=Instance.new("ScreenGui"); sg.Name="SlimeGetEm"; sg.ResetOnSpawn=false
    sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; sg.IgnoreGuiInset=true; sg.Parent=lp.PlayerGui

    -- ── LOADING SCREEN ────────────────────────────────────────────
    local ls=frm(sg,UDim2.new(0,WW,0,WH),UDim2.new(0.5,-WW/2,0.5,-WH/2),C.win)
    ls.ZIndex=60; ls.ClipsDescendants=true; rnd(ls,18); str(ls,C.border,1,0.2)

    -- subtle gradient overlay on loader
    local lsGrad=Instance.new("UIGradient"); lsGrad.Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0,Color3.fromRGB(30,30,36)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(18,18,22)),
    }; lsGrad.Rotation=145; lsGrad.Parent=ls

    -- Logo box
    local logoBox=frm(ls,UDim2.new(0,60,0,60),UDim2.new(0.5,-30,0.5,-90),C.elem)
    rnd(logoBox,16); str(logoBox,C.borderBrt,1,0.2)
    local logoL=lbl(logoBox,"S",30,C.txtW,Enum.Font.GothamBlack,Enum.TextXAlignment.Center)
    logoL.Size=UDim2.new(1,0,1,0)

    local loadTitle=lbl(ls,opts.Title or "SlimeGetEm",22,C.txtW,Enum.Font.GothamBlack,Enum.TextXAlignment.Center)
    loadTitle.Size=UDim2.new(1,0,0,28); loadTitle.Position=UDim2.new(0,0,0.5,2)

    local loadSub=lbl(ls,opts.Sub or "Loading...",12,C.txtG,Enum.Font.Gotham,Enum.TextXAlignment.Center)
    loadSub.Size=UDim2.new(1,0,0,16); loadSub.Position=UDim2.new(0,0,0.5,36)

    local barBg=frm(ls,UDim2.new(0,240,0,4),UDim2.new(0.5,-120,0.5,68),C.elem); rnd(barBg,3)
    local barFill=frm(barBg,UDim2.new(0,0,1,0),nil,C.accBrt); rnd(barFill,3)
    -- bar gradient
    local barGrad=Instance.new("UIGradient"); barGrad.Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0,C.txtG),
        ColorSequenceKeypoint.new(1,C.white),
    }; barGrad.Parent=barFill

    local loadPct=lbl(ls,"0%",10,C.txtD,Enum.Font.GothamMedium,Enum.TextXAlignment.Center)
    loadPct.Size=UDim2.new(1,0,0,14); loadPct.Position=UDim2.new(0,0,0.5,80)

    -- ── MAIN WINDOW ────────────────────────────────────────────────
    local main=frm(sg,UDim2.new(0,WW,0,WH),UDim2.new(0.5,-WW/2,0.5,-WH/2),C.win)
    main.Visible=false; main.ClipsDescendants=true; rnd(main,18); str(main,C.border,1,0.15)

    -- Thin top glow line
    local topLine=frm(main,UDim2.new(0.65,0,0,1),UDim2.new(0.175,0,0,0),C.accBrt)
    topLine.BackgroundTransparency=0.55
    local tlg=Instance.new("UIGradient"); tlg.Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0,C.black),
        ColorSequenceKeypoint.new(0.4,C.white),
        ColorSequenceKeypoint.new(0.6,C.white),
        ColorSequenceKeypoint.new(1,C.black),
    }; tlg.Parent=topLine

    -- ── Header ────────────────────────────────────────────────────
    local header=frm(main,UDim2.new(1,0,0,54),nil,C.win)

    -- Title
    local titleL=lbl(header,opts.Title or "SlimeGetEm",19,C.txtW,Enum.Font.GothamBlack)
    titleL.Size=UDim2.new(0,280,0,24); titleL.Position=UDim2.new(0,16,0,10)

    local subL=lbl(header,opts.Sub or "",12,C.txtD,Enum.Font.Gotham)
    subL.Size=UDim2.new(0,280,0,16); subL.Position=UDim2.new(0,16,0,34)

    -- Status pill
    local pill=frm(header,UDim2.new(0,82,0,22),UDim2.new(1,-170,0,16),C.elem); rnd(pill,11); str(pill,C.border,1,0.3)
    local pillDot=frm(pill,UDim2.new(0,8,0,8),UDim2.new(0,8,0.5,-4),C.txtD); rnd(pillDot,4)
    local pillTxt=lbl(pill,"INACTIVE",10,C.txtD,Enum.Font.GothamBold,Enum.TextXAlignment.Left)
    pillTxt.Size=UDim2.new(1,-22,1,0); pillTxt.Position=UDim2.new(0,22,0,0)

    -- Minimize & Close
    local minBtn=tbtn(header,UDim2.new(0,26,0,26),UDim2.new(1,-66,0,14),C.amber)
    rnd(minBtn,7)
    local minL=lbl(minBtn,"–",16,C.white,Enum.Font.GothamBold,Enum.TextXAlignment.Center); minL.Size=UDim2.new(1,0,1,0)

    local closeBtn=tbtn(header,UDim2.new(0,26,0,26),UDim2.new(1,-34,0,14),C.red)
    rnd(closeBtn,7)
    local closeL=lbl(closeBtn,"×",18,C.white,Enum.Font.GothamBold,Enum.TextXAlignment.Center); closeL.Size=UDim2.new(1,0,1,0)

    -- Toggle visibility (RightShift by default, or opts.ToggleKey)
    local guiOpen   = true
    local guiLoaded = false
    local toggleKey = opts.ToggleKey or Enum.KeyCode.RightShift

    local function openGUI()
        if not guiLoaded then return end
        guiOpen = true
        main.Visible = true
        main.BackgroundTransparency = 1
        main.Size     = UDim2.new(0, WW*0.88, 0, WH*0.88)
        main.Position = UDim2.new(0.5, -WW*0.88/2, 0.5, -WH*0.88/2)
        tw(main, {
            BackgroundTransparency = 0,
            Size     = UDim2.new(0, WW, 0, WH),
            Position = UDim2.new(0.5, -WW/2, 0.5, -WH/2),
        }, 0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end

    local function closeGUI()
        if not guiLoaded then return end
        guiOpen = false
        tw(main, {
            BackgroundTransparency = 1,
            Size     = UDim2.new(0, WW*0.88, 0, WH*0.88),
            Position = UDim2.new(0.5, -WW*0.88/2, 0.5, -WH*0.88/2),
        }, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.delay(0.25, function() if not guiOpen then main.Visible = false end end)
    end

    local function toggleGUI()
        if guiOpen then closeGUI() else openGUI() end
    end

    UIS.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if inp.KeyCode == toggleKey then toggleGUI() end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        tw(main,{Size=UDim2.new(0,WW*0.88,0,WH*0.88),BackgroundTransparency=1},0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In)
        task.wait(0.25); sg:Destroy()
    end)

    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        tw(main, {Size = minimized and UDim2.new(0,WW,0,54) or UDim2.new(0,WW,0,WH)},
            0.28, Enum.EasingStyle.Quart)
    end)

    -- Header divider
    local hdiv=frm(main,UDim2.new(1,-32,0,1),UDim2.new(0,16,0,54),C.border)
    hdiv.BackgroundTransparency=0.5

    -- ── Drag ──────────────────────────────────────────────────────
    local dragging,ds,dp=false,nil,nil
    header.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; ds=i.Position; dp=main.Position end
    end)
    header.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-ds
            main.Position=UDim2.new(dp.X.Scale,dp.X.Offset+d.X,dp.Y.Scale,dp.Y.Offset+d.Y)
        end
    end)

    -- ── Sidebar ────────────────────────────────────────────────────
    local sidebar=frm(main,UDim2.new(0,SIDEBAR,1,-56),UDim2.new(0,0,0,55),C.panel)
    -- right border line
    local sbl=frm(sidebar,UDim2.new(0,1,1,0),UDim2.new(1,-1,0,0),C.border)
    local sbList=Instance.new("UIListLayout"); sbList.SortOrder=Enum.SortOrder.LayoutOrder
    sbList.Padding=UDim.new(0,2); sbList.Parent=sidebar
    pad(sidebar,8,8,6,6)

    -- ── Content area ──────────────────────────────────────────────
    local contentArea=frm(main,UDim2.new(1,-SIDEBAR,1,-56),UDim2.new(0,SIDEBAR,0,55),C.black,1)

    -- Sliding tab indicator on sidebar
    local tabInd=frm(sidebar,UDim2.new(0,3,0,30),UDim2.new(1,-3,0,6),C.accBrt); rnd(tabInd,2)
    tabInd.ZIndex=5

    -- ── Loading animation ──────────────────────────────────────────
    task.spawn(function()
        local steps={"Initializing...","Building interface...","Loading modules...","Finalizing..."}
        for i,s in ipairs(steps) do
            loadSub.Text=s
            local p=i/#steps
            tw(barFill,{Size=UDim2.new(p,0,1,0)},0.3)
            loadPct.Text=math.floor(p*100).."%"
            task.wait(0.25)
        end
        loadPct.Text="100%"
        tw(barFill,{Size=UDim2.new(1,0,1,0)},0.18)
        task.wait(0.32)
        -- Reveal main
        main.Visible=true
        main.Size=UDim2.new(0,WW*0.93,0,WH*0.93)
        main.Position=UDim2.new(0.5,-WW*0.93/2,0.5,-WH*0.93/2)
        main.BackgroundTransparency=1
        tw(ls,{BackgroundTransparency=1},0.25); task.wait(0.05)
        tw(main,{
            BackgroundTransparency=0,
            Size=UDim2.new(0,WW,0,WH),
            Position=UDim2.new(0.5,-WW/2,0.5,-WH/2)
        },0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out)
        task.wait(0.35); ls:Destroy()
        guiLoaded = true
        notify("SlimeGetEm","Loaded! Press "..tostring(toggleKey.Name).." to toggle",3)
    end)

    -- ═══════════════════════════════════════════════════════════════
    --  WINDOW OBJECT
    -- ═══════════════════════════════════════════════════════════════
    local Win={_tabs={},_tabBtns={},_active=nil,_pillDot=pillDot,_pillTxt=pillTxt,_pill=pill}

    function Win:Notify(t,d,dur) notify(t,d,dur) end

    -- ── TAB ─────────────────────────────────────────────────────────
    function Win:Tab(name)
        local idx=#self._tabs+1

        -- Sidebar button
        local sb=tbtn(sidebar,UDim2.new(1,0,0,34),nil,C.win,1); sb.LayoutOrder=idx; rnd(sb,8)
        local sbBg=frm(sb,UDim2.new(1,0,1,0),nil,C.cardHov); sbBg.BackgroundTransparency=1; rnd(sbBg,8)
        local sbTxt=lbl(sb,name,12,C.txtG,Enum.Font.GothamMedium); sbTxt.Size=UDim2.new(1,-10,1,0); sbTxt.Position=UDim2.new(0,10,0,0)

        -- Scroll frame
        local scroll=Instance.new("ScrollingFrame")
        scroll.Size=UDim2.new(1,0,1,0); scroll.BackgroundTransparency=1; scroll.BorderSizePixel=0
        scroll.ScrollBarThickness=3; scroll.ScrollBarImageColor3=C.borderBrt
        scroll.CanvasSize=UDim2.new(0,0,0,0); scroll.Visible=false; scroll.ClipsDescendants=true
        scroll.Parent=contentArea

        local iList=Instance.new("UIListLayout"); iList.SortOrder=Enum.SortOrder.LayoutOrder
        iList.Padding=UDim.new(0,7); iList.Parent=scroll
        pad(scroll,12,14,12,12)
        iList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll.CanvasSize=UDim2.new(0,0,0,iList.AbsoluteContentSize.Y+26)
        end)

        local Tab={_scroll=scroll,_ord=0}
        table.insert(self._tabs,Tab)
        table.insert(self._tabBtns,{sb=sb,bg=sbBg,txt=sbTxt})

        local function activate()
            for i,tb in ipairs(self._tabBtns) do
                local on=(tb.sb==sb)
                tw(tb.bg,{BackgroundTransparency=on and 0.55 or 1},0.18)
                tw(tb.txt,{TextColor3=on and C.txtW or C.txtG},0.18)
                self._tabs[i]._scroll.Visible=on
                if on then
                    self._tabs[i]._scroll.GroupTransparency=1
                    tw(self._tabs[i]._scroll,{GroupTransparency=0},0.2)
                end
            end
            -- Animate indicator
            local ay=sb.AbsolutePosition.Y-sidebar.AbsolutePosition.Y
            tw(tabInd,{Position=UDim2.new(1,-3,0,ay+2)},0.2,Enum.EasingStyle.Quart)
            self._active=Tab
        end

        sb.MouseButton1Click:Connect(activate)
        sb.MouseEnter:Connect(function() if self._active~=Tab then tw(sbBg,{BackgroundTransparency=0.8},0.12) end end)
        sb.MouseLeave:Connect(function() if self._active~=Tab then tw(sbBg,{BackgroundTransparency=1},0.12) end end)

        if idx==1 then task.defer(activate) end

        -- ── CARD factory ────────────────────────────────────────────
        local function card(h)
            Tab._ord=Tab._ord+1
            local f=frm(scroll,UDim2.new(1,0,0,h),nil,C.card)
            f.LayoutOrder=Tab._ord; f.ClipsDescendants=true; rnd(f,10); str(f,C.border,1,0.5)
            -- sheen
            local sh=frm(f,UDim2.new(1,0,0,1),nil,C.white); sh.BackgroundTransparency=0.88
            return f
        end

        local function addLD(f,label2,desc2)
            local l=lbl(f,label2,13,C.txtW,Enum.Font.GothamSemibold)
            l.Size=UDim2.new(1,-16,0,17); l.Position=UDim2.new(0,12,0,9)
            if desc2 and desc2~="" then
                local d=lbl(f,desc2,11,C.txtD,Enum.Font.Gotham)
                d.Size=UDim2.new(1,-16,0,14); d.Position=UDim2.new(0,12,0,27)
            end
        end

        local hasDesc=function(o) return o.Desc and o.Desc~="" end
        local CH=function(o) return hasDesc(o) and 60 or 44 end  -- card height helper

        -- ══════════════════════════════════════════════════════════
        --  TOGGLE  (pill switch)
        -- ══════════════════════════════════════════════════════════
        function Tab:Toggle(o)
            o=o or {}
            local f=card(CH(o)); addLD(f,o.Label or "Toggle",o.Desc)
            local val=o.Default==true

            local track=frm(f,UDim2.new(0,44,0,24),UDim2.new(1,-56,0.5,-12),val and C.onDim or C.off); rnd(track,12)
            str(track,val and C.on or C.border,1,val and 0.5 or 0.3)
            local knob=frm(track,UDim2.new(0,18,0,18),val and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9),C.white); rnd(knob,9)
            local hit=tbtn(f,UDim2.new(1,0,1,0),nil,C.black,1)

            local trackStroke=track:FindFirstChildOfClass("UIStroke")

            local function set(v,silent)
                val=v
                tw(knob,{Position=v and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)},0.18,Enum.EasingStyle.Back)
                tw(track,{BackgroundColor3=v and C.onDim or C.off},0.18)
                if trackStroke then tw(trackStroke,{Color=v and C.on or C.border,Transparency=v and 0.3 or 0.4},0.18) end
                if not silent then
                    if o.Callback then o.Callback(v) end
                    notify(o.Label or "Toggle",v and "Enabled" or "Disabled")
                end
            end
            hit.MouseButton1Click:Connect(function() set(not val) end)
            hit.MouseEnter:Connect(function() tw(f,{BackgroundColor3=C.cardHov},0.12) end)
            hit.MouseLeave:Connect(function() tw(f,{BackgroundColor3=C.card},0.12) end)
            return {Set=function(v) set(v,true) end,Get=function() return val end}
        end

        -- ══════════════════════════════════════════════════════════
        --  CHECKBOX  (square box tick)
        -- ══════════════════════════════════════════════════════════
        function Tab:Checkbox(o)
            o=o or {}
            local f=card(CH(o)); addLD(f,o.Label or "Checkbox",o.Desc)
            local val=o.Default==true

            -- Box
            local box=frm(f,UDim2.new(0,22,0,22),UDim2.new(1,-36,0.5,-11),val and C.accBrt or C.elem); rnd(box,6)
            local boxStr=str(box,val and C.white or C.border,1,val and 0.4 or 0.2)

            -- Tick mark (TextLabel "✓")
            local tick=lbl(box,"✓",14,C.win,Enum.Font.GothamBold,Enum.TextXAlignment.Center)
            tick.Size=UDim2.new(1,0,1,0); tick.TextTransparency=val and 0 or 1

            local hit=tbtn(f,UDim2.new(1,0,1,0),nil,C.black,1)
            local function set(v,silent)
                val=v
                tw(box,{BackgroundColor3=v and C.accBrt or C.elem},0.15)
                tw(tick,{TextTransparency=v and 0 or 1},0.12)
                if boxStr then tw(boxStr,{Color=v and C.white or C.border,Transparency=v and 0.3 or 0.2},0.15) end
                if not silent then
                    if o.Callback then o.Callback(v) end
                    notify(o.Label or "Checkbox",v and "Checked" or "Unchecked")
                end
            end
            hit.MouseButton1Click:Connect(function() set(not val) end)
            hit.MouseEnter:Connect(function() tw(f,{BackgroundColor3=C.cardHov},0.12) end)
            hit.MouseLeave:Connect(function() tw(f,{BackgroundColor3=C.card},0.12) end)
            return {Set=function(v) set(v,true) end,Get=function() return val end}
        end

        -- ══════════════════════════════════════════════════════════
        --  MULTIBOX  — expandable list, each row toggles independently
        --  Checkmark appears on the right of each selected row
        -- ══════════════════════════════════════════════════════════
        function Tab:Multibox(o)
            o = o or {}
            local opts2  = o.Options or {}
            local ITEM_H = 36
            local HDR_H  = CH(o)          -- header row height
            local OPEN_H = HDR_H + 6 + #opts2 * ITEM_H + 8

            -- Outer card — clips children, expands downward
            local f = card(HDR_H)
            f.ClipsDescendants = true

            -- ── Header row (label + desc + badge + arrow) ────────────
            -- Label & desc already added via addLD, but we need them
            -- INSIDE a fixed-height header so they never scroll
            local hdrRow = frm(f, UDim2.new(1,0,0,HDR_H), UDim2.new(0,0,0,0), C.black, 1)
            addLD(hdrRow, o.Label or "Multibox", o.Desc)

            -- Count badge (top-right of header)
            local badge    = frm(hdrRow, UDim2.new(0,26,0,22), UDim2.new(1,-96,0.5,-11), C.elem)
            rnd(badge,7); str(badge,C.border,1,0.3)
            local badgeTxt = lbl(badge,"0",11,C.txtG,Enum.Font.GothamBold,Enum.TextXAlignment.Center)
            badgeTxt.Size  = UDim2.new(1,0,1,0)

            -- Arrow expand button (top-right of header)
            local arrowBtn = frm(hdrRow, UDim2.new(0,32,0,28), UDim2.new(1,-38,0.5,-14), C.elem)
            rnd(arrowBtn,8); str(arrowBtn,C.border,1,0.4)
            local arrowL   = lbl(arrowBtn,"▾",13,C.txtG,Enum.Font.GothamBold,Enum.TextXAlignment.Center)
            arrowL.Size    = UDim2.new(1,0,1,0)
            local arrowHit = tbtn(hdrRow, UDim2.new(0,32,0,28), UDim2.new(1,-38,0.5,-14), C.black, 1)

            -- ── Separator line ───────────────────────────────────────
            local sep = frm(f, UDim2.new(1,-24,0,1), UDim2.new(0,12,0,HDR_H), C.border)
            sep.BackgroundTransparency = 0.55

            -- ── Option rows ──────────────────────────────────────────
            -- Use a frame below the header; UIListLayout stacks rows cleanly
            local listOuter = frm(f, UDim2.new(1,0,0,#opts2*ITEM_H+6), UDim2.new(0,0,0,HDR_H+2), C.black, 1)
            local rowLayout = Instance.new("UIListLayout")
            rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
            rowLayout.Padding   = UDim.new(0,0)
            rowLayout.Parent    = listOuter
            pad(listOuter,4,4,0,0)

            local selected = {}
            local count    = 0
            local chips    = {}

            for i, optName in ipairs(opts2) do
                -- Row container
                local row   = frm(listOuter, UDim2.new(1,0,0,ITEM_H), nil, C.black, 1)
                row.LayoutOrder = i

                -- Hover bg (inset 12px each side)
                local rowBg = frm(row, UDim2.new(1,-24,1,-6), UDim2.new(0,12,0,3), C.elem)
                rowBg.BackgroundTransparency = 1
                rnd(rowBg, 8)

                -- Option name label
                local rowTxt = lbl(row, optName, 12, C.txtG, Enum.Font.GothamMedium)
                rowTxt.Size     = UDim2.new(1,-64,1,0)
                rowTxt.Position = UDim2.new(0,24,0,0)

                -- Checkbox on the right (inside the hover bg bounds)
                local chkBox  = frm(row, UDim2.new(0,22,0,22), UDim2.new(1,-38,0.5,-11), C.elem)
                rnd(chkBox,7); str(chkBox,C.border,1,0.3)
                local chkTick = lbl(chkBox,"✓",13,C.win,Enum.Font.GothamBold,Enum.TextXAlignment.Center)
                chkTick.Size            = UDim2.new(1,0,1,0)
                chkTick.TextTransparency = 1

                -- Full-row hitbox
                local rowHit = tbtn(row, UDim2.new(1,0,1,0), nil, C.black, 1)

                chips[optName] = {active=false, rowTxt=rowTxt, chkBox=chkBox, chkTick=chkTick, rowBg=rowBg}

                rowHit.MouseButton1Click:Connect(function()
                    local c = chips[optName]
                    c.active = not c.active
                    if c.active then
                        selected[optName] = true;  count = count + 1
                        tw(rowBg,   {BackgroundTransparency=0.65},        0.14)
                        tw(rowTxt,  {TextColor3=C.txtW},                  0.14)
                        tw(chkBox,  {BackgroundColor3=C.accBrt},          0.14)
                        tw(chkTick, {TextTransparency=0, TextColor3=C.win}, 0.1)
                    else
                        selected[optName] = nil;   count = count - 1
                        tw(rowBg,   {BackgroundTransparency=1},           0.14)
                        tw(rowTxt,  {TextColor3=C.txtG},                  0.14)
                        tw(chkBox,  {BackgroundColor3=C.elem},            0.14)
                        tw(chkTick, {TextTransparency=1},                 0.1)
                    end
                    badgeTxt.Text = tostring(count)
                    tw(badge,    {BackgroundColor3=count>0 and C.accDim or C.elem}, 0.14)
                    tw(badgeTxt, {TextColor3=count>0 and C.accBrt or C.txtG},      0.14)
                    if o.Callback then o.Callback(selected) end
                end)
                rowHit.MouseEnter:Connect(function()
                    if not chips[optName].active then tw(rowBg,{BackgroundTransparency=0.85},0.1) end
                end)
                rowHit.MouseLeave:Connect(function()
                    if not chips[optName].active then tw(rowBg,{BackgroundTransparency=1},0.1) end
                end)
            end

            -- ── Expand / collapse ────────────────────────────────────
            local expanded = false
            arrowHit.MouseButton1Click:Connect(function()
                expanded = not expanded
                tw(f, {Size=UDim2.new(1,0,0, expanded and OPEN_H or HDR_H)},
                    0.26, Enum.EasingStyle.Quart)
                arrowL.Text = expanded and "▴" or "▾"
                tw(arrowL,   {TextColor3=expanded and C.txtW or C.txtG},         0.15)
                tw(arrowBtn, {BackgroundColor3=expanded and C.elemHov or C.elem}, 0.15)
            end)
            arrowHit.MouseEnter:Connect(function()
                tw(arrowBtn,{BackgroundColor3=C.elemHov},0.1)
            end)
            arrowHit.MouseLeave:Connect(function()
                tw(arrowBtn,{BackgroundColor3=expanded and C.elemHov or C.elem},0.1)
            end)

            return {
                GetSelected = function() return selected end,
                SetSelected = function(tbl)
                    for _, c in pairs(chips) do
                        c.active = false
                        c.chkBox.BackgroundColor3   = C.elem
                        c.chkTick.TextTransparency  = 1
                        c.rowBg.BackgroundTransparency = 1
                        c.rowTxt.TextColor3         = C.txtG
                    end
                    selected = {}; count = 0
                    for _, n in ipairs(tbl) do
                        if chips[n] then
                            chips[n].active                    = true
                            selected[n]                        = true
                            count                              = count + 1
                            chips[n].chkBox.BackgroundColor3   = C.accBrt
                            chips[n].chkTick.TextTransparency  = 0
                            chips[n].rowBg.BackgroundTransparency = 0.65
                            chips[n].rowTxt.TextColor3         = C.txtW
                        end
                    end
                    badgeTxt.Text = tostring(count)
                end,
            }
        end

        -- ══════════════════════════════════════════════════════════
        --  SLIDER
        -- ══════════════════════════════════════════════════════════
        function Tab:Slider(o)
            o=o or {}
            local fh=hasDesc(o) and 78 or 62
            local f=card(fh); addLD(f,o.Label or "Slider",o.Desc)
            local minV=o.Min or 0; local maxV=o.Max or 100
            local val=math.clamp(o.Default or minV,minV,maxV)

            local valL=lbl(f,tostring(val),12,C.accBrt,Enum.Font.GothamBold,Enum.TextXAlignment.Right)
            valL.Size=UDim2.new(0,52,0,16); valL.Position=UDim2.new(1,-64,0,9)

            local ty=hasDesc(o) and 52 or 36
            local tBg=frm(f,UDim2.new(1,-24,0,8),UDim2.new(0,12,0,ty),C.elem); rnd(tBg,4)
            local tFill=frm(tBg,UDim2.new((val-minV)/(maxV-minV),0,1,0),nil,C.accBrt); rnd(tFill,4)
            -- fill gradient
            local fg=Instance.new("UIGradient"); fg.Color=ColorSequence.new{
                ColorSequenceKeypoint.new(0,C.txtG), ColorSequenceKeypoint.new(1,C.white),
            }; fg.Parent=tFill

            local thumb=frm(tBg,UDim2.new(0,14,0,14),UDim2.new((val-minV)/(maxV-minV),-7,0.5,-7),C.white); rnd(thumb,7)
            local tHit=tbtn(tBg,UDim2.new(1,0,0,22),UDim2.new(0,0,0.5,-11),C.black,1)

            local drag=false
            local function setV(v,silent)
                v=math.clamp(v,minV,maxV)
                if o.Step then v=math.floor(v/o.Step+0.5)*o.Step end
                val=v
                local p=(v-minV)/(maxV-minV)
                tFill.Size=UDim2.new(p,0,1,0)
                thumb.Position=UDim2.new(p,-7,0.5,-7)
                valL.Text=tostring(math.floor(v*1000+0.5)/1000)
                if not silent and o.Callback then o.Callback(v) end
            end
            tHit.MouseButton1Down:Connect(function() drag=true; tw(thumb,{Size=UDim2.new(0,16,0,16)},0.08) end)
            UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false; tw(thumb,{Size=UDim2.new(0,14,0,14)},0.08) end end)
            UIS.InputChanged:Connect(function(i)
                if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
                    local mx=UIS:GetMouseLocation()
                    local p=math.clamp((mx.X-tBg.AbsolutePosition.X)/tBg.AbsoluteSize.X,0,1)
                    setV(minV+(maxV-minV)*p)
                end
            end)
            return {Set=function(v) setV(v,true) end,Get=function() return val end}
        end

        -- ══════════════════════════════════════════════════════════
        --  DROPDOWN  (single select, stored refs, clean logic)
        -- ══════════════════════════════════════════════════════════
        function Tab:Dropdown(o)
            o = o or {}
            local opts3   = o.Options or {}
            local ITEM_H2 = 32
            local CLOSED_H2 = CH(o)
            local OPEN_H2   = CLOSED_H2 + #opts3 * ITEM_H2 + 10

            local f = card(CLOSED_H2)
            f.ClipsDescendants = true
            addLD(f, o.Label or "Dropdown", o.Desc)

            local sel = o.Default or (opts3[1] or "Select...")

            -- Header select row
            local selRow = frm(f, UDim2.new(1,-24,0,28), UDim2.new(0,12,0,CLOSED_H2-36), C.elem)
            rnd(selRow,8); str(selRow,C.border,1,0.4)
            local selTxt = lbl(selRow, sel, 12, C.txtW, Enum.Font.GothamMedium)
            selTxt.Size = UDim2.new(1,-28,1,0); selTxt.Position = UDim2.new(0,10,0,0)
            local arrL = lbl(selRow, "▾", 11, C.txtD, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
            arrL.Size = UDim2.new(0,22,1,0); arrL.Position = UDim2.new(1,-24,0,0)

            -- Options list container
            local oList = frm(f, UDim2.new(1,-24,0,0), UDim2.new(0,12,0,CLOSED_H2-4), C.elem)
            rnd(oList,8); str(oList,C.border,1,0.4); oList.ClipsDescendants = true
            local oLayout = Instance.new("UIListLayout")
            oLayout.SortOrder = Enum.SortOrder.LayoutOrder
            oLayout.Parent = oList

            -- Store row refs: optName -> {rowTxt, ckTxt, rowBg}
            local rows = {}
            for i, optN in ipairs(opts3) do
                local ob = tbtn(oList, UDim2.new(1,0,0,ITEM_H2), nil, C.black, 1)
                ob.LayoutOrder = i
                local obBg = frm(ob, UDim2.new(1,0,1,0), nil, C.elemHov)
                obBg.BackgroundTransparency = 1
                local oTxt = lbl(ob, optN, 12, optN==sel and C.txtW or C.txtG, Enum.Font.GothamMedium)
                oTxt.Size = UDim2.new(1,-36,1,0); oTxt.Position = UDim2.new(0,10,0,0)
                local ckL = lbl(ob, optN==sel and "✓" or "", 12, C.accBrt, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
                ckL.Size = UDim2.new(0,24,1,0); ckL.Position = UDim2.new(1,-26,0,0)
                rows[optN] = {txt=oTxt, ck=ckL, bg=obBg}

                ob.MouseEnter:Connect(function()
                    if sel ~= optN then tw(obBg,{BackgroundTransparency=0.75},0.1) end
                end)
                ob.MouseLeave:Connect(function()
                    if sel ~= optN then tw(obBg,{BackgroundTransparency=1},0.1) end
                end)
                ob.MouseButton1Click:Connect(function()
                    local prev = sel
                    sel = optN
                    selTxt.Text = optN
                    -- deactivate previous row
                    if rows[prev] then
                        tw(rows[prev].txt, {TextColor3=C.txtG}, 0.12)
                        rows[prev].ck.Text = ""
                        tw(rows[prev].bg, {BackgroundTransparency=1}, 0.12)
                    end
                    -- activate new row
                    tw(oTxt, {TextColor3=C.txtW}, 0.12)
                    ckL.Text = "✓"
                    tw(obBg, {BackgroundTransparency=0.6}, 0.12)
                    -- close dropdown
                    tw(f, {Size=UDim2.new(1,0,0,CLOSED_H2)}, 0.22, Enum.EasingStyle.Quart)
                    tw(oList, {Size=UDim2.new(1,-24,0,0)}, 0.22, Enum.EasingStyle.Quart)
                    arrL.Text = "▾"
                    tw(arrL, {TextColor3=C.txtD}, 0.12)
                    if o.Callback then o.Callback(optN) end
                    notify(o.Label or "Dropdown", optN.." selected")
                end)
            end

            -- Toggle expand on header hit
            local expDD = false
            local selHit = tbtn(f, UDim2.new(1,-24,0,28), UDim2.new(0,12,0,CLOSED_H2-36), C.black, 1)
            selHit.MouseButton1Click:Connect(function()
                expDD = not expDD
                tw(f, {Size=UDim2.new(1,0,0, expDD and OPEN_H2 or CLOSED_H2)}, 0.24, Enum.EasingStyle.Quart)
                tw(oList, {Size=UDim2.new(1,-24,0, expDD and #opts3*ITEM_H2 or 0)}, 0.24, Enum.EasingStyle.Quart)
                arrL.Text = expDD and "▴" or "▾"
                tw(arrL, {TextColor3 = expDD and C.txtW or C.txtD}, 0.12)
            end)

            return {
                Get = function() return sel end,
                Set = function(v)
                    if rows[sel] then rows[sel].ck.Text=""; rows[sel].txt.TextColor3=C.txtG end
                    sel=v; selTxt.Text=v
                    if rows[v] then rows[v].ck.Text="✓"; rows[v].txt.TextColor3=C.txtW end
                    if o.Callback then o.Callback(v) end
                end
            }
        end

        -- ══════════════════════════════════════════════════════════
        --  BUTTON
        -- ══════════════════════════════════════════════════════════
        function Tab:Button(o)
            o=o or {}
            local f=card(CH(o)); addLD(f,o.Label or "Button",o.Desc)
            local runBtn=frm(f,UDim2.new(0,64,0,26),UDim2.new(1,-76,0.5,-13),C.elem); rnd(runBtn,8); str(runBtn,C.borderBrt,1,0.4)
            local runL=lbl(runBtn,"Run",12,C.txtW,Enum.Font.GothamSemibold,Enum.TextXAlignment.Center); runL.Size=UDim2.new(1,0,1,0)
            local runHit=tbtn(f,UDim2.new(0,64,0,26),UDim2.new(1,-76,0.5,-13),C.black,1)
            runHit.MouseButton1Click:Connect(function()
                tw(runBtn,{Size=UDim2.new(0,60,0,24)},0.07)
                task.wait(0.08); tw(runBtn,{Size=UDim2.new(0,64,0,26)},0.12,Enum.EasingStyle.Back)
                if o.Callback then o.Callback() end
                notify(o.Label or "Button","Executed")
            end)
            runHit.MouseEnter:Connect(function() tw(runBtn,{BackgroundColor3=C.elemHov},0.12); tw(f,{BackgroundColor3=C.cardHov},0.12) end)
            runHit.MouseLeave:Connect(function() tw(runBtn,{BackgroundColor3=C.elem},0.12); tw(f,{BackgroundColor3=C.card},0.12) end)
        end

        -- ══════════════════════════════════════════════════════════
        --  KEYBIND
        -- ══════════════════════════════════════════════════════════
        function Tab:Keybind(o)
            o=o or {}
            local f=card(CH(o)); addLD(f,o.Label or "Keybind",o.Desc)
            local curKey=o.Default or Enum.KeyCode.Unknown
            local listening=false
            local kBtn=frm(f,UDim2.new(0,84,0,26),UDim2.new(1,-96,0.5,-13),C.elem); rnd(kBtn,8); str(kBtn,C.border,1,0.3)
            local kL=lbl(kBtn,curKey.Name,11,C.txtW,Enum.Font.GothamMedium,Enum.TextXAlignment.Center); kL.Size=UDim2.new(1,0,1,0)
            local kHit=tbtn(f,UDim2.new(0,84,0,26),UDim2.new(1,-96,0.5,-13),C.black,1)
            kHit.MouseButton1Click:Connect(function()
                if listening then return end
                listening=true; kL.Text="…"
                tw(kBtn,{BackgroundColor3=C.elemHov},0.12)
            end)
            UIS.InputBegan:Connect(function(inp,gp)
                if listening and not gp and inp.UserInputType==Enum.UserInputType.Keyboard then
                    listening=false; curKey=inp.KeyCode; kL.Text=inp.KeyCode.Name
                    tw(kBtn,{BackgroundColor3=C.elem},0.12)
                    if o.Callback then o.Callback(inp.KeyCode) end
                    notify(o.Label or "Keybind","Set to "..inp.KeyCode.Name)
                end
            end)
            return {Get=function() return curKey end}
        end

        -- ══════════════════════════════════════════════════════════
        --  TEXTBOX
        -- ══════════════════════════════════════════════════════════
        function Tab:Textbox(o)
            o=o or {}
            local fh=hasDesc(o) and 78 or 62
            local f=card(fh); addLD(f,o.Label or "Textbox",o.Desc)
            local ty=hasDesc(o) and 46 or 30
            local box=Instance.new("TextBox")
            box.Size=UDim2.new(1,-24,0,26); box.Position=UDim2.new(0,12,0,ty)
            box.BackgroundColor3=C.elem; box.BorderSizePixel=0
            box.Text=o.Default or ""; box.PlaceholderText=o.Placeholder or "Enter text…"
            box.TextColor3=C.txtW; box.PlaceholderColor3=C.txtD
            box.TextSize=12; box.Font=Enum.Font.GothamMedium
            box.TextXAlignment=Enum.TextXAlignment.Left; box.ClearTextOnFocus=o.ClearOnFocus~=false
            box.Parent=f; rnd(box,7)
            local bs=str(box,C.border,1,0.4)
            local bp=Instance.new("UIPadding"); bp.PaddingLeft=UDim.new(0,8); bp.PaddingRight=UDim.new(0,8); bp.Parent=box
            box.Focused:Connect(function() tw(bs,{Color=C.accBrt,Transparency=0},0.15) end)
            box.FocusLost:Connect(function(ep)
                tw(bs,{Color=C.border,Transparency=0.4},0.15)
                if ep and o.Callback then o.Callback(box.Text) end
            end)
            return {Get=function() return box.Text end,Set=function(v) box.Text=v end}
        end

        -- ══════════════════════════════════════════════════════════
        --  SECTION  (divider label)
        -- ══════════════════════════════════════════════════════════
        function Tab:Section(name)
            Tab._ord=Tab._ord+1
            local f=frm(scroll,UDim2.new(1,0,0,22),nil,C.black,1); f.LayoutOrder=Tab._ord
            local line=frm(f,UDim2.new(0.3,0,0,1),UDim2.new(0,0,0.5,0),C.border); line.BackgroundTransparency=0.5
            local sg2=Instance.new("UIGradient"); sg2.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,C.black),ColorSequenceKeypoint.new(1,C.borderBrt)}; sg2.Parent=line
            local sl=lbl(f,name:upper(),9,C.txtD,Enum.Font.GothamBold,Enum.TextXAlignment.Center); sl.Size=UDim2.new(1,0,1,0)
            local lineR=frm(f,UDim2.new(0.3,0,0,1),UDim2.new(0.7,0,0.5,0),C.border); lineR.BackgroundTransparency=0.5
            local srg=Instance.new("UIGradient"); srg.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,C.borderBrt),ColorSequenceKeypoint.new(1,C.black)}; srg.Parent=lineR
        end

        return Tab
    end  -- Win:Tab

    return Win
end  -- Lib:Window

return Lib
