%% Create Integral Maps
% If this option is ON, matmap creates integral maps of the selected time
% series. In order to do so, fiducials (qrs wave or t wave or both) are
% needed. Thus 'Detect Fiducials' needs to be ON.
%
% The integral maps are created using the 'fidsIntAll' function, which
% calls the 'fidsIntegralMap' function to do the actuall integration.
%
% The integral maps are saved in the matmap output directory. The filenames
% of the integral maps are the 'normal' filenames with '-itg' added at the
% end.