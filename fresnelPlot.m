clearvars; close all; clc;

file = load('n528.mat');
dLaser1 = file.dLaserResult;

file = load('n10.mat');
dLaser2 = file.dLaserResult;

file = load('n80.mat');
dLaser3 = file.dLaserResult;

figure
plot(dLaser1(:, 30), 'LineWidth',3)
hold on
plot(dLaser2(:, 30),'r', 'LineWidth',3)
hold on
plot(dLaser3(:, 30),'g', 'LineWidth',3)
title('Revised computer model with Fresnel''s equations')
xlabel('distance along surface (\mum)')
ylabel('absorptivity (%)')
axis([50 550 0 1])
legend('n = 5.28', 'n = 10.08', 'n = 80')