import delimited "C:\Users\cam\Downloads\P_Data_Extract_From_World_Development_Indicators (6)\b59c1505-51e4-4b4d-bff8-875b6ee0cf68_Data.csv", clear
desc

*drops notes
drop in 870/874

*Rename variables
rename v1 countryname
rename v2 countrycode
rename v3 varname
rename v4 varcode

*renaming variable years
local i=2013
foreach x of varlist v5-v15 {
    rename `x' yr`i'
    local i = `i' +1
    }
	
*the first row is column names; we need to drop it
drop in 1

*need to destring the year data
destring yr20*, replace force

reshape long yr, i(countryname countrycode varname) j(year)

rename yr value

gen varhold=.
replace varhold=1 if varcode=="AG.LND.TOTL.K2"
replace varhold=2 if varcode=="EN.GHG.CO2.PC.CE.AR5"
replace varhold=3 if varcode=="NY.GDP.PCAP.KD"
replace varhold=4 if varcode=="SP.URB.TOTL.IN.ZS"

*reshape is sensitive to unnecessary variable
drop varname varcode

reshape wide value, i(countryname countrycode year) j(varhold)

rename value1 area
rename value2 co2pc
rename value3 gdppc
rename value4 urbper
list in 1/5

label variable area "area km sq"
label variable co2pc "Carbon dioxide (CO2) emissions excluding LULUCF per capita"
label variable gdppc "GDP per capita (constant 2015 US$)"
label variable urbper "Urban population (% of total population) "

cd "D:\documents copy\teaching\SOCG 206 spring 2025\jupyter\data"
save worldbank.dta,replace

*load the data
cd "D:\documents copy\teaching\SOCG 206 spring 2025\jupyter\data"
use worldbank.dta,clear
desc

*countryname is string variable
encode countryname,g(country)

*use the j cluster

xtset country year

*Stata has many specific panel commands "xt"
*xtsum reports summary statistics overall, between, and within the data.
xtsum co2pc gdppc urbper area year

egen area_avg = mean(area), by(countryname)

xtsum area area_avg

*gen colonial=0
replace colonial=1 if countryname=="Australia"| countryname=="Austria"| countryname=="Belarus" | countryname=="Belgium" | ////
    countryname=="Canada" | countryname=="China" | countryname=="Croatia" | countryname=="Cyprus" | countryname=="Czech Republic" | ////
    countryname=="Denmark" | countryname=="Estonia" | countryname=="Ethiopia" | countryname=="Finland" | countryname=="France" | ////
    countryname=="Germany" | countryname=="Greece" | countryname=="Hungary" | countryname=="Ireland" | countryname=="Israel" | ////
    countryname=="Italy" | countryname=="Japan" | countryname=="Jordan" | countryname=="Kyrgyz Republic" | countryname=="Latvia" | ////
    countryname=="Liberia" | countryname=="Lithuania" | countryname=="Luxembourg" | countryname=="Malta" | countryname=="Moldova" | ////
    countryname=="Mongolia" | countryname=="Montenegro" | countryname=="Netherlands" |countryname== "New Zealand" | ////
    countryname=="North Macedonia" | countryname=="Norway" | countryname=="Poland" | countryname=="Portugal" | countryname=="Romania" | ////
    countryname=="Russia" | countryname=="Serbia" | countryname=="Slovak Republic" | countryname=="South Africa" | ////
    countryname=="Spain" | countryname=="Sweden" | countryname=="Switzerland" | countryname=="United Kingdom" | countryname=="United States"
	
histogram co2pc, bin(20)
histogram gdppc, bin(20)
histogram urbper, bin(20)
histogram area, bin(20)
histrogram area_avg, bin(20)

*log transforming variables
foreach x of varlist area_avg area-urbper {
    gen ln`x' = ln(`x'+1)
    }
	
histogram lnco2pc, bin(20)
histogram lngdppc, bin(20)
histogram lnurbper, bin(20)
histogram lnarea_avg, bin(20)

*random effects model
*mle stands for maximum likelihood estimation and vce is to use robust standard errors
xtreg lnco2pc lngdppc lnurbper lnarea_avg i.colonial, mle
estimates store random

*mle stands for maximum likelihood esimation and vce is to use robust standard errors
xtreg lnco2pc lngdppc lnurbper lnarea_avg i.colonial, vce(robust)

*manually calculate ICC
di .5593655^2/(.5593655^2+.07271549^2)

*Between effects model
xtreg lnco2pc lngdppc lnurbper lnarea_avg i.colonial, be
estimate store between

xtreg lnco2pc lngdppc lnurbper lnarea_avg i.colonial, fe
estimates store fixed

xtreg lnco2pc lngdppc lnurbper lnarea_avg i.colonial, fe vce(robust)

estimates table random between fixed,  b(%7.3f) se(%7.3f) p(%4.3f)

*Class practice

*Let's run the data 
use "https://www.stata-press.com/data/mlmus4/smoking.dta",clear
desc
