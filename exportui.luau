--[[
     
     
                                 BY GEETANK
                                 DISCORD : @topggalactic
     
     
]]--

local GuiLibrary = {}
GuiLibrary.__index = GuiLibrary

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")

-- Local Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Sound Assets (Create these sounds in your game)
local SOUNDS = {
    Click = "rbxassetid://131961136", -- Button click
    Hover = "rbxassetid://131961136", -- Hover effect
    Switch = "rbxassetid://131961136", -- Toggle switch
    Slide = "rbxassetid://131961136", -- Slider movement
    Dropdown = "rbxassetid://131961136", -- Dropdown open/close
    Type = "rbxassetid://131961136", -- Typing sound
    Success = "rbxassetid://131961136", -- Success notification
    Error = "rbxassetid://131961136", -- Error notification
    WindowOpen = "rbxassetid://131961136", -- Window opening
    WindowClose = "rbxassetid://131961136" -- Window closing
}

-- Default Theme Configuration
local DEFAULT_THEME = {
    -- Colors
    Background = Color3.fromRGB(25, 25, 25),
    Secondary = Color3.fromRGB(35, 35, 35),
    Accent = Color3.fromRGB(0, 162, 255),
    AccentHover = Color3.fromRGB(0, 132, 215),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(200, 200, 200),
    Success = Color3.fromRGB(46, 204, 113),
    Warning = Color3.fromRGB(241, 196, 15),
    Error = Color3.fromRGB(231, 76, 60),
    Border = Color3.fromRGB(60, 60, 60),
    
    -- Sizes
    CornerRadius = UDim.new(0, 8),
    BorderSize = 1,
    
    -- Fonts
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold,
    
    -- Animation
    AnimationTime = 0.3,
    AnimationStyle = Enum.EasingStyle.Quad,
    AnimationDirection = Enum.EasingDirection.Out,
    
    -- Sound
    SoundEnabled = true,
    SoundVolume = 0.5
}

-- Utility Functions
local function playSound(soundName, volume)
    if not DEFAULT_THEME.SoundEnabled then return end
    
    local soundId = SOUNDS[soundName]
    if not soundId then return end
    
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = volume or DEFAULT_THEME.SoundVolume
    sound.Parent = SoundService
    
    sound:Play()
    
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

local function createTween(object, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or DEFAULT_THEME.AnimationTime,
        style or DEFAULT_THEME.AnimationStyle,
        direction or DEFAULT_THEME.AnimationDirection
    )
    
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or DEFAULT_THEME.CornerRadius
    corner.Parent = parent
    return corner
end

local function createStroke(parent, thickness, color)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = thickness or DEFAULT_THEME.BorderSize
    stroke.Color = color or DEFAULT_THEME.Border
    stroke.Parent = parent
    return stroke
end

