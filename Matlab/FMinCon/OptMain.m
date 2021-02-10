close all
clc
%%
%model parameters covid
global b d1 d2 d3 d4 d5 d6 d7 d8 m 
global beta 
global eta 
global tau lambda k p
global sigma_1 sigma_2 
global gamma_1 gamma_2 gamma_3
global rho_1 rho_2
%global u_va u_1 u_2 u_p

    
d1=0.01;d2=0.01;d3=0.01;d4=0.01;d5=0.01;d6=0.01;d7=0.01;d8=0;
b=1180; m=0.09;
    
beta=0.000000008;
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
initstates=[59999728,200,4000,94,101,26,1,0];
% scale = 1e-8;
% initstates = zeros(1, 8);
% initstates(2) = vpa(200*scale);
% initstates(3) = vpa(4000*scale);
% initstates(4) = vpa(94*scale);
% initstates(5) = vpa(101*scale);
% initstates(6) = vpa(26*scale);
% initstates(7) = vpa(1*scale);
% initstates(1) = 1 - initstates(2)-initstates(3)-initstates(4)-initstates(5)-initstates(6)-initstates(7)
global days;
days=100; %tempo di esecuzione in gg


global u
u = zeros(ceil(days/7),4);
u(:,1) = 0;
u(:,2) = 0.2;
u(:,3) = 0.15;
u(:,4) = 0.3;

%here u can set specific imput changes with time
%inputs(u_p, 170) = 0.001;
%Inputs = [u_va u_1 u_2 u_p];
%ObjectiveFn(initialstates',days,inputs)

%% PLOT BEFORE THE OPTIMIZATION
figure
Plotter()

%% PARAMETERS FITTING (beta, sigma1, sigma2)

    options.MaxFunEvals=1000000;
    %options.TolFun=1e-10;
    options.MaxIter=10000000;
    lb= [0.0000000001, 0.0001, 0.0001];
    ub=[0.0000009,0.2, 0.2];
    guess= [beta, sigma_1, sigma_2];
    [optPar,fval]=fmincon(@CostFunFitting,guess,[],[],[],[],lb,ub,[],options);
    disp('beta sigma1 sigma2');
    disp(optPar);
%% OPTIMIZATION

% weeks=ceil((days)/7);
% options.MaxFunEvals=1000000;
% options.TolFun=1e-10;
% options.MaxIter=10000000;
% lb=zeros(weeks,4);
% ub=zeros(weeks,4);
% ub(:,:)=0.999;
% guess=zeros(weeks,4);%guess iniziali inputs
% guess(:,:)=0.5;
% [optu,fval]=fmincon(@ObjectiveFn,guess,[],[],[],[],lb,ub,[],options);
% disp('u_va u_1 u_2 u_p');
% disp(optu);

%% PLOT AFTER THE OPTIMIZATION
% figure 
% Plotter()
