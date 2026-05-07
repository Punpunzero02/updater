local HydraUI = {}
HydraUI.__index = HydraUI

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")



function HydraUI.new(theme)
    local self = setmetatable({}, HydraUI)
    self.T = theme
    self._trackedElements = {}
    self._trackedStrokes  = {}
    return self
end



function HydraUI:trackElement(elem, colorKey, prop)
    table.insert(self._trackedElements, { elem = elem, colorKey = colorKey, prop = prop })
end

function HydraUI:trackStroke(stroke, colorKey)
    table.insert(self._trackedStrokes, { stroke = stroke, colorKey = colorKey })
end

function HydraUI:applyTheme(newTheme)
    self.T = newTheme
    for _, t in ipairs(self._trackedElements) do
        if t.elem and t.elem.Parent then
            local val = self.T[t.colorKey]
            if val then pcall(function() t.elem[t.prop] = val end) end
        end
    end
    for _, t in ipairs(self._trackedStrokes) do
        if t.stroke and t.stroke.Parent then
            local val = self.T[t.colorKey]
            if val then pcall(function() t.stroke.Color = val end) end
        end
    end
end



-- UICorner
function HydraUI:corner(parent, radius)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, radius or 4)
    return c
end

-- UIStroke (default STROKE key)
function HydraUI:stroke(parent, col, thickness)
    local s = Instance.new("UIStroke", parent)
    s.Color = col or self.T.STROKE
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    self:trackStroke(s, "STROKE")
    return s
end

-- UIStroke with specific colorKey tracking
function HydraUI:strokeKeyed(parent, colorKey, thickness)
    local s = Instance.new("UIStroke", parent)
    s.Color = self.T[colorKey] or self.T.STROKE
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    self:trackStroke(s, colorKey)
    return s
end

-- Frame
function HydraUI:frame(parent, sz, pos, bgKey, transparency)
    local f = Instance.new("Frame")
    f.Size               = sz  or UDim2.new(1, 0, 1, 0)
    f.Position           = pos or UDim2.new(0, 0, 0, 0)
    f.BackgroundColor3   = (type(bgKey) == "string") and (self.T[bgKey] or self.T.PANEL) or (bgKey or self.T.PANEL)
    f.BackgroundTransparency = transparency or 0
    f.BorderSizePixel    = 0
    f.Parent             = parent
    if type(bgKey) == "string" then
        self:trackElement(f, bgKey, "BackgroundColor3")
    end
    return f
end

-- TextLabel
function HydraUI:label(parent, text, sz, pos, colorKey, fontSize, xAlign)
    local l = Instance.new("TextLabel")
    l.Size               = sz  or UDim2.new(1, 0, 0, 14)
    l.Position           = pos or UDim2.new(0, 0, 0, 0)
    l.BackgroundTransparency = 1
    l.Text               = text or ""
    l.TextColor3         = (type(colorKey) == "string") and (self.T[colorKey] or self.T.TEXT) or (colorKey or self.T.TEXT)
    l.Font               = Enum.Font.GothamBold
    l.TextSize           = fontSize or 10
    l.TextXAlignment     = xAlign or Enum.TextXAlignment.Left
    l.TextTruncate       = Enum.TextTruncate.AtEnd
    l.Parent             = parent
    if type(colorKey) == "string" then
        self:trackElement(l, colorKey, "TextColor3")
    end
    return l
end

-- TextButton
function HydraUI:button(parent, text, sz, pos, bgKey, textColorKey, fontSize)
    local b = Instance.new("TextButton")
    b.Size             = sz  or UDim2.new(0, 60, 0, 20)
    b.Position         = pos or UDim2.new(0, 0, 0, 0)
    b.BackgroundColor3 = (type(bgKey) == "string") and (self.T[bgKey] or self.T.BTN) or (bgKey or self.T.BTN)
    b.BorderSizePixel  = 0
    b.Text             = text or ""
    b.TextColor3       = (type(textColorKey) == "string") and (self.T[textColorKey] or self.T.TEXT) or (textColorKey or self.T.TEXT)
    b.Font             = Enum.Font.GothamBold
    b.TextSize         = fontSize or 9
    b.AutoButtonColor  = false
    b.Parent           = parent
    self:corner(b, 3)
    if type(bgKey) == "string" then self:trackElement(b, bgKey, "BackgroundColor3") end
    if type(textColorKey) == "string" then self:trackElement(b, textColorKey, "TextColor3") end
    return b
end

-- TextBox
function HydraUI:input(parent, default, placeholder, sz, pos)
    local b = Instance.new("TextBox")
    b.Size               = sz  or UDim2.new(0, 60, 0, 18)
    b.Position           = pos or UDim2.new(0, 0, 0, 0)
    b.BackgroundColor3   = self.T.ROW
    b.BorderSizePixel    = 0
    b.Text               = tostring(default or "")
    b.PlaceholderText    = placeholder or ""
    b.TextColor3         = self.T.ACCENT
    b.PlaceholderColor3  = self.T.DIM
    b.Font               = Enum.Font.Gotham
    b.TextSize           = 9
    b.ClearTextOnFocus   = false
    b.Parent             = parent
    self:corner(b, 3)
    self:stroke(b, self.T.STROKE, 1)
    self:trackElement(b, "ROW",    "BackgroundColor3")
    self:trackElement(b, "ACCENT", "TextColor3")
    self:trackElement(b, "DIM",    "PlaceholderColor3")
    return b
end

-- ScrollingFrame
function HydraUI:scroll(parent, sz, pos)
    local s = Instance.new("ScrollingFrame")
    s.Size                = sz  or UDim2.new(1, 0, 1, 0)
    s.Position            = pos or UDim2.new(0, 0, 0, 0)
    s.BackgroundTransparency = 1
    s.BorderSizePixel     = 0
    s.ScrollBarThickness  = 2
    s.ScrollBarImageColor3 = self.T.ACCENT
    s.CanvasSize          = UDim2.new(0, 0, 0, 0)
    s.AutomaticCanvasSize = Enum.AutomaticSize.Y
    s.Parent              = parent
    self:trackElement(s, "ACCENT", "ScrollBarImageColor3")
    return s
end

-- UIListLayout
function HydraUI:listLayout(parent, padding)
    local l = Instance.new("UIListLayout", parent)
    l.Padding    = UDim.new(0, padding or 3)
    l.SortOrder  = Enum.SortOrder.LayoutOrder
    return l
end

