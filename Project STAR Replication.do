*** Install Packages ***
	global dir = "C:\GitHub\"
	cd "$dir"
	ssc install est2tex
	ssc install outreg2
	ssc install ivreg2
	ssc install weakivtest
	ssc install avar
	ssc install ranktest

*** Creating Variables ***
	
	** Open data **
		clear
		use "C:\GitHub\STAR_Students.dta", clear

	**Grades**
		global grades gk g1 g2 g3
		*Todo: Check if it has to be global

	** Free Lunch **
		foreach grade of global grades{
			replace `grade'freelunch=1 if `grade'freelunch==1
			replace `grade'freelunch=0 if `grade'freelunch==2
		}
		
	** White and Asian **
		gen whiteasian = 1 if race == 1 | race == 3
		replace whiteasian = 0 if whiteasian != 1

	**Master Teacher**
		foreach grade of global grades{
			gen masterteacher`grade' = 1 if `grade'thighdegree == 3 | `grade'thighdegree == 4 | `grade'thighdegree == 5 | `grade'thighdegree == 6
			replace masterteacher`grade' = 0 if masterteacher`grade' != 1
		}	
		
	**White Teacher**
		foreach grade of global grades{
			gen whiteteacher`grade' = 1 if `grade'trace == 1
			replace whiteteacher`grade' = 0 if whiteteacher`grade' != 1
		}

	** Attrition **
		gen attritionsgk = 0 if flagsgk == 1 & flagsg1 == 1 & flagsg2 == 1 & flagsg3 == 1
		gen attritionsg1 = 0 if flagsg1 == 1 & flagsg2 == 1 & flagsg3 == 1
		gen attritionsg2 = 0 if flagsg2 == 1 & flagsg3 == 1
		gen attritionsg3 = 0
		replace attritionsgk = 1 if attritionsgk != 0
		replace attritionsg1 = 1 if attritionsg1 != 0
		replace attritionsg2 = 1 if attritionsg2 != 0
		*Todo: This is replacing missing values. Fix that.

	** Age **

		*Age reference is Sep. 30, 1985
		gen age85=(714900-((birthyear*12*30)+(birthmonth*30)+birthday))
		*gen age85=mdy(birthmonth,birthday,birthyear)
		*replace age85=mdy(9,1,1985)-age85
		replace age85=age85/365

	**Regular Class Size Dummy**

		gen regular=1 if gkclasssize < 28 & gkclasssize > 17
		*replace regular=0 if regular != 1 
		*gen regular=1 if gkclasstype == 2
		*replace regular=1 if gkclasstype == 3

	**Percentile SAT 1**

		foreach grade of global grades{ 
			**Percentile Reading SAT**
				gen temp = 0
				gen pct_reading = .
				forvalues i = 1/11601 {
					qui replace temp = regular
					if regular[`i'] != 1{
						qui replace temp = 1 in `i'
						qui replace temp = `grade'treadss*temp
						qui egen pctile = mean((temp < temp[`i']) / (temp < .))
						if missing(`grade'treadss[`i']){
							qui replace pctile = .
						}
						qui replace pct_reading = pctile in `i'
						qui drop pctile
					}
					else {
						qui replace temp = `grade'treadss*temp
						qui egen pctile = mean((temp < temp[`i']) / (temp < .))
						if missing(`grade'treadss[`i']){
							qui replace pctile = .
						}
						qui replace pct_reading = pctile in `i'
						qui drop pctile
					}
				}
				drop temp

			**Percentile Math SAT**
				gen temp = 0
				gen pct_math = .
				forvalues i = 1/11601 {
					qui replace temp = regular
					if regular[`i'] != 1{
						qui replace temp = 1 in `i'
						qui replace temp = `grade'tmathss*temp
						qui egen pctile = mean((temp < temp[`i']) / (temp < .))
						if missing(`grade'tmathss[`i']){
							qui replace pctile = .
						}
						qui replace pct_math = pctile in `i'
						qui drop pctile
					}
					else {
						qui replace temp = `grade'tmathss*temp
						qui egen pctile = mean((temp < temp[`i']) / (temp < .))
						if missing(`grade'tmathss[`i']){
							qui replace pctile = .
						}
						qui replace pct_math = pctile in `i'
						qui drop pctile
					}
				}
				drop temp

			**Percentile Word SAT**
				gen temp = 0
				gen pct_word = .
				forvalues i = 1/11601 {
					qui replace temp = regular
					if regular[`i'] != 1{
						qui replace temp = 1 in `i'
						qui replace temp = `grade'wordskillss*temp
						qui egen pctile = mean((temp < temp[`i']) / (temp < .))
						if missing(`grade'wordskillss[`i']){
							qui replace pctile = .
						}
						qui replace pct_word = pctile in `i'
						qui drop pctile
					}
					else {
						qui replace temp = `grade'wordskillss*temp
						qui egen pctile = mean((temp < temp[`i']) / (temp < .))
						if missing(`grade'wordskillss[`i']){
							qui replace pctile = .
						}
						qui replace pct_word = pctile in `i'
						qui drop pctile
					}
				}
				drop temp

			**Total Percentile**
				egen pct_sat_`grade' = rmean(pct_reading pct_word pct_math)
				drop pct_reading
				drop pct_word
				drop pct_math
				replace pct_sat_`grade' = pct_sat_`grade'*100
		}
		*save "C:\GitHub\STAR_Students.dta"
	
	**Percentile SAT 2**

	foreach grade of global grades{
		foreach sub in tread tmath wordskill {
			cumul `grade'`sub'ss if inrange(gkclasstype,2,3), gen(`grade'`sub'xt)
			sort `grade'`sub'ss
			qui replace `grade'`sub'xt=`grade'`sub'xt[_n-1] if `grade'`sub'ss==`grade'`sub'ss[_n-1] & gkclasstype==1
			qui ipolate `grade'`sub'xt `grade'`sub'ss, gen(ipo)
			qui replace `grade'`sub'xt=ipo if gkclasstype==1 & mi(`grade'`sub'xt)
			drop ipo
		}
		egen `grade'SATxt = rmean(`grade'treadxt `grade'tmathxt `grade'wordskillxt)
		qui replace `grade'SATxt=100*`grade'SATxt	
	}
	** Use this for method 2
	replace pct_sat_gk = (gkSATxt+pct_sat_gk)/2
	replace pct_sat_g1 = (g1SATxt+pct_sat_g1)/2
	replace pct_sat_g2 = (g2SATxt+pct_sat_g2)/2
	replace pct_sat_g3 = (g3SATxt+pct_sat_g3)/2
	
	**Grade Entered Star**

		gen gradeenter=""
		replace gradeenter="gk" if flagsgk==1
		replace gradeenter="g1" if flagsgk==0 & flagsg1==1 
		replace gradeenter="g2" if flagsgk==0 & flagsg1==0 & flagsg2==1
		replace gradeenter="g3" if flagsgk==0 & flagsg1==0 & flagsg2==0 & flagsg3==1

	**Class Assignment in First Year**
		gen firstclasstype = .
		foreach grade of global grades{
			set varabbrev off
			replace firstclasstype = `grade'classtype if gradeenter == "`grade'"
		}	

*** Table V ***
	replace regular=0 if regular != 1
	gen small=0
	replace small=1 if regular==0
	
	foreach grade of global grades{	

		sum pct_sat_`grade' if small == 1
		sum pct_sat_`grade' if regular == 1

		reg pct_sat_`grade' ib(2).`grade'classtype, vce(cluster `grade'tchid)
		reg pct_sat_`grade' ib(2).`grade'classtype i.`grade'schid, vce(cluster `grade'tchid)
		reg pct_sat_`grade' ib(2).`grade'classsize whiteasian gender `grade'freelunch i.`grade'schid, vce(cluster `grade'tchid)
		reg pct_sat_`grade' ib(2).`grade'classsize whiteasian gender `grade'freelunch whiteteacher`grade' masterteacher`grade' i.`grade'tyears i.`grade'schid, vce(cluster `grade'tchid)

		reg firstclasstype ib(2).`grade'classtype, vce(cluster `grade'tchid)
		reg firstclasstype ib(2).`grade'classtype i.`grade'schid, vce(cluster `grade'tchid)
		reg firstclasstype ib(2).`grade'classsize whiteasian gender `grade'freelunch i.`grade'schid, vce(cluster `grade'tchid)
		reg firstclasstype ib(2).`grade'classsize whiteasian gender `grade'freelunch whiteteacher`grade' masterteacher`grade' i.`grade'tyears i.`grade'schid, vce(cluster `grade'tchid)
	}

*** Table I ***

		foreach grade of global grades{		
			*Todo: Write the correct entry in STAR

			**Free Lunch**
				reg `grade'freelunch ibn.`grade'classtype if flags`grade'==1, noconstant
				test i1.`grade'classtype == i2.`grade'classtype == i3.`grade'classtype

			**White Asian**
				reg whiteasian ibn.`grade'classtype if flags`grade'==1, noconstant
				test i1.`grade'classtype == i2.`grade'classtype == i3.`grade'classtype

			**Age in 1985**
				reg age85 ibn.`grade'classtype if flags`grade'==1, noconstant
				test i1.`grade'classtype == i2.`grade'classtype == i3.`grade'classtype

			**Attrition**
				reg attritions`grade' ibn.`grade'classtype if flags`grade'==1, noconstant
				test i1.`grade'classtype == i2.`grade'classtype == i3.`grade'classtype

			**Class Size**
				reg `grade'classsize ibn.`grade'classtype if flags`grade'==1, noconstant
				test i1.`grade'classtype == i2.`grade'classtype == i3.`grade'classtype

			**Class Type**
				reg pct_sat_`grade' ibn.`grade'classtype if flags`grade'==1, noconstant
				test i1.`grade'classtype == i2.`grade'classtype == i3.`grade'classtype

		}

*** Density Graph ***
	foreach grade of global grades{	
		twoway kdensity pct_sat_`grade' if `grade'classtype == 1|| kdensity pct_sat_`grade' if `grade'classtype != 1, recast(line) lc(red)
		*kdensity pct_sat_`grade' if `grade'classtype == 1
		*kdensity pct_sat_`grade' if `grade'classtype != 1
	}
	**Test**
	*twoway kdensity pct_sat_gk if gkclasstype == 1|| kdensity pct_sat_gk if gkclasstype != 1, recast(line) lc(red)
	*twoway kdensity pct_sat_g1 if g1classtype == 1|| kdensity pct_sat_g1 if g1classtype != 1, recast(line) lc(red)
	twoway kdensity pct_sat_g2 if g2classtype == 1|| kdensity pct_sat_g2 if g2classtype != 1, recast(line) lc(red)
	*twoway kdensity pct_sat_g3 if g3classtype == 1|| kdensity pct_sat_g3 if g3classtype != 1, recast(line) lc(red)
	
*** Table III ***
	*Todo: Check replace gkclasstype=1 if gkclasstype==.
	*Todo: Check how to correcly replace
	*Todo: Test for grade entered
	tab g1classsize g1classtype
	mean g1classsize if g1classtype == 1
	mean g1classsize if g1classtype == 2
	mean g1classsize if g1classtype == 3

*** Table VII ***
	
	foreach grade of global grades{	
		reg pct_sat_`grade' `grade'classsize whiteasian gender `grade'freelunch whiteteacher`grade' masterteacher`grade' i.`grade'tyears i.`grade'schid, vce(cluster `grade'tchid)
		ivregress 2sls pct_sat_`grade' (`grade'classsize = i.`grade'classtype) whiteasian gender `grade'freelunch whiteteacher`grade' masterteacher`grade' i.`grade'tyears i.`grade'schid, vce(cluster `grade'tchid)
		*weakivtest
	}		

*** Notes ***

	*2 Different methods were tried to calculate the percentiles.
	*We kept the one that is closer to the paper.
	*Original: 54.7 and 49.9 with beta 4.82 and 5.37
	*Regular1: 52.98 and 48.54 with beta 4.41 and 4.97
	*Regular2: 52.90 and 48.54 with beta 4.35 and 4.83



