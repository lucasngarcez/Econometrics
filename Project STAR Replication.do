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

*Kindergarten*

use "C:\GitHub\STAR_Students.dta", clear

gen regular=1 if gkclasssize > 17
*replace regular=0 if regular != 1

*check how to find the min for a subsample

egen min_hssattot = min(hssattot*regular) 
egen max_hssattot = max(hssattot*regular)
gen percent_hssattot = hssattot
replace percent_hssattot = 100*((hssattot-min_hssattot)/(max_hssattot-min_hssattot))

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
