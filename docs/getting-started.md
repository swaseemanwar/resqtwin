# Getting Started

> **MVP scope:** `LOCKED` basic landslide digital twin

The first goal is to reproduce one complete, deterministic loop before adding
Simulink models, sensors, hardware, AI, terrain, or multiple routes.

## Prerequisites

- Git
- An installed and activated MATLAB R2026a (the documented release)
- Simulink for the later block-model stage; it is not required by the current
  MATLAB reference calculation

The current slice uses base MATLAB functionality. Do not add toolbox
dependencies until a feature requires them and the dependency is documented.

## Activate MATLAB first

Confirm that MATLAB can acquire a licence before creating project metadata:

```bash
matlab -batch "disp(version)"
```

If MATLAB reports `Licensing Error 1`, activate it with the licence supplied by
your institution or event organizer. For a default R2026a Linux installation,
the activation client can be started with:

```bash
/usr/local/MATLAB/R2026a/bin/glnxa64/MathWorksProductAuthorizer.sh
```

Sign in with the MathWorks account linked to the licence, or ask the licence
administrator for the correct network/offline configuration. Never place a
licence file or account credential in this repository. See MathWorks'
[activation instructions](https://www.mathworks.com/help/install/ug/activate-matlab-installation-manually.html).

If the Linux activation client reports `Unable to install license. Please try
again later.`, close it and retry only the Product Authorizer with elevated
permission:

```bash
sudo /usr/local/MATLAB/R2026a/bin/glnxa64/MathWorksProductAuthorizer
```

Do not run MATLAB itself with `sudo`. If elevated activation still fails,
contact MathWorks Install Support or reinstall MATLAB with consistent
installation ownership. See the
[MathWorks support answer for this exact error](https://www.mathworks.com/matlabcentral/answers/2032044-why-do-i-receive-the-error-unable-to-install-license-please-try-again-later-while-activating-ma).

## Recommended: create a MATLAB Project

Create the project from the existing repository rather than generating a new
folder hierarchy:

1. Open MATLAB and set the current folder to the repository root.
2. On the **Home** tab, select **New > Project**.
3. Name the project `ResQTwin` and select this existing repository folder.
4. In **Set Up Project**, set the repository root as the startup folder.
5. Add only these folders to the project search path:
   - `src/matlab`
   - `simulation/matlab`
   - `scripts/matlab`
6. Keep MATLAB's source-control-friendly multiple project definition files.
7. Remove ignored local/private files such as `AGENTS.md`, `.codex/`, local
   data, logs, and generated output from the project file list without deleting
   them from disk.
8. Review the generated project definition files before committing them.

When the project opens, MATLAB adds its project paths. When it closes, MATLAB
removes them. Do not add the entire repository recursively because test and
generated folders should not become production search paths.

MathWorks reference:
[Create Projects](https://www.mathworks.com/help/matlab/matlab_prog/create-projects.html).

## Lightweight setup without project metadata

From the repository root, run:

```matlab
run("scripts/setupProject.m")
```

This adds the same three development folders for the current MATLAB session.

## Verify the baseline

Run:

```matlab
run("scripts/setupProject.m")  % omit if the MATLAB Project configured the path
results = runProjectTests();
dashboard = runLandslideDashboard();
```

Expected behavior:

- all 23 tests pass;
- the dashboard opens paused at 0 seconds with `SAFE` and road `OPEN`;
- clicking **Play** progresses through `SAFE`, `WATCH`, and `UNSAFE`;
- the road closes at 44 seconds and stays closed through 60 seconds; and
- the plots reveal factor of safety and emulated pressure as playback advances.

Use **Pause**, **Reset**, or the timeline slider to rehearse specific moments.
The [dashboard guide](dashboard.md) describes the controls and checkpoints.
The MVP scope remains `LOCKED`.

If a function is not found, confirm the path configuration:

```matlab
which resqtwin.infiniteSlopeFactorOfSafety
which resqtwin.scenarios.basicLandslide
which runLandslideDashboard
```

## First implementation sequence

1. Make the existing deterministic tests pass on every team machine.
2. Confirm and document the expected transition times and outputs.
3. Verify the dashboard's displayed states at 0, 19, and 44 seconds.
4. Rehearse a repeatable 60-to-90-second demonstration.

A Simulink model remains a `PROPOSED` later addition.

The basic MVP is complete when a new team member can open the project, run the
tests, and reproduce the full observation-to-road-decision demonstration using
only the documented commands.
