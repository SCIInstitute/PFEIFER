function test

error('a')

load('Case2_PacingtoVTtoVF.mat')

potvals = Signal.Ve;

temp_filtered_potvals = temporal_filter(potvals);

Signal.temp_filtered_Ve = temp_filtered_potvals;

filename = '/Users/anton/Documents/temp_filtered_Case2_PacingtoVTtoVF.mat';

save(filename,'Signal','Geo','-v6')