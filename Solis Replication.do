*** Lucas Garcez - Replication ***

*** Notes ***

	* 2 Different methods were tried to calculate the percentiles.
	* The first one is interpolating as suggested by prof. Carruthers.
	* The second is adding each small individual to the regular & regular+aide pool and recalculating percentiles with the actual grade.
	* At the end I calculated the average of the percentiles obtained with the two methods.
	* It is easy to change it to have just one or the other method. See "Method Choice" comment below.
	* Because recalculating for every individual is computationally intensive, expect 5 to 10 minutes to have all the percentiles calculated.
	* We chose to save the tables as a .txt delimited by space. 
	* If there are already .txt files with the same names the tables will be added to the existing files instead of overwriting. See comments below.
	
*** Setting Directory ***
	global dir = "C:\GitHub\"
	cd "$dir"
	
*** Install Packages (If necessary) ***
	*ssc install est2tex
	*ssc install outreg2
	*ssc install ivreg2
	*ssc install weakivtest
	*ssc install avar
	*ssc install ranktest
	*ssc install mat2txt

*** Creating Variables ***
	
	** Open data **
		clear
		qui use "C:\GitHub\STAR_Students.dta", clear

	**Grades**
		qui global grades gk g1 g2 g3
		*Todo: Check if it has to be global

	** Free Lunch **
		qui foreach grade of global grades{
			replace `grade'freelunch=1 if `grade'freelunch==1
			replace `grade'freelunch=0 if `grade'freelunch==2
			label variable `grade'freelunch "FREE/REDUCED LUNCH STATUS. 1 IF LUNCH IS FREE"
		}
		
	** White and Asian **
		qui gen whiteasian = 1 if race == 1 | race == 3
		qui replace whiteasian = 0 if whiteasian != 1
		qui label variable whiteasian "1 IF CHILD IS WHITE OR ASIAN"
		
	** Transform Gender into Dummy **
		qui replace gender = 0 if gender == 1
		qui replace gender = 1 if gender == 2
		qui label variable gender "STUDENT GENDER. 1 IF FEMALE"
		
	**Master Teacher**
		qui foreach grade of global grades{
			gen masterteacher`grade' = 1 if `grade'thighdegree == 3 | `grade'thighdegree == 4 | `grade'thighdegree == 5 | `grade'thighdegree == 6
			replace masterteacher`grade' = 0 if masterteacher`grade' != 1
			label variable masterteacher`grade' "TEACHERS WITH MASTERS DEGREE OR MORE. 1 IF MASTERS OR MORE"
		}	
		
	**White Teacher**
		qui foreach grade of global grades{
			gen whiteteacher`grade' = 1 if `grade'trace == 1
			replace whiteteacher`grade' = 0 if whiteteacher`grade' != 1
			label variable whiteteacher`grade' "WHITE TEACHER. 0 IF NON-WHITE"
		}
		
	**Transform Teacher Gender into Dummy**
		qui foreach grade of global grades{
			replace `grade'tgen = 0 if gender == 1
			replace `grade'tgen = 1 if gender == 2
			label variable `grade'tgen "TEACHER GENDER. 1 IF FEMALE"
		}


	** Attrition **
		qui gen attritionsgk = 0 if flagsgk == 1 & flagsg1 == 1 & flagsg2 == 1 & flagsg3 == 1
		qui gen attritionsg1 = 0 if flagsg1 == 1 & flagsg2 == 1 & flagsg3 == 1
		qui gen attritionsg2 = 0 if flagsg2 == 1 & flagsg3 == 1
		qui gen attritionsg3 = 0
		qui replace attritionsgk = 1 if attritionsgk != 0
		qui replace attritionsg1 = 1 if attritionsg1 != 0
		qui replace attritionsg2 = 1 if attritionsg2 != 0
		qui foreach grade of global grades{
			label variable attritions`grade' "ATTRITION. 1 IF LEFT THE PROGRAM"
		}
		*Todo: This is replacing missing values. Check if it affects results.

	** Age **

		*Age reference is Sep. 30, 1985
		qui gen age85=(714900-((birthyear*12*30)+(birthmonth*30)+birthday))
		qui replace age85=age85/365
		qui label variable age85 "APPROX. STUDENT AGE IN 1985"
		*gen age85=mdy(birthmonth,birthday,birthyear)
		*replace age85=mdy(9,1,1985)-age85

	**Regular Class Size Dummy**

		qui gen regular=1 if gkclasssize < 28 & gkclasssize > 17
		qui label variable regular "REGULAR SIZE CLASS. 1 IF REGULAR"
		*replace regular=0 if regular != 1 
		*gen regular=1 if gkclasstype == 2
		*replace regular=1 if gkclasstype == 3

	**Percentile SAT Method (1)**

		qui foreach grade of global grades{ 
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
	
	**Percentile SAT Method (2)**

	qui foreach grade of global grades{
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
	** Method Choice: Edit here if you want just method (1) or just method (2)
 		qui egen temp = rmean(gkSATxt pct_sat_gk)
		qui replace pct_sat_gk = temp
		qui drop temp
		qui label variable pct_sat_gk "AVERAGE SAT PERCENTILE IN KINDERGARTEN"
		qui egen temp = rmean(g1SATxt pct_sat_g1)
		qui replace pct_sat_g1 = temp
		qui drop temp
		qui label variable pct_sat_g1 "AVERAGE SAT PERCENTILE IN GRADE 1"
	 	qui egen temp = rmean(g2SATxt pct_sat_g2)
		qui replace pct_sat_g2 = temp
		qui drop temp
		qui label variable pct_sat_g2 "AVERAGE SAT PERCENTILE IN GRADE 2"
	 	qui egen temp = rmean(g3SATxt pct_sat_g3)
		qui replace pct_sat_g3 = temp
		qui drop temp
		qui label variable pct_sat_g3 "AVERAGE SAT PERCENTILE IN GRADE 3"
	
	**Grade Entered Star**

		qui gen gradeenter=""
		qui replace gradeenter="gk" if flagsgk==1
		qui replace gradeenter="g1" if flagsgk==0 & flagsg1==1 
		qui replace gradeenter="g2" if flagsgk==0 & flagsg1==0 & flagsg2==1
		qui replace gradeenter="g3" if flagsgk==0 & flagsg1==0 & flagsg2==0 & flagsg3==1
		qui label variable gradeenter "GRADE WHEN ENTERED STAR"

	**Class Assignment in First Year**
		qui gen firstclasstype = .
		qui foreach grade of global grades{
			set varabbrev off
			replace firstclasstype = `grade'classtype if gradeenter == "`grade'"
		}
		qui label variable firstclasstype "CLASS ASSIGNMENT WHEN ENTERED STAR"

