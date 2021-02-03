close all
clc

step=1

t=1:step:10

S = zeros(1, length(t));
E = zeros(1, length(t));
Ia = zeros(1, length(t));
Q = zeros(1, length(t));
I1 = zeros(1, length(t));
I2 = zeros(1, length(t));
R = zeros(1, length(t));
V = zeros(1, length(t));
T = zeros(1, length(t));


S(i+1) = S(i)+step*(b-(+d1+beta*Ia(i)*(1-u_p)+u_va)*S(i)+eta*R(i)); 
E(i+1) = E(i)+step*(beta*Ia(i)*(1-u_p)*S(i)-(d2+k)*E(i)); 
Ia(i+1) = Ia(i)+step*(-(d3+lambda*tau+gamma_1)*Ia(i)+k*E(i));
Q(i+1) = Q(i)+step*(-(d4+gamma_2+sigma_1)*Q(i)+p*lambda*tau*Ia(i));
I1(i+1) = I1(i)+step*(-(d5+gamma_3+rho_1*u_1+sigma_2*(1-u_1))*I1(i)+sigma_1*Q(i)+(1-p)*lambda*tau*Ia(i));
I2(i+1) = I2(i)+step*(-(d6+m+rho_2*u_2)*I2(i)+sigma_2*(1-u_1)*I1(i)); 
R(i+1) = R(i)+step*(-(eta+d7)*R(i)+gamma_1*Ia(i)+gamma_2*Q(i)+(gamma_3+rho_1*u_1)*I1(i)+rho_2*u_2*I2(i));
V(i+1) = V(i)+step*(-d8*V(i)+u_va*S(i)); 

Sys=[S(i+1),E(i+1),Ia(i+1),Q(i+1),I1(i+1),I2(i+1),R(i+1),V(i+1)]


