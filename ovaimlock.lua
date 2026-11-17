
--==================================================
-- NEXUS AIM HUB V4
-- Roblox Studio | LocalScript
-- Multiplayer experience
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- SETTINGS
local aimEnabled = false
local espEnabled = false
local aimMode = "Smooth"
local smoothness = 20
local fov = 250
local targetPart = "Head"
local currentTarget = nil

local espObjects = {}
local menuOpen = true

-- COLORS
local BLUE = Color3.fromRGB(30, 120, 255)
local DARK = Color3.fromRGB(15, 19, 31)
local PANEL = Color3.fromRGB(29, 38, 57)
local WHITE = Color3.fromRGB(255, 255, 255)

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "NexusAimHubV4"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(270, 390)
frame.Position = UDim2.new(0.5, -135, 0.5, -195)
frame.BackgroundColor3 = DARK
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius =
    UDim.new(0, 14)

local stroke = Instance.new("UIStroke")
stroke.Color = BLUE
stroke.Thickness = 1.5
stroke.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundColor3 = Color3.fromRGB(24, 75, 155)
title.Text = "NEXUS AIM HUB V4"
title.TextColor3 = WHITE
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.Parent = frame

Instance.new("UICorner", title).CornerRadius =
    UDim.new(0, 12)

local function makeButton(text, y, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -24, 0, 35)
    b.Position = UDim2.fromOffset(12, y)
    b.BackgroundColor3 = color or PANEL
    b.TextColor3 = WHITE
    b.Text = text
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.AutoButtonColor = true
    b.Parent = frame

    Instance.new("UICorner", b).CornerRadius =
        UDim.new(0, 8)

    return b
end

-- OPEN / CLOSE BUTTON
local openButton = Instance.new("TextButton")
openButton.Size = UDim2.fromOffset(105, 42)
openButton.Position = UDim2.new(0, 15, 0.45, 0)
openButton.BackgroundColor3 = BLUE
openButton.Text = "NEXUS MENU"
openButton.TextColor3 = WHITE
openButton.TextSize = 13
openButton.Font = Enum.Font.GothamBold
openButton.Parent = gui

Instance.new("UICorner", openButton).CornerRadius =
    UDim.new(0, 10)

openButton.Activated:Connect(function()
    menuOpen = not menuOpen
    frame.Visible = menuOpen
end)

--==================================================
-- BUTTONS
--==================================================

local aimButton = makeButton("AIM ASSIST: OFF", 55)
local modeButton = makeButton("MODE: SMOOTH", 96)
local partButton = makeButton("TARGET: HEAD", 137)
local speedButton = makeButton("SMOOTHNESS: 20%", 178)
local fovButton = makeButton("FOV: 250", 219)

local espButton = makeButton("PLAYER ESP: OFF", 260)
local distanceButton = makeButton("DISTANCE LABELS: ON", 301)
local closeButton = makeButton("CLOSE MENU", 342, BLUE)

local distanceEnabled = true

--==================================================
-- AIM SETTINGS
--==================================================

aimButton.Activated:Connect(function()
    aimEnabled = not aimEnabled
    currentTarget = nil
    aimButton.Text = aimEnabled
        and "AIM ASSIST: ON"
        or "AIM ASSIST: OFF"
end)

modeButton.Activated:Connect(function()
    aimMode = aimMode == "Smooth" and "Hard" or "Smooth"
    modeButton.Text = "MODE: " .. string.upper(aimMode)
end)

partButton.Activated:Connect(function()
    targetPart = targetPart == "Head"
        and "HumanoidRootPart" or "Head"

    partButton.Text = targetPart == "Head"
        and "TARGET: HEAD"
        or "TARGET: TORSO"
end)

speedButton.Activated:Connect(function()
    smoothness = smoothness + 10

    if smoothness > 100 then
        smoothness = 10
    end

    speedButton.Text =
        "SMOOTHNESS: " .. smoothness .. "%"
end)

fovButton.Activated:Connect(function()
    fov = fov + 50

    if fov > 400 then
        fov = 100
    end

    fovButton.Text = "FOV: " .. fov
end)

closeButton.Activated:Connect(function()
    menuOpen = false
    frame.Visible = false
end)

--==================================================
-- PLAYER ESP
--==================================================

local function getPlayerColor(other)
    if player.Team and other.Team then
        if player.Team == other.Team then
            return Color3.fromRGB(40, 220, 120)
        else
            return Color3.fromRGB(255, 65, 75)
        end
    end

    return Color3.fromRGB(40, 160, 255)
end

local function removeESP(other)
    local objects = espObjects[other]

    if objects then
        if objects.highlight then
            objects.highlight:Destroy()
        end

        if objects.billboard then
            objects.billboard:Destroy()
        end

        espObjects[other] = nil
    end
end

