local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local parent = CoreGui:FindFirstChild("RobloxGui") or CoreGui
local VirtualInputManager = game:GetService("VirtualInputManager")
SelectedKeybinds = Enum.KeyCode.RightControl
_G.SelectedKeybinds = SelectedKeybinds

local isVisible = false

HRSetting = {
    tab = {},
    ver = 1.1
}
HRHelper = {}
Color = {
    Background = Color3.fromRGB(10, 10, 10), 
    Primary = Color3.fromRGB(0, 101, 255),
    White = Color3.fromRGB(245, 245, 245)
}

_G.HRSetting = HRSetting
_G.HRHelper = HRHelper
_G.Color = Color

local saveHR = _G.HRSetting
local activeToast = {}
local ToastYPos = 0.9

function HRHelper:callFunction(name, ...)
    local func = self[name]
    if func and type(func) == "function" then
        func(self, ...)
    end
end

function HRHelper:slide(gui, tipe, start, ends, callback, ticks, delay)
    tipe = tipe or "X" 
    ticks = ticks or 0.03
    delay = delay or 0.01
    local current = start
    local forward = (ends > start)

    while true do
        if forward then
            current = current + ticks
            if current > ends then
                current = ends
                if tipe == "X" then
                    gui.Position = UDim2.new(current, 0, gui.Position.Y.Scale, 0)
                else
                    gui.Position = UDim2.new(gui.Position.X.Scale, 0, current, 0)
                end
                if callback then callback() end
                break
            end
        else
            current = current - ticks
            if current < ends then
                current = ends
                if tipe == "X" then
                    gui.Position = UDim2.new(current, 0, gui.Position.Y.Scale, 0)
                else
                    gui.Position = UDim2.new(gui.Position.X.Scale, 0, current, 0)
                end
                if callback then callback() end
                break
            end
        end

        if tipe == "X" then
            gui.Position = UDim2.new(current, 0, gui.Position.Y.Scale, 0)
        else
            gui.Position = UDim2.new(gui.Position.X.Scale, 0, current, 0)
        end
        task.wait(delay)
    end
end

local activeToast = {}
local ToastYPos = 0.9

local function setActiveToastYPos()
    for i, v in ipairs(activeToast) do
        local targetY = ToastYPos - ((i - 1) * 0.11) 
        game:GetService("TweenService"):Create(v, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
            Position = UDim2.new(0.98, 0, targetY, 0)
        }):Play()
    end
end

function HRHelper.showToast(txt, time)
    local duration = time or 1.5
    local tstGUI = Instance.new("CanvasGroup") 
    tstGUI.Name = "HyperToast"
    tstGUI.Size = UDim2.new(0.175, 0, 0.1, 0)
    tstGUI.AnchorPoint = Vector2.new(1, 0.5) 
    tstGUI.Position = UDim2.new(1.3, 0, ToastYPos, 0)
    tstGUI.BackgroundColor3 = Color.Background or Color3.fromRGB(25, 25, 25)
    tstGUI.GroupTransparency = 1
    tstGUI.ZIndex = 20
    tstGUI.Parent = parent

    Instance.new("UICorner", tstGUI).CornerRadius = UDim.new(0.15, 0)
    
    local tstStroke = Instance.new("UIStroke", tstGUI)
    tstStroke.Color = Color.Primary or Color3.fromRGB(0, 170, 255)
    tstStroke.Thickness = 2
    tstStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local tstTitle = Instance.new("TextLabel", tstGUI)
    tstTitle.Size = UDim2.new(0.4, 0, 0.3, 0)
    tstTitle.Position = UDim2.new(0.05, 0, 0.15, 0)
    tstTitle.BackgroundTransparency = 1
    tstTitle.Text = "INFO : "
    tstTitle.Font = Enum.Font.GothamBold
    tstTitle.TextColor3 = Color.Primary or Color3.fromRGB(0, 170, 255)
    tstTitle.TextScaled = true
    tstTitle.TextXAlignment = Enum.TextXAlignment.Left
    tstTitle.Parent = tstGUI

    local tstLabel = Instance.new("TextLabel", tstGUI)
    tstLabel.Size = UDim2.new(0.9, 0, 0.4, 0)
    tstLabel.Position = UDim2.new(0.05, 0, 0.45, 0)
    tstLabel.BackgroundTransparency = 1
    tstLabel.Text = txt
    tstLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
    tstLabel.RichText = true
    tstLabel.TextScaled = true
	tstLabel.Font = Enum.Font.GothamBold
    tstLabel.TextXAlignment = Enum.TextXAlignment.Left
    tstLabel.Parent = tstGUI
    
    local tstSizeConstraint = Instance.new("UITextSizeConstraint", tstLabel)
    tstSizeConstraint.MaxTextSize = 15
    tstSizeConstraint.MinTextSize = 8

    local barBg = Instance.new("Frame", tstGUI)
    barBg.Size = UDim2.new(0.9, 0, 0.05, 0)
    barBg.Position = UDim2.new(0.05, 0, 0.88, 0)
    barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    barBg.BorderSizePixel = 0
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

    local barFill = Instance.new("Frame", barBg)
    barFill.Size = UDim2.new(1, 0, 1, 0)
    barFill.BackgroundColor3 = Color.Primary or Color3.fromRGB(0, 170, 255)
    barFill.BorderSizePixel = 0
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

    local TS = game:GetService("TweenService")
    local info = TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    
    table.insert(activeToast, 1, tstGUI)
    setActiveToastYPos()

    TS:Create(tstGUI, info, {
        GroupTransparency = 0,
        Position = UDim2.new(0.98, 0, tstGUI.Position.Y.Scale, 0)
    }):Play()

    TS:Create(barFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 1, 0)
    }):Play()

    task.delay(duration, function()
        if tstGUI then
            local close = TS:Create(tstGUI, info, {
                GroupTransparency = 1,
                Position = UDim2.new(1.3, 0, tstGUI.Position.Y.Scale, 0)
            })
            close:Play()
            close.Completed:Connect(function()
                local index = table.find(activeToast, tstGUI)
                if index then table.remove(activeToast, index) end
                tstGUI:Destroy()
                setActiveToastYPos()
            end)
        end
    end)
