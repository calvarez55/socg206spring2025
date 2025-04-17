import delimited "D:\documents copy\research\Practice\extract\nhgis\nhgis0138_csv\nhgis0138_ds172_2010_state.csv", clear
describe

*Make sure to review the codebook to get a breakdown of the variables
rename h7z001 tot
rename h7z002 nt_lat
rename h7z003 wht_ntl
rename h7z004 blk_ntl
rename h7z005 ami_ntl
rename h7z006 asn_ntl
rename h7z007 hawpac_ntl
rename h7z008 other_ntl
rename h7z009 multirace_ntl
rename h7z010 lat
rename h7z011 wht
rename h7z012 blk
rename h7z013 ami
rename h7z014 asn
rename h7z015 hawpac
rename h7z016 other
rename h7z017 multirace

*We could also do a foreach loop
gen latper=100*(lat/tot)
gen whtper=100*((wht_ntl+wht)/tot)
gen blkper=100*((blk_ntl+blk)/tot)
gen amiper=100*((ami_ntl+ami)/tot)
gen asnper=100*((asn_ntl+asn)/tot)
gen hawpacper=100*((hawpac_ntl+hawpac)/tot)
gen otherper=100*((other_ntl+other)/tot)
gen multiraceper=100*((multirace_ntl+multirace)/tot)

*I only want to keep relevant variables
keep name statea latper-multiraceper

*I am renaming to make the using file
rename statea geoid2

cd "D:\documents copy\teaching\SOCG 206 spring 2025\jupyter\data\"
merge 1:1 geoid2 using "incarceration2021 4 14 25.dta"

*merging makes a new variable and you need to drop or rename if you want to merge again
drop _merge

*save file
cd "D:\documents copy\teaching\SOCG 206 spring 2025\jupyter\data"
save "incar_race 4 16 25.dta", replace

*Cleaning income csv
import delimited "D:\documents copy\research\Practice\extract\nhgis\nhgis0139_csv\nhgis0139_ds175_2010_state.csv", clear
describe

*Make sure to review the codebook to get a breakdown of the variables
rename i25e001 medhhinc
rename statea geoid2

*I only want to keep relevant variables
keep geoid2 medhhinc

*labeling medhhinc
label variable medhhinc "median household income"

cd "D:\documents copy\teaching\SOCG 206 spring 2025\jupyter\data\"
merge 1:1 geoid2 using "incar_race 4 16 25.dta"

drop _merge
*save file
cd "D:\documents copy\teaching\SOCG 206 spring 2025\jupyter\data"
save "incar_race_inc 4 16 25.dta", replace

tabstat latper latincar_per medhhinc, stat(mean median min max n)

tab eparegion

cd "D:\documents copy\teaching\SOCG 206 spring 2025\jupyter\data"
use "incar_race_inc 4 16 25.dta", clear

*running OLS command
regress latincar_per latper medhhinc i.eparegion

*linearity
quietly regress latincar_per latper medhhinc i.eparegion
predict r_1, residuals

*makes scatter plot matrix for correlation
graph matrix latincar_per latper medhhinc

scatter latincar_per latper, mlabel(state)

*normality
qnorm r_1, rlopts(lcolor(red)) aspect(1)

kdensity r_1, normal

swilk r_1

*homoscedasticity
rvfplot, yline(0) mlabel(state)

estat imtest
estat hettest

*multicollinearity
*VIF is a post-regress command
vif

regress latincar_per latper medhhinc i.eparegion if state!="Puerto Rico"

predict r_2, residuals

*Linearity
scatter latincar_per latper if state!="Puerto Rico", mlabel(state)

*Normality
swilk r_2

*Homoscedasticity
estat imtest
estat hettest

*Multicollinearity
vif

cd "D:\documents copy\teaching\SOCG 206 spring 2025\jupyter\data"
use "incar_race_inc 4 16 25.dta", clear
quietly regress latincar_per latper medhhinc i.eparegion
predict yhat
list state yhat latincar_per latper medhhinc eparegion in 1 

di 8.084027 + .9924154*(3.883101)+ .00000388*(40474) +1*(0)-6.288965*(0) -8.200945*(0) -8.095685*(1) -7.190414*(0) -6.36532*(0) -4.343998*(0) -1.880735*(0) -5.360627*(0) -4.050782*(0)

twoway ///
    (scatter latincar_per latper) ///
    (lfit yhat latper)
	
* Bonus storing regression results to excel table
cd "D:\documents copy\teaching\SOCG 206 spring 2025\jupyter\data"
use "incar_race_inc 4 16 25.dta", clear

quietly regress latincar_per latper medhhinc i.eparegion
matrix table = r(table)
matrix list table

matrix b = table[1, 1..9]'
matrix se = table[2, 1..9]'
matrix pvalue = table[4, 1..9]'

cd "D:\documents copy\teaching\SOCG 206 spring 2025\jupyter\results"
putexcel set "workbook2 myresults", sheet("Model1") modify
putexcel C1="Coef." A2=matrix(b), rownames nformat(number_d2)
putexcel D1="SE" D2=matrix(se)
putexcel E1="p-value" E2=matrix(pvalue)

quietly regress latincar_per latper medhhinc i.eparegion if state!="Puerto Rico"
matrix table = r(table)
matrix list table

matrix b = table[1, 1..9]'
matrix se = table[2, 1..9]'
matrix pvalue = table[4, 1..9]'

cd "D:\documents copy\teaching\SOCG 206 spring 2025\jupyter\results"
putexcel set "workbook2 myresults", sheet("Model2") modify
putexcel C1="Coef." A2=matrix(b), rownames nformat(number_d2)
putexcel D1="SE" D2=matrix(se)
putexcel E1="p-value" E2=matrix(pvalue)
