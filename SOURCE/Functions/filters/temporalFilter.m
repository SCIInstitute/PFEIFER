function filteredPotvals = temporalFilter(potvals)


%%%% filter Parameters
A = 1;
B = [0.03266412226059 0.06320942361376 0.09378788647083 0.10617422096837 0.09378788647083 0.06320942361376 0.03266412226059];



D = potvals';
%Zi = ones(max(length(A),length(B))-1,1)*D(1,:);
D = filter(B,A,D);
D(  1: (max(length(A),length(B))-1)   , :) = ones( max(length(A),length(B))-1  ,1 )  *  D( max(length(A),length(B)) ,:);
filteredPotvals = D'; 

