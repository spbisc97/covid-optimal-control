function J=ObjectiveFn(input)
global initstates;
global days;
global u
global OptFunVal Functionals
weeks=ceil((days)/7);
%time=linspace(1,days,days);
tspan=[1 days];
%opzioni di ode step massimo di integrazione =1
opts = odeset('MaxStep',1);

% put Ucontrols in matrix form again
Ucol=[eye(weeks) zeros(weeks) zeros(weeks) zeros(weeks)];
u=[Ucol*input, circshift(Ucol,[0 weeks])*input, circshift(Ucol,[0 weeks*2])*input, circshift(Ucol,[0 weeks*3])*input ];

[t,x]=ode45(@CovidSimulator,tspan,initstates,opts);
%StateVars = ['S', 'E', 'Ia', 'Q' ,'I1', 'I2' ,'R', 'V'];
s=x(:,1);
e=x(:,2);
ia=x(:,3);
q=x(:,4);
i1=x(:,5);
i2=x(:,6);
r=x(:,7);
v=x(:,8);
time=t(:,1);

%funzione di costo
% sum(s) integrale da 1 a days , sum(u) integrale da 1 a days/7 (weeks)

J=-2*(sum(s).*6e-7)+sum(u)*(eye(4).*[0.3 0.2 0.4 0.1])*sum(u)';

if Functionals(2) ~= "-3*(sum(s).*1e-6)+sum(u)*(eye(4).*[0.3 0.2 0.4 0.1])*sum(u)'"
    Functionals(2) = "-3*(sum(s).*1e-6)+sum(u)*(eye(4).*[0.3 0.2 0.4 0.1])*sum(u)'";
end

len = length(OptFunVal(:,2));
OptFunVal(len+1,2)=J;

end

