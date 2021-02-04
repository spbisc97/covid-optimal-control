function CovidSim(initstates,days,inputs)

syms b d1 d2 d3 d4 d5 d6 d7 d8 m
sym beta 
sym eta 
syms tau lambda k p
syms u_va u_1 u_2 u_p
syms sigma_1 sigma_2 
syms gamma_1 gamma_2 gamma_3
syms rho_1 rho_2
%syms lambda_1 lambda_2 lambda_3 lambda_4 lambda_5 lambda_6 lambda_7 lambda_8
%syms S E Ia Q I1 I2 R V
%syms alpha_1 delta_1 delta_2 delta_3 delta_4

u_va=0;u_1=0.4;u_2=0.5;u_p=0.9;


d1=0.01;d2=0.01;d3=0.01;d4=0.01;d5=0.01;d6=0.01;d7=0.01;d8=0.01;b=1000;m=0.001;

beta=0.00000001;
eta=0.01; %~circa 100 giorni
tau=0.01;
lambda=0.01;
k=0.1;
p=0.1;
sigma_1=0.01;sigma_2=0.01;
gamma_1=0.01;gamma_2=0.01;gamma_3=0.01;
rho_1=1;rho_2=1;

T=[];
function xdot =sim(t,x)
    %inutile
    T(end+1) = t;
    %
    
    % floor sta per valore intero di 
    t=floor(t);
    % in questo modo la u può cambiare ad ogni t volendo
    if(inputs(1,t)~=0);u_va=inputs(1,t);end
    if(inputs(2,t)~=0);u_1=inputs(2,t);end
    if(inputs(3,t)~=0);u_2=inputs(3,t);end
    if(inputs(4,t)~=0);u_p=inputs(4,t);end
    
    
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
    xdot(8)=(-d8 * V + u_va * S);
    
end

%time=linspace(1,days,days);
tspan=[1 days];
%opzioni di ode step massimo di integrazione =1
opts = odeset('MaxStep',1);

[t,x]=ode45(@sim,tspan,initstates,opts);
%StateVars = ['S', 'E', 'Ia', 'Q' ,'I1', 'I2' ,'R', 'V'];
s=x(:,1);
e=x(:,2);
ia=x(:,3);
q=x(:,4);
i1=x(:,5);
i2=x(:,6);
r=x(:,7);
v=x(:,8);
time=t(:,1);

%plotta il tutto 
tiledlayout(3,1)
nexttile();
plot(t,s);
legend('S');
nexttile();
plot(t,[e ia q r v])
legend( 'E', 'Ia', 'Q' ,'R', 'V');
nexttile();
plot(t,[i1 i2])
legend('I1', 'I2');
%display(x)
%legend('S', 'E', 'Ia', 'Q' ,'I1', 'I2' ,'R', 'V');
%display(T)
end

