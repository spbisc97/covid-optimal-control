%MAIN  ODE
clear all
close all
clc
global d125 d3 d4
global b1 b2 b5
global beta
global delta4 
global gamma
global Dati_NV Norm Dati_Vax
global NV N n_R n_V m_V
global S1 S2 E I R
global delta1
global uV ci
global pp
global NT

%=======================================================
load VettoreparametriMODELLO
load Copertura_Vax
load Dati_R

VettoreparametriMODELLO
Datireali
NV=16;
pp=10; % dati che ci lasciamo per il TEST

%
d125=VettoreparametriMODELLO(1);
d3=VettoreparametriMODELLO(2);
d4=VettoreparametriMODELLO(3);
b1=VettoreparametriMODELLO(4);
b2=VettoreparametriMODELLO(5);
b5=VettoreparametriMODELLO(6);
beta=VettoreparametriMODELLO(7);
delta4=VettoreparametriMODELLO(8);
gamma=VettoreparametriMODELLO(9);
[MT,NT]=size(Dati_R);
Dati_Vax=Dati_R(NV+1:end-pp);
[m_V n_V]=size (Dati_Vax);

%
Norm=10^(-6);
%---condizioni iniziali--------------
ci=Norm*[50*10^6   10000   10    70000   10000 ]'; %condizioni inziali dello stato S1 S2 E I R
%
%===============ottimizzazione parametro delta1====================================
vettore1=1*ones(1,n_V); %delta1
vettoreParametri=vettore1
Um=0; %minimo
UM=0.8; %massimo
vettoreParametri0=1*vettore1; %VALORE INIZIALE 

Umin=Um*vettoreParametri;
Uin=vettoreParametri0';
Umax=UM*vettoreParametri;
%========================================================================================
%
LB=Umin;        %limite inferiore vettore parametri
UB=Umax;        %limite superiore vettore parametri
U0=Uin;         %condizione iniziale vettoreparametri
%
% ----------fmincon--------------------------------------------------------
%  parametri per fmincon
A=[];
B=[];
Aeq=[];
Beq=[];
options.MaxFunEvals=1000000;
options.TolFun=1e-10;
options.MaxIter=10000000;

[parametri, costo, exitflag, uscita, moltiplicatori] = fmincon('Indice_Costo_ODE_VAX',U0,A,B,[],[], LB, UB,[], options);
parametri;
delta1=parametri;


 VettoreparametriTOTALE=[d125 d3 d4 b1 b2 b5 beta delta1(end)  delta4  gamma]
 save VettoreparametriTOTALE  VettoreparametriTOTALE

%====================GRAFICI==============================================
Ireali=Norm*Dati_Vax; % DATI REALI

tempo=[1:n_V]

figure,
plot(tempo, S1,'b'), ylabel('S1- S2'), xlabel('t'),grid on
hold on
plot(tempo,S2,'r'), grid on
%
figure,plot(tempo, E), ylabel('E'), xlabel('t'),grid on
%
figure, plot(tempo, Ireali*10^6), ylabel('IrealiBLU- I sim rosso ')
hold on
plot(tempo, I*10^6, 'r')
%
figure, plot(tempo, R), title('rimossi')
PopTot=S1+S2+E+I+R;
figure, 
plot(tempo,PopTot), title ('popolazione totale'),
'tutte insieme'
figure,
plot(tempo, S1,'b'), ylabel('tutti'),
hold on
plot(tempo,S2,'r'), grid on
%
plot(tempo, E,'g'), 
plot(tempo, I, 'c')
 plot(tempo, R,'y'), 
PopTot=S1+S2+E+I+R;
 plot(tempo,PopTot,'*'),grid on
 figure, plot(tempo, delta1), title('controllo')
 'Indicatori'
S1Tot=sum(S1)
S2Tot=sum(S2)
ETot=sum(E)
ITot=sum(I)
RTot=sum(R)
UTOTALE=sum(delta1)
EE=[];
for ii=1: length(I)
errorePerc(ii)=(I(ii)-Ireali(ii))/Ireali(ii)
EE=[EE errorePerc(ii)]
end
sum(EE)

figure, bar( Dati_R(NV+1:end)*10^6)
[a b]=size(I)
errore=10^6*(Ireali'-I);
errore2=sqrt(errore'*errore)/a
sigma_errore=std(errore)
valmed_error=mean(errore)
