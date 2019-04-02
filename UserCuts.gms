$Title UserCuts

***************************************************************
*** PARAMETERS
***************************************************************

$include Input_Data.gms

***************************************************************
*** VARIABLES
***************************************************************

variable obj objective function variable

variable c_aux(t) auxilliary variable

variable c(t,i) operation cost in each time period

positive variable g(t,i) generator outputs

positive variable g_lin(t,i,b) generator block outputs

binary variable suc(t,i,j) start up cost

variable pf(t,l) power flow through lines

variable pfk(t,l,ll) power flow through lines under contingency k

binary variable x(t,i) binary variable equal to 1 if generator is producing, and 0 otherwise

binary variable y(t,i) binary variable equal to 1 if generator is start-up, and 0 otherwise

binary variable z(t,i) binary variable equal to 1 if generator is shut-down, and 0 otherwise

positive variable ul(t, s) unserved load

variable Pnet(t,s) total power in bus s at time t

***************************************************************
*** EQUATION DECLARATION
***************************************************************

equations

cost objective function
cost_aux(t) auxilliary equation
bin_set1(t,i) setting start-up binary variables
bin_set10(t,i) setting start-up binary variables
bin_set2(t,i) setting start-up binary variables
gen_sum(t,i) summing the generation of blocks per generator
gen_min(t,i) genertor minimum output
cost_sum(t,i) generation cost summation
block_output(t,i,b) limiting the output of each generator block
min_updown_1(t,i) minimum updown time constraint 1
min_updown_2(t,i) minimum updown time constraint 2
min_updown_3(t,i) minimum updown time constraint 3
ramp_limit_min(t,i) ramp-down limit
ramp_limit_max(t,i) ramp-up limit
ramp_limit_min_1(i) ramp-down limit for the first time period
ramp_limit_max_1(i) ramp-up limit for the first time period
start_up_cost1(t,i,j) stairwise linear cost function - equation 1
start_up_cost2(t,i) stairwise linear cost function - equation 2

net_power(t,s) net power in bus whitout line flows generation minus load
power_balance2(t) power balance in every period of time

line_flow(t,l) defining power flow through lines

line_flow_k(t,l,ll) defining power flow through lines in contingency k
line_flow_k_min(t,l,ll) restricts the minimun power flow through line in contingency k
line_flow_k_max(t,l,ll) restricts the maximum power flow through line in contingency k

;

***************************************************************
*** SETTINGS
***************************************************************

*needed for running twice through the same set in a single equation
alias (t,tt), (l, ll);

***************************************************************
*** EQUATIONS
***************************************************************

cost..
         obj =e= sum(t, c_aux(t)) + sum((t, s), ul(t, s))*1000;

cost_aux(t)..
         c_aux(t) =e= sum(i, c(t, i))
;

bin_set1(t, i)$(ord(t) gt 1)..
         y(t, i) - z(t,i) =e= x(t, i) - x(t-1, i)
;

bin_set10(t, i)$(ord(t) = 1)..
         y(t, i) - z(t,i) =e= x(t, i) - onoff_t0(i)
;

bin_set2(t, i)..
         y(t, i) + z(t, i) =l= 1
;

cost_sum(t, i)..
         c(t, i) =e= a(i)*x(t, i) + sum(b,g_lin(t, i, b)*k(i, b)) + sum(j, suc_sw(i, j)*suc(t, i, j))
;

gen_sum(t, i)..
         g(t, i) =e= sum(b,g_lin(t, i, b))
;

gen_min(t, i)..
         g(t, i) =g= g_min(i)*x(t, i)
;

block_output(t, i, b)..
         g_lin(t, i, b) =l= g_max(i, b)*x(t, i)
;

min_updown_1(t, i)$(L_up_min(i)+L_down_min(i) gt 0 and ord(t) le L_up_min(i)+L_down_min(i))..
         x(t, i) =e= onoff_t0(i)
;

min_updown_2(t,i)..
         sum(tt$(ord(tt) ge ord(t)-g_up(i)+1 and ord(tt) le ord(t)),y(tt, i)) =l= x(t, i)
;

min_updown_3(t,i)..
         sum(tt$(ord(tt) ge ord(t)-g_down(i)+1 and ord(tt) le ord(t)),z(tt,i)) =l= 1-x(t, i)
;

ramp_limit_min(t,i)$(ord(t) gt 1)..
         -ramp_down(i) =l= g(t, i) - g(t-1, i)
;

ramp_limit_max(t, i)$(ord(t) gt 1)..
         ramp_up(i) =g= g(t, i) - g(t-1, i)
;

ramp_limit_min_1(i)..
         -ramp_down(i) =l= g('t1', i) - g_0(i)
;

ramp_limit_max_1(i)..
         ramp_up(i) =g= g('t1', i) - g_0(i)
;

