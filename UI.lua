--[[
    NebulaUI v1.0
    Criada exclusivamente para mobile
    Sem CoreGui, sem binds, tema escuro com destaque configurável
]]

local NebulaUI = {}
NebulaUI.__index = NebulaUI

-- Serviços
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Tema padrão
NebulaUI.Theme = {
    Background = Color3.fromRGB(13, 13, 15),
    Card = Color3.fromRGB(26, 26, 30),
    Element = Color3.fromRGB(42, 42, 48),
    ElementHover = Color3.fromRGB(55, 55, 63),
    Accent = Color3.fromRGB(255, 59, 48), -- Vermelho vibrante
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(170, 170, 180),
    Outline = Color3.fromRGB(80, 80, 90),
    Success = Color3.fromRGB(76, 175, 80),
    Warning = Color3.fromRGB(255, 152, 0),
}

-- Variáveis globais
local Flags = {}
local Items = {}
local CurrentWindow = nil
local NotificationQueue = {}

-- Funções utilitárias
local function createInstance(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end
    return instance
end

local function applyTheme(instance, property, themeColor)
    instance[property] = themeColor
end

local function tweenObject(object, properties, duration)
    local tweenInfo = TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

local function addBlur(parent)
    local blur = createInstance("BlurEffect", {
        Size = 8,
        Parent = parent,
    })
    return blur
end

-- Cria a janela principal
function NebulaUI:CreateWindow(title)
    local Window = {}
    Window.Title = title
    Window.Tabs = {}
    Window.Notifications = {}

    -- ScreenGui dentro do PlayerGui (sem CoreGui)
    local ScreenGui = createInstance("ScreenGui", {
        Name = "NebulaUI_" .. title,
        Parent = PlayerGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
    })

    -- Fundo escuro com blur
    local BackgroundFrame = createInstance("Frame", {
        Name = "Background",
        Parent = ScreenGui,
        BackgroundColor3 = NebulaUI.Theme.Background,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
    })
    addBlur(BackgroundFrame)

    -- Container principal
    local MainFrame = createInstance("Frame", {
        Name = "Main",
        Parent = ScreenGui,
        BackgroundColor3 = NebulaUI.Theme.Card,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 420, 0, 600),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
    })
    -- Cantos arredondados
    local UICorner = createInstance("UICorner", {
        Parent = MainFrame,
        CornerRadius = UDim.new(0, 16),
    })
    local UIStroke = createInstance("UIStroke", {
        Parent = MainFrame,
        Color = NebulaUI.Theme.Outline,
        Thickness = 1,
    })

    -- Header
    local HeaderFrame = createInstance("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = NebulaUI.Theme.Accent,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 60),
        Position = UDim2.new(0, 0, 0, 0),
    })
    local HeaderCorner = createInstance("UICorner", {
        Parent = HeaderFrame,
        CornerRadius = UDim.new(0, 16),
    })
    -- Garante que só as bordas superiores fiquem arredondadas
    HeaderCorner.CornerRadius = UDim.new(0, 16)
    local HeaderTitle = createInstance("TextLabel", {
        Parent = HeaderFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 0),
        Size = UDim2.new(1, -40, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = NebulaUI.Theme.Text,
        TextSize = 24,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    -- Container para Tabs
    local TabContainer = createInstance("Frame", {
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 60),
    })
    local TabListLayout = createInstance("UIListLayout", {
        Parent = TabContainer,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 5),
    })
    local TabPadding = createInstance("UIPadding", {
        Parent = TabContainer,
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
    })

    -- Container para SubTabs
    local SubTabContainer = createInstance("Frame", {
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 100),
        Visible = false,
    })
    local SubTabListLayout = createInstance("UIListLayout", {
        Parent = SubTabContainer,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 5),
    })
    local SubTabPadding = createInstance("UIPadding", {
        Parent = SubTabContainer,
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
    })

    -- Container para o conteúdo (Groupboxes)
    local ContentContainer = createInstance("ScrollingFrame", {
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 140),
        Size = UDim2.new(1, 0, 1, -140),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = NebulaUI.Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y,
    })
    local ContentLayout = createInstance("UIListLayout", {
        Parent = ContentContainer,
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Padding = UDim.new(0, 10),
    })
    local ContentPadding = createInstance("UIPadding", {
        Parent = ContentContainer,
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 20),
    })

    -- Função para criar Tab
    function Window:CreateTab(tabTitle)
        local Tab = {}
        Tab.Title = tabTitle
        Tab.SubTabs = {}
        Tab.Button = nil

        Tab.Button = createInstance("TextButton", {
            Parent = TabContainer,
            BackgroundColor3 = NebulaUI.Theme.Element,
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 100, 0, 35),
            Text = tabTitle,
            Font = Enum.Font.GothamSemibold,
            TextColor3 = NebulaUI.Theme.TextSecondary,
            TextSize = 16,
        })
        local tabCorner = createInstance("UICorner", {
            Parent = Tab.Button,
            CornerRadius = UDim.new(0, 8),
        })
        local tabStroke = createInstance("UIStroke", {
            Parent = Tab.Button,
            Color = NebulaUI.Theme.Outline,
            Thickness = 1,
        })

        Tab.Button.Activated:Connect(function()
            -- Atualiza visual das tabs
            for _, otherTab in pairs(Window.Tabs) do
                if otherTab ~= Tab then
                    otherTab.Button.BackgroundColor3 = NebulaUI.Theme.Element
                    otherTab.Button.TextColor3 = NebulaUI.Theme.TextSecondary
                    otherTab.Button.BackgroundTransparency = 0.5
                    -- Esconde subtabs e conteúdo de outras tabs
                    if otherTab.SubTabContainer then otherTab.SubTabContainer.Visible = false end
                    if otherTab.ContentContainer then otherTab.ContentContainer.Visible = false end
                end
            end
            Tab.Button.BackgroundColor3 = NebulaUI.Theme.Accent
            Tab.Button.TextColor3 = NebulaUI.Theme.Text
            Tab.Button.BackgroundTransparency = 0
            -- Mostra subtabs e conteúdo da tab ativa
            if Tab.SubTabContainer then Tab.SubTabContainer.Visible = true end
            if Tab.ContentContainer then Tab.ContentContainer.Visible = true end
        end)

        -- Container de SubTabs para esta Tab
        Tab.SubTabContainer = createInstance("Frame", {
            Parent = SubTabContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
        })
        local subListLayout = createInstance("UIListLayout", {
            Parent = Tab.SubTabContainer,
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 5),
        })

        -- Container de conteúdo para esta Tab
        Tab.ContentContainer = createInstance("ScrollingFrame", {
            Parent = ContentContainer,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = NebulaUI.Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y,
        })
        local contentList = createInstance("UIListLayout", {
            Parent = Tab.ContentContainer,
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            Padding = UDim.new(0, 10),
        })
        local contentPad = createInstance("UIPadding", {
            Parent = Tab.ContentContainer,
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 20),
        })

        -- Função para criar SubTab
        function Tab:CreateSubTab(subTitle)
            local SubTab = {}
            SubTab.Title = subTitle
            SubTab.Groupboxes = {}
            SubTab.Button = nil

            SubTab.Button = createInstance("TextButton", {
                Parent = Tab.SubTabContainer,
                BackgroundColor3 = NebulaUI.Theme.Element,
                BackgroundTransparency = 0.5,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 80, 0, 30),
                Text = subTitle,
                Font = Enum.Font.GothamSemibold,
                TextColor3 = NebulaUI.Theme.TextSecondary,
                TextSize = 14,
            })
            local subCorner = createInstance("UICorner", {
                Parent = SubTab.Button,
                CornerRadius = UDim.new(0, 8),
            })
            local subStroke = createInstance("UIStroke", {
                Parent = SubTab.Button,
                Color = NebulaUI.Theme.Outline,
                Thickness = 1,
            })

            SubTab.Button.Activated:Connect(function()
                for _, otherSub in pairs(Tab.SubTabs) do
                    if otherSub ~= SubTab then
                        otherSub.Button.BackgroundColor3 = NebulaUI.Theme.Element
                        otherSub.Button.TextColor3 = NebulaUI.Theme.TextSecondary
                        otherSub.Button.BackgroundTransparency = 0.5
                        if otherSub.ContentContainer then otherSub.ContentContainer.Visible = false end
                    end
                end
                SubTab.Button.BackgroundColor3 = NebulaUI.Theme.Accent
                SubTab.Button.TextColor3 = NebulaUI.Theme.Text
                SubTab.Button.BackgroundTransparency = 0
                if SubTab.ContentContainer then SubTab.ContentContainer.Visible = true end
            end)

            -- Container para Groupboxes desta SubTab
            SubTab.ContentContainer = createInstance("Frame", {
                Parent = Tab.ContentContainer,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0), -- altura automática
                Visible = false,
            })
            local groupList = createInstance("UIListLayout", {
                Parent = SubTab.ContentContainer,
                FillDirection = Enum.FillDirection.Vertical,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                VerticalAlignment = Enum.VerticalAlignment.Top,
                Padding = UDim.new(0, 10),
            })

            -- Função para criar Groupbox
            function SubTab:CreateGroupbox(groupTitle, side)
                local Groupbox = {}
                Groupbox.Title = groupTitle
                Groupbox.Items = {}
                side = side or "Full" -- "Left", "Right", "Full"

                local groupFrame = createInstance("Frame", {
                    Parent = SubTab.ContentContainer,
                    BackgroundColor3 = NebulaUI.Theme.Card,
                    BackgroundTransparency = 0.1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, -20, 0, 40), -- altura inicial
                })
                local groupCorner = createInstance("UICorner", {
                    Parent = groupFrame,
                    CornerRadius = UDim.new(0, 12),
                })
                local groupStroke = createInstance("UIStroke", {
                    Parent = groupFrame,
                    Color = NebulaUI.Theme.Outline,
                    Thickness = 1,
                })

                local groupHeader = createInstance("TextLabel", {
                    Parent = groupFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 15, 0, 0),
                    Size = UDim2.new(1, -30, 0, 40),
                    Font = Enum.Font.GothamBold,
                    Text = groupTitle,
                    TextColor3 = NebulaUI.Theme.Text,
                    TextSize = 18,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })

                local groupContent = createInstance("Frame", {
                    Parent = groupFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 15, 0, 40),
                    Size = UDim2.new(1, -30, 0, 0),
                })
                local groupItemsLayout = createInstance("UIListLayout", {
                    Parent = groupContent,
                    FillDirection = Enum.FillDirection.Vertical,
                    HorizontalAlignment = Enum.HorizontalAlignment.Left,
                    VerticalAlignment = Enum.VerticalAlignment.Top,
                    Padding = UDim.new(0, 8),
                })

                -- Função para redimensionar grupo baseado nos itens
                local function updateGroupSize()
                    local totalHeight = 40 -- header
                    for _, item in ipairs(Groupbox.Items) do
                        if item.GetHeight then
                            totalHeight = totalHeight + item:GetHeight() + 8
                        else
                            totalHeight = totalHeight + 40 + 8
                        end
                    end
                    groupFrame.Size = UDim2.new(1, -20, 0, totalHeight)
                    groupContent.Size = UDim2.new(1, -30, 0, totalHeight - 40)
                end

                Groupbox.UpdateSize = updateGroupSize

                -- Métodos para adicionar elementos
                function Groupbox:AddLabel(text)
                    local label = createInstance("TextLabel", {
                        Parent = groupContent,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 30),
                        Font = Enum.Font.GothamMedium,
                        Text = text,
                        TextColor3 = NebulaUI.Theme.TextSecondary,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextWrapped = true,
                    })
                    local item = { GetHeight = function() return 30 end }
                    table.insert(Groupbox.Items, item)
                    updateGroupSize()
                    return label
                end

                function Groupbox:AddParagraph(data)
                    local titleLabel = createInstance("TextLabel", {
                        Parent = groupContent,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 20),
                        Font = Enum.Font.GothamBold,
                        Text = data.Title or "",
                        TextColor3 = NebulaUI.Theme.Text,
                        TextSize = 15,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })
                    local contentLabel = createInstance("TextLabel", {
                        Parent = groupContent,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 40),
                        Font = Enum.Font.Gotham,
                        Text = data.Content or "",
                        TextColor3 = NebulaUI.Theme.TextSecondary,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextWrapped = data.TextWrapped or true,
                    })
                    local item = {
                        GetHeight = function() return 60 end,
                        Elements = { titleLabel, contentLabel }
                    }
                    table.insert(Groupbox.Items, item)
                    updateGroupSize()
                    return item
                end

                function Groupbox:AddToggle(data)
                    local frame = createInstance("Frame", {
                        Parent = groupContent,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 44),
                    })
                    local label = createInstance("TextLabel", {
                        Parent = frame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(1, -60, 1, 0),
                        Font = Enum.Font.GothamMedium,
                        Text = data.Title or "Toggle",
                        TextColor3 = NebulaUI.Theme.Text,
                        TextSize = 15,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })
                    local switchFrame = createInstance("Frame", {
                        Parent = frame,
                        BackgroundColor3 = NebulaUI.Theme.Element,
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, 50, 0, 28),
                        Position = UDim2.new(1, -50, 0.5, -14),
                        AnchorPoint = Vector2.new(1, 0.5),
                    })
                    local switchCorner = createInstance("UICorner", {
                        Parent = switchFrame,
                        CornerRadius = UDim.new(1, 0),
                    })
                    local switchDot = createInstance("Frame", {
                        Parent = switchFrame,
                        BackgroundColor3 = NebulaUI.Theme.TextSecondary,
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, 22, 0, 22),
                        Position = UDim2.new(0, 3, 0.5, -11),
                        AnchorPoint = Vector2.new(0, 0.5),
                    })
                    local dotCorner = createInstance("UICorner", {
                        Parent = switchDot,
                        CornerRadius = UDim.new(1, 0),
                    })
                    local state = data.Default or false
                    local function updateVisual()
                        if state then
                            switchFrame.BackgroundColor3 = NebulaUI.Theme.Accent
                            switchDot.Position = UDim2.new(1, -25, 0.5, -11)
                            switchDot.AnchorPoint = Vector2.new(0, 0.5)
                            switchDot.BackgroundColor3 = NebulaUI.Theme.Text
                        else
                            switchFrame.BackgroundColor3 = NebulaUI.Theme.Element
                            switchDot.Position = UDim2.new(0, 3, 0.5, -11)
                            switchDot.AnchorPoint = Vector2.new(0, 0.5)
                            switchDot.BackgroundColor3 = NebulaUI.Theme.TextSecondary
                        end
                    end
                    updateVisual()
                    switchFrame.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                            state = not state
                            updateVisual()
                            if data.Callback then
                                data.Callback(state)
                            end
                            if data.Flag then
                                Flags[data.Flag] = state
                            end
                        end
                    end)
                    local item = {
                        GetHeight = function() return 44 end,
                        Value = state,
                        Set = function(v)
                            state = v
                            updateVisual()
                            if data.Callback then data.Callback(v) end
                        end,
                    }
                    table.insert(Groupbox.Items, item)
                    updateGroupSize()
                    return item
                end

                function Groupbox:AddCheckbox(data)
                    -- Similar ao Toggle, mas com quadradinho
                    local frame = createInstance("Frame", {
                        Parent = groupContent,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 44),
                    })
                    local box = createInstance("TextButton", {
                        Parent = frame,
                        BackgroundColor3 = NebulaUI.Theme.Element,
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, 26, 0, 26),
                        Position = UDim2.new(0, 0, 0.5, -13),
                        Text = "",
                    })
                    local boxCorner = createInstance("UICorner", {
                        Parent = box,
                        CornerRadius = UDim.new(0, 6),
                    })
                    local check = createInstance("TextLabel", {
                        Parent = box,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Font = Enum.Font.GothamBold,
                        Text = "✓",
                        TextColor3 = NebulaUI.Theme.Text,
                        TextSize = 16,
                        Visible = false,
                    })
                    local label = createInstance("TextLabel", {
                        Parent = frame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 35, 0, 0),
                        Size = UDim2.new(1, -35, 1, 0),
                        Font = Enum.Font.GothamMedium,
                        Text = data.Title or "Checkbox",
                        TextColor3 = NebulaUI.Theme.Text,
                        TextSize = 15,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })
                    local state = data.Default or false
                    local function updateVisual()
                        if state then
                            box.BackgroundColor3 = NebulaUI.Theme.Accent
                            check.Visible = true
                        else
                            box.BackgroundColor3 = NebulaUI.Theme.Element
                            check.Visible = false
                        end
                    end
                    updateVisual()
                    box.Activated:Connect(function()
                        state = not state
                        updateVisual()
                        if data.Callback then data.Callback(state) end
                        if data.Flag then Flags[data.Flag] = state end
                    end)
                    local item = {
                        GetHeight = function() return 44 end,
                        Value = state,
                        Set = function(v)
                            state = v
                            updateVisual()
                            if data.Callback then data.Callback(v) end
                        end,
                    }
                    table.insert(Groupbox.Items, item)
                    updateGroupSize()
                    return item
                end

                function Groupbox:AddSlider(data)
                    local frame = createInstance("Frame", {
                        Parent = groupContent,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 50),
                    })
                    local label = createInstance("TextLabel", {
                        Parent = frame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(1, 0, 0, 20),
                        Font = Enum.Font.GothamMedium,
                        Text = data.Title or "Slider",
                        TextColor3 = NebulaUI.Theme.Text,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })
                    local valueLabel = createInstance("TextLabel", {
                        Parent = frame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 20),
                        Size = UDim2.new(1, 0, 0, 20),
                        Font = Enum.Font.GothamMedium,
                        Text = tostring(data.Default or data.Min or 0),
                        TextColor3 = NebulaUI.Theme.Accent,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Right,
                    })
                    local sliderBg = createInstance("Frame", {
                        Parent = frame,
                        BackgroundColor3 = NebulaUI.Theme.Element,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 10),
                        Position = UDim2.new(0, 0, 0, 40),
                    })
                    local sliderCorner = createInstance("UICorner", {
                        Parent = sliderBg,
                        CornerRadius = UDim.new(1, 0),
                    })
                    local fill = createInstance("Frame", {
                        Parent = sliderBg,
                        BackgroundColor3 = NebulaUI.Theme.Accent,
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, 0, 1, 0),
                    })
                    local fillCorner = createInstance("UICorner", {
                        Parent = fill,
                        CornerRadius = UDim.new(1, 0),
                    })
                    local dragButton = createInstance("TextButton", {
                        Parent = sliderBg,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Text = "",
                    })
                    local current = data.Default or data.Min or 0
                    local min = data.Min or 0
                    local max = data.Max or 100
                    local function updateVisual()
                        local percent = (current - min) / (max - min)
                        fill.Size = UDim2.new(percent, 0, 1, 0)
                        valueLabel.Text = tostring(current) .. (data.Suffix or "")
                    end
                    updateVisual()
                    local dragging = false
                    dragButton.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = true
                        end
                    end)
                    dragButton.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = false
                            if data.Callback then data.Callback(current) end
                            if data.Flag then Flags[data.Flag] = current end
                        end
                    end)
                    dragButton.InputChanged:Connect(function(input)
                        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
                            local mousePos = UserInputService:GetMouseLocation()
                            local relativeX = mousePos.X - sliderBg.AbsolutePosition.X
                            local percent = math.clamp(relativeX / sliderBg.AbsoluteSize.X, 0, 1)
                            current = min + (max - min) * percent
                            if data.Rounding then
                                local mult = 10 ^ data.Rounding
                                current = math.floor(current * mult + 0.5) / mult
                            else
                                current = math.floor(current + 0.5)
                            end
                            updateVisual()
                            if data.Callback then data.Callback(current) end -- Atualiza em tempo real
                        end
                    end)
                    local item = {
                        GetHeight = function() return 50 end,
                        Value = current,
                        Set = function(v)
                            current = math.clamp(v, min, max)
                            updateVisual()
                            if data.Callback then data.Callback(current) end
                        end,
                    }
                    table.insert(Groupbox.Items, item)
                    updateGroupSize()
                    return item
                end

                function Groupbox:AddDropdown(data)
                    local frame = createInstance("Frame", {
                        Parent = groupContent,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 44),
                    })
                    local label = createInstance("TextLabel", {
                        Parent = frame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(1, 0, 0, 20),
                        Font = Enum.Font.GothamMedium,
                        Text = data.Title or "Dropdown",
                        TextColor3 = NebulaUI.Theme.Text,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })
                    local selectedText = createInstance("TextButton", {
                        Parent = frame,
                        BackgroundColor3 = NebulaUI.Theme.Element,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 0, 0, 22),
                        Size = UDim2.new(1, 0, 0, 22),
                        Font = Enum.Font.GothamMedium,
                        Text = "Selecione...",
                        TextColor3 = NebulaUI.Theme.Text,
                        TextSize = 13,
                    })
                    local ddCorner = createInstance("UICorner", {
                        Parent = selectedText,
                        CornerRadius = UDim.new(0, 6),
                    })
                    local ddStroke = createInstance("UIStroke", {
                        Parent = selectedText,
                        Color = NebulaUI.Theme.Outline,
                        Thickness = 1,
                    })
                    local optionsFrame = createInstance("Frame", {
                        Parent = frame,
                        BackgroundColor3 = NebulaUI.Theme.Card,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 0, 0, 44),
                        Size = UDim2.new(1, 0, 0, 0),
                        ClipsDescendants = true,
                        Visible = false,
                        ZIndex = 5,
                    })
                    local optCorner = createInstance("UICorner", {
                        Parent = optionsFrame,
                        CornerRadius = UDim.new(0, 8),
                    })
                    local optStroke = createInstance("UIStroke", {
                        Parent = optionsFrame,
                        Color = NebulaUI.Theme.Outline,
                        Thickness = 1,
                    })
                    local optionList = createInstance("UIListLayout", {
                        Parent = optionsFrame,
                        FillDirection = Enum.FillDirection.Vertical,
                        HorizontalAlignment = Enum.HorizontalAlignment.Left,
                        VerticalAlignment = Enum.VerticalAlignment.Top,
                        Padding = UDim.new(0, 2),
                    })
                    local optionPadding = createInstance("UIPadding", {
                        Parent = optionsFrame,
                        PaddingLeft = UDim.new(0, 5),
                        PaddingRight = UDim.new(0, 5),
                        PaddingTop = UDim.new(0, 5),
                        PaddingBottom = UDim.new(0, 5),
                    })
                    local selected = {}
                    local optionButtons = {}
                    local multi = data.Multi or false
                    local defaultValues = data.Default or (multi and {} or data.Values[1])
                    if multi then
                        for _, v in pairs(defaultValues) do selected[v] = true end
                    else
                        selected[defaultValues] = true
                    end
                    local function updateSelectedText()
                        local textParts = {}
                        for opt, isSelected in pairs(selected) do
                            if isSelected then table.insert(textParts, opt) end
                        end
                        if #textParts == 0 then
                            selectedText.Text = "Selecione..."
                        else
                            selectedText.Text = table.concat(textParts, ", ")
                        end
                    end
                    updateSelectedText()
                    local function rebuildOptions()
                        for _, btn in pairs(optionButtons) do btn:Destroy() end
                        optionButtons = {}
                        for _, opt in ipairs(data.Values) do
                            local btn = createInstance("TextButton", {
                                Parent = optionsFrame,
                                BackgroundColor3 = NebulaUI.Theme.Element,
                                BorderSizePixel = 0,
                                Size = UDim2.new(1, 0, 0, 30),
                                Font = Enum.Font.GothamMedium,
                                Text = opt,
                                TextColor3 = NebulaUI.Theme.TextSecondary,
                                TextSize = 13,
                            })
                            local btnCorner = createInstance("UICorner", {
                                Parent = btn,
                                CornerRadius = UDim.new(0, 6),
                            })
                            btn.Activated:Connect(function()
                                if multi then
                                    selected[opt] = not selected[opt]
                                else
                                    selected = {}
                                    selected[opt] = true
                                    optionsFrame.Visible = false
                                end
                                updateSelectedText()
                                if data.Callback then
                                    if multi then
                                        data.Callback(selected)
                                    else
                                        local selectedValue
                                        for k, v in pairs(selected) do if v then selectedValue = k end end
                                        data.Callback(selectedValue)
                                    end
                                end
                                if data.Flag then Flags[data.Flag] = selected end
                                -- Atualizar cores dos botões
                                for _, b in ipairs(optionButtons) do
                                    if selected[b.Text] then
                                        b.BackgroundColor3 = NebulaUI.Theme.Accent
                                        b.TextColor3 = NebulaUI.Theme.Text
                                    else
                                        b.BackgroundColor3 = NebulaUI.Theme.Element
                                        b.TextColor3 = NebulaUI.Theme.TextSecondary
                                    end
                                end
                            end)
                            table.insert(optionButtons, btn)
                        end
                        -- Ajusta altura do frame de opções
                        local totalOptHeight = #data.Values * 32 + 10
                        optionsFrame.Size = UDim2.new(1, 0, 0, totalOptHeight)
                    end
                    rebuildOptions()
                    selectedText.Activated:Connect(function()
                        optionsFrame.Visible = not optionsFrame.Visible
                    end)
                    local item = {
                        GetHeight = function() return 44 + (optionsFrame.Visible and #data.Values * 32 + 10 or 0) end,
                        Value = selected,
                        Refresh = function(newValues)
                            data.Values = newValues
                            rebuildOptions()
                            updateSelectedText()
                        end,
                        SetVisible = function(v) optionsFrame.Visible = v end,
                    }
                    table.insert(Groupbox.Items, item)
                    updateGroupSize()
                    return item
                end

                function Groupbox:AddButton(data)
                    local btn = createInstance("TextButton", {
                        Parent = groupContent,
                        BackgroundColor3 = NebulaUI.Theme.Element,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 40),
                        Font = Enum.Font.GothamBold,
                        Text = data.Title or "Button",
                        TextColor3 = NebulaUI.Theme.Text,
                        TextSize = 15,
                    })
                    local btnCorner = createInstance("UICorner", {
                        Parent = btn,
                        CornerRadius = UDim.new(0, 8),
                    })
                    local btnStroke = createInstance("UIStroke", {
                        Parent = btn,
                        Color = NebulaUI.Theme.Outline,
                        Thickness = 1,
                    })
                    btn.Activated:Connect(function()
                        if data.Callback then data.Callback() end
                    end)
                    local item = { GetHeight = function() return 40 end }
                    table.insert(Groupbox.Items, item)
                    updateGroupSize()
                    return btn
                end

                function Groupbox:AddColorPicker(data)
                    -- Implementação simplificada: mostra um botão que abre um popup com sliders RGB
                    local frame = createInstance("Frame", {
                        Parent = groupContent,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 44),
                    })
                    local label = createInstance("TextLabel", {
                        Parent = frame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(1, -50, 0, 20),
                        Font = Enum.Font.GothamMedium,
                        Text = data.Title or "Color",
                        TextColor3 = NebulaUI.Theme.Text,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })
                    local colorPreview = createInstance("TextButton", {
                        Parent = frame,
                        BackgroundColor3 = data.Default or NebulaUI.Theme.Accent,
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, 30, 0, 30),
                        Position = UDim2.new(1, -30, 0, 0),
                        Text = "",
                    })
                    local previewCorner = createInstance("UICorner", {
                        Parent = colorPreview,
                        CornerRadius = UDim.new(0, 8),
                    })
                    local currentColor = data.Default or NebulaUI.Theme.Accent
                    colorPreview.Activated:Connect(function()
                        -- Abre um popup com sliders RGB (simplificado)
                        -- Para manter o código curto, aqui apenas alternamos entre cores básicas
                        local colors = {
                            Color3.fromRGB(255, 59, 48),
                            Color3.fromRGB(0, 122, 255),
                            Color3.fromRGB(76, 175, 80),
                            Color3.fromRGB(255, 152, 0),
                            Color3.fromRGB(156, 39, 176),
                        }
                        local currentIndex = 1
                        for i, c in ipairs(colors) do
                            if c == currentColor then currentIndex = i end
                        end
                        currentIndex = currentIndex % #colors + 1
                        currentColor = colors[currentIndex]
                        colorPreview.BackgroundColor3 = currentColor
                        if data.Callback then data.Callback(currentColor, 0) end
                        if data.Flag then Flags[data.Flag] = currentColor end
                    end)
                    local item = { GetHeight = function() return 44 end, Value = currentColor }
                    table.insert(Groupbox.Items, item)
                    updateGroupSize()
                    return item
                end

                function Groupbox:AddRadioButton(data)
                    local frame = createInstance("Frame", {
                        Parent = groupContent,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, #data.Options * 36),
                    })
                    local label = createInstance("TextLabel", {
                        Parent = frame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(1, 0, 0, 20),
                        Font = Enum.Font.GothamMedium,
                        Text = data.Title or "Radio",
                        TextColor3 = NebulaUI.Theme.Text,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })
                    local current = data.Default or data.Options[1]
                    local buttons = {}
                    for i, opt in ipairs(data.Options) do
                        local btnFrame = createInstance("Frame", {
                            Parent = frame,
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 0, 0, 20 + (i-1)*36),
                            Size = UDim2.new(1, 0, 0, 30),
                        })
                        local dot = createInstance("Frame", {
                            Parent = btnFrame,
                            BackgroundColor3 = NebulaUI.Theme.Element,
                            BorderSizePixel = 0,
                            Size = UDim2.new(0, 18, 0, 18),
                            Position = UDim2.new(0, 0, 0.5, -9),
                        })
                        local dotCorner = createInstance("UICorner", {
                            Parent = dot,
                            CornerRadius = UDim.new(1, 0),
                        })
                        local dotInner = createInstance("Frame", {
                            Parent = dot,
                            BackgroundColor3 = NebulaUI.Theme.Accent,
                            BorderSizePixel = 0,
                            Size = UDim2.new(0, 10, 0, 10),
                            Position = UDim2.new(0.5, -5, 0.5, -5),
                            Visible = (opt == current),
                        })
                        local dotInnerCorner = createInstance("UICorner", {
                            Parent = dotInner,
                            CornerRadius = UDim.new(1, 0),
                        })
                        local btnLabel = createInstance("TextButton", {
                            Parent = btnFrame,
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 25, 0, 0),
                            Size = UDim2.new(1, -25, 1, 0),
                            Font = Enum.Font.GothamMedium,
                            Text = opt,
                            TextColor3 = NebulaUI.Theme.Text,
                            TextSize = 14,
                            TextXAlignment = Enum.TextXAlignment.Left,
                        })
                        btnLabel.Activated:Connect(function()
                            current = opt
                            for _, b in ipairs(buttons) do
                                b.inner.Visible = (b.opt == current)
                            end
                            if data.Callback then data.Callback(current) end
                            if data.Flag then Flags[data.Flag] = current end
                        end)
                        table.insert(buttons, { opt = opt, inner = dotInner })
                    end
                    local item = { GetHeight = function() return 20 + #data.Options * 36 end, Value = current }
                    table.insert(Groupbox.Items, item)
                    updateGroupSize()
                    return item
                end

                function Groupbox:AddProgressBar(data)
                    local frame = createInstance("Frame", {
                        Parent = groupContent,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 44),
                    })
                    local label = createInstance("TextLabel", {
                        Parent = frame,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(1, 0, 0, 20),
                        Font = Enum.Font.GothamMedium,
                        Text = data.Title or "Progress",
                        TextColor3 = NebulaUI.Theme.Text,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    })
                    local barBg = createInstance("Frame", {
                        Parent = frame,
                        BackgroundColor3 = NebulaUI.Theme.Element,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 14),
                        Position = UDim2.new(0, 0, 0, 25),
                    })
                    local barCorner = createInstance("UICorner", {
                        Parent = barBg,
                        CornerRadius = UDim.new(1, 0),
                    })
                    local barFill = createInstance("Frame", {
                        Parent = barBg,
                        BackgroundColor3 = NebulaUI.Theme.Accent,
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, 0, 1, 0),
                    })
                    local fillCorner = createInstance("UICorner", {
                        Parent = barFill,
                        CornerRadius = UDim.new(1, 0),
                    })
                    local current = data.Default or 0
                    local function updateVisual()
                        barFill.Size = UDim2.new(math.clamp(current, 0, 1), 0, 1, 0)
                    end
                    updateVisual()
                    local item = {
                        GetHeight = function() return 44 end,
                        Value = current,
                        Set = function(v)
                            current = v
                            updateVisual()
                        end,
                    }
                    table.insert(Groupbox.Items, item)
                    updateGroupSize()
                    return item
                end

                function Groupbox:AddSeparator()
                    local sep = createInstance("Frame", {
                        Parent = groupContent,
                        BackgroundColor3 = NebulaUI.Theme.Outline,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 1),
                    })
                    local item = { GetHeight = function() return 1 end }
                    table.insert(Groupbox.Items, item)
                    updateGroupSize()
                    return sep
                end

                function Groupbox:AddSpacing(px)
                    px = px or 5
                    local space = createInstance("Frame", {
                        Parent = groupContent,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, px),
                    })
                    local item = { GetHeight = function() return px end }
                    table.insert(Groupbox.Items, item)
                    updateGroupSize()
                    return space
                end

                updateGroupSize()
                table.insert(SubTab.Groupboxes, Groupbox)
                return Groupbox
            end

            table.insert(Tab.SubTabs, SubTab)
            return SubTab
        end

        table.insert(Window.Tabs, Tab)
        return Tab
    end

    -- Sistema de notificações
    function Window:Notify(title, message, duration)
        duration = duration or 3
        local notificationFrame = createInstance("Frame", {
            Parent = MainFrame,
            BackgroundColor3 = NebulaUI.Theme.Card,
            BackgroundTransparency = 0.1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -20, 0, 60),
            Position = UDim2.new(0, 10, 1, -60),
        })
        local notifCorner = createInstance("UICorner", {
            Parent = notificationFrame,
            CornerRadius = UDim.new(0, 10),
        })
        local notifStroke = createInstance("UIStroke", {
            Parent = notificationFrame,
            Color = NebulaUI.Theme.Accent,
            Thickness = 2,
        })
        local titleLabel = createInstance("TextLabel", {
            Parent = notificationFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 5),
            Size = UDim2.new(1, -20, 0, 20),
            Font = Enum.Font.GothamBold,
            Text = title or "Notificação",
            TextColor3 = NebulaUI.Theme.Text,
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        local msgLabel = createInstance("TextLabel", {
            Parent = notificationFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 25),
            Size = UDim2.new(1, -20, 0, 25),
            Font = Enum.Font.Gotham,
            Text = message or "",
            TextColor3 = NebulaUI.Theme.TextSecondary,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
        })
        -- Animação de entrada
        notificationFrame.Position = UDim2.new(0, 10, 1, 10)
        tweenObject(notificationFrame, { Position = UDim2.new(0, 10, 1, -60) }, 0.3)
        -- Remover após duração
        task.delay(duration, function()
            tweenObject(notificationFrame, { Position = UDim2.new(0, 10, 1, 10) }, 0.3)
            task.delay(0.3, function()
                notificationFrame:Destroy()
            end)
        end)
    end

    -- Expor funções da biblioteca
    Window.Flags = Flags
    Window.Items = Items
    Window.Theme = NebulaUI.Theme

    function Window:SetTheme(themeTable)
        for prop, value in pairs(themeTable) do
            if NebulaUI.Theme[prop] then
                NebulaUI.Theme[prop] = value
            end
        end
        -- Atualizar visual dos elementos existentes (simplificado)
        -- Em produção, percorreria todos os itens
    end

    function Window:UpdateTheme(prop, value)
        NebulaUI.Theme[prop] = value
        -- Atualizar visual
    end

    CurrentWindow = Window
    return Window
end

-- Função global para notificações
function NebulaUI:Notify(title, message, duration)
    if CurrentWindow then
        CurrentWindow:Notify(title, message, duration)
    end
end

return NebulaUI
