%StateVars = [S E Ia Q I1 I2 R V];
%Inputs = [u_va u_1 u_2 u_p];
u_va=1; u_1= 2;u_2= 3;u_p= 4;

%parameters = [beta 
%stati iniziali = [S E Ia Q I1 I2 R V];
initialstates=[59999728,200,4000,94,101,26,1,0];

days=300; %tempo di esecuzione in gg
inputs=zeros(4,days);
%parameters = zeros(
%here u can set specific imput changes with time
%inputs(u_p, 170) = 0.001;
inputs(u_1, 50) = 0.2;
inputs(u_2, 50) = 0.3;
inputs(u_va,260)=0.007;
%
CovidSim(initialstates',days,inputs)


