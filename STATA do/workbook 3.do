sysuse auto, clear
desc

*This command is using ML approach to find the highest log likelihood. Here we state we want to use normal distn.  
mlexp (ln(normalden(turn, {xb: length headroom _cons}, {sigma})))

*running OLS and it is very similar
regress turn length headroom

cd "C:\Users\cam\Downloads\alr\logistic\"

import delimited "chdage.dat", delimiters(" ") clear
keep v7 v8 v9 v16 v17 v18 v26 v27 v28

gen c1=v8
replace c1=v7 if v7!=.
replace c1=v9 if v9!=.

gen c2=v16
replace c2=v17 if v17!=.
replace c2=v18 if v18!=.

gen c3=v26
replace c3=v27 if v27!=.
replace c3=v28 if v28!=.

keep c1 c2 c3
rename c1 id
rename c2 age
rename c3 chd

save chdage.dta, replace

use chdage.dta, clear

scatter chd age

gen agrp=age
recode agrp 20/29=1 30/34=2 35/39=3 40/44=4 45/49=5 50/54=6 55/59=7 60/69=8

list id age agrp chd

summ age

tab chd

tabstat chd,by(agrp) stat(mean median min max)

sort agrp
collapse (count) tot=chd (sum) present=chd, by(agrp)
list

gen prop = present / tot
gen absent = tot - present
gen count = present + absent

scatter prop agrp, ylabel(0(.2)1) xlabel(1(1)8)

use "http://www.stata-press.com/data/agis6/environ", clear
tab environ libcand, row

use "http://www.stata-press.com/data/agis6/nlsy97_chapter11.dta", clear
codebook drank30 age97 pdrink97 dinner97 male

summarize drank30 age97 pdrink97 dinner97 male

*Using "logistic" command reports the estimates in ODDS ratios
logistic drank30 age97 pdrink97 dinner97 i.male

*Using "logit" command reports the estimates in logits so you have transform them back!
logit drank30 age97 pdrink97 dinner97 i.male

*You can calculate the odds ratio by exp the coef of age97
di exp(.1563548)

use "https://www.stata-press.com/data/r17/nhanes2.dta", clear
codebook diabetes region

logistic diabetes age i.rural ib4.region