local function createGradient(parent, colors, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(colors or {
        ColorSequenceKeypoint.new(0, DEFAULT_THEME.Background),
        ColorSequenceKeypoint.new(1, DEFAULT_THEME.Secondary)
    })
    gradient.Rotation = rotation or 90
    gradient.Parent = parent
    return gradient
end

local function addDropShadow(parent, size, offset, color, transparency)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "DropShadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/Controls/DropShadow.png"
    shadow.ImageColor3 = color or Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = transparency or 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.Size = UDim2.new(1, size or 20, 1, size or 20)
    shadow.Position = UDim2.new(0, -(size or 20)/2 + (offset and offset.X or 5), 0, -(size or 20)/2 + (offset and offset.Y or 5))
    shadow.ZIndex = parent.ZIndex - 1
    shadow.Parent = parent.Parent
    return shadow
end

-- Animation Presets
local ANIMATIONS = {
    FadeIn = function(object, duration)
        object.BackgroundTransparency = 1
        return createTween(object, {BackgroundTransparency = 0}, duration)
    end,
    
    FadeOut = function(object, duration)
        return createTween(object, {BackgroundTransparency = 1}, duration)
    end,
    
    SlideIn = function(object, direction, duration)
        local originalPos = object.Position
        local offset = direction == "left" and UDim2.new(-1, 0, 0, 0) or
                      direction == "right" and UDim2.new(1, 0, 0, 0) or
                      direction == "up" and UDim2.new(0, 0, -1, 0) or
                      UDim2.new(0, 0, 1, 0)
        
        object.Position = originalPos + offset
        return createTween(object, {Position = originalPos}, duration)
    end,
    
    Bounce = function(object, scale, duration)
        local originalSize = object.Size
        return createTween(object, {Size = originalSize * (scale or 1.1)}, duration/2):andThen(function()
            return createTween(object, {Size = originalSize}, duration/2)
        end)
    end,
    
    Pulse = function(object, intensity, duration)
        local originalColor = object.BackgroundColor3
        local pulseColor = Color3.new(
            math.min(1, originalColor.R + (intensity or 0.1)),
            math.min(1, originalColor.G + (intensity or 0.1)),
            math.min(1, originalColor.B + (intensity or 0.1))
        )
        
        return createTween(object, {BackgroundColor3 = pulseColor}, duration/2):andThen(function()
            return createTween(object, {BackgroundColor3 = originalColor}, duration/2)
        end)
    end
}

-- Voice Feedback System
local VoiceFeedback = {}

function VoiceFeedback:speak(text, voice)
    -- This would integrate with text-to-speech if available
    -- For now, we'll use sound effects and visual feedback
    print("[Voice]: " .. text)
    playSound("Success", 0.3)
end

function VoiceFeedback:announce(action, component)
    local messages = {
        button_click = "Button activated",
        slider_change = "Slider value changed",
        toggle_on = "Toggle enabled",
        toggle_off = "Toggle disabled",
        dropdown_open = "Dropdown opened",
        dropdown_close = "Dropdown closed",
        tab_switch = "Tab switched",
        window_open = "Window opened",
        window_close = "Window closed",
        window_minimize = "Window minimized"
    }
    
    local message = messages[action] or action
    self:speak(message)
end

-- Main GUI Library Class
function GuiLibrary.new(config)
    local self = setmetatable({}, GuiLibrary)
    
    -- Configuration
    self.config = config or {}
    self.theme = self.config.theme or DEFAULT_THEME
    self.name = self.config.name or "GUI Library"
    self.voice = VoiceFeedback
    
    -- Main ScreenGui
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = self.name
    self.screenGui.ResetOnSpawn = false
    self.screenGui.IgnoreGuiInset = true
    self.screenGui.Parent = PlayerGui
    
    -- Component tracking
    self.windows = {}
    self.components = {}
    self.themes = {default = DEFAULT_THEME}
    
    -- Initialize
    self:_initialize()
    
    return self
end

function GuiLibrary:_initialize()
    -- Create notification system
    self:_createNotificationSystem()
    
    -- Voice announcement
    self.voice:announce("window_open", "library")
    playSound("WindowOpen")
end

function GuiLibrary:_createNotificationSystem()
    self.notificationFrame = Instance.new("Frame")
    self.notificationFrame.Name = "Notifications"
    self.notificationFrame.BackgroundTransparency = 1
    self.notificationFrame.Position = UDim2.new(1, -320, 0, 20)
    self.notificationFrame.Size = UDim2.new(0, 300, 1, -40)
    self.notificationFrame.Parent = self.screenGui
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = self.notificationFrame
end

-- Window Creation
function GuiLibrary:createWindow(options)
    options = options or {}
    
    local window = {
        title = options.title or "New Window",
        size = options.size or UDim2.new(0, 600, 0, 400),
        position = options.position or UDim2.new(0.5, -300, 0.5, -200),
        resizable = options.resizable ~= false,
        minimizable = options.minimizable ~= false,
        closable = options.closable ~= false,
        theme = options.theme or self.theme
    }
    
    -- Main Window Frame
    window.frame = Instance.new("Frame")
    window.frame.Name = window.title
    window.frame.BackgroundColor3 = window.theme.Background
    window.frame.BorderSizePixel = 0
    window.frame.Position = window.position
    window.frame.Size = window.size
    window.frame.ZIndex = 10
    window.frame.Parent = self.screenGui
    
    createCorner(window.frame, window.theme.CornerRadius)
    createStroke(window.frame, window.theme.BorderSize, window.theme.Border)
    addDropShadow(window.frame, 30, {X = 0, Y = 8}, Color3.fromRGB(0, 0, 0), 0.3)
    
    -- Title Bar
    window.titleBar = Instance.new("Frame")
    window.titleBar.Name = "TitleBar"
    window.titleBar.BackgroundColor3 = window.theme.Secondary
    window.titleBar.BorderSizePixel = 0
    window.titleBar.Size = UDim2.new(1, 0, 0, 40)
    window.titleBar.Parent = window.frame
    
    createCorner(window.titleBar, UDim.new(0, 8))
    
    -- Title Bar Bottom Border
    local titleBarBottom = Instance.new("Frame")
    titleBarBottom.BackgroundColor3 = window.theme.Secondary
    titleBarBottom.BorderSizePixel = 0
    titleBarBottom.Position = UDim2.new(0, 0, 1, -8)
    titleBarBottom.Size = UDim2.new(1, 0, 0, 8)
    titleBarBottom.Parent = window.titleBar
    
    -- Window Title
    window.titleLabel = Instance.new("TextLabel")
    window.titleLabel.Name = "Title"
    window.titleLabel.BackgroundTransparency = 1
    window.titleLabel.Position = UDim2.new(0, 15, 0, 0)
    window.titleLabel.Size = UDim2.new(1, -100, 1, 0)
    window.titleLabel.Font = window.theme.FontBold
    window.titleLabel.Text = window.title
    window.titleLabel.TextColor3 = window.theme.Text
    window.titleLabel.TextSize = 16
    window.titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    window.titleLabel.Parent = window.titleBar
    
    -- Window Controls Container
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Name = "Controls"
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.Position = UDim2.new(1, -80, 0, 8)
    controlsFrame.Size = UDim2.new(0, 72, 0, 24)
    controlsFrame.Parent = window.titleBar
    
    local controlsLayout = Instance.new("UIListLayout")
    controlsLayout.FillDirection = Enum.FillDirection.Horizontal
    controlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    controlsLayout.Padding = UDim.new(0, 4)
    controlsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    controlsLayout.Parent = controlsFrame
    
    -- Minimize Button
    if window.minimizable then
        window.minimizeBtn = self:_createWindowControl(controlsFrame, "−", window.theme.Warning, function()
            self:_minimizeWindow(window)
        end)
        window.minimizeBtn.LayoutOrder = 1
    end
    
    -- Close Button
    if window.closable then
        window.closeBtn = self:_createWindowControl(controlsFrame, "×", window.theme.Error, function()
            self:_closeWindow(window)
        end)
        window.closeBtn.LayoutOrder = 2
    end
    
    -- Content Area
    window.content = Instance.new("ScrollingFrame")
    window.content.Name = "Content"
    window.content.BackgroundColor3 = window.theme.Background
    window.content.BackgroundTransparency = 0.02
    window.content.BorderSizePixel = 0
    window.content.Position = UDim2.new(0, 0, 0, 40)
    window.content.Size = UDim2.new(1, 0, 1, -40)
    window.content.CanvasSize = UDim2.new(0, 0, 0, 0)
    window.content.ScrollBarThickness = 6
    window.content.ScrollBarImageColor3 = window.theme.Accent
    window.content.Parent = window.frame
    
    createCorner(window.content, UDim.new(0, 8))
    
    -- Content Layout
    window.layout = Instance.new("UIListLayout")
    window.layout.Padding = UDim.new(0, 10)
    window.layout.SortOrder = Enum.SortOrder.LayoutOrder
    window.layout.Parent = window.content
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 15)
    contentPadding.PaddingBottom = UDim.new(0, 15)
    contentPadding.PaddingLeft = UDim.new(0, 15)
    contentPadding.PaddingRight = UDim.new(0, 15)
    contentPadding.Parent = window.content
    
    -- Make draggable
    self:_makeDraggable(window.frame, window.titleBar)
    
    -- Auto-resize content
    local function updateCanvasSize()
        window.content.CanvasSize = UDim2.new(0, 0, 0, window.layout.AbsoluteContentSize.Y + 30)
    end
    
    window.layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
    updateCanvasSize()
    
    -- Add to windows list
    table.insert(self.windows, window)
    
    -- Animations
    ANIMATIONS.SlideIn(window.frame, "up", 0.4)
    ANIMATIONS.FadeIn(window.frame, 0.3)
    
    -- Voice feedback
    self.voice:announce("window_open", window.title)
    playSound("WindowOpen")
    
    return window
end

