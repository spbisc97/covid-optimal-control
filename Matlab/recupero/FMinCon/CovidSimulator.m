function xdot=CovidSimulator(t,x)
    global u
    global b d1 d2 d3 d4 d5 d6 d7 d8 m
    global beta 
    global eta 
    global tau lambda k p
    global sigma_1 sigma_2 
    global gamma_1 gamma_2 gamma_3
    global rho_1 rho_2
    
    

        u_va=u(1);u_1=u(2);u_2=u(3);u_p=u(4);
        %impostazione dei vari numeri sulle variabili
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
        %sistema in se
        xdot(1)=(b - (+d1 + beta * Ia * (1 - u_p) + u_va) * S + eta * R );
        xdot(2)=(beta * Ia * (1 - u_p) * S - (d2 + k) * E);
        xdot(3)=(-(d3 + lambda * tau + gamma_1) * Ia + k * E);
        xdot(4)=(-(d4 + gamma_2 + sigma_1) * Q + p * lambda * tau * Ia);
        xdot(5)=(-(d5 + gamma_3 + rho_1 * u_1 + sigma_2 * (1 - u_1)) * I1 + sigma_1 * Q + (1 - p) * lambda * tau * Ia);
        xdot(6)=(-(d6 + m + rho_2 * u_2) * I2 + sigma_2 * (1 - u_1) * I1);
        xdot(7)=(-(eta + d7) * R + gamma_1 * Ia + gamma_2 * Q + (gamma_3 + rho_1 * u_1) * I1 + rho_2 * u_2 * I2);
        xdot(8)= (-d8*V+u_va * S);
       
end