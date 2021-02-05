function J=ObjectiveFn(inputs)
    close all
    clc
    
    global b d1 d2 d3 d4 d5 d6 d7 d8 m
    global beta 
    global eta 
    global tau lambda k p
    global sigma_1 sigma_2 
    global gamma_1 gamma_2 gamma_3
    global rho_1 rho_2
    %syms lambda_1 lambda_2 lambda_3 lambda_4 lambda_5 lambda_6 lambda_7 lambda_8
    %syms S E Ia Q I1 I2 R V
    %syms alpha_1 delta_1 delta_2 delta_3 delta_4
    
    initstates=[59999728,200,4000,94,101,26,1,0];

    days=100;
    
    
    d1=0.01;d2=0.01;d3=0.01;d4=0.01;d5=0.01;d6=0.01;d7=0.01;d8=0.01;b=10000;m=0.001;
    
    beta=0.000000008;
    eta=0.01; %~circa 100 giorni
    tau=0.07; %inverso tempo medio insorgenza sintomi
    lambda=0.06; %valore medio nuovi positivi
    k=0.06; %inverso tempo medio periodo incubazione 12-14 giorni circa
    p=0.2; %percentuale persone in isolamento domiciliare rispetto alla percentuale
        %positivi in ospedale 
    sigma_1=0.08; sigma_2 = 0.05 ;%sigma_2=0.01;
    gamma_1=0.03;gamma_2=0.03;gamma_3=0.02;
    rho_1=1;rho_2=1;
    
    


    
    %time=linspace(1,days,days);
    tspan=[1 days];
    %opzioni di ode step massimo di integrazione =1
    opts = odeset('MaxStep',1);
    
    global u
    u=inputs;
    
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
    
    J=-1*(sum(s)+(u*u')*days);
    
    
    end
    
    