function GuiLibrary:_createWindowControl(parent, text, color, callback)
    local button = Instance.new("TextButton")
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.BorderSizePixel = 0
    button.Size = UDim2.new(0, 24, 0, 24)
    button.Font = self.theme.FontBold
    button.Text = text
    button.TextColor3 = color
    button.TextSize = 14
    button.Parent = parent
    
    createCorner(button, UDim.new(0, 4))
    
    -- Hover effects
    button.MouseEnter:Connect(function()
        createTween(button, {BackgroundColor3 = color}, 0.2)
        createTween(button, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
        playSound("Hover", 0.2)
    end)
    
    button.MouseLeave:Connect(function()
        createTween(button, {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}, 0.2)
        createTween(button, {TextColor3 = color}, 0.2)
    end)
    
    button.MouseButton1Click:Connect(function()
        ANIMATIONS.Bounce(button, 0.9, 0.2)
        playSound("Click")
        if callback then callback() end
    end)
    
    return button
end

function GuiLibrary:_minimizeWindow(window)
    if window.minimized then
        -- Restore window
        createTween(window.frame, {Size = window.originalSize}, 0.3)
        createTween(window.content, {Size = UDim2.new(1, 0, 1, -40)}, 0.3)
        window.minimized = false
        window.minimizeBtn.Text = "−"
        self.voice:announce("window_restore", window.title)
    else
        -- Minimize window
        window.originalSize = window.frame.Size
        createTween(window.frame, {Size = UDim2.new(window.frame.Size.X.Scale, window.frame.Size.X.Offset, 0, 40)}, 0.3)
        createTween(window.content, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
        window.minimized = true
        window.minimizeBtn.Text = "□"
        self.voice:announce("window_minimize", window.title)
    end
    
    playSound("Click")
end

function GuiLibrary:_closeWindow(window)
    ANIMATIONS.SlideIn(window.frame, "down", 0.3)
    ANIMATIONS.FadeOut(window.frame, 0.3)
    
    wait(0.3)
    window.frame:Destroy()
    
    -- Remove from windows list
    for i, w in pairs(self.windows) do
        if w == window then
            table.remove(self.windows, i)
            break
        end
    end
    
    self.voice:announce("window_close", window.title)
    playSound("WindowClose")
end

function GuiLibrary:_makeDraggable(frame, dragHandle)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    dragHandle.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Button Component
function GuiLibrary:createButton(parent, options)
    options = options or {}
    
    local button = {
        text = options.text or "Button",
        size = options.size or UDim2.new(0, 120, 0, 35),
        position = options.position or UDim2.new(0, 0, 0, 0),
        style = options.style or "primary", -- primary, secondary, success, warning, error
        disabled = options.disabled or false,
        callback = options.callback or function() end
    }
    
    -- Color scheme based on style
    local colors = {
        primary = {self.theme.Accent, self.theme.AccentHover},
        secondary = {self.theme.Secondary, self.theme.Border},
        success = {self.theme.Success, Color3.fromRGB(39, 174, 96)},
        warning = {self.theme.Warning, Color3.fromRGB(230, 126, 34)},
        error = {self.theme.Error, Color3.fromRGB(192, 57, 43)}
    }
    
    local colorSet = colors[button.style] or colors.primary
    
    -- Button Frame
    button.frame = Instance.new("TextButton")
    button.frame.Name = "Button_" .. button.text
    button.frame.BackgroundColor3 = button.disabled and self.theme.Border or colorSet[1]
    button.frame.BorderSizePixel = 0
    button.frame.Position = button.position
    button.frame.Size = button.size
    button.frame.Font = self.theme.FontBold
    button.frame.Text = button.text
    button.frame.TextColor3 = button.disabled and self.theme.TextSecondary or self.theme.Text
    button.frame.TextSize = 14
    button.frame.ZIndex = 5
    button.frame.Parent = parent.content or parent
    
    createCorner(button.frame, self.theme.CornerRadius)
    
    if not button.disabled then
        createStroke(button.frame, 1, Color3.fromRGB(255, 255, 255))
        button.frame.UIStroke.Transparency = 0.9
    end
    
    -- Ripple Effect Container
    local rippleContainer = Instance.new("Frame")
    rippleContainer.BackgroundTransparency = 1
    rippleContainer.Size = UDim2.new(1, 0, 1, 0)
    rippleContainer.ClipsDescendants = true
    rippleContainer.Parent = button.frame
    
    createCorner(rippleContainer, self.theme.CornerRadius)
    
    -- Button interactions
    if not button.disabled then
        button.frame.MouseEnter:Connect(function()
            createTween(button.frame, {BackgroundColor3 = colorSet[2]}, 0.2)
            createTween(button.frame.UIStroke, {Transparency = 0.7}, 0.2)
            playSound("Hover", 0.3)
            
            -- Subtle scale effect
            createTween(button.frame, {Size = button.size * 1.02}, 0.1)
        end)
        
        button.frame.MouseLeave:Connect(function()
            createTween(button.frame, {BackgroundColor3 = colorSet[1]}, 0.2)
            createTween(button.frame.UIStroke, {Transparency = 0.9}, 0.2)
            createTween(button.frame, {Size = button.size}, 0.1)
        end)
        
        button.frame.MouseButton1Click:Connect(function()
            -- Ripple effect
            self:_createRipple(rippleContainer, UserInputService:GetMouseLocation())
            
            -- Button press animation
            createTween(button.frame, {Size = button.size * 0.96}, 0.05):andThen(function()
                createTween(button.frame, {Size = button.size}, 0.1)
            end)
            
            playSound("Click")
            self.voice:announce("button_click", button.text)
            
            if button.callback then
                button.callback()
            end
        end)
    end
    
    -- Add update methods
    function button:setText(newText)
        self.text = newText
        self.frame.Text = newText
    end
    
    function button:setDisabled(disabled)
        self.disabled = disabled
        self.frame.BackgroundColor3 = disabled and self.theme.Border or colorSet[1]
        self.frame.TextColor3 = disabled and self.theme.TextSecondary or self.theme.Text
    end
    
    function button:destroy()
        self.frame:Destroy()
    end
    
    table.insert(self.components, button)
    return button
end

function GuiLibrary:_createRipple(container, mousePos)
    local ripple = Instance.new("Frame")
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.8
    ripple.BorderSizePixel = 0
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0, mousePos.X - container.AbsolutePosition.X, 0, mousePos.Y - container.AbsolutePosition.Y)
    ripple.ZIndex = 10
    ripple.Parent = container
    
    createCorner(ripple, UDim.new(1, 0))
    
    -- Animate ripple
    local maxSize = math.max(container.AbsoluteSize.X, container.AbsoluteSize.Y) * 2
    
    createTween(ripple, {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        Position = UDim2.new(0, mousePos.X - container.AbsolutePosition.X - maxSize/2, 0, mousePos.Y - container.AbsolutePosition.Y - maxSize/2),
        BackgroundTransparency = 1
    }, 0.5)
    
    wait(0.5)
    ripple:Destroy()
end

-- Slider Component
function GuiLibrary:createSlider(parent, options)
    options = options or {}
    
    local slider = {
        label = options.label or "Slider",
        min = options.min or 0,
        max = options.max or 100,
        value = options.value or 50,
        step = options.step or 1,
        suffix = options.suffix or "",
        size = options.size or UDim2.new(1, -30, 0, 50),
        position = options.position or UDim2.new(0, 0, 0, 0),
        callback = options.callback or function() end
    }
    
    -- Main Container
    slider.container = Instance.new("Frame")
    slider.container.Name = "Slider_" .. slider.label
    slider.container.BackgroundTransparency = 1
    slider.container.Position = slider.position
    slider.container.Size = slider.size
    slider.container.Parent = parent.content or parent
    
    -- Label
    slider.labelFrame = Instance.new("TextLabel")
    slider.labelFrame.BackgroundTransparency = 1
    slider.labelFrame.Size = UDim2.new(1, 0, 0, 20)
    slider.labelFrame.Font = self.theme.Font
    slider.labelFrame.Text = slider.label
    slider.labelFrame.TextColor3 = self.theme.Text
    slider.labelFrame.TextSize = 14
    slider.labelFrame.TextXAlignment = Enum.TextXAlignment.Left
    slider.labelFrame.Parent = slider.container
    
    -- Value Display
    slider.valueLabel = Instance.new("TextLabel")
    slider.valueLabel.BackgroundTransparency = 1
    slider.valueLabel.Position = UDim2.new(1, 0, 0, 0)
    slider.valueLabel.Size = UDim2.new(0, 0, 0, 20)
    slider.valueLabel.Font = self.theme.FontBold
    slider.valueLabel.Text = tostring(slider.value) .. slider.suffix
    slider.valueLabel.TextColor3 = self.theme.Accent
    slider.valueLabel.TextSize = 14
    slider.valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    slider.valueLabel.Parent = slider.container
    
    -- Track Background
    slider.track = Instance.new("Frame")
    slider.track.BackgroundColor3 = self.theme.Secondary
    slider.track.BorderSizePixel = 0
    slider.track.Position = UDim2.new(0, 0, 0, 25)
    slider.track.Size = UDim2.new(1, 0, 0, 6)
    slider.track.Parent = slider.container
    
    createCorner(slider.track, UDim.new(0, 3))
    
    -- Progress Fill
    slider.fill = Instance.new("Frame")
    slider.fill.BackgroundColor3 = self.theme.Accent
    slider.fill.BorderSizePixel = 0
    slider.fill.Size = UDim2.new((slider.value - slider.min) / (slider.max - slider.min), 0, 1, 0)
    slider.fill.Parent = slider.track
    
    createCorner(slider.fill, UDim.new(0, 3))
    
    -- Thumb/Handle
    slider.thumb = Instance.new("Frame")
    slider.thumb.BackgroundColor3 = self.theme.Text
    slider.thumb.BorderSizePixel = 0
    slider.thumb.Position = UDim2.new((slider.value - slider.min) / (slider.max - slider.min), -8, 0.5, -8)
    slider.thumb.Size = UDim2.new(0, 16, 0, 16)
    slider.thumb.ZIndex = 5
    slider.thumb.Parent = slider.track
    
    createCorner(slider.thumb, UDim.new(1, 0))
    addDropShadow(slider.thumb, 8, {X = 0, Y = 2}, Color3.fromRGB(0, 0, 0), 0.4)
    
    -- Thumb glow effect
    local thumbGlow = Instance.new("Frame")
    thumbGlow.BackgroundColor3 = self.theme.Accent
    thumbGlow.BackgroundTransparency = 0.8
    thumbGlow.BorderSizePixel = 0
    thumbGlow.Position = UDim2.new(0.5, -12, 0.5, -12)
    thumbGlow.Size = UDim2.new(0, 24, 0, 24)
    thumbGlow.ZIndex = 4
    thumbGlow.Visible = false
    thumbGlow.Parent = slider.track
    
    createCorner(thumbGlow, UDim.new(1, 0))
    
    -- Interaction handling
    local dragging = false
    
    local function updateSlider(input)
        local mouseX = input.Position.X
        local trackPos = slider.track.AbsolutePosition.X
        local trackSize = slider.track.AbsoluteSize.X
        
        local percent = math.clamp((mouseX - trackPos) / trackSize, 0, 1)
        local newValue = slider.min + (slider.max - slider.min) * percent
        
        -- Snap to step
        newValue = math.floor(newValue / slider.step + 0.5) * slider.step
        newValue = math.clamp(newValue, slider.min, slider.max)
        
        if newValue ~= slider.value then
            slider.value = newValue
            
            -- Update UI
            local fillPercent = (slider.value - slider.min) / (slider.max - slider.min)
            createTween(slider.fill, {Size = UDim2.new(fillPercent, 0, 1, 0)}, 0.1)
            createTween(slider.thumb, {Position = UDim2.new(fillPercent, -8, 0.5, -8)}, 0.1)
            
            slider.valueLabel.Text = tostring(slider.value) .. slider.suffix
            
            playSound("Slide", 0.3)
            
            if slider.callback then
                slider.callback(slider.value)
            end
        end
    end
    
    -- Mouse interactions
    slider.track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            thumbGlow.Visible = true
            createTween(thumbGlow, {BackgroundTransparency = 0.6}, 0.2)
            createTween(slider.thumb, {Size = UDim2.new(0, 18, 0, 18)}, 0.2)
            updateSlider(input)
        end
    end)
    
    slider.track.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
            dragging = false
            createTween(thumbGlow, {BackgroundTransparency = 1}, 0.2):andThen(function()
                thumbGlow.Visible = false
            end)
            createTween(slider.thumb, {Size = UDim2.new(0, 16, 0, 16)}, 0.2)
            
            self.voice:announce("slider_change", slider.label)
        end
    end)
    
    -- Add update methods
    function slider:setValue(newValue)
        self.value = math.clamp(newValue, self.min, self.max)
        local fillPercent = (self.value - self.min) / (self.max - self.min)
        
        createTween(self.fill, {Size = UDim2.new(fillPercent, 0, 1, 0)}, 0.2)
        createTween(self.thumb, {Position = UDim2.new(fillPercent, -8, 0.5, -8)}, 0.2)
        
        self.valueLabel.Text = tostring(self.value) .. self.suffix
        
        if self.callback then
            self.callback(self.value)
        end
    end
    
    function slider:setRange(min, max)
        self.min = min
        self.max = max
        self:setValue(math.clamp(self.value, min, max))
    end
    
    function slider:destroy()
        self.container:Destroy()
    end
    
    table.insert(self.components, slider)
    return slider
