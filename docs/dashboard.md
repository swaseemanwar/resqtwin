# Landslide dashboard

The dashboard implements the status display within the `LOCKED` basic MVP:
one homogeneous slope, one exposed road segment, and emulated pore-water
pressure. It presents the existing MATLAB scenario's observations and decisions.

## Open the dashboard

In MATLAB R2026a, set the repository as the Current Folder and run:

```matlab
run("scripts/setupProject.m");
dashboard = runLandslideDashboard();
```

The window opens at 0 seconds with road **OPEN** and slope **SAFE**. The top
cards show road access, slope state, factor of safety, and pore-water pressure.
The plots show only observations up to the selected simulation time.

The display identifies its data as simulated. Soil values and thresholds are
illustrative; this prototype is for demonstrations, not operational road-safety
decisions.

## Playback controls

| Control | Behavior |
| --- | --- |
| Play | Advances from the current observation, approximately one simulation second per real second. |
| Pause | Holds the current observation and plotted history. |
| Reset | Stops playback and restores the initial observation and plots. |
| Timeline slider | Pauses playback and selects the nearest whole simulation second. |
| Replay | Appears at 60 seconds and starts again from 0 seconds. |
| Close window | Stops playback and releases the dashboard's timer. |

Playback uses a MATLAB timer. If MATLAB is busy, replay can take longer than
60 real seconds; the displayed time always refers to the simulated scenario.
MATLAB documents this scheduling behavior in the
[timer reference](https://www.mathworks.com/help/matlab/ref/timer.html).

## Demonstration checkpoints

| Simulation time | Slope state | Road status |
| --- | --- | --- |
| 0 s | SAFE | OPEN |
| 19 s | WATCH | OPEN |
| 44 s | UNSAFE | CLOSED |
| 60 s | UNSAFE | CLOSED; playback complete |

For a quick rehearsal, move the slider or select a checkpoint from the Command
Window:

```matlab
dashboard.seek(19);
dashboard.seek(44);
dashboard.reset();
```

`dashboard.play()` and `dashboard.pause()` provide the same controls as the
buttons. `delete(dashboard)` closes the window and releases its timer.

## Verification

```matlab
results = runProjectTests();
```

Expect 23 passing tests. Dashboard tests create hidden figures and exercise
the same callbacks used by its buttons and slider, including real timer
advancement. They verify displayed decisions and history, pause/resume, reset,
completion/replay, invalid time selection, independent windows, and cleanup.
