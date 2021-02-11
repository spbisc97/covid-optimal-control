function Plotter()

global initstates
global days

[t,x]=ode45(@CovidSimulator,[1 days],initstates);

tiledlayout(3,1)
nexttile();
plot(t,x(:,1));
legend('S');
title('Persone non ancora infette');
nexttile();
plot(t,[x(:,2) x(:,3) x(:,4) x(:,7) x(:,8)])
legend( 'E', 'Ia', 'Q' ,'R', 'V', 'Location', 'northwest');
title('Esposti, Infetti asintomatici, quar., guariti, vacc.')
nexttile();
plot(t,[x(:,5) x(:,6)])
title('Infetti ospedalizzati ed interapia intensiva');
legend('I1', 'I2', 'Location', 'northwest');
set(gcf, 'Position',  [800, 50, 900, 920])

end