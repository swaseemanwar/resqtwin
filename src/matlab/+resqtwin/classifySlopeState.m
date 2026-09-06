function [state, routeOpen] = classifySlopeState( ...
        factorOfSafety, watchThreshold)
%CLASSIFYSLOPESTATE Map factor of safety to an illustrative decision state.
%   [STATE, ROUTEOPEN] = resqtwin.classifySlopeState(FS) uses a default
%   watch threshold of 1.3 and an instability threshold of 1.0.
%   FS >= 1.3 is SAFE; 1 <= FS < 1.3 is WATCH; FS < 1 is UNSAFE.
%   The road is open in SAFE and WATCH. Outputs preserve the shape of FS.
%   A second input changes the watch threshold, which must be greater than 1.

if nargin < 2
    watchThreshold = 1.3;
end

validateattributes(factorOfSafety, {'numeric'}, ...
    {'real', 'finite', 'nonnegative'}, mfilename, 'factorOfSafety');
validateattributes(watchThreshold, {'numeric'}, ...
    {'real', 'finite', 'scalar', '>', 1}, ...
    mfilename, 'watchThreshold');

state = strings(size(factorOfSafety));
state(factorOfSafety >= watchThreshold) = "SAFE";
state(factorOfSafety >= 1 & factorOfSafety < watchThreshold) = "WATCH";
state(factorOfSafety < 1) = "UNSAFE";

routeOpen = factorOfSafety >= 1;
end
