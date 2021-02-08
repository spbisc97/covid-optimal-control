
close all
clc


%model parameters covid
    global b d1 d2 d3 d4 d5 d6 d7 d8 m
    global beta 
    global eta 
    global tau lambda k p
    global sigma_1 sigma_2 
    global gamma_1 gamma_2 gamma_3
    global rho_1 rho_2
    %syms lambda_1 lambda_2 lambda_3 lambda_4 lambda_5 lambda_6 lambda_7 lambda_8
    %syms S E Ia Q I1 I2 R V
    %syms alpha_1 delta_1 delta_2 delta_3 delta_4   
    
    d1=0;d2=0;d3=0;d4=0;d5=0;d6=0;d7=0;d8=0;
    b=0;m=0;
    
    beta=0.000000008;
    eta=0.01; %~circa 100 giorni
    tau=0.07; %inverso tempo medio insorgenza sintomi
    lambda=0.06; %valore medio nuovi positivi
    k=0.06; %inverso tempo medio periodo incubazione 12-14 giorni circa
    p=0.2; %percentuale persone in isolamento domiciliare rispetto alla percentuale
        %positivi in ospedale 
    sigma_1=0.08; sigma_2 = 0.05 ;%sigma_2=0.01;
    gamma_1=0.03;gamma_2=0.03;gamma_3=0.02;
    rho_1=1;rho_2=1;
    
    
    





%StateVars = [S E Ia Q I1 I2 R V];
%Inputs = [u_va u_1 u_2 u_p];


 
%stati iniziali = [S E Ia Q I1 I2 R V];
global initstates;
initstates=[59999728,200,4000,94,101,26,1,0];
global days;
days=71; %tempo di esecuzione in gg


%here u can set specific imput changes with time
%inputs(u_p, 170) = 0.001;
%Inputs = [u_va u_1 u_2 u_p];






%ObjectiveFn(initialstates',days,inputs)
weeks=ceil((days)/7);
options.MaxFunEvals=1000000;
options.TolFun=1e-10;
options.MaxIter=10000000;
lb=zeros(weeks,4);
ub=zeros(weeks,4);
ub(:,:)=0.999;
guess=zeros(weeks,4);%guess iniziali inputs
guess(:,:)=0.5;

guess(:,1)=0.0;


%set constraints
%linear inequalities A*x ≤ b

[optu,fval]=fmincon(@ObjectiveFn,guess,[],[],[],[],lb,ub,[],options);
disp('u_va u_1 u_2 u_p');
disp(optu);
