function J=ObjectiveFn(input)
  
    

    
    global initstates;

    global days;
    


    
    %time=linspace(1,days,days);
    tspan=[1 days];
    %opzioni di ode step massimo di integrazione =1
    opts = odeset('MaxStep',1);
    
    global u
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
    
    %plotta il tutto 
%     tiledlayout(3,1)
%     nexttile();
%     plot(t,s);
%     legend('S');
%     title('Persone non ancora infette');
%     nexttile();
%     plot(t,[e ia q r v])
%     legend( 'E', 'Ia', 'Q' ,'R', 'V');
%     title('Esposti, Infetti asintomatici, quar., guariti, vacc.')
%     nexttile();
%     plot(t,[i1 i2])
%     title('Infetti ospedalizzati ed interapia intensiva');
%     legend('I1', 'I2');
    
    
    %display(x)
    %legend('S', 'E', 'Ia', 'Q' ,'I1', 'I2' ,'R', 'V');
    %display(T)
    
%     set(gcf, 'Position',  [550, 50, 700, 720])
    global J
    J=-1*(sum(s/(1e6))*days)+sum(u)*sum(u)';
    
    end
    
    