function J_fitting = CostFunFitting(parameters)

global days
global initstates
global  sigma_1 sigma_2 %beta
global gamma_1 gamma_2 gamma_3 p
global rho_1 rho_2 lambda k
global Q_real I1_real I2_real OptFunVal

sigma_1 = parameters(1);
sigma_2 = parameters(2);
gamma_1 = parameters(3);
gamma_2  = parameters(4);
gamma_3= parameters(5);
p = parameters(6);
rho_1 = parameters(7);
rho_2 = parameters(8);
lambda = parameters(9);
k = parameters(10);
%beta = parameters(11);

%S_real = zeros(sizeTable(1),1);
%     S_real(1) = initstates(1);
%     for i=2:sizeTable(1)
%         S_real(i) = S_real(i-1)-tableData.nuovi_positivi(i);
%     end

tspan =(1:1:days);
opts = odeset('MaxStep',1);
init=[initstates(1:3) Q_real(1) I1_real(1) I2_real(1) initstates(7:8)];
[t,x]=ode45(@CovidSimulator,tspan,init,opts);
%StateVars = ['S', 'E', 'Ia', 'Q' ,'I1', 'I2' ,'R', 'V'];
%S_sim=x(:,1);
Q_sim=x(:,4);
I1_sim=x(:,5);
I2_sim=x(:,6);

J_fitting = (sum(abs(Q_real-Q_sim))/days)+(sum(abs(I1_real-I1_sim))/days)+(sum(abs(I2_real-I2_sim))/days);
len = length(OptFunVal(:,1));
OptFunVal(len+1,1)=J_fitting;

end

