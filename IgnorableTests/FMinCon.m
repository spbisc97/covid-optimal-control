% funzione obiettivo
objective = @(x) x(1)*x(4)*(x(1)+x(2)+x(3))+x(3);

%guess iniziale 
x0=[1,5,5,1];
%print on screen
disp(['initial Objective: ' num2str(objective(x0))])

%set constraints
%linear inequalities A*x ≤ b. x0 
A=[];
b=[];
%linear equalities Aeq*x = beq 
Aeq=[];
beq=[];


%lower and upper bound for x
lb=1.0* ones(4);
ub=5.0* ones(4);

%subjects the minimization to the 
%nonlinear inequalities c(x) or equalities ceq(x) defined in nlcon
nonlincon = @nlcon;


if true 
    options = optimoptions('fmincon','Display','iter','Algorithm','sqp');
    [x,fval,exitflag,output,lambda,grad,hessian]=fmincon(objective,x0,A,b,Aeq,beq,lb,ub,nonlincon,options);
else
    x=fmincon(objective,x0,A,b,Aeq,beq,lb,ub,'nlcon');
end
disp(x)

disp(['Final Objective: ' num2str(objective(x))])

[c,ceq] = nlcon (x)
