function J=Indice_Costo_SOLO_VAX(parametri)

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

%======================================================
delta1=parametri';
% size(delta1)
% pause

uV=delta1;

'dentro indice costo'

tspan=[0 n_V];
dZdt=zeros(1,5);

Z0=ci;
[tempoODE Z]=ode45('Modello_ODE_M_VAX', tspan, Z0);
global t=tempoODE;

S1=Z(:,1);
S2=Z(:,2);
E=Z(:,3);
I=Z(:,4);
R=Z(:,5);
Isim=I;          

%========estrapolazione vettore tempo
[mt nt]=size(tempoODE);
%mt=righe di tempoODE
tempodatireali=[1:n_V];
global TempiReali=tempodatireali;
dist=[];
for ii=1:n_V
    for jj=1:mt
        dist=[dist; abs(tempoODE(jj)-tempodatireali(ii))];
    end
end
DistVett=reshape(dist,mt,n_V)
global DistanzeVettore = DistVett;
[a,b]=min(DistVett)

Z=Z(b,:)

%================================DATI==============================================
Dati_NV; 
Ireali=Norm*Dati_Vax;     % DATI REALI
size(Z);
S1=Z(:,1);
S2=Z(:,2);
E=Z(:,3);
I=Z(:,4);
R=Z(:,5);
Isim=I;          
figure, plot(S1)
hold on
plot(S2,'r')
plot(I,'g')

close all
save S1 S1
save S2 S2
save E E
save I I
save R R
% DATI SIMULATI
%==========================INDICE COSTO====================================

'indice costo'
size(I);
size(Ireali);

errore=I(1:end)'-Ireali(1:end);

p1=0.01; %p1=0.01 fitting perfetto- delta1 meno
p2=1-p1;

%errorepop=sum(S1+S2+E+I+R)-sum(Z0)*ones(1,NV);
J=p1*max(abs(errore*errore'))+p2*sqrt((errore)*(errore)')%+0.5*(p1*max(abs(errorepop*errorepop'))+p2*sqrt(errorepop*errorepop'))%J=J1+J2