end

-- Toggle/Switch Component
function GuiLibrary:createToggle(parent, options)
    options = options or {}
    
    local toggle = {
        label = options.label or "Toggle",
        value = options.value or false,
        size = options.size or UDim2.new(1, -30, 0, 35),
        position = options.position or UDim2.new(0, 0, 0, 0),
        callback = options.callback or function() end
    }
    
    -- Main Container
    toggle.container = Instance.new("Frame")
    toggle.container.Name = "Toggle_" .. toggle.label
    toggle.container.BackgroundTransparency = 1
    toggle.container.Position = toggle.position
    toggle.container.Size = toggle.size
    toggle.container.Parent = parent.content or parent
    
    -- Label
    toggle.labelFrame = Instance.new("TextLabel")
    toggle.labelFrame.BackgroundTransparency = 1
    toggle.labelFrame.Size = UDim2.new(1, -60, 1, 0)
    toggle.labelFrame.Font = self.theme.Font
    toggle.labelFrame.Text = toggle.label
    toggle.labelFrame.TextColor3 = self.theme.Text
    toggle.labelFrame.TextSize = 14
    toggle.labelFrame.TextXAlignment = Enum.TextXAlignment.Left
    toggle.labelFrame.TextYAlignment = Enum.TextYAlignment.Center
    toggle.labelFrame.Parent = toggle.container
    
    -- Switch Background
    toggle.switch = Instance.new("TextButton")
    toggle.switch.BackgroundColor3 = toggle.value and self.theme.Accent or self.theme.Secondary
    toggle.switch.BorderSizePixel = 0
    toggle.switch.Position = UDim2.new(1, -50, 0.5, -12)
    toggle.switch.Size = UDim2.new(0, 50, 0, 24)
    toggle.switch.Text = ""
    toggle.switch.Parent = toggle.container
    
    createCorner(toggle.switch, UDim.new(0, 12))
    
    -- Switch Thumb
    toggle.thumb = Instance.new("Frame")
    toggle.thumb.BackgroundColor3 = self.theme.Text
    toggle.thumb.BorderSizePixel = 0
    toggle.thumb.Position = toggle.value and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    toggle.thumb.Size = UDim2.new(0, 20, 0, 20)
    toggle.thumb.ZIndex = 5
    toggle.thumb.Parent = toggle.switch
    
    createCorner(toggle.thumb, UDim.new(1, 0))
    addDropShadow(toggle.thumb, 6, {X = 0, Y = 1}, Color3.fromRGB(0, 0, 0), 0.3)
    
    -- Interaction
    toggle.switch.MouseButton1Click:Connect(function()
        toggle.value = not toggle.value
        
        -- Animate switch
        local newThumbPos = toggle.value and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        local newSwitchColor = toggle.value and self.theme.Accent or self.theme.Secondary
        
        createTween(toggle.thumb, {Position = newThumbPos}, 0.2)
        createTween(toggle.switch, {BackgroundColor3 = newSwitchColor}, 0.2)
        
        -- Bounce effect
        createTween(toggle.thumb, {Size = UDim2.new(0, 22, 0, 22)}, 0.1):andThen(function()
            createTween(toggle.thumb, {Size = UDim2.new(0, 20, 0, 20)}, 0.1)
        end)
        
        playSound("Switch")
        self.voice:announce(toggle.value and "toggle_on" or "toggle_off", toggle.label)
        
        if toggle.callback then
            toggle.callback(toggle.value)
        end
    end)
    
    -- Hover effects
    toggle.switch.MouseEnter:Connect(function()
        createTween(toggle.switch, {Size = UDim2.new(0, 52, 0, 26)}, 0.2)
        playSound("Hover", 0.2)
    end)
    
    toggle.switch.MouseLeave:Connect(function()
        createTween(toggle.switch, {Size = UDim2.new(0, 50, 0, 24)}, 0.2)
    end)
    
    -- Add update methods
    function toggle:setValue(newValue)
        self.value = newValue
        
        local newThumbPos = self.value and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        local newSwitchColor = self.value and self.theme.Accent or self.theme.Secondary
        
        createTween(self.thumb, {Position = newThumbPos}, 0.2)
        createTween(self.switch, {BackgroundColor3 = newSwitchColor}, 0.2)
        
        if self.callback then
            self.callback(self.value)
        end
    end
    
    function toggle:destroy()
        self.container:Destroy()
    end
    
    table.insert(self.components, toggle)
    return toggle