-- UIPadding
function HydraUI:padding(parent, t, l, r, b)
    local p = Instance.new("UIPadding", parent)
    p.PaddingTop    = UDim.new(0, t or 0)
    p.PaddingLeft   = UDim.new(0, l or 0)
    p.PaddingRight  = UDim.new(0, r or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    return p
end



-- Toggle Switch
-- returns { Set(bool), Get(), Frame }
function HydraUI:toggle(parent, pos, init, onChange, big)
    local W  = big and 34 or 26
    local H  = big and 16 or 12
    local KS = big and 12 or 9
    local R  = big and 8  or 6

    local box = self:frame(parent, UDim2.new(0, W, 0, H), pos, "TOGGLE_OFF")
    self:corner(box, R)
    self:strokeKeyed(box, "STROKE", 1)

    local knob = self:frame(box, UDim2.new(0, KS, 0, KS), UDim2.new(0, 1, 0.5, -KS/2), Color3.fromRGB(200, 210, 230))
    self:corner(knob, KS)

    local state = init and true or false
    local onX   = W - KS - 1
    local offX  = 1

    local function apply(s)
        TweenService:Create(box,  TweenInfo.new(0.12), { BackgroundColor3 = s and self.T.TOGGLE_ON or self.T.TOGGLE_OFF }):Play()
        TweenService:Create(knob, TweenInfo.new(0.12), { Position = s and UDim2.new(0, onX, 0.5, -KS/2) or UDim2.new(0, offX, 0.5, -KS/2) }):Play()
        if typeof(onChange) == "function" then onChange(s) end
    end

    apply(state)

    local hit = self:button(box, "", UDim2.new(1, 0, 1, 0), nil, "BTN", "TEXT")
    hit.BackgroundTransparency = 1
    hit.ZIndex = 5
    hit.MouseButton1Click:Connect(function()
        state = not state
        apply(state)
    end)

    return {
        Set   = function(v) state = v and true or false apply(state) end,
        Get   = function() return state end,
        Frame = box,
    }
end


-- returns { card, header, body }
function HydraUI:card(parent, sz, pos, strokeColorKey)
    local colorKey = strokeColorKey or "STROKE"
    local c = self:frame(parent, sz, pos, "CARD")
    self:corner(c, 4)
    self:strokeKeyed(c, colorKey, 1)

    local hdr = self:frame(c, UDim2.new(1, 0, 0, 22), UDim2.new(0, 0, 0, 0), "PANEL")
    self:corner(hdr, 4)

    local body = self:frame(c, UDim2.new(1, -4, 1, -26), UDim2.new(0, 2, 0, 24), "BG", 1)

    return { card = c, header = hdr, body = body }
end

-- Section Header Label
function HydraUI:sectionHeader(parent, text, layoutOrder)
    local l = self:label(parent, text, UDim2.new(1, 0, 0, 10), nil, "ACCENT", 7)
    l.Font        = Enum.Font.GothamBold
    l.LayoutOrder = layoutOrder or 0
    return l
end

-- Tab Bar
-- tabs = { "Tab1", "Tab2", ... }
-- onSwitch(index) callback
-- returns { bar, buttons={}, setActive(i) }
function HydraUI:tabBar(parent, tabs, onSwitch, colorKey)
    local accentKey = colorKey or "ACCENT"
    local bar = self:frame(parent, UDim2.new(1, 0, 0, 18), nil, "PANEL")
    self:stroke(bar, self.T.STROKE, 1)
    self:trackElement(bar, "PANEL", "BackgroundColor3")

    local n    = #tabs
    local btns = {}

    local function setActive(idx)
        for i, b in ipairs(btns) do
            b.BackgroundColor3 = (i == idx) and self.T.CARD or self.T.PANEL
            b.TextColor3       = (i == idx) and self.T[accentKey] or self.T.DIM
        end
    end

    for i, name in ipairs(tabs) do
        local bw = math.floor(parent.AbsoluteSize.X / n)
        local b  = self:button(bar, name,
            UDim2.new(0, bw - 2, 0, 14),
            UDim2.new(0, (i-1) * bw + 1, 0.5, -7),
            i == 1 and "CARD" or "PANEL",
            i == 1 and accentKey or "DIM",
            6
        )
        self:strokeKeyed(b, "STROKE", 1)
        btns[i] = b
        b.MouseButton1Click:Connect(function()
            setActive(i)
            if typeof(onSwitch) == "function" then onSwitch(i) end
        end)
    end

    return { bar = bar, buttons = btns, setActive = setActive }
end

-- Log Panel
-- returns { panel, append(msg, color), clear() }
function HydraUI:logPanel(parent, sz, pos, maxLines)
    local max  = maxLines or 30
    local n    = 0

    local outer = self:frame(parent, sz, pos, "PANEL")
    self:corner(outer, 3)
    self:strokeKeyed(outer, "STROKE", 1)
    self:trackElement(outer, "PANEL", "BackgroundColor3")

    local hdr = self:frame(outer, UDim2.new(1, 0, 0, 12), nil, "BG", 1)
    self:trackElement(hdr, "BG", "BackgroundColor3")
    local hdrLbl = self:label(hdr, "LOGS", UDim2.new(1, -36, 1, 0), UDim2.new(0, 4, 0, 0), "ACCENT", 7)
    hdrLbl.Font = Enum.Font.GothamBold

    local clearBtn = self:button(hdr, "Clear",
        UDim2.new(0, 30, 0, 10),
        UDim2.new(1, -32, 0.5, -5),
        "BTN", "DIM", 6
    )
    self:strokeKeyed(clearBtn, "STROKE", 1)

    local scrl = self:scroll(outer, UDim2.new(1, -4, 1, -14), UDim2.new(0, 2, 0, 13))
    self:listLayout(scrl, 1)
    self:padding(scrl, 1, 3, 3, 1)

    local function append(msg, col)
        n = n + 1
        local r = Instance.new("TextLabel")
        r.Size               = UDim2.new(1, 0, 0, 9)
        r.BackgroundTransparency = 1
        r.Text               = os.date("%H:%M:%S") .. " " .. tostring(msg)
        r.TextColor3         = col or self.T.TEXT2
        r.Font               = Enum.Font.Gotham
        r.TextSize           = 7
        r.TextXAlignment     = Enum.TextXAlignment.Left
        r.TextTruncate       = Enum.TextTruncate.AtEnd
        r.LayoutOrder        = n
        r.Parent             = scrl
        local kids = {}
        for _, c in ipairs(scrl:GetChildren()) do
            if c:IsA("TextLabel") then table.insert(kids, c) end
        end
        while #kids > max do kids[1]:Destroy() table.remove(kids, 1) end
        task.defer(function() scrl.CanvasPosition = Vector2.new(0, math.huge) end)
    end

    local function clear()
        for _, c in ipairs(scrl:GetChildren()) do
            if c:IsA("TextLabel") then c:Destroy() end
        end
        n = 0
    end

    clearBtn.MouseButton1Click:Connect(clear)

    return { panel = outer, append = append, clear = clear }
end

-- Search Bar
-- returns { bar, box (TextBox) }
function HydraUI:searchBar(parent, sz, pos, placeholder)
    local bar = self:frame(parent, sz or UDim2.new(1, -6, 0, 16), pos or UDim2.new(0, 3, 0, 3), "ROW")
    self:corner(bar, 3)
    self:strokeKeyed(bar, "STROKE", 1)

    local box = Instance.new("TextBox", bar)
    box.Size               = UDim2.new(1, -10, 1, 0)
    box.Position           = UDim2.new(0, 5, 0, 0)
    box.BackgroundTransparency = 1
    box.PlaceholderText    = placeholder or "Search..."
    box.Text               = ""
    box.TextColor3         = self.T.TEXT
    box.PlaceholderColor3  = self.T.DIM
    box.Font               = Enum.Font.Gotham
    box.TextSize           = 8
    box.TextXAlignment     = Enum.TextXAlignment.Left
    box.ClearTextOnFocus   = false
    self:trackElement(box, "TEXT", "TextColor3")
    self:trackElement(box, "DIM",  "PlaceholderColor3")

    return { bar = bar, box = box }
end

-- Stat Box (for queue: Pending / Listed / Free Slots)
-- returns numLabel yang bisa di-set .Text
function HydraUI:statBox(parent, x, colorKey, labelText)
    local card = self:frame(parent, UDim2.new(0, 52, 1, 0), UDim2.new(0, x, 0, 0), "CARD")
    self:corner(card, 3)
    self:strokeKeyed(card, colorKey, 1)
    self:trackElement(card, "CARD", "BackgroundColor3")

    local numLbl = self:label(card, "0",
        UDim2.new(1, 0, 0, 18),
        UDim2.new(0, 0, 0, 2),
        colorKey, 12,
        Enum.TextXAlignment.Center
    )
    numLbl.Font = Enum.Font.GothamBold

    local nameLbl = self:label(card, labelText,
        UDim2.new(1, 0, 0, 9),
        UDim2.new(0, 0, 0, 19),
        "TEXT", 7,
        Enum.TextXAlignment.Center
    )
    nameLbl.Font = Enum.Font.Gotham
    self:trackElement(nameLbl, "TEXT", "TextColor3")

    return numLbl
end

-- Listing Row (market/booth)
-- data = { petType, mutName, mutCode, level, weight, price, sellerName }
-- onBuy = function(btn, data)
-- returns row Frame
function HydraUI:listingRow(parent, data, layoutOrder, onBuy)
    local isAlt = layoutOrder % 2 == 0
    local row   = self:frame(parent, UDim2.new(1, -2, 0, 18), nil, isAlt and "ROW_ALT" or "ROW")
    row.LayoutOrder = layoutOrder
    self:corner(row, 2)

    local mutDisplay = (data.mutName and data.mutName ~= "") and data.mutName or "-"
    local mutColor   = (data.mutName and data.mutName ~= "") and self.T.MUT_COL or self.T.DIM

    local nameL = self:label(row, data.petType,
        UDim2.new(0, 82, 1, 0), UDim2.new(0, 4, 0, 0), "TEXT", 7)
    nameL.Font = Enum.Font.GothamBold

    local mutL = self:label(row, mutDisplay,
        UDim2.new(0, 60, 1, 0), UDim2.new(0, 88, 0, 0), mutColor, 6)
    mutL.Font = Enum.Font.Gotham

    local ageL = self:label(row,
        string.format("Age %d | %.1fKG", data.level or 0, data.weight or 0),
        UDim2.new(0, 66, 1, 0), UDim2.new(0, 150, 0, 0), "DIM", 6)
    ageL.Font = Enum.Font.Gotham

    local priceL = self:label(row, tostring(data.price or 0),
        UDim2.new(0, 42, 1, 0), UDim2.new(0, 218, 0, 0),
        "ACCENT", 7, Enum.TextXAlignment.Left)
    priceL.Font = Enum.Font.GothamBold

    local sellerL = self:label(row, data.sellerName or "...",
        UDim2.new(0, 54, 1, 0), UDim2.new(0, 262, 0, 0), "SELLER_COL", 6)
    sellerL.Font = Enum.Font.Gotham

    if typeof(onBuy) == "function" then
        local buyBtn = self:button(row, "BUY",
            UDim2.new(0, 24, 0, 13), UDim2.new(1, -26, 0.5, -6),
            "GREEN", "TEXT", 6)
        self:strokeKeyed(buyBtn, "GREEN", 1)
        buyBtn.MouseButton1Click:Connect(function() onBuy(buyBtn, data) end)
    end

    return row
end

-- Confirm Dialog overlay
-- config = { title, lines = { {key, value} }, onConfirm, onCancel, accentKey }
-- returns overlay Frame
function HydraUI:confirmDialog(guiParent, config)
    local accentKey = config.accentKey or "ACCENT"
    local lines     = config.lines or {}

    local overlay = Instance.new("Frame")
    overlay.Size                   = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.45
    overlay.BorderSizePixel        = 0
    overlay.ZIndex                 = 200
    overlay.Parent                 = guiParent

    local cardH = 20 + #lines * 14 + 24
    local card  = self:frame(overlay,
        UDim2.new(0, 200, 0, cardH),
        UDim2.new(0.5, -100, 0.5, -(cardH / 2)),
        "PANEL"
    )
    card.ZIndex = 201
    self:corner(card, 6)
    self:strokeKeyed(card, accentKey, 1)

    local titleL = Instance.new("TextLabel")
    titleL.Size                   = UDim2.new(1, 0, 0, 14)
    titleL.Position               = UDim2.new(0, 0, 0, 2)
    titleL.BackgroundTransparency = 1
    titleL.Text                   = config.title or "Confirm"
    titleL.TextColor3             = self.T[accentKey] or self.T.ACCENT
    titleL.Font                   = Enum.Font.GothamBold
    titleL.TextSize               = 9
    titleL.TextXAlignment         = Enum.TextXAlignment.Center
    titleL.ZIndex                 = 202
    titleL.Parent                 = card

    local div = Instance.new("Frame")
    div.Size             = UDim2.new(1, -8, 0, 1)
    div.Position         = UDim2.new(0, 4, 0, 17)
    div.BackgroundColor3 = self.T.STROKE
    div.BorderSizePixel  = 0
    div.ZIndex           = 202
    div.Parent           = card

    for i, pair in ipairs(lines) do
        local y = 20 + (i - 1) * 14
        local kL = Instance.new("TextLabel")
        kL.Size                   = UDim2.new(0, 60, 0, 12)
        kL.Position               = UDim2.new(0, 8, 0, y)
        kL.BackgroundTransparency = 1
        kL.Text                   = pair[1]
        kL.TextColor3             = self.T.DIM
        kL.Font                   = Enum.Font.Gotham
        kL.TextSize               = 8
        kL.TextXAlignment         = Enum.TextXAlignment.Left
        kL.ZIndex                 = 202
        kL.Parent                 = card

        local vL = Instance.new("TextLabel")
        vL.Size                   = UDim2.new(1, -72, 0, 12)
        vL.Position               = UDim2.new(0, 70, 0, y)
        vL.BackgroundTransparency = 1
        vL.Text                   = pair[2]
        vL.TextColor3             = (i == #lines) and (self.T[accentKey] or self.T.ACCENT) or self.T.TEXT
        vL.Font                   = Enum.Font.GothamBold
        vL.TextSize               = 8
        vL.TextXAlignment         = Enum.TextXAlignment.Left
        vL.ZIndex                 = 202
        vL.Parent                 = card
    end

    local bY = 20 + #lines * 14 + 2
    local confirmBtn = self:button(card, "Confirm",
        UDim2.new(0, 72, 0, 16), UDim2.new(0.5, -76, 0, bY),
        accentKey, "SEL_TXT", 8)
    confirmBtn.ZIndex = 202
    self:strokeKeyed(confirmBtn, accentKey, 1)

    local cancelBtn = self:button(card, "Cancel",
        UDim2.new(0, 52, 0, 16), UDim2.new(0.5, 6, 0, bY),
        "BTN", "DIM", 8)
    cancelBtn.ZIndex = 202
    self:strokeKeyed(cancelBtn, "STROKE", 1)

    cancelBtn.MouseButton1Click:Connect(function()
        overlay:Destroy()
        if typeof(config.onCancel) == "function" then config.onCancel() end
    end)
    confirmBtn.MouseButton1Click:Connect(function()
        overlay:Destroy()
        if typeof(config.onConfirm) == "function" then config.onConfirm() end
    end)

    return overlay
end

-- Buy Confirm Dialog (specific version for hydra script)
-- listing = { petType, mutName, level, weight, price }
-- onConfirm = function()
-- returns overlay Frame
function HydraUI:buyConfirmDialog(guiParent, listing, onConfirm)
    local overlay = Instance.new("Frame")
    overlay.Name                   = "BuyConfirmOverlay"
    overlay.Size                   = UDim2.new(1, 0, 1, 0)
    overlay.Position               = UDim2.new(0, 0, 0, 0)
    overlay.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.45
    overlay.BorderSizePixel        = 0
    overlay.ZIndex                 = 200
    overlay.Parent                 = guiParent

    local card = Instance.new("Frame")
    card.Size             = UDim2.new(0, 200, 0, 110)
    card.Position         = UDim2.new(0.5, -100, 0.5, -55)
    card.BackgroundColor3 = self.T.PANEL
    card.BorderSizePixel  = 0
    card.ZIndex           = 201
    card.Parent           = overlay
    self:corner(card, 6)
    self:strokeKeyed(card, "ACCENT", 1)

    local titleL = Instance.new("TextLabel")
    titleL.Size                   = UDim2.new(1, 0, 0, 14)
    titleL.Position               = UDim2.new(0, 0, 0, 2)
    titleL.BackgroundTransparency = 1
    titleL.Text                   = "Confirm Purchase"
    titleL.TextColor3             = self.T.ACCENT
    titleL.Font                   = Enum.Font.GothamBold
    titleL.TextSize               = 9
    titleL.TextXAlignment         = Enum.TextXAlignment.Center
    titleL.ZIndex                 = 202
    titleL.Parent                 = card

    local divider = Instance.new("Frame")
    divider.Size             = UDim2.new(1, -8, 0, 1)
    divider.Position         = UDim2.new(0, 4, 0, 17)
    divider.BackgroundColor3 = self.T.STROKE
    divider.BorderSizePixel  = 0
    divider.ZIndex           = 202
    divider.Parent           = card

    local mutDisplay = (listing.mutName and listing.mutName ~= "") and listing.mutName or "None"
    local infoLines = {
        { "Pet",      listing.petType or "Unknown" },
        { "Mutation", mutDisplay },
        { "Age / KG", string.format("Age %d  |  %.1f KG", listing.level or 0, listing.weight or 0) },
        { "Price",    tostring(listing.price or 0) .. " tokens" },
    }

    for i, pair in ipairs(infoLines) do
        local rowY = 20 + (i - 1) * 14
        local kL = Instance.new("TextLabel")
        kL.Size                   = UDim2.new(0, 60, 0, 12)
        kL.Position               = UDim2.new(0, 8, 0, rowY)
        kL.BackgroundTransparency = 1
        kL.Text                   = pair[1]
        kL.TextColor3             = self.T.DIM
        kL.Font                   = Enum.Font.Gotham
        kL.TextSize               = 8
        kL.TextXAlignment         = Enum.TextXAlignment.Left
        kL.ZIndex                 = 202
        kL.Parent                 = card

        local vL = Instance.new("TextLabel")
        vL.Size                   = UDim2.new(1, -72, 0, 12)
        vL.Position               = UDim2.new(0, 70, 0, rowY)
        vL.BackgroundTransparency = 1
        vL.Text                   = pair[2]
        vL.TextColor3             = (i == 4) and self.T.ACCENT or self.T.TEXT
        vL.Font                   = Enum.Font.GothamBold
        vL.TextSize               = 8
        vL.TextXAlignment         = Enum.TextXAlignment.Left
        vL.ZIndex                 = 202
        vL.Parent                 = card
    end

    local confirmBtn = Instance.new("TextButton")
    confirmBtn.Size             = UDim2.new(0, 72, 0, 16)
    confirmBtn.Position         = UDim2.new(0.5, -76, 1, -20)
    confirmBtn.BackgroundColor3 = self.T.ACCENT
    confirmBtn.BorderSizePixel  = 0
    confirmBtn.Text             = "Buy"
    confirmBtn.TextColor3       = self.T.SEL_TXT
    confirmBtn.Font             = Enum.Font.GothamBold
    confirmBtn.TextSize         = 8
    confirmBtn.AutoButtonColor  = false
    confirmBtn.ZIndex           = 202
    confirmBtn.Parent           = card
    self:corner(confirmBtn, 3)
    self:strokeKeyed(confirmBtn, "ACCENT", 1)

    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size             = UDim2.new(0, 52, 0, 16)
    cancelBtn.Position         = UDim2.new(0.5, 6, 1, -20)
    cancelBtn.BackgroundColor3 = self.T.BTN
    cancelBtn.BorderSizePixel  = 0
    cancelBtn.Text             = "Cancel"
    cancelBtn.TextColor3       = self.T.DIM
    cancelBtn.Font             = Enum.Font.GothamBold
    cancelBtn.TextSize         = 8
    cancelBtn.AutoButtonColor  = false
    cancelBtn.ZIndex           = 202
    cancelBtn.Parent           = card
    self:corner(cancelBtn, 3)
    self:strokeKeyed(cancelBtn, "STROKE", 1)

    cancelBtn.MouseButton1Click:Connect(function()
        overlay:Destroy()
    end)
    confirmBtn.MouseButton1Click:Connect(function()
        overlay:Destroy()
        if typeof(onConfirm) == "function" then onConfirm() end
    end)

    return overlay
end

-- Pet Picker Overlay
-- config = {
--    petList       = { { name, egg } },   -- array of pet entries
--    selectedPet   = "PetName" or nil,
--    onSelect      = function(petName or nil),
--    zIndex        = number (default 60),
-- }
-- returns { overlay, open(curSel), close() }
function HydraUI:petPicker(guiParent, config)
    local zIdx    = config.zIndex or 60
    local petList = config.petList or {}

    local overlay = self:frame(guiParent,
        UDim2.new(0, 240, 0, 300),
        UDim2.new(0.5, -120, 0.5, -150),
        "BG"
    )
    overlay.Visible = false
    overlay.ZIndex  = zIdx
    self:corner(overlay, 7)
    self:strokeKeyed(overlay, "ACCENT", 1)
    self:trackElement(overlay, "BG", "BackgroundColor3")

    local hdr = self:frame(overlay, UDim2.new(1, 0, 0, 22), nil, "PANEL")
    hdr.ZIndex = zIdx + 1
    self:trackElement(hdr, "PANEL", "BackgroundColor3")

    local titleLbl = self:label(hdr, "Select Pet",
        UDim2.new(1, -26, 1, 0), UDim2.new(0, 6, 0, 0), "ACCENT", 8)
    titleLbl.ZIndex = zIdx + 2

    local closeBtn = self:button(hdr, "x",
        UDim2.new(0, 16, 0, 14), UDim2.new(1, -20, 0.5, -7),
        "ERROR", "TEXT", 8)
    closeBtn.ZIndex = zIdx + 2

    local searchBox = Instance.new("TextBox", overlay)
    searchBox.Size               = UDim2.new(1, -8, 0, 16)
    searchBox.Position           = UDim2.new(0, 4, 0, 26)
    searchBox.BackgroundColor3   = self.T.ROW
    searchBox.BorderSizePixel    = 0
    searchBox.PlaceholderText    = "Search pet..."
    searchBox.Text               = ""
    searchBox.TextColor3         = self.T.TEXT
    searchBox.PlaceholderColor3  = self.T.DIM
    searchBox.Font               = Enum.Font.Gotham
    searchBox.TextSize           = 8
    searchBox.ClearTextOnFocus   = false
    searchBox.ZIndex             = zIdx + 1
    self:corner(searchBox, 3)
    self:stroke(searchBox, self.T.STROKE, 1)
    self:trackElement(searchBox, "ROW",  "BackgroundColor3")
    self:trackElement(searchBox, "TEXT", "TextColor3")
    self:trackElement(searchBox, "DIM",  "PlaceholderColor3")

    local scrl = self:scroll(overlay, UDim2.new(1, -4, 1, -46), UDim2.new(0, 2, 0, 44))
    scrl.ZIndex = zIdx - 9
    self:listLayout(scrl, 2)
    self:padding(scrl, 2, 3, 3, 2)

    local currentSel = config.selectedPet
    local _cb        = nil

    local function refresh(q)
        for _, c in ipairs(scrl:GetChildren()) do
            if c:IsA("GuiObject") then c:Destroy() end
        end
        local qL = string.lower(q or "")
        for i, pet in ipairs(petList) do
            local petName = pet.name or pet[1] or ""
            local petEgg  = pet.egg  or pet[2] or ""
            if qL ~= "" and not string.lower(petName):find(qL, 1, true) then continue end
            local isSel = currentSel == petName
            local row = self:button(scrl, "",
                UDim2.new(1, 0, 0, 20), nil,
                isSel and "ACCENT" or "ROW",
                isSel and "SEL_TXT" or "TEXT", 8)
            row.LayoutOrder    = i
            row.TextXAlignment = Enum.TextXAlignment.Left
            row.ZIndex         = zIdx + 2
            self:corner(row, 3)
            self:strokeKeyed(row, isSel and "ACCENT" or "STROKE", 1)
            local nL = self:label(row,
                petName .. "  (" .. petEgg .. ")",
                UDim2.new(1, -8, 0, 12), UDim2.new(0, 6, 0, 4),
                isSel and "SEL_TXT" or "TEXT", 8)
            nL.Font   = Enum.Font.GothamBold
            nL.ZIndex = zIdx + 3
            row.MouseButton1Click:Connect(function()
                if _cb then
                    if petName == currentSel then
                        currentSel = nil
                        _cb(nil)
                    else
                        currentSel = petName
                        _cb(petName)
                    end
                end
            end)
        end
    end

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        refresh(searchBox.Text)
    end)

    closeBtn.MouseButton1Click:Connect(function()
        overlay.Visible = false
        searchBox.Text  = ""
    end)

    local function open(curSel, cb)
        currentSel = curSel
        _cb = function(n)
            overlay.Visible = false
            searchBox.Text  = ""
            if typeof(cb) == "function" then cb(n) end
        end
        refresh("")
        overlay.Visible = true
    end

    local function close()
        overlay.Visible = false
        searchBox.Text  = ""
    end

    return { overlay = overlay, open = open, close = close }
end

-- Mutation Picker Overlay (multi-select)
-- config = {
--    mutationList  = { { code, name } },  -- array, first entry  {code="ANY",name="Any"}
--    selectedMuts  = {},                   -- table of selected codes
--    onSelect      = function(selectedList),
--    zIndex        = number (default 60),
-- }
-- returns { overlay, open(curMuts, cb), close() }
function HydraUI:mutationPicker(guiParent, config)
    local zIdx       = config.zIndex or 60
    local mutList    = config.mutationList or {}

    local overlay = self:frame(guiParent,
        UDim2.new(0, 220, 0, 280),
        UDim2.new(0.5, -110, 0.5, -140),
        "BG"
    )
    overlay.Visible = false
    overlay.ZIndex  = zIdx
    self:corner(overlay, 7)
    self:strokeKeyed(overlay, "MUT_COL", 1)
    self:trackElement(overlay, "BG", "BackgroundColor3")

    local hdr = self:frame(overlay, UDim2.new(1, 0, 0, 22), nil, "PANEL")
    hdr.ZIndex = zIdx + 1
    self:trackElement(hdr, "PANEL", "BackgroundColor3")

    local titleLbl = self:label(hdr, "Select Mutation",
        UDim2.new(1, -26, 1, 0), UDim2.new(0, 6, 0, 0), "MUT_COL", 8)
    titleLbl.ZIndex = zIdx + 2

    local closeBtn = self:button(hdr, "x",
        UDim2.new(0, 16, 0, 14), UDim2.new(1, -20, 0.5, -7),
        "ERROR", "TEXT", 8)
    closeBtn.ZIndex = zIdx + 2

    local searchBox = Instance.new("TextBox", overlay)
    searchBox.Size               = UDim2.new(1, -8, 0, 16)
    searchBox.Position           = UDim2.new(0, 4, 0, 26)
    searchBox.BackgroundColor3   = self.T.ROW
    searchBox.BorderSizePixel    = 0
    searchBox.PlaceholderText    = "Search mutation..."
    searchBox.Text               = ""
    searchBox.TextColor3         = self.T.TEXT
    searchBox.PlaceholderColor3  = self.T.DIM
    searchBox.Font               = Enum.Font.Gotham
    searchBox.TextSize           = 8
    searchBox.ClearTextOnFocus   = false
    searchBox.ZIndex             = zIdx + 1
    self:corner(searchBox, 3)
    self:stroke(searchBox, self.T.STROKE, 1)
    self:trackElement(searchBox, "ROW",  "BackgroundColor3")
    self:trackElement(searchBox, "TEXT", "TextColor3")
    self:trackElement(searchBox, "DIM",  "PlaceholderColor3")

    local scrl = self:scroll(overlay, UDim2.new(1, -4, 1, -46), UDim2.new(0, 2, 0, 44))
    scrl.ZIndex = zIdx + 1
    self:listLayout(scrl, 2)
    self:padding(scrl, 2, 3, 3, 2)

    local currentMuts = {}
    local _cb         = nil

    local function refresh(q)
        for _, c in ipairs(scrl:GetChildren()) do
            if c:IsA("GuiObject") then c:Destroy() end
        end
        local qL = string.lower(q or "")
        for i, mut in ipairs(mutList) do
            if mut.code == "ANY" then continue end
            if qL ~= "" and not string.lower(mut.name):find(qL, 1, true) then continue end
            local isSel = false
            for _, m in ipairs(currentMuts) do
                if m == mut.code then isSel = true break end
            end
            local row = self:button(scrl, "",
                UDim2.new(1, 0, 0, 20), nil,
                isSel and "MUT_COL" or "ROW",
                isSel and "SEL_TXT" or "TEXT", 8)
            row.LayoutOrder    = i
            row.TextXAlignment = Enum.TextXAlignment.Left
            row.ZIndex         = zIdx + 2
            self:corner(row, 3)
            self:strokeKeyed(row, isSel and "MUT_COL" or "STROKE", 1)
            local nL = self:label(row, mut.name,
                UDim2.new(1, -8, 0, 12), UDim2.new(0, 6, 0, 4),
                isSel and "SEL_TXT" or "MUT_COL", 8)
            nL.Font   = Enum.Font.GothamBold
            nL.ZIndex = zIdx + 3
            local codeCap = mut.code
            row.MouseButton1Click:Connect(function()
                local found = false
                for j, m in ipairs(currentMuts) do
                    if m == codeCap then
                        table.remove(currentMuts, j)
                        found = true
                        break
                    end
                end
                if not found then table.insert(currentMuts, codeCap) end
                refresh(searchBox.Text)
                if typeof(_cb) == "function" then
                    local result = {}
                    for _, v in ipairs(currentMuts) do table.insert(result, v) end
                    _cb(result)
                end
            end)
        end
    end

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        refresh(searchBox.Text)
    end)

    closeBtn.MouseButton1Click:Connect(function()
        overlay.Visible = false
        searchBox.Text  = ""
    end)

    local function open(curMuts, cb)
        _cb = cb
        table.clear(currentMuts)
        if type(curMuts) == "table" then
            for _, v in ipairs(curMuts) do
                table.insert(currentMuts, v)
            end
        end
        refresh("")
        overlay.Visible = true
    end

    local function close()
        overlay.Visible = false
        searchBox.Text  = ""
    end

    return { overlay = overlay, open = open, close = close }
