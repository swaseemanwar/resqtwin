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
- **14 automated MATLAB tests** for the calculations, rules, scenario, and demo.

The calculation loop and basic plotting demo are available. A presentation-ready
slope-state and road-status display is still to be added.

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

Tested with **MATLAB R2026a**. Simulink is not required to run the current code.

Open the `resqtwin` repository as MATLAB's **Current Folder**, then run:

```matlab
run("scripts/setupProject.m");
observations = runBasicLandslideDemo();
disp(observations);
```

The output table contains pressure, factor of safety, slope state, and road
status for each second from 0 to 60. `RouteOpen` is `true` when the road is open.
In this example, the slope enters WATCH at 19 seconds and the road closes at
44 seconds. Use `runBasicLandslideDemo(false)` to skip the plot.

To run the tests:

```matlab
results = runProjectTests();
```

Expected result: **14 passing tests**. See [Getting Started](docs/getting-started.md)
for setup details and MATLAB Project instructions.

## Main files

| File or folder | Purpose |
| --- | --- |
| [infiniteSlopeFactorOfSafety.m](src/matlab/+resqtwin/infiniteSlopeFactorOfSafety.m) | Calculates slope stability. |
| [classifySlopeState.m](src/matlab/+resqtwin/classifySlopeState.m) | Converts factor of safety into slope and road status. |
| [basicLandslide.m](simulation/matlab/+resqtwin/+scenarios/basicLandslide.m) | Runs the 60-second pressure scenario. |
| [scripts/matlab/](scripts/matlab/) | Runs the tests and plotting demo after setup. |
| [tests/matlab/](tests/matlab/) | Checks the calculations, thresholds, and scenario. |

## Next steps

1. Add a clear slope-state and road-status display.
2. Rehearse the complete observation-to-road-decision demonstration.

A Simulink model, physical sensors, and AI forecasting remain **PROPOSED**
later additions. Decisions become **LOCKED** when explicitly agreed; replaced
decisions are marked **SUPERSEDED**.

Keep commits small and focused. See [CONTRIBUTING.md](CONTRIBUTING.md) for the
branch, pull request, and repository rules. Shared requirements and decisions
belong under [docs/](docs/).
