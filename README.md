# ResQTwin

ResQTwin is a MATLAB and Simscape digital twin prototype that physically simulates how rising pore water pressure inside soil affects slope stability and road safety.

Built for **AI in Disaster Management**, PS7: **“Disaster Area Digital Twin.”**

## Current Status: Phase 1 (Hydro-Mechanical Co-Simulation)

A fully physics-based **Hydro-Mechanical Co-Simulation** plant model. 

The following physical features are now implemented:
*   **Simscape Multibody 3D Environment:** A stationary bedrock foundation (`Static_Bedrock`) and a 3D sliding soil mass (`Sliding_Soil_Mass`) connected via a prismatic joint.
*   **Simscape Fluids Hydraulic Circuit:** Simulates dynamic pore water pressure ($u$) buildup inside the soil matrix using an Isothermal Liquid domain.
*   **Mohr-Coulomb Geotechnical Solver:** Dynamically calculates shear resistance using the real-world formula $\tau = c + (\sigma - u) \tan\phi$. As fluid pressure ($u$) builds, effective stress drops to zero and the 3D block physically ruptures and slides.
*   **Dynamic Scenario Driver:** A Signal Editor feeds a customized 60-second rainfall pressure surge scenario directly into the physical fluid pump.

## How to Run & Verify the New Model

To run this model, **Simulink**, **Simscape**, **Simscape Multibody**, and **Simscape Fluids** toolboxes installed.

1. **Initialize the Environment:** Open the `resqtwin` repository folder in MATLAB. Double-click the MATLAB Project file (`.prj`) to automatically load all paths and variables, or manually run `run("scripts/setupProject.m")` in the command window.
2. **Open the Plant Model:** Open the new `ResQTwin_Plant.slx` file from the Current Folder.
3. **Run the Simulation:** Ensure the simulation Stop Time is set to `60` seconds, then click the green **Run** button.
4. **View the Results:**
   *   **Mechanics Explorer:** Open the 3D visualization window. You will see the `Sliding_Soil_Mass` physically slide down the bedrock incline as water pressure surges.
   *   **Pressure Scope:** Double-click the `Scope` block connected to the sensor to monitor the live pore water pressure ($u$) trace over the 60-second run.

## Updated Main Files

| File or folder | Purpose |
| --- | --- |
| `ResQTwin_Plant.slx` | **[NEW]** The core Simscape Multibody and Simscape Fluids co-simulation plant model. |
| `Rainfall_Pressure_Scenario.mat` | **[NEW]** The 60-second Signal Editor dataset driving the dynamic fluid pressure pump. |
| `infiniteSlopeFactorOfSafety.m` | *(Superseded by Simscape solver)* Calculated basic slope stability. |
| `classifySlopeState.m` | *(Pending AI update)* Converts factor of safety into SAFE/WATCH/UNSAFE road status. |
| `scripts/matlab/` | Launches legacy dashboard, tests, and static demo after setup. |

## Next Steps

1. **Phase 2: AI Predictive Forecasting:** We will route the live shear stress ($\tau$) and normal stress ($\sigma$) outputs from Simscape into the Deep Learning / Predictive Maintenance Toolbox to train an LSTM model that predicts the Factor of Safety 15 to 30 minutes ahead.
2. **Phase 3: Stateflow Control Logic:** Implement a Stateflow chart to manage automated SAFE/WATCH/UNSAFE state transitions based on the AI forecast.
3. **Phase 4: Hardware-in-the-Loop (HIL):** Replace the simulated Signal Editor with live STM32/ESP32 sensor telemetry. We will use a Multi-Criteria Network Digital Twin (MNDT) architecture to dynamically switch between Wi-Fi, LoRa, and 5G to maximize the Packet Delivery Ratio (PDR) during severe storms.
4. **Final Packaging:** Ensure the `.prj` file passes the MATLAB Dependency Analyzer so it runs flawlessly on the judges' machines.
