n1 = 5.28;
n2 = 10.08;
n3 = 80;
reflectance1 = zeros(157);
reflectance2 = zeros(157);
reflectance3 = zeros(157);
theta = zeros(157);
i = 1;
for x = 0:0.01:pi/2
    theta(i) = x;
    reflectance1(i) = (((n1^2*cos(x) - sqrt(n1^2 - sin(x)^2))/(n1^2*cos(x) + sqrt(n1^2 - sin(x)^2)))^2 + ((cos(x) - sqrt(n1^2 - sin(x)^2))/(cos(x) + sqrt(n1^2 - sin(x)^2)))^2)/2;
    i = i+1;
end

i = 1;
for x = 0:0.01:pi/2
    theta(i) = x;
    reflectance2(i) = (((n2^2*cos(x) - sqrt(n2^2 - sin(x)^2))/(n2^2*cos(x) + sqrt(n2^2 - sin(x)^2)))^2 + ((cos(x) - sqrt(n2^2 - sin(x)^2))/(cos(x) + sqrt(n2^2 - sin(x)^2)))^2)/2;
    i = i+1;
end

i = 1;
for x = 0:0.01:pi/2
    theta(i) = x;
    reflectance3(i) = (((n3^2*cos(x) - sqrt(n3^2 - sin(x)^2))/(n3^2*cos(x) + sqrt(n3^2 - sin(x)^2)))^2 + ((cos(x) - sqrt(n3^2 - sin(x)^2))/(cos(x) + sqrt(n3^2 - sin(x)^2)))^2)/2;
    i = i+1;
end

figure
plot(theta(:, 1), reflectance1(:, 1),theta(:, 1), reflectance2(:, 1), 'r', 'LineWidth',3)
hold on
plot(theta(:, 1), reflectance3(:, 1), 'g', 'LineWidth',3)
xlabel('incident angle (radians)')
ylabel('reflectivity')
axis([0 1.6 0.3 1])
legend('n = 5.28', 'n = 10.08', 'n = 80')
