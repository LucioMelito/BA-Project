clearvars; close all; clc;

iTotal = 5000; iCreated = 0; iter = 1;
dPowder = zeros(iTotal, 4); dStabCheck = zeros(3);
dXmax = 6; dYmax = 3.0; dZmax = 0; delta = 0.01;
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