function J_fitting = CostFunFitting(parameters)

global days
global initstates
global  sigma_1 sigma_2 %beta
global gamma_1 gamma_2 gamma_3 p
global lambda k
global Q_real I1_real I2_real OptFunVal
%global u



sigma_1 = parameters(:,1);
sigma_2 = parameters(:,2);
gamma_1 = parameters(:,3);
gamma_2  = parameters(:,4);
gamma_3= parameters(:,5);
p = parameters(:,6);
lambda = parameters(:,7);
k = parameters(:,8);
% weeks=ceil((days)/7);
% for elem = 1:1:weeks
%     u(elem,2:4)=parameters((elem-1)*3+9:(elem-1)*3+11);
% end
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

%J_fitting = (sum(((Q_real-Q_sim)./(Q_real)).^2))+(sum(((I1_real-I1_sim)./I1_real).^2)/days)+(sum(((I2_real-I2_sim)./I2_real).^2)/days);
J_fitting = (1/2)*(sum(((Q_real-Q_sim)).^2)/days)+(sum(((I1_real-I1_sim)).^2)/days)+(sum(((I2_real-I2_sim)).^2)/days);

len = length(OptFunVal(:,1));
OptFunVal(len+1,1)=J_fitting;

end

