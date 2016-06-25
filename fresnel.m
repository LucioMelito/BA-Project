clearvars; close all; clc;

iCreated = 3317; 
dXmax = 6; dYmax = 3; dZmax = 0; delta = 0.01;

file = load('bed.mat');
dPowder = file.dPowder;

x = dPowder(:, 1);
y = dPowder(:, 2);
z = dPowder(:, 3);
r = dPowder(:, 4);

%bubbleplot3(x, y, z, r, [],[],[],[],'Tag','Powder Bed')

% RAY TRACING

iPhotonsPerUnit = 100; iXphotons = dXmax*iPhotonsPerUnit; iYphotons = dYmax*iPhotonsPerUnit;
iNumPhotons = iXphotons*iYphotons;
dPhoton = zeros(iNumPhotons, 9); dPhotonSpacing = 1.0/iPhotonsPerUnit; colabs = 0.05; dLaserWidth = 0.375;
n = 10;

% Initialise photons
for i = 1:iNumPhotons
    dPhoton(i, 1) = dPhotonSpacing * mod(i, iXphotons);
    dPhoton(i, 2) = dPhotonSpacing * floor(i/iXphotons);
    dPhoton(i, 3) = 0.6;
    dPhoton(i, 4) = 0;
    dPhoton(i, 5) = 0;
    dPhoton(i, 6) = -2 * delta;
    dPhoton(i, 7) = 1;
    dPhoton(i, 8) = dPhoton(i, 1);
    dPhoton(i, 9) = dPhoton(i, 2);
end

% Photons loop
for i = 1:iNumPhotons
    
    % Main ray-trace loop
    while true
        
        % Collision test -> normal ejection
        for j = 1:iCreated
            
            dx = dPhoton(i, 1) - dPowder(j, 1); dy = dPhoton(i, 2) - dPowder(j, 2); dz = dPhoton(i, 3) - dPowder(j, 3);
            if dx^2 + dy^2 + dz^2 < dPowder(j, 4)^2
                
                % Reflectance calculation
                
                direction = [-dPhoton(i,4) -dPhoton(i, 5) -dPhoton(i, 6)];
                normal = [(dPhoton(i, 1) - dPowder(j, 1)) (dPhoton(i, 2) - dPowder(j, 2)) (dPhoton(i, 3) - dPowder(j, 3))];
                angle = atan2(norm(cross(direction,normal)),dot(direction,normal));
                
                reflection = (((n^2*cos(angle) - sqrt(n^2 - sin(angle)^2))/(n^2*cos(angle) + sqrt(n^2 - sin(angle)^2)))^2 + ((cos(angle) - sqrt(n^2 - sin(angle)^2))/(cos(angle) + sqrt(n^2 - sin(angle)^2)))^2)/2;
                
                vperpx = (dPhoton(i, 4)*dx + dPhoton(i, 5)*dy + dPhoton(i, 6)*dz) * dx / (dx^2 + dy^2 + dz^2);
                vperpy = (dPhoton(i, 4)*dx + dPhoton(i, 5)*dy + dPhoton(i, 6)*dz) * dy / (dx^2 + dy^2 + dz^2);
                vperpz = (dPhoton(i, 4)*dx + dPhoton(i, 5)*dy + dPhoton(i, 6)*dz) * dz / (dx^2 + dy^2 + dz^2);
                
                vparx = dPhoton(i, 4) - vperpx;
                vpary = dPhoton(i, 5) - vperpy;
                vparz = dPhoton(i, 6) - vperpz;
                
                dPhoton(i, 4) = -vperpx + vparx;
                dPhoton(i, 5) = -vperpy + vpary;
                dPhoton(i, 6) = -vperpz + vparz;
                
                if reflection < 1 && reflection > 0
                    dPhoton(i, 7) = dPhoton(i, 7)*reflection;
                end
            end
        end
        
        % Move the photon along its path
        dPhoton(i, 1) = dPhoton(i, 1) + dPhoton(i, 4);
        dPhoton(i, 2) = dPhoton(i, 2) + dPhoton(i, 5);
        dPhoton(i, 3) = dPhoton(i, 3) + dPhoton(i, 6);
        
        % Test if photon outside boundaries
        if dPhoton(i, 1) > dXmax
            break
        end
        if dPhoton(i, 1) < 0
            break
        end
        if dPhoton(i, 2) > dYmax
            break
        end
        if dPhoton(i, 2) < 0
            break
        end
        if dPhoton(i, 3) > 0.65
            break
        end
        if dPhoton(i, 3) < 0
            break
        end
        
    end
    
    if mod(i, 1000) == 0
        i
    end
end

% Absorption
hits = dPhoton(:, 7);
for i = 1:iNumPhotons
    dPhoton(i, 7) = 1 - dPhoton(i, 7);
end

% Beam averaging
dJaggedResult = zeros(iXphotons, iYphotons);
for i = 1:iXphotons
    for j = 1:iYphotons
        dJaggedResult(i, j) = dPhoton((i-1) + iXphotons*(j-1) + 1, 7);
    end
end

dLaserResult = zeros(iXphotons, iYphotons);
for i = 1:iXphotons
    
    j = floor(iYphotons/2);
    dLaserResult(i, j) = 0;
    dNormWeight = 0;
    
    for k = 1:iXphotons
        for l = 1:iYphotons
            weight = exp(-((k-i)*(dPhotonSpacing)/(sqrt(2)*dLaserWidth))^2 - ((l-j)*(dPhotonSpacing)/(sqrt(2)*dLaserWidth))^2);
            
            dNormWeight = dNormWeight + weight;
            dLaserResult(i, j) = dLaserResult(i, j) + dJaggedResult(k, l)*weight;
        end
    end
    
    dLaserResult(i, j) = dLaserResult(i, j) / dNormWeight;
end

mean(dLaserResult(50:550, 30))
std(dLaserResult(50:550, 30))
std(dLaserResult(50:550, 30)) / mean(dLaserResult(50:550, 30))

% Absorptvity plot
plot(dLaserResult(:, 30))
title('Revised computer model with normal distribution')
xlabel('distance along surface (\mum)')
ylabel('absorptivity (%)')