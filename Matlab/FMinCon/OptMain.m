close all
clear
clc
%% Setup and Parameters
%suppress warning for too near constraints
warning ('off','all');

%load alredy optimized data
load_data_fitting=1; %true/false 1/0
load_data_optimization=1;
%save data to disk
save_info=0;

%let functions run
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
global month month_dur
month_dur=28;


tableData = onlineData('dati_covid.csv', 'https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-andamento-nazionale/dpc-covid19-ita-andamento-nazionale.csv');
%get data from "Presidenza del Consiglio dei Ministri - Dipartimento della Protezione Civile"

%setup initial values for fmincon logging
OptFunVal=zeros(1,6);
Functionals=["" "" "" "" ""];



% death per day parameter calculation
Population=60000000;
Deaths2019=647000;
d=(Deaths2019/Population)/365;

% Parameters setup
d1=d;d2=d;d3=d;d4=d;d5=d;d6=d;d7=d;d8=0;
m=0.09; % covid death rate in italy
b=1180; %per day births
beta=3.5e-10;   %contact rate
eta=0;  %0.005; %again susceptible, about 200 days ~6 months
k=0.3; %inverse of the incubation period (not infectious) 3/4 days
tau=0.2; %inverse of the mean time to swab (infectious)= 5 days


%initial states= [S E Ia Q I1 I2 R V];
initstates=[59699728,200000,300000,16000,900,60,400000,10];


days=245; %execution time of the simulation in days
weeks=ceil((days)/7); %execution time in weeks(controls)
months=ceil((days)/month_dur); %execution time in months(parameters)


%inputs = [u_va u_1 u_2 u_p];
u = zeros(weeks,4);
for i=1:1:length(u(:,1))
    u(i,1) = 0;
    u(i,2) = 0.5;
    u(i,3) = 0.6;
    u(i,4) = 0.4;
end


lambda=ones(months,1)*0.01; %(guess)percentage of positive 
p=ones(months,1)*0.95; %(guess)percentage of quarantined people
sigma_1=ones(months,1)*0.09; sigma_2 = ones(months,1)*0.1; %(guess) complication rates
gamma_1=ones(months,1)*0.009;gamma_2=ones(months,1)*0.08;gamma_3=ones(months,1)*0.07; %spontaneous recovery rate da Ia Q I1
rho_1=ones(months,1)*0.8;rho_2=ones(months,1)*0.7; % care success rate



%% Get The Real Data

%data starts from june -> move to S for better realistic data
%get index of the real data value from the date '2020-06-23' startSimDay
if verLessThan('matlab','9.10')
    startSimDay='2020-06-23';
    initday=find(ismember(cellfun(@(x) x(1:10),tableData.data,'UniformOutput',false),startSimDay));
    tableData(1:initday,:)=[];
else
    startSimDay=datetime('2020-06-23');
    initday=find(ismember(tableData.data.Day,startSimDay.Day) & ...
        ismember(tableData.data.Month,startSimDay.Month) & ...
        ismember(tableData.data.Year,startSimDay.Year));
    tableData(1:initday,:)=[];
end

%get real data from table and smooth it for less spikes
global Q_real I1_real I2_real
Q=tableData.isolamento_domiciliare(1:days,1);
I1=tableData.ricoverati_con_sintomi(1:days,1);
I2=tableData.terapia_intensiva(1:days,1);
Q_real = smooth(Q);
I1_real = smooth(I1);
I2_real = smooth(I2);

%check if there is enough data
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

%% Set Vaccine control
%first Vaccine Day 27 december+ 10 days
%set vaccine 10 days after initday '2021-01-06' 
if verLessThan('matlab','9.10')
    startSimDay='2021-01-06';
    fVD=find(ismember(cellfun(@(x) x(1:10),tableData.data,'UniformOutput',false),startSimDay));
else
    startSimDay=datetime('2021-01-06');
    fVD=find(ismember(tableData.data.Day,startSimDay.Day) & ...
        ismember(tableData.data.Month,startSimDay.Month) & ...
        ismember(tableData.data.Year,startSimDay.Year));
end
if days>fVD
    u(ceil(fVD/7):weeks,1)=0.02;% ~ 12 thousand inoculation per day
    if days>(fVD+30)
        u(ceil((fVD+30)/7):weeks,1)=0.09;%~ 54 thousand vaccination per day
    end
end


%% PARAMETERS FITTING (beta, sigma1, sigma2)
disp("PARAMETERS FITTING")
descr=["From " datestr(tableData.data(1)) "to" datestr(tableData.data(days))];
disp(join(descr));

%load already computed fitting parameters, for faster or none computation
if exist('OptParameters.mat','file') && load_data_fitting
    load('OptParameters.mat') 
    u=ufit;
end

%update initial data with real one
initstates=[59699728,200000,300000,Q_real(1),I1_real(1),I2_real(1),200000,10];


