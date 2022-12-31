$Title Pump Scheduling 4WT

Sets 
     n          nodes       / s, j1, j2, r1, r2, r3, r4 /
     j(n)       junctions   / j1, j2 /
     r(n)       reservoirs  / r1, r2, r3, r4 /
     l(n,n)     pipes       / s.j1, j1.j2, j1.r1, j1.r4, j2.r2, j2.r3 /
     t          1-hour periods  / t1*t24 /
     night(t)   night periods   / t1*t8 /      
     c          pump class    / small /
     d          pump number   / p1*p3 /
     k(c,d)     pump type     / small.p1*p3 /
     degree     polynomial degrees / 0*2 /

     alias (n,np)
     alias (k,kp)
     alias (d,dp);

Scalar
     height0      reference height at the source (m)     / 0 /
     tariffnight  electricity hourly tariff at night (euro.kWh^-1) / 0.02916 /
     tariffday    electricity hourly tariff at day (euro.kWh^-1)   / 0.04609 /

Parameter tariff(t)   electricity tariff;
    tariff(t)        = tariffday;
    tariff(night(t)) = tariffnight;

Parameters
    height(n)   elevation at each node relative to s (m)
                / s 0, j1 30, j2 30, r1 50, r2 50, r3 45, r4 35 /

    surface(r)  mean surface of each reservoir (m^2)
                / r1 80, r2 80, r3 80, r4 80 /

    vmin(r)     minimal volume of each reservoir (m^3)
                / r1 100, r2 100, r3 100, r4 100 /

    vmax(r)     maximal volume of each reservoir (m^3)
                / r1 300, r2 300, r3 300, r4 300 /

Parameter vinit(r) initial volume of each reservoir;
    vinit(r) = vmin(r);

* a polynomial is represented as the list of coefficients for each term degree
Table psi(c,degree) quadratic fit of the service pressure (m) on the flow (m^3.h^-1) for each class of pumps
                  0              1            2
      small       63.0796        0            -0.0064085;

Table gamma(c,degree) linear fit of the electrical power (kW) on the flow (m^3.h^-1) for each class of pumps
                  0              1
      small       3.81101     0.09627;

Table demand(r,t) demand in water at each reservoir and each hour (m^3)
     t1     t2    t3    t4     t5     t6    t7      t8      t9     t10   t11   t12   t13    t14    t15   t16   t17   t18   t19   t20   t21   t22   t23   t24
r1   9.83   5.0   3.67  6.5    5.67   7.5   3.0     3.0     2.0    13.5  14.0  12.0  12.0   12.0   12.0  12.83 15.67 13.17 12.0  10.0  11.0  14.0  19.5  10.17
r2   44.83  18.0  0.0   0.0    0.0    0.0   0.0     45.0    51.67  0.0   0.0   0.0   15.17  103.83 34.83 43.83 54.83 51.17 53.5  0.67  0.0   0.0   1.5   53.5
r3   14.0   13.33 25.5  11.0   10.0   10.0  11.0    10.33   30.17  17.67 36.33 38.0  35.0   35.17  19.33 31.83 23.5  16.83 28.0  33.5  39.0  38.5  32.67 29.67
r4   1.0    1.0   8.5   9.5    4.0    2.33  0.0     1.0     0.83   2.0   2.0   2.0   2.0    2.0    2.0   3.0   2.0   1.0   2.0   3.0   2.0   3.0   3.0   2.0;

Table phi(n,n,degree) quadratic fit of the pressure loss (m) on the flow (m^3.h^-1) for each pipe
                2               1
     s.j1       0.00005425      0.00038190  
     j1.j2      0.00027996      0.00149576
     j1.r1      0.00089535      0.00340436
     j1.r4      0.00044768      0.00170218  
     j2.r2      0.00223839      0.00851091
     j2.r3      0.00134303      0.00510655;
      
Positive Variable
    qkt(c,d,t) Débit d_eau pompé par la pompe k à la période t
    qrt(r,t) Débit entrant dans chaque réservoir r à la période t
    qlt(n,n,t)  débit en pipe l au temps t 
    vrt(r,t) Volume d_eau dans les réservoirs r à la période t
    pkt(c,d,t) Puissance de la pompe k à la période t
    charge(n,t) Charge à chaque noeud j à la période t;

