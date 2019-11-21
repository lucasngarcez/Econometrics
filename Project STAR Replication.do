*** Install Packages ***
global dir = "C:\GitHub\"
cd "$dir"
ssc install est2tex
ssc install outreg2
ssc install ivreg2
ssc install weakivtest
ssc install avar
ssc install ranktest

*****Mergining Data Sets and Creating Variables*****

clear
use "C:\GitHub\STAR_K-3_Schools.dta", clear
sort schid
save "C:\GitHub\STAR_K-3_Schools.dta", replace

use "C:\GitHub\STAR_High_Schools.dta", clear
sort hsid
save "C:\GitHub\STAR_High_Schools.dta", replace

use "C:\GitHub\STAR_Students.dta", clear

**Regular class size dummy**

gen regular=1 if gkclasssize < 28 & gkclasssize > 17
*replace regular=0 if regular != 1 
*gen regular=1 if gkclasstype == 2
*replace regular=1 if gkclasstype == 3

**Percentile Total SAT**

gen temp = 0
gen pct_hssattot = .
forvalues i = 1/11601 {
	qui replace temp = regular
	if regular[`i'] != 1{
		qui replace temp = 1 in `i'
		qui replace temp = gktreadss*temp
		qui egen pctile = mean((temp < temp[`i']) / (temp < .))
		if missing(gktreadss[`i']){
			qui replace pctile = .
		}
		qui replace pct_hssattot = pctile in `i'
		qui drop pctile
	}
	else {
		qui replace temp = gktreadss*temp
		qui egen pctile = mean((temp < temp[`i']) / (temp < .))
		if missing(gktreadss[`i']){
			qui replace pctile = .
		}
		qui replace pct_hssattot = pctile in `i'
		qui drop pctile
	}
}
drop temp

**Percentile Verbal SAT**

gen temp = 0
gen pct_hssatverbal = .
forvalues i = 1/11601 {
	qui replace temp = regular
	if regular[`i'] != 1{
		qui replace temp = 1 in `i'
		qui replace temp = gktmathss*temp
		qui egen pctile = mean((temp < temp[`i']) / (temp < .))
		if missing(gktmathss[`i']){
			qui replace pctile = .
		}
		qui replace pct_hssatverbal = pctile in `i'
		qui drop pctile
	}
	else {
		qui replace temp = gktmathss*temp
		qui egen pctile = mean((temp < temp[`i']) / (temp < .))
		if missing(gktmathss[`i']){
			qui replace pctile = .
		}
		qui replace pct_hssatverbal = pctile in `i'
		qui drop pctile
	}
}
drop temp

**Percentile Math SAT**

gen temp = 0
gen pct_hssatmath = .
forvalues i = 1/11601 {
	qui replace temp = regular
	if regular[`i'] != 1{
		qui replace temp = 1 in `i'
		qui replace temp = gkwordskillss*temp
		qui egen pctile = mean((temp < temp[`i']) / (temp < .))
		if missing(gkwordskillss[`i']){
			qui replace pctile = .
		}
		qui replace pct_hssatmath = pctile in `i'
		qui drop pctile
	}
	else {
		qui replace temp = gkwordskillss*temp
		qui egen pctile = mean((temp < temp[`i']) / (temp < .))
		if missing(gkwordskillss[`i']){
			qui replace pctile = .
		}
		qui replace pct_hssatmath = pctile in `i'
		qui drop pctile
	}
}
drop temp

**Percentile Math SAT**

gen pct_sat = 0
*Check if one of the 3 are missing
replace pct_sat = (pct_hssattot+pct_hssatmath+pct_hssatverbal)/3

**Labeling variables**
replace pct_hssattot = pct_hssattot*100 
replace pct_hssatmath = pct_hssatmath*100 
replace pct_hssatverbal = pct_hssatverbal*100 
replace pct_sat = pct_sat*100 
label variable pct_hssattot "PERCENTILE OF TOTAL SAT FOR POOLED REGULAR"
label variable pct_hssatmath "PERCENTILE OF MATH SAT FOR POOLED REGULAR"
label variable pct_hssatverbal "PERCENTILE OF VERBAL SAT FOR POOLED REGULAR"
label variable pct_sat "AVERAGE PERCENTILE OF SAT FOR POOLED REGULAR"

**Kindergarten school merge**

sort gkschid
rename gkschid schid
merge m:1 schid using "C:\GitHub\STAR_K-3_Schools.dta"
drop _merge
rename schid gkschid 
save "C:\GitHub\STAR_Students_Kindergarden.dta"


**Grade 1 school merge**

use "C:\GitHub\STAR_Students_Kindergarden.dta", clear
sort g1schid
rename g1schid schid
merge m:1 schid using "C:\GitHub\STAR_K-3_Schools.dta"
drop _merge
save "C:\GitHub\STAR_Students_Grade1.dta"


**Grade 2 school merge**

use "C:\GitHub\STAR_Students_Kindergarden.dta", clear
sort g2schid
rename g2schid schid
merge m:1 schid using "C:\GitHub\STAR_K-3_Schools.dta"
drop _merge
save "C:\GitHub\STAR_Students_Grade2.dta"


**Grade 3 school merge**

use "C:\GitHub\STAR_Students_Kindergarden.dta", clear
sort g2schid
rename g2schid schid
merge m:1 schid using "C:\GitHub\STAR_K-3_Schools.dta"
drop _merge
save "C:\GitHub\STAR_Students_Grade3.dta"

*** Table V ***
use "C:\GitHub\STAR_Students_Kindergarden.dta"
replace regular=0 if regular != 1
gen small=0
replace small=1 if regular==0

sum pct_sat if small == 1
sum pct_sat if regular == 1

*Todo: Cluster standard errors.
reg pct_sat ib(last).gkclasstype, robust
reg pct_sat ib(last).gkclasstype i.gkschid, robust

*** Table I (Kindergarten)***

*Variables*

replace gkfreelunch=1 if gkfreelunch==1
replace gkfreelunch=0 if gkfreelunch==2

gen whiteasian = 1 if race == 1 | race == 3
replace whiteasian = 0 if whiteasian != 1

gen attritionsgk = 0 if flagsgk == 1 & flagsgk == 1 & flagsg1 == 1 & flagsg2 == 1 & flagsg3 == 1
replace attritionsgk = 1 if attritionsgk != 0

*Age reference is Sep. 30, 1985
gen age85=(714900-((birthyear*12*30)+(birthmonth*30)+birthday))
*gen age85=mdy(birthmonth,birthday,birthyear)
*replace age85=mdy(9,1,1985)-age85
replace age85=age85/365

*Coefficients and p-values*

reg gkfreelunch ibn.gkclasstype if flagsgk==1, noconstant
test i1.gkclasstype == i2.gkclasstype == i3.gkclasstype

reg whiteasian ibn.gkclasstype if flagsgk==1, noconstant
test i1.gkclasstype == i2.gkclasstype == i3.gkclasstype

*Todo: Age in 1985
reg age85 ibn.gkclasstype if flagsgk==1, noconstant
test i1.gkclasstype == i2.gkclasstype == i3.gkclasstype

reg attritionsgk ibn.gkclasstype if flagsgk==1, noconstant
test i1.gkclasstype == i2.gkclasstype == i3.gkclasstype

reg gkclasssize ibn.gkclasstype if flagsgk==1, noconstant
test i1.gkclasstype == i2.gkclasstype == i3.gkclasstype

reg pct_sat ibn.gkclasstype if flagsgk==1, noconstant
test i1.gkclasstype == i2.gkclasstype == i3.gkclasstype

twoway kdensity pct_sat if gkclasstype == 1|| kdensity pct_sat if gkclasstype != 1, recast(line) lc(red)

kdensity pct_sat if gkclasstype == 1
kdensity pct_sat if gkclasstype != 1

*** Table III ***
*replace gkclasstype=1 if gkclasstype==.
*check how to replace
tab g1classsize g1classtype
mean g1classsize if gkclasstype == 1
mean g1classsize if gkclasstype == 2
mean g1classsize if gkclasstype == 3

** Notes:
*2 Different methods were tried to calculate the percentiles.
*We kept the one that is closer to the paper.
*Original: 54.7 and 49.9 with beta 4.82 and 5.37
*Regular1: 52.98 and 48.54 with beta 4.41 and 4.97
*Regular2: 52.90 and 48.54 with beta 4.35 and 4.83

*** Table I***

reg gkfreelunch ibn.gkclasstype i.gkschid, noconstant
test i1.gkclasstype == i2.gkclasstype == i3.gkclasstype
  
reg whiteasian ibn.gkclasstype i.gkschid, noconstant
test i1.gkclasstype == i2.gkclasstype == i3.gkclasstype

reg age85 ibn.gkclasstype i.gkschid, noconstant
test i1.gkclasstype == i2.gkclasstype == i3.gkclasstype

reg attritionsgk ibn.gkclasstype i.gkschid, noconstant
test i1.gkclasstype == i2.gkclasstype == i3.gkclasstype

reg gkclasssize ibn.gkclasstype i.gkschid, noconstant
test i1.gkclasstype == i2.gkclasstype == i3.gkclasstype

reg  pct_sat ibn.gkclasstype i.gkschid, noconstant
test i1.gkclasstype == i2.gkclasstype == i3.gkclasstype


*** Table VII***

reg pct_sat gkclasssize whiteasian gender gkfreelunch i.gktrace i.gkthighdegree i.gktcareer i.gkschid, r

ivreg2 pct_sat (gkclasssize = i.gkclasstype) whiteasian gender gkfreelunch i.gktrace i.gkthighdegree i.gktcareer i.gkschid, r
weakivtest

