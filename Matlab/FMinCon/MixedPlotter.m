function [Icomp,ContrComp] = MixedPlotter(Fit,Opt1,Opt2,Opt3,Opt4)
%compare strategies

global initstates
global days
global u
opts = odeset('MaxStep',1);


u=Fit;
[t,F]=ode45(@CovidSimulator,1:1:days,initstates,opts);
F(:,end+1)=t;

u=Opt1;
[t,O1]=ode45(@CovidSimulator,1:1:days,initstates,opts);
O1(:,end+1)=t;

u=Opt2;
[t,O2]=ode45(@CovidSimulator,1:1:days,initstates,opts);
O2(:,end+1)=t;

u=Opt3;
[t,O3]=ode45(@CovidSimulator,1:1:days,initstates,opts);
O3(:,end+1)=t;

u=Opt4;
[t,O4]=ode45(@CovidSimulator,1:1:days,initstates,opts);
O4(:,end+1)=t;


%% I_1 I_2 Comparison

fig1=figure('Name','Optimization over I_1 I_2 Comparison');
tiledlayout(2,1);

nexttile(1);
plot(F(:,end),F(:,5),'Linestyle','--','Color','#0072BD','LineWidth',1.5);
hold on
plot(O1(:,end),O1(:,5),'Color','#D95319','LineWidth',1.5);
hold on
plot(O2(:,end),O2(:,5),'Color','#EDB120','LineWidth',1.5);
hold on
plot(O3(:,end),O3(:,5),'Color','#7E2F8E','LineWidth',1.5);
hold on
plot(O4(:,end),O4(:,5),'Color','#77AC30','LineWidth',1.5);
hold on
legend('Fit','Opt1','Opt2','Opt3','Opt4');
legend('Location','bestoutside');
title('Hospedalized non IC');

nexttile(2);
plot(F(:,end),F(:,6),'Linestyle','--','Color','#0072BD','LineWidth',1.5);
hold on
plot(O1(:,end),O1(:,6),'Color','#D95319','LineWidth',1.5);
hold on
plot(O2(:,end),O2(:,6),'Color','#EDB120','LineWidth',1.5);
hold on
plot(O3(:,end),O3(:,6),'Color','#7E2F8E','LineWidth',1.5);
hold on
plot(O4(:,end),O4(:,6),'Color','#77AC30','LineWidth',1.5);
hold on
legend('Fit','Opt1','Opt2','Opt3','Opt4');
legend('Location','bestoutside');
title('Hospedalized IC');

set(gcf,'Position', get(0, 'ScreenSize')./2);

Icomp=gcf;
%% Control Strategies Comparison

fig2=figure('Name','Control Strategies Comparison');
tiledlayout(4,1);

nexttile(1);
stairs(Fit(:,1),'Linestyle','--','Color','#0072BD','LineWidth',1.5);
hold on
stairs(Opt1(:,1),'Color','#D95319','LineWidth',1.5);
hold on
stairs(Opt2(:,1),'Color','#EDB120','LineWidth',1.5);
hold on
stairs(Opt3(:,1),'Color','#7E2F8E','LineWidth',1.5);
hold on
stairs(Opt4(:,1),'Color','#77AC30','LineWidth',1.5);
hold on
legend('Fit','Opt1','Opt2','Opt3','Opt4');
legend('Location','bestoutside');
title('Vaccine Control');

nexttile(2);
stairs(Fit(:,2),'Linestyle','--','Color','#0072BD','LineWidth',1.5);
hold on
stairs(Opt1(:,2),'Color','#D95319','LineWidth',1.5);
hold on
stairs(Opt2(:,2),'Color','#EDB120','LineWidth',1.5);
hold on
stairs(Opt3(:,2),'Color','#7E2F8E','LineWidth',1.5);
hold on
stairs(Opt4(:,2),'Color','#77AC30','LineWidth',1.5);
hold on
legend('Fit','Opt1','Opt2','Opt3','Opt4');
legend('Location','bestoutside');
title('Hospedalized non IC Control');

nexttile(3);
stairs(Fit(:,3),'Linestyle','--','Color','#0072BD','LineWidth',1.5);
hold on
stairs(Opt1(:,3),'Color','#D95319','LineWidth',1.5);
hold on
stairs(Opt2(:,3),'Color','#EDB120','LineWidth',1.5);
hold on
stairs(Opt3(:,3),'Color','#7E2F8E','LineWidth',1.5);
hold on
stairs(Opt4(:,3),'Color','#77AC30','LineWidth',1.5);
hold on
legend('Fit','Opt1','Opt2','Opt3','Opt4');
legend('Location','bestoutside');
title('Hospedalized IC Control');

nexttile(4);
stairs(Fit(:,4),'Linestyle','--','Color','#0072BD','LineWidth',1.5);
hold on
stairs(Opt1(:,4),'Color','#D95319','LineWidth',1.5);
hold on
stairs(Opt2(:,4),'Color','#EDB120','LineWidth',1.5);
hold on
stairs(Opt3(:,4),'Color','#7E2F8E','LineWidth',1.5);
hold on
stairs(Opt4(:,4),'Color','#77AC30','LineWidth',1.5);
hold on
legend('Fit','Opt1','Opt2','Opt3','Opt4');
legend('Location','bestoutside');
title('Preventive Control');
set(gcf,'Position', get(0, 'ScreenSize')./[1 1 2 1]);

ContrComp=gcf;
end

