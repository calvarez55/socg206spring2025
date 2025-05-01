use "https://www.stata-press.com/data/r17/nhanes2.dta", clear
desc

tab highbp
tab region
*We can use the robust standard errors feature in logistic regression
logistic highbp i.female age i.region, vce(robust)

quietly logit highbp i.female age i.region, vce(robust)
*find means of variables
summ female age 
tab region

di exp(-2.351029 -.4317336*.5251667 + .0478323*47.57965 -.1234056*.2680 -.075136*.2756 -.0599217*.2539)/(1+exp(-2.351029 -.4317336*.5251667 + .0478323*47.57965 -.1234056*.2680 -.075136*.2756 -.0599217*.2539))

*margins with "atmeans" will calculate everything at the mean
margins, atmeans

margins, at(female=1 age=40 region==1)
margins, at(female=0 age=40 region==1)

import delimited "C:\Users\cam\Downloads\alr\logistic\lowbwt11.dat", delimiters(" ") clear

gen pair=v12
replace pair=v11 if v11!=.
label variable pair "pair"

gen low=v18
replace low=v17 if v17!=.
label variable low "low birth weight 1<=25000g"

gen age=v23
replace age=v22 if v22!=.
label variable age "age"

gen lwt=v26
replace lwt=v27 if v27!=.
replace lwt=v28 if v28!=.
label variable lwt "weight of mother at last menstrual period"

gen race=v33
replace race=v34 if v34!=.
replace race=v35 if v35!=.
label variable race "race 1=wht 2=blk 3=other"

gen smoke=v41
replace smoke=v42 if v42!=.
replace smoke=v43 if v43!=.
label variable smoke "smoking status"

gen ptd=v47
replace ptd=v48 if v48!=.
replace ptd=v49 if v49!=.
label variable ptd "history of premature labor"

gen ht=v52
replace ht=v53 if v53!=.
replace ht=v54 if v54!=.
label variable ht "history of hypertension"

gen ui=v57
replace ui=v58 if v58!=.
replace ui=v59 if v59!=.
label variable ui "presence of uterine irritability"

drop v1-v59

summ pair low age lwt smoke ptd ht ui
tab race

*demographic model
logit low i.race age
estimates store demo

*health model
logit low i.ptd i.ht i.ui
estimates store health

*activity model
logit low lwt i.smoke
estimates store activity

logit low i.race age ptd ht ui lwt i.smoke
estimates store full

estimates table demo health activity full, stats(r2_p aic bic)

*save to excel
cd "D:\documents copy\teaching\SOCG 206 spring 2025\jupyter\results"
putdocx begin
putdocx table results = etable
putdocx save myresults.docx

quietly logit low i.race age ptd ht ui lwt i.smoke
estimate store full

quietly logit low i.race age
estimate store demo

lrtest full demo

use "https://www.stata-press.com/data/r17/nhanes2.dta", clear
describe
