# Simulation

Use this directory for synthetic scenarios and simulator-facing assets.

Start with minimal, deterministic scenarios that exercise the twin loop and expected failure modes. Record seeds, initial conditions, units, timing assumptions, and expected outcomes.

Gazebo, ROS 2 simulation packages, or other engines may be introduced later if the locked architecture benefits from them. Keep engine-specific structure out of the repository until that decision is made.

## Current prototype

`matlab/+resqtwin/+scenarios/basicLandslide.m` defines the deterministic input
and expected state progression for the `LOCKED` basic MVP. It uses
directly emulated pore-water pressure; it does not yet implement rainfall
infiltration or debris runout.
