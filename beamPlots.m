clearvars; close all; clc;

file = load('beam1.mat');
dLaser1 = file.dLaserResult;

file = load('beam2.mat');
dLaser2 = file.dLaserResult;

file = load('beam3.mat');
dLaser3 = file.dLaserResult;

file = load('beam4.mat');
dLaser4 = file.dLaserResult;

file = load('beam5.mat');
dLaser5 = file.dLaserResult;

%{
figure
plot(dLaser1(:, 19), 'LineWidth',2)
hold on
plot(dLaser2(:, 29),'r', 'LineWidth',2)
hold on
plot(dLaser3(:, 45),'g', 'LineWidth',2)
hold on
plot(dLaser4(:, 58),'m', 'LineWidth',2)
hold on
plot(dLaser5(:, 67),'k', 'LineWidth',2)
title('Absorptivity resulting from different beam widths')
xlabel('distance along surface (\mum)')
ylabel('absorptivity (%)')
axis([50 550 0.63 0.73])
legend('75 \mum', '118 \mum', '181 \mum', '232 \mum', '267 \mum')
%}

figure
scatter(75, std(dLaser1(50:550, 19)) / mean(dLaser1(50:550, 19)))
hold on
scatter(118, std(dLaser2(50:550, 29)) / mean(dLaser2(50:550, 29)))
hold on
scatter(181, std(dLaser3(50:550, 45)) / mean(dLaser3(50:550, 45)))
hold on
scatter(232, std(dLaser4(50:550, 58)) / mean(dLaser4(50:550, 58)))
hold on
scatter(267, std(dLaser5(50:550, 67)) / mean(dLaser5(50:550, 67)))
axis([50 300 2*10^(-3) 14*10^(-3)])
xlabel('beam width (\mum)')
ylabel('relative standard deviation (%)')