local function createESP(other)
    if other == player then return end

    removeESP(other)

    local character = other.Character
    if not character then return end

    local humanoid =
        character:FindFirstChildOfClass("Humanoid")

    local head = character:FindFirstChild("Head")
    local root = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or humanoid.Health <= 0 then
        return
    end

    local adornee = head or root
    if not adornee then return end

    -- OUTLINE THROUGH WALLS
    local highlight = Instance.new("Highlight")
    highlight.Name = "NexusPlayerHighlight"
    highlight.Adornee = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = getPlayerColor(other)
    highlight.OutlineColor = WHITE
    highlight.FillTransparency = 0.72
    highlight.OutlineTransparency = 0
    highlight.Enabled = espEnabled
    highlight.Parent = character

    -- NAME AND DISTANCE TAG
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NexusPlayerTag"
    billboard.Adornee = adornee
    billboard.Size = UDim2.fromOffset(180, 55)
    billboard.StudsOffset = Vector3.new(0, 2.8, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = espEnabled
    billboard.Parent = gui

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 25)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = other.DisplayName
    nameLabel.TextColor3 = getPlayerColor(other)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Parent = billboard

    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Position = UDim2.fromOffset(0, 24)
    distanceLabel.Size = UDim2.new(1, 0, 0, 20)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "Distance: --"
    distanceLabel.TextColor3 = WHITE
    distanceLabel.TextStrokeTransparency = 0
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.TextSize = 11
    distanceLabel.Parent = billboard

    espObjects[other] = {
        highlight = highlight,
        billboard = billboard,
        nameLabel = nameLabel,
        distanceLabel = distanceLabel
    }
end

-- ESP TOGGLE
espButton.Activated:Connect(function()
    espEnabled = not espEnabled

    espButton.Text = espEnabled
        and "PLAYER ESP: ON"
        or "PLAYER ESP: OFF"

    if espEnabled then
        for _, other in ipairs(Players:GetPlayers()) do
            if other ~= player then
                createESP(other)
            end
        end
    else
        for other in pairs(espObjects) do
            removeESP(other)
        end
    end
end)

distanceButton.Activated:Connect(function()
    distanceEnabled = not distanceEnabled

    distanceButton.Text = distanceEnabled
        and "DISTANCE LABELS: ON"
        or "DISTANCE LABELS: OFF"

    for _, objects in pairs(espObjects) do
        objects.distanceLabel.Visible = distanceEnabled
    end
end)

-- PLAYER JOIN / LEAVE
local function setupPlayer(other)
    if other == player then return end

    other.CharacterAdded:Connect(function()
        task.wait(0.5)

        if espEnabled then
            createESP(other)
        end
    end)

    if espEnabled and other.Character then
        createESP(other)
    end
end

for _, other in ipairs(Players:GetPlayers()) do
    setupPlayer(other)
end

Players.PlayerAdded:Connect(setupPlayer)

Players.PlayerRemoving:Connect(function(other)
    removeESP(other)
end)

--==================================================
-- WALL CHECK
--==================================================

local function canSeeTarget(character, part)
    local myCharacter = player.Character
    if not myCharacter or not part then
        return false
    end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {myCharacter}
    params.IgnoreWater = true

    local direction =
        part.Position - camera.CFrame.Position

    local result = workspace:Raycast(
        camera.CFrame.Position,
        direction,
        params
    )

    return result ~= nil
        and result.Instance:IsDescendantOf(character)
end

--==================================================
-- FIND TARGET
--==================================================

local function getTarget()
    local closest = nil
    local shortest = fov
    local center = camera.ViewportSize / 2

    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player then
            local character = other.Character

            local humanoid = character and
                character:FindFirstChildOfClass("Humanoid")

            local part = character and
                character:FindFirstChild(targetPart)

            if humanoid and humanoid.Health > 0
                and part and part:IsA("BasePart") then

                local pos, visible =
                    camera:WorldToViewportPoint(part.Position)

                if visible and pos.Z > 0 then
                    local distance =
                        (Vector2.new(pos.X, pos.Y) - center).Magnitude

                    if distance < shortest
                        and canSeeTarget(character, part) then

                        shortest = distance
                        closest = part
                    end
                end
            end
        end
    end

    return closest
end

--==================================================
-- AIM LOOP
--==================================================

RunService:BindToRenderStep(
    "NexusAimV4",
    Enum.RenderPriority.Camera.Value + 1,
    function()
        if not aimEnabled then
            currentTarget = nil
            return
        end

        if currentTarget then
            local character = currentTarget.Parent

            local humanoid = character and
                character:FindFirstChildOfClass("Humanoid")

            if not humanoid
                or humanoid.Health <= 0
                or not currentTarget:IsDescendantOf(workspace)
                or not canSeeTarget(character, currentTarget) then

                currentTarget = nil
            end
        end

        if not currentTarget then
            currentTarget = getTarget()
        end

        if currentTarget then
            local desired = CFrame.lookAt(
                camera.CFrame.Position,
                currentTarget.Position
            )

            if aimMode == "Hard" then
                camera.CFrame = desired
            else
                camera.CFrame = camera.CFrame:Lerp(
                    desired,
                    smoothness / 100
                )
            end
        end
    end
)

--==================================================
-- ESP UPDATE LOOP
--==================================================

RunService.Heartbeat:Connect(function()
    if not espEnabled then return end

    local myCharacter = player.Character
    local myRoot = myCharacter and
        myCharacter:FindFirstChild("HumanoidRootPart")

    for other, objects in pairs(espObjects) do
        local character = other.Character
        local humanoid = character and
            character:FindFirstChildOfClass("Humanoid")

        local root = character and
            character:FindFirstChild("HumanoidRootPart")

        if not character or not humanoid
            or humanoid.Health <= 0 or not root then

            removeESP(other)
        else
            local color = getPlayerColor(other)

            objects.highlight.FillColor = color
            objects.nameLabel.TextColor3 = color

            if myRoot then
                local distance =
                    (myRoot.Position - root.Position).Magnitude

                objects.distanceLabel.Text =
                    "Distance: " .. math.floor(distance) .. " studs"
            end

            objects.distanceLabel.Visible = distanceEnabled
        end
    end
end)

print("NEXUS AIM HUB V4 LOADED SUCCESSFULLY")