end

-- Generic Picker Overlay (Pet atau Mutation, single/multi)
-- config = {
--    title, strokeColorKey,
--    items = { {name, sub, key} },
--    multiSelect = bool,
--    selected = {} or string,
--    onSelect = function(result),
--    searchPlaceholder,
-- }
-- returns { overlay, open(), close() }
function HydraUI:picker(guiParent, config)
    local strokeKey = config.strokeColorKey or "ACCENT"
    local multi     = config.multiSelect or false

    local overlay = self:frame(guiParent,
        UDim2.new(0, 240, 0, 300),
        UDim2.new(0.5, -120, 0.5, -150),
        "BG"
    )
    overlay.Visible = false
    overlay.ZIndex  = 60
    self:corner(overlay, 7)
    self:strokeKeyed(overlay, strokeKey, 1)
    self:trackElement(overlay, "BG", "BackgroundColor3")

    local hdr = self:frame(overlay, UDim2.new(1, 0, 0, 22), nil, "PANEL")
    hdr.ZIndex = 61
    self:trackElement(hdr, "PANEL", "BackgroundColor3")
    local titleLbl = self:label(hdr, config.title or "Select",
        UDim2.new(1, -26, 1, 0), UDim2.new(0, 6, 0, 0), strokeKey, 8)
    titleLbl.ZIndex = 62
    local closeBtn = self:button(hdr, "x",
        UDim2.new(0, 16, 0, 14), UDim2.new(1, -20, 0.5, -7),
        "ERROR", "TEXT", 8)
    closeBtn.ZIndex = 62

    local searchBox = Instance.new("TextBox", overlay)
    searchBox.Size              = UDim2.new(1, -8, 0, 16)
    searchBox.Position          = UDim2.new(0, 4, 0, 26)
    searchBox.BackgroundColor3  = self.T.ROW
    searchBox.BorderSizePixel   = 0
    searchBox.PlaceholderText   = config.searchPlaceholder or "Search..."
    searchBox.Text              = ""
    searchBox.TextColor3        = self.T.TEXT
    searchBox.PlaceholderColor3 = self.T.DIM
    searchBox.Font              = Enum.Font.Gotham
    searchBox.TextSize          = 8
    searchBox.ClearTextOnFocus  = false
    searchBox.ZIndex            = 61
    self:corner(searchBox, 3)
    self:stroke(searchBox, self.T.STROKE, 1)
    self:trackElement(searchBox, "ROW",  "BackgroundColor3")
    self:trackElement(searchBox, "TEXT", "TextColor3")
    self:trackElement(searchBox, "DIM",  "PlaceholderColor3")

    local scrl = self:scroll(overlay, UDim2.new(1, -4, 1, -46), UDim2.new(0, 2, 0, 44))
    scrl.ZIndex = 51
    self:listLayout(scrl, 2)
    self:padding(scrl, 2, 3, 3, 2)

    local currentSelected = multi and {} or nil
    if multi and type(config.selected) == "table" then
        for _, v in ipairs(config.selected) do currentSelected[v] = true end
    elseif not multi then
        currentSelected = config.selected
    end

    local function isSelected(key)
        if multi then return currentSelected[key] == true
        else return currentSelected == key end
    end

    local function rebuild(query)
        for _, c in ipairs(scrl:GetChildren()) do
            if c:IsA("GuiObject") then c:Destroy() end
        end
        local q = string.lower(query or "")
        for i, item in ipairs(config.items or {}) do
            local name = item.name or item[1] or tostring(item)
            local sub  = item.sub  or item[2] or ""
            if q ~= "" and not string.lower(name):find(q, 1, true) then continue end
            local sel  = isSelected(item.key or name)
            local row  = self:button(scrl, "",
                UDim2.new(1, 0, 0, 20), nil,
                sel and strokeKey or "ROW",
                sel and "SEL_TXT" or "TEXT", 8)
            row.LayoutOrder    = i
            row.TextXAlignment = Enum.TextXAlignment.Left
            row.ZIndex         = 62
            self:corner(row, 3)
            self:strokeKeyed(row, sel and strokeKey or "STROKE", 1)
            local nameLbl = self:label(row,
                sub ~= "" and (name .. "  (" .. sub .. ")") or name,
                UDim2.new(1, -8, 0, 12), UDim2.new(0, 6, 0, 4),
                sel and "SEL_TXT" or "TEXT", 8)
            nameLbl.Font   = Enum.Font.GothamBold
            nameLbl.ZIndex = 63
            local keyCap = item.key or name
            row.MouseButton1Click:Connect(function()
                if multi then
                    if currentSelected[keyCap] then
                        currentSelected[keyCap] = nil
                    else
                        currentSelected[keyCap] = true
                    end
                    rebuild(searchBox.Text)
                    if typeof(config.onSelect) == "function" then
                        local result = {}
                        for k in pairs(currentSelected) do table.insert(result, k) end
                        config.onSelect(result)
                    end
                else
                    currentSelected = keyCap
                    overlay.Visible = false
                    searchBox.Text  = ""
                    if typeof(config.onSelect) == "function" then
                        config.onSelect(keyCap)
                    end
                end
            end)
        end
    end

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        rebuild(searchBox.Text)
    end)
    closeBtn.MouseButton1Click:Connect(function()
        overlay.Visible = false
        searchBox.Text  = ""
    end)

    local function open(curSel)
        if multi and type(curSel) == "table" then
            table.clear(currentSelected)
            for _, v in ipairs(curSel) do currentSelected[v] = true end
        elseif not multi then
            currentSelected = curSel
        end
        rebuild("")
        overlay.Visible = true
    end

    local function close()
        overlay.Visible = false
        searchBox.Text  = ""
    end

    return { overlay = overlay, open = open, close = close }
