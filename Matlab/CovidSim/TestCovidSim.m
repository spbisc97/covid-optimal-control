%StateVars = [S E Ia Q I1 I2 R V];
%Inputs = [u_va u_1 u_2 u_p];
u_va=1;u_1=2;u_2=3;u_p=4;

initialstates=[55000000,100000,100000,100000,700,40,800000,0];

days=100;
inputs=zeros(4,days);
%here u can set specific imput changes with time
inputs(u_va,50)=0.2;
%
CovidSim(initialstates',days,inputs)


