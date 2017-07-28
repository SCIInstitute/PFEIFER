function Pos4 = triVector4(Pos3)
% function Pos4 = triVector4(Pos3)
%
% This function transforms a normal matrix containing the position in three
% coordinates into a opengl-style four vector matrix.
% The difference is that the last position is used as a scaling number
% The latter makes a translation a matrix multiplication as well
% Hence all transformations on 4-vector can be described as matrix multiplications
%
% INPUT 
% Pos3 - matrix with a three cartesian coordinates per column
%
% OUTPUT 
% Pos4 - matrix with four cartesian coordinates per column

% align data in case someone made a transposition of the matrix
if size(Pos3,1) ~= 3,
	if size(Pos3,2) == 3,
		Pos3 = Pos3';
	else
	  	error('Dimensions Pos3 don not fit\n');
	end
end 

% making it a four vector
Pos4 = [Pos3 ; ones(1,size(Pos3,2))];

return
