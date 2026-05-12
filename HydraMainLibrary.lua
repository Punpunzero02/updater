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

-- FIXED: Simple left/right cycle picker — no floating dropdown, no scroll-overlap bug
function VoidUI:inlinePicker(parent, options, currentVal, onSelect, size, pos)
	local T = self.T
	local container = self:frame(parent, size or UDim2.new(1, 0, 0, 28), pos, T.BTN)
	self:corner(container, 5)
	self:stroke(container, T.STROKE, 1)

	local selectedIdx = 1
	for i, v in ipairs(options) do
		if v == currentVal then selectedIdx = i; break end
	end

	-- Left arrow button
	local leftBtn = self:button(container, "<", UDim2.new(0, 28, 1, -2), UDim2.new(0, 1, 0, 1), T.PANEL, T.ACCENT, 13)
	self:corner(leftBtn, 4)
	leftBtn.Font = Enum.Font.GothamBold

	-- Center display label
	local display = self:label(
		container,
		options[selectedIdx] or "",
		UDim2.new(1, -62, 1, 0),
		UDim2.new(0, 30, 0, 0),
		T.ACCENT, 9,
		Enum.TextXAlignment.Center
	)
	display.Font = Enum.Font.GothamBold
	display.TextTruncate = Enum.TextTruncate.AtEnd

	-- Right arrow button
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

return VoidUI
