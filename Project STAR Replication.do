*** Install Packages ***
global dir = "C:\GitHub\"
cd "$dir"
ssc install est2tex
ssc install outreg2
ssc install ivreg2
ssc install weakivtest
ssc install avar

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
		qui replace temp = gktlistss*temp
		qui egen pctile = mean((temp < temp[`i']) / (temp < .))
		if missing(gktlistss[`i']){
			qui replace pctile = .
		}
		qui replace pct_hssatmath = pctile in `i'
		qui drop pctile
	}
	else {
		qui replace temp = gktlistss*temp
		qui egen pctile = mean((temp < temp[`i']) / (temp < .))
		if missing(gktlistss[`i']){
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

reg pct_sat ib(last).gkclasstype, robust
reg pct_sat ib(last).gkclasstype i.gkschid, robust

*Cluster standard errors

*Original: 54.7 and 49.9 with beta 4.82 and 5.37
*Regular1: 52.98 and 48.54 with beta 4.41 and 4.97
*Regular2: 52.90 and 48.54 with beta 4.35 and 4.83