end

function HRSetting:onLoad()
	saveHR = self
	return self
end

HRSetting:onLoad()

function HRHelper:showNotif(text, btnRight, btnLeft)
    local TargetUI = saveHR.ScreenUI
    
    if not TargetUI then return end

    local NotifFrame = Instance.new("Frame", TargetUI)
    NotifFrame.Name = "HR_Notification"
    NotifFrame.Size = UDim2.new(0.250, 0, 0.150, 0)
    NotifFrame.Position = UDim2.new(0.42, 0, 0.35, 0) 
    NotifFrame.BackgroundColor3 = Color.Background
    NotifFrame.ZIndex = 150
    
    Instance.new("UICorner", NotifFrame).CornerRadius = UDim.new(0, 12)
    
    local stroke = Instance.new("UIStroke", NotifFrame)
    stroke.Color = Color.Primary
    stroke.Thickness = 2

    local Label = Instance.new("TextLabel", NotifFrame)
    Label.Size = UDim2.new(1, 0, 0.5, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.Font = Enum.Font.SourceSansBold
    Label.TextSize = 18
    Label.ZIndex = 151

    local function createStyledBtn(name, pos, callback, isPrimary)
        local btn = Instance.new("TextButton", NotifFrame)
        btn.Size = UDim2.new(0.4, 0, 0.25, 0)
        btn.Position = pos
        btn.Text = name
        btn.ZIndex = 152
        btn.TextColor3 = Color.White
        btn.Font = Enum.Font.SourceSansBold
        btn.TextSize = 18
        btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

        local grad = Instance.new("UIGradient", btn)
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, isPrimary and Color.Primary or Color3.fromRGB(100, 100, 100)),
            ColorSequenceKeypoint.new(1, isPrimary and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(50, 50, 50))
        })
        grad.Enabled = false

        btn.MouseEnter:Connect(function()
            grad.Enabled = true
        end)

        btn.MouseLeave:Connect(function()
            grad.Enabled = false
        end)

        btn.MouseButton1Click:Connect(function()
            NotifFrame:Destroy()
            callback()
        end)
    end

    createStyledBtn(btnRight.name, UDim2.new(0.55, 0, 0.65, 0), btnRight.callback, true)
    createStyledBtn(btnLeft.name, UDim2.new(0.05, 0, 0.65, 0), btnLeft.callback, true)
end

