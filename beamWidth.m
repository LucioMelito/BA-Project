clearvars; close all; clc;

iCreated = 3317; 
dXmax = 6; dYmax = 0.6; dZmax = 0; delta = 0.01;

file = load('beamPhotons.mat');
dPhoton = file.dPhoton;

iPhotonsPerUnit = 100; iXphotons = dXmax*iPhotonsPerUnit; iYphotons = dYmax*iPhotonsPerUnit;
iNumPhotons = iXphotons*iYphotons;
dPhotonSpacing = 1.0/iPhotonsPerUnit; colabs = 0.05; dLaserWidth = 1.335;
n = 10;

% Beam averaging
dJaggedResult = zeros(ceil(dLaserWidth*iPhotonsPerUnit), iYphotons);
for i = 1:iXphotons
    for j = 1:ceil(dLaserWidth*iPhotonsPerUnit)
        dJaggedResult(i, j) = dPhoton((i-1) + iXphotons*(j-1) + 1, 7);
    end
end

dLaserResult = zeros(iXphotons, ceil(dLaserWidth*iPhotonsPerUnit));
for i = 1:iXphotons
    
    j = floor(ceil(dLaserWidth*iPhotonsPerUnit)/2);
    dLaserResult(i, j) = 0;
    dNormWeight = 0;
    
    for k = 1:iXphotons
        for l = 1:ceil(dLaserWidth*iPhotonsPerUnit)
            weight = exp(-((k-i)*(dPhotonSpacing)/(sqrt(2)*dLaserWidth))^2 - ((l-j)*(dPhotonSpacing)/(sqrt(2)*dLaserWidth))^2);
            
            dNormWeight = dNormWeight + weight;
            dLaserResult(i, j) = dLaserResult(i, j) + dJaggedResult(k, l)*weight;
        end
    end
    
    dLaserResult(i, j) = dLaserResult(i, j) / dNormWeight;
end

mean(dLaserResult(50:550, j))
std(dLaserResult(50:550, j))
std(dLaserResult(50:550, j)) / mean(dLaserResult(50:550, j))
j

% Absorptvity plot
plot(dLaserResult(:, j))
title('Revised computer model with normal distribution')
xlabel('distance along surface (\mum)')
ylabel('absorptivity (%)')