
-- Defining the parameters with user inputs
local Z = ui_number("Number of Teeth", 9, 7, 40) -- Number of Teeth
local N = Z + 1 -- Number of Pins (Rollers)
local R = Z * 3 -- Rotor Radius, scales with Z
local da = 1.8 -- Adjusted Shaft Eccentricity to ensure contact
local extrusion_depth = ui_scalar("Face Width", 6, 3, 10) -- Extrusion depth of the gear
local gear_hole_radius = ui_number("Gear Hole Radius", 10, 8, 13) -- Radius of the hole in the gear

-- Fixed parameters for the model
local dp = 11.5 -- Pin diameter
local base_plate_thickness = ui_scalar("Base Plate Thickness", 10, 1, 10) -- Thickness of the base plate
local pin_height = ui_scalar("Pin Height", 7, 1, 10) -- Height of the pins
local pin_radius = dp / 2 -- Radius of the pins
local central_shaft_radius = ui_number("Central Shaft Radius", 4, 4, 7) -- Radius of the central shaft
local eccentric_cam_radius = central_shaft_radius * 1.5 -- Radius of the larger part of the eccentric cam
local input_shaft_radius = central_shaft_radius -- Radius of the smaller part of the eccentric cam (input shaft)
local central_shaft_height = base_plate_thickness + extrusion_depth + 2 -- Height of the central shaft including extra height

-- Derived parameters for calculations
local housing_circle_circumference = 2 * math.pi * R -- Circumference of the housing circle
local roller_radius = housing_circle_circumference / (4 * N) -- Roller radius

-- Function to calculate the cycloidal path
function cycloidal_path(theta)
    local x = (R * math.cos(theta)) 
            - (roller_radius * math.cos(theta + math.atan(math.sin((1 - N) * theta) / ((R / (da * N)) - math.cos((1 - N) * theta)))))
            - (da * math.cos(N * theta))
    local y = (-R * math.sin(theta)) 
            + (roller_radius * math.sin(theta + math.atan(math.sin((1 - N) * theta) / ((R / (da * N)) - math.cos((1 - N) * theta)))))
            + (da * math.sin(N * theta))
    return x, y
end

-- Generate the cycloidal gear path
local theta = {}
local X = {}
local Y = {}
for i = 0, 719 do
    theta[i + 1] = -math.pi + (2 * math.pi / 719) * i
    local angle = theta[i + 1]
    local X_val, Y_val = cycloidal_path(angle)
    table.insert(X, X_val)
    table.insert(Y, Y_val)
end

-- Function to calculate pin positions
local function calculate_pin_positions(R, da, N)
    local positions = {}
    local theta_step = (2 * math.pi) / N
    for i = 0, N - 1 do
        local theta = theta_step * i
        local x = (R + da) * math.cos(theta)
        local y = (R + da) * math.sin(theta)
        table.insert(positions, {x, y})
    end
    return positions
end

-- Function to create a 3D cycloidal gear by extruding the 2D path
local function create3DCycloidalGear(X, Y, depth)
    local points = {}
    for i = 1, #X do
        table.insert(points, v(X[i], Y[i]))
    end
    return linear_extrude(v(0, 0, depth), points)
end

local cycloidalGear = create3DCycloidalGear(X, Y, extrusion_depth) -- Create the cycloidal gear

-- Create a hole in the center of the gear
local centerHole = translate(0, 0, extrusion_depth / 2) * cylinder(gear_hole_radius, extrusion_depth)

-- Subtract the hole from the cycloidal gear to create the final gear shape
local finalGear = difference(cycloidalGear, centerHole)

-- Function to create the base plate
local function createBasePlate(radius, thickness)
    return translate(0, 0, -thickness / 2) * difference(
        cylinder(radius, thickness),
        translate(0, 0, -thickness / 2) * cylinder(eccentric_cam_radius, thickness)
    )
end

-- Function to create pins at calculated positions
local function createPins(pin_positions, pin_radius, pin_height)
    local pins = {}
    for _, pos in ipairs(pin_positions) do
        local x, y = unpack(pos)
        table.insert(pins, translate(x, y, 0) * cylinder(pin_radius, pin_height))
    end
    return union(pins)
end

-- Function to create the eccentric cam and input shaft
local function createEccentricCam(eccentric_radius, input_radius, eccentric_height, input_height, offset)
    -- Create the larger part of the eccentric cam
    local eccentric_cam = translate(0, 0, -eccentric_height / 2) * cylinder(eccentric_radius, eccentric_height)
    
    -- Create the smaller input shaft, offset within the larger eccentric cam
    local input_shaft = translate(offset, 0, -eccentric_height / 2) * cylinder(input_radius, eccentric_height + input_height)
    
    -- Combine the larger and smaller parts
    return union({
        eccentric_cam,
        input_shaft
    })
end

-- Generate the components
local base_plate_radius = R + 10 -- Base plate slightly larger than gear radius
local base_plate = createBasePlate(base_plate_radius, base_plate_thickness) -- Create the base plate

local pin_positions = calculate_pin_positions(R, da, N) -- Calculate pin positions
local pins = createPins(pin_positions, pin_radius, pin_height) -- Create pins

local eccentric_cam = createEccentricCam(eccentric_cam_radius, input_shaft_radius, base_plate_thickness, extrusion_depth, eccentric_cam_radius - input_shaft_radius) -- Create the eccentric cam and input shaft

-- Rotation and Translation
local eccentric_cam_rotation = ui_numberBox("Rotation", 0) -- Eccentric cam rotation input
local gear_translation_x = da * math.cos(math.rad(eccentric_cam_rotation * 10)) -- Calculate gear translation in x
local gear_translation_y = da * math.sin(math.rad(eccentric_cam_rotation * 10)) -- Calculate gear translation in y
local gear_rotation = -eccentric_cam_rotation * 10 / Z  

-- Emit part separately for 3D printing


emit(eccentric_cam, 3)