function HRSetting:createMainGUI()
    self.ScreenUI = Instance.new("ScreenGui")
    self.ScreenUI.Name = "HRScreenUI"
    self.ScreenUI.Parent = parent
    self.ScreenUI.ResetOnSpawn = false

    g = self
    g.background = Instance.new("Frame")
    g.background.Size = UDim2.new(0.45, 0, 0.45, 0)
    g.background.Position = UDim2.new(0.25, 0, 0.25, 0)
    g.background.ZIndex = 10
    g.background.BackgroundColor3 = Color.Background
    g.background.Parent = self.ScreenUI
    g.background.Active = true
    g.background.Draggable = true

    local bgCorner = Instance.new("UICorner", g.background)
    bgCorner.CornerRadius = UDim.new(0, 10)
        
    local bgStroke = Instance.new("UIStroke", g.background)
    bgStroke.Color = Color.Primary
    bgStroke.Thickness = 2.5
    bgStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local barrier = Instance.new("Frame")
    barrier.Size = UDim2.new(0, 1, 0.8, 0)
    barrier.Position = UDim2.new(0.25, 0, 0.188, 0)
    barrier.ZIndex = 12
    barrier.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    barrier.Parent = g.background
    self.barrier = barrier

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = g.background
    Title.Size = UDim2.new(0.25, 0, 0.1, 0)
    Title.Position = UDim2.new(0.1, 0, 0.0035, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Hyper Hub | Version " .. HRSetting.ver .. " Release"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 24
    Title.ZIndex = 15
	self.Title = Title

	local titleStroke = Instance.new("UIStroke")
    titleStroke.Thickness = 1.2
    titleStroke.Parent = Title

    local TitleGradient = Instance.new("UIGradient")
    TitleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color.Primary),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 175, 200)),
		ColorSequenceKeypoint.new(0.75, Color3.fromRGB(0, 125, 175)),
        ColorSequenceKeypoint.new(1, Color.Primary)
    })
    TitleGradient.Parent = Title

    task.spawn(function()
        local offset = 0
        while task.wait(0.05) do
            TitleGradient.Offset = Vector2.new(math.sin(tick() * 2) * 0.35, 0)
        end
    end)

	local SubTitle = Instance.new("TextLabel")
    SubTitle.Name = "SubTitle"
    SubTitle.Parent = g.background
    SubTitle.Size = UDim2.new(0.5, 0, 0.05, 0)
    SubTitle.Position = UDim2.new(0.015, 0, 0.085, 0) 
    SubTitle.BackgroundTransparency = 1
    SubTitle.Text = "Made By KhdBG "
    SubTitle.TextColor3 = Color3.fromRGB(255, 255, 255) 
    SubTitle.Font = Enum.Font.SourceSansBold
    SubTitle.TextSize = 14
    SubTitle.TextXAlignment = Enum.TextXAlignment.Left
    SubTitle.ZIndex = 16
	self.Subtitle = SubTitle

    local subStroke = Instance.new("UIStroke")
    subStroke.Thickness = 1.5
    subStroke.Parent = SubTitle

    local subGradient = Instance.new("UIGradient")
    subGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color.Primary),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 200, 255)),
        ColorSequenceKeypoint.new(1, Color.Primary)
    })
    subGradient.Parent = subStroke

    task.spawn(function()
        while task.wait(0.05) do
            subGradient.Offset = Vector2.new(math.sin(tick() * 2) * 0.5, 0)
        end
    end)

    local Watermark = Instance.new("TextLabel")
    Watermark.Name = "Watermark"
    Watermark.Parent = g.background
    Watermark.Size = UDim2.new(0.3, 0, 0.05, 0)
    Watermark.Position = UDim2.new(0.68, 0, 0.93, 0)
    Watermark.BackgroundTransparency = 1
    Watermark.Text = "Hyper Hub Release V" .. HRSetting.ver
    Watermark.TextColor3 = Color3.fromRGB(150, 150, 150)
    Watermark.Font = Enum.Font.SourceSansItalic
    Watermark.TextSize = 12
    Watermark.TextXAlignment = Enum.TextXAlignment.Right
    Watermark.ZIndex = 15
	self.Watermark = Watermark
end

