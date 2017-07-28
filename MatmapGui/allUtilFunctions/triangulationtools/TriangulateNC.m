function Tri = TriangulateNC(Pos,Vertex)

% function Boundary = SlicesToPos(Slices)
% This function converts data obtained from slices
% in a three dimensional image build out of triangles
% the routine uses a simple algorithm 
WB = WaitBar(0,'Generating model...');

% Here the triangulation starts

% Determine the number of slices
nSlices = size(Vertex,2);

% Generate a Position matrix and a cell matrix telling which vertices are at which position

nVertex = size(Pos,2);

% Generate Position Matrix

Vertex = SameDirection(Vertex,Pos);

% generate Triangulation matrix
Tri = zeros(3,2);

k = 1;
  
for q = 1:(nSlices-1),

% get two succeeding slices

H1 = Vertex{q};
H2 = Vertex{q+1};

I1 = 1; I2 = 1;

% Rotate H2 to match H1 best

P = Pos(:,H1(I1))*ones(1,size(H2,2))-Pos(:,H2);
 
L = sqrt(sum(P.*P));
R2 = find(L  == min(L));

if R2 > 1,
	H2 = [H2(R2:size(H2,2)) H2(1:(R2-1))]; 
end

% Make it circular

N1 = size(H1,2);
N2 = size(H2,2);

% One vertex has not to be circular
if N1 == 2, 
   H1 = Vertex{q}; N1 = 1;
end
if N2 == 2, 
   H2 = Vertex{q+1}; N2 = 1; 
end

% N1 and N2 are the number of vertices in one plane
% H1 and H2 contain the numbers

% Now start triangulating

while ~((I1 == N1) & (I2 == N2)),
	if ((I1 < N1) & (I2 < N2)),
		L1 = sqrt(sum((Pos(:,H1(I1+1))-Pos(:,H2(I2))).*(Pos(:,H1(I1+1))-Pos(:,H2(I2)))));
		L2 = sqrt(sum((Pos(:,H1(I1))-Pos(:,H2(I2+1))).*(Pos(:,H1(I1))-Pos(:,H2(I2+1)))));
		if L1 < L2,
			Tri(:,k) = [H1(I1) H1(I1+1) H2(I2)]';
 			k = k + 1;
 			I1 = I1 + 1;
		else
 			Tri(:,k) = [H1(I1) H2(I2+1) H2(I2)]';
 			k = k + 1;
 			I2 = I2 + 1;
		end;
	end;
	if (I2 == N2)
 		Tri(:,k) = [H1(I1) H1(I1+1) H2(I2)]';
 		k = k + 1;
 		I1 = I1 + 1;
	elseif (I1 == N1)
 		Tri(:,k) = [H1(I1) H2(I2+1) H2(I2)]';
 		k = k + 1;
 		I2 = I2 + 1;
	end;
end;
waitbar(q/(nSlices-1));
end;

close(WB);
% Make a final check

% CheckTriangulation(Tri,Pos);

Tri = [ Tri(2,:) ; Tri(1,:) ; Tri(3,:) ];

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Vertex = SameDirection(Vertex,Pos)

% This function turns the slices all in the same direction

nSlices = size(Vertex,2);
NVec = zeros(3,1);
for p = 1:nSlices,
   V = Vertex{p};
   % make it circular
   V = [V V(1)];
   n = size(V,2);
   % Check if there are enough points to define at least a direction
   if n > 3,
      if norm(NVec) == 0,
         % Define a positive direction
         NVec = cross(Pos(:,V(1))-Pos(:,V(2)),Pos(:,V(2))-Pos(:,V(3)));
      end
      % Surface is zero
      Surf = 0;
      for j = 1:(n-1)
         Surf = Surf + cross(Pos(:,V(j)),Pos(:,V(j+1)))'*NVec;
      end
      if Surf < 0,
         % reverse direction if total surface is smaller than zero
         V = Vertex{p}
         V = V(end:-1:1);
         Vertex{p} = V;
      end
   end
end % loop %

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function CheckTriangulation(Tri,Pos)

% This function checks if the triangulation went OK

n = size(Pos,2);
m = size(Tri,2);

if min(Tri(:)) < 1,
   error('Triangulation matrix has an index smaller than one');
end
if max(Tri(:)) > n, 
   error('Triangulation matrix refers to a non-existing point'); 
end

TestMatrix = zeros(n);

for p = 1:m,
   TestMatrix(Tri(1,p),Tri(2,p)) = TestMatrix(Tri(1,p),Tri(2,p))+ 1;
   TestMatrix(Tri(2,p),Tri(3,p)) = TestMatrix(Tri(2,p),Tri(3,p))+ 1;
	TestMatrix(Tri(3,p),Tri(1,p)) = TestMatrix(Tri(3,p),Tri(1,p))+ 1;
end

if max(TestMatrix(:)) > 1, 
   error('A triangle side is used more than one time'); 
end
if nnz(TestMatrix-TestMatrix') > 0, 
   error('Not every triangle side is connected correctly'); 
end

return

