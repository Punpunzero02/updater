local VoidUI = {}
VoidUI.__index = VoidUI

local TweenSvc = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

function VoidUI.new(theme)
	local self = setmetatable({}, VoidUI)
	self.T = theme
	return self
end

function VoidUI:corner(parent, radius)
	local c = Instance.new("UICorner", parent)
	c.CornerRadius = UDim.new(0, radius or 6)
	return c
end

function VoidUI:stroke(parent, col, th)
	local s = Instance.new("UIStroke", parent)
	s.Color = col or self.T.STROKE
	s.Thickness = th or 1
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	return s
end

function VoidUI:frame(parent, size, pos, bg, tr)
	local f = Instance.new("Frame")
	f.Size = size or UDim2.new(1, 0, 1, 0)
	f.Position = pos or UDim2.new(0, 0, 0, 0)
	f.BackgroundColor3 = bg or self.T.PANEL
	f.BackgroundTransparency = tr or 0
	f.BorderSizePixel = 0
	f.Parent = parent
	return f
end

function VoidUI:label(parent, text, size, pos, col, fs, xa)
	local l = Instance.new("TextLabel")
	l.Size = size or UDim2.new(1, 0, 0, 16)
	l.Position = pos or UDim2.new(0, 0, 0, 0)
	l.BackgroundTransparency = 1
	l.Text = text or ""
	l.TextColor3 = col or self.T.TEXT
	l.Font = Enum.Font.GothamBold
	l.TextSize = fs or 11
	l.TextXAlignment = xa or Enum.TextXAlignment.Left
	l.TextTruncate = Enum.TextTruncate.AtEnd
	l.Parent = parent
	return l
end

function VoidUI:button(parent, text, size, pos, bg, tc, fs)
	local b = Instance.new("TextButton")
	b.Size = size or UDim2.new(0, 80, 0, 26)
	b.Position = pos or UDim2.new(0, 0, 0, 0)
	b.BackgroundColor3 = bg or self.T.BTN
	b.BorderSizePixel = 0
	b.Text = text or ""
	b.TextColor3 = tc or self.T.TEXT
	b.Font = Enum.Font.GothamBold
	b.TextSize = fs or 11
	b.AutoButtonColor = false
	b.Parent = parent
	self:corner(b, 5)
	return b
end

function VoidUI:input(parent, default, ph, size, pos)
	local b = Instance.new("TextBox")
	b.Size = size or UDim2.new(0, 80, 0, 22)
	b.Position = pos or UDim2.new(0, 0, 0, 0)
	b.BackgroundColor3 = self.T.BTN
	b.BorderSizePixel = 0
	b.Text = tostring(default or "")
	b.PlaceholderText = ph or ""
	b.TextColor3 = self.T.ACCENT
	b.PlaceholderColor3 = self.T.DIM
	b.Font = Enum.Font.GothamBold
	b.TextSize = 11
	b.ClearTextOnFocus = false
	b.Parent = parent
	self:corner(b, 4)
	self:stroke(b, self.T.STROKE, 1)
	return b
end

function VoidUI:scroll(parent, size, pos)
	local sf = Instance.new("ScrollingFrame")
	sf.Size = size or UDim2.new(1, 0, 1, 0)
	sf.Position = pos or UDim2.new(0, 0, 0, 0)
	sf.BackgroundTransparency = 1
	sf.BorderSizePixel = 0
	sf.ScrollBarThickness = 3
	sf.ScrollBarImageColor3 = self.T.ACCENT
	sf.CanvasSize = UDim2.new(0, 0, 0, 0)
	sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
	sf.Parent = parent
	return sf
end

function VoidUI:list(parent, pad)
	local l = Instance.new("UIListLayout", parent)
	l.Padding = UDim.new(0, pad or 4)
	l.SortOrder = Enum.SortOrder.LayoutOrder
	return l
end

function VoidUI:pad(parent, t, l, r, b_)
	local p = Instance.new("UIPadding", parent)
	p.PaddingTop = UDim.new(0, t or 0)
	p.PaddingLeft = UDim.new(0, l or 0)
	p.PaddingRight = UDim.new(0, r or 0)
	p.PaddingBottom = UDim.new(0, b_ or 0)
	return p
end

function VoidUI:divider(parent, lo)
	local d = self:frame(parent, UDim2.new(1, 0, 0, 1), nil, Color3.fromRGB(28, 28, 28))
	d.LayoutOrder = lo
	return d
end