*** Table V ***
	qui replace regular=0 if regular != 1
	qui gen small=0
	qui replace small=1 if regular==0
	qui foreach grade of global grades{
		matrix TableV`grade' = J(18, 8, .)
		matrix colnames TableV`grade' = "(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)" "(8)"
		matrix rownames TableV`grade' = "Small Class" "." "Regular/aide class" "." "White/Asian" "." "Female" "." "Free Lunch" "." "White Teacher" "." "Teacher Experience" "." "Master's Degree" "." "School Fixed Effects" "R-Squared"
		sum pct_sat_`grade' if small == 1
		sum pct_sat_`grade' if regular == 1
	}
	qui foreach grade of global grades{
		reg pct_sat_`grade' ib(2).`grade'classtype, vce(cluster `grade'tchid)
		matrix TableV`grade'[1,1] = _b[1.`grade'classtype]
		matrix TableV`grade'[2,1] = _se[1.`grade'classtype]
		matrix TableV`grade'[3,1] = _b[3.`grade'classtype]
		matrix TableV`grade'[4,1] = _se[3.`grade'classtype]
		matrix TableV`grade'[17,1] = 0
		matrix TableV`grade'[18,1] = e(r2)
	}
	qui foreach grade of global grades{
		reg pct_sat_`grade' ib(2).`grade'classtype i.`grade'schid, vce(cluster `grade'tchid)
		matrix TableV`grade'[1,2] = _b[1.`grade'classtype]
		matrix TableV`grade'[2,2] = _se[1.`grade'classtype]
		matrix TableV`grade'[3,2] = _b[3.`grade'classtype]
		matrix TableV`grade'[4,2] = _se[3.`grade'classtype]
		matrix TableV`grade'[17,2] = 1
		matrix TableV`grade'[18,2] = e(r2)
	}	
	qui foreach grade of global grades{
		reg pct_sat_`grade' ib(2).`grade'classtype whiteasian gender `grade'freelunch i.`grade'schid, vce(cluster `grade'tchid)
		matrix TableV`grade'[1,3] = _b[1.`grade'classtype]
		matrix TableV`grade'[2,3] = _se[1.`grade'classtype]
		matrix TableV`grade'[3,3] = _b[3.`grade'classtype]
		matrix TableV`grade'[4,3] = _se[3.`grade'classtype]
		matrix TableV`grade'[5,3] = _b[whiteasian]
		matrix TableV`grade'[6,3] = _se[whiteasian]
		matrix TableV`grade'[7,3] = _b[gender]
		matrix TableV`grade'[8,3] = _se[gender]
		matrix TableV`grade'[9,3] = _b[`grade'freelunch]
		matrix TableV`grade'[10,3] = _se[`grade'freelunch]
		matrix TableV`grade'[17,3] = 1
		matrix TableV`grade'[18,3] = e(r2)	
	}
	qui foreach grade of global grades{
		reg pct_sat_`grade' ib(2).`grade'classtype whiteasian gender `grade'freelunch whiteteacher`grade' masterteacher`grade' `grade'tyears i.`grade'schid, vce(cluster `grade'tchid)
		matrix TableV`grade'[1,4] = _b[1.`grade'classtype]
		matrix TableV`grade'[2,4] = _se[1.`grade'classtype]
		matrix TableV`grade'[3,4] = _b[3.`grade'classtype]
		matrix TableV`grade'[4,4] = _se[3.`grade'classtype]
		matrix TableV`grade'[5,4] = _b[whiteasian]
		matrix TableV`grade'[6,4] = _se[whiteasian]
		matrix TableV`grade'[7,4] = _b[gender]
		matrix TableV`grade'[8,4] = _se[gender]
		matrix TableV`grade'[9,4] = _b[`grade'freelunch]
		matrix TableV`grade'[10,4] = _se[`grade'freelunch]
		matrix TableV`grade'[11,4] = _b[whiteteacher`grade']
		matrix TableV`grade'[12,4] = _se[whiteteacher`grade']
		matrix TableV`grade'[13,4] = _b[`grade'tyears]
		matrix TableV`grade'[14,4] = _se[`grade'tyears]
		matrix TableV`grade'[15,4] = _b[masterteacher`grade']
		matrix TableV`grade'[16,4] = _se[masterteacher`grade']	
		matrix TableV`grade'[17,4] = 1
		matrix TableV`grade'[18,4] = e(r2)	
	}
	qui foreach grade of global grades{
		reg pct_sat_`grade' ib(2).firstclasstype, vce(cluster `grade'tchid)
		matrix TableV`grade'[1,5] = _b[1.firstclasstype]
		matrix TableV`grade'[2,5] = _se[1.firstclasstype]
		matrix TableV`grade'[3,5] = _b[3.firstclasstype]
		matrix TableV`grade'[4,5] = _se[3.firstclasstype]
		matrix TableV`grade'[17,5] = 0
		matrix TableV`grade'[18,5] = e(r2)	
	}
	qui foreach grade of global grades{
		reg pct_sat_`grade' ib(2).firstclasstype i.`grade'schid, vce(cluster `grade'tchid)
		matrix TableV`grade'[1,6] = _b[1.firstclasstype]
		matrix TableV`grade'[2,6] = _se[1.firstclasstype]
		matrix TableV`grade'[3,6] = _b[3.firstclasstype]
		matrix TableV`grade'[4,6] = _se[3.firstclasstype]
		matrix TableV`grade'[17,6] = 1
		matrix TableV`grade'[18,6] = e(r2)	
	}
	qui foreach grade of global grades{
		reg pct_sat_`grade' ib(2).firstclasstype whiteasian gender `grade'freelunch i.`grade'schid, vce(cluster `grade'tchid)
		matrix TableV`grade'[1,7] = _b[1.firstclasstype]
		matrix TableV`grade'[2,7] = _se[1.firstclasstype]
		matrix TableV`grade'[3,7] = _b[3.firstclasstype]
		matrix TableV`grade'[4,7] = _se[3.firstclasstype]
		matrix TableV`grade'[5,7] = _b[whiteasian]
		matrix TableV`grade'[6,7] = _se[whiteasian]
		matrix TableV`grade'[7,7] = _b[gender]
		matrix TableV`grade'[8,7] = _se[gender]
		matrix TableV`grade'[9,7] = _b[`grade'freelunch]
		matrix TableV`grade'[10,7] = _se[`grade'freelunch]
		matrix TableV`grade'[17,7] = 1
		matrix TableV`grade'[18,7] = e(r2)	
	}
	qui foreach grade of global grades{
		reg pct_sat_`grade' ib(2).firstclasstype whiteasian gender `grade'freelunch whiteteacher`grade' masterteacher`grade' `grade'tyears i.`grade'schid, vce(cluster `grade'tchid)
		matrix TableV`grade'[1,8] = _b[1.firstclasstype]
		matrix TableV`grade'[2,8] = _se[1.firstclasstype]
		matrix TableV`grade'[3,8] = _b[3.firstclasstype]
		matrix TableV`grade'[4,8] = _se[3.firstclasstype]
		matrix TableV`grade'[5,8] = _b[whiteasian]
		matrix TableV`grade'[6,8] = _se[whiteasian]
		matrix TableV`grade'[7,8] = _b[gender]
		matrix TableV`grade'[8,8] = _se[gender]
		matrix TableV`grade'[9,8] = _b[`grade'freelunch]
		matrix TableV`grade'[10,8] = _se[`grade'freelunch]
		matrix TableV`grade'[11,8] = _b[whiteteacher`grade']
		matrix TableV`grade'[12,8] = _se[whiteteacher`grade']
		matrix TableV`grade'[13,8] = _b[`grade'tyears]
		matrix TableV`grade'[14,8] = _se[`grade'tyears]
		matrix TableV`grade'[15,8] = _b[masterteacher`grade']
		matrix TableV`grade'[16,8] = _se[masterteacher`grade']	
		matrix TableV`grade'[17,8] = 1
		matrix TableV`grade'[18,8] = e(r2)
	}
	

