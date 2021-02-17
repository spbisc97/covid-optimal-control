close all
clc
%% Setup and Parameters
%load alredy optimized data
load_data=false;


%model parameters covid
global b d1 d2 d3 d4 d5 d6 d7 d8 m
global beta
global eta
global tau lambda k p
global sigma_1 sigma_2
global gamma_1 gamma_2 gamma_3
global rho_1 rho_2
global OptFunVal
global initstates
global days
global u
%global u_va u_1 u_2 u_p
OptFunVal=zeros(1,2);
days=240; %tempo di esecuzione in gg
weeks=ceil((days)/7);

d1=0.01;d2=0.01;d3=0.01;d4=0.01;d5=0.01;d6=0.01;d7=0.01;d8=0;
b=1180; m=0.09;

beta=2.5e-8;   %(60 000 000 * rt )
eta=0.01; %~circa 100 giorni
tau=0.1; %inverso tempo medio insorgenza sintomi
lambda=zeros(weeks,1);
lambda(:)=0.01; %valore medio nuovi positivi
k=zeros(weeks,1);
k(:)=0.4; %inverso tempo medio periodo incubazione (non contagiosa) 5 giorni circa
p=zeros(weeks,1);
p(:)=0.8; %percentuale persone in isolamento domiciliare rispetto alla percentuale positivi in ospedale

sigma_1=zeros(weeks,1);
sigma_1(:)=0.09;

sigma_2=zeros(weeks,1); 
sigma_2(:)= 0.1;

gamma_1=zeros(weeks,1);
gamma_1(:)=0.09;

gamma_2=zeros(weeks,1);
gamma_2(:)=0.08;

gamma_3=zeros(weeks,1);
gamma_3(:)=0.07;

rho_1=1;rho_2=1;
%u_va=0;u_1=0.2;u_2=0.15;u_p=0.3;

% global inputs
% inputs = [u_va u_1 u_2 u_p];
%stati iniziali = [S E Ia Q I1 I2 R V];

initstates=[59699728,120000,200000,16000,900,60,400000,0];
% scale = 1e-8;
% initstates = zeros(1, 8);
% initstates(2) = vpa(200*scale);
% initstates(3) = vpa(4000*scale);
% initstates(4) = vpa(94*scale);
% initstates(5) = vpa(101*scale);
% initstates(6) = vpa(26*scale);
% initstates(7) = vpa(1*scale);
% initstates(1) = 1 - initstates(2)-initstates(3)-initstates(4)-initstates(5)-initstates(6)-initstates(7)




u = zeros(weeks,4);
u(:,1) = 0;
u(:,2) = 0.4;
u(:,3) = 0.4;
u(:,4) = 0.3;

%first csv day 2020-02-24T18:00:00 ---30*4
if weeks>19
u(14:19,4) = 0.5;
end
if weeks>19
u(22:25,4) = 0.8;
end
if weeks>15
u(15:weeks,2) = 0.6;
end
if weeks>22
u(22:weeks,3) = 0.6;
end

