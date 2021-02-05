%StateVars = [S E Ia Q I1 I2 R V];
%Inputs = [u_va u_1 u_2 u_p];
u_va=1; u_1= 2;u_2= 3;u_p= 4;

 
%stati iniziali = [S E Ia Q I1 I2 R V];
initialstates=[59999728,200,4000,94,101,26,1,0];

days=300; %tempo di esecuzione in gg
inputs=zeros(4,1);
%here u can set specific imput changes with time
%inputs(u_p, 170) = 0.001;
%Inputs = [u_va u_1 u_2 u_p];
inputs(1)=0;inputs(2)=0.2;inputs(3)=0.15;inputs(4)=0.3;



% ObjectiveFn(initialstates',days,inputs)
options.MaxFunEvals=1000000;
options.TolFun=1e-10;
options.MaxIter=10000000;
lb=zeros(1,4);
ub=[0.9 0.9 0.9 0.9];
guess=[0.5 0.5 0.5 0.5];
%set constraints
%linear inequalities A*x ≤ b
A=[1 1 1 1];
b=[2];
[optu,fval]=fmincon(@ObjectiveFn,guess,A,b,[],[],lb,ub,[],options);