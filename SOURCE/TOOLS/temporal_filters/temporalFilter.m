% MIT License
% 
% Copyright (c) 2017 The Scientific Computing and Imaging Institute
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.



function filteredPotvals = temporalFilter(potvals)

%%%% filter Parameters
A = 1;
B = [0.0277777777777778	0.0555555555555556	0.0833333333333333	0.111111111111111	0.138888888888889	0.166666666666667	0.138888888888889	0.111111111111111	0.0833333333333333	0.0555555555555556	0.0277777777777778];


%%%% do the filtering
D = potvals';
%Zi = ones(max(length(A),length(B))-1,1)*D(1,:);
D = filter(B,A,D);
D(  1: (max(length(A),length(B))-1)   , :) = ones( max(length(A),length(B))-1  ,1 )  *  D( max(length(A),length(B)) ,:);
filteredPotvals = D'; 
