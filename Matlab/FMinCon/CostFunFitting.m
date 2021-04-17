function J_fitting = CostFunFitting(parameters)

%get values from global
global days
global initstates
global  sigma_1 sigma_2 %beta
global gamma_1 gamma_2 gamma_3 p
global lambda rho_1 rho_2
global Q_real I1_real I2_real OptFunVal
global u month month_dur ut
global Functionals future_initstates


%get initial and final day
init_day=(month-1)*month_dur+1;
if (month)*month_dur > days
    final_day=days ;
else
    final_day=(month)*month_dur;
end

%set parameters from fmincon to global 
sigma_1(month) = parameters(1);
sigma_2(month) = parameters(2);
gamma_1(month) = parameters(3);
gamma_2(month)  = parameters(4);
gamma_3(month)= parameters(5);
p(month) = parameters(6);
lambda(month) = parameters(7);
rho_1(month) = parameters(8);
rho_2(month) = parameters(9);


%move parameters from fmincon to global u
weeks=ceil((days)/7);
for elem = 1:1:(length(parameters)-9)/3
    week=(ceil(((month-1)*month_dur+1)/7))+elem-1;
    if week <= weeks
        u(week,2:4)=parameters((elem-1)*3+10:(elem-1)*3+12);
    end
end


%fill the day gap if not starting from day one
if (init_day==1)
    tspan =(init_day:1:final_day);
else
    tspan =(init_day-1:1:final_day);
end

%set ode options
opts = odeset('MaxStep',1);
init=initstates;
[t,x]=ode45(@CovidSimulator,tspan,init,opts);
%StateVars = ['S', 'E', 'Ia', 'Q' ,'I1', 'I2' ,'R', 'V']; %S_sim=x(:,1);

%fill the day gap if not starting from day one
if (init_day==1)
    Q_sim=x(:,4);
    I1_sim=x(:,5);
    I2_sim=x(:,6);
else
    Q_sim=x(2:end,4);
    I1_sim=x(2:end,5);
    I2_sim=x(2:end,6);
end

if (length(Q_sim) ~= length(Q_real(init_day:final_day))) || ...
        (length(I1_sim) ~= length(I1_real(init_day:final_day))) || ...
        (length(I2_sim) ~= length(I2_real(init_day:final_day)) )
    ME = MException('Variables  not of the same length');
    throw(ME)
end

future_initstates=[x(end,1),x(end,2),x(end,3),x(end,4),x(end,5),x(end,6),x(end,7),x(end,8)];


%Q~10^5   I1 ~ 10^4 i1 ~10^3
%cost function
J_fitting = (1)*(sum(((Q_real(init_day:final_day)-Q_sim)).^2)/days)+...
    (2e1)*(sum(((I1_real(init_day:final_day)-I1_sim)).^2)/days)+...
    (8e1)*(sum(((I2_real(init_day:final_day)-I2_sim)).^2)/days);


%keep the log of the costs function used across simulations
if Functionals(1) ~= "(1)*(sum(((Q_real(init_day:final_day)-Q_sim)).^2)/days)+(2e1)*(sum(((I1_real(init_day:final_day)-I1_sim)).^2)/days)+(8e1)*(sum(((I2_real(init_day:final_day)-I2_sim)).^2)/days)"
    Functionals(1) = "(1)*(sum(((Q_real(init_day:final_day)-Q_sim)).^2)/days)+(2e1)*(sum(((I1_real(init_day:final_day)-I1_sim)).^2)/days)+(8e1)*(sum(((I2_real(init_day:final_day)-I2_sim)).^2)/days)";
end

%set where last execution finishes
len = length(OptFunVal(:,1));
OptFunVal(len+1,6)=month;
if OptFunVal(len,6)==month
    OptFunVal(len,6)=0;
end
%get execution value
OptFunVal(len+1,1)=J_fitting;

end

