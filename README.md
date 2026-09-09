# ResQTwin

ResQTwin is a MATLAB prototype that shows how rising water pressure in soil
affects slope stability and whether a nearby road stays open.

Built for **MATRIX 2026**, **AI in Disaster Management**, PS7:
**“Disaster Area Digital Twin.”**

## Current status

The following features are implemented:

- Factor-of-safety calculation for a slope.
- **SAFE / WATCH / UNSAFE** classification and **OPEN / CLOSED** road status.
- A 60-second scenario with simulated water pressure.
- Setup, test, and demo commands, including a pressure and factor-of-safety plot.
- An interactive dashboard with road and slope status, updating plots,
  Play/Pause/Reset controls, and a timeline slider.
- **23 automated MATLAB tests** for the calculations, scenario, demo, and dashboard.

The dashboard presents the observation-to-road-decision loop using the
deterministic scenario. It opens paused at 0 seconds, ready for playback.

## How it works

**LOCKED MVP:** one slope with uniform soil, at risk of a shallow landslide,
and one road segment. The intended user is an incident commander reviewing
the simulated road status.

```text
Water pressure -> Factor of safety -> Slope state -> Road status
```

Factor of safety (FS) compares the stresses resisting sliding with those
causing it. The current example uses these rules:

| Factor of safety | Slope state | Road status |
| --- | --- | --- |
| FS >= 1.3 | SAFE | OPEN |
| 1.0 <= FS < 1.3 | WATCH | OPEN |
| FS < 1.0 | UNSAFE | CLOSED |

This prototype uses example soil values and simulated pressure. It is not
validated for real road-safety decisions.

## Run in MATLAB

Use **MATLAB R2026a**. Simulink is not required to run the current code.

Open the `resqtwin` repository as MATLAB's **Current Folder**, then run:

```matlab
run("scripts/setupProject.m");
dashboard = runLandslideDashboard();
```

Click **Play** to reveal the scenario one second at a time. **Pause** holds the
current observation, **Reset** returns to 0 seconds, and the slider jumps to a
selected time. The slope enters WATCH at 19 seconds and the road closes at
44 seconds. At 60 seconds, playback stops and **Replay** starts again from zero.
See the [dashboard guide](docs/dashboard.md) for demonstration checkpoints.

For the full static plot and output table, use:

```matlab
observations = runBasicLandslideDemo();
disp(observations);
```

Use `runBasicLandslideDemo(false)` to skip the plot. `RouteOpen` in the output
table is `true` when the road is open.

To run the tests:

```matlab
results = runProjectTests();
```

Expected result: **23 passing tests**. See [Getting Started](docs/getting-started.md)
for setup details and MATLAB Project instructions.

## Main files

| File or folder | Purpose |
| --- | --- |
| [infiniteSlopeFactorOfSafety.m](src/matlab/+resqtwin/infiniteSlopeFactorOfSafety.m) | Calculates slope stability. |
| [classifySlopeState.m](src/matlab/+resqtwin/classifySlopeState.m) | Converts factor of safety into slope and road status. |
| [basicLandslide.m](simulation/matlab/+resqtwin/+scenarios/basicLandslide.m) | Runs the 60-second pressure scenario. |
| [LandslideDashboard.m](src/matlab/+resqtwin/+ui/LandslideDashboard.m) | Displays the current observation and manages playback. |
| [scripts/matlab/](scripts/matlab/) | Launches the dashboard, tests, and static demo after setup. |
| [tests/matlab/](tests/matlab/) | Checks the calculations, thresholds, and scenario. |

## Next steps

1. Rehearse the complete observation-to-road-decision demonstration.
2. Record team test results and demonstration evidence.

A Simulink model, physical sensors, and AI forecasting remain **PROPOSED**
later additions. Decisions become **LOCKED** when explicitly agreed; replaced
decisions are marked **SUPERSEDED**.

Keep commits small and focused. See [CONTRIBUTING.md](CONTRIBUTING.md) for the
branch, pull request, and repository rules. Shared requirements and decisions
belong under [docs/](docs/).