function HRSetting:createTabList()
    self.Sidebar = Instance.new("ScrollingFrame", self.background)
    self.Sidebar.Size = UDim2.new(0.25, -10, 0.8, 0)
    self.Sidebar.Position = UDim2.new(0, 5, 0.188, 0)
    self.Sidebar.BackgroundTransparency = 1
    self.Sidebar.ScrollBarThickness = 0
    self.Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local sideList = Instance.new("UIListLayout", self.Sidebar)
    sideList.Padding = UDim.new(0, 5)
    sideList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    self.ItemContainer = Instance.new("Frame", self.background)
    self.ItemContainer.Position = UDim2.new(0.25, 5, 0.188, 0)
    self.ItemContainer.Size = UDim2.new(0.75, -10, 0.8, 0)
    self.ItemContainer.BackgroundTransparency = 1
    self.ItemContainer.ZIndex = 11
end

function HRSetting:addTab(name, index)
    index = index or #self.tab + 1

    local TabBtn = Instance.new("TextButton", self.Sidebar)
    TabBtn.Size = UDim2.new(0.9, 0, 0, 35)
    TabBtn.BackgroundColor3 = Color.White
    TabBtn.BackgroundTransparency = 0.9
    TabBtn.Text = ""
    TabBtn.ZIndex = 16
    TabBtn.LayoutOrder = index
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local TabText = Instance.new("TextLabel", TabBtn)
    TabText.Size = UDim2.new(1, 0, 1, 0)
    TabText.BackgroundTransparency = 1
    TabText.Text = name
    TabText.TextColor3 = Color3.fromRGB(180, 180, 180)
    TabText.Font = Enum.Font.SourceSansBold
    TabText.TextSize = 16
    TabText.ZIndex = 25
    
    local btnGradient = Instance.new("UIGradient", TabBtn)
    btnGradient.Color = ColorSequence.new(Color.Primary, Color3.fromRGB(0, 40, 100))
    btnGradient.Rotation = 90
    btnGradient.Enabled = false

    local ItemPage = Instance.new("ScrollingFrame", self.ItemContainer)
    ItemPage.Size = UDim2.new(1, 0, 1, 0)
    ItemPage.BackgroundTransparency = 1
    ItemPage.Visible = false
    ItemPage.ScrollBarThickness = 2
    ItemPage.CanvasSize = UDim2.new(0, 0, 0, 0)
    ItemPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ItemPage.ZIndex = 20

    Instance.new("UIListLayout", ItemPage).Padding = UDim.new(0, 8)
    ItemPage.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	ItemPage.UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    Instance.new("UIPadding", ItemPage).PaddingTop = UDim.new(0, 5)

    TabBtn.MouseButton1Click:Connect(function()
        for _, data in ipairs(self.tab) do
            local isTarget = (data.name == name)
            data.scroll.Visible = isTarget
            data.tab.UIGradient.Enabled = isTarget
            data.tab.BackgroundTransparency = isTarget and 0 or 0.9
            data.tab.TextLabel.TextColor3 = isTarget and Color.White or Color3.fromRGB(180, 180, 180)
        end
    end)

    table.insert(self.tab, index, {name = name, scroll = ItemPage, tab = TabBtn})

    if #self.tab == 1 then
        TabBtn.BackgroundTransparency = 0
        btnGradient.Enabled = true
        TabText.TextColor3 = Color.White
        ItemPage.Visible = true
    end
end


function HRSetting:addToggle(tabName, text, funcName, isNoDot, ...)
    local setting, tabIndex
    for i, data in ipairs(self.tab) do
        if data.name == tabName then setting, tabIndex = data.scroll, i break end
    end
    if not setting then return end

    local args = {...}
    local enabled = false
    
    local ItemBG = Instance.new("Frame", setting)
    ItemBG.Size = UDim2.new(0.95, 0, 0, 40)
    ItemBG.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    ItemBG.ZIndex = 25
    Instance.new("UICorner", ItemBG).CornerRadius = UDim.new(0, 6)

    local TglBtn = Instance.new("TextButton", ItemBG)
    TglBtn.Size = UDim2.new(1, 0, 1, 0)
    TglBtn.BackgroundTransparency = 1
    TglBtn.Text = ""
    TglBtn.ZIndex = 26

    local Label = Instance.new("TextLabel", TglBtn)
    Label.Text = text
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.SourceSansBold
    Label.TextSize = 16
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 27

    local SwitchBg = Instance.new("Frame", TglBtn)
    SwitchBg.Size = UDim2.new(0, 36, 0, 18)
    SwitchBg.Position = UDim2.new(1, -45, 0.5, -9)
    SwitchBg.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    SwitchBg.ZIndex = 27
	SwitchBg.Visible = not isNoDot
    Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)

    local Dot = Instance.new("Frame", SwitchBg)
    Dot.Size = UDim2.new(0, 14, 0, 14)
    Dot.Position = UDim2.new(0, 2, 0.5, -7)
    Dot.BackgroundColor3 = Color.White
    Dot.ZIndex = 28
    Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

    TglBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
		HRHelper:callFunction(funcName, enabled, unpack(args))
        local pos = enabled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        local targetColor = enabled and Color.Primary or Color3.fromRGB(45, 45, 45)
        TweenService:Create(Dot, TweenInfo.new(0.2), {Position = pos}):Play()
        TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        Label.TextColor3 = enabled and Color.White or Color3.fromRGB(200, 200, 200)
    end)
