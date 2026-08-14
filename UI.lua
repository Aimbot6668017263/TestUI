--[[
    NebulaUI v1.1 - Versão Corrigida
    - Corrigido erro de exibição de "table: 0x..." (adicionado tostring)
    - Corrigido Dropdown e MultiSelect para flutuarem fora da janela (parent em ScreenGui)
]]

local NebulaUI = {}
NebulaUI.__index = NebulaUI

-- Serviços
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Tema
local Theme = {
    Accent      = Color3.fromRGB(100, 180, 255),
    Background  = Color3.fromRGB(13, 13, 18),
    SidebarBG   = Color3.fromRGB(9, 9, 13),
    ElementBG   = Color3.fromRGB(22, 22, 32),
    HoverBG     = Color3.fromRGB(28, 28, 40),
    TopbarBG    = Color3.fromRGB(16, 16, 23),
    Text        = Color3.fromRGB(225, 225, 235),
    SubText     = Color3.fromRGB(110, 110, 135),
    ToggleOn    = Color3.fromRGB(100, 180, 255),
    ToggleOff   = Color3.fromRGB(45, 45, 60),
    Border      = Color3.fromRGB(40, 40, 58),
    SidebarWidth = 72,
    WindowWidth = 380,
    WindowHeight = 440,
    CornerRadius = 14,
}

-- Funções utilitárias
local function CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or Theme.CornerRadius)
    corner.Parent = parent
    return corner
end

local function CreatePadding(parent, top, right, bottom, left)
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, top or 0)
    padding.PaddingRight = UDim.new(0, right or 0)
    padding.PaddingBottom = UDim.new(0, bottom or 0)
    padding.PaddingLeft = UDim.new(0, left or 0)
    padding.Parent = parent
    return padding
end

local function CreateListLayout(parent, gap, direction, horizontalAlignment)
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, gap or 6)
    layout.FillDirection = direction or Enum.FillDirection.Vertical
    layout.HorizontalAlignment = horizontalAlignment or Enum.HorizontalAlignment.Left
    layout.Parent = parent
    return layout
end