end

-- Draggable Window
-- returns { main, titleBar, closeBtn, minBtn, floatBtn, titleLbl }
function HydraUI:window(guiParent, w, h, title)
    local W = w or 420
    local H = h or 290

    local main = self:frame(guiParent,
        UDim2.new(0, W, 0, H),
        UDim2.new(0.5, -W/2, 0.5, -H/2),
        "BG"
    )
    main.Active = true
    self:corner(main, 7)
    self:strokeKeyed(main, "ACCENT", 1)
    main.ClipsDescendants = true
    self:trackElement(main, "BG", "BackgroundColor3")

    -- Title bar
    local tbar = self:frame(main, UDim2.new(1, 0, 0, 24), nil, "PANEL")
    self:corner(tbar, 7)
    self:stroke(tbar, self.T.STROKE, 1)
    self:trackElement(tbar, "PANEL", "BackgroundColor3")

    local titleLbl = self:label(tbar, title or "Window",
        UDim2.new(1, -100, 1, 0), UDim2.new(0, 24, 0, 0), "ACCENT", 9)
    titleLbl.Font = Enum.Font.GothamBold

    local closeBtn = self:button(tbar, "x",
        UDim2.new(0, 16, 0, 14), UDim2.new(1, -20, 0.5, -7),
        "ERROR", "TEXT", 8)
    self:strokeKeyed(closeBtn, "ERROR", 1)

    local minBtn = self:button(tbar, "-",
        UDim2.new(0, 16, 0, 14), UDim2.new(1, -38, 0.5, -7),
        "BTN", "DIM", 10)
    self:strokeKeyed(minBtn, "STROKE", 1)
    self:trackElement(minBtn, "BTN", "BackgroundColor3")
    self:trackElement(minBtn, "DIM", "TextColor3")

    -- Resizer
    local resizer = self:button(main, "↘",
        UDim2.new(0, 16, 0, 16), UDim2.new(1, -16, 1, -16),
        "BTN", "ACCENT", 10)
    resizer.ZIndex = 100
    self:corner(resizer, 3)
    self:trackElement(resizer, "BTN",    "BackgroundColor3")
    self:trackElement(resizer, "ACCENT", "TextColor3")

    -- Drag logic
    do
        local drag, dInp, sPos, sMP = false, nil, nil, nil
        tbar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                drag = true dInp = i sPos = i.Position sMP = main.Position
                i.Changed:Connect(function()
                    if i.UserInputState == Enum.UserInputState.End then drag = false end
                end)
            end
        end)
        tbar.InputChanged:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch then dInp = i end
        end)
        UIS.InputChanged:Connect(function(i)
            if not drag or i ~= dInp then return end
            local d = i.Position - sPos
            main.Position = UDim2.new(sMP.X.Scale, sMP.X.Offset + d.X, sMP.Y.Scale, sMP.Y.Offset + d.Y)
        end)
    end

    -- Resize logic
    do
        local resizing, startPos, startSize = false, nil, nil
        resizer.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                resizing  = true
                startPos  = i.Position
                startSize = Vector2.new(main.AbsoluteSize.X, main.AbsoluteSize.Y)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if not resizing then return end
            if i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch then
                main.Size = UDim2.new(0,
                    math.max(320, startSize.X + i.Position.X - startPos.X),
                    0,
                    math.max(200, startSize.Y + i.Position.Y - startPos.Y)
                )
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                resizing = false
            end
        end)
    end

    -- Float button
    local floatBtn = Instance.new("ImageButton", guiParent)
    floatBtn.Size             = UDim2.new(0, 30, 0, 30)
    floatBtn.Position         = UDim2.new(0, 14, 0.5, -15)
    floatBtn.BackgroundColor3 = self.T.PANEL
    floatBtn.BorderSizePixel  = 0
    floatBtn.Active           = true
    floatBtn.Draggable        = true
    floatBtn.Visible          = false
    self:corner(floatBtn, 15)
    self:strokeKeyed(floatBtn, "ACCENT", 1)
    self:trackElement(floatBtn, "PANEL", "BackgroundColor3")

    floatBtn.MouseButton1Click:Connect(function()
        floatBtn.Visible = false
        main.Visible     = true
    end)
    minBtn.MouseButton1Click:Connect(function()
        main.Visible     = false
        floatBtn.Visible = true
    end)
    closeBtn.MouseButton1Click:Connect(function()
        guiParent:Destroy()
    end)

    return {
        main      = main,
        titleBar  = tbar,
        closeBtn  = closeBtn,
        minBtn    = minBtn,
        floatBtn  = floatBtn,
        titleLbl  = titleLbl,
    }
