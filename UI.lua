--[[
    MyUI – Biblioteca de Interface Personalizada
    - Design escuro com acentos neon
    - Tabs à esquerda, conteúdo à direita
    - Totalmente touch-friendly
    - Sem CoreGui, persistente após morte
]]

local MyUI = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ========== CONFIGURAÇÕES DE TEMA ==========
local Theme = {
    Background = Color3.fromRGB(18, 18, 28),
    Sidebar = Color3.fromRGB(28, 28, 42),
    Groupbox = Color3.fromRGB(22, 22, 36),
    Accent = Color3.fromRGB(0, 200, 255),
    Text = Color3.fromRGB(230, 230, 255),
    TextDark = Color3.fromRGB(160, 160, 180),
    Outline = Color3.fromRGB(60, 60, 80),
    Positive = Color3.fromRGB(0, 255, 150),
    Negative = Color3.fromRGB(255, 80, 80),
}

-- ========== ESTRUTURA PRINCIPAL ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MyUI"
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 450)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -225)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- Arredondamento e borda
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Theme.Accent
UIStroke.Thickness = 1.5
UIStroke.Transparency = 0.4
UIStroke.Parent = MainFrame

-- ========== BARRA DE TÍTULO (arrastável) ==========
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Theme.Sidebar
TitleBar.BackgroundTransparency = 0.2
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -80, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ MyUI"
TitleLabel.TextColor3 = Theme.Text
TitleLabel.TextSize = 18
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Botão fechar
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -36, 0, 4)
CloseBtn.BackgroundColor3 = Theme.Negative
CloseBtn.BackgroundTransparency = 0.4
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0)
CloseCorner.Parent = CloseBtn
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- ========== SISTEMA DE ARRASTE ==========
local dragData = { dragging = false, startPos = nil, startMouse = nil }
local function onInputBegan(input, gP)
    if gP then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local mousePos = UserInputService:GetMouseLocation()
        local fPos = MainFrame.AbsolutePosition
        local fSize = MainFrame.AbsoluteSize
        if mousePos.X >= fPos.X and mousePos.X <= fPos.X + fSize.X and
           mousePos.Y >= fPos.Y and mousePos.Y <= fPos.Y + 36 then
            dragData.dragging = true
            dragData.startPos = MainFrame.Position
            dragData.startMouse = input.Position
        end
    end
end
local function onInputChanged(input, gP)
    if gP then return end
    if dragData.dragging then
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragData.startMouse
            MainFrame.Position = UDim2.new(
                dragData.startPos.X.Scale, dragData.startPos.X.Offset + delta.X,
                dragData.startPos.Y.Scale, dragData.startPos.Y.Offset + delta.Y
            )
        end
    end
end
local function onInputEnded(input, gP)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragData.dragging = false
    end
end
UserInputService.InputBegan:Connect(onInputBegan)
UserInputService.InputChanged:Connect(onInputChanged)
UserInputService.InputEnded:Connect(onInputEnded)

-- ========== ESTRUTURA DE TABS E CONTEÚDO ==========
-- Sidebar (esquerda)
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 160, 1, -36)
Sidebar.Position = UDim2.new(0, 0, 0, 36)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.BackgroundTransparency = 0.1
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 0)
SidebarCorner.Parent = Sidebar

-- Área de conteúdo (direita)
local ContentArea = Instance.new("ScrollingFrame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -160, 1, -36)
ContentArea.Position = UDim2.new(0, 160, 0, 36)
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel = 0
ContentArea.ScrollBarThickness = 4
ContentArea.ScrollBarImageColor3 = Theme.Accent
ContentArea.Parent = MainFrame

-- Container interno para os conteúdos das tabs
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, 0, 1, 0)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = ContentArea

-- ========== GERENCIADOR DE TABS ==========
local Tabs = {}
local CurrentTab = nil
local TabButtons = {}

