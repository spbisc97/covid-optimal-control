function dZdt =Modello_ODE_M_VAX(tempoODE, Z)

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

Z1=Z(1);
Z2=Z(2);
Z3=Z(3);
Z4=Z(4);
Z5=Z(5);
tempoODE

for ii=1:n_V
    if   (ii-1<=tempoODE) && (tempoODE <ii)
        u=uV(ii);
    end
end
if   tempoODE >=n_V
        u=uV(n_V);
end
% u=uV(1)


% if tempoODE <=1
%     'u1'
%     u=uV(1);
% end
% if 1<tempoODE <=2
%     'u2'
%     u=uV(2);
% end
% 
% if 2<tempoODE <=3
%     'u3'
%     u=uV(3);
% end
% if 3<tempoODE<=4
%     u=uV(4);
% end
% if 4<tempoODE<=5
%     u=uV(5);
% end
% if 5<tempoODE<=6
%     u=uV(6);
% end
% if 6<tempoODE<=7
%     u=uV(7);
% end
% if 7<tempoODE<=8
%     u=uV(8);
% end
% if 8<tempoODE<=9
%     u=uV(9);
% end
% if 9<tempoODE<=10
%     u=uV(10);
% end
% if 10<tempoODE<=11
%     u=uV(11);
% end
% if 11<tempoODE<=12
%     u=uV(12);
% end
% if 12<tempoODE<=13
%     u=uV(13);
% end
% if 13<tempoODE<=14
%     u=uV(14);
% end
% if 14<tempoODE<=15
%     u=uV(15);
% end
% if 15<tempoODE<=16
%     u=uV(16);
% end
% if 16<tempoODE<=17
%     u=uV(17);
% end
% if 17<tempoODE<=18
%     u=uV(18);
% end
% if 18<tempoODE<=19
%     u=uV(19);
% end
% if 19<tempoODE<=20
%     u=uV(20);
% end
% if 20<tempoODE<=21
%     u=uV(21);
% end
% if 21<tempoODE<=22
%     u=uV(22);
% end
% if 22<tempoODE<=23
%     u=uV(23);
% end
% %%pp=10
% if 23<tempoODE<=24
%     u=uV(24);
% end
% if 24<tempoODE<=25
%     u=uV(25);
% end
% if 25<tempoODE<=26
%     u=uV(26);
% end
% if 26<tempoODE<=27
%     u=uV(27);
% end
% if 27<tempoODE<=28
%     u=uV(28);
% end
% 
% %pp=1
% if 28<tempoODE<=29
%     u=uV(29);
% end

%=============================================================
dZdt1=b1-d125*Z1-beta*Z1*Z4-u*Z1; %S1

dZdt2=b2-d125*Z2-beta*Z2*Z4; %S2

dZdt3=-d3*Z3+beta*Z1*Z4+beta*Z2*Z4-delta4*Z3;  %E

dZdt4=-d4*Z4+delta4*Z3-gamma*Z4; %I
 
dZdt5=b5-d125*Z5+gamma*Z4+u*Z1;  %R

dZdt=[dZdt1 dZdt2 dZdt3 dZdt4 dZdt5]';
