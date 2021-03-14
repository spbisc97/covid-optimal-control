close all
clear
clc
%% Setup and Parameters
%suppress warning for too near constraints
warning ('off','all');

%load alredy optimized data
load_data_fitting=true;
load_data_optimization=true;
save_info=0;

fitting=0;

optimization1=0;
optimization2=0;
optimization3=0;
optimization4=0;

optu1=0;optu2=0;optu3=0;optu4=0;


%model parameters covid
global b d1 d2 d3 d4 d5 d6 d7 d8 m
global beta
global eta
global tau lambda k p
global sigma_1 sigma_2
global gamma_1 gamma_2 gamma_3
global rho_1 rho_2
global OptFunVal
global initstates future_initstates
global days
global u
global Functionals
global month
%global u_va u_1 u_2 u_p
OptFunVal=zeros(1,5);
Functionals=["" "" "" "" ""];
Population=60000000;
Deaths2019=647000;
d=(Deaths2019/Population)/365;

d1=d;d2=d;d3=d;d4=d;d5=d;d6=d;d7=d;d8=0;
b=1180; m=0.09;

beta=3.5e-10;   %(60 000 000 * rt )
eta=0;  %0.01; %~circa 100 giorni ~3 mesi
tau=0.2; %inverso tempo medio insorgenza sintomi (dopo incubazione non contagiosa)= 5gg
k=0.3; %inverso tempo medio periodo incubazione (non contagiosa) 3/4 giorni circa

%u_va=0;u_1=0.2;u_2=0.15;u_p=0.3;
% global inputs
% inputs = [u_va u_1 u_2 u_p];
%stati iniziali = [S E Ia Q I1 I2 R V];

initstates=[59699728,200000,300000,16000,900,60,400000,0];
% scale = 1e-8;
% initstates = zeros(1, 8);
% initstates(2) = vpa(200*scale);
% initstates(3) = vpa(4000*scale);
% initstates(4) = vpa(94*scale);
% initstates(5) = vpa(101*scale);
% initstates(6) = vpa(26*scale);
% initstates(7) = vpa(1*scale);
% initstates(1) = 1 - initstates(2)-initstates(3)-initstates(4)-initstates(5)-initstates(6)-initstates(7)

days=245; %tempo di esecuzione in gg
weeks=ceil((days)/7);
months=ceil((days)/31);

u = zeros(weeks,4);
u(:,1) = 0;
u(:,2) = 0.5;
u(:,3) = 0.5;
u(:,4) = 0.5;

lambda=ones(months,1)*0.01; %valore medio nuovi positivi
p=ones(months,1)*0.8; %percentuale(guess) persone in isolamento domiciliare rispetto alla percentuale positivi in ospedale
sigma_1=ones(months,1)*0.09; sigma_2 = ones(months,1)*0.1; %guess tassi complicanza
gamma_1=ones(months,1)*0.009;gamma_2=ones(months,1)*0.08;gamma_3=ones(months,1)*0.07; %guarigione spontanea
rho_1=ones(months,1)*0.8;rho_2=ones(months,1)*0.7; % tassi di successo