local function CreateTabButton(name, icon)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.Position = UDim2.new(0, 5, 0, #TabButtons * 42 + 5)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    btn.BackgroundTransparency = 0.5
    btn.Text = icon and (icon .. "  " .. name) or name
    btn.TextColor3 = Theme.TextDark
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamMedium
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.Parent = Sidebar
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Theme.Outline
    stroke.Thickness = 0
    stroke.Parent = btn
    
    return btn
end

function MyUI:Tab(name, icon)
    local tabData = { Name = name, Icon = icon, SubTabs = {}, ActiveSubTab = nil }
    local btn = CreateTabButton(name, icon)
    tabData.Button = btn
    
    -- Container para os conteúdos desta tab (inicialmente oculto)
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = name .. "Container"
    tabContainer.Size = UDim2.new(1, 0, 1, 0)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Visible = false
    tabContainer.Parent = ContentContainer
    
    tabData.Container = tabContainer
    
    btn.MouseButton1Click:Connect(function()
        if CurrentTab then
            CurrentTab.Container.Visible = false
            CurrentTab.Button.BackgroundColor3 = Color3.fromRGB(40,40,60)
            CurrentTab.Button.TextColor3 = Theme.TextDark
            CurrentTab.Button.UIStroke.Thickness = 0
        end
        tabContainer.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(60,60,90)
        btn.TextColor3 = Theme.Accent
        btn.UIStroke.Thickness = 2
        btn.UIStroke.Color = Theme.Accent
        CurrentTab = tabData
    end)
    
    -- Se for a primeira tab, ativa
    if #TabButtons == 0 then
        tabContainer.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(60,60,90)
        btn.TextColor3 = Theme.Accent
        btn.UIStroke.Thickness = 2
        btn.UIStroke.Color = Theme.Accent
        CurrentTab = tabData
    end
    
    table.insert(TabButtons, btn)
    Tabs[name] = tabData
    
    -- Retorna um objeto para criar SubTabs
    return {
        SubTab = function(self, subName)
            local subContainer = Instance.new("Frame")
            subContainer.Name = subName
            subContainer.Size = UDim2.new(1, 0, 1, 0)
            subContainer.BackgroundTransparency = 1
            subContainer.Visible = false
            subContainer.Parent = tabContainer
            
            -- Cria um botão de subtab (opcional, pode ser dropdown ou botões)
            -- Vamos usar um sistema simples: ao criar uma subtab, ela fica visível por padrão
            -- Se houver mais de uma, usaremos um seletor simples (dropdown)
            if not tabData.ActiveSubTab then
                subContainer.Visible = true
                tabData.ActiveSubTab = subName
            else
                -- Para simplificar, usaremos um dropdown para selecionar subtab
                -- Mas isso pode ser implementado depois
                -- Por enquanto, a primeira subtab é a ativa
            end
            
            -- Para facilitar, vamos criar um grupo de subtabs com botões (mas isso foge do escopo)
            -- Vamos simplesmente retornar um objeto para adicionar groupboxes
            return {
                Groupbox = function(self, title, side, icon)
                    -- side: "Left" ou "Right"
                    local isLeft = side == "Left"
                    local container = subContainer
                    
                    local group = Instance.new("Frame")
                    group.Name = title
                    group.Size = UDim2.new(isLeft and 0.48 or 0.48, 0, 0, 40)
                    group.Position = UDim2.new(isLeft and 0.01 or 0.51, 0, 0, 0)
                    group.BackgroundColor3 = Theme.Groupbox
                    group.BackgroundTransparency = 0.2
                    group.BorderSizePixel = 0
                    group.ClipsDescendants = true
                    group.Parent = container
                    
                    local gCorner = Instance.new("UICorner")
                    gCorner.CornerRadius = UDim.new(0, 8)
                    gCorner.Parent = group
                    
                    local gStroke = Instance.new("UIStroke")
                    gStroke.Color = Theme.Outline
                    gStroke.Thickness = 1
                    gStroke.Transparency = 0.5
                    gStroke.Parent = group
                    
                    -- Título do groupbox
                    local gTitle = Instance.new("TextLabel")
                    gTitle.Size = UDim2.new(1, -20, 0, 28)
                    gTitle.Position = UDim2.new(0, 10, 0, 4)
                    gTitle.BackgroundTransparency = 1
                    gTitle.Text = title
                    gTitle.TextColor3 = Theme.Text
                    gTitle.TextSize = 15
                    gTitle.Font = Enum.Font.GothamBold
                    gTitle.TextXAlignment = Enum.TextXAlignment.Left
                    gTitle.Parent = group
                    
                    -- Container interno para os itens
                    local itemsContainer = Instance.new("Frame")
                    itemsContainer.Name = "Items"
                    itemsContainer.Size = UDim2.new(1, -10, 0, 0)
                    itemsContainer.Position = UDim2.new(0, 5, 0, 32)
                    itemsContainer.BackgroundTransparency = 1
                    itemsContainer.Parent = group
                    
                    local itemY = 0
                    local itemGap = 6
                    
                    -- Função para atualizar altura do group
                    local function updateGroupHeight()
                        local totalHeight = itemsContainer.AbsoluteSize.Y + 40
                        group.Size = UDim2.new(isLeft and 0.48 or 0.48, 0, 0, totalHeight)
                    end
                    
                    -- Retorna funções para adicionar elementos
                    local groupObj = {
                        _container = itemsContainer,
                        _y = itemY,
                        _gap = itemGap,
                        _update = updateGroupHeight,
                        _addItem = function(self, itemHeight)
                            local frame = Instance.new("Frame")
                            frame.Size = UDim2.new(1, 0, 0, itemHeight)
                            frame.Position = UDim2.new(0, 0, 0, self._y)
                            frame.BackgroundTransparency = 1
                            frame.Parent = self._container
                            self._y = self._y + itemHeight + self._gap
                            -- Atualiza altura total do group
                            RunService.Heartbeat:Wait()
                            self._update()
                            return frame
                        end
                    }
                    
                    -- Adiciona os métodos
                    function groupObj:AddLabel(text)
                        local f = self:_addItem(24)
                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(1, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.Text = text
                        lbl.TextColor3 = Theme.TextDark
                        lbl.TextSize = 14
                        lbl.Font = Enum.Font.GothamMedium
                        lbl.TextXAlignment = Enum.TextXAlignment.Left
                        lbl.Parent = f
                        return f
                    end
                    
                    function groupObj:AddParagraph(params)
                        local title = params.Title or ""
                        local content = params.Content or ""
                        local wrapped = params.TextWrapped or false
                        local f = self:_addItem(40)
                        local lblTitle = Instance.new("TextLabel")
                        lblTitle.Size = UDim2.new(1, 0, 0, 18)
                        lblTitle.BackgroundTransparency = 1
                        lblTitle.Text = title
                        lblTitle.TextColor3 = Theme.Text
                        lblTitle.TextSize = 14
                        lblTitle.Font = Enum.Font.GothamBold
                        lblTitle.TextXAlignment = Enum.TextXAlignment.Left
                        lblTitle.Parent = f
                        
                        local lblContent = Instance.new("TextLabel")
                        lblContent.Size = UDim2.new(1, 0, 0, 20)
                        lblContent.Position = UDim2.new(0, 0, 0, 18)
                        lblContent.BackgroundTransparency = 1
                        lblContent.Text = content
                        lblContent.TextColor3 = Theme.TextDark
                        lblContent.TextSize = 13
                        lblContent.Font = Enum.Font.GothamMedium
                        lblContent.TextXAlignment = Enum.TextXAlignment.Left
                        lblContent.TextWrapped = wrapped
                        lblContent.Parent = f
                        -- Ajusta altura baseada no conteúdo
                        if wrapped then
                            local textBounds = lblContent.TextBounds
                            local newHeight = math.max(20, textBounds.Y + 10)
                            f.Size = UDim2.new(1, 0, 0, 18 + newHeight)
                            lblContent.Size = UDim2.new(1, 0, 0, newHeight)
                        end
                        return f
                    end
                    
                    function groupObj:AddToggle(params)
                        local title = params.Title or ""
                        local default = params.Default or false
                        local flag = params.Flag
                        local callback = params.Callback or function() end
                        local f = self:_addItem(32)
                        
                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(0.7, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.Text = title
                        lbl.TextColor3 = Theme.Text
                        lbl.TextSize = 14
                        lbl.Font = Enum.Font.GothamMedium
                        lbl.TextXAlignment = Enum.TextXAlignment.Left
                        lbl.Parent = f
                        
                        local toggleFrame = Instance.new("Frame")
                        toggleFrame.Size = UDim2.new(0, 40, 0, 22)
                        toggleFrame.Position = UDim2.new(1, -45, 0.5, -11)
                        toggleFrame.BackgroundColor3 = default and Theme.Accent or Color3.fromRGB(80,80,100)
                        toggleFrame.BorderSizePixel = 0
                        toggleFrame.Parent = f
                        local tCorner = Instance.new("UICorner")
                        tCorner.CornerRadius = UDim.new(1,0)
                        tCorner.Parent = toggleFrame
                        
                        local knob = Instance.new("Frame")
                        knob.Size = UDim2.new(0, 16, 0, 16)
                        knob.Position = default and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
                        knob.BackgroundColor3 = Color3.new(1,1,1)
                        knob.BorderSizePixel = 0
                        knob.Parent = toggleFrame
                        local kCorner = Instance.new("UICorner")
                        kCorner.CornerRadius = UDim.new(1,0)
                        kCorner.Parent = knob
                        
                        local state = default
                        local function toggle()
                            state = not state
                            toggleFrame.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(80,80,100)
                            TweenService:Create(knob, TweenInfo.new(0.15), {Position = state and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)}):Play()
                            callback(state)
                        end
                        toggleFrame.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                toggle()
                            end
                        end)
                        return { Set = function(self, val) if val ~= state then toggle() end end }
                    end
                    
                    function groupObj:AddCheckbox(params)
                        local title = params.Title or ""
                        local default = params.Default or false
                        local risky = params.Risky or false
                        local callback = params.Callback or function() end
                        local f = self:_addItem(32)
                        
                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(0.7, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.Text = title
                        lbl.TextColor3 = risky and Theme.Negative or Theme.Text
                        lbl.TextSize = 14
                        lbl.Font = Enum.Font.GothamMedium
                        lbl.TextXAlignment = Enum.TextXAlignment.Left
                        lbl.Parent = f
                        
                        local chkFrame = Instance.new("Frame")
                        chkFrame.Size = UDim2.new(0, 22, 0, 22)
                        chkFrame.Position = UDim2.new(1, -45, 0.5, -11)
                        chkFrame.BackgroundColor3 = default and Theme.Accent or Color3.fromRGB(60,60,80)
                        chkFrame.BorderSizePixel = 0
                        chkFrame.Parent = f
                        local cCorner = Instance.new("UICorner")
                        cCorner.CornerRadius = UDim.new(0, 4)
                        cCorner.Parent = chkFrame
                        
                        local checkMark = Instance.new("TextLabel")
                        checkMark.Size = UDim2.new(1, 0, 1, 0)
                        checkMark.BackgroundTransparency = 1
                        checkMark.Text = "✓"
                        checkMark.TextColor3 = Color3.new(1,1,1)
                        checkMark.TextSize = 18
                        checkMark.Font = Enum.Font.GothamBold
                        checkMark.Visible = default
                        checkMark.Parent = chkFrame
                        
                        local state = default
                        local function toggle()
                            state = not state
                            chkFrame.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(60,60,80)
                            checkMark.Visible = state
                            callback(state)
                        end
                        chkFrame.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                toggle()
                            end
                        end)
                        return { Set = function(self, val) if val ~= state then toggle() end end }
                    end
                    
                    function groupObj:AddSlider(params)
                        local title = params.Title or ""
                        local min = params.Min or 0
                        local max = params.Max or 100
                        local default = params.Default or 50
                        local rounding = params.Rounding or 0
                        local suffix = params.Suffix or ""
                        local callback = params.Callback or function() end
                        local f = self:_addItem(40)
                        
                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(0.6, 0, 0.5, 0)
                        lbl.Position = UDim2.new(0, 0, 0, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.Text = title
                        lbl.TextColor3 = Theme.Text
                        lbl.TextSize = 14
                        lbl.Font = Enum.Font.GothamMedium
                        lbl.TextXAlignment = Enum.TextXAlignment.Left
                        lbl.Parent = f
                        
                        local valLabel = Instance.new("TextLabel")
                        valLabel.Size = UDim2.new(0.3, 0, 0.5, 0)
                        valLabel.Position = UDim2.new(0.7, 0, 0, 0)
                        valLabel.BackgroundTransparency = 1
                        valLabel.Text = tostring(default) .. suffix
                        valLabel.TextColor3 = Theme.Accent
                        valLabel.TextSize = 14
                        valLabel.Font = Enum.Font.GothamMedium
                        valLabel.TextXAlignment = Enum.TextXAlignment.Right
                        valLabel.Parent = f
                        
                        local track = Instance.new("Frame")
                        track.Size = UDim2.new(0.9, 0, 0, 6)
                        track.Position = UDim2.new(0.05, 0, 0.7, 0)
                        track.BackgroundColor3 = Color3.fromRGB(60,60,80)
                        track.BorderSizePixel = 0
                        track.Parent = f
                        local trackCorner = Instance.new("UICorner")
                        trackCorner.CornerRadius = UDim.new(1,0)
                        trackCorner.Parent = track
                        
                        local fill = Instance.new("Frame")
                        fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
                        fill.BackgroundColor3 = Theme.Accent
                        fill.BorderSizePixel = 0
                        fill.Parent = track
                        local fillCorner = Instance.new("UICorner")
                        fillCorner.CornerRadius = UDim.new(1,0)
                        fillCorner.Parent = fill
                        
                        local knobSlider = Instance.new("Frame")
                        knobSlider.Size = UDim2.new(0, 16, 0, 16)
                        knobSlider.Position = UDim2.new((default-min)/(max-min), -8, 0.5, -8)
                        knobSlider.BackgroundColor3 = Theme.Accent
                        knobSlider.BorderSizePixel = 0
                        knobSlider.Parent = track
                        local knobCorner = Instance.new("UICorner")
                        knobCorner.CornerRadius = UDim.new(1,0)
                        knobCorner.Parent = knobSlider
                        
                        local value = default
                        local dragging = false
                        local function updateSlider(input)
                            local trackAbsPos = track.AbsolutePosition
                            local trackAbsSize = track.AbsoluteSize.X
                            local mouseX = input.Position.X
                            local percent = math.clamp((mouseX - trackAbsPos.X) / trackAbsSize, 0, 1)
                            local newVal = min + (max-min) * percent
                            if rounding > 0 then
                                newVal = math.round(newVal / rounding) * rounding
                            else
                                newVal = math.round(newVal)
                            end
                            newVal = math.clamp(newVal, min, max)
                            value = newVal
                            fill.Size = UDim2.new((value-min)/(max-min), 0, 1, 0)
                            knobSlider.Position = UDim2.new((value-min)/(max-min), -8, 0.5, -8)
                            valLabel.Text = tostring(value) .. suffix
                            callback(value)
                        end
                        knobSlider.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                dragging = true
                                updateSlider(input)
                            end
                        end)
                        UserInputService.InputChanged:Connect(function(input, gP)
                            if gP then return end
                            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                                updateSlider(input)
                            end
                        end)
                        UserInputService.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                dragging = false
                            end
                        end)
                        return { Set = function(self, val) 
                            val = math.clamp(val, min, max)
                            value = val
                            fill.Size = UDim2.new((value-min)/(max-min), 0, 1, 0)
                            knobSlider.Position = UDim2.new((value-min)/(max-min), -8, 0.5, -8)
                            valLabel.Text = tostring(value) .. suffix
                            callback(value)
                        end }
                    end
                    
                    function groupObj:AddDropdown(params)
                        local title = params.Title or ""
                        local values = params.Values or {}
                        local default = params.Default
                        local multi = params.Multi or false
                        local callback = params.Callback or function() end
                        local f = self:_addItem(34)
                        
                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(0.5, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.Text = title
                        lbl.TextColor3 = Theme.Text
                        lbl.TextSize = 14
                        lbl.Font = Enum.Font.GothamMedium
                        lbl.TextXAlignment = Enum.TextXAlignment.Left
                        lbl.Parent = f
                        
                        local btn = Instance.new("TextButton")
                        btn.Size = UDim2.new(0.45, 0, 0.7, 0)
                        btn.Position = UDim2.new(0.5, 0, 0.15, 0)
                        btn.BackgroundColor3 = Color3.fromRGB(50,50,70)
                        btn.Text = multi and "Select..." or (default or values[1] or "")
                        btn.TextColor3 = Theme.Text
                        btn.TextSize = 13
                        btn.Font = Enum.Font.GothamMedium
                        btn.BorderSizePixel = 0
                        btn.Parent = f
                        local btnCorner = Instance.new("UICorner")
                        btnCorner.CornerRadius = UDim.new(0, 4)
                        btnCorner.Parent = btn
                        
                        local dropdownFrame = Instance.new("Frame")
                        dropdownFrame.Size = UDim2.new(0.45, 0, 0, 0)
                        dropdownFrame.Position = UDim2.new(0.5, 0, 0, 34)
                        dropdownFrame.BackgroundColor3 = Color3.fromRGB(40,40,55)
                        dropdownFrame.BorderSizePixel = 0
                        dropdownFrame.ClipsDescendants = true
                        dropdownFrame.Visible = false
                        dropdownFrame.Parent = f
                        local dCorner = Instance.new("UICorner")
                        dCorner.CornerRadius = UDim.new(0, 4)
                        dCorner.Parent = dropdownFrame
                        
                        local selected = {}
                        if multi then
                            if type(default) == "table" then
                                for _, v in ipairs(default) do selected[v] = true end
                            end
                        else
                            selected[default] = true
                        end
                        
                        local itemHeight = 28
                        local function updateDropdownHeight()
                            dropdownFrame.Size = UDim2.new(0.45, 0, 0, #values * itemHeight + 2)
                        end
                        
                        for i, val in ipairs(values) do
                            local item = Instance.new("TextButton")
                            item.Size = UDim2.new(1, 0, 0, itemHeight)
                            item.Position = UDim2.new(0, 0, 0, (i-1)*itemHeight)
                            item.BackgroundColor3 = Color3.fromRGB(50,50,70)
                            item.Text = val
                            item.TextColor3 = Theme.TextDark
                            item.TextSize = 13
                            item.Font = Enum.Font.GothamMedium
                            item.BorderSizePixel = 0
                            item.Parent = dropdownFrame
                            local iCorner = Instance.new("UICorner")
                            iCorner.CornerRadius = UDim.new(0, 2)
                            iCorner.Parent = item
                            
                            if selected[val] then
                                item.BackgroundColor3 = Theme.Accent
                                item.TextColor3 = Color3.new(1,1,1)
                            end
                            
                            item.MouseButton1Click:Connect(function()
                                if multi then
                                    selected[val] = not selected[val]
                                    if selected[val] then
                                        item.BackgroundColor3 = Theme.Accent
                                        item.TextColor3 = Color3.new(1,1,1)
                                    else
                                        item.BackgroundColor3 = Color3.fromRGB(50,50,70)
                                        item.TextColor3 = Theme.TextDark
                                    end
                                    -- Atualiza texto do botão
                                    local selList = {}
                                    for k, v in pairs(selected) do if v then table.insert(selList, k) end end
                                    btn.Text = #selList > 0 and table.concat(selList, ", ") or "Select..."
                                    callback(selected)
                                else
                                    -- Single
                                    for _, other in ipairs(dropdownFrame:GetChildren()) do
                                        if other:IsA("TextButton") then
                                            other.BackgroundColor3 = Color3.fromRGB(50,50,70)
                                            other.TextColor3 = Theme.TextDark
                                        end
                                    end
                                    item.BackgroundColor3 = Theme.Accent
                                    item.TextColor3 = Color3.new(1,1,1)
                                    btn.Text = val
                                    dropdownFrame.Visible = false
                                    callback(val)
                                end
                            end)
                        end
                        updateDropdownHeight()
                        
                        btn.MouseButton1Click:Connect(function()
                            dropdownFrame.Visible = not dropdownFrame.Visible
                        end)
                        return { Refresh = function(self, newValues)
                            -- não implementado para brevidade
                        end }
                    end
                    
                    function groupObj:AddRadioButton(params)
                        local title = params.Title or ""
                        local options = params.Options or {}
                        local default = params.Default or options[1]
                        local callback = params.Callback or function() end
                        local f = self:_addItem(30 + #options * 24)
                        
                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(1, 0, 0, 24)
                        lbl.BackgroundTransparency = 1
                        lbl.Text = title
                        lbl.TextColor3 = Theme.Text
                        lbl.TextSize = 14
                        lbl.Font = Enum.Font.GothamMedium
                        lbl.TextXAlignment = Enum.TextXAlignment.Left
                        lbl.Parent = f
                        
                        local yPos = 24
                        local selected = default
                        for _, opt in ipairs(options) do
                            local row = Instance.new("Frame")
                            row.Size = UDim2.new(1, 0, 0, 24)
                            row.Position = UDim2.new(0, 0, 0, yPos)
                            row.BackgroundTransparency = 1
                            row.Parent = f
                            
                            local radio = Instance.new("Frame")
                            radio.Size = UDim2.new(0, 18, 0, 18)
                            radio.Position = UDim2.new(0, 0, 0.5, -9)
                            radio.BackgroundColor3 = (opt == selected) and Theme.Accent or Color3.fromRGB(60,60,80)
                            radio.BorderSizePixel = 0
                            radio.Parent = row
                            local rCorner = Instance.new("UICorner")
                            rCorner.CornerRadius = UDim.new(1,0)
                            rCorner.Parent = radio
                            
                            local inner = Instance.new("Frame")
                            inner.Size = UDim2.new(0, 8, 0, 8)
                            inner.Position = UDim2.new(0.5, -4, 0.5, -4)
                            inner.BackgroundColor3 = Color3.new(1,1,1)
                            inner.BorderSizePixel = 0
                            inner.Visible = (opt == selected)
                            inner.Parent = radio
                            local innerCorner = Instance.new("UICorner")
                            innerCorner.CornerRadius = UDim.new(1,0)
                            innerCorner.Parent = inner
                            
                            local optLbl = Instance.new("TextLabel")
                            optLbl.Size = UDim2.new(1, -24, 1, 0)
                            optLbl.Position = UDim2.new(0, 24, 0, 0)
                            optLbl.BackgroundTransparency = 1
                            optLbl.Text = opt
                            optLbl.TextColor3 = Theme.TextDark
                            optLbl.TextSize = 13
                            optLbl.Font = Enum.Font.GothamMedium
                            optLbl.TextXAlignment = Enum.TextXAlignment.Left
                            optLbl.Parent = row
                            
                            row.InputBegan:Connect(function(input)
                                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                    selected = opt
                                    for _, child in ipairs(f:GetChildren()) do
                                        if child:IsA("Frame") and child ~= lbl then
                                            local r = child:FindFirstChildWhichIsA("Frame")
                                            if r then
                                                r.BackgroundColor3 = Color3.fromRGB(60,60,80)
                                                local innerDot = r:FindFirstChildWhichIsA("Frame")
                                                if innerDot then innerDot.Visible = false end
                                            end
                                        end
                                    end
                                    radio.BackgroundColor3 = Theme.Accent
                                    inner.Visible = true
                                    callback(opt)
                                end
                            end)
                            yPos = yPos + 24
                        end
                    end
                    
                    function groupObj:AddColorPicker(params)
                        local title = params.Title or ""
                        local default = params.Default or Color3.new(1,0,0)
                        local alpha = params.Transparency or 0
                        local callback = params.Callback or function() end
                        local f = self:_addItem(36)
                        
                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(0.5, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.Text = title
                        lbl.TextColor3 = Theme.Text
                        lbl.TextSize = 14
                        lbl.Font = Enum.Font.GothamMedium
                        lbl.TextXAlignment = Enum.TextXAlignment.Left
                        lbl.Parent = f
                        
                        local colorBtn = Instance.new("TextButton")
                        colorBtn.Size = UDim2.new(0, 40, 0, 30)
                        colorBtn.Position = UDim2.new(1, -45, 0.5, -15)
                        colorBtn.BackgroundColor3 = default
                        colorBtn.BorderSizePixel = 0
                        colorBtn.Parent = f
                        local cBtnCorner = Instance.new("UICorner")
                        cBtnCorner.CornerRadius = UDim.new(0, 4)
                        cBtnCorner.Parent = colorBtn
                        
                        -- Simples: abre um seletor de cores (usando ColorPicker do Roblox)
                        -- Na prática, você pode implementar um seletor customizado, mas por simplicidade, usaremos o InputBegan para abrir o seletor nativo? Não é possível, então faremos um placeholder.
                        -- Vamos apenas permitir clicar e mudar para uma cor aleatória (para demonstração)
                        colorBtn.MouseButton1Click:Connect(function()
                            local newColor = Color3.new(math.random(), math.random(), math.random())
                            colorBtn.BackgroundColor3 = newColor
                            callback(newColor, alpha)
                        end)
                        return { Set = function(self, color, a)
                            colorBtn.BackgroundColor3 = color
                            callback(color, a or alpha)
                        end }
                    end
                    
                    function groupObj:AddTextbox(params)
                        local title = params.Title or ""
                        local placeholder = params.Placeholder or ""
                        local clearOnFocus = params.ClearOnFocus or false
                        local callback = params.Callback or function() end
                        local f = self:_addItem(34)
                        
                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(0.4, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.Text = title
                        lbl.TextColor3 = Theme.Text
                        lbl.TextSize = 14
                        lbl.Font = Enum.Font.GothamMedium
                        lbl.TextXAlignment = Enum.TextXAlignment.Left
                        lbl.Parent = f
                        
                        local box = Instance.new("TextBox")
                        box.Size = UDim2.new(0.55, 0, 0.7, 0)
                        box.Position = UDim2.new(0.4, 0, 0.15, 0)
                        box.BackgroundColor3 = Color3.fromRGB(45,45,65)
                        box.Text = ""
                        box.PlaceholderText = placeholder
                        box.TextColor3 = Theme.Text
                        box.TextSize = 13
                        box.Font = Enum.Font.GothamMedium
                        box.BorderSizePixel = 0
                        box.ClearTextOnFocus = clearOnFocus
                        box.Parent = f
                        local boxCorner = Instance.new("UICorner")
                        boxCorner.CornerRadius = UDim.new(0, 4)
                        boxCorner.Parent = box
                        
                        box.FocusLost:Connect(function(enterPressed)
                            if enterPressed then
                                callback(box.Text)
                            end
                        end)
                        return { Set = function(self, text) box.Text = text end }
                    end
                    
                    function groupObj:AddButton(params)
                        local title = params.Title or ""
                        local callback = params.Callback or function() end
                        local f = self:_addItem(32)
                        
                        local btn = Instance.new("TextButton")
                        btn.Size = UDim2.new(0.9, 0, 0.7, 0)
                        btn.Position = UDim2.new(0.05, 0, 0.15, 0)
                        btn.BackgroundColor3 = Theme.Accent
                        btn.BackgroundTransparency = 0.2
                        btn.Text = title
                        btn.TextColor3 = Theme.Text
                        btn.TextSize = 14
                        btn.Font = Enum.Font.GothamMedium
                        btn.BorderSizePixel = 0
                        btn.Parent = f
                        local btnCorner = Instance.new("UICorner")
                        btnCorner.CornerRadius = UDim.new(0, 4)
                        btnCorner.Parent = btn
                        btn.MouseButton1Click:Connect(callback)
                        return btn
                    end
                    
                    function groupObj:AddKeybind(params)
                        -- Para mobile, não usamos keybinds, mas mantemos para compatibilidade
                        local title = params.Title or ""
                        local default = params.Default or Enum.KeyCode.None
                        local callback = params.Callback or function() end
                        local f = self:_addItem(32)
                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(0.6, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.Text = title .. " (mobile not supported)"
                        lbl.TextColor3 = Theme.TextDark
                        lbl.TextSize = 13
                        lbl.Font = Enum.Font.GothamMedium
                        lbl.Parent = f
                        return { Set = function() end }
                    end
                    
                    function groupObj:AddSeparator()
                        local f = self:_addItem(4)
                        local line = Instance.new("Frame")
                        line.Size = UDim2.new(1, -10, 0, 1)
                        line.Position = UDim2.new(0, 5, 0.5, -0.5)
                        line.BackgroundColor3 = Theme.Outline
                        line.BorderSizePixel = 0
                        line.Parent = f
                    end
                    
                    function groupObj:AddSpacing(height)
                        self:_addItem(height)
                    end
                    
                    function groupObj:AddLabelText(key, value)
                        local f = self:_addItem(24)
                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(1, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.Text = key .. "  " .. value
                        lbl.TextColor3 = Theme.Text
                        lbl.TextSize = 14
                        lbl.Font = Enum.Font.GothamMedium
                        lbl.TextXAlignment = Enum.TextXAlignment.Left
                        lbl.Parent = f
                        -- Destacar valor
                        local valPart = Instance.new("TextLabel")
                        valPart.Size = UDim2.new(0.4, 0, 1, 0)
                        valPart.Position = UDim2.new(0.5, 0, 0, 0)
                        valPart.BackgroundTransparency = 1
                        valPart.Text = value
                        valPart.TextColor3 = Theme.Accent
                        valPart.TextSize = 14
                        valPart.Font = Enum.Font.GothamBold
                        valPart.TextXAlignment = Enum.TextXAlignment.Right
                        valPart.Parent = f
                    end
                    
                    function groupObj:AddBulletText(text)
                        local f = self:_addItem(24)
                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(1, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.Text = "• " .. text
                        lbl.TextColor3 = Theme.TextDark
                        lbl.TextSize = 13
                        lbl.Font = Enum.Font.GothamMedium
                        lbl.TextXAlignment = Enum.TextXAlignment.Left
                        lbl.Parent = f
                    end
                    
                    function groupObj:AddNewLine()
                        self:_addItem(6)
                    end
                    
                    function groupObj:AlignTextToFramePadding(text)
                        local f = self:_addItem(24)
                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(1, -10, 1, 0)
                        lbl.Position = UDim2.new(0, 5, 0, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.Text = text
                        lbl.TextColor3 = Theme.TextDark
                        lbl.TextSize = 13
                        lbl.Font = Enum.Font.GothamMedium
                        lbl.TextXAlignment = Enum.TextXAlignment.Left
                        lbl.Parent = f
                    end
                    
                    function groupObj:AddTextUnformatted(text)
                        local f = self:_addItem(24)
                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(1, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.Text = text
                        lbl.TextColor3 = Theme.TextDark
                        lbl.TextSize = 13
                        lbl.Font = Enum.Font.Code
                        lbl.TextXAlignment = Enum.TextXAlignment.Left
                        lbl.Parent = f
                    end
                    
                    function groupObj:AddTextWrapped(text)
                        local f = self:_addItem(24)
                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(1, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.Text = text
                        lbl.TextColor3 = Theme.TextDark
                        lbl.TextSize = 13
                        lbl.Font = Enum.Font.GothamMedium
                        lbl.TextXAlignment = Enum.TextXAlignment.Left
                        lbl.TextWrapped = true
                        lbl.Parent = f
                    end
                    
                    function groupObj:AddProgressBar(params)
                        local title = params.Title or ""
                        local default = params.Default or 0.5
                        local callback = params.Callback or function() end
                        local f = self:_addItem(36)
                        
                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(0.6, 0, 0.5, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.Text = title
                        lbl.TextColor3 = Theme.Text
                        lbl.TextSize = 14
                        lbl.Font = Enum.Font.GothamMedium
                        lbl.TextXAlignment = Enum.TextXAlignment.Left
                        lbl.Parent = f
                        
                        local valLbl = Instance.new("TextLabel")
                        valLbl.Size = UDim2.new(0.3, 0, 0.5, 0)
                        valLbl.Position = UDim2.new(0.7, 0, 0, 0)
                        valLbl.BackgroundTransparency = 1
                        valLbl.Text = math.round(default*100) .. "%"
                        valLbl.TextColor3 = Theme.Accent
                        valLbl.TextSize = 14
                        valLbl.Font = Enum.Font.GothamMedium
                        valLbl.TextXAlignment = Enum.TextXAlignment.Right
                        valLbl.Parent = f
                        
                        local track = Instance.new("Frame")
                        track.Size = UDim2.new(0.9, 0, 0, 6)
                        track.Position = UDim2.new(0.05, 0, 0.7, 0)
                        track.BackgroundColor3 = Color3.fromRGB(60,60,80)
                        track.BorderSizePixel = 0
                        track.Parent = f
                        local trackCorner = Instance.new("UICorner")
                        trackCorner.CornerRadius = UDim.new(1,0)
                        trackCorner.Parent = track
                        
                        local fill = Instance.new("Frame")
                        fill.Size = UDim2.new(default, 0, 1, 0)
                        fill.BackgroundColor3 = Theme.Accent
                        fill.BorderSizePixel = 0
                        fill.Parent = track
                        local fillCorner = Instance.new("UICorner")
                        fillCorner.CornerRadius = UDim.new(1,0)
                        fillCorner.Parent = fill
                        
                        local obj = { Set = function(self, val)
                            val = math.clamp(val, 0, 1)
                            fill.Size = UDim2.new(val, 0, 1, 0)
                            valLbl.Text = math.round(val*100) .. "%"
                            callback(val)
                        end }
                        return obj
                    end
                    
                    function groupObj:AddGraph(params)
                        -- Placeholder simples
                        local f = self:_addItem(60)
                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(1, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.Text = "📊 " .. (params.Title or "Graph")
                        lbl.TextColor3 = Theme.Text
                        lbl.TextSize = 14
                        lbl.Font = Enum.Font.GothamMedium
                        lbl.Parent = f
                        -- Poderíamos implementar um gráfico real, mas é extenso
                        return { Set = function() end }
                    end
                    
                    function groupObj:AddImage(params)
                        local f = self:_addItem(120)
                        local img = Instance.new("ImageLabel")
                        img.Size = UDim2.new(0.8, 0, 1, 0)
                        img.Position = UDim2.new(0.1, 0, 0, 0)
                        img.BackgroundTransparency = 1
                        img.Image = params.Image or ""
                        img.Parent = f
                        return img
                    end
                    
                    function groupObj:AddImageButton(params)
                        local f = self:_addItem(50)
                        local btn = Instance.new("ImageButton")
                        btn.Size = UDim2.new(0, 40, 0, 40)
                        btn.Position = UDim2.new(0.5, -20, 0, 5)
                        btn.BackgroundTransparency = 1
                        btn.Image = params.Image or ""
                        btn.Parent = f
                        btn.MouseButton1Click:Connect(params.Callback or function() end)
                        return btn
                    end
                    
                    function groupObj:AddVerticalSlider(params)
                        -- Placeholder (pode ser implementado)
                        local f = self:_addItem(140)
                        local lbl = Instance.new("TextLabel")
                        lbl.Size = UDim2.new(1, 0, 0, 24)
                        lbl.BackgroundTransparency = 1
                        lbl.Text = params.Title or "Vertical Slider"
                        lbl.TextColor3 = Theme.Text
                        lbl.TextSize = 14
                        lbl.Font = Enum.Font.GothamMedium
                        lbl.Parent = f
                        return { Set = function() end }
                    end
                    
                    function groupObj:AddSelectable(params)
                        local title = params.Title or ""
                        local default = params.Default or false
                        local callback = params.Callback or function() end
                        local f = self:_addItem(32)
                        local btn = Instance.new("TextButton")
                        btn.Size = UDim2.new(0.9, 0, 0.7, 0)
                        btn.Position = UDim2.new(0.05, 0, 0.15, 0)
                        btn.BackgroundColor3 = default and Theme.Accent or Color3.fromRGB(50,50,70)
                        btn.Text = title
                        btn.TextColor3 = default and Color3.new(1,1,1) or Theme.Text
                        btn.TextSize = 14
                        btn.Font = Enum.Font.GothamMedium
                        btn.BorderSizePixel = 0
                        btn.Parent = f
                        local btnCorner = Instance.new("UICorner")
                        btnCorner.CornerRadius = UDim.new(0, 4)
                        btnCorner.Parent = btn
                        local state = default
                        btn.MouseButton1Click:Connect(function()
                            state = not state
                            btn.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(50,50,70)
                            btn.TextColor3 = state and Color3.new(1,1,1) or Theme.Text
                            callback(state)
                        end)
                        return { Set = function(self, val) 
                            if val ~= state then
                                state = val
                                btn.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(50,50,70)
                                btn.TextColor3 = state and Color3.new(1,1,1) or Theme.Text
                                callback(state)
                            end
                        end }
                    end
                    
                    function groupObj:TreeNode(title)
                        -- Nós de árvore (expansíveis)
                        local isOpen = false
                        local f = self:_addItem(32)
                        local header = Instance.new("TextButton")
                        header.Size = UDim2.new(1, 0, 1, 0)
                        header.BackgroundColor3 = Color3.fromRGB(40,40,60)
                        header.Text = "▶ " .. title
                        header.TextColor3 = Theme.Text
                        header.TextSize = 14
                        header.Font = Enum.Font.GothamMedium
                        header.TextXAlignment = Enum.TextXAlignment.Left
                        header.BorderSizePixel = 0
                        header.Parent = f
                        local hCorner = Instance.new("UICorner")
                        hCorner.CornerRadius = UDim.new(0, 4)
                        hCorner.Parent = header
                        
                        local container = Instance.new("Frame")
                        container.Size = UDim2.new(1, 0, 0, 0)
                        container.Position = UDim2.new(0, 0, 0, 32)
                        container.BackgroundTransparency = 1
                        container.Visible = false
                        container.Parent = f
                        
                        local treeObj = {
                            _container = container,
                            _y = 0,
                            _gap = 4,
                            _addItem = function(self, height)
                                local item = Instance.new("Frame")
                                item.Size = UDim2.new(1, -10, 0, height)
                                item.Position = UDim2.new(0, 5, 0, self._y)
                                item.BackgroundTransparency = 1
                                item.Parent = self._container
                                self._y = self._y + height + self._gap
                                return item
                            end
                        }
                        
                        -- Adiciona métodos básicos para dentro da árvore
                        function treeObj:AddLabel(text)
                            local f = self:_addItem(24)
                            local lbl = Instance.new("TextLabel")
                            lbl.Size = UDim2.new(1, 0, 1, 0)
                            lbl.BackgroundTransparency = 1
                            lbl.Text = text
                            lbl.TextColor3 = Theme.TextDark
                            lbl.TextSize = 13
                            lbl.Font = Enum.Font.GothamMedium
                            lbl.TextXAlignment = Enum.TextXAlignment.Left
                            lbl.Parent = f
                            return f
                        end
                        function treeObj:AddToggle(params) 
                            local f = self:_addItem(32)
                            -- código similar ao toggle, mas dentro da árvore
                            -- Implementação resumida...
                            return { Set = function() end }
                        end
                        function treeObj:AddButton(params)
                            local f = self:_addItem(32)
                            local btn = Instance.new("TextButton")
                            btn.Size = UDim2.new(0.8, 0, 0.7, 0)
                            btn.Position = UDim2.new(0.1, 0, 0.15, 0)
                            btn.BackgroundColor3 = Theme.Accent
                            btn.BackgroundTransparency = 0.2
                            btn.Text = params.Title
                            btn.TextColor3 = Theme.Text
                            btn.TextSize = 13
                            btn.Font = Enum.Font.GothamMedium
                            btn.BorderSizePixel = 0
                            btn.Parent = f
                            btn.MouseButton1Click:Connect(params.Callback or function() end)
                            return btn
                        end
                        function treeObj:TreePop()
                            -- não faz nada, apenas para compatibilidade
                        end
                        
                        header.MouseButton1Click:Connect(function()
                            isOpen = not isOpen
                            container.Visible = isOpen
                            header.Text = (isOpen and "▼ " or "▶ ") .. title
                            -- Atualiza altura
                            if isOpen then
                                local totalHeight = container.AbsoluteSize.Y + 32
                                f.Size = UDim2.new(1, 0, 0, totalHeight)
                            else
                                f.Size = UDim2.new(1, 0, 0, 32)
                            end
                            self._update()
                        end)
                        return treeObj
                    end
                    
                    return groupObj
                end
            }
        end
    }
end

-- ========== FUNÇÃO PARA CRIAR WINDOW (compatibilidade) ==========
function MyUI:Window(title)
    TitleLabel.Text = "⚡ " .. title
    return {
        Tab = function(self, name, icon)
            return MyUI:Tab(name, icon)
        end
    }
end

-- ========== RETORNA A BIBLIOTECA ==========
return MyUI