*** Table I ***

		qui foreach grade of global grades{		
			*Todo: Confirm that we have the correct entry in STAR
			*Tip: Use "return list" to see available numbers
				matrix TableI`grade' = J(6, 4, .)
				matrix colnames TableI`grade' = "Small" "Regular" "Regular/Aide" "Joint P-Value"
				matrix rownames TableI`grade' = "Free Lunch" "White/Asian" "Age in 1985" "Attrition" "Class Size" "Percentile Score" 
		
			**Free Lunch**
				reg `grade'freelunch ibn.`grade'classtype if gradeenter=="`grade'", noconstant
				matrix TableI`grade'[1,1] = _b[1.`grade'classtype]
				matrix TableI`grade'[1,2] = _b[2.`grade'classtype]
				matrix TableI`grade'[1,3] = _b[3.`grade'classtype]
				test i1.`grade'classtype == i2.`grade'classtype == i3.`grade'classtype
				matrix TableI`grade'[1,4] = r(p)
			**White Asian**
				reg whiteasian ibn.`grade'classtype if gradeenter=="`grade'", noconstant
				matrix TableI`grade'[2,1] = _b[1.`grade'classtype]
				matrix TableI`grade'[2,2] = _b[2.`grade'classtype]
				matrix TableI`grade'[2,3] = _b[3.`grade'classtype]
				test i1.`grade'classtype == i2.`grade'classtype == i3.`grade'classtype
				matrix TableI`grade'[2,4] = r(p)

			**Age in 1985**
				reg age85 ibn.`grade'classtype if gradeenter=="`grade'", noconstant
				matrix TableI`grade'[3,1] = _b[1.`grade'classtype]
				matrix TableI`grade'[3,2] = _b[2.`grade'classtype]
				matrix TableI`grade'[3,3] = _b[3.`grade'classtype]
				test i1.`grade'classtype == i2.`grade'classtype == i3.`grade'classtype
				matrix TableI`grade'[3,4] = r(p)

			**Attrition**
				reg attritions`grade' ibn.`grade'classtype if gradeenter=="`grade'", noconstant
				matrix TableI`grade'[4,1] = _b[1.`grade'classtype]
				matrix TableI`grade'[4,2] = _b[2.`grade'classtype]
				matrix TableI`grade'[4,3] = _b[3.`grade'classtype]
				test i1.`grade'classtype == i2.`grade'classtype == i3.`grade'classtype
				matrix TableI`grade'[4,4] = r(p)

			**Class Size**
				reg `grade'classsize ibn.`grade'classtype if gradeenter=="`grade'", noconstant
				matrix TableI`grade'[5,1] = _b[1.`grade'classtype]
				matrix TableI`grade'[5,2] = _b[2.`grade'classtype]
				matrix TableI`grade'[5,3] = _b[3.`grade'classtype]
				test i1.`grade'classtype == i2.`grade'classtype == i3.`grade'classtype
				matrix TableI`grade'[5,4] = r(p)

			**Percentile**
				reg pct_sat_`grade' ibn.`grade'classtype if gradeenter=="`grade'", noconstant
				matrix TableI`grade'[6,1] = _b[1.`grade'classtype]
				matrix TableI`grade'[6,2] = _b[2.`grade'classtype]
				matrix TableI`grade'[6,3] = _b[3.`grade'classtype]
				test i1.`grade'classtype == i2.`grade'classtype == i3.`grade'classtype
				matrix TableI`grade'[6,4] = r(p)

		}

*** Density Graph ***
	qui foreach grade of global grades{	
		twoway kdensity pct_sat_`grade' if `grade'classtype == 1|| kdensity pct_sat_`grade' if `grade'classtype != 1, recast(line) lc(red)
		*Todo: Find a way to change the labels
		graph export density_pct_sat_`grade'.png
	}
	
*** Table II ***
	qui matrix TableII = J(6, 4, .)
	matrix colnames TableII = "K" "1" "2" "3"
	matrix rownames TableII = "Free Lunch" "White/Asian" "Age" "Attrition" "Actual Class Size" "Percentile Score" 	
	qui gen n = 1
	qui foreach grade of global grades{	
		qui reg `grade'freelunch ibn.`grade'classtype i.`grade'schid if gradeenter=="`grade'", noconstant
		qui test i1.`grade'classtype == i2.`grade'classtype == i3.`grade'classtype
		matrix TableII[1,n] = r(p)
		qui reg whiteasian ibn.`grade'classtype i.`grade'schid if gradeenter=="`grade'", noconstant
		qui test i1.`grade'classtype == i2.`grade'classtype == i3.`grade'classtype
		matrix TableII[2,n] = r(p)
		qui reg age85 ibn.`grade'classtype i.`grade'schid if gradeenter=="`grade'", noconstant
		qui test i1.`grade'classtype == i2.`grade'classtype == i3.`grade'classtype
		matrix TableII[3,n] = r(p)
		qui reg attritions`grade' ibn.`grade'classtype i.`grade'schid if gradeenter=="`grade'", noconstant
		qui test i1.`grade'classtype == i2.`grade'classtype == i3.`grade'classtype
		matrix TableII[4,n] = r(p)
		qui reg `grade'classsize ibn.`grade'classtype i.`grade'schid if gradeenter=="`grade'", noconstant
		qui test i1.`grade'classtype == i2.`grade'classtype == i3.`grade'classtype
		matrix TableII[5,n] = r(p)
		qui reg pct_sat_`grade' ibn.`grade'classtype i.`grade'schid if gradeenter=="`grade'", noconstant
		qui test i1.`grade'classtype == i2.`grade'classtype == i3.`grade'classtype
		matrix TableII[6,n] = r(p)
		replace n = n+1
	}
	qui drop n
	
	
