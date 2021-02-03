function SEIR(u,N)
%Math-Works website is also useful for this. Wikipedia explains the 4 odes
%nicely.
%u = 0.01;       %These are just parameters for the model.
%N = 1;
b = 0.005;
v = 0.05;
a = 0.8;
    function dF = rigid(t, x);       %set up the function to be solved in a seperate function environment
        dF = zeros(4,1);
dF(1) = u*N - u*x(1) - b*x(2)*x(1)/N;  %set of 4 odes, I just found them on wikipedia to then use here.
dF(2) = b*x(3)*x(1)/N - (u + a)*x(2);
dF(3) = a*x(2) - (v + u)*x(3);
dF(4) = v*x(3) - u*x(4);
    end
options = odeset('Refine', 10, 'RelTol', 1e-4);     %allows us to tailor ode45's options
[t,y] = ode45(@rigid, [0 60], [500 1 0 1], options); %call ode45 to solve the model "rigid".

plot(t, y)
title('SEIR model')
legend('S','E','I', 'R')
end