end


function HRSetting:addSlider(tabName, text, min, max, funcName, ...)
    local setting
    for _, data in ipairs(self.tab) do
        if data.name == tabName then setting = data.scroll break end
    end
    if not setting then return end

    local args = {...}
    
    local ItemBG = Instance.new("Frame", setting)
    ItemBG.Size = UDim2.new(0.95, 0, 0, 70)
    ItemBG.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    ItemBG.ZIndex = 25
    Instance.new("UICorner", ItemBG).CornerRadius = UDim.new(0, 6)

    local Blocker = Instance.new("TextButton", ItemBG)
    Blocker.Size = UDim2.new(1, 0, 1, 0)
    Blocker.BackgroundTransparency = 1
    Blocker.Text = ""
    Blocker.ZIndex = 26

    local Label = Instance.new("TextLabel", ItemBG)
    Label.Text = text
    Label.Size = UDim2.new(0.6, 0, 0, 25)
    Label.Position = UDim2.new(0, 12, 0, 10)
    Label.TextColor3 = Color.White
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.SourceSansBold
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 27

    local Input = Instance.new("TextBox", ItemBG)
    Input.Size = UDim2.new(0, 50, 0, 22)
    Input.Position = UDim2.new(1, -62, 0, 12)
    Input.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Input.Text = tostring(min)
    Input.TextColor3 = Color.Primary
    Input.Font = Enum.Font.SourceSansBold
    Input.TextSize = 14
    Input.ZIndex = 28
    Input.ClearTextOnFocus = false
    Instance.new("UICorner", Input)

    local Bar = Instance.new("Frame", ItemBG)
    Bar.Size = UDim2.new(0.9, 0, 0, 10)
    Bar.Position = UDim2.new(0.5, 0, 0, 50)
    Bar.AnchorPoint = Vector2.new(0.5, 0)
    Bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Bar.ZIndex = 27
    Instance.new("UICorner", Bar)
    
    local Fill = Instance.new("Frame", Bar)
    Fill.Size = UDim2.new(0, 0, 1, 0)
    Fill.BackgroundColor3 = Color.Primary
    Fill.ZIndex = 28
    Instance.new("UICorner", Fill)

    local DragBtn = Instance.new("TextButton", Bar)
    DragBtn.Size = UDim2.new(1, 0, 5, 0) 
    DragBtn.Position = UDim2.new(0.5, 0, 0.5, 0)
    DragBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    DragBtn.BackgroundTransparency = 1
    DragBtn.Text = ""
    DragBtn.ZIndex = 35

    local dragging = false

    local function updateSlider(value, ignoreInput)
        local val = math.clamp(tonumber(value) or min, min, max)
        local percent = (val - min) / (max - min)
        
        TweenService:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
        
        if not ignoreInput then
            Input.Text = tostring(val)
        end
        
        HRHelper:callFunction(funcName, val, unpack(args))
    end

    local function move()
        local pos = math.clamp((Mouse.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * pos)
        updateSlider(val)
    end

    Blocker.MouseEnter:Connect(function() self.background.Draggable = false end)
    Blocker.MouseLeave:Connect(function() if not dragging then self.background.Draggable = true end end)

    DragBtn.InputBegan:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 then 
            dragging = true 
            move()
        end 
    end)

    UserInputService.InputEnded:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 then 
            dragging = false 
            self.background.Draggable = true
        end 
    end)

    RunService.RenderStepped:Connect(function() if dragging then move() end end)

    Input.FocusLost:Connect(function(enterPressed)
        updateSlider(Input.Text)
    end)
end

HRSetting.activeCheckboxes = HRSetting.activeCheckboxes or {}