Binary Variable
    xkt(c,d,t) Pompe k allumé à la période t, sinon 0; 
     
free variable
    z Coût total ;

Equations
    cost    definition de la fonction objective
    flow_s(t)   conservation du flow entre les pompes et la source à chaque temps t
    flow_r(t,n)   conservation du flow à chaque temps t
    flow_j(t,n)   conservation du flow à chaque temps t
    volumes_min(r,t)   volumes min à chaque temps t et pour chaque réservoir r
    volumes_max(r,t)  volumes max à chaque temps t et pour chaque réservoir r
    demandes_t1(r)   demandes pour t1 et pour chaque réservoir r
    demandes(r,t)   demandes pour chaque temps t et pour chaque réservoir r (aussi conservation du flow dans chaque tank)
    debits_min (c,d,t)   débits min pour chaque temps t et pour chaque pompe k (ssi la pompe k est allumée)
    debits_max (c,d,t)   débits max pour chaque temps t et pour chaque pompe k (ssi la pompe k est allumée)
    puissances(c,d,t)   puissances de chaque pompe à chaque temps t et pour chaque pompe k
    gain_de_charge(c,d,t)   charge en s égale au gain de charge des pompes de toutes classes pour tout t
    perte_de_charge_j (n,n,t)    charge en j égale à la perte de charge des canalisations pour tout t et tous noeuds
    perte_de_charge_r (n,n,t)    charge en j égale à la perte de charge des canalisations pour tout t et tous noeuds
    charge_r(r,t)   charge en r pour tout t
    symetrie_1(c,d,c,d,t)  Supprimer les symétries de pompes;
    
    
    
cost ..        z  =e=  sum((k,t),pkt(k,t) * tariff(t)) ;
flow_s(t) ..     sum((k), qkt(k,t))  =e=  sum(l('s',np), qlt(l,t)) ;
flow_r(t,r(n)) ..     sum(l(np,n), qlt(l,t))  =e=  qrt(r,t) ;
flow_j(t,j(n)) ..     sum(l(np,n), qlt(l,t))  =e=  sum(l(n,np), qlt(l,t)) ;
volumes_min(r,t) .. vmin(r)  =l=  vrt(r,t)  ;
volumes_max(r,t) .. vrt(r,t)  =l=  vmax(r);
demandes_t1(r)  .. vinit(r) + qrt(r,'t1') =e= vrt(r,'t1') + demand(r,'t1') ;
demandes(r,t) $(ord(t) gt 1) .. vrt(r,t-1) + qrt(r,t) =e= vrt(r,t) + demand(r,t) ;
debits_min(k(c,d),t) .. xkt(k,t)*0  =l=  qkt(k,t)   ;
debits_max(k(c,d),t) .. qkt(k,t)  =l=  xkt(k,t) * 99.21 ;
puissances(k(c,d),t) .. pkt(k,t) =e= gamma(c,'0')*xkt(k,t) + gamma(c,'1')*qkt(k,t) ;
gain_de_charge(k(c,d),t) .. charge('s',t)*xkt(k,t) =e= psi('small','0')*xkt(k,t)+psi('small','2')*(qkt(k,t)*qkt(k,t));
perte_de_charge_j(l(n,j(np)),t) .. charge(n,t) - charge(np,t)  =g= phi(l,'1')*qlt(l,t) + phi(l,'2')*(qlt(l,t)*qlt(l,t)) ;
perte_de_charge_r(l(n,r(np)),t) .. charge(n,t) - charge(np,t) - height(r) =g= phi(l,'1')*qlt(l,t) + phi(l,'2')*(qlt(l,t)*qlt(l,t)) ;
charge_r(r,t)..  charge(r,t) =e= vrt(r,t) / surface(r);
symetrie_1(k(c,d),kp(c,d+1),t)  .. xkt(kp,t) =l= xkt(k,t);


Model Planification /all/;

Solve Planification using minlp minimizing z ;