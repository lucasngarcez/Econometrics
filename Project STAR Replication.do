*** Install Packages ***
global dir = "C:\GitHub\"
cd "$dir"
ssc install est2tex
ssc install outreg2
ssc install ivreg2
ssc install weakivtest
ssc install avar

*** Mergining Data Sets ***
clear
use "C:\GitHub\STAR_K-3_Schools.dta", clear
sort schid
save "C:\GitHub\STAR_K-3_Schools.dta", replace

use "C:\GitHub\STAR_High_Schools.dta", clear
sort hsid
save "C:\GitHub\STAR_High_Schools.dta", replace

use "C:\GitHub\STAR_Students.dta", clear

gen regular=1 if gkclasssize < 28 & gkclasssize > 17
*replace regular=0 if regular != 1

*egen min_hssattot = min(hssattot*regular) 
*egen max_hssattot = max(hssattot*regular)
*gen percent_hssattot = hssattot
*replace percent_hssattot = 100*((hssattot-min_hssattot)/(max_hssattot-min_hssattot))
*sysuse auto, clear

*sort hssattot
*gen score=1 if hssattot > 0
*gen rank = _n
*pctile pct = hssattot, nq(11602) genp(percent)

		*qui replace temp = hssattot*temp
		*display temp[`i']
		*qui pctile pct = temp, nq(150) genp(percent)
		*display percent[`i']
		*qui replace pct_hssattot = percent in `i'
		*drop pct
		*drop percent
		
		*qui pctile pct = hssattot*regular, nq(150) genp(percent)
		*qui replace pct_hssattot = percent in `i'
		*drop pct
		*drop percent

gen temp = 0
gen pct_hssattot = .
forvalues i = 1/11601 {
	qui replace temp = regular
	if regular[`i'] != 1{
		qui replace temp = 1 in `i'
		qui replace temp = hssattot*temp
		qui egen pctile = mean((temp < temp[`i']) / (temp < .))
		if missing(hssattot[`i']){
			qui replace pctile = .
		}
		qui replace pct_hssattot = pctile in `i'
		qui drop pctile
	}
	else {
		qui replace temp = hssattot*temp
		qui egen pctile = mean((temp < temp[`i']) / (temp < .))
		if missing(hssattot[`i']){
			qui replace pctile = .
		}
		qui replace pct_hssattot = pctile in `i'
		qui drop pctile
	}
}
drop temp

gen temp = 0
gen pct_hssatverbal = .
forvalues i = 1/11601 {
	qui replace temp = regular
	if regular[`i'] != 1{
		qui replace temp = 1 in `i'
		qui replace temp = hssatverbal*temp
		qui egen pctile = mean((temp < temp[`i']) / (temp < .))
		if missing(hssatverbal[`i']){
			qui replace pctile = .
		}
		qui replace pct_hssatverbal = pctile in `i'
		qui drop pctile
	}
	else {
		qui replace temp = hssatverbal*temp
		qui egen pctile = mean((temp < temp[`i']) / (temp < .))
		if missing(hssatverbal[`i']){
			qui replace pctile = .
		}
		qui replace pct_hssatverbal = pctile in `i'
		qui drop pctile
	}
}
drop temp

gen temp = 0
gen pct_hssatmath = .
forvalues i = 1/11601 {
	qui replace temp = regular
	if regular[`i'] != 1{
		qui replace temp = 1 in `i'
		qui replace temp = hssatmath*temp
		qui egen pctile = mean((temp < temp[`i']) / (temp < .))
		if missing(hssatmath[`i']){
			qui replace pctile = .
		}
		qui replace pct_hssatmath = pctile in `i'
		qui drop pctile
	}
	else {
		qui replace temp = hssatmath*temp
		qui egen pctile = mean((temp < temp[`i']) / (temp < .))
		if missing(hssatmath[`i']){
			qui replace pctile = .
		}
		qui replace pct_hssatmath = pctile in `i'
		qui drop pctile
	}
}
drop temp

label variable pct_hssattot "PERCENTILE OF TOTAL SAT FOR POOLED REGULAR"
label variable pct_hssatmath "PERCENTILE OF MATH SAT FOR POOLED REGULAR"
label variable pct_hssatverbal "PERCENTILE OF VERBAL SAT FOR POOLED REGULAR"

gen pct_sat = 0
if pct_hssattot != . {
	replace pct_sat = (pct_hssattot+pct_hssatmath+pct_hssatverbal)
}
label variable pct_sat "AVERAGE PERCENTILE OF SAT FOR POOLED REGULAR"


sort gkschid
rename gkschid schid
merge m:1 schid using "C:\GitHub\STAR_K-3_Schools.dta"
drop _merge
rename schid gkschid 
save "C:\GitHub\STAR_Students_Kindergarden.dta"


*Grade 1*

use "C:\GitHub\STAR_Students_Kindergarden.dta", clear
sort g1schid
rename g1schid schid
merge m:1 schid using "C:\GitHub\STAR_K-3_Schools.dta"
drop _merge
save "C:\GitHub\STAR_Students_Grade1.dta"


*Grade 2*

use "C:\GitHub\STAR_Students_Kindergarden.dta", clear
sort g2schid
rename g2schid schid
merge m:1 schid using "C:\GitHub\STAR_K-3_Schools.dta"
drop _merge
save "C:\GitHub\STAR_Students_Grade2.dta"


*Grade 3*

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
reg percent_hssattot small
reg percent_hssattot small i.gkschid
