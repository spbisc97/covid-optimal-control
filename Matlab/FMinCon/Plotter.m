function plotFigure=Plotter(Tile)

global initstates
global days


[t,x]=ode45(@CovidSimulator,[1 days],initstates);
if Tile~=true
    tiledlayout(4,1);
else
    tiledlayout(Tile)
end
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
plotFigure=gcf;
end