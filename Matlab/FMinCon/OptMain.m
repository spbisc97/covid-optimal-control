close all
clear
% clc
%% Setup and Parameters
%suppress warning for too near constraints
warning ('off','all');

%load alredy optimized data
load_data_fitting=0; %true/false 1/0
load_data_optimization=0;
save_info=0;

fitting=1;

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

days=252; %tempo di esecuzione in gg


tableData = onlineData('dati_covid.csv', 'https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-andamento-nazionale/dpc-covid19-ita-andamento-nazionale.csv');
%get data from "Presidenza del Consiglio dei Ministri - Dipartimento della Protezione Civile"

%global u_va u_1 u_2 u_p
OptFunVal=zeros(1,6);
Functionals=["" "" "" "" ""];
Population=60000000;
Deaths2019=647000;
d=(Deaths2019/Population)/365;

d1=d;d2=d;d3=d;d4=d;d5=d;d6=d;d7=d;d8=0;
b=1180; m=0.09;



beta=6e-10;   %(rt/(6e7*variazione media positivi( media=1.98e+03 ))
eta=0;  %0.005; %~circa 240 giorni ~8 mesi
tau=0.2; %inverso tempo medio insorgenza sintomi (dopo incubazione non contagiosa)= 5gg
k=0.3; %inverso tempo medio periodo incubazione (non contagiosa) 3/4 giorni circa


%stati iniziali = [S E Ia Q I1 I2 R V];

weeks=ceil((days)/7); %tempo di esecuzione in settimane(controlli)
months=ceil((days)/month_dur); %tempo di esecuzione in mesi(parametri)


% inputs = [u_va u_1 u_2 u_p];
u = zeros(weeks,4);

for i=1:1:length(u(:,1))
    u(i,1) = 0;
    u(i,2) = 0.5;
    u(i,3) = 0.6;
    u(i,4) = 0.4;
  if ( 110<(i-0.5)*7 )<160
     u(i,4) = 0.4; 
  end
  
  
end


lambda=ones(months,1)*0.01; %valore medio nuovi positivi
p=ones(months,1)*0.95; %percentuale(guess) persone in isolamento domiciliare rispetto alla percentuale positivi in ospedale
sigma_1=ones(months,1)*0.09; sigma_2 = ones(months,1)*0.1; %guess tassi complicanza
gamma_1=ones(months,1)*0.009;gamma_2=ones(months,1)*0.08;gamma_3=ones(months,1)*0.07; %guarigione spontanea da Ia Q I1
rho_1=ones(months,1)*0.8;rho_2=ones(months,1)*0.7; % tassi di successo



%% Get The Real Data

%data starts from june -> move to S for better realistic data
initday=find(ismember(cellfun(@(x) x(1:10),tableData.data,'UniformOutput',false),'2020-06-23'));
tableData(1:initday,:)=[];

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

%% Set Vaccine control

%set vaccine 10 days after initday
fVD=find(...
    ismember(cellfun(@(x) x(1:10),tableData.data,'UniformOutput',false)...
    ,'2021-01-06'));  %first Vaccine Day 27 december+ 10 days
if days>fVD
    u(ceil(fVD/7):weeks,1)=0.02;% ~ 12 mila vaccinazioni gg
    if days>(fVD+30)
        u(ceil((fVD+30)/7):weeks,1)=0.09;%~ 54 mila vaccinazioni gg
    end
end


%% PARAMETERS FITTING (beta, sigma1, sigma2)
disp("PARAMETERS FITTING")
descr=["From " tableData.data(1) "to" tableData.data(days)];
disp(join(descr));
if exist('OptParameters.mat','file') && load_data_fitting
    load('OptParameters.mat') %if fitting already there, less computation time getting faster to optimum
    u=ufit;
end

initstates=[59699728,40000,60000,Q_real(1),I1_real(1),I2_real(1),50000,10];

if fitting
    
    opts = optimoptions('fmincon',... %
        'Algorithm','interior-point', ... %default
        'MaxFunctionEvaluations',1e7, ...
        'MaxIterations',1e7, ... %'UseParallel',true,
        'OptimalityTolerance',1e-4);
    
    %     options.MaxFunEvals=1e7;
    %     options.TolFun=1e-7;
    %     options.MaxIter=1e7;
    for month = 1:months
        
        fguess=[sigma_1(month), sigma_2(month), gamma_1(month), gamma_2(month), gamma_3(month), p(month), lambda(month), rho_1(month) , rho_2(month)];
        lb= [0.0001,0.001 ,0.00001,0.0001,0.0001, 0.86,0.001,  0.001,0.001];
        ub=[0.1,0.2 ,0.5,0.2,0.4, 0.96,0.9,   0.8,0.9];
        disp(join(["fitting on month:", month]));
        fprintf("with control weeks: ");
        for elem = (ceil(((month-1)*month_dur+1)/7)):1:(ceil(month*month_dur/7))
            if elem <= weeks
                fprintf(" %d ",elem);
                lb=[lb,0.55,0.45,0.25];% u1  u2  up
                ub=[ub,0.8,0.7,0.9];% u1  u2  up
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
        [optPar,fval]=fmincon(@CostFunFitting,fguess,A_ineq,B_ineq,[],[],lb,ub,[],opts); %options
        initstates=future_initstates;
    end
    
    
    ufit=u;
    
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
initstates=[59699728,40000,60000,Q_real(1),I1_real(1),I2_real(1),50000,10];

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


options = optimoptions('fmincon',... %
    'Algorithm','interior-point', ... %default
    'MaxFunctionEvaluations',1e6, ...
    'MaxIterations',1e6, ... %'UseParallel',true,
    'OptimalityTolerance',1e-4);

%tranform in array
lb=ones(weeks*4,1)*1e-13;
ub=ones(weeks*4,1)*0.999; %upperbound in contr %ub(:)=0.999;
ub(1:weeks)=1e-10;



guess=zeros(weeks*4,1);%guess iniziali inputs
guess(1:weeks)=1e-10;
guess(weeks+1:weeks*2)=0.3;
guess(weeks*2+1:weeks*3)=0.1;
guess(weeks*2+1:weeks*3)=1;


fVD=find(...
    ismember(cellfun(@(x) x(1:10),tableData.data,'UniformOutput',false)...
    ,'2020-12-27'));
%first Vaccine Day 27 december
if days>fVD
    ub(ceil(fVD/7):weeks)=0.2;% ~ 120 mila vaccinazioni gg
    if days>(fVD+30)
        ub(ceil((fVD+30)/7):weeks)=1;
        %upperbound 600 mila vaccinazioni gg
    end
end


Acontrol=[eye(weeks)*1 eye(weeks)*1 eye(weeks)*1 eye(weeks)*1];
% constaint on sum of weeks controls (u_va*1<u_1*1<u_2*1<u_p*1)<

Bcontrol=ones(weeks,1)*2.5;


%% FIRST STRATEGY
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