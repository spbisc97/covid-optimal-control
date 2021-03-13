function plotFigure=Plotter(Tile)

global initstates
global days
global u


[t,x]=ode45(@CovidSimulator,[1 days],initstates);
if Tile~=true
    tiledlayout(5,1);
else
    tiledlayout(Tile)
end
nexttile(1);
plot(t,x(:,1),'LineWidth',1.5);
legend('S');
title('Persone non ancora infette');


nexttile(2);
plot(t,[x(:,2) x(:,3) x(:,7) x(:,8)],'LineWidth',1.5)
legend( 'E', 'Ia','R', 'V', 'Location', 'northwest');
title('Esposti, Infetti asintomatici, guariti, vacc.')


nexttile(3);
plot(t,x(:,4),'LineWidth',1.5)
legend( 'Q');
title('Quarantena')

nexttile(4);
plot(t,[x(:,5) x(:,6)],'LineWidth',1.5)
title('Infetti ospedalizzati ed interapia intensiva');
legend('I1', 'I2', 'Location', 'northwest');

udays=zeros(days,4);
for i=1:1:days
    w=ceil(i/7);
    udays(i,:)=u(w,:);
end

nexttile(5);
plot(1:1:days,[udays(:,1),udays(:,2),udays(:,3),udays(:,4)],'LineWidth',1.5)
legend('U_v', 'U_1','U_2', 'U_p');
set(gcf,'Position',  get(0, 'ScreenSize')./[1 1 2 1]);
plotFigure=gcf;

end