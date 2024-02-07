***************************************************************************

clear
est clear
set matsize 11000



******User
global DRIVE 	"//rdsfcifs.acrc.bris.ac.uk/GeneEnvironment_Interactions/UKB/"
global OUTPUT	"C:/Users/pk20062/Dropbox/DONNI - UKB birth location accuracy/output/"






*** Load sibling birth location dataset:
use "${DRIVE}GeographicID/Projects/NV_Papers/Birth locations/dta/sibling_birth_location_data.dta", clear







************************************************
*** Comparison of initial assessment centres ***
************************************************


*** Use both siblings as observations (since they may have attended different centres):
replace district_different = F.district_different if sibling_id==1
replace age_gap = F.age_gap if sibling_id==1






*** Graph with share of siblings born in different districts across the different assessment centres:
mean district_different, over(assessment_centre_alpha) vce(cluster family_id)
reg district_different ibn.assessment_centre_alpha, nocons cluster(family_id)
est store diff_distr_centres

coefplot diff_distr_centres, ///
			xtitle("Share") ///
			xlabel(0 (0.2) 1) xscale(range(0 1)) ///
			ytitle("Initial assessment centre") ///
			baselevels omitted scheme(s1mono) grid(none) sort	

graph export "${OUTPUT}/graphs/by centre/share_different_district_by_centre_sorted.png", width(2000) replace
graph export "${OUTPUT}/graphs/by centre/share_different_district_by_centre_sorted.pdf", replace

// Source data:
preserve

qui reg district_different ibn.assessment_centre_alpha, nocons cluster(family_id)

matrix A=r(table)'
svmat A, names(col)

