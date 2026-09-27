-----------------------------------------------------------------
-- Case Study Cyber Physical Production Systems using AM (SS2024)
--
--  Under guidance of: Prof. Dr. Ing. Stefan Scherbarth
----------------------------------------------------------------
--  Group 19: Gear with Cycloidal Tooth gear geometry
--  Members:
--   Venkata Rama Aditya Philkana - 22303031
--   Vishnu Suresh                 - 22304456
--   Jatin Naga Datta Sai Saran Yenugu    - 22301237

-- User inputs for defining the parameters
local Z = ui_number("Number of Teeth", 9, 7, 40) -- Number of Teeth
local N = Z + 1 -- Number of Pins (Rollers)
local R = Z * 3 -- Rotor Radius, scales with Z
local da = 1.8 -- Adjusted Shaft Eccentricity to ensure contact
local extrusion_depth = ui_scalar("Face Width", 6, 3, 10) -- Extrusion depth of the gear
local gear_hole_radius = ui_number("Gear Hole Radius", 10, 8, 13) -- Radius of the hole in the gear
local base_plate_thickness = ui_scalar("Base Plate Thickness", 10, 1, 10) -- Thickness of the base plate
local pin_height = ui_scalar("Pin Height", 7, 1, 10) -- Height of the pins
local central_shaft_radius = ui_number("Central Shaft Radius", 4, 4, 7) -- Radius of the central shaft

-- Fixed parameters for the model
local dp = 11.5 -- Pin diameter
local pin_radius = dp / 2 -- Radius of the pins
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

-- Function to generate the cycloidal gear path
function generate_gear_path()
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
    return X, Y
end
--This above section of the code is responsible for calculating the coordinates that form the shape of the cycloidal gear. Imagine drawing a curve by plotting 720 points around a circle. Each point's position is determined by an angle, theta, which ranges from -p (negative pi) to p (pi). To get these positions, the code uses the cycloidal_path function. This function takes an angle, theta, and calculates where the point should be on the X and Y axes. The calculations consider the gear's rotor radius, the radius of the rollers (pins), and how much the shaft is offset from the center (eccentricity).

-- Function to calculate pin positions
function calculate_pin_positions(R, da, N)
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
function create_3D_cycloidal_gear(X, Y, depth)
    local points = {}
    for i = 1, #X do
        table.insert(points, v(X[i], Y[i]))
    end
    return linear_extrude(v(0, 0, depth), points)
end
-- The above part defines a function that takes the 2D coordinates of the cycloidal path and extrudes them into a 3D shape to form the cycloidal gear. The function "create3DCycloidalGear" is defined and it starts by creating an empty list called points. The function then goes through all the X and Y coordinates that define the cycloidal path. For each coordinate, it adds a point to the points list.Once all the points are collected, the function uses linear_extrude to stretch this 2D outline upwards into a 3D shape. The height of this shape is determined by the extrusion_depth parameter.

-- Function to create the base plate with a central hole
function create_base_plate(radius, thickness, hole_radius)
    return translate(0, 0, -thickness / 2) * difference(
        cylinder(radius, thickness),
        translate(0, 0, -thickness / 2) * cylinder(hole_radius, thickness)
    )
end

-- Function to create pins at calculated positions
function create_pins(pin_positions, pin_radius, pin_height)
    local pins = {}
    for _, pos in ipairs(pin_positions) do
        local x, y = unpack(pos)
        table.insert(pins, translate(x, y, 0) * cylinder(pin_radius, pin_height))
    end
    return union(pins)
end
-- The above function creates the cylindrical pins that will be positioned on the base plate. These pins are crucial because they interact with the cycloidal gear, providing support and guiding its movement. The function "createpins" is defined and It starts by making an empty list called pins to keep track of all the pins we're going to create. The function goes through each (x, y) coordinate where a pin needs to be placed. These positions have been calculated earlier to ensure the pins are correctly spaced.For each coordinate, it uses the translate function to move to the correct position and the cylinder function to create a pin of the specified radius and height. Each pin is then added to the 'pins' list. Once all the pins are created, the function combines them into a single object using the union function. This combined object is then returned by the function.

-- Function to create the eccentric cam and input shaft
function create_eccentric_cam(eccentric_radius, input_radius, eccentric_height, input_height, offset)
    local eccentric_cam = translate(0, 0, -eccentric_height / 2) * cylinder(eccentric_radius, eccentric_height)
    local input_shaft = translate(offset, 0, -eccentric_height / 2) * cylinder(input_radius, eccentric_height + input_height)
    return union({ eccentric_cam, input_shaft })
end

-- Main function to generate components
function generate_components()
    local X, Y = generate_gear_path() -- Generate gear path
    local cycloidal_gear = create_3D_cycloidal_gear(X, Y, extrusion_depth) -- Create cycloidal gear
    local center_hole = translate(0, 0, extrusion_depth / 2) * cylinder(gear_hole_radius, extrusion_depth) -- Create gear hole
    local final_gear = difference(cycloidal_gear, center_hole) -- Final gear shape
    
    local base_plate_radius = R + 10 -- Base plate radius
    local base_plate = create_base_plate(base_plate_radius, base_plate_thickness, central_shaft_radius) -- Create base plate with central hole
    
    local pin_positions = calculate_pin_positions(R, da, N) -- Calculate pin positions
    local pins = create_pins(pin_positions, pin_radius, pin_height) -- Create pins
    
    local eccentric_cam = create_eccentric_cam(eccentric_cam_radius, input_shaft_radius, base_plate_thickness, extrusion_depth, eccentric_cam_radius - input_shaft_radius) -- Create eccentric cam and input shaft
    
    local eccentric_cam_rotation = ui_numberBox("Rotation", 0) -- Eccentric cam rotation input
    local gear_translation_x = da * math.cos(math.rad(eccentric_cam_rotation * 10)) -- Gear translation in x
    local gear_translation_y = da * math.sin(math.rad(eccentric_cam_rotation * 10)) -- Gear translation in y
    local gear_rotation = -eccentric_cam_rotation * 10 / Z -- Gear rotation
    
    emit(base_plate, 1) -- Emit base plate with central hole
    emit(translate(0, 0, base_plate_thickness / 2) * pins, 2) -- Emit pins positioned correctly
    emit(eccentric_cam, 3) -- Emit eccentric cam positioned correctly
    emit(translate(gear_translation_x, gear_translation_y, base_plate_thickness / 2) * rotate(0, 0, gear_rotation) * final_gear, 4) -- Emit cycloidal gear with translation and rotation applied
end

-- Call the main function to generate components
generate_components()