end

-- Label Component
function GuiLibrary:createLabel(parent, options)
    options = options or {}
    
    local label = {
        text = options.text or "Label",
        size = options.size or UDim2.new(1, -30, 0, 25),
        position = options.position or UDim2.new(0, 0, 0, 0),
        textSize = options.textSize or 14,
        textColor = options.textColor or self.theme.Text,
        alignment = options.alignment or "left" -- left, center, right
    }
    
    -- Label Frame
    label.frame = Instance.new("TextLabel")
    label.frame.Name = "Label_" .. label.text:sub(1, 10)
    label.frame.BackgroundTransparency = 1
    label.frame.Position = label.position
    label.frame.Size = label.size
    label.frame.Font = self.theme.Font
    label.frame.Text = label.text
    label.frame.TextColor3 = label.textColor
    label.frame.TextSize = label.textSize
    label.frame.TextWrapped = true
    label.frame.Parent = parent.content or parent
    
    -- Set alignment
    if label.alignment == "center" then
        label.frame.TextXAlignment = Enum.TextXAlignment.Center
    elseif label.alignment == "right" then
        label.frame.TextXAlignment = Enum.TextXAlignment.Right
    else
        label.frame.TextXAlignment = Enum.TextXAlignment.Left
    end
    
    -- Add update methods
    function label:setText(newText)
        self.text = newText
        self.frame.Text = newText
    end
    
    function label:setColor(newColor)
        self.textColor = newColor
        self.frame.TextColor3 = newColor
    end
    
    function label:destroy()
        self.frame:Destroy()
    end
    
    table.insert(self.components, label)
    return label
end

-- Textbox Component
function GuiLibrary:createTextbox(parent, options)
    options = options or {}
    
    local textbox = {
        label = options.label or "Textbox",
        placeholder = options.placeholder or "Enter text...",
        value = options.value or "",
        size = options.size or UDim2.new(1, -30, 0, 60),
        position = options.position or UDim2.new(0, 0, 0, 0),
        multiline = options.multiline or false,
        callback = options.callback or function() end
    }
    
    -- Main Container
    textbox.container = Instance.new("Frame")
    textbox.container.Name = "Textbox_" .. textbox.label
    textbox.container.BackgroundTransparency = 1
    textbox.container.Position = textbox.position
    textbox.container.Size = textbox.size
    textbox.container.Parent = parent.content or parent
    
    -- Label
    if textbox.label ~= "" then
        textbox.labelFrame = Instance.new("TextLabel")
        textbox.labelFrame.BackgroundTransparency = 1
        textbox.labelFrame.Size = UDim2.new(1, 0, 0, 20)
        textbox.labelFrame.Font = self.theme.Font
        textbox.labelFrame.Text = textbox.label
        textbox.labelFrame.TextColor3 = self.theme.Text
        textbox.labelFrame.TextSize = 14
        textbox.labelFrame.TextXAlignment = Enum.TextXAlignment.Left
        textbox.labelFrame.Parent = textbox.container
    end
    
    -- Input Background
    local inputY = textbox.label ~= "" and 25 or 0
    local inputHeight = textbox.size.Y.Offset - inputY
    
    textbox.inputFrame = Instance.new("Frame")
    textbox.inputFrame.BackgroundColor3 = self.theme.Secondary
    textbox.inputFrame.BorderSizePixel = 0
    textbox.inputFrame.Position = UDim2.new(0, 0, 0, inputY)
    textbox.inputFrame.Size = UDim2.new(1, 0, 0, inputHeight)
    textbox.inputFrame.Parent = textbox.container
    
    createCorner(textbox.inputFrame, self.theme.CornerRadius)
    createStroke(textbox.inputFrame, 1, self.theme.Border)
    
    -- Input Field
    if textbox.multiline then
        textbox.input = Instance.new("TextBox")
        textbox.input.BackgroundTransparency = 1
        textbox.input.Position = UDim2.new(0, 10, 0, 5)
        textbox.input.Size = UDim2.new(1, -20, 1, -10)
        textbox.input.Font = self.theme.Font
        textbox.input.Text = textbox.value
        textbox.input.PlaceholderText = textbox.placeholder
        textbox.input.TextColor3 = self.theme.Text
        textbox.input.PlaceholderColor3 = self.theme.TextSecondary
        textbox.input.TextSize = 14
        textbox.input.TextXAlignment = Enum.TextXAlignment.Left
        textbox.input.TextYAlignment = Enum.TextYAlignment.Top
        textbox.input.TextWrapped = true
        textbox.input.MultiLine = true
        textbox.input.ClearTextOnFocus = false
        textbox.input.Parent = textbox.inputFrame
    else
        textbox.input = Instance.new("TextBox")
        textbox.input.BackgroundTransparency = 1
        textbox.input.Position = UDim2.new(0, 10, 0, 0)
        textbox.input.Size = UDim2.new(1, -20, 1, 0)
        textbox.input.Font = self.theme.Font
        textbox.input.Text = textbox.value
        textbox.input.PlaceholderText = textbox.placeholder
        textbox.input.TextColor3 = self.theme.Text
        textbox.input.PlaceholderColor3 = self.theme.TextSecondary
        textbox.input.TextSize = 14
        textbox.input.TextXAlignment = Enum.TextXAlignment.Left
        textbox.input.ClearTextOnFocus = false
        textbox.input.Parent = textbox.inputFrame
    end
    
    -- Focus effects
    textbox.input.Focused:Connect(function()
        createTween(textbox.inputFrame.UIStroke, {Color = self.theme.Accent}, 0.2)
        createTween(textbox.inputFrame.UIStroke, {Thickness = 2}, 0.2)
        playSound("Type", 0.3)
    end)
    
    textbox.input.FocusLost:Connect(function()
        createTween(textbox.inputFrame.UIStroke, {Color = self.theme.Border}, 0.2)
        createTween(textbox.inputFrame.UIStroke, {Thickness = 1}, 0.2)
        
        textbox.value = textbox.input.Text
        
        if textbox.callback then
            textbox.callback(textbox.value)
        end
    end)
    
    -- Typing sound effect
    local lastTextLength = #textbox.input.Text
    textbox.input:GetPropertyChangedSignal("Text"):Connect(function()
        local currentLength = #textbox.input.Text
        if currentLength ~= lastTextLength then
            playSound("Type", 0.1)
            lastTextLength = currentLength
        end
    end)
    
    -- Add update methods
    function textbox:setValue(newValue)
        self.value = newValue
        self.input.Text = newValue
    end
    
    function textbox:getValue()
        return self.input.Text
    end
    
    function textbox:destroy()
        self.container:Destroy()
    end
    
    table.insert(self.components, textbox)
    return textbox
