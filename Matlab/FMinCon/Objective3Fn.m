function J=Objective3Fn(input)
    global initstates;
    global OptFunVal;
    global days;
    global u Functionals
    
    %time=linspace(1,days,days);
    tspan=[1 days];
    %opzioni di ode step massimo di integrazione =1
    opts = odeset('MaxStep',1);
    
    u=input;
    
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
    
    J=-0.9*(sum(s))+0.9*(sum(i1))+0.9*(sum(i2))+1e-3*sum(u)*sum(u)';
if Functionals(4) ~= "-0.9*(sum(s))+0.9*(sum(i1))+0.9*(sum(i2))+1e-3*sum(u)*sum(u)'"
    Functionals(4) = "-0.9*(sum(s))+0.9*(sum(i1))+0.9*(sum(i2))+1e-3*sum(u)*sum(u)'";
end
    
    
    len = length(OptFunVal(:,4));
    OptFunVal(len+1,4)=J;
    
    end
    
    