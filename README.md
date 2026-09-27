# Parametric Cycloidal Gear Generator in Lua

This repository contains a suite of Lua scripts developed in IceSL to parametrically model and assemble a cycloidal gear system. It was developed as a case study for Cyber Physical Production Systems using Additive Manufacturing.

## Overview

The scripts allow for the flexible generation of a cycloidal drive assembly by calculating complex cycloidal curves and coordinates directly through code. The multi-functional script allows users to generate the entire assembly together or extract individual components for 3D printing.

The generated assembly consists of three main components:

* Base plate with roller pins.


* Cycloidal gear.


* Eccentric cam with an input shaft.



## Features and Customization

The model is highly parametric, allowing users to modify the following variables in the IceSL Tweak Box for real-time model updates:

* **Number of Teeth:** Defines the base geometry and scales the rotor radius (Default: 9)[cite: 16, 18].
* **Face Width:** Controls the 3D extrusion depth of the gear[cite: 16, 18].
* **Gear Hole Radius:** Adjusts the central cutout for the eccentric cam[cite: 16, 18].
* **Base Plate Thickness & Pin Height:** Controls the structural support and roller dimensions[cite: 16, 18].
* **Rotation:** Simulates the kinematic movement of the gear assembly to check alignment.



## Repository Structure

* `Final.lua`: The main script that calculates the cycloidal path, generates pin positions, and renders the complete assembly[cite: 19].
* `Cycloidal_Gear.lua`: Isolated script for computing the 2D cycloidal path via mathematical derivation and extruding it into a 3D gear[cite: 17].
* `Eccentric_pin.lua`: Generates the offset input shaft and eccentric cam[cite: 18].
* `Rollers_along_with_base_plate.lua`: Calculates the correct spacing for the rollers and generates the base plate[cite: 20].
* `Lua_Manual.pdf`: Comprehensive user manual explaining the math, interdependent parameters, and script functions.



## Usage and 3D Printing

1. Open the desired `.lua` file using IceSL or IceSL-forge.


2. Adjust the parameters in the Tweak Box to fit your mechanical requirements.


3. The scripts utilize the `emit()` function to isolate and export individual components as `.stl` files.


4. 3D print the components separately.


5. Fix the input shaft to the base plate hole, and attach the eccentric cam to the cycloidal gear hole to complete the physical assembly.




---

Have you considered recording a short screen-capture GIF of the gear rotating dynamically within the IceSL software to put at the very top of the README?
