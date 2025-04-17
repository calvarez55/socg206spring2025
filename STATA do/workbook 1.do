pwd

cd "D:\documents copy\teaching\SOCG 206 spring 2025\jupyter\workbook1"

*example of opening .dta file from the web. This also will work for a file path.
use "https://www.stata-press.com/data/r18/lifeexp.dta", clear

*First, you must read in the file from the web.
import excel "https://ers.usda.gov/sites/default/files/_laserfiche/DataFiles/53251/Ruralurbancontinuumcodes2023.xlsx?v=10526", firstrow clear
describe
list in 1/3

*First, you must read in the file from the web.
import delimited "https://ers.usda.gov/sites/default/files/_laserfiche/DataFiles/53251/Ruralurbancontinuumcodes2023.csv?v=92956", clear
describe
list in 1/3

*saving stata data file
save "D:\documents copy\teaching\SOCG 206 spring 2025\jupyter\data.dta", replace

export excel "D:\documents copy\teaching\SOCG 206 spring 2025\jupyter\data.xlsx", replace

export delimited "D:\documents copy\teaching\SOCG 206 spring 2025\jupyter\data.csv", replace

*Use the asterisk sign * or // to write single-line commands.
/* Use asterisk with a backslash and asterisk to 
multi-line comments */ 

help merge

*setting up working directory to be my workbook 1 folder
cd "D:\documents copy\teaching\SOCG 206 spring 2025\jupyter\workbook1"

*open a log file
log using "week2 inclass practice.smcl", replace

*opening datafile
use "https://www.stata-press.com/data/r18/lifeexp.dta", clear

*tell stata to describe data
desc

*This will close and save log file and convert to pdf
capture log close
translate "D:\documents copy\teaching\SOCG 206 spring 2025\jupyter\workbook1\week2 inclass practice.smcl" ///
    "D:\documents copy\teaching\SOCG 206 spring 2025\jupyter\workbook1\week2 inclass practice.pdf", replace
	
use "https://www.stata-press.com/data/r17/census12.dta", clear

*the describe command will give you summary of the data type of your variables
describe

*This opens the data
use https://www.stata-press.com/data/r17/hbp2.dta, clear
*This code prints a descriptive of the dataset.
desc

list in 1/5

*Stata wont let you run statistics with string variables. See error message
regress year i.sex

*This is an example of using encode
encode sex, gen(sex_numeric) label("Respondent's sex (numeric)")

*Let's see if there was a change
list in 1/5
desc

*Now, we can run statistics
regress year i.sex_numeric

codebook race

*DESTRING
*Reading in data and asking for description of data
use http://www.stata-press.com/data/r13/destring2, clear
desc
list in 1/5

destring price, generate(price3)

/*Code for destring
You could use either one of these codes. Note that the second one REPLACES the string variable with the numeric variable.*/
destring date price percent, generate(date2 price2 percent2) ignore("$ ,%")

*destring date price percent, ignore("$ ,%") replace

*Let's make sure it worked.
desc
list in 1/5

*First, you must read in the file from the web.
import excel "https://www.prisonpolicy.org/data/race_ethnicity_gender_2010.xlsx", ///
    sheet(Total) clear
describe

list A C E in 1/6 
list A C E in 58/61

*Second, you drop the observations or rows that are not necessary.
drop in 59/61
drop in 1/4

list in 1/2

*Fourth, you need to rename the variables with useful names
rename A geoid
rename B geoid2
rename C state
rename D tot_incar
rename E wht_incar
rename F blk_incar
rename G indig_incar
rename H asian_incar
rename I hawpi_incar
rename J other_incar
rename K multirace_incar
rename L lat_incar

*Row 1 just has the variable names so you can drop it now that you are done cleaning
drop in 1

drop M-AI
desc

*This is one way to transform the string variables into numeric variables.
destring geoid2, replace
destring tot_incar, replace
destring wht_incar, replace
destring blk_incar, replace
destring indig_incar, replace
destring asian_incar, replace
destring hawpi_incar, replace
destring other_incar, replace
destring multirace_incar, replace
destring lat_incar, replace
describe
*You will know it worked, if in data view, the variables are displayed in black text color.

/* SHORCUT
destring tot_incar-lat_incar, replace
*/

*Next, this is one way to make the string variable of "state" into a numeric variable
encode state, gen(state_num) label("State (numeric variable)")
*You will know if worked if state is in blue text color.

*Let's make sure it worked
desc

generate whtincar_per=(100*wht_incar)/tot_incar
generate blkincar_per=(100*blk_incar)/tot_incar
generate indigincar_per=(100*indig_incar)/tot_incar
generate latincar_per=(100*lat_incar)/tot_incar
generate asianincar_per=(100*asian_incar)/tot_incar
generate hawpincar_per=(100*hawpi_incar)/tot_incar
generate otherincar_per=(100*other_incar)/tot_incar
generate multincar_per=(100*multirace_incar)/tot_incar

summarize whtincar_per-multincar_per

/*  SHORTCUT
foreach x of varlist wht_incar-lat_incar {
    gen `x'per=(100*`x')/tot_incar
    }
*/

gen eparegion=geoid2
recode eparegion ( 9 23 25 33 44 50 =1) ( 34 36 72 =2) ///
    ( 10 11 24 42 51 54= 3) ( 1 12 13 21 28 37 45 47=4) ///
    ( 17 18 26 27 39 55=5) ( 5 22 35 40 48=6) ( 19 20 29 31=7) ///
    ( 8 30 38 46 49 56=8) ( 4 6 15 32=9) ( 16 41 53 =10)
	
forvalues region = 1/10 {
      display `region'
      summarize whtincar_per blkincar_per latincar_per if eparegion == `region'
  }
  
 *Let's save our data
cd "D:\documents copy\teaching\SOCG 206 spring 2025\jupyter\data"
save "incarceration 4 14 25.dta", replace

*read the csv file; make sure to include clear
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
keep name geocode latper-multiraceper

*I am renaming to make the using file
rename geocode geoid2

cd "D:\documents copy\teaching\SOCG 206 spring 2025\jupyter\data\"
merge 1:1 geoid2 using "incarceration2021 4 8 25.dta"

collapse (mean) latper-multiraceper whtincar_per-multincar_per,by(eparegion)

import delimited "D:\documents copy\teaching\SOCG 206 spring 2025\jupyter\data\240b728c-ef6f-4084-8509-9c06e59888a9_Data.csv", clear
desc

*drops notes
drop in 436/440

*Rename variables
rename v1 countryname
rename v2 countrycode
rename v3 varname
rename v4 varcode

*renaming variable years
local i=2010
foreach x of varlist v5-v18 {
    rename `x' yr`i'
    local i = `i' +1
    }
	
*the first row is column names; we need to drop it
drop in 1

*need to destring the year data
destring yr20*, replace ignore("..")

reshape long yr, i(countryname countrycode varname) j(year)

rename yr value

gen varhold=.
replace varhold=1 if varcode=="EN.GHG.CO2.PC.CE.AR5"
replace varhold=2 if varcode=="NY.GDP.PCAP.KD"

*reshape is sensitive to unnecessary variable
drop varname varcode

reshape wide value, i(countryname countrycode year) j(varhold)

rename value1 co2pc
rename value2 gdppc
list in 1/5