sum assessment_centre_alpha
local max=r(max)
gen centre=""
forvalues i=1/`max'{
	local label: label (assessment_centre_alpha) `i'
	di "`label'"
	replace centre="`label'" if _n==`i'
}

keep centre b ll ul
keep if b!=.
order centre b ll ul
sort b

rename b share
rename ll ci95_lower
rename ul ci95_upper
export delimited "${OUTPUT}/graphs/by centre/share_different_district_by_centre_sorted_source_data.csv", replace

restore



		
		
		
*** Estimate p separately for each assessment centre - but impose a single q for all:
reg district_different ibn.assessment_centre_alpha age_gap, nocons cluster(family_id)
est store diff_distr_centres_age1

nlcom 	(p1: 1-sqrt(1-_b[1.assessment_centre_alpha])) ///
		(p2: 1-sqrt(1-_b[2.assessment_centre_alpha])) ///
		(p3: 1-sqrt(1-_b[3.assessment_centre_alpha])) ///
		(p4: 1-sqrt(1-_b[4.assessment_centre_alpha])) ///
		(p5: 1-sqrt(1-_b[5.assessment_centre_alpha])) ///
		(p6: 1-sqrt(1-_b[6.assessment_centre_alpha])) ///
		(p7: 1-sqrt(1-_b[7.assessment_centre_alpha])) ///
		(p8: 1-sqrt(1-_b[8.assessment_centre_alpha])) ///
		(p9: 1-sqrt(1-_b[9.assessment_centre_alpha])) ///
		(p10: 1-sqrt(1-_b[10.assessment_centre_alpha])) ///
		(p11: 1-sqrt(1-_b[11.assessment_centre_alpha])) ///
		(p12: 1-sqrt(1-_b[12.assessment_centre_alpha])) ///
		(p13: 1-sqrt(1-_b[13.assessment_centre_alpha])) ///
		(p14: 1-sqrt(1-_b[14.assessment_centre_alpha])) ///
		(p15: 1-sqrt(1-_b[15.assessment_centre_alpha])) ///
		(p16: 1-sqrt(1-_b[16.assessment_centre_alpha])) ///
		(p17: 1-sqrt(1-_b[17.assessment_centre_alpha])) ///
		(p18: 1-sqrt(1-_b[18.assessment_centre_alpha])) ///
		(p19: 1-sqrt(1-_b[19.assessment_centre_alpha])) ///
		(p20: 1-sqrt(1-_b[20.assessment_centre_alpha])) ///
		(p21: 1-sqrt(1-_b[21.assessment_centre_alpha])) ///
		(p22: 1-sqrt(1-_b[22.assessment_centre_alpha])) ///
		, post
		
est store diff_distr_centres_age_p

coefplot diff_distr_centres_age_p, ///
			keep(p*) ///
			xtitle("Estimate of p", margin(0 0 0 2)) ///
			xlabel(0 (0.1) 0.5) xscale(range(0 0.5)) ///
			ytitle("Initial assessment centre") ///
			rename(p1=Barts p2=Birmingham p3=Bristol p4=Bury p5=Cardiff ///
			p6=Croydon p7=Edinburgh p8=Glasgow p9=Hounslow p10=Leeds ///
			p11=Liverpool p12=Manchester p13=Middlesborough p14=Newcastle ///
			p15=Nottingham p16=Oxford p17=Reading p18=Sheffield ///
			p19=Stockport(pilot) p20=Stoke p21=Swansea p22=Wrexham) ///
			baselevels omitted scheme(s1mono) grid(none) sort
		
graph export "${OUTPUT}/graphs/by centre/district_p_by_centre_qjoint_sorted.png", width(2000) replace
graph export "${OUTPUT}/graphs/by centre/district_p_by_centre_qjoint_sorted.pdf", replace	
			
// Source data:
preserve

qui reg district_different ibn.assessment_centre_alpha age_gap, nocons cluster(family_id)
qui nlcom 	(p1: 1-sqrt(1-_b[1.assessment_centre_alpha])) ///
		(p2: 1-sqrt(1-_b[2.assessment_centre_alpha])) ///
		(p3: 1-sqrt(1-_b[3.assessment_centre_alpha])) ///
		(p4: 1-sqrt(1-_b[4.assessment_centre_alpha])) ///
		(p5: 1-sqrt(1-_b[5.assessment_centre_alpha])) ///
		(p6: 1-sqrt(1-_b[6.assessment_centre_alpha])) ///
		(p7: 1-sqrt(1-_b[7.assessment_centre_alpha])) ///
		(p8: 1-sqrt(1-_b[8.assessment_centre_alpha])) ///
		(p9: 1-sqrt(1-_b[9.assessment_centre_alpha])) ///
		(p10: 1-sqrt(1-_b[10.assessment_centre_alpha])) ///
		(p11: 1-sqrt(1-_b[11.assessment_centre_alpha])) ///
		(p12: 1-sqrt(1-_b[12.assessment_centre_alpha])) ///
		(p13: 1-sqrt(1-_b[13.assessment_centre_alpha])) ///
		(p14: 1-sqrt(1-_b[14.assessment_centre_alpha])) ///
		(p15: 1-sqrt(1-_b[15.assessment_centre_alpha])) ///
		(p16: 1-sqrt(1-_b[16.assessment_centre_alpha])) ///
		(p17: 1-sqrt(1-_b[17.assessment_centre_alpha])) ///
		(p18: 1-sqrt(1-_b[18.assessment_centre_alpha])) ///
		(p19: 1-sqrt(1-_b[19.assessment_centre_alpha])) ///
		(p20: 1-sqrt(1-_b[20.assessment_centre_alpha])) ///
		(p21: 1-sqrt(1-_b[21.assessment_centre_alpha])) ///
		(p22: 1-sqrt(1-_b[22.assessment_centre_alpha])) ///
		, post

matrix A=r(table)'
svmat A, names(col)

sum assessment_centre_alpha
local max=r(max)
gen centre=""
forvalues i=1/`max'{
	local label: label (assessment_centre_alpha) `i'
	di "`label'"
	replace centre="`label'" if _n==`i'
}

keep centre b ll ul
keep if b!=.
order centre b ll ul
sort b

rename b p
rename ll ci95_lower
rename ul ci95_upper
export delimited "${OUTPUT}/graphs/by centre/district_p_by_centre_qjoint_sorted_source_data.csv", replace

restore