%here u can set specific imput changes with time
%inputs(u_p, 170) = 0.001;
%Inputs = [u_va u_1 u_2 u_p];
%ObjectiveFn(initialstates',days,inputs)

%% PLOT BEFORE THE OPTIMIZATION
%figure
%Plotter(false)


%% Get The Real Data
tableData = onlineData('dati_covid.csv', 'https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-andamento-nazionale/dpc-covid19-ita-andamento-nazionale.csv');
%get data from "Presidenza del Consiglio dei Ministri - Dipartimento della Protezione Civile"
%data starts from june -> move to S for better realistic data
tableData(1:(30*4),:)=[];
global Q_real I1_real I2_real
Q=tableData.isolamento_domiciliare(1:days,1);
I1=tableData.ricoverati_con_sintomi(1:days,1);
I2=tableData.terapia_intensiva(1:days,1);
Q_real = smooth(Q);
I1_real = smooth(I1);
I2_real = smooth(I2);
%less spikes

if size(Q_real)< days
    disp("Not enough real data!",size(Q_real),'<',days)
    quit(1)
end

%% Plot Real Data
disp("Plot Real Data")
figure('Name','Real Data')
RealTile=tiledlayout(4,1);
nexttile(1);
%plot((1:1:days),0);

nexttile(2);
plot((1:1:days),0);
nexttile(3);
plot((1:1:days),Q_real,"m");
hold on;
plot((1:1:days),Q,".m");
title("In isolamento");
legend('Q_r');
legend('Location','bestoutside');
nexttile(4);
plot((1:1:days),I1_real,"g",(1:1:days),I2_real,"c");
hold on;
plot((1:1:days),I1,".g",(1:1:days),I2,".c");
title("Ospedalizzati e in terapia intensiva");
legend( 'I1_r', 'I2_r');
legend('Location','bestoutside');
set(gcf, 'Position',   get(0, 'ScreenSize')./[1 1 2 1])

hold on;
pause(2)
%% PARAMETERS FITTING (beta, sigma1, sigma2)
disp("PARAMETERS FITTING")
if exist('OptParameters.mat','file') && load_data_fitting
    load('OptParameters.mat') %if fitting already there, less computation time getting faster to optimum
    u=ufit;
end

% opts = optimoptions('fmincon',...
%     'Algorithm','interior-point', ... %default
%     'MaxFunctionEvaluations',1000000000, ...
%     'MaxIterations',10000000000, ... %'UseParallel',true,
%     'FunctionTolerance',1e-13);
if fitting
    options.MaxFunEvals=100000000;
    options.TolFun=1e-12;
    options.MaxIter=100000000;
    for month = 1:months
        
        guess= [sigma_1(month), sigma_2(month), gamma_1(month), gamma_2(month), gamma_3(month), p(month), lambda(month), rho_1(month) , rho_2(month)];
        lb= [0.00001,0.00001 ,0.00001,0.01,0.01, 0.3,0.001,  0.2,0.2];
        ub=[0.1,0.1 ,0.005,0.1,0.5, 0.99,0.7,   0.9,0.9];
        
        for elem = (ceil(month*31/7)):1:(ceil((month+1)*31/7))
            if elem < weeks
                len=length(lb);
                lb(len+1:len+3)=[0,0,0];
                ub(len+1:len+3)=[0.9,0.9,0.9];
                guess(len+1:len+3)=u(elem,2:4);
            end
        end
        A_ineq=[];B_ineq=[];
        %         zero_ineq=length(guess);
        %         k_ineq=0.1;
        %         diag=eye((weeks -1)*3);diag(:,end+1:end+3)=0;
        %         diag(:,end+1:end+zero_ineq)=0;
        %         A_ineq=circshift(diag,[0 zero_ineq])-circshift(diag,[0 zero_ineq+3]);
        %         B_ineq=k_ineq*ones((weeks-1)*3,1);
        
        
        
        [optPar,fval]=fmincon(@CostFunFitting,guess,A_ineq,B_ineq,[],[],lb,ub,[],options);
        initstates=future_initstates;
    end
    
    disp('sigma_1, sigma_2, gamma_1, gamma_2, gamma_3, p, rho_1, rho_2, lambda, k, u');
    
    ufit=u;
    disp(optPar);
end


%% PLOT AFTER THE FITTING OPTIMIZATION
disp('PLOT AFTER THE FITTING')
initstates=[59699728,200000,300000,Q_real(1),I1_real(1),I2_real(1),200000,0];

[t,x]=ode45(@CovidSimulator,[1 days],initstates);

nexttile(1);
plot(t,x(:,1));
ylim([5.5e7 6.1e7])

legend(nexttile(1),'S');
title('Persone non ancora infette');
nexttile(2);
plot(t,[x(:,2) x(:,3) x(:,7) x(:,8)])
ylim([0 5e6])

legend(nexttile(2), 'E', 'Ia','R', 'V', 'Location', 'bestoutside');
title('Esposti, Infetti asintomatici, guariti, vacc.')
nexttile(3);
title('Quarantena');
plot(t,x(:,4),'k','DisplayName','Q');
legend('Location','bestoutside');
nexttile(4);
plot(t,x(:,5),'b','DisplayName','I1');
plot(t,x(:,6),'r','DisplayName','I2');
title('Infetti ospedalizzati ed interapia intensiva');
legend('Location','bestoutside');
set(gcf,'Name','Fitting');
set(gcf, 'Position',   get(0, 'ScreenSize')./[1 1 2 1])
fittingPlot=gcf;



pause(2)
%% OPTIMIZATION SETTINGS

disp("CONTROL OPTIMIZATION")
if exist('OptControl.mat','file') && load_data_optimization
    load('OptControl.mat')
end

%tranform in array
lb=zeros(weeks*4,1);
ub=zeros(weeks*4,1); %upperbound in contr
ub(:)=0.999;
ub(1:weeks)=1e-10;



guess=zeros(weeks*4,1);%guess iniziali inputs

guess(1:weeks)=0.0;
guess(weeks+1:weeks*2)=0.3;
guess(weeks*2+1:weeks*3)=0.1;
guess(weeks*2+1:weeks*3)=1;


fVD=189; %first Vaccine Day
if days>fVD
    ub(ceil(fVD/7):weeks)=0.04; %upperbound 400 mila vaccinazioni gg
    if days>(fVD+30)
        ub(ceil((fVD+30)/7):weeks)=0.08;
        %upperbound 800 mila vaccinazioni gg
        %da febbraio in poi
    end
end


Acontrol=[eye(weeks)*1 eye(weeks)*1 eye(weeks)*1 eye(weeks)*1];
% constaint on sum of weeks controls (u_va*1<u_1*1<u_2*1<u_p*1)<

Bcontrol=ones(weeks,1)*2.5;


%% FIRST STRATEGY
controlPlot = zeros(1,4);


if optimization1
    options=optimoptions('fmincon','Algorithm','interior-point');
    disp('################### FIRST STRATEGY #####################')
    [optu1,fval]=fmincon(@ObjectiveFn,guess,Acontrol,Bcontrol,[],[],lb,ub,[],options);
    disp('u_va u_1 u_2 u_p');
    optu1=u;
    disp(optu1);
end
if optu1
    u=optu1;
    figure('Name','Optimal Control Susceptible Based Strategy');
    controlPlot(1) = Plotter(false);
    pause(2)
end
%% SECOND STRATEGY
if optimization2
    disp('################### SECOND STRATEGY #####################')
    [optu2,fval]=fmincon(@Objective2Fn,guess,[],[],[],[],lb,ub,[],options);
    disp('u_va u_1 u_2 u_p');
    optu2=u;
    disp(optu2);
end
if optu2
    u=optu2;
    figure('Name','Optimal Control I_1 I_2 Based Strategy');
    controlPlot(2)=Plotter(false);
    pause(2)
end

%% THIRD STRATEGY
if optimization3
    disp('################### THIRD STRATEGY #####################')
    
    [optu3,fval]=fmincon(@Objective3Fn,guess,[],[],[],[],lb,ub,[],options);
    disp('u_va u_1 u_2 u_p');
    optu3=u;
    disp(optu3);
end
if optu3
    u=optu3;
    figure('Name','Optimal Control Mixed Strategy');
    controlPlot(3)=Plotter(false);
    pause(2)
end
%% FOURTH STRATEGY
if optimization4
    disp('################### FOURTH STRATEGY #####################')
    [optu4,fval]=fmincon(@Objective4Fn,guess,[],[],[],[],lb,ub,[],options);
    disp('u_va u_1 u_2 u_p');
    optu4=u;
    disp(optu4);
end
if optu4
    u=optu4;
    figure('Name','Optimal Control Vaccine Based Strategy');
    controlPlot(4)=Plotter(false);
    pause(2)
end
%% PLOT AFTER THE OPTIMIZATION
if optu1
    disp('PLOT COMPARISON AFTER OPTIMIZATION')
    MixedPlotter(ufit,optu1,optu2,optu3,optu4);
end

%% Save some info
%for later

if save_info
    save ('OptParameters', 'sigma_1', 'sigma_2', 'gamma_1',...
        'gamma_2', 'gamma_3', 'p', 'rho_1', 'rho_2', ...
        'lambda', 'k','ufit');
    save ('OptControl','optu1','optu2','optu3','optu4','u');
    % %forever
    
    if ~exist('Vars/','dir')
        mkdir Vars;
    end
    pos='Vars/';
    place=strcat(pos,datestr(now,'mmmm-dd-yyyy_HH-MM'));
    para=strcat(place,'-Parameters.mat');
    save (para, 'sigma_1', 'sigma_2', 'gamma_1', ...
        'gamma_2', 'gamma_3', 'p', 'rho_1', 'rho_2', 'lambda', 'k','u', ...
        'Functionals','OptFunVal' ...
        );
    if exist('fittingPlot','var')
        image=strcat(place,'-Fitting.png');
        saveas(fittingPlot,image);
    end
    if exist('controlPlot','var')
        for i = 1:length(controlPlot)
            if controlPlot(i)
                image2=strcat(place,'-Control',string(i),'.png');
                saveas(controlPlot(i),image2);
            end
        end
    end
    if exist('Icomp','var')
        image=strcat(place,'-Icomp.png');
        saveas(Icomp,image);
    end
    if exist('ContrComp','var')
        image=strcat(place,'-ContrComp.png');
        saveas(ContrComp,image);
    end
end
