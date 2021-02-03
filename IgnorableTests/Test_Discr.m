function y = Test_Discr(x)

syms b d1 d2 d3 d4 d5 d6 d7 d8 m
sym beta 
sym eta 
sym tau 
sym lambda 
sym k 
sym p
sym u_va 
sym u_1 
sym u_2 
sym u_p
sym sigma_1 
sym sigma_2
sym gamma_1 
sym gamma_2 
sym gamma_3
sym rho_1 
sym rho_2
syms lambda_1 lambda_2 lambda_3 lambda_4 lambda_5 lambda_6 lambda_7 lambda_8

syms S E Ia Q I1 I2 R V
syms alpha_1 delta_1 delta_2 delta_3 delta_4

S = x(1); 
E = x(2);
Ia = x(3);
Q = x(4);
I1 = x(5);
I2 = x(6);
R = x(7);
V= x(8);



y(1)=(b - (+d1 + beta * Ia * (1 - u_p) + u_va) * S + eta * R);
y(2)=(beta * Ia * (1 - u_p) * S - (d2 + k) * E);
y(3)=(-(d3 + lambda * tau + gamma_1) * Ia + k * E);
y(4)=(-(d4 + gamma_2 + sigma_1) * Q + p * lambda * tau * Ia);
y(5)=(-(d5 + gamma_3 + rho_1 * u_1 + sigma_2 * (1 - u_1)) * I1 + sigma_1 * Q + (1 - p) * lambda * tau * Ia);
y(6)=(-(d6 + m + rho_2 * u_2) * I2 + sigma_2 * (1 - u_1) * I1);
y(7)=(-(eta + d7) * R + gamma_1 * Ia + gamma_2 * Q + (gamma_3 + rho_1 * u_1) * I1 + rho_2 * u_2 * I2);
y(8)=(-d8 * V + u_va * S);

end
