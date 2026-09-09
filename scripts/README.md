# Scripts

Place reproducible automation here, including setup checks, validation utilities, data preparation, and demonstration helpers.

Scripts should:

- fail clearly and avoid hidden machine state;
- accept documented inputs instead of embedding secrets or absolute paths;
- be safe to rerun;
- print actionable diagnostics; and
- have a focused test or dry-run path when practical.

Do not add package installers or large orchestration frameworks until the project actually requires them.

## Current entry points

- `setupProject.m` adds the current source, simulation, and MATLAB script
  folders to the MATLAB path.
- `matlab/runProjectTests.m` runs the deterministic MATLAB tests.
- `matlab/runBasicLandslideDemo.m` runs and plots the `LOCKED` basic
  landslide scenario.
- `matlab/runLandslideDashboard.m` opens the interactive scenario dashboard
  with Play/Pause/Reset controls and a timeline slider.