function HRSetting:addCheckbox(tabName, info, selectedActiveCheckbox)
    if not self.tab then 
        warn("[addCheckbox Error]: self.tab is nil! Make sure tabs are initialized.") 
        return 
    end
    
    local setting = nil
    local index = 0
    for i, data in ipairs(self.tab) do
        if data.name == tabName then 
            setting = data.scroll 
            index = i
            break 
        end
    end
    
    if not setting then return end

    if type(info) ~= "table" then return end

    local listLayout = setting:FindFirstChildOfClass("UIListLayout")
    local function runLogic(f, state)
        if not f or f == "" then 
            warn("[addCheckbox Warning]: Function name/obj is empty for state: " .. tostring(state))
            return 
        end

        if type(f) == "string" then
            if HRHelper and HRHelper.callFunction then
                local success = HRHelper:callFunction(f, state)
                if not success then
                    local GFunc = _G[f]
                    if type(GFunc) == "function" then 
                        GFunc(state) 
                    end
                end
            elseif _G[f] then
                _G[f](state)
            end
        elseif type(f) == "function" then
            f(state)
        end
    end

    local function resetOthers(currentText)
        if not self.activeCheckboxes then return end
        for i = #self.activeCheckboxes, 1, -1 do
            local cb = self.activeCheckboxes[i]
            if cb then
                if not cb.indicator or not cb.indicator.Parent then
                    table.remove(self.activeCheckboxes, i)
                elseif cb.tab == tabName and cb.name ~= currentText then
                    cb.enabled = false
                    cb.indicator.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    if cb.label then cb.label.TextColor3 = Color3.fromRGB(200, 200, 200) end
                    runLogic(cb.func, false)
                end
            end
        end
    end

	local currentCount = 0
    for _, child in ipairs(setting:GetChildren()) do
        if child:IsA("Frame") then currentCount = currentCount + 1 end
    end

    for i, laci in ipairs(info) do
        if type(laci) == "table" then
            local text = laci[1] or "Unknown"
            local func = laci[2]
            
            local ItemBG = Instance.new("Frame", setting)
            ItemBG.Name = "Checkbox_" .. tostring(text)
            ItemBG.Size = UDim2.new(0.95, 0, 0, 45)
            ItemBG.BackgroundColor3 = Color.Background
            ItemBG.ZIndex = 25 
            Instance.new("UICorner", ItemBG).CornerRadius = UDim.new(0, 6)

            local TglBtn = Instance.new("TextButton", ItemBG)
            TglBtn.Size = UDim2.new(1, 0, 1, 0)
            TglBtn.BackgroundTransparency = 1
            TglBtn.Text = ""
            TglBtn.ZIndex = 26

            local Label = Instance.new("TextLabel", TglBtn)
            Label.Text = text
            Label.Size = UDim2.new(0.7, 0, 1, 0)
            Label.Position = UDim2.new(0, 12, 0, 0)
            Label.TextColor3 = Color3.fromRGB(200, 200, 200)
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.SourceSansBold
            Label.TextSize = 16
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.ZIndex = 27

            local Indicator = Instance.new("Frame", TglBtn)
            Indicator.Size = UDim2.new(0, 18, 0, 18)
            Indicator.Position = UDim2.new(1, -30, 0.5, -9)
            Indicator.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            Indicator.BorderSizePixel = 0
            Indicator.ZIndex = 28
            Instance.new("UICorner", Indicator).CornerRadius = UDim.new(0, 4)

            local checkboxData = {
                name = text,
                tab = tabName,
                indicator = Indicator,
                label = Label,
                enabled = false,
                func = func
            }
            table.insert(self.activeCheckboxes, checkboxData)
            table.insert(self.tab[index], {name = text, func = func})

            local function toggle(state)
                if state then
                    resetOthers(text)
                    checkboxData.enabled = true
                    Indicator.BackgroundColor3 = Color3.fromRGB(0, 101, 255)
                    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
                else
                    checkboxData.enabled = false
                    Indicator.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
                end
                runLogic(func, checkboxData.enabled)
            end

            if selectedActiveCheckbox == text then
                toggle(true)
            end

            TglBtn.MouseButton1Click:Connect(function()
                toggle(not checkboxData.enabled)
            end)

            TglBtn.MouseEnter:Connect(function() 
                if self.background then self.background.Draggable = false end 
            end)
            TglBtn.MouseLeave:Connect(function() 
                if self.background then self.background.Draggable = true end 
            end)
        else
            warn("[addCheckbox Warning]: One of the 'info' elements is not a table.")
        end
    end
    
    setting.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