function VoidUI:toggle(parent, pos, initState, onChange)
	local T = self.T
	local box = self:frame(parent, UDim2.new(0, 44, 0, 22), pos, T.TOGGLE_OFF)
	self:corner(box, 11)
	self:stroke(box, T.STROKE, 1)
	local knob = self:frame(box, UDim2.new(0, 16, 0, 16), UDim2.new(0, 3, 0.5, -8), Color3.fromRGB(220, 220, 220))
	self:corner(knob, 8)
	local state = initState and true or false
	local function apply(s)
		TweenSvc:Create(box, TweenInfo.new(0.15), { BackgroundColor3 = s and T.TOGGLE_ON or T.TOGGLE_OFF }):Play()
		TweenSvc:Create(knob, TweenInfo.new(0.15), { Position = s and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8) }):Play()
		if typeof(onChange) == "function" then onChange(s) end
	end
	apply(state)
	local hit = self:button(box, "", UDim2.new(1, 0, 1, 0), nil, T.BTN, T.TEXT)
	hit.BackgroundTransparency = 1
	hit.ZIndex = 5
	hit.MouseButton1Click:Connect(function() state = not state; apply(state) end)
	return { Set = function(v) state = v and true or false; apply(state) end, Get = function() return state end, Frame = box }
end

function VoidUI:inlinePicker(parent, options, currentVal, onSelect, size, pos)
	local T = self.T
	local container = self:frame(parent, size or UDim2.new(1, 0, 0, 28), pos, T.BTN)
	self:corner(container, 5)
	self:stroke(container, T.STROKE, 1)
	local selectedIdx = 1
	for i, v in ipairs(options) do
		if v == currentVal then selectedIdx = i; break end
	end
	local leftBtn = self:button(container, "<", UDim2.new(0, 28, 1, -2), UDim2.new(0, 1, 0, 1), T.PANEL, T.ACCENT, 13)
	self:corner(leftBtn, 4)
	leftBtn.Font = Enum.Font.GothamBold
	local display = self:label(container, options[selectedIdx] or "", UDim2.new(1, -62, 1, 0), UDim2.new(0, 30, 0, 0), T.ACCENT, 9, Enum.TextXAlignment.Center)
	display.Font = Enum.Font.GothamBold
	display.TextTruncate = Enum.TextTruncate.AtEnd
	local rightBtn = self:button(container, ">", UDim2.new(0, 28, 1, -2), UDim2.new(1, -29, 0, 1), T.PANEL, T.ACCENT, 13)
	self:corner(rightBtn, 4)
	rightBtn.Font = Enum.Font.GothamBold
	local function pick(idx)
		selectedIdx = ((idx - 1) % #options) + 1
		display.Text = options[selectedIdx]
		if typeof(onSelect) == "function" then onSelect(options[selectedIdx]) end
	end
	leftBtn.MouseButton1Click:Connect(function() pick(selectedIdx - 1) end)
	rightBtn.MouseButton1Click:Connect(function() pick(selectedIdx + 1) end)
	return {
		Get = function() return options[selectedIdx] end,
		Set = function(v)
			for i, opt in ipairs(options) do
				if opt == v then selectedIdx = i; display.Text = v; break end
			end
		end,
		Frame = container,
		Close = function() end,
		DropFrame = nil,
	}
end

function VoidUI:accordion(parent, title, lo, startOpen)
	local T = self.T
	local header = self:frame(parent, UDim2.new(1, 0, 0, 32), nil, Color3.fromRGB(3, 3, 3))
	header.LayoutOrder = lo
	self:corner(header, 6)
	self:stroke(header, T.ACCENT, 1)
	self:label(header, title, UDim2.new(1, -40, 1, 0), UDim2.new(0, 12, 0, 0), T.ACCENT, 10)
	local arrow = self:label(header, startOpen and "v" or ">", UDim2.new(0, 20, 1, 0), UDim2.new(1, -26, 0, 0), T.DIM, 11, Enum.TextXAlignment.Center)
	local hitBtn = self:button(header, "", UDim2.new(1, 0, 1, 0), nil, T.BTN, T.TEXT)
	hitBtn.BackgroundTransparency = 1
	hitBtn.ZIndex = 5
	local body = self:frame(parent, UDim2.new(1, 0, 0, 0), nil, Color3.fromRGB(3, 3, 3))
	body.LayoutOrder = lo + 1
	body.AutomaticSize = Enum.AutomaticSize.Y
	body.Visible = startOpen ~= false
	self:corner(body, 6)
	self:stroke(body, T.ACCENT, 1)
	local inner = self:frame(body, UDim2.new(1, 0, 1, 0), nil, Color3.fromRGB(3, 3, 3), 0)
	inner.AutomaticSize = Enum.AutomaticSize.Y
	self:list(inner, 5)
	self:pad(inner, 8, 8, 8, 8)
	local isOpen = startOpen ~= false
	hitBtn.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		body.Visible = isOpen
		arrow.Text = isOpen and "v" or ">"
	end)
	return { Header = header, Body = body, Inner = inner, Arrow = arrow }
end

function VoidUI.fmtTime(secs)
	secs = math.floor(secs)
	local h = math.floor(secs / 3600)
	local m = math.floor((secs % 3600) / 60)
	local s = secs % 60
	if h > 0 then return string.format("%dh %dm %ds", h, m, s)
	elseif m > 0 then return string.format("%dm %ds", m, s)
	else return string.format("%ds", s) end
