function J=Objective4Fn(input)
global initstates;
global OptFunVal;
global days;
global u Functionals
weeks=ceil((days)/7);
%time=linspace(1,days,days);
tspan=[1 days];
opts = odeset('MaxStep',1);

% put Ucontrols in matrix form again
Ucol=[eye(weeks) zeros(weeks) zeros(weeks) zeros(weeks)];
u=[Ucol*input, circshift(Ucol,[0 weeks])*input, circshift(Ucol,[0 weeks*2])*input, circshift(Ucol,[0 weeks*3])*input ];


[t,x]=ode45(@CovidSimulator,tspan,initstates,opts);
%StateVars = ['S', 'E', 'Ia', 'Q' ,'I1', 'I2' ,'R', 'V'];
% s=x(:,1);
% e=x(:,2);
% ia=x(:,3);
% q=x(:,4);
% i1=x(:,5);
% i2=x(:,6);
% r=x(:,7);
v=x(:,8);
% time=t(:,1);

%funzione di costo

J=-1*(sum(v)*1e-3)+sum(u)*(eye(4).*[0.3 0.2 0.4 0.1])*sum(u)';
if Functionals(4) ~= "-1*(sum(v)*1e-3)+sum(u)*(eye(4).*[0.3 0.2 0.4 0.1])*sum(u)'"
    Functionals(4) = "-1*(sum(v)*1e-3)+sum(u)*(eye(4).*[0.3 0.2 0.4 0.1])*sum(u)'";
end


len = length(OptFunVal(:,5));
OptFunVal(len+1,5)=J;

end

