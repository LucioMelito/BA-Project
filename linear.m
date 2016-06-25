clearvars; close all; clc;

iTotal = 2000; iCreated = 0; iter = 1;
dPowder = zeros(iTotal, 4); dStabCheck = zeros(3);
dXmax = 6; dYmax = 0.6; dZmax = 0; delta = 0.01;
% dPowder(x, y , z, r)

% Powder placement algorithm
for i = 1:iTotal
    
    % Generate a new particle
    dPowder(i, 1) = rand*dXmax;
    dPowder(i, 2) = rand*dYmax;
    dPowder(i, 3) = dZmax + 0.22;
    dPowder(i, 4) = normrnd(0.075, 0.0125);
    %dPowder(i, 4) = rand()*0.05 + 0.05;
    
    % Particle placement cycle
    while true
        
        for j = 1:3 % New reference position
            dStabCheck(j) = dPowder(i, j);
        end
        
        % Drop the particle a bit
        dPowder(i, 3) = dPowder(i, 3) - delta;
        
        % Normal forcing
        for j = 1:iCreated
            iDistance = sqrt((dPowder(i, 1) - dPowder(j, 1))^2 + (dPowder(i, 2) - dPowder(j, 2))^2 + (dPowder(i, 3) - dPowder(j, 3))^2);
            fDistance = dPowder(i, 4) + dPowder(j, 4);
            
            if fDistance > iDistance % Only off the ones that are initially touching it
                dPowder(i, 1) = dPowder(i, 1) + (fDistance - iDistance)*(dPowder(i, 1) - dPowder(j, 1))/iDistance;
                dPowder(i, 2) = dPowder(i, 2) + (fDistance - iDistance)*(dPowder(i, 2) - dPowder(j, 2))/iDistance;
                dPowder(i, 3) = dPowder(i, 3) + (fDistance - iDistance)*(dPowder(i, 3) - dPowder(j, 3))/iDistance;
            end
        end
        
        % STABILITY CHECKING MECHANISM
        stability = 1;
        for j = 1:3
            diff = dPowder(i, j) - dStabCheck(j);
            if abs(diff) > 0.0000001 % Check if anything changed
                stability = 0;
                break
            end
        end
            
            if stability == 1
                break
            end
            % End of stability check
            
            % Test ground collision
            if dPowder(i, 3) - dPowder(i, 4) < 0
                dPowder(i, 3) = dPowder(i, 4); % Edge adjustment
                break
            end
    end
    
    % Done with this particle; create and continue
    iCreated = iCreated + 1;
    if dPowder(i, 3) > dZmax % Efficiency improvement for dropping
        dZmax = dPowder(i, 3);
    end    
end

% Particle trimming at top
maxHeight = 0.5;
for i = 1:iCreated
    if dPowder(i, 3) > maxHeight
        dPowder(i, 4) = 0;
    end
end

x = dPowder(:, 1);
y = dPowder(:, 2);
z = dPowder(:, 3);
r = dPowder(:, 4);

bubbleplot3(x, y, z, r, [],[],[],[],'Tag','Powder Bed')

% RAY TRACING

iPhotonsPerUnit = 100; iXphotons = dXmax*iPhotonsPerUnit; iYphotons = dYmax*iPhotonsPerUnit;
iNumPhotons = iXphotons*iYphotons;
dPhoton = zeros(iNumPhotons, 9); dPhotonSpacing = 1.0/iPhotonsPerUnit; colabs = 0.05; dLaserWidth = 0.30;

% Initialise photons
for i = 1:iNumPhotons
    dPhoton(i, 1) = dPhotonSpacing * mod(i, iXphotons);
    dPhoton(i, 2) = dPhotonSpacing * floor(i/iXphotons);
    dPhoton(i, 3) = 0.6;
    dPhoton(i, 4) = 0;
    dPhoton(i, 5) = 0;
    dPhoton(i, 6) = -2 * delta;
    dPhoton(i, 7) = 0;
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
                vperpx = (dPhoton(i, 4)*dx + dPhoton(i, 5)*dy + dPhoton(i, 6)*dz) * dx / (dx^2 + dy^2 + dz^2);
                vperpy = (dPhoton(i, 4)*dx + dPhoton(i, 5)*dy + dPhoton(i, 6)*dz) * dy / (dx^2 + dy^2 + dz^2);
                vperpz = (dPhoton(i, 4)*dx + dPhoton(i, 5)*dy + dPhoton(i, 6)*dz) * dz / (dx^2 + dy^2 + dz^2);
                
                vparx = dPhoton(i, 4) - vperpx;
                vpary = dPhoton(i, 5) - vperpy;
                vparz = dPhoton(i, 6) - vperpz;
                
                dPhoton(i, 4) = -vperpx + vparx;
                dPhoton(i, 5) = -vperpy + vpary;
                dPhoton(i, 6) = -vperpz + vparz;
                
                dPhoton(i, 7) = dPhoton(i, 7) + 1;
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
    dPhoton(i, 7) = 1 - (1 - colabs)^dPhoton(i, 7);
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
axis([50 550 0 0.4])