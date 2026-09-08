# Source

This directory will contain reusable implementation code that is not primarily a model, test, script, or hardware firmware artifact.

Organize by stable responsibility rather than speculative technology. Add language- or tool-specific subdirectories only when real source files exist, and keep interfaces between components explicit and testable.

MATLAB, Python, ROS 2, and embedded integrations can coexist here later without changing the top-level repository contract.

## Current prototype

`matlab/+resqtwin/` contains the reviewable MATLAB reference calculations for
the `LOCKED` basic landslide MVP. It is kept independent from Simulink
so its expected behavior can be unit tested before a block model is added.