%here u can set specific imput changes with time
%inputs(u_p, 170) = 0.001;
%Inputs = [u_va u_1 u_2 u_p];
%ObjectiveFn(initialstates',days,inputs)

%% PLOT BEFORE THE OPTIMIZATION
%figure
%Plotter()


%% Get The Real Data
tableData = onlineData('dati_covid.csv', 'https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-andamento-nazionale/dpc-covid19-ita-andamento-nazionale.csv');
%get data from "Presidenza del Consiglio dei Ministri - Dipartimento della Protezione Civile"
%deta starts from February -> move to S for better realistic data
tableData(1:(30*4),:)=[];
global Q_real I1_real I2_real
Q=tableData.isolamento_domiciliare(1:days,1);
I1=tableData.ricoverati_con_sintomi(1:days,1);
I2=tableData.terapia_intensiva(1:days,1);
Q_real = smooth(Q);
I1_real = smooth(I1); 
I2_real = smooth(I2);
if size(Q_real)< days
    disp("Not enough real data!",size(Q_real),'<',days)
    quit(1)
end

%% Plot Real Data
disp("Plot Real Data")
tiledlayout(3,1)
nexttile();
plot((1:1:days),0);
nexttile();
plot((1:1:days),Q_real,"m");
hold;
plot((1:1:days),Q,".");
title("In isolamento");
legend('Q');
nexttile();
plot((1:1:days),I1_real,"b",(1:1:days),I2_real,"r");
hold;
plot((1:1:days),I1,".",(1:1:days),I2,".");
title("Ospedalizzati e in terapia intensiva");
legend( 'I1', 'I2');
set(gcf, 'Position',  [50, 50, 900, 620])

pause(2)

%% PARAMETERS FITTING (beta, sigma1, sigma2)
disp("PARAMETERS FITTING")
if exist('OptParameters.mat') && load_data %#ok<EXIST>
    load('OptParameters.mat')
end
% opts = optimoptions('fmincon',...
%     'Algorithm','interior-point', ... %default
%     'MaxFunctionEvaluations',1000000000, ...
%     'MaxIterations',10000000000, ... %'UseParallel',true,
%     'FunctionTolerance',1e-13);
options.MaxFunEvals=10000000;
options.TolFun=1e-5;
options.MaxIter=10000000;
lb=ones(weeks,1)*[0.00001,0.00001 ,0,0.001,0.001, 0.3,0.001,0.1];
ub=ones(weeks,1)*[0.1,0.1 ,1,0.1,0.9, 0.99,0.7,0.8];
guess= [sigma_1, sigma_2, gamma_1, gamma_2, gamma_3, p, lambda, k];
% for elem = 1:1:weeks
%     len=length(lb);
%     lb(len+1:len+3)=[0,0,0];
%     ub(len+1:len+3)=[0.9,0.9,0.9];
%     guess(len+1:len+3)=u(elem,2:4);
% end
[optPar,fval]=fmincon(@CostFunFitting,guess,[],[],[],[],lb,ub,[],options);
save ('OptParameters', 'sigma_1', 'sigma_2', 'gamma_1', 'gamma_2', 'gamma_3', 'p', 'rho_1', 'rho_2', 'lambda', 'k','u');
disp('sigma_1, sigma_2, gamma_1, gamma_2, gamma_3, p, rho_1, rho_2, lambda, k, u');
disp(optPar);


%% PLOT AFTER THE OPTIMIZATION
disp('PLOT AFTER THE FITTING')
figure
fittingPlot=Plotter();

pause(2)
%% OPTIMIZATION
if exist('OptControl.mat') && load_data %#ok<EXIST>
    load('OptControl.mat')
end
disp('CONTROL OPTIMIZATION')
options.MaxFunEvals=1000000;
options.TolFun=1e-9;
options.MaxIter=10000000;
lb=zeros(weeks,4);
ub=zeros(weeks,4);
ub(:,:)=1;
guess=zeros(weeks,4);%guess iniziali inputs
guess(:,:)=0.5;
[optu,fval]=fmincon(@ObjectiveFn,guess,[],[],[],[],lb,ub,[],options);
disp('u_va u_1 u_2 u_p');
disp(optu);

%% PLOT AFTER THE OPTIMIZATION

disp('PLOT AFTER OPTIMIZATION')
figure;
controlPlot=Plotter();

%% Save some info
%for later
save ('OptParameters', 'sigma_1', 'sigma_2', 'gamma_1',...
 'gamma_2', 'gamma_3', 'p', 'rho_1', 'rho_2', ...
'lambda', 'k');
save ('OptControl', 'u');
%forever
pos='Vars/';
place=strcat(pos,datestr(now));
para=strcat(place,'-Parameters.mat');
save (para, 'sigma_1', 'sigma_2', 'gamma_1', ...
'gamma_2', 'gamma_3', 'p', 'rho_1', 'rho_2', 'lambda', 'k','u' ...
);
image=strcat(place,'-Fitting.png');
saveas(fittingPlot,image);
image2=strcat(place,'-Control.png');
saveas(controlPlot,image2);



