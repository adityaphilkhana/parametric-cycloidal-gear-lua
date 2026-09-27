-- Defining parameters for the gear --
local Z = ui_number("Number of Teeth", 20, 10, 40) -- Number of Teeth
local R = ui_number("Rotor Radius", 30, 10, 50) -- Rotor Radius
local da = ui_scalar("Tip diameter", 1, 0.1, 2) -- Tip Diameter
local gear_height = ui_scalar("Gear Height", 5, 1, 10) -- Gear height
local extrusion_depth = ui_scalar("Face Width", 5, 1, 10) -- Face Width
local gear_hole_radius = ui_number("Gear Hole Radius", 10, 5, 20) -- Radius of the hole in the gear

-- Calculate roller radius --
local HCC = 2 * math.pi * R -- Housing Circle Circumference
local Rr = HCC / (4 * Z) -- Roller Radius (adapted from pins to teeth)

-- Generate the cycloidal path --
local theta = {}
local X = {}
local Y = {}
for i = 0, 719 do
    theta[i + 1] = -math.pi + (2 * math.pi / 719) * i
    local angle = theta[i + 1]
    local X_val = (R * math.cos(angle)) - (Rr * math.cos(angle + math.atan(math.sin((1 - Z) * angle) / ((R / (da * Z)) - math.cos((1 - Z) * angle))))) - (da * math.cos(Z * angle))
    local Y_val = (-R * math.sin(angle)) + (Rr * math.sin(angle + math.atan(math.sin((1 - Z) * angle) / ((R / (da * Z)) - math.cos((1 - Z) * angle))))) + (da * math.sin(Z * angle))
    table.insert(X, X_val)
    table.insert(Y, Y_val)
end

-- Create 3D cycloidal gear by extruding the 2D path --
local function create3DCycloidalGear(X, Y, depth)
    local points = {}
    for i = 1, #X do
        table.insert(points, v(X[i], Y[i]))
    end
    return linear_extrude(v(0, 0, depth), points)
end

local cycloidalGear = create3DCycloidalGear(X, Y, extrusion_depth)

-- Create a hole in the center --
local centerHole = cylinder(gear_hole_radius, extrusion_depth)

-- Subtract the hole from the cycloidal gear --
local finalGear = difference(cycloidalGear, centerHole)
emit(finalGear, 6)