end
function HRSetting:createHelpBtn()
    local g = self
    local ParentFrame = g.background
    ParentFrame.ClipsDescendants = true

    local ControlFrame = Instance.new("Frame", ParentFrame)
    ControlFrame.ZIndex = 21 
    ControlFrame.Size = UDim2.new(0, 70, 0, 30)
    ControlFrame.Position = UDim2.new(1, -75, 0, 12) 
    ControlFrame.BackgroundTransparency = 1

    local DelBtn = Instance.new("ImageButton", ControlFrame)
    DelBtn.Name = "DeleteBtn"
    DelBtn.Size = UDim2.new(0, 18, 0, 18)
    DelBtn.Position = UDim2.new(1, -22, 0.5, -9)
    DelBtn.BackgroundTransparency = 1
    DelBtn.Image = "rbxassetid://6031094678"
    DelBtn.ImageColor3 = Color3.new(1, 1, 1) 
	DelBtn.ZIndex = 25

    local MinBtn = Instance.new("TextButton", ControlFrame)
    MinBtn.Name = "hide"
    MinBtn.Size = UDim2.new(0, 18, 0, 18)
    MinBtn.Position = UDim2.new(0, 5, 0.5, -9)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.new(1, 1, 1)
    MinBtn.TextSize = 25
    MinBtn.Font = Enum.Font.SourceSansBold
	MinBtn.ZIndex = 25

    DelBtn.MouseButton1Click:Connect(function()
        HRHelper:showNotif("Are U Sure To Delete This Gui?", 
            {name = "Yes", callback = function() 
                 HRHelper:showNotif("Do U Really sure?", 
                    {name = "Yes", callback = function() 
                       self.ScreenUI:Destroy()
				       HRSetting = nil
				       HRHelper.showToast("Destroyed")
                    end}, 
                 {name = "Cancel", callback = function()end})
             end}, 
        {name = "Cancel", callback = function()end})
    end)
    
    MinBtn.MouseButton1Click:Connect(function()
        isVisible = not isVisible
        if self.ScreenUI then
            self.background.Visible = isVisible
        end
    end)
end

function HRSetting:createOpenBtn()
    local opn = Instance.new("TextButton")
    opn.Size = UDim2.new(0.04, 0, 0.07, 0)
    opn.Position = UDim2.new(0.5, 0, 0.1, 0)
    opn.Text = "HR"
	opn.TextColor3 = Color.White
    opn.BackgroundColor3 = Color.Background
	opn.Font = Enum.Font.SourceSansBold
	opn.TextSize = 25
	opn.RichText = true
	opn.Draggable = true
    Instance.new("UICorner", opn).CornerRadius = UDim.new(0, 8)
	opn.Parent = self.ScreenUI
    
    local opnStroke = Instance.new("UIStroke")
    opnStroke.Color = Color.Primary
    opnStroke.Thickness = 2.3
    opnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    opnStroke.Parent = opn

	local opnStroke2 = Instance.new("UIStroke")
    opnStroke2.Color = Color.Primary
    opnStroke2.Thickness = 1.3
    opnStroke2.Parent = opn


    opn.MouseButton1Click:Connect(function()
        isVisible = not isVisible
        if self.ScreenUI then
            self.background.Visible = isVisible
        end
    end)


    self.openBtn = opn
end

function HRSetting:init()
    saveHR = self
    self:createMainGUI()
    self:createTabList()
	self:createHelpBtn()
    self:createOpenBtn()

    self:addTab("Home", 1)
end

HRSetting:init()
HRSetting:addToggle("Home", "OpenConsole", "openConsole")
HRSetting:addToggle("Home", "Hyper Hub V"..HRSetting.ver.." Release", "", true)
HRSetting:addToggle("Home", "HyperHub Credits : ", "", true)
HRSetting:addToggle("Home", "GUI By : KhdBg", "", true)
HRSetting:addToggle("Home", "Function By : KhdBg, Zentex & RageV99", "", true)

function HRHelper:openConsole()
   togopenConsole = not togopenConsole
   if togopenConsole then
       VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F9, false, game)
   else
       VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F9, false, game)
   end
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == SelectedKeybinds then 
	    isVisible = not isVisible
        saveHR.background.Visible = isVisible
    end
end)

HRHelper.showToast("Press RightControl to Open Menu", 3)
