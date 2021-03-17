function xdot=CovidSimulator(t,x)

global u
global b d1 d2 d3 d4 d5 d6 d7 d8 m
global beta
global eta
global tau lambda k p
global sigma_1 sigma_2
global gamma_1 gamma_2 gamma_3
global rho_1 rho_2
%global inputs

%     u_va = inputs(1);
%     u_1 = inputs(2);
%     u_2 = inputs(3);
%     u_p = inputs(4);

week=ceil(t/7);
month=ceil(t/31);
u_va=u(week,1);u_1=u(week,2);u_2=u(week,3);u_p=u(week,4);

S = x(1);
E = x(2);
Ia = x(3);
Q = x(4);
I1 = x(5);
I2 = x(6);
R = x(7);
V= x(8);
%uscita del sistema
xdot=zeros(8,1);

xdot(1)=(b - (+d1 + beta  * Ia * (1 - u_p) + u_va) * S + eta * R );
xdot(2)=(beta * Ia * (1 - u_p) * S - (d2 + k) * E);
xdot(3)=(-(d3 + lambda(month) * tau + gamma_1(month)) * Ia + k * E);
xdot(4)=(-(d4 + gamma_2(month) + sigma_1(month)) * Q + p(month) * lambda(month) * tau * Ia);
xdot(5)=(-(d5 + gamma_3(month) + rho_1(month) * u_1 + sigma_2(month) * (1 - u_1)) * I1 + sigma_1(month) * Q + (1 - p(month)) * lambda(month) * tau * Ia);
xdot(6)=(-(d6 + m + rho_2(month) * u_2) * I2 + sigma_2(month) * (1 - u_1) * I1);
xdot(7)=(-(eta + d7) * R + gamma_1(month) * Ia + gamma_2(month) * Q + (gamma_3(month) + rho_1(month) * u_1) * I1 + rho_2(month) * u_2 * I2);
xdot(8)= (-d8*V+u_va * S);

end