local function TweenObject(object, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or 0.2,
        easingStyle or Enum.EasingStyle.Quad,
        easingDirection or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

local function CreateFrame(parent, size, position, color, name)
    local frame = Instance.new("Frame")
    frame.Size = size or UDim2.new(1, 0, 0, 40)
    frame.Position = position or UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = color or Theme.Background
    frame.BorderSizePixel = 0
    frame.Name = tostring(name or "Frame")
    frame.Parent = parent
    return frame
end

local function CreateLabel(parent, text, size, color, name)
    local label = Instance.new("TextLabel")
    label.Size = size or UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = tostring(text or "")
    label.TextColor3 = color or Theme.Text
    label.TextSize = 13
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Name = tostring(name or "Label")
    label.Parent = parent
    return label
end

local function CreateStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Border
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

-- Função principal
function NebulaUI:CreateWindow(windowTitle)
    local Window = {}
    Window.Title = tostring(windowTitle)
    Window.OpenDropdown = nil

    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NebulaUI_" .. Window.Title
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = PlayerGui

    -- Sombra
    local Shadow = Instance.new("ImageLabel")
    Shadow.Size = UDim2.new(0, Theme.WindowWidth + 50, 0, Theme.WindowHeight + 50)
    Shadow.Position = UDim2.new(0.5, -(Theme.WindowWidth + 50) / 2, 0.5, -(Theme.WindowHeight + 50) / 2)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://6014261993"
    Shadow.ImageColor3 = Color3.new(0, 0, 0)
    Shadow.ImageTransparency = 0.55
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    Shadow.ZIndex = 0
    Shadow.Parent = ScreenGui

    -- Janela principal
    local WindowFrame = CreateFrame(
        ScreenGui,
        UDim2.new(0, Theme.WindowWidth, 0, Theme.WindowHeight),
        UDim2.new(0.5, -Theme.WindowWidth / 2, 0.5, -Theme.WindowHeight / 2),
        Theme.Background,
        "Window"
    )
    WindowFrame.ZIndex = 10
    CreateCorner(WindowFrame, Theme.CornerRadius)
    CreateStroke(WindowFrame, Theme.Border, 1)

    -- Topbar
    local Topbar = CreateFrame(WindowFrame, UDim2.new(1, 0, 0, 46), nil, Theme.TopbarBG, "Topbar")
    CreateCorner(Topbar, Theme.CornerRadius)
    CreateFrame(Topbar, UDim2.new(1, 0, 0.5, 0), UDim2.new(0, 0, 0.5, 0), Theme.TopbarBG, "FixBot")
    CreateStroke(Topbar, Theme.Border, 1)

    local AccentBar = CreateFrame(Topbar, UDim2.new(0, 4, 0, 26), UDim2.new(0, 12, 0.5, -13), Theme.Accent, "Accent")
    CreateCorner(AccentBar, 2)

    local TitleLabel = CreateLabel(Topbar, Window.Title, UDim2.new(1, -100, 1, 0), Theme.Text, "Title")
    TitleLabel.Position = UDim2.new(0, 26, 0, 0)
    TitleLabel.TextSize = 15
    TitleLabel.Font = Enum.Font.GothamBold

    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 28, 0, 28)
    CloseButton.Position = UDim2.new(1, -40, 0.5, -14)
    CloseButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.TextSize = 12
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.BorderSizePixel = 0
    CloseButton.Parent = Topbar
    CreateCorner(CloseButton, 7)

    CloseButton.Activated:Connect(function()
        WindowFrame.ClipsDescendants = true
        TweenObject(WindowFrame, { Size = UDim2.new(0, Theme.WindowWidth, 0, 0) }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        TweenObject(Shadow, { ImageTransparency = 1 }, 0.25)
        task.delay(0.35, function()
            ScreenGui:Destroy()
        end)
    end)

    -- Arrastar
    local dragging = false
    local dragStart = nil
    local windowStart = nil

    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            windowStart = WindowFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseMove then return end
        local delta = input.Position - dragStart
        local newPosition = UDim2.new(
            windowStart.X.Scale,
            windowStart.X.Offset + delta.X,
            windowStart.Y.Scale,
            windowStart.Y.Offset + delta.Y
        )
        WindowFrame.Position = newPosition
        Shadow.Position = UDim2.new(newPosition.X.Scale, newPosition.X.Offset - 25, newPosition.Y.Scale, newPosition.Y.Offset - 25)
    end)

    -- Sidebar
    local Sidebar = CreateFrame(
        WindowFrame,
        UDim2.new(0, Theme.SidebarWidth, 1, -46),
        UDim2.new(0, 0, 0, 46),
        Theme.SidebarBG,
        "Sidebar"
    )
    CreateCorner(Sidebar, Theme.CornerRadius)
    CreateFrame(Sidebar, UDim2.new(0.5, 0, 1, 0), UDim2.new(0.5, 0, 0, 0), Theme.SidebarBG, "FixRight")
    CreateStroke(Sidebar, Theme.Border, 1)

    local TabListFrame = CreateFrame(Sidebar, UDim2.new(1, 0, 1, 0), nil, Color3.new(0, 0, 0), "TabList")
    TabListFrame.BackgroundTransparency = 1
    CreateListLayout(TabListFrame, 4, Enum.FillDirection.Vertical, Enum.HorizontalAlignment.Center)
    CreatePadding(TabListFrame, 8, 5, 8, 5)

    -- Área de conteúdo
    local ContentArea = CreateFrame(
        WindowFrame,
        UDim2.new(1, -Theme.SidebarWidth, 1, -46),
        UDim2.new(0, Theme.SidebarWidth, 0, 46),
        Theme.Background,
        "ContentArea"
    )

    local allTabs = {}
    local activeTab = nil

    local function CreateScrollFrame(parent)
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, 0, 1, 0)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 3
        scroll.ScrollBarImageColor3 = Theme.Accent
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.ScrollingDirection = Enum.ScrollingDirection.Y
        scroll.Parent = parent
        CreateListLayout(scroll, 5)
        CreatePadding(scroll, 8, 8, 8, 8)
        return scroll
    end

    local function SelectTab(tab)
        if activeTab == tab then return end
        activeTab = tab
        for _, data in pairs(allTabs) do
            data.content.Visible = false
            TweenObject(data.button, { BackgroundColor3 = Theme.SidebarBG }, 0.15)
            TweenObject(data.label, { TextColor3 = Theme.SubText }, 0.15)
            TweenObject(data.icon, { TextColor3 = Theme.SubText }, 0.15)
            data.indicator.BackgroundTransparency = 1
        end
        tab.content.Visible = true
        TweenObject(tab.button, { BackgroundColor3 = Theme.HoverBG }, 0.15)
        TweenObject(tab.label, { TextColor3 = Theme.Accent }, 0.15)
        TweenObject(tab.icon, { TextColor3 = Theme.Accent }, 0.15)
        tab.indicator.BackgroundTransparency = 0
    end

    -- Funções de elementos (definidas antes de CreateTab)
    local function AddSection(tabData, sectionText)
        if type(sectionText) ~= "string" then
            sectionText = tostring(sectionText)
        end
        local sectionFrame = CreateFrame(tabData.content, UDim2.new(1, 0, 0, 20), nil, Color3.new(0, 0, 0), "Section_" .. sectionText)
        sectionFrame.BackgroundTransparency = 1
        CreateFrame(sectionFrame, UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 0.5, 0), Theme.Border, "Line")
        local labelBackground = CreateFrame(sectionFrame, UDim2.new(0, 0, 1, 0), UDim2.new(0, 6, 0, 0), Theme.Background, "LabelBG")
        labelBackground.AutomaticSize = Enum.AutomaticSize.X
        local sectionLabel = Instance.new("TextLabel")
        sectionLabel.BackgroundTransparency = 1
        sectionLabel.AutomaticSize = Enum.AutomaticSize.X
        sectionLabel.Size = UDim2.new(0, 0, 1, 0)
        sectionLabel.Text = "  " .. sectionText:upper() .. "  "
        sectionLabel.TextColor3 = Theme.SubText
        sectionLabel.TextSize = 10
        sectionLabel.Font = Enum.Font.GothamBold
        sectionLabel.Parent = labelBackground
    end

    local function AddToggle(tabData, labelText, description, default, callback)
        labelText = tostring(labelText)
        if description then description = tostring(description) end
        local state = default or false
        local height = description and 58 or 46
        local container = CreateFrame(tabData.content, UDim2.new(1, 0, 0, height), nil, Theme.ElementBG, "Toggle_" .. labelText)
        CreateCorner(container, 9)
        CreatePadding(container, 8, 10, 8, 10)
        CreateStroke(container, Theme.Border, 1)
        CreateLabel(container, labelText, UDim2.new(1, -60, 0, 16), Theme.Text)
        if description then
            local descLabel = CreateLabel(container, description, UDim2.new(1, -60, 0, 13), Theme.SubText, "Description")
            descLabel.Position = UDim2.new(0, 0, 0, 20)
            descLabel.TextSize = 11
            descLabel.Font = Enum.Font.Gotham
        end
        local hitbox = Instance.new("TextButton")
        hitbox.Size = UDim2.new(1, 0, 1, 0)
        hitbox.BackgroundTransparency = 1
        hitbox.Text = ""
        hitbox.Parent = container
        local track = CreateFrame(hitbox, UDim2.new(0, 42, 0, 24), UDim2.new(1, -42, 0.5, -12), state and Theme.ToggleOn or Theme.ToggleOff, "Track")
        CreateCorner(track, 12)
        local knob = CreateFrame(track, UDim2.new(0, 18, 0, 18), UDim2.new(0, state and 21 or 3, 0.5, -9), Color3.new(1, 1, 1), "Knob")
        CreateCorner(knob, 9)
        local function setState(value)
            state = value
            TweenObject(track, { BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff }, 0.18)
            TweenObject(knob, { Position = UDim2.new(0, state and 21 or 3, 0.5, -9) }, 0.18, Enum.EasingStyle.Back)
            if type(callback) == "function" then callback(state) end
        end
        hitbox.Activated:Connect(function()
            setState(not state)
        end)
        return { Set = setState, Get = function() return state end }
    end

    local function AddSlider(tabData, labelText, minValue, maxValue, defaultValue, callback)
        labelText = tostring(labelText)
        minValue = tonumber(minValue) or 0
        maxValue = tonumber(maxValue) or 100
        defaultValue = tonumber(defaultValue) or minValue
        local currentValue = math.clamp(defaultValue, minValue, maxValue)
        local container = CreateFrame(tabData.content, UDim2.new(1, 0, 0, 58), nil, Theme.ElementBG, "Slider_" .. labelText)
        CreateCorner(container, 9)
        CreatePadding(container, 8, 10, 8, 10)
        CreateStroke(container, Theme.Border, 1)
        local row = CreateFrame(container, UDim2.new(1, 0, 0, 16), nil, Color3.new(0, 0, 0), "Row")
        row.BackgroundTransparency = 1
        CreateLabel(row, labelText, UDim2.new(0.7, 0, 1, 0), Theme.Text).TextSize = 13
        local valueLabel = CreateLabel(row, tostring(currentValue), UDim2.new(0.3, 0, 1, 0), Theme.Accent, "Value")
        valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.TextSize = 13
        valueLabel.Font = Enum.Font.GothamBold
        local track = CreateFrame(container, UDim2.new(1, 0, 0, 5), UDim2.new(0, 0, 0, 30), Color3.fromRGB(35, 35, 50), "Track")
        CreateCorner(track, 3)
        local initialPercent = (currentValue - minValue) / (maxValue - minValue)
        local fill = CreateFrame(track, UDim2.new(initialPercent, 0, 1, 0), nil, Theme.Accent, "Fill")
        CreateCorner(fill, 3)
        local knob = CreateFrame(track, UDim2.new(0, 14, 0, 14), UDim2.new(initialPercent, -7, 0.5, -7), Color3.new(1, 1, 1), "Knob")
        CreateCorner(knob, 7)
        CreateStroke(knob, Theme.Accent, 2)
        local hitbox = Instance.new("TextButton")
        hitbox.Size = UDim2.new(1, 0, 0, 26)
        hitbox.Position = UDim2.new(0, 0, 0, 20)
        hitbox.BackgroundTransparency = 1
        hitbox.Text = ""
        hitbox.Parent = container
        local sliding = false
        local function updateValue(inputX)
            local percent = math.clamp((inputX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            currentValue = math.round(minValue + (maxValue - minValue) * percent)
            local finalPercent = (currentValue - minValue) / (maxValue - minValue)
            fill.Size = UDim2.new(finalPercent, 0, 1, 0)
            knob.Position = UDim2.new(finalPercent, -7, 0.5, -7)
            valueLabel.Text = tostring(currentValue)
            if type(callback) == "function" then callback(currentValue) end
        end
        hitbox.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding = true
                updateValue(input.Position.X)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if sliding and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMove) then
                updateValue(input.Position.X)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding = false
            end
        end)
        return {
            Get = function() return currentValue end,
            Set = function(value)
                currentValue = math.clamp(tonumber(value) or currentValue, minValue, maxValue)
                local finalPercent = (currentValue - minValue) / (maxValue - minValue)
                fill.Size = UDim2.new(finalPercent, 0, 1, 0)
                knob.Position = UDim2.new(finalPercent, -7, 0.5, -7)
                valueLabel.Text = tostring(currentValue)
            end
        }
    end

    local function AddButton(tabData, labelText, buttonText, callback)
        labelText = tostring(labelText)
        buttonText = tostring(buttonText or "Run")
        local container = CreateFrame(tabData.content, UDim2.new(1, 0, 0, 44), nil, Theme.ElementBG, "Button_" .. labelText)
        CreateCorner(container, 9)
        CreatePadding(container, 8, 10, 8, 10)
        CreateStroke(container, Theme.Border, 1)
        CreateLabel(container, labelText, UDim2.new(0.6, 0, 1, 0), Theme.Text).TextSize = 13
        local buttonVisual = CreateFrame(container, UDim2.new(0, 80, 1, -8), UDim2.new(1, -80, 0, 4), Theme.Accent, "ButtonVisual")
        CreateCorner(buttonVisual, 7)
        local buttonLabel = CreateLabel(buttonVisual, buttonText, UDim2.new(1, 0, 1, 0), Color3.fromRGB(10, 10, 20), "ButtonLabel")
        buttonLabel.TextXAlignment = Enum.TextXAlignment.Center
        buttonLabel.TextSize = 12
        buttonLabel.Font = Enum.Font.GothamBold
        local hitbox = Instance.new("TextButton")
        hitbox.Size = UDim2.new(1, 0, 1, 0)
        hitbox.BackgroundTransparency = 1
        hitbox.Text = ""
        hitbox.Parent = container
        hitbox.Activated:Connect(function()
            TweenObject(buttonVisual, { BackgroundColor3 = Color3.fromRGB(70, 130, 200) }, 0.08)
            task.delay(0.15, function()
                TweenObject(buttonVisual, { BackgroundColor3 = Theme.Accent }, 0.15)
            end)
            if type(callback) == "function" then callback() end
        end)
        return hitbox
    end

    local function AddTextBox(tabData, labelText, placeholderText, callback)
        labelText = tostring(labelText)
        placeholderText = tostring(placeholderText or "Digite...")
        local container = CreateFrame(tabData.content, UDim2.new(1, 0, 0, 66), nil, Theme.ElementBG, "TextBox_" .. labelText)
        CreateCorner(container, 9)
        CreatePadding(container, 8, 10, 8, 10)
        CreateStroke(container, Theme.Border, 1)
        CreateLabel(container, labelText, UDim2.new(1, 0, 0, 15), Theme.Text).TextSize = 12
        local inputBackground = CreateFrame(container, UDim2.new(1, 0, 0, 28), UDim2.new(0, 0, 0, 20), Color3.fromRGB(16, 16, 22), "InputBackground")
        CreateCorner(inputBackground, 7)
        local inputStroke = CreateStroke(inputBackground, Theme.Border, 1)
        local textBox = Instance.new("TextBox")
        textBox.Size = UDim2.new(1, -16, 1, 0)
        textBox.Position = UDim2.new(0, 8, 0, 0)
        textBox.BackgroundTransparency = 1
        textBox.Text = ""
        textBox.PlaceholderText = placeholderText
        textBox.PlaceholderColor3 = Theme.SubText
        textBox.TextColor3 = Theme.Text
        textBox.TextSize = 12
        textBox.Font = Enum.Font.Gotham
        textBox.TextXAlignment = Enum.TextXAlignment.Left
        textBox.ClearTextOnFocus = false
        textBox.Parent = inputBackground
        textBox.Focused:Connect(function()
            TweenObject(inputStroke, { Color = Theme.Accent }, 0.15)
        end)
        textBox.FocusLost:Connect(function(enterPressed)
            TweenObject(inputStroke, { Color = Theme.Border }, 0.15)
            if type(callback) == "function" then callback(textBox.Text, enterPressed) end
        end)
        return textBox
    end

    -- ==============================================================
    -- DROPDOWN CORRIGIDO
    -- ==============================================================
    local function AddDropdown(tabData, labelText, options, defaultOption, callback)
        labelText = tostring(labelText)
        if type(options) ~= "table" then options = {} end
        local selectedOption = tostring(defaultOption or options[1] or "")
        local isOpen = false
        local listFrame = nil

        local container = CreateFrame(tabData.content, UDim2.new(1, 0, 0, 44), nil, Theme.ElementBG, "Dropdown_" .. labelText)
        CreateCorner(container, 9)
        CreatePadding(container, 8, 10, 8, 10)
        CreateStroke(container, Theme.Border, 1)

        CreateLabel(container, labelText, UDim2.new(0.48, 0, 1, 0), Theme.Text).TextSize = 13

        local selectButton = Instance.new("TextButton")
        selectButton.Size = UDim2.new(0.49, 0, 1, -8)
        selectButton.Position = UDim2.new(0.51, 0, 0, 4)
        selectButton.BackgroundColor3 = Theme.HoverBG
        selectButton.Text = selectedOption
        selectButton.TextColor3 = Theme.Accent
        selectButton.TextSize = 11
        selectButton.Font = Enum.Font.GothamMedium
        selectButton.BorderSizePixel = 0
        selectButton.TextTruncate = Enum.TextTruncate.AtEnd
        selectButton.Parent = container
        CreateCorner(selectButton, 7)
        CreateStroke(selectButton, Theme.Border, 1)

        local arrowLabel = CreateLabel(selectButton, "▾", UDim2.new(0, 16, 1, 0), Theme.SubText, "Arrow")
        arrowLabel.Position = UDim2.new(1, -18, 0, 0)
        arrowLabel.TextXAlignment = Enum.TextXAlignment.Center
        arrowLabel.Font = Enum.Font.GothamBold

        local function closeDropdown()
            isOpen = false
            if listFrame then listFrame.Visible = false end
            TweenObject(arrowLabel, { TextColor3 = Theme.SubText }, 0.15)
            Window.OpenDropdown = nil
        end

        local function openDropdown()
            if Window.OpenDropdown and Window.OpenDropdown ~= closeDropdown then
                Window.OpenDropdown()
            end
            Window.OpenDropdown = closeDropdown

            if not listFrame then
                local listHeight = math.min(#options, 5) * 34 + 8
                -- CORREÇÃO: Parent mudou de WindowFrame para ScreenGui
                listFrame = CreateFrame(ScreenGui, UDim2.new(0, 10, 0, listHeight), UDim2.new(0, 0, 0, 0), Theme.ElementBG, "DropdownList")
                CreateCorner(listFrame, 9)
                CreateStroke(listFrame, Theme.Border, 1)
                listFrame.ZIndex = 100 -- Fica acima da janela
                CreateListLayout(listFrame, 2)
                CreatePadding(listFrame, 4, 4, 4, 4)

                for _, opt in ipairs(options) do
                    -- CORREÇÃO: Força conversão para string para evitar "table: 0x..."
                    local option = tostring(opt)
                    local optionButton = Instance.new("TextButton")
                    optionButton.Size = UDim2.new(1, 0, 0, 30)
                    optionButton.BackgroundColor3 = Theme.ElementBG
                    optionButton.Text = option
                    optionButton.TextColor3 = (option == selectedOption) and Theme.Accent or Theme.Text
                    optionButton.TextSize = 12
                    optionButton.Font = Enum.Font.GothamMedium
                    optionButton.BorderSizePixel = 0
                    optionButton.ZIndex = 101
                    optionButton.Parent = listFrame
                    CreateCorner(optionButton, 7)

                    optionButton.MouseEnter:Connect(function()
                        TweenObject(optionButton, { BackgroundColor3 = Theme.HoverBG }, 0.1)
                    end)
                    optionButton.MouseLeave:Connect(function()
                        TweenObject(optionButton, { BackgroundColor3 = Theme.ElementBG }, 0.1)
                    end)

                    optionButton.Activated:Connect(function()
                        selectedOption = option
                        selectButton.Text = option
                        closeDropdown()
                        if type(callback) == "function" then callback(option) end
                    end)
                end
            end

            -- CORREÇÃO: Cálculo usa coordenadas absolutas da tela
            local absoluteX = selectButton.AbsolutePosition.X
            local absoluteY = selectButton.AbsolutePosition.Y + selectButton.AbsoluteSize.Y + 4
            listFrame.Position = UDim2.new(0, absoluteX, 0, absoluteY)
            listFrame.Size = UDim2.new(0, selectButton.AbsoluteSize.X, 0, math.min(#options, 5) * 34 + 8)
            listFrame.Visible = true
            isOpen = true
            TweenObject(arrowLabel, { TextColor3 = Theme.Accent }, 0.15)
        end

        selectButton.Activated:Connect(function()
            if isOpen then closeDropdown() else openDropdown() end
        end)

        return {
            Get = function() return selectedOption end,
            Set = function(value)
                selectedOption = tostring(value)
                selectButton.Text = selectedOption
            end,
            Close = closeDropdown
        }
    end

    -- ==============================================================
    -- MULTISELECT CORRIGIDO
    -- ==============================================================
    local function AddMultiSelect(tabData, labelText, options, defaultOptions, callback)
        labelText = tostring(labelText)
        if type(options) ~= "table" then options = {} end
        local selectedOptions = {}
        -- CORREÇÃO: Converte as opções padrão para string
        for _, v in ipairs(defaultOptions or {}) do
            selectedOptions[tostring(v)] = true
        end
        local isOpen = false
        local listFrame = nil
        local checkReferences = {}

        local function buildButtonText()
            local names = {}
            for _, opt in ipairs(options) do
                -- CORREÇÃO: Converte opção para string
                local option = tostring(opt)
                if selectedOptions[option] then table.insert(names, option) end
            end
            if #names == 0 then return "Nenhum" end
            return table.concat(names, ", ")
        end

        local container = CreateFrame(tabData.content, UDim2.new(1, 0, 0, 44), nil, Theme.ElementBG, "MultiSelect_" .. labelText)
        CreateCorner(container, 9)
        CreatePadding(container, 8, 10, 8, 10)
        CreateStroke(container, Theme.Border, 1)
        CreateLabel(container, labelText, UDim2.new(0.48, 0, 1, 0), Theme.Text).TextSize = 13

        local selectButton = Instance.new("TextButton")
        selectButton.Size = UDim2.new(0.49, 0, 1, -8)
        selectButton.Position = UDim2.new(0.51, 0, 0, 4)
        selectButton.BackgroundColor3 = Theme.HoverBG
        selectButton.Text = buildButtonText()
        selectButton.TextColor3 = Theme.Accent
        selectButton.TextSize = 10
        selectButton.Font = Enum.Font.GothamMedium
        selectButton.BorderSizePixel = 0
        selectButton.TextTruncate = Enum.TextTruncate.AtEnd
        selectButton.Parent = container
        CreateCorner(selectButton, 7)
        CreateStroke(selectButton, Theme.Border, 1)

        local arrowLabel = CreateLabel(selectButton, "▾", UDim2.new(0, 16, 1, 0), Theme.SubText, "Arrow")
        arrowLabel.Position = UDim2.new(1, -18, 0, 0)
        arrowLabel.TextXAlignment = Enum.TextXAlignment.Center
        arrowLabel.Font = Enum.Font.GothamBold

        local function syncCheckboxes()
            for option, references in pairs(checkReferences) do
                local active = selectedOptions[option] == true
                references.check.Visible = active
                references.checkboxBackground.BackgroundColor3 = active and Color3.fromRGB(20, 40, 65) or Color3.fromRGB(20, 20, 30)
            end
        end

        local function closeMultiSelect()
            isOpen = false
            if listFrame then listFrame.Visible = false end
            TweenObject(arrowLabel, { TextColor3 = Theme.SubText }, 0.15)
            if Window.OpenDropdown == closeMultiSelect then
                Window.OpenDropdown = nil
            end
        end

        local function openMultiSelect()
            if Window.OpenDropdown and Window.OpenDropdown ~= closeMultiSelect then
                Window.OpenDropdown()
            end
            Window.OpenDropdown = closeMultiSelect

            if not listFrame then
                local listHeight = math.min(#options, 5) * 38 + 8
                -- CORREÇÃO: Parent mudou de WindowFrame para ScreenGui
                listFrame = CreateFrame(ScreenGui, UDim2.new(0, 10, 0, listHeight), UDim2.new(0, 0, 0, 0), Theme.ElementBG, "MultiSelectList")
                CreateCorner(listFrame, 9)
                CreateStroke(listFrame, Theme.Border, 1)
                listFrame.ZIndex = 100 -- Fica acima da janela
                CreateListLayout(listFrame, 2)
                CreatePadding(listFrame, 4, 4, 4, 4)

                for _, opt in ipairs(options) do
                    -- CORREÇÃO: Converte opção para string
                    local option = tostring(opt)
                    local row = CreateFrame(listFrame, UDim2.new(1, 0, 0, 34), nil, Theme.ElementBG, "Row_" .. option)
                    CreateCorner(row, 7)
                    row.ZIndex = 101

                    local checkboxBackground = CreateFrame(row, UDim2.new(0, 18, 0, 18), UDim2.new(0, 8, 0.5, -9), Color3.fromRGB(20, 20, 30), "CheckboxBG")
                    checkboxBackground.ZIndex = 102
                    CreateCorner(checkboxBackground, 5)
                    CreateStroke(checkboxBackground, Theme.Border, 1)

                    local checkLabel = CreateLabel(checkboxBackground, "✓", UDim2.new(1, 0, 1, 0), Theme.Accent, "Check")
                    checkLabel.TextXAlignment = Enum.TextXAlignment.Center
                    checkLabel.TextSize = 12
                    checkLabel.Font = Enum.Font.GothamBold
                    checkLabel.ZIndex = 103
                    checkLabel.Visible = selectedOptions[option] == true

                    checkReferences[option] = {
                        checkboxBackground = checkboxBackground,
                        check = checkLabel
                    }

                    local optionLabel = CreateLabel(row, option, UDim2.new(1, -36, 1, 0), Theme.Text, "Label")
                    optionLabel.Position = UDim2.new(0, 34, 0, 0)
                    optionLabel.TextSize = 12
                    optionLabel.ZIndex = 102

                    local hitbox = Instance.new("TextButton")
                    hitbox.Size = UDim2.new(1, 0, 1, 0)
                    hitbox.BackgroundTransparency = 1
                    hitbox.Text = ""
                    hitbox.ZIndex = 104
                    hitbox.Parent = row

                    hitbox.MouseEnter:Connect(function()
                        TweenObject(row, { BackgroundColor3 = Theme.HoverBG }, 0.1)
                    end)
                    hitbox.MouseLeave:Connect(function()
                        TweenObject(row, { BackgroundColor3 = Theme.ElementBG }, 0.1)
                    end)

                    hitbox.Activated:Connect(function()
                        selectedOptions[option] = not (selectedOptions[option] == true)
                        local active = selectedOptions[option]
                        checkLabel.Visible = active
                        TweenObject(checkboxBackground, { BackgroundColor3 = active and Color3.fromRGB(20, 40, 65) or Color3.fromRGB(20, 20, 30) }, 0.15)
                        selectButton.Text = buildButtonText()
                        if type(callback) == "function" then
                            local selectedList = {}
                            for _, optInner in ipairs(options) do
                                -- CORREÇÃO: Converte opção para string
                                local optStr = tostring(optInner)
                                if selectedOptions[optStr] then table.insert(selectedList, optStr) end
                            end
                            callback(selectedList)
                        end
                    end)
                end
            end

            syncCheckboxes()
            -- CORREÇÃO: Cálculo usa coordenadas absolutas da tela
            local absoluteX = selectButton.AbsolutePosition.X
            local absoluteY = selectButton.AbsolutePosition.Y + selectButton.AbsoluteSize.Y + 4
            listFrame.Position = UDim2.new(0, absoluteX, 0, absoluteY)
            listFrame.Size = UDim2.new(0, selectButton.AbsoluteSize.X, 0, math.min(#options, 5) * 38 + 8)
            listFrame.Visible = true
            isOpen = true
            TweenObject(arrowLabel, { TextColor3 = Theme.Accent }, 0.15)
        end

        selectButton.Activated:Connect(function()
            if isOpen then closeMultiSelect() else openMultiSelect() end
        end)

        return {
            Get = function()
                local selectedList = {}
                for _, opt in ipairs(options) do
                    -- CORREÇÃO: Converte opção para string
                    local option = tostring(opt)
                    if selectedOptions[option] then table.insert(selectedList, option) end
                end
                return selectedList
            end,
            Close = closeMultiSelect
        }
    end

    -- Criação de abas (agora as funções já estão definidas)
    local function CreateTab(tabName, tabIcon)
        tabName = tostring(tabName)
        tabIcon = tabIcon and tostring(tabIcon) or tabName:sub(1,1)
        local tabData = {}

        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 58)
        button.BackgroundColor3 = Theme.SidebarBG
        button.Text = ""
        button.BorderSizePixel = 0
        button.AutoButtonColor = false
        button.Parent = TabListFrame
        CreateCorner(button, 9)

        local indicator = CreateFrame(button, UDim2.new(0, 3, 0, 28), UDim2.new(0, 0, 0.5, -14), Theme.Accent, "Indicator")
        CreateCorner(indicator, 2)
        indicator.BackgroundTransparency = 1

        local icon = CreateLabel(button, tabIcon, UDim2.new(1, 0, 0, 24), Theme.SubText, "Icon")
        icon.Position = UDim2.new(0, 0, 0, 7)
        icon.TextXAlignment = Enum.TextXAlignment.Center
        icon.TextSize = 17
        icon.Font = Enum.Font.GothamBold

        local label = CreateLabel(button, tabName, UDim2.new(1, 0, 0, 13), Theme.SubText, "Label")
        label.Position = UDim2.new(0, 0, 0, 33)
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.TextSize = 10
        label.Font = Enum.Font.Gotham

        local content = CreateScrollFrame(ContentArea)
        content.Visible = false

        tabData.button = button
        tabData.label = label
        tabData.icon = icon
        tabData.indicator = indicator
        tabData.content = content
        tabData.name = tabName

        table.insert(allTabs, tabData)
        button.Activated:Connect(function()
            SelectTab(tabData)
        end)

        if #allTabs == 1 then
            task.defer(function()
                SelectTab(tabData)
            end)
        end

        -- Expor funções
        tabData.AddSection = function(text) AddSection(tabData, text) end
        tabData.AddToggle = function(label, desc, default, callback) return AddToggle(tabData, label, desc, default, callback) end
        tabData.AddSlider = function(label, min, max, default, callback) return AddSlider(tabData, label, min, max, default, callback) end
        tabData.AddButton = function(label, btnText, callback) return AddButton(tabData, label, btnText, callback) end
        tabData.AddTextBox = function(label, placeholder, callback) return AddTextBox(tabData, label, placeholder, callback) end
        tabData.AddDropdown = function(label, options, default, callback) return AddDropdown(tabData, label, options, default, callback) end
        tabData.AddMultiSelect = function(label, options, defaults, callback) return AddMultiSelect(tabData, label, options, defaults, callback) end

        return tabData
    end

    -- Animação de entrada
    WindowFrame.ClipsDescendants = true
    WindowFrame.Size = UDim2.new(0, Theme.WindowWidth, 0, 0)
    Shadow.ImageTransparency = 1
    TweenObject(WindowFrame, { Size = UDim2.new(0, Theme.WindowWidth, 0, Theme.WindowHeight) }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    TweenObject(Shadow, { ImageTransparency = 0.55 }, 0.35)
    task.delay(0.42, function()
        WindowFrame.ClipsDescendants = false
    end)

    -- Métodos públicos
    function Window:CreateTab(tabName, icon)
        return CreateTab(tabName, icon)
    end

    function Window:Notify(title, message, duration)
        title = tostring(title)
        message = tostring(message)
        local notificationFrame = CreateFrame(ScreenGui, UDim2.new(0, 200, 0, 60), UDim2.new(1, -10, 1, -60), Theme.ElementBG, "Notification")
        CreateCorner(notificationFrame, 8)
        CreateStroke(notificationFrame, Theme.Accent, 1)
        local titleLabel = CreateLabel(notificationFrame, title, UDim2.new(1, 0, 0, 20), Theme.Text)
        titleLabel.Position = UDim2.new(0, 10, 0, 5)
        titleLabel.Font = Enum.Font.GothamBold
        local messageLabel = CreateLabel(notificationFrame, message, UDim2.new(1, 0, 0, 20), Theme.SubText)
        messageLabel.Position = UDim2.new(0, 10, 0, 25)
        messageLabel.TextSize = 12
        TweenObject(notificationFrame, { Position = UDim2.new(1, -10, 1, -60) }, 0.3)
        task.delay(duration or 3, function()
            TweenObject(notificationFrame, { Position = UDim2.new(1, -10, 1, 10) }, 0.3)
            task.delay(0.3, function()
                notificationFrame:Destroy()
            end)
        end)
    end

    function Window:Destroy()
        ScreenGui:Destroy()
    end

    return Window
end

return NebulaUI