*** Table III ***
	*Todo: Check if we need to replace gkclasstype=1 if gkclasstype==.
	*Todo: Check if we are replacing correcly replace
	*Todo: Test for grade entered
	qui matrix TableIII = J(20, 3, .)
	qui matrix colnames TableIII = "Small" "Regular" "Aide"
	qui matrix rowname TableIII = "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22" "23" "24" "25" "26" "27" "28" "29" "30" "Average Class Size"
	qui forvalues i = 12(1)30{
		sum g1classtype if g1classsize == `i' & g1classtype == 1
		matrix TableIII[`i'-11,1] = r(N)
		sum g1classtype if g1classsize == `i' & g1classtype == 2
		matrix TableIII[`i'-11,2] = r(N)
		sum g1classtype if g1classsize == `i' & g1classtype == 3
		matrix TableIII[`i'-11,3] = r(N)
	}
	qui sum g1classsize if g1classtype == 1
	qui matrix TableIII[20,1] = r(mean)
	qui sum g1classsize if g1classtype == 2
	qui matrix TableIII[20,2] = r(mean)
	qui sum g1classsize if g1classtype == 3
	qui matrix TableIII[20,3] = r(mean)
	
 
*** Table VII ***
	qui matrix TableVII = J(8, 3, .)
	matrix colnames TableVII = "OLS" "2SLS" "Sample Size"
	matrix rownames TableVII = "K" "." "1" "." "2" "." "3" "."
	qui gen n = 1
	qui foreach grade of global grades{
		*Todo: Add the weakivtest here if possible
		reg pct_sat_`grade' `grade'classsize whiteasian gender `grade'freelunch whiteteacher`grade' masterteacher`grade' i.`grade'tyears i.`grade'schid, vce(cluster `grade'tchid)
		matrix TableVII[n,1] = _b[`grade'classsize]
		matrix TableVII[n+1,1] = _se[`grade'classsize]
		ivregress 2sls pct_sat_`grade' (`grade'classsize = i.`grade'classtype) whiteasian gender `grade'freelunch whiteteacher`grade' masterteacher`grade' i.`grade'tyears i.`grade'schid, vce(cluster `grade'tchid)
		matrix TableVII[n,2] = _b[`grade'classsize]
		matrix TableVII[n+1,2] = _se[`grade'classsize]
		matrix TableVII[n,3] = e(N)
		replace n = n+2
		*weakivtest
	}
	qui drop n

*** Save Results as txt***	
	*Note: If there are already .txt files with the same names the tables will be added to the existing files instead of overwriting. That's the option "append" below
	qui global Tables TableIgk TableIg1 TableIg2 TableIg3 TableII TableIII TableVgk TableVg1 TableVg2 TableVg3 TableVII
	foreach table of global Tables{
		mat2txt, matrix(`table') saving(`table') append
	}
	
*** Display Results ***
	
	**Display Table I**
		*Kindergarten*
		matrix list TableIgk
		*First Grade*
		matrix list TableIg1
		*Second Grade*
		matrix list TableIg2
		*Third Grade*
		matrix list TableIg3

	**Display Table II**
		matrix list TableII

	**Display Table III**
		matrix list TableIII

	**Display Table V**
		*Kindergarten*
		matrix list TableVgk
		*First Grade*
		matrix list TableVg1
		*Second Grade*
		matrix list TableVg2
		*Third Grade*
		matrix list TableVg3
		**Display Table VII**
		matrix list TableVII
		
