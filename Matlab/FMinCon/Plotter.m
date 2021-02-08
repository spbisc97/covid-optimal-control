function Plotter()



    [t,x]=ode45(@CovidSimulator,tspan,initstates,opts);


end