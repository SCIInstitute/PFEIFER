%% Baseline Correction
% Determine if a baseline correction should be performed or not.
%
% *Notes on how the baseline correction is done:*
%
% A least squares linear Regression is performed using the the timeframes
% startpoint:(startpoint + baseline width) and endpoint:(endpoint+baseline
% width). For the actual baseline correction the resulting line is substracted from the values.
% As startpoint and endpoint either the first and the last time frame
% selected in the 'Slicing/Averaging' window (default for 'no user
% selection') or the start and endpoint selected by the user are taken.
%
% The baseline correction is done using the sigBaseLine function.