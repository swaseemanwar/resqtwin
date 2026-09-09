# Basic Landslide Twin MVP

> **Status:** `LOCKED` on 2026-09-03
>
> This document defines the first implementation target. The lock covers the
> landslide hazard, MVP user and decision, one-slope/one-road boundary, and the
> end-to-end twin loop. It does not lock hardware, calibration, advanced
> architecture, or post-MVP features.

## Purpose

Build the smallest end-to-end model that can demonstrate this loop:

```text
emulated observation -> slope-state estimate -> decision state -> route status
```

The counterpart is one shallow, homogeneous slope and one road segment at its
base. The user is an incident commander deciding whether that road should
remain open.

## First vertical slice

The first slice accepts an emulated pore-water-pressure observation and uses a
static infinite-slope Mohr-Coulomb calculation to estimate factor of safety.
It classifies the result as:

- `SAFE`: factor of safety is at least 1.3;
- `WATCH`: factor of safety is at least 1.0 but below 1.3; or
- `UNSAFE`: factor of safety is below 1.0.

Only `UNSAFE` closes the single exposed road in this prototype. These thresholds
are illustrative and are not operational warning criteria.

For slope angle `beta`, vertical soil depth `z`, soil unit weight `gamma`,
effective cohesion `c`, effective friction angle `phi`, and pore-water pressure
`u`, the reference calculation is:

```text
FS = [c + (gamma*z*cos(beta)^2 - u)*tan(phi)]
     / [gamma*z*sin(beta)*cos(beta)]
```

The formulation follows the simple infinite-slope model family used by the USGS
TRIGRS rainfall-infiltration and slope-stability program:
<https://pubs.usgs.gov/of/2008/1159/>.

## Demonstration scenario

The deterministic scenario lasts 60 seconds. Pore-water pressure is held at
zero, ramped from 0 to 12 kPa, and then held at 12 kPa. All soil values are
illustrative:

| Parameter | Value |
| --- | ---: |
| Slope angle | 30 deg |
| Vertical soil depth | 2 m |
| Soil unit weight | 18 kN/m^3 |
| Effective cohesion | 5 kPa |
| Effective friction angle | 32 deg |

The run must begin in `SAFE`, pass through `WATCH`, end in `UNSAFE`, and close
the exposed road.

## Explicit limitations

- This is an initiation/stability demonstration, not a runout or impact model.
- The slope is static, homogeneous, and represented by one calculation point.
- Pore pressure is directly emulated; rainfall infiltration is not modeled yet.
- Parameters have not been calibrated against a physical rig or field data.
- The output must not be used for real evacuation or public-safety decisions.

## Deferred ideas

The following remain `PROPOSED LATER` and are outside the first vertical slice:

- a calibrated rainfall-to-pore-pressure model;
- live moisture, displacement, and IMU observations;
- sensor staleness, bias, dropout, and uncertainty handling;
- FFT or spectral features from vibration measurements, with controlled
  calibration before relating any feature to a soil parameter;
- terrain-aware runout and impact-zone estimation;
- a rigid-block 6-DOF approximation only if experiments support the coherent
  block assumption; and
- a route graph with multiple evacuation alternatives.

Impact output should be expressed as a validated uncertainty envelope, not an
exact impact point.

## Acceptance checks

1. The friction-only neutral case (`beta = phi`, `c = 0`, `u = 0`) returns
   factor of safety 1 within numerical tolerance.
2. Increasing pore pressure monotonically reduces factor of safety.
3. The demonstration traverses `SAFE`, `WATCH`, and `UNSAFE` in that order.
4. The road is open at the start and closed at the end.
5. Invalid or physically unsupported inputs fail explicitly.
