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

OK = 1

return
