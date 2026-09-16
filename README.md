# ResQTwin: Disaster Area Digital Twin (PS7)

ResQTwin is a MATLAB, Simscape, and Stateflow digital twin prototype that physically simulates how rising pore water pressure inside soil affects slope stability, uses AI to forecast impending slope failure, and dynamically manages road safety status.

---

## 🛠 Prerequisites & Toolboxes

Tested on **MATLAB R2024b / R2025a**. Ensure the following toolboxes are installed:
- MATLAB & Simulink
- Simscape
- Simscape Multibody
- Simscape Fluids
- Deep Learning Toolbox (LSTM Inference)
- Stateflow

---

## 📁 Repository Structure

```text
resqtwin/
├── data/                   # Simulation datasets, rainfall profiles & pre-trained AI models
├── scripts/                # AI training routines and setup scripts
├── simulation/             # Custom MATLAB packages and scenario generators
├── CONTRIBUTING.md         # Contribution guidelines
├── README.md               # Project documentation
├── ResQTwin_Plant.slx      # Core Hydro-Mechanical, AI & Stateflow Co-Simulation Model
└── resqtwin.prj            # MATLAB Project environment file