end







-- tabs = { { label, colorKey } }
-- returns { bar, buttons={}, pages={}, switchTo(i) }
function HydraUI:sidebar(parent, tabs)
    local bar = self:frame(parent, UDim2.new(0, 46, 1, -24), UDim2.new(0, 0, 0, 24), "PANEL")
    self:stroke(bar, self.T.STROKE, 1)
    self:trackElement(bar, "PANEL", "BackgroundColor3")
    self:listLayout(bar, 2)
    self:padding(bar, 3, 3, 3, 3)

    local btns  = {}
    local pages = {}

    for i, tab in ipairs(tabs) do
        local colorKey = tab.colorKey or "ACCENT"
        local b = self:button(bar, tab.label,
            UDim2.new(1, 0, 0, 34), nil,
            "CARD", colorKey, 6
        )
        b.LayoutOrder = i
        b.TextWrapped = true
        self:strokeKeyed(b, colorKey, 1)
        self:trackElement(b, "CARD",   "BackgroundColor3")
        self:trackElement(b, colorKey, "TextColor3")
        btns[i] = b

        local pg = self:frame(parent,
            UDim2.new(1, -50, 1, -24),
            UDim2.new(0, 48, 0, 24),
            "BG", 1
        )
        pg.Visible = (i == 1)
        pages[i]   = pg
        self:trackElement(pg, "BG", "BackgroundColor3")
    end

    local function switchTo(idx)
        for i, pg in ipairs(pages) do
            pg.Visible = (i == idx)
            local colorKey = tabs[i].colorKey or "ACCENT"
            btns[i].BackgroundColor3 = (i == idx) and self.T.CARD or self.T.PANEL
            btns[i].TextColor3       = self.T[colorKey]
        end
    end

    for i in ipairs(tabs) do
        btns[i].MouseButton1Click:Connect(function() switchTo(i) end)
    end

    return { bar = bar, buttons = btns, pages = pages, switchTo = switchTo }
