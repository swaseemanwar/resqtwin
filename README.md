# ResQTwin

ResQTwin is a MATLAB prototype that shows how rising water pressure in soil
affects slope stability and whether a nearby road stays open.

Built for **MATRIX 2026**, **AI in Disaster Management**, PS7:
**“Disaster Area Digital Twin.”**

## Current status

The following features are implemented and merged into `main`:

- Factor-of-safety calculation for a slope.
- **SAFE / WATCH / UNSAFE** classification and **OPEN / CLOSED** road status.
- A 60-second scenario with simulated water pressure.
- **12 automated MATLAB tests** for the calculations, rules, and scenario.

The calculation loop works. The visual demo and status display are still to
be added.

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
addpath("src/matlab", "simulation/matlab");
observations = resqtwin.scenarios.basicLandslide();
disp(observations);
```

The output table contains pressure, factor of safety, slope state, and road
status for each second from 0 to 60. `RouteOpen` is `true` when the road is open.
In this example, the slope enters WATCH at 19 seconds and the road closes at
44 seconds.

To run the tests:

```matlab
results = runtests("tests/matlab");
assertSuccess(results);
```

Expected result: **12 passing tests**.

## Main files

| File or folder | Purpose |
| --- | --- |
| [infiniteSlopeFactorOfSafety.m](src/matlab/+resqtwin/infiniteSlopeFactorOfSafety.m) | Calculates slope stability. |
| [classifySlopeState.m](src/matlab/+resqtwin/classifySlopeState.m) | Converts factor of safety into slope and road status. |
| [basicLandslide.m](simulation/matlab/+resqtwin/+scenarios/basicLandslide.m) | Runs the 60-second pressure scenario. |
| [tests/matlab/](tests/matlab/) | Checks the calculations, thresholds, and scenario. |

## Next steps

1. Add a simple setup script and demo command.
2. Add a clear slope-state and road-status display.

A Simulink model, physical sensors, and AI forecasting remain **PROPOSED**
later additions. Decisions become **LOCKED** when explicitly agreed; replaced
decisions are marked **SUPERSEDED**.

Keep commits small and focused. See [CONTRIBUTING.md](CONTRIBUTING.md) for the
branch, pull request, and repository rules. Shared requirements and decisions
belong under [docs/](docs/).
