$TITLE Pump scheduling smallest 
$ontext
version: 2.0
author of this version: sofdem@gmail.com
characteristics: 9-period model for free GAMS version
$offtext

*$offlisting
* stops the echo print of the input file
*$offsymxref
* stops the print of a complete cros-reference list of symbols
*option limcol = 0;
* stops the print of the column listing
*option limrow = 0;
* stops the print of the equation listing
*option solprint = off;
* stop report solution

Sets 
     n          nodes      / s, j1, j2, r1, r2, r3, r4 /
     j(n)       junctions  / j1, j2 /
     r(n)       reservoirs / r1, r2, r3, r4 /
     l(n,n)     pipes      / s.j1, j1.j2, j1.r1, j1.r4, j2.r2, j2.r3 /
     t          1-hour periods / t1*t9 /
     night(t)   night periods  / t1*t4 /      
     c          pump class   / small /
     d          pump number  / p1*p3 /
     k(c,d)     pump type    / small.p1*p3 /
     degree     polynomial degrees / 0*2 /
     

     alias (n,np)      
     alias (k,kp)
     alias (d,dp)
     alias (t,tp);

Scalar
     height0      reference height at the source (m)      / 0 /
     tariffnight  electricity hourly tariff at night (euro.kWh^-1)  / 0.02916 /
     tariffday    electricity hourly tariff at day (euro.kWh^-1)    / 0.04609 /

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

Table demand(r,t) demand in water at each reservoir each hour (m^3)
     t1     t2    t3    t4     t5     t6    t7      t8      t9
r1   9.83   5.0   3.67  6.5    5.67   7.5   3.0     3.0     2.0
r2   44.83  18.0  0.0   0.0    0.0    0.0   0.0     45.0    51.67
r3   14.0   13.33 25.5  11.0   10.0   10.0  11.0    10.33   30.17
r4   1.0    1.0   8.5   9.5    4.0    2.33  0.0     1.0     0.83

Table phi(n,n,degree) quadratic fit of the pressure loss (m) on the flow (m^3.h^-1) for each pipe
                2               1
     s.j1       0.00005425      0.00038190  
     j1.j2      0.00027996      0.00149576
     j1.r1      0.00089535      0.00340436
     j1.r4      0.00044768      0.00170218  
     j2.r2      0.00223839      0.00851091
     j2.r3      0.00134303      0.00510655;

Positive Variable
    qkt(c,d,t) D�bit d_eau pomp� par la pompe k � la p�riode t
    qrt(r,t) D�bit entrant dans chaque r�servoir r � la p�riode t
    qlt(n,n,t)  d�bit en pipe l au temps t 
    vrt(r,t) Volume d_eau dans les r�servoirs r � la p�riode t
    pkt(c,d,t) Puissance de la pompe k � la p�riode t;

Binary Variable
    xkt(c,d,t) Pompe k allum� � la p�riode t, sinon 0 ;
     
free variable
    z Co�t total ;


Equations
    cost    definition de la fonction objective
    flow(t)   conservation du flow � chaque temps t
    volumes_min(r,t)   volumes min � chaque temps t et pour chaque r�servoir r
    volumes_max(r,t)  volumes max � chaque temps t et pour chaque r�servoir r
    debits_min (c,d,t)   d�bits min pour chaque temps t et pour chaque pompe k (ssi la pompe k est allum�e)
    debits_max (c,d,t)   d�bits max pour chaque temps t et pour chaque pompe k (ssi la pompe k est allum�e)
    puissances(c,d,t)   puissances de chaque pompe � chaque temps t et pour chaque pompe k
    demandes(r,t,t)   demandes pour chaque temps t et pour chaque r�servoir r (aussi conservation du flow dans chaque tank);
    
    
cost ..        z  =e=  sum((k,t),pkt(k,t) * tariff(t)) ;
flow(t) ..     sum((k), qkt(k,t))  =e=  sum((r), qrt(r,t)) ;
volumes_min(r,t) .. vmin(r)  =l=  vrt(r,t)  ;
volumes_max(r,t) .. vrt(r,t)  =l=  vmax(r);
debits_min(k(c,d),t) .. xkt(k,t)*0  =l=  qkt(k,t)   ;
debits_max(k(c,d),t) .. qkt(k,t)  =l=  xkt(k,t) * 99 ;
puissances(k(c,d),t) .. pkt(k,t) =e= gamma(c,'0')*xkt(k,t) + gamma(c,'1')*qkt(k,t) ;
demandes(r,t,tp) .. vrt(r,t) + qrt(r,t) =e= vrt(r,tp) + demand(r,t) ;

Model Planification /all/;

Solve Planification using mip minimizing z ;

Display 'vinit', vinit;
