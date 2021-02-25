function J_fitting = CostFunFitting(parameters)

global days
global initstates
global  sigma_1 sigma_2 %beta
global gamma_1 gamma_2 gamma_3 p
global lambda rho_1 rho_2
global Q_real I1_real I2_real OptFunVal
global u month
global Functionals future_initstates

init_day=(month-1)*31 +1;
 if (month)*31 > days 
     final_day=days ;
 else
     final_day=(month)*31 ;
 end  


sigma_1(month) = parameters(1);
sigma_2(month) = parameters(2);
gamma_1(month) = parameters(3);
gamma_2(month)  = parameters(4);
gamma_3(month)= parameters(5);
p(month) = parameters(6);
lambda(month) = parameters(7);
rho_1(month) = parameters(8);
rho_2(month) = parameters(9);



weeks=ceil((days)/7);
for elem = 1:1:(length(parameters)-9)/3
    week=(ceil(month*31/7))+elem-1;
    if week < weeks
        u(week,2:4)=parameters((elem-1)*3+10:(elem-1)*3+12);
    end
end




    tspan =(init_day:1:final_day);

opts = odeset('MaxStep',1);
init=[initstates(1:3) Q_real(init_day) I1_real(init_day) I2_real(init_day) initstates(7:8)];
[t,x]=ode45(@CovidSimulator,tspan,init,opts);
%StateVars = ['S', 'E', 'Ia', 'Q' ,'I1', 'I2' ,'R', 'V'];
%S_sim=x(:,1);
Q_sim=x(:,4);
I1_sim=x(:,5);
I2_sim=x(:,6);

future_initstates=[x(end,1),x(end,2),x(end,3),x(end,4),x(end,5),x(end,6),x(end,7),x(end,8)];
%Q~10^5   I1 ~ 10^4 i1 ~10^3

%J_fitting = (sum(((Q_real-Q_sim)./(Q_real)).^2))+(sum(((I1_real-I1_sim)./I1_real).^2)/days)+(sum(((I2_real-I2_sim)./I2_real).^2)/days);
J_fitting = (1e-1)*(sum(((Q_real(init_day:final_day)-Q_sim)).^2)/days)+...
    (2)*(sum(((I1_real(init_day:final_day)-I1_sim)).^2)/days)+...
    (1e1)*(sum(((I2_real(init_day:final_day)-I2_sim)).^2)/days);


if Functionals(1) ~= "(1e-1)*(sum(((Q_real(init_day:final_day)-Q_sim)).^2)/days)+(2)*(sum(((I1_real(init_day:final_day)-I1_sim)).^2)/days)+(1e1)*(sum(((I2_real(init_day:final_day)-I2_sim)).^2)/days)"
    Functionals(1) = "(1e-1)*(sum(((Q_real(init_day:final_day)-Q_sim)).^2)/days)+(2)*(sum(((I1_real(init_day:final_day)-I1_sim)).^2)/days)+(1e1)*(sum(((I2_real(init_day:final_day)-I2_sim)).^2)/days)";
end

len = length(OptFunVal(:,1));
OptFunVal(len+1,1)=J_fitting;

end

