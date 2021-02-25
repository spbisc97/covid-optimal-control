close all
clear
clc
%% Setup and Parameters
%load alredy optimized data
load_data=false;

fitting=1;

optimization1=0;
optimization2=0;
optimization3=0;
optimization4=0;



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

beta=2.5e-9;   %(60 000 000 * rt )
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

days=200; %tempo di esecuzione in gg
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
gamma_1=ones(months,1)*0.09;gamma_2=ones(months,1)*0.08;gamma_3=ones(months,1)*0.07; %guarigione spontanea
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
figure
RealTile=tiledlayout(4,1);
nexttile(1);
plot((1:1:days),0);
nexttile(2);
plot((1:1:days),0);
nexttile(3);
plot((1:1:days),Q_real,"m");
hold on;
plot((1:1:days),Q,".");
title("In isolamento");
legend('Q');
nexttile(4);
plot((1:1:days),I1_real,"b",(1:1:days),I2_real,"r");
hold on;
plot((1:1:days),I1,".",(1:1:days),I2,".");
title("Ospedalizzati e in terapia intensiva");
legend( 'I1', 'I2');
set(gcf, 'Position',  [800, 50, 900, 920])

hold on;
pause(2)
%% PARAMETERS FITTING (beta, sigma1, sigma2)
disp("PARAMETERS FITTING")
if exist('OptParameters.mat','file') && load_data
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
        lb= [0.00001,0.00001 ,0,0.001,0.001, 0.3,0.001,  0,0];
        ub=[0.1,0.1 ,1,0.1,0.9, 0.99,0.7,   0.9,0.9];
        
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
%         

        
        [optPar,fval]=fmincon(@CostFunFitting,guess,A_ineq,B_ineq,[],[],lb,ub,[],options);
        initstates=future_initstates;
    end
    
    disp('sigma_1, sigma_2, gamma_1, gamma_2, gamma_3, p, rho_1, rho_2, lambda, k, u');
    
    ufit=u;
    disp(optPar);
end


%% PLOT AFTER THE FITTING OPTIMIZATION
disp('PLOT AFTER THE OPTIMIZATION')
initstates=[59699728,200000,300000,Q_real(1),I1_real(1),I2_real(1),400000,0];

[t,x]=ode45(@CovidSimulator,[1 days],initstates);

nexttile(1);
plot(t,x(:,1));
legend('S');
title('Persone non ancora infette');
nexttile(2);
plot(t,[x(:,2) x(:,3) x(:,7) x(:,8)])
legend( 'E', 'Ia','R', 'V', 'Location', 'northwest');
title('Esposti, Infetti asintomatici, guariti, vacc.')
nexttile(3);
plot(t,x(:,4))
legend( 'Q');
title('Quarantena')
nexttile(4);
plot(t,[x(:,5) x(:,6)])
title('Infetti ospedalizzati ed interapia intensiva');
legend('I1', 'I2', 'Location', 'northwest');
set(gcf, 'Position',  [800, 50, 900, 920])
fittingPlot=gcf;



pause(2)
%% OPTIMIZATION SETTINGS

disp("CONTROL OPTIMIZATION")
if exist('OptControls.mat','file') && load_data
    load('OptControls.mat')
end
options.MaxFunEvals=1000000;
options.TolFun=1e-10;
options.MaxIter=10000000;
lb=zeros(weeks,4);
ub=zeros(weeks,4);
ub(:,:)=0.999;
guess=zeros(weeks,4);%guess iniziali inputs
guess(:,:)=0.5;

%% FIRST STRATEGY
controlPlot = zeros(1,4);
if optimization1
    disp('################### FIRST STRATEGY #####################')
    [optu,fval]=fmincon(@ObjectiveFn,guess,[],[],[],[],lb,ub,[],options);
    disp('u_va u_1 u_2 u_p');
    disp(optu);
    figure
    controlPlot(1) = Plotter(false);
    pause(2)
end
%% SECOND STRATEGY
if optimization2
    disp('################### SECOND STRATEGY #####################')
    [optu,fval]=fmincon(@Objective2Fn,guess,[],[],[],[],lb,ub,[],options);
    disp('u_va u_1 u_2 u_p');
    disp(optu);
    figure
    controlPlot(2)=Plotter(false);
    pause(2)
end
%% THIRD STRATEGY
if optimization3
    disp('################### THIRD STRATEGY #####################')
    
    [optu,fval]=fmincon(@Objective3Fn,guess,[],[],[],[],lb,ub,[],options);
    disp('u_va u_1 u_2 u_p');
    disp(optu);
    figure
    controlPlot(3)=Plotter(false);
    pause(2)
end
%% FOURTH STRATEGY
if optimization4
    disp('################### FOURTH STRATEGY #####################')
    [optu,fval]=fmincon(@Objective4Fn,guess,[],[],[],[],lb,ub,[],options);
    disp('u_va u_1 u_2 u_p');
    disp(optu);
    figure
    controlPlot(4)=Plotter(false);
    pause(2)
end
%% PLOT AFTER THE OPTIMIZATION
% disp('PLOT AFTER OPTIMIZATION')
% figure;
% controlPlot=Plotter(false);


%% Save some info
%for later
save ('OptParameters', 'sigma_1', 'sigma_2', 'gamma_1',...
    'gamma_2', 'gamma_3', 'p', 'rho_1', 'rho_2', ...
    'lambda', 'k','ufit');
save ('OptControl', 'u');
%forever

% if ~exist('Vars/','dir')
%     mkdir Vars;
% end
% pos='Vars/';
% place=strcat(pos,datestr(now,'mmmm-dd-yyyy_HH-MM'));
% para=strcat(place,'-Parameters.mat');
% save (para, 'sigma_1', 'sigma_2', 'gamma_1', ...
%     'gamma_2', 'gamma_3', 'p', 'rho_1', 'rho_2', 'lambda', 'k','u', ...
%     'Functionals','OptFunVal' ...
%     );
% if exist('fittingPlot','var')
%     image=strcat(place,'-Fitting.png');
%     saveas(fittingPlot,image);
% end
% if exist('controlPlot','var')
%     for i = 1:length(controlPlot)
%         if exist('controlPlot(i)','var')
%             image2=strcat(place,'-Control',string(i),'.png');
%             saveas(controlPlot(i),image2);
%         end
%     end
% end