function [newCpts] = geomLinkGeom(Tchannels,Tpts,Trefchannels,Trefpts,Cchannels,Cpts,Crefchannels,Crefpts,deltaz)
% FUNCTION [newCpts] = geomLinkGeom(Tchannels,Tpts,Trefchannels,Trefpts,Cchannels,Cpts,Crefchannels,Crefpts,deltaz)
%
% DESCRIPTION
% Function to link the cage geometry in that of the torso using an intermediate geometry
%
% INPUT
% Tchannels,Tpts       points and channels of the torso tank
% Trefchannels,Trefpts points measured of the torso in the reference frame
% Cchannels,Cpts       points and channels of the cage
% Crefchannels,Crefpts points measured of the cage in the reference frame
%
% OUTPUT
% newCpts              pointsof the cage in the torso coordinate system
%

Tpts4 = triVector4(Tpts);
Trefpts4 = triVector4(Trefpts);
Cpts4 = triVector4(Cpts);
Crefpts4 = triVector4(Crefpts);


FID = fopen('alignment.txt','w')

fprintf(FID,'*********************************************\n')
fprintf(FID,'computing transfer between cage and reference\n')
T = evalc('RT1 = geomAlignMatrix(Crefchannels,Crefpts4,Cchannels,Cpts4);')
fprintf(FID,T);

fprintf(FID,'*********************************************\n')
fprintf(FID,'computing transfer between reference and torso\n')
T= evalc('RT2 = geomAlignMatrix(Tchannels,Tpts4,Trefchannels,Trefpts4);')
fprintf(FID,T)

Tz = [1 0 0 0; 0 1 0 0; 0 0 1 -deltaz; 0 0 0 1];

RT = Tz*RT2*RT1;

fprintf(FID,'**********************************************\n')
fprintf(FID,'final matrix after two rotations and one z-translation:\n')
fprintf(FID,'ztranslation = %3.2f \n',-deltaz)
fprintf(FID,evalc('disp(RT)'))
fprintf(FID,'matrix for right multiplication:\n')
fprintf(FID,evalc('disp(RT'')'))

newCpts4 = RT*Cpts4;
newCpts = triVector3(newCpts4);


fclose(FID);

