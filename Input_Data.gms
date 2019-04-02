$OffDigit

***************************************************************
*** SETS
***************************************************************

set t time periods /t1*t24/;
set i generators /i1*i96/;
set b generator blocks /b1*b3/;
set s buses /0*72/;
set l lines /l1*l120/;
set j start up cost intervals /j1*j8/;
set column auxiliary /column1/;
set tr transmission data (1-HP 2-MOV 3-MS 4-YD) /tr1*tr4/;

***************************************************************
*** OPTIONS
***************************************************************

scalar transmission_option/4/;
* 1 - HP
* 2 - MOV
* 3 - MS
* 4 - YD

parameter line_capacity line capacity factor /0.8/;

alias(l, ll), (t, tt);

***************************************************************
*** PARAMETERS
***************************************************************

*GENERATOR DATA

table gen_map(i, s) generator map
$include gmap.inc
;

table g_max(i, b) generator block generation limit
$include block_max.inc
;

table k_option(i, b, tr) slope of each generator cost curve block
$include k.inc
;

parameter k(i, b);
k(i, b)=sum(tr$(ord(tr)=transmission_option), k_option(i, b, tr));

table suc_sw_option(i, j, tr) generator stepwise start-up cost
$include start_up_sw.inc
;

parameter suc_sw(i, j);
suc_sw(i, j)=sum(tr$(ord(tr)=transmission_option), suc_sw_option(i, j, tr));

table suc_sl(i, j) generator stepwise start-up hourly blocks
$include start_up_sl.inc
;

table aux2(i,column)
$include aux2.inc
;

parameter count_off_init(i) number of time periods each generator has been off;
count_off_init(i)=sum(column, aux2(i, column));

table aux3(i,column)
$include aux3.inc
;

parameter count_on_init(i) number of time periods each generator has been on;
count_on_init(i)=sum(column, aux3(i, column));

table aux4(i, tr)
$include aux4.inc
;

parameter a(i) fixed operating cost of each generator;
a(i)=sum(tr$(ord(tr)=transmission_option),aux4(i, tr));

table aux5(i, tr)
$include aux5.inc
;

parameter ramp_up(i) generator ramp-up limit;
ramp_up(i)=sum(tr$(ord(tr)=transmission_option), aux5(i, tr));

table aux6(i, tr)
$include aux6.inc
;

parameter ramp_down(i) generator ramp-down limit;
ramp_down(i)=sum(tr$(ord(tr)=transmission_option), aux6(i, tr));

table aux7(i, tr)
$include aux7.inc
;

parameter g_down(i) generator minimum down time;
g_down(i)=sum(tr$(ord(tr)=transmission_option), aux7(i, tr));

table aux8(i, tr)
$include aux8.inc
;

parameter g_up(i) generator minimum up time;
g_up(i)=sum(tr$(ord(tr)=transmission_option), aux8(i, tr));

table aux9(i, tr)
$include aux9.inc
;

parameter g_min(i) generator minimum output;
g_min(i)=sum(tr$(ord(tr)=transmission_option), aux9(i, tr));

table aux10(i, column)
$include aux10.inc
;

parameter g_0(i) generator generation at t=0;
g_0(i)=sum(column, aux10(i, column));

parameter onoff_t0(i) on-off status at t=0;
onoff_t0(i)$(count_on_init(i) gt 0) = 1;

parameter L_up_min(i) used for minimum up time constraints;
L_up_min(i) = min(card(t), (g_up(i)-count_on_init(i))*onoff_t0(i));

parameter L_down_min(i) used for minimum up time constraints;
L_down_min(i) = min(card(t), (g_down(i)-count_off_init(i))*(1-onoff_t0(i)));

scalar M number of hours a unit can be on or off /2600/;

*LINE DATA

table aux11(l, column)
$include aux11.inc
;

parameter admitance(l) line admittance;
admitance(l)=sum(column, aux11(l, column));

table line_map(l, s) line map
$include line_map.inc
;

table aux12(l, column)
$include aux12.inc
;

parameter l_max(l) line capacities (long-term ratings);
l_max(l)=sum(column, aux12(l, column));

*DEMAND DATA

table d(t, s) yearly demand at bus s
$include load24.inc
;

* Linear Sensitive Factors

*$call 'python makeDF.py input_UC_ii.xlsx branch bus -o1 ptdf.inc -o2 lodf.inc'

table ptdf(l, s) factores PTDF
$include ptdf.inc
;

table lodf(l, ll) factores LODF
$include lodf.inc
;
