%DATI REALI ITALIA 
% i dati con "*" sono stati estrapolati e non trovati direttamente
D_1970=52000; %*
D_1971=63409;
D_1972=49794;
D_1973=67620;
D_1974=24075;
D_1975=48000;% *
D_1976=53618;
D_1977=42112;
D_1978=66483;
D_1979=21000;%*
D_1980=27495;
D_1981=70926;
D_1982=20405;
D_1983=30938;
D_1984=73000;%*
D_1985=74728;
D_1986=21731;
D_1987=20000;%*
D_1988=88000;%*
D_1989=29373;
D_1990=5464;
D_1991=22917;
D_1992=63191;
D_1993=17409;
D_1994=6450;
D_1995=37131;
D_1996=31000;%*
D_1997=41254;
D_1998=4072;
D_1999=2908;%2000;%*
D_2000=1435;
D_2001=826;%1000;%*
D_2002=18025;
D_2003=11978;%8000;%*
D_2004=686;
D_2005=215;%500;%*
D_2006=571;
D_2007=595;%550;%*
D_2008=5311;
D_2009=759;%600;%*
D_2010=3064;%909; %W
D_2011=1905;%965; %W
D_2012=216;%389;%W
D_2013=1244;%2258;
D_2014=1016;%1696;
D_2015=168;%258;
D_2016=632;%844;
D_2017=4358;%4991;
D_2018=2081;%2526;
Dati_R=[D_1970 D_1971 D_1972 D_1973 D_1974 D_1975 D_1976 D_1977 D_1978 D_1979 D_1980 D_1981 D_1982 D_1983 D_1984 D_1985 D_1986 D_1987 D_1988 D_1989 D_1990...
    D_1991 D_1992  D_1993 D_1994 D_1995 D_1996 D_1997 D_1998 D_1999 D_2000 D_2001 D_2002 D_2003 D_2004 D_2005 D_2006 D_2007 D_2008 D_2009 D_2010 D_2011...
    D_2012 D_2013 D_2014 D_2015 D_2016 D_2017 D_2018];
save Dati_R Dati_R
%===============================
% %Dal 1985-2016
Copertura_Vax_da1985=[5 10 12 17 21 10 41 43 50 50 50 50 50 50 75 74.1 76.9 80.8 83.9 85.7 87.3 88.3 89.6 90.1 90 90.6 90.1 90 88.3 86.7 85.2 87.3];
Copertura_Vax=[ 10 12 17 21 10 41 43 50 50 50 50 50 50 75 74.1 76.9 80.8 83.9 85.7 87.3 88.3 89.6 90.1 90 90.6 90.1 90 88.3 86.7 85.2 87.3];

figure, bar(Copertura_Vax)
save Copertura_Vax Copertura_Vax