%if fitting enabled start it
if fitting
    %fmincon options for fitting
    opts = optimoptions('fmincon',... %
        'Algorithm','interior-point', ... %default
        'MaxFunctionEvaluations',1e7, ...
        'MaxIterations',1e7, ... %'UseParallel',true,
        'OptimalityTolerance',1e-4);
    
    %     options.MaxFunEvals=1e7;
    %     options.TolFun=1e-7;
    %     options.MaxIter=1e7;
    
    %determine each month fit parameters 
    for month = 1:months
        %set guess and bounds for the month
        fguess=[sigma_1(month), sigma_2(month), gamma_1(month), gamma_2(month), gamma_3(month), p(month), lambda(month), rho_1(month) , rho_2(month)];
        lb= [0.0001,0.001 ,0.00001,0.0001,0.0001, 0.86,0.001,  0.001,0.001];
        ub=[0.1,0.2 ,0.5,0.2,0.4, 0.96,0.9,   0.8,0.9];
        disp(join(["fitting on month:", month]));
        fprintf("with control weeks: ");
        for elem = (ceil(((month-1)*month_dur+1)/7)):1:(ceil(month*month_dur/7))
            if elem <= weeks
                fprintf(" %d ",elem);
                lb=[lb,0.55,0.45,0.35];
                ub=[ub,0.8,0.7,0.8];
                fguess=[fguess,u(elem,2:4)];
            end
        end
        fprintf("\n");
        
        %         removed variations contraints
        %         zero_ineq=length(guess);
        %         k_ineq=0.1;
        %         diag=eye((weeks -1)*3);diag(:,end+1:end+3)=0;
        %         diag(:,end+1:end+zero_ineq)=0;
        %         A_ineq=circshift(diag,[0 zero_ineq])-circshift(diag,[0 zero_ineq+3]);
        %         B_ineq=k_ineq*ones((weeks-1)*3,1);
        
        A_ineq=[];B_ineq=[];
        
        %start fmincon computation
        [optPar,fval]=fmincon(@CostFunFitting,fguess,A_ineq,B_ineq,[],[],lb,ub,[],opts); %options
        %set initial values for the next month
        initstates=future_initstates;
    end
    
    %get fitted controls
    ufit=u;   
    
    %pretty print of the values
    fprintf('month,   sigma_1  ,   sigma_2    ,    gamma_1   ,   gamma_2    ,   gamma_3    ,      p      ,     lambda   ,     rho_1     ,    rho_2   \n');
    fprintf("    ")
    for elem=1:1:9
        fprintf( "%.5f-%.4f|",lb(elem),ub(elem));
    end
    fprintf("\n");
    for month=1:1:months
        fprintf(2, 'day:%d \n',(month-1)*month_dur+1)
        fprintf("  %2d:  %.5f    |   %.5f    |   %.5f    |   %.5f    |   %.5f    |   %.5f    |   %.5f    |   %.5f    |   %.5f  \n" ,month ,sigma_1(month), sigma_2(month), gamma_1(month), gamma_2(month), gamma_3(month), p(month), lambda(month), rho_1(month) , rho_2(month))
    end
    fprintf(2,"day:%d \n",days);
    fprintf("\n mean: %.5f    |   %.5f    |   %.5f    |   %.5f    |   %.5f    |   %.5f    |   %.5f    |   %.5f    |   %.5f \n",mean(sigma_1), mean(sigma_2), mean(gamma_1), mean(gamma_2), mean(gamma_3), mean(p), mean(lambda), mean(rho_1) , mean(rho_2))
    
end


%% PLOT AFTER THE FITTING OPTIMIZATION
disp('PLOT AFTER THE FITTING')

%reset initial values to beginning ones
initstates=[59699728,200000,300000,Q_real(1),I1_real(1),I2_real(1),200000,10];

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

%load already optimized controls from disk
disp("CONTROL OPTIMIZATION")
if exist('OptControl.mat','file') && load_data_optimization
    load('OptControl.mat')
end

%fmincon options for optimization
options = optimoptions('fmincon',... %
        'Algorithm','interior-point', ... %default
        'MaxFunctionEvaluations',1e6, ...
        'MaxIterations',1e6, ... %'UseParallel',true,
        'OptimalityTolerance',1e-4);

%tranform in list the controls(fmincon better likes list than matrices) 
lb=zeros(weeks*4,1);
ub=zeros(weeks*4,1); %upperbound in contr
ub(:)=0.999;
ub(1:weeks)=1e-10;


%initial guess inputs(to list)
guess=zeros(weeks*4,1);
guess(1:weeks)=0.0;
guess(weeks+1:weeks*2)=0.3;
guess(weeks*2+1:weeks*3)=0.1;
guess(weeks*2+1:weeks*3)=1;


%get vaccine day index
if verLessThan('matlab','9.10')
    startSimDay='2020-12-27';
    fVD=find(ismember(cellfun(@(x) x(1:10),tableData.data,'UniformOutput',false),startSimDay));
else
    startSimDay=datetime('2020-12-27');
    fVD=find(ismember(tableData.data.Day,startSimDay.Day) & ...
        ismember(tableData.data.Month,startSimDay.Month) & ...
        ismember(tableData.data.Year,startSimDay.Year));
end
%first Vaccine Day 27 december
if days>fVD
    ub(ceil(fVD/7):weeks)=0.2;% ~ 120 mila vaccinazioni gg
    if days>(fVD+30)
        ub(ceil((fVD+30)/7):weeks)=1;
        %upperbound 600 mila vaccinazioni gg
    end
end

%constaint on sum of weeks controls (u_va*1<u_1*1<u_2*1<u_p*1) 
%#resources allocation
Acontrol=[eye(weeks)*1 eye(weeks)*1 eye(weeks)*1 eye(weeks)*1];
Bcontrol=ones(weeks,1)*2.5;


%% FIRST STRATEGY
%values to save plots to disk
controlPlot = zeros(1,4);

if optimization1
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
    [Icomp,ContrComp]=MixedPlotter(ufit,optu1,optu2,optu3,optu4);
end

%% Save some info

if save_info
    save ('OptParameters', 'sigma_1', 'sigma_2', 'gamma_1',...
        'gamma_2', 'gamma_3', 'p', 'rho_1', 'rho_2', ...
        'lambda', 'k','ufit');
    save ('OptControl','optu1','optu2','optu3','optu4','u');
    
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