start_up_cost1(t, i, j)..
         suc(t, i, j) =l= sum(tt$(ord(tt) lt ord(t) and ord(tt) ge suc_sl(i, j) and ord(tt) le suc_sl(i, j+1)-1),z(t-ord(j), i))
                 + 1$(ord(j) lt card(j) and count_off_init(i)+ord(t)-1 ge suc_sl(i, j) and count_off_init(i)+ord(t)-1 lt suc_sl(i, j+1))
                 + 1$(ord(j) = card(j) and count_off_init(i)+ord(t)-1 ge suc_sl(i, j))
;

start_up_cost2(t, i)..
         sum(j, suc(t, i, j)) =e= y(t, i)
;

net_power(t, s)..
         Pnet(t, s) =e= sum(i$(gen_map(i,s)),g(t,i)) - d(t,s) + ul(t, s)${d(t, s) gt 0}
;

power_balance2(t)..
         sum(s, Pnet(t,s)) =e= 0
;

line_flow(t, l)..
         pf(t, l) =e= sum(s,ptdf(l, s)*Pnet(t, s))
;

********************************************************************************
** Flow limits for normal operation
********************************************************************************

pf.lo(t, l)=-l_max(l)*line_capacity;
pf.up(t, l)= l_max(l)*line_capacity;

********************************************************************************
** Flow limits under contingencies
********************************************************************************

parameter ContBin(t, l, ll) 'Biinary matrix for restriction registration';
ContBin(t, l, ll) = 0;

line_flow_k(t, l, ll)$(ContBin(t, l, ll) ne 0)..
         pfk(t, l, ll) =e= pf(t, l) + lodf(l, ll)*pf(t, ll);

line_flow_k_min(t, l, ll)$(ContBin(t, l, ll) ne 0)..
         pfk(t, l, ll) =g= -l_max(l)*line_capacity;

line_flow_k_max(t, l, ll)$(ContBin(t, l, ll) ne 0)..
         pfk(t, l, ll) =l= l_max(l)*line_capacity;

***************************************************************
*** SOLVE AND USER CUTS
***************************************************************

parameters
overLoad(t, l, ll) 'Overflow matrix'
sumOverLoad 'Total overload from overflow matrix'
tol 'stop criteria (1e-6 = 1W)' /1e-6/
;

MODEL userCuts /all/;

file opt cplex option file /cplex.opt/;
put opt;
put 'threads 0'/;
put 'miptrace _UC_deterministic_4_04_0.csv'/;
putclose;
userCuts.optfile = 1

option
         reslim = 1200,
         Savepoint = 1,
         optcr = 0.005,
         solveopt = replace,
         limrow = 0,
         limcol = 0
;

* Loop to compute the mandatory restriction to be added

repeat(
         overLoad(t, l, ll) = 0;

         Solve userCuts us mip min obj;

         ContBin(t, l, ll)$[((abs[pf.l(t, l) + lodf(l, ll)*pf.l(t, ll)]) ge l_max(l)*line_capacity )] = 1;

         overLoad(t, l, ll)$[((abs[pf.l(t, l) + lodf(l, ll)*pf.l(t, ll)]) ge l_max(l)*line_capacity )] = {(abs[pf.l(t, l) + lodf(l, ll)*pf.l(t, ll)])} - {l_max(l)*line_capacity};

         sumOverLoad = sum((t, l, ll) ,overLoad(t, l, ll));

         display  sumOverLoad, overLoad, ContBin, obj.l;

Until sumOverLoad lt tol);

* Aditional calculations for analysis

parameters
* lin_vul(l) permite identificar las lineas que con mayor frecuencia se sobrecargan
*ante las diferentes contigencias presentadas en el proceso iteratico para el despacho seguro
lin_vul(l) 'parametro para identificar las lineas mas vulnerables ante las diferentes contingencias '

* lin_critcas(ll) permite identificar las lineas que, al momento de fallar, generan mas sobrecargas en otras linea
lin_critcas(ll)'parametro para identificar las lineas que generan mas impacto al momento de fallar'

lin_congt(l,ll)'numero de afectaciones l ante la contigencia ll'

resgenpper(t)'numero de restricciones activas generadas por periodo'

Numrestpercri  ' Número de restricciones activas en el periodo critico '
Peridcritic(t) 'periodo critico: donde mas restricciones activas N-1 se generan'
*Periodo Crítico se refiere al periodo de tiempo donde mas restricciones se generan , es decir, donde se violentan mas restricciones ante el N-1

linvulpercir(t, l)'lineas afectadas en el periodo crítico'
llcrtiperctr(t, ll)'contigencias severas en periodo critico'
;

lin_vul(l)=sum([t, ll], ContBin(t, l, ll));
lin_critcas(ll)=sum([t, l], ContBin(t, l, ll));
lin_congt(l, ll) =sum([t], ContBin(t, l, ll));

resgenpper(t)=sum([l, ll],ContBin(t, l, ll));
Numrestpercri=smax(t, resgenpper(t));
Peridcritic(t)=ord(t)$(resgenpper(t) eq Numrestpercri);
linvulpercir(t, l)$(resgenpper(t) eq Numrestpercri)= sum([ll], ContBin(t, l, ll));
llcrtiperctr(t, ll)$(resgenpper(t) eq Numrestpercri)= sum([l], ContBin(t, l, ll));

display lin_vul, lin_critcas;
