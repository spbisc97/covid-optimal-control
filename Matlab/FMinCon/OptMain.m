close all
clc
%%
%model parameters covid
global b d1 d2 d3 d4 d5 d6 d7 d8 
global beta 
global eta 
global tau lambda k p
global sigma_1 sigma_2 
global gamma_1 gamma_2 gamma_3
global rho_1 rho_2
global u_va u_1 u_2 u_p

    
d1=0.00003;d2=0.0001;d3=0.0001;d4=0.0001;d5=0.0001;d6=0.0001;d7=0.0001;d8=0;
b=0.1;m=0.0009;
    
beta=0.000000005;
eta=0.01; %~circa 100 giorni
tau=0.07; %inverso tempo medio insorgenza sintomi
lambda=0.06; %valore medio nuovi positivi
k=0.06; %inverso tempo medio periodo incubazione 12-14 giorni circa
p=0.2; %percentuale persone in isolamento domiciliare rispetto alla percentuale positivi in ospedale 
sigma_1=0.08; sigma_2 = 0.05 ;%sigma_2=0.01;
gamma_1=0.03;gamma_2=0.03;gamma_3=0.02;
rho_1=1;rho_2=1;
%u_va=0;u_1=0.2;u_2=0.15;u_p=0.3;

% global inputs
% inputs = [u_va u_1 u_2 u_p];
%stati iniziali = [S E Ia Q I1 I2 R V];
global initstates;
%initstates=[59999728,200,4000,94,101,26,1,0];
scale = 1e-8;
initstates = zeros(1, 8);
initstates(2) = vpa(200*scale);
initstates(3) = vpa(4000*scale);
initstates(4) = vpa(94*scale);
initstates(5) = vpa(101*scale);
initstates(6) = vpa(26*scale);
initstates(7) = vpa(1*scale);
initstates(1) = 1 - initstates(2)-initstates(3)-initstates(4)-initstates(5)-initstates(6)-initstates(7)
global days;
days=100; %tempo di esecuzione in gg


%here u can set specific imput changes with time
%inputs(u_p, 170) = 0.001;
%Inputs = [u_va u_1 u_2 u_p];
%ObjectiveFn(initialstates',days,inputs)

%% BEFORE THE OPTIMIZATION
%figure
%Plotter()
%% PLOT BEFORE OPTIMIZATION no function Plotter
% [t,x]=ode45(@CovidSimulator,[1 days],initstates);
%     tiledlayout(3,1)
%     nexttile();
%     plot(t,x(:,1));
%     legend('S');
%     title('Persone non ancora infette');
%     nexttile();
%     plot(t,[x(:,2) x(:,3) x(:,4) x(:,7) x(:,8)])
%     legend( 'E', 'Ia', 'Q' ,'R', 'V', 'Location', 'northwest');
%     title('Esposti, Infetti asintomatici, quar., guariti, vacc.')
%     nexttile();
%     plot(t,[x(:,5) x(:,6)])
%     title('Infetti ospedalizzati ed interapia intensiva');
%     legend('I1', 'I2', 'Location', 'northwest');
%     set(gcf, 'Position',  [550, 50, 900, 920])
%% OPTIMIZATION

weeks=ceil((days)/7);
options.MaxFunEvals=1000000;
options.TolFun=1e-10;
options.MaxIter=10000000;
lb=zeros(weeks,4);
ub=zeros(weeks,4);
ub(:,:)=0.999;
guess=zeros(weeks,4);%guess iniziali inputs
guess(:,:)=0.5;
[optu,fval]=fmincon(@ObjectiveFn,guess,[],[],[],[],lb,ub,[],options);
disp('u_va u_1 u_2 u_p');
disp(optu);

%% AFTER THE OPTIMIZATION
%figure 
%Plotter()