end

-- Dropdown Component
function GuiLibrary:createDropdown(parent, options)
    options = options or {}
    
    local dropdown = {
        label = options.label or "Dropdown",
        options = options.options or {"Option 1", "Option 2", "Option 3"},
        selected = options.selected or options.options[1],
        size = options.size or UDim2.new(1, -30, 0, 60),
        position = options.position or UDim2.new(0, 0, 0, 0),
        callback = options.callback or function() end,
        open = false
    }
    
    -- Main Container
    dropdown.container = Instance.new("Frame")
    dropdown.container.Name = "Dropdown_" .. dropdown.label
    dropdown.container.BackgroundTransparency = 1
    dropdown.container.Position = dropdown.position
    dropdown.container.Size = dropdown.size
    dropdown.container.ZIndex = 1
    dropdown.container.Parent = parent.content or parent
    
    -- Label
    dropdown.labelFrame = Instance.new("TextLabel")
    dropdown.labelFrame.BackgroundTransparency = 1
    dropdown.labelFrame.Size = UDim2.new(1, 0, 0, 20)
    dropdown.labelFrame.Font = self.theme.Font
    dropdown.labelFrame.Text = dropdown.label
    dropdown.labelFrame.TextColor3 = self.theme.Text
    dropdown.labelFrame.TextSize = 14
    dropdown.labelFrame.TextXAlignment = Enum.TextXAlignment.Left
    dropdown.labelFrame.Parent = dropdown.container
    
    -- Dropdown Button
    dropdown.button = Instance.new("TextButton")
    dropdown.button.BackgroundColor3 = self.theme.Secondary
    dropdown.button.BorderSizePixel = 0
    dropdown.button.Position = UDim2.new(0, 0, 0, 25)
    dropdown.button.Size = UDim2.new(1, 0, 0, 35)
    dropdown.button.Font = self.theme.Font
    dropdown.button.Text = "  " .. dropdown.selected
    dropdown.button.TextColor3 = self.theme.Text
    dropdown.button.TextSize = 14
    dropdown.button.TextXAlignment = Enum.TextXAlignment.Left
    dropdown.button.ZIndex = 2
    dropdown.button.Parent = dropdown.container
    
    createCorner(dropdown.button, self.theme.CornerRadius)
    createStroke(dropdown.button, 1, self.theme.Border)
    
    -- Dropdown Arrow
    dropdown.arrow = Instance.new("TextLabel")
    dropdown.arrow.BackgroundTransparency = 1
    dropdown.arrow.Position = UDim2.new(1, -30, 0, 0)
    dropdown.arrow.Size = UDim2.new(0, 30, 1, 0)
    dropdown.arrow.Font = self.theme.FontBold
    dropdown.arrow.Text = "▼"
    dropdown.arrow.TextColor3 = self.theme.TextSecondary
    dropdown.arrow.TextSize = 12
    dropdown.arrow.ZIndex = 3
    dropdown.arrow.Parent = dropdown.button
    
    -- Options Container
    dropdown.optionsFrame = Instance.new("ScrollingFrame")
    dropdown.optionsFrame.BackgroundColor3 = self.theme.Secondary
    dropdown.optionsFrame.BorderSizePixel = 0
    dropdown.optionsFrame.Position = UDim2.new(0, 0, 1, 2)
    dropdown.optionsFrame.Size = UDim2.new(1, 0, 0, math.min(#dropdown.options * 35, 140))
    dropdown.optionsFrame.CanvasSize = UDim2.new(0, 0, 0, #dropdown.options * 35)
    dropdown.optionsFrame.ScrollBarThickness = 4
    dropdown.optionsFrame.ScrollBarImageColor3 = self.theme.Accent
    dropdown.optionsFrame.Visible = false
    dropdown.optionsFrame.ZIndex = 10
    dropdown.optionsFrame.Parent = dropdown.button
    
    createCorner(dropdown.optionsFrame, self.theme.CornerRadius)
    createStroke(dropdown.optionsFrame, 1, self.theme.Border)
    addDropShadow(dropdown.optionsFrame, 20, {X = 0, Y = 5}, Color3.fromRGB(0, 0, 0), 0.2)
    
    -- Options Layout
    local optionsLayout = Instance.new("UIListLayout")
    optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optionsLayout.Parent = dropdown.optionsFrame
    
    -- Create option buttons
    dropdown.optionButtons = {}
    for i, option in pairs(dropdown.options) do
        local optionButton = Instance.new("TextButton")
        optionButton.BackgroundColor3 = self.theme.Secondary
        optionButton.BorderSizePixel = 0
        optionButton.Size = UDim2.new(1, 0, 0, 35)
        optionButton.Font = self.theme.Font
        optionButton.Text = "  " .. option
        optionButton.TextColor3 = self.theme.Text
        optionButton.TextSize = 14
        optionButton.TextXAlignment = Enum.TextXAlignment.Left
        optionButton.ZIndex = 11
        optionButton.LayoutOrder = i
        optionButton.Parent = dropdown.optionsFrame
        
        -- Hover effect
        optionButton.MouseEnter:Connect(function()
            createTween(optionButton, {BackgroundColor3 = self.theme.Accent}, 0.2)
            playSound("Hover", 0.2)
        end)
        
        optionButton.MouseLeave:Connect(function()
            createTween(optionButton, {BackgroundColor3 = self.theme.Secondary}, 0.2)
        end)
        
        -- Click handler
        optionButton.MouseButton1Click:Connect(function()
            dropdown.selected = option
            dropdown.button.Text = "  " .. option
            
            -- Close dropdown
            dropdown:toggle()
            
            playSound("Click")
            
            if dropdown.callback then
                dropdown.callback(option, i)
            end
        end)
        
        table.insert(dropdown.optionButtons, optionButton)
    end
    
    -- Toggle function
    function dropdown:toggle()
        self.open = not self.open
        
        if self.open then
            self.optionsFrame.Visible = true
            createTween(self.arrow, {Rotation = 180}, 0.2)
            createTween(self.optionsFrame, {Size = UDim2.new(1, 0, 0, math.min(#self.options * 35, 140))}, 0.3)
            
            playSound("Dropdown")
            self.voice:announce("dropdown_open", self.label)
        else
            createTween(self.arrow, {Rotation = 0}, 0.2)
            createTween(self.optionsFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2):andThen(function()
                self.optionsFrame.Visible = false
            end)
            
            self.voice:announce("dropdown_close", self.label)
        end
    end
    
    -- Main button click
    dropdown.button.MouseButton1Click:Connect(function()
        dropdown:toggle()
    end)
    
    -- Hover effects on main button
    dropdown.button.MouseEnter:Connect(function()
        createTween(dropdown.button.UIStroke, {Color = self.theme.Accent}, 0.2)
        playSound("Hover", 0.3)
    end)
    
    dropdown.button.MouseLeave:Connect(function()
        createTween(dropdown.button.UIStroke, {Color = self.theme.Border}, 0.2)
    end)
    
    -- Close when clicking outside
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dropdown.open then
            local mousePos = UserInputService:GetMouseLocation()
            local buttonPos = dropdown.button.AbsolutePosition
            local buttonSize = dropdown.button.AbsoluteSize
            local optionsPos = dropdown.optionsFrame.AbsolutePosition
            local optionsSize = dropdown.optionsFrame.AbsoluteSize
            
            -- Check if click is outside dropdown area
            if not (mousePos.X >= buttonPos.X and mousePos.X <= buttonPos.X + buttonSize.X and
                    mousePos.Y >= buttonPos.Y and mousePos.Y <= optionsPos.Y + optionsSize.Y) then
                dropdown:toggle()
            end
        end
    end)
    
    -- Add update methods
    function dropdown:setSelected(option)
        if table.find(self.options, option) then
            self.selected = option
            self.button.Text = "  " .. option
            
            if self.callback then
                self.callback(option, table.find(self.options, option))
            end
        end
    end
    
    function dropdown:addOption(option)
        table.insert(self.options, option)
        
        -- Create new option button
        local optionButton = Instance.new("TextButton")
        optionButton.BackgroundColor3 = self.theme.Secondary
        optionButton.BorderSizePixel = 0
        optionButton.Size = UDim2.new(1, 0, 0, 35)
        optionButton.Font = self.theme.Font
        optionButton.Text = "  " .. option
        optionButton.TextColor3 = self.theme.Text
        optionButton.TextSize = 14
        optionButton.TextXAlignment = Enum.TextXAlignment.Left
        optionButton.ZIndex = 11
        optionButton.LayoutOrder = #self.options
        optionButton.Parent = self.optionsFrame
        
        -- Add interactions
        optionButton.MouseEnter:Connect(function()
            createTween(optionButton, {BackgroundColor3 = self.theme.Accent}, 0.2)
            playSound("Hover", 0.2)
        end)
        
        optionButton.MouseLeave:Connect(function()
            createTween(optionButton, {BackgroundColor3 = self.theme.Secondary}, 0.2)
        end)
        
        optionButton.MouseButton1Click:Connect(function()
            self.selected = option
            self.button.Text = "  " .. option
            self:toggle()
            
            playSound("Click")
            
            if self.callback then
                self.callback(option, #self.options)
            end
        end)
        
        table.insert(self.optionButtons, optionButton)
        
        -- Update canvas size
        self.optionsFrame.CanvasSize = UDim2.new(0, 0, 0, #self.options * 35)
    end
    
    function dropdown:destroy()
        self.container:Destroy()
    end
    
    table.insert(self.components, dropdown)
    return dropdown
end

-- Tab System
function GuiLibrary:createTabSystem(parent, options)
    options = options or {}
    
    local tabSystem = {
        tabs = {},
        currentTab = nil,
        size = options.size or UDim2.new(1, -30, 1, -100),
        position = options.position or UDim2.new(0, 0, 0, 0)
    }
    
    -- Main Container
    tabSystem.container = Instance.new("Frame")
    tabSystem.container.Name = "TabSystem"
    tabSystem.container.BackgroundTransparency = 1
    tabSystem.container.Position = tabSystem.position
    tabSystem.container.Size = tabSystem.size
    tabSystem.container.Parent = parent.content or parent
    
    -- Tab Headers Container
    tabSystem.headersFrame = Instance.new("Frame")
    tabSystem.headersFrame.BackgroundColor3 = self.theme.Secondary
    tabSystem.headersFrame.BorderSizePixel = 0
    tabSystem.headersFrame.Size = UDim2.new(1, 0, 0, 40)
    tabSystem.headersFrame.Parent = tabSystem.container
    
    createCorner(tabSystem.headersFrame, UDim.new(0, 8))
    
    -- Headers Layout
    tabSystem.headersLayout = Instance.new("UIListLayout")
    tabSystem.headersLayout.FillDirection = Enum.FillDirection.Horizontal
    tabSystem.headersLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabSystem.headersLayout.Parent = tabSystem.headersFrame
    
    -- Content Container
    tabSystem.contentFrame = Instance.new("Frame")
    tabSystem.contentFrame.BackgroundColor3 = self.theme.Background
    tabSystem.contentFrame.BorderSizePixel = 0
    tabSystem.contentFrame.Position = UDim2.new(0, 0, 0, 45)
    tabSystem.contentFrame.Size = UDim2.new(1, 0, 1, -45)
    tabSystem.contentFrame.Parent = tabSystem.container
    
    createCorner(tabSystem.contentFrame, self.theme.CornerRadius)
    createStroke(tabSystem.contentFrame, 1, self.theme.Border)
    
    -- Add tab method
    function tabSystem:addTab(name, content)
        local tab = {
            name = name,
            active = false,
            content = content or {}
        }
        
        -- Tab Header Button
        tab.header = Instance.new("TextButton")
        tab.header.BackgroundColor3 = self.theme.Secondary
        tab.header.BorderSizePixel = 0
        tab.header.Size = UDim2.new(0, 120, 1, 0)
        tab.header.Font = self.theme.FontBold
        tab.header.Text = name
        tab.header.TextColor3 = self.theme.TextSecondary
        tab.header.TextSize = 14
        tab.header.LayoutOrder = #self.tabs + 1
        tab.header.Parent = self.headersFrame
        
        createCorner(tab.header, UDim.new(0, 8))
        
        -- Tab Content Frame
        tab.contentFrame = Instance.new("ScrollingFrame")
        tab.contentFrame.BackgroundTransparency = 1
        tab.contentFrame.Size = UDim2.new(1, 0, 1, 0)
        tab.contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        tab.contentFrame.ScrollBarThickness = 6
        tab.contentFrame.ScrollBarImageColor3 = self.theme.Accent
        tab.contentFrame.Visible = false
        tab.contentFrame.Parent = self.contentFrame
        
        -- Content Layout
        tab.layout = Instance.new("UIListLayout")
        tab.layout.Padding = UDim.new(0, 10)
        tab.layout.SortOrder = Enum.SortOrder.LayoutOrder
        tab.layout.Parent = tab.contentFrame
        
        local contentPadding = Instance.new("UIPadding")
        contentPadding.PaddingTop = UDim.new(0, 15)
        contentPadding.PaddingBottom = UDim.new(0, 15)
        contentPadding.PaddingLeft = UDim.new(0, 15)
        contentPadding.PaddingRight = UDim.new(0, 15)
        contentPadding.Parent = tab.contentFrame
        
        -- Auto-resize content
        local function updateCanvasSize()
            tab.contentFrame.CanvasSize = UDim2.new(0, 0, 0, tab.layout.AbsoluteContentSize.Y + 30)
        end
        
        tab.layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
        updateCanvasSize()
        
        -- Header click handler
        tab.header.MouseButton1Click:Connect(function()
            self:selectTab(name)
            playSound("Click")
            self.voice:announce("tab_switch", name)
        end)
        
        -- Hover effects
        tab.header.MouseEnter:Connect(function()
            if not tab.active then
                createTween(tab.header, {BackgroundColor3 = self.theme.Border}, 0.2)
            end
            playSound("Hover", 0.2)
        end)
        
        tab.header.MouseLeave:Connect(function()
            if not tab.active then
                createTween(tab.header, {BackgroundColor3 = self.theme.Secondary}, 0.2)
            end
        end)
        
        table.insert(self.tabs, tab)
        
        -- Select first tab automatically
        if #self.tabs == 1 then
            self:selectTab(name)
        end
        
        return tab
    end
    
    -- Select tab method
    function tabSystem:selectTab(name)
        for _, tab in pairs(self.tabs) do
            if tab.name == name then
                -- Activate this tab
                tab.active = true
                tab.contentFrame.Visible = true
                createTween(tab.header, {BackgroundColor3 = self.theme.Accent}, 0.2)
                createTween(tab.header, {TextColor3 = self.theme.Text}, 0.2)
                
                ANIMATIONS.FadeIn(tab.contentFrame, 0.3)
                
                self.currentTab = tab
            else
                -- Deactivate other tabs
                tab.active = false
                tab.contentFrame.Visible = false
                createTween(tab.header, {BackgroundColor3 = self.theme.Secondary}, 0.2)
                createTween(tab.header, {TextColor3 = self.theme.TextSecondary}, 0.2)
            end
        end
    end
    
    function tabSystem:destroy()
        self.container:Destroy()
    end
    
    table.insert(self.components, tabSystem)
    return tabSystem
end

-- Notification System
function GuiLibrary:notify(options)
    options = options or {}
    
    local notification = {
        title = options.title or "Notification",
        message = options.message or "",
        type = options.type or "info", -- info, success, warning, error
        duration = options.duration or 4
    }
    
    -- Color scheme based on type
    local colors = {
        info = self.theme.Accent,
        success = self.theme.Success,
        warning = self.theme.Warning,
        error = self.theme.Error
    }
    
    local color = colors[notification.type] or colors.info
    
    -- Notification Frame
    local notifFrame = Instance.new("Frame")
    notifFrame.BackgroundColor3 = self.theme.Background
    notifFrame.BorderSizePixel = 0
    notifFrame.Size = UDim2.new(1, 0, 0, 80)
    notifFrame.Position = UDim2.new(1, 0, 0, 0) -- Start off-screen
    notifFrame.ZIndex = 100
    notifFrame.Parent = self.notificationFrame
    
    createCorner(notifFrame, self.theme.CornerRadius)
    createStroke(notifFrame, 2, color)
    addDropShadow(notifFrame, 15, {X = 0, Y = 3}, Color3.fromRGB(0, 0, 0), 0.3)
    
    -- Accent bar
    local accentBar = Instance.new("Frame")
    accentBar.BackgroundColor3 = color
    accentBar.BorderSizePixel = 0
    accentBar.Size = UDim2.new(0, 4, 1, 0)
    accentBar.Parent = notifFrame
    
    createCorner(accentBar, UDim.new(0, 2))
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 15, 0, 8)
    titleLabel.Size = UDim2.new(1, -50, 0, 20)
    titleLabel.Font = self.theme.FontBold
    titleLabel.Text = notification.title
    titleLabel.TextColor3 = self.theme.Text
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notifFrame
    
    -- Message
    local messageLabel = Instance.new("TextLabel")
    messageLabel.BackgroundTransparency = 1
    messageLabel.Position = UDim2.new(0, 15, 0, 28)
    messageLabel.Size = UDim2.new(1, -50, 0, 40)
    messageLabel.Font = self.theme.Font
    messageLabel.Text = notification.message
    messageLabel.TextColor3 = self.theme.TextSecondary
    messageLabel.TextSize = 12
    messageLabel.TextWrapped = true
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.Parent = notifFrame
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.BackgroundTransparency = 1
    closeBtn.Position = UDim2.new(1, -30, 0, 5)
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Font = self.theme.FontBold
    closeBtn.Text = "×"
    closeBtn.TextColor3 = self.theme.TextSecondary
    closeBtn.TextSize = 16
    closeBtn.Parent = notifFrame
    
    closeBtn.MouseButton1Click:Connect(function()
        createTween(notifFrame, {Position = UDim2.new(1, 0, 0, 0)}, 0.3)
        wait(0.3)
        notifFrame:Destroy()
    end)
    
    -- Animate in
    createTween(notifFrame, {Position = UDim2.new(0, 0, 0, 0)}, 0.4)
    
    -- Auto close
    if notification.duration > 0 then
        wait(notification.duration)
        createTween(notifFrame, {Position = UDim2.new(1, 0, 0, 0)}, 0.3)
        wait(0.3)
        notifFrame:Destroy()
    end
    
    -- Play sound
    playSound(notification.type == "error" and "Error" or "Success")
end

-- Theme Management
function GuiLibrary:setTheme(themeName, themeData)
    if themeData then
        self.themes[themeName] = themeData
    end
    
    if self.themes[themeName] then
        self.theme = self.themes[themeName]
        
        -- Update all existing components
        for _, component in pairs(self.components) do
            self:_updateComponentTheme(component)
        end
        
        -- Update windows
        for _, window in pairs(self.windows) do
            self:_updateWindowTheme(window)
        end
    end
end

function GuiLibrary:_updateComponentTheme(component)
    -- This would update component colors based on the new theme
    -- Implementation depends on component type
end

function GuiLibrary:_updateWindowTheme(window)
    createTween(window.frame, {BackgroundColor3 = self.theme.Background}, 0.3)
    createTween(window.titleBar, {BackgroundColor3 = self.theme.Secondary}, 0.3)
    createTween(window.titleLabel, {TextColor3 = self.theme.Text}, 0.3)
end

-- Cleanup
function GuiLibrary:destroy()
    if self.screenGui then
        self.screenGui:Destroy()
    end
    
    self.voice:announce("window_close", "library")
    playSound("WindowClose")
end

-- Export the library
return GuiLibrary