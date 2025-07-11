local TweenService  = game:GetService("TweenService")
local Players       = game:GetService("Players")
local UserInput     = game:GetService("UserInputService")
local RunService    = game:GetService("RunService")

local player, root  = Players.LocalPlayer
local function updateCharacter()
    local char = player.Character or player.CharacterAdded:Wait()
    root = char:WaitForChild("HumanoidRootPart", 5)
end
updateCharacter()
player.CharacterAdded:Connect(updateCharacter)

local function goUp()
    if root then
        local currentPos = root.Position
        local targetPos = currentPos + Vector3.new(0, 200, 0)
        TweenService:Create(root, TweenInfo.new(1.2), {CFrame = CFrame.new(targetPos)}):Play()
    end
end

local function dropDown()
    if root then
        root.CFrame = root.CFrame - Vector3.new(0, 50, 0)
    end
end

local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn, gui.Parent = "ToggleDoorGui", false, player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size        = UDim2.new(0, 120, 0, 40)
frame.AnchorPoint = Vector2.new(1, 0)
frame.Position    = UDim2.new(1, -10, 0, 60)
frame.BackgroundTransparency = 0.15
frame.BackgroundColor3       = Color3.fromRGB(25,25,25)
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,6)

local stroke = Instance.new("UIStroke", frame)
stroke.Thickness, stroke.ApplyStrokeMode = 2, Enum.ApplyStrokeMode.Border
RunService.Heartbeat:Connect(function()
    stroke.Color = Color3.fromHSV((tick()*0.2)%1, 1, 1)
end)

local toggle = Instance.new("TextButton", frame)
toggle.Size, toggle.Position   = UDim2.new(1,-12,1,-12), UDim2.new(0,6,0,6)
toggle.FontFace                = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold)
toggle.TextScaled              = true
toggle.TextColor3              = Color3.new(1,1,1)
toggle.TextStrokeTransparency  = 0.2
toggle.TextStrokeColor3        = Color3.new(0,0,0)
toggle.AutoButtonColor         = false
toggle.Text, toggle.BackgroundColor3 = "NightX", Color3.fromRGB(200,60,60)
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,6)

local grad = Instance.new("UIGradient", toggle)
grad.Rotation = 90
grad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200,200,200))
}

local pulse = Instance.new("Frame", toggle)
pulse.BackgroundTransparency, pulse.BackgroundColor3 = 1, Color3.new(1,1,1)
pulse.Size, pulse.ZIndex = UDim2.new(1,0,1,0), toggle.ZIndex - 1
Instance.new("UICorner", pulse).CornerRadius = UDim.new(0,6)

do
    local dragging, dragInput, dragStart, startPos
    local function update(inp)
        local d = inp.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                   startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
    frame.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, inp.Position, frame.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
            dragInput = inp
        end
    end)
    UserInput.InputChanged:Connect(function(inp)
        if inp == dragInput and dragging then update(inp) end
    end)
end

local enabled = false
local function tween(o,p,t,s)
    TweenService:Create(o,TweenInfo.new(t or 0.25, Enum.EasingStyle[s or "Quad"], Enum.EasingDirection.Out),p):Play()
end

local function setState(state)
    enabled = state
    toggle.Text = state and "Teleport On" or "Teleport Off"
    tween(grad,   {Rotation = state and 0 or 90}, 0.3)
    tween(toggle, {BackgroundColor3 = state and Color3.fromRGB(60,220,120) or Color3.fromRGB(200,60,60)}, 0.25)
    toggle.Size = UDim2.new(1,-12,1,-12)
    tween(toggle,{Size = UDim2.new(1,-6,1,-6)},0.12,"Sine")
    task.delay(0.12,function()
        tween(toggle,{Size = UDim2.new(1,-12,1,-12)},0.1,"Sine")
    end)
    pulse.BackgroundTransparency = 0.7
    pulse.Size = UDim2.new(1,0,1,0)
    tween(pulse,{BackgroundTransparency = 1, Size = UDim2.new(1.4,0,1.4,0)},0.35,"Quad")
    if state then goUp() else dropDown() end
end

toggle.MouseButton1Click:Connect(function()
    setState(not enabled)
end)