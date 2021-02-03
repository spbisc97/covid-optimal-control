close all
clc
%Popolazione italiana
popolazione=60e6;

%parametro di integrazione
%discretizzazione del sistema continuo (per poterne calcolare l'evoluzione numericamente) secondo il metodo di Eulero
%time-step
step = 0.4;
tempoMax= 120;
t = 1:step:tempoMax;

%-------------------------------------------------------------------------
%------------------------------ DATI REALI -------------------------------
%-------------------------------------------------------------------------


%persone in isolamento domiciliare (Q)
real_Q = [94	162	221	284	412	543	798	927	1000	1065	1155	1060	1843	2180	2936	2599	3724	5036	6201	7860	9268	10197	11108	12090	14935	19185	22116	23783	26522	28697	30920	33648	36653	39533	42588	43752	45420	48134	50456	52579	55270	58320	60313	61557	63084	64873	66534	68744	71063	72333	73094	74696	76778	78364	80031	80589	80758	81104	81510	81710	82286	82212	82722	83504	83619	83652	81708	81796	81808	81436	81678	80770	74426	73139	72157	69974	68679	67950	67449	65392	64132	60470	59012	57278	55597	54422	52452	51051	49770	48485	47428	46574	44504	42732	40118	38606	36561	35275	34844	33569	33202	32588	31359	30582	30111	29718	28028	27141	26270	24877	23518	22471	22213	21091	20649	20066	18750	18586	18510	18472];
real_Qt = transpose(real_Q);

%ricoverati con sintomi (I1)
real_I1 = [101	114	128	248	345	401	639	742	1034	1346	1790	2394	2651	3557	4316	5038	5838	6650	7426	8372	9663	11025	12894	14363	15757	16020	17708	19846	20692	21937	23112	24753	26029	26676	27386	27795	28192	28403	28540	28741	29010	28949	28976	28718	28485	28399	28242	28144	27847	28023	28011	27643	26893	25786	25007	25033	24906	24134	23805	22871	22068	21533	21372	20353	19723	19210	18149	17569	17357	17242	16823	16270	15769	15174	14636	13834	13618	13539	12865	12172	11453	10792	10400	10311	10207	9991	9624	9269	8957	8695	8613	8185	7917	7729	7379	7094	6680	6387	6099	5916	5742	5503	5301	5002	4864	4729	4581	4320	4131	3893	3747	3594	3489	3301	3113	2867	2632	2474	2314	2038];
real_I1t = transpose(real_I1);

%ricoverati in terapia intensiva (I2)
real_I2 = [26	35	36	56	64	105	140	166	229	295	351	462	567	650	733	877	1028	1153	1328	1518	1672	1851	2060	2257	2498	2655	2857	3009	3204	3396	3489	3612	3732	3856	3906	3981	4023	4035	4053	4068	3994	3977	3898	3792	3693	3605	3497	3381	3343	3260	3186	3079	2936	2812	2733	2635	2573	2471	2384	2267	2173	2102	2009	1956	1863	1795	1694	1578	1539	1501	1479	1427	1333	1311	1168	1034	1027	999	952	893	855	808	775	762	749	716	676	640	595	572	553	541	521	505	489	475	450	435	424	408	353	338	316	293	287	283	263	249	236	227	220	209	207	177	163	168	161	152	148	127];
real_I2t = transpose(real_I2);


%-------------------------------------------------------------------------
%----------   VETTORI PER L'EVOLUZIONE NEL TEMPO DELLE VARIABILI ---------
%-------------------------------------------------------------------------

S = zeros(1, length(t));
E = zeros(1, length(t));
A = zeros(1, length(t));
Q = zeros(1, length(t));
I1 = zeros(1, length(t));
I2 = zeros(1, length(t));
R = zeros(1, length(t));
M = zeros(1, length(t));
T = zeros(1, length(t));


%-------------------------------------------------------------------------
%-------------------------- CONDIZIONI INIZIALI --------------------------
%-------------------------------------------------------------------------
E(1) = 50;  
A(1) = 4324; 
Q(1) = 94;
I1(1) = 101;
I2(1) = 26;
R(1) = 1;
S(1) = popolazione - E(1)- Q(1) - I1(1) - I2(1) - R(1);
M(1) = 0;
T(1) = 0;


%-------------------------------------------------------------------------
%---------------------- PARAMETRI FISSI NEL TEMPO -------------------------
%-------------------------------------------------------------------------

beta = 0.000000008;
c= 1;
d1 = 0.011;     %tasso di mortalità di S
b = S(1)*d1;    %numero di persone in ingresso al compartimento S
d2 = 0.018;     %tasso di mortalità di E
d3 = 0.019;     %tasso di mortalità di A
d4 = 0.02;      %tasso di mortalità di Q
d5 = 0.05;      %tasso di mortalità di I1
d7 = 0.009;     %tasso di mortalità di R
d6 = 0.03;
tau1 = 0.2;     %inverso del tempo medio per l'insorgenza dei sintomi
tau2 = 0.25;    %inverso del tempo medio per l'esito del tampone
k = 0.2;        %inverso del tempo medio trascorso dai soggetti nel compartimento E 
         
%-------------------------------------------------------------------------
%---------------------- PARAMETRI VARIABILI NEL TEMPO --------------------
%-------------------------------------------------------------------------

gamma1 = 0;     %tasso di guarigione senza controlli specifici per infetti in isolamento domiciliare 
gamma2 = 0;     %tasso di guarigione senza controlli specifici per infetti ospedalizzati 
u_p = 0;        %controllo preventivo (distanza sociale, igiene delle mani ecc...)
u_Ta = 0.02;    %controllo riguardante il tampone
u_1 = 0.004;    %controllo riguardante cure a casa
u_2 = 0.005;    %controllo riguardante cure in ospedale no in terapia intensiva
u_3 = 0.006;    %controllo riguardante cure in ospedale in terapia intensiva
rho1 = 1;       %peso del controllo u_1
rho2 = 1;       %peso del controllo u_2
rho3 = 1;       %peso del controllo u_3
p = 0.2;        %percentuale persone in isolamento domiciliare rispetto i nuovi casi positivi, 
                
theta = 0.03;   %percentuale di test
lambda = 0.015; %percentuale di tesi positivi
sigma1 = 0.3;   %tasso di complicanza della malattia
m = 0.001;      %tasso di mortalità a causa della malattia

disp('%%%%%%%%%%%%%%%% VALORE DEL NUMERO DI RIPRODUZIONE DI BASE, R0 %%%%%%%%%%%%%%%%')
R0 = (beta*b)/(d1*(d2+k))

%-------------------------------------------------------------------------
%------------------------------ SIMULAZIONE ------------------------------
%-------------------------------------------------------------------------

for i=1:length(t)-1
  
     if (i>=7/step) && (i<14/step)
       gamma1 = 0; 
       gamma2 = 0;
        u_p = 0;  
        u_Ta = 0.03; 
        u_1 = 0.04;  
        u_2 = 0.005;  
        u_3 = 0.006;  
        p = 0.2; 
        theta = 0.05;  
        lambda = 0.03; 
        m = 0.001;
     end
     
     if (i>=14/step) && (i<21/step)
        u_p = 0.01;  
        u_Ta = 0.04; 
        u_1 = 0.004;  
        u_2 = 0.005;  
        u_3 = 0.006;  
        p = 0.4; 
        theta = 0.05;  
        lambda = 0.04; 
        m = 0.13; %le morti sono aumentate vertiginosamente
     end
     
     if (i>=21/step) && (i<28/step)   %lockdown  
        u_Ta = 0.05; 
        u_2 = 0.009;  
        u_3 = 0.01;  
        theta = 0.06; 
        rho2 = 10;  
        lambda = 0.05; 
        m = 0.16; 
     end
     
     
     if (i>=28/step) && (i<33/step)
        gamma1 = 0.002; 
        gamma2 = 0.001;
        u_p = 0.1;  
        u_Ta = 0.05; 
        u_1 = 0.03;  
        u_2 = 0.035;  
        u_3 = 0.05;  
        p = 0.6; 
        theta = 0.06; 
        rho2 = 8;  
        rho3 = 1;
        tau2 = 0.25;           
        sigma1 = sigma1+0.01; 
        lambda = 0.052; 
        m = m+0.01; 
     end
     
     if (i>=33/step) && (i<35/step)
        gamma1 = 0.002; 
        gamma2 = 0.001;
        u_p = 0.1;  
        u_Ta = 0.05; 
        u_1 = 0.03;  
        u_2 = 0.045;  
        u_3 = u_3+0.002;  
        p = 0.6; 
        theta = 0.06; 
        rho2 = 10; 
        rho3 = 3;
        tau2 = 0.25;           
        sigma1 = sigma1+0.05; 
        lambda = 0.054; 
        m = m+0.04;
     end
     
     if (i>=35/step) && (i<40/step)
       beta = 0.0000000045;
       gamma1 = 0.002; 
       gamma2 = 0.001;
        u_p = 0.2;  
        u_Ta = 0.05; 
        u_1 = 0.04;  
        u_2 = 0.05;  
        u_3 = 0.06;  
        p = 0.65; 
        theta = 0.07;            
        sigma1 = sigma1-0.006; 
        lambda = 0.052; 
     end
     if (i>=40/step) && (i<42/step) %i primi risultati del lockdown si iniziano a vedere ora, controllo u_p aumenta molto
        u_p = 0.4;  
        u_Ta = u_Ta+0.002; 
        u_1 = 0.045;  
        u_3 = 0.051;  
        p = 0.6; 
        theta = theta+0.002;            
        sigma1 = sigma1-0.006; 
        m = 0.47; 
     end
     
     if (i>=42/step) && (i<46/step)  
        u_Ta = u_Ta+0.002; 
        u_1 = 0.045;    
        u_3 = 0.051;  
        p = 0.6; 
        theta = theta+0.002; 
        gamma1 = 0.02;           %aumentano persone che guariscono anche senza controlli
        rho1 = 3;          
        lambda = 0.08;
        m = 0.45;
     end
     
     if (i>=46/step) && (i<51/step)
        u_p = 0.55;  
        u_Ta = u_Ta+0.002; 
        u_1 = 0.05;  
        u_2 = 0.051;  
        u_3 = 0.052;   
        theta = theta+0.002; 
        rho1 = 4.4; 
        sigma1 = sigma1-0.001;  
        m = m-0.008;
     end
     if (i>=51/step) && (i<56/step)
        u_p = 0.6;  
        u_Ta = u_Ta+0.002;  
        u_1 = 0.05;  
        u_2 = 0.051;  
        u_3 = 0.065;  
        p = 0.6; 
        theta = theta+0.002; 
        gamma1 = 0.1;  
        rho1 = 4.3;  
        rho3 = 3.2;         
        lambda = lambda-0.0015;  %diminuiscono i positivi in relazione al numero di tamponi effettuati
                                 %il tasso di complicanza si inizia a stabilizzare anche grazie agli effetti
                                 %del controllo u_2 che evitano che le persone vadano in I2     
     end
     if (i>=56/step) && (i<63/step) 
        u_Ta = u_Ta+0.002; 
        u_1 = 0.05;  
        u_2 = 0.05;  
        u_3 = 0.065;  
        theta = theta+0.003;   
        gamma1 = 0.11;  
        rho1 = 4.35;  
        rho3 = 3.2;            
        lambda = lambda-0.0015;  
        m = m-0.001;
            
     end
     
     if (i>=63/step) &&(i<67/step)
        u_p = u_p-0.05;             %inizia a diminuire controllo preventivo 
        u_Ta = u_Ta+0.002; 
        u_1 = 0.045;  
        theta = theta+0.003;
        gamma1 = 0.14;  
        rho1 = 3.5;    
        rho2 = 9; 
        rho3 = 3.6;
        sigma1 = sigma1-0.01;
        lambda = lambda-0.0012;  
        m = m-0.007;                
        
     end
     
     if (i>=67/step) && (i<69/step)
        u_Ta = u_Ta+0.002;   
        u_1 = 0.03;  
        u_2 = 0.05;  
        u_3 = 0.055;  
        theta = theta+0.003;
        gamma1 = 0.12;  
        rho1 = 3;     
        sigma1 = sigma1-0.01;
        lambda = lambda-0.0012;  
        m = m-0.007;  
        
     end
     if (i>=69/step) && (i<74/step)
        gamma1 = 0.15;  
        gamma2 = 0.001;
        lambda = 0.014; 
     end
     if (i>=74/step) && (i<80/step)
         u_1 = 0.02;  
        u_2 = 0.05;  
        u_3 = 0.055;  
        gamma2 = 0.01;
        rho1 = 2.5;    
        lambda = 0.011;
     end
     if (i>=80/step) && (i<87/step)
        u_Ta = u_Ta+0.002; 
         u_1 = 0.035;  
        u_2 = 0.06;  
        u_3 = 0.06;  
        rho1 = 3;    
        rho2 = 10; 
        lambda = 0.01;
        
     end
     
     if (i>=87/step) && (i<94/step)
        u_Ta = u_Ta+0.002; 
         u_1 = u_1+0.003;  
        u_2 = u_2+0.002;  
        u_3 = u_3+0.001;  
     end
     
     if (i>=94/step) && (i<105/step)
        u_Ta = u_Ta+0.002; 
        u_2 = u_2+0.003;  
        gamma1 = gamma1+0.007;
     end
     
     if (i>=105/step) && (i<120/step)
        u_Ta = u_Ta+0.002; 
        u_1 = u_1+0.0025;  
        u_2 = u_2+0.005;  
        gamma1 = gamma1+0.005;  
        rho3 = 4;
     end
     
    T(i+1) = i;
    S(i+1) = S(i)+step*(b-(+d1+beta*E(i)*(1-c*u_p)+c*theta*u_Ta)*S(i)+c*(1-lambda)*tau2*A(i)); 
    E(i+1) = E(i)+step*(beta*E(i)*(1-c*u_p)*S(i)-(d2+c*theta*tau1*u_Ta+k)*E(i)); 
    A(i+1) = A(i)+step*(c*theta*u_Ta*S(i)+c*theta*tau1*u_Ta*E(i)-c*(1-lambda)*tau2*A(i)-d3*A(i)-c*lambda*tau2*A(i));
    Q(i+1) = Q(i)+step*(c*p*lambda*tau2*A(i)-(d4+gamma1+c*rho1*u_1)*Q(i));
    I1(i+1) = I1(i)+step*(k*E(i)+c*(1-p)*lambda*tau2*A(i)-(d5+gamma2+c*rho2*u_2+sigma1)*I1(i));
    I2(i+1) = I2(i)+step*(sigma1*I1(i)-(m+d6+c*rho3*u_3)*I2(i)); 
    R(i+1) = R(i)+step*((gamma1+c*rho1*u_1)*Q(i)+(gamma2+c*rho2*u_2)*I1(i)+rho3*u_3-d7*R(i));
    M(i+1) = M(i)+step*(m*I2(i)); 
    
    
    
   
end    


Q_trasp = transpose(Q);
I1_trasp = transpose(I1);
I2_trasp = transpose(I2);
infected = [Q_trasp I1_trasp I2_trasp];


%-------------------------------------------------------------------------
%------------------- VISUALIZZAZIONE SIMULAZIONE -------------------------
%-------------------------------------------------------------------------



subplot(3,1,1),stem(1:120,real_Q, 'Color','red', 'MarkerEdgeColor','white');
xlim([t(1) t(end)])
hold on
plot(t,Q, '- k','linewidth',2)
title('Infetti in isolamento domiciliare: dati reali vs dati stimati');
legend('infetti isol.dom.reali', 'infetti isol.dom.stimati','Location','northeast'); 
grid on;
xlabel('tempo, t'); 
ylabel('Casi in isolamento domiciliare');


subplot(3,1,2),stem(1:120,real_I1, 'Color','red', 'MarkerEdgeColor','white');
xlim([t(1) t(end)])
hold on;
plot(t,I1, '- k','linewidth',2)
title('Infetti ospedalizzati: dati reali vs dati stimati');
legend('infetti ospedalizzati reali', 'infetti ospedalizzati stimati','Location','northeast'); 
grid on;
xlabel('tempo, t'); 
ylabel('Casi Infetti ospedalizzati');



subplot(3,1,3),stem(1:120,real_I1, 'Color','red', 'MarkerEdgeColor','white');
xlim([t(1) t(end)])
hold on;
plot(t,I2, '- k','linewidth',2);
title('Infetti TI: dati reali vs dati stimati');
legend('infetti TI reali', 'infetti TI stimati','Location','northeast'); 
grid on;
xlabel('tempo, t'); 
ylabel('Casi infetti in TI');

set(gcf, 'Position',  [550, 50, 700, 720])