end



function HydraUI:inlinePicker(rowParent, overlayParent, config) -- Pick mode
	local zIdx = config.zIndex or 70
	local strokeKey = config.strokeColorKey or "ACCENT"
	local multi = config.multiSelect or false
	local selected = multi and {} or (config.default or nil)
	local _cb = config.onSelect

	local row = self:frame(rowParent, UDim2.new(1,-4,0,16), nil, "CARD")
	self:corner(row, 3)
	self:strokeKeyed(row, strokeKey, 1)

	local lblLeft = self:label(row, config.label or "Mode", UDim2.new(0,60,1,0), UDim2.new(0,4,0,0), "TEXT", 9)
	lblLeft.Font = Enum.Font.GothamBold

	local valLbl = self:label(row, config.default or "Select...", UDim2.new(1,-80,1,0), UDim2.new(0,66,0,0), strokeKey, 9)
	valLbl.Font = Enum.Font.GothamBold

	self:label(row, "▼", UDim2.new(0,14,1,0), UDim2.new(1,-16,0,0), "DIM", 8, Enum.TextXAlignment.Center)

	local overlay = self:frame(overlayParent, UDim2.new(0,220,0,200), UDim2.new(0,0,0,0), "PANEL")
	overlay.Visible = false
	overlay.ZIndex = zIdx
	self:corner(overlay, 5)
	self:strokeKeyed(overlay, strokeKey, 1)

	local ohdr = self:frame(overlay, UDim2.new(1,0,0,20), nil, Color3.fromRGB(10,16,36))
	self:corner(ohdr, 5)
	local otitle = self:label(ohdr, config.label or "Mode", UDim2.new(1,-24,1,0), UDim2.new(0,6,0,0), strokeKey, 9)
	otitle.Font = Enum.Font.GothamBold
	otitle.ZIndex = zIdx+1
	local xBtn = self:button(ohdr, "x", UDim2.new(0,14,0,14), UDim2.new(1,-17,0.5,-7), "ERROR", "TEXT", 8)
	xBtn.ZIndex = zIdx+1

	local searchBox = Instance.new("TextBox", overlay)
	searchBox.Size = UDim2.new(1,-8,0,16)
	searchBox.Position = UDim2.new(0,4,0,23)
	searchBox.BackgroundColor3 = Color3.fromRGB(10,16,36)
	searchBox.BorderSizePixel = 0
	searchBox.PlaceholderText = "Search..."
	searchBox.Text = ""
	searchBox.TextColor3 = self.T.TEXT
	searchBox.PlaceholderColor3 = self.T.DIM
	searchBox.Font = Enum.Font.Gotham
	searchBox.TextSize = 8
	searchBox.ClearTextOnFocus = false
	searchBox.ZIndex = zIdx+1
	self:corner(searchBox, 3)
	self:strokeKeyed(searchBox, "STROKE", 1)

	local scrl = self:scroll(overlay, UDim2.new(1,-4,1,-42), UDim2.new(0,2,0,42))
	scrl.ZIndex = zIdx
	self:listLayout(scrl, 2)
	self:padding(scrl, 2,3,3,2)

	local function getSelName()
		if multi then
			local names = {}
			for _, item in ipairs(config.items or {}) do
				if selected[item.key] then table.insert(names, item.name) end
			end
			return #names > 0 and table.concat(names, ", ") or "Select..."
		else
			for _, item in ipairs(config.items or {}) do
				if item.key == selected then return item.name end
			end
			return "Select..."
		end
	end

	local function rebuild(q)
		for _, c in ipairs(scrl:GetChildren()) do if c:IsA("GuiObject") then c:Destroy() end end
		local ql = string.lower(q or "")
		for i, item in ipairs(config.items or {}) do
			if ql ~= "" and not string.lower(item.name):find(ql,1,true) then continue end
			local isSel = multi and selected[item.key] or selected == item.key
			local btn = self:button(scrl, item.name, UDim2.new(1,0,0,22), nil,
				isSel and strokeKey or "ROW",
				isSel and "SEL_TXT" or "TEXT", 9)
			btn.Font = Enum.Font.GothamBold
			btn.LayoutOrder = i
			btn.ZIndex = zIdx+2
			self:corner(btn, 3)
			self:strokeKeyed(btn, isSel and strokeKey or "STROKE", 1)
			local kc = item.key
			btn.MouseButton1Click:Connect(function()
				if multi then
					if selected[kc] then selected[kc]=nil else selected[kc]=true end
					rebuild(searchBox.Text)
					valLbl.Text = getSelName()
					if _cb then
						local res={}
						for k in pairs(selected) do table.insert(res,k) end
						_cb(res)
					end
				else
					selected = kc
					valLbl.Text = getSelName()
					overlay.Visible = false
					searchBox.Text = ""
					if _cb then _cb(kc) end
				end
			end)
		end
	end

	searchBox:GetPropertyChangedSignal("Text"):Connect(function() rebuild(searchBox.Text) end)
	xBtn.MouseButton1Click:Connect(function() overlay.Visible=false searchBox.Text="" end)

	local hitBtn = self:button(row, "", UDim2.new(1,0,1,0), nil, "CARD", "TEXT", 8)
	hitBtn.BackgroundTransparency = 1
	hitBtn.ZIndex = 5
	hitBtn.MouseButton1Click:Connect(function()
		if overlay.Visible then
			overlay.Visible = false
			searchBox.Text = ""
		else
			local abs = row.AbsolutePosition
			local absSize = row.AbsoluteSize
			overlay.Position = UDim2.new(0, abs.X, 0, abs.Y + absSize.Y + 2)
			rebuild("")
			overlay.Visible = true
		end
	end)

	return {
		row = row,
		overlay = overlay,
		Set = function(v)
			if multi and type(v)=="table" then
				table.clear(selected)
				for _,k in ipairs(v) do selected[k]=true end
			else
				selected = v
			end
			valLbl.Text = getSelName()
		end,
		Get = function()
			if multi then
				local res={}
				for k in pairs(selected) do table.insert(res,k) end
				return res
			end
			return selected
		end,
	}
end

return HydraUI
