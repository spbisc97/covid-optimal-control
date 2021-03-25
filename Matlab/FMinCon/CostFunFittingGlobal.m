function J_fitting = CostFunFittingGlobal(parameters)

global days
global initstates
global  sigma_1 sigma_2 %beta
global gamma_1 gamma_2 gamma_3 p
global lambda rho_1 rho_2
global Q_real I1_real I2_real OptFunVal
global u
global Functionals month_dur

weeks=ceil((days)/7);
months=ceil((days)/month_dur);


for month=1:months
    
    sigma_1(month) = parameters(1+(month-1)*9);
    sigma_2(month) = parameters(2+(month-1)*9);
    gamma_1(month) = parameters(3+(month-1)*9);
    gamma_2(month)  = parameters(4+(month-1)*9);
    gamma_3(month)= parameters(5+(month-1)*9);
    p(month) = parameters(6+(month-1)*9);
    lambda(month) = parameters(7+(month-1)*9);
    rho_1(month) = parameters(8+(month-1)*9);
    rho_2(month) = parameters(9+(month-1)*9);% = month
end




for week = 1:1:(length(parameters)-months*9)/3
    if week < weeks
        u(week,2:4)=parameters((week-1)*3+months*9+1:(week-1)*3+months*9+3);
    end
end





tspan =(1:1:days);

opts = odeset('MaxStep',1);
init=initstates;
[t,x]=ode45(@CovidSimulator,tspan,init,opts);
%StateVars = ['S', 'E', 'Ia', 'Q' ,'I1', 'I2' ,'R', 'V'];
% S_sim=x(:,1);
Q_sim=x(:,4);
I1_sim=x(:,5);
I2_sim=x(:,6);



J_fitting = (1)*(sum(((Q_real-Q_sim)).^2)/days)+...
    (2)*(sum(((I1_real-I1_sim)).^2)/days)+...
    (1e1)*(sum(((I2_real-I2_sim)).^2)/days);


if Functionals(1) ~= "(1e-1)*(sum(((Q_real(init_day:final_day)-Q_sim)).^2)/days)+(2)*(sum(((I1_real(init_day:final_day)-I1_sim)).^2)/days)+(1e1)*(sum(((I2_real(init_day:final_day)-I2_sim)).^2)/days)"
    Functionals(1) = "(1e-1)*(sum(((Q_real(init_day:final_day)-Q_sim)).^2)/days)+(2)*(sum(((I1_real(init_day:final_day)-I1_sim)).^2)/days)+(1e1)*(sum(((I2_real(init_day:final_day)-I2_sim)).^2)/days)";
end

len = length(OptFunVal(:,7));
OptFunVal(len+1,7)=J_fitting;


end