end

function VoidUI:buildPetList(scrollFrame, activePets, selMap, onToggle, searchTxt, getKGFn, getInvFn, isFavFn, getAgeFn)
	local T = self.T
	for _, c in ipairs(scrollFrame:GetChildren()) do if c:IsA("GuiObject") then c:Destroy() end end
	local search = string.lower(searchTxt or "")
	local inv = getInvFn()
	local list = {}
	for uuid in pairs(inv) do table.insert(list, uuid) end
	table.sort(list, function(a, b)
		local aA = activePets[a] and 1 or 0
		local bA = activePets[b] and 1 or 0
		if aA ~= bA then return aA > bA end
		return getKGFn(a) > getKGFn(b)
	end)
	for i, uuid in ipairs(list) do
		local d = inv[uuid]; if not d then continue end
		local petType = d.PetType or "?"
		if search ~= "" and not petType:lower():find(search, 1, true) then continue end
		local isActive = activePets[uuid]
		local isSel = selMap[uuid] == true
		local age = d.PetData and (d.PetData.Level or 0) or 0
		local kg = getKGFn(uuid)
		local base = d.PetData and (d.PetData.BaseWeight or 0) or 0
		local fv = isFavFn(uuid) and " ❤" or ""
		local activeTxt = isActive and " (active)" or ""
		local txt = string.format("[%s%s%s]  Age %d  |  %.2f KG  |  Base %.2f", petType, activeTxt, fv, age, kg, base)
		local row = self:button(scrollFrame, txt, UDim2.new(1, 0, 0, 26), nil,
			isSel and T.SEL_BG or (isActive and T.ACTIVE_BG or Color3.fromRGB(13, 13, 13)),
			isSel and T.SEL_TXT or (isActive and T.ACTIVE_TXT or T.TEXT), 9)
		row.LayoutOrder = i
		row.TextXAlignment = Enum.TextXAlignment.Left
		self:pad(row, 0, 8, 4, 0)
		self:stroke(row, isSel and T.ACCENT or T.STROKE, 1)
		row.MouseButton1Click:Connect(function() onToggle(uuid, petType, kg, isActive) end)
	end
end

function VoidUI:boostPicker(parent, boostOptions, selMap, onClose)
	local T = self.T
	local ov = self:frame(parent, UDim2.new(1, 0, 1, 0), nil, T.BG)
	ov.ZIndex = 40
	ov.Visible = false
	local hdr = self:frame(ov, UDim2.new(1, 0, 0, 28), nil, T.PANEL)
	self:stroke(hdr, T.STROKE, 1)
	self:label(hdr, "Select Boost", UDim2.new(1, -60, 1, 0), UDim2.new(0, 8, 0, 0), T.ACCENT, 10)
	local doneBtn = self:button(hdr, "Done", UDim2.new(0, 44, 0, 22), UDim2.new(1, -48, 0.5, -11), T.ACCENT, T.SEL_TXT, 9)
	self:stroke(doneBtn, T.ACCENT, 1)
	local searchBox = self:input(ov, "", "Search boost...", UDim2.new(1, -8, 0, 22), UDim2.new(0, 4, 0, 32))
	searchBox.TextColor3 = T.TEXT
	local sf = self:scroll(ov, UDim2.new(1, 0, 1, -58), UDim2.new(0, 0, 0, 58))
	self:list(sf, 4)
	self:pad(sf, 4, 6, 6, 4)
	local function rebuild()
		for _, c in ipairs(sf:GetChildren()) do if c:IsA("GuiObject") then c:Destroy() end end
		local query = string.lower(searchBox.Text)
		for i, b in ipairs(boostOptions) do
			if query ~= "" and not b.name:lower():find(query, 1, true) then continue end
			local isSel = selMap[b.name] == true
			local row = self:button(sf, b.name, UDim2.new(1, 0, 0, 28), nil,
				isSel and T.SEL_BG or T.BTN,
				isSel and T.SEL_TXT or T.TEXT, 10)
			row.LayoutOrder = i
			row.TextXAlignment = Enum.TextXAlignment.Center
			self:corner(row, 6)
			self:stroke(row, isSel and T.ACCENT or T.STROKE, 1)
			row.MouseButton1Click:Connect(function()
				if selMap[b.name] then selMap[b.name] = nil
				else selMap[b.name] = true end
				rebuild()
			end)
		end
	end
	searchBox:GetPropertyChangedSignal("Text"):Connect(rebuild)
	doneBtn.MouseButton1Click:Connect(function()
		ov.Visible = false
		if onClose then onClose() end
	end)
	rebuild()
	return {
		Frame = ov,
		Open = function() ov.Visible = true; rebuild() end,
		Close = function() ov.Visible = false end,
	}
end

return VoidUI
