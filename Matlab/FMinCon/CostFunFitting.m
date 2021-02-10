function J_fitting = CostFunFitting(parameters)

    global J_fitting
    global days
    global initstates
    global beta sigma_1 sigma_2
    beta = parameters(1);
    sigma_1 = parameters(2);
    sigma_2 = parameters(3);
    tableData = onlineData('dati_covid.csv', 'https://raw.githubusercontent.com/pcm-dpc/COVID-19/master/dati-andamento-nazionale/dpc-covid19-ita-andamento-nazionale.csv');
    sizeTable = size(tableData);
    
    %S_real = zeros(sizeTable(1),1);
%     S_real(1) = initstates(1);
%     for i=2:sizeTable(1)
%         S_real(i) = S_real(i-1)-tableData.nuovi_positivi(i);
%     end
    Q_real = tableData.isolamento_domiciliare(1:days,1);
    size(Q_real);
    I1_real = tableData.ricoverati_con_sintomi(1:days,1);
    I2_real = tableData.terapia_intensiva(1:days,1);
    save Q_real I1_real I2_real
    tspan = [1:1:days];
    opts = odeset('MaxStep',1);
    [t,x]=ode45(@CovidSimulator,tspan,initstates,opts);
    %StateVars = ['S', 'E', 'Ia', 'Q' ,'I1', 'I2' ,'R', 'V'];
    S_sim=x(:,1);
    Q_sim=x(:,4);
    I1_sim=x(:,5);
    I2_sim=x(:,6);
    
    time=t(:,1);
    J_fitting = (sum((Q_real-Q_sim).^2))/days+(sum((I1_real-I1_sim).^2))/days+(sum((I2_real-I2_sim).^2));
    %(sum((S_real-S_sim).^2))/days+
end

