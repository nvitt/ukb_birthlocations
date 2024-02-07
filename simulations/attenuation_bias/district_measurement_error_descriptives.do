***************************************************************************

clear all
est clear
set matsize 11000
set maxvar 120000


******User
global DRIVE 	"//rdsfcifs.acrc.bris.ac.uk/GeneEnvironment_Interactions/UKB/"
global OUTPUT	"C:/Users/pk20062/Dropbox/DONNI - UKB birth location accuracy/"




*** Set seed:
set seed 15041855



*** Simulate birth-date fixed effects:
set obs 395
gen birth_date=-274+_n
forvalues i=1/220 {
	gen birth_date_fe_`i'=rnormal()
	qui sum birth_date_fe_`i'
	replace birth_date_fe_`i' = (birth_date_fe_`i' - r(mean)) / (r(sd))
}

tempfile birth_date_fe
save "`birth_date_fe'"





*** Load simulated district-level data:
insheet using "${OUTPUT}gis_data/simulations/district_spatial_simulations.txt", clear

rename g_unit gid

expand 395

bysort gid: gen birth_date=-274+_n

merge m:1 birth_date using "`birth_date_fe'"
drop _merge

local i=1
foreach var of varlist rho* {
		qui sum `var'
		replace `var' = (`var' - r(mean)) / (r(sd))
		
		rename birth_date_fe_`i' fe_`var'
		
		local i=`i'+1
}

order gid birth_date
sort gid birth_date

tempfile district_date_data
save "`district_date_data'"










*** Load sibling birth location dataset:
use "${DRIVE}GeographicID/Projects/NV_Papers/Birth locations/dta/sibling_birth_location_data.dta", clear
keep family_id sibling_id birth_date age_gap gid birth_easting birth_northing

*** Set as panel:
sort family_id sibling_id
xtset family_id sibling_id





*** Sibling's district:
gen sibling_gid = L.gid if sibling_id==2
replace sibling_gid = F.gid if sibling_id==1


*** Merge in nearest district to midpoint between sibling birth locations:
gen double midpoint_easting = (birth_easting + L.birth_easting)/2 if sibling_id==2
replace midpoint_easting = (birth_easting + F.birth_easting)/2 if sibling_id==1
gen double midpoint_northing = (birth_northing + L.birth_northing)/2 if sibling_id==2
replace midpoint_northing = (birth_northing + F.birth_northing)/2 if sibling_id==1
merge m:1 midpoint_easting midpoint_northing using "${DRIVE}GeographicID/Projects/NV_Papers/Birth locations/dta/sibling_midpoint_data.dta", keepusing(midpoint_nearest_gid)
drop _merge

drop midpoint_easting midpoint_northing birth_easting birth_northing



*** Merge in simulated district-level data based on own district:
merge m:1 gid birth_date using "`district_date_data'" // not matched districts from birth location data are island districts without direct neighbours for which we could not simulate spatial data AND Fife district (10032829) which covers multiple districts in spatial data(?!)
drop if _merge==2
drop _merge

rename rho* simulation_rho*





*** Merge in simulated district-level data based on sibling's district:
rename gid original_gid
rename sibling_gid gid

merge m:1 gid birth_date using "`district_date_data'" // not matched districts from birth location data are island districts without direct neighbours for which we could not simulate spatial data AND Fife district (10032829) which covers multiple districts in spatial data(?!)
drop if _merge==2
drop _merge

rename rho* simulation_rho*_sibdistr


rename gid sibling_gid 





*** Merge in simulated district-level data based on midpoint between sibling's birth locations:
rename midpoint_nearest_gid gid

merge m:1 gid birth_date using "`district_date_data'" // not matched districts from birth location data are island districts without direct neighbours for which we could not simulate spatial data AND Fife district (10032829) which covers multiple districts in spatial data(?!)
drop if _merge==2
drop _merge

rename rho* simulation_rho*_middistr


rename gid midpoint_nearest_gid



*** Limit sample to observations with valid distr, sibdistr and middistr simulated variables:
keep if simulation_rho0_1!=. & simulation_rho0_1_sibdistr!=. & simulation_rho0_1_middistr!=.








*** Normalize simulated data and create measurement error variables:
sum simulation_rho*
foreach var of varlist simulation_rho* {
	if strpos("`var'","_sibdistr") == 0 & strpos("`var'","_middistr") == 0 {
		qui sum `var'
		replace `var' = (`var' - r(mean)) / (r(sd))
		replace `var'_sibdistr = (`var'_sibdistr - r(mean)) / (r(sd))
		replace `var'_middistr = (`var'_middistr - r(mean)) / (r(sd))
		gen diff_`var' = `var' - `var'_sibdistr
		gen mse_`var' = (`var' - `var'_sibdistr)^2
	}
}
sum simulation_rho*
sum mse_* if original_gid==sibling_gid
sum mse_* if original_gid!=sibling_gid
sum mse_*











*** Simulate with individual probability of incorrect district p = 0.158 and annual move probability q = 0.009
keep if  simulation_rho0_1!=. & simulation_rho0_1_sibdistr!=.
sort family_id sibling_id
gen error_prob = (2*0.158-0.158^2) / (2*0.158 - 0.158^2 + 0.009 * age_gap) if original_gid!=sibling_gid
gen both_error_prob = 0.158^2 / (2*0.158-0.158^2) if original_gid!=sibling_gid

capture program drop simulation
program define simulation, rclass
	
	syntax varlist
		
	di "`1'"
	di "$repnum "
	
	cap drop district_error both_sib which_sib x x_obs
	
	gen district_error = rbinomial(1,error_prob) if sibling_id==2 & original_gid!=sibling_gid
	replace district_error = 1 if district_error==. & error_prob==1
	
	gen both_sib = rbinomial(1,both_error_prob) if district_error==1
	replace both_sib = F.both_sib if sibling_id==1
	
	gen which_sib = 1+rbinomial(1,0.5) if district_error==1 & both_sib==0
	
	replace district_error = 1 if F.both_sib==1 & sibling_id==1
	replace district_error = 1 if F.district_error==1 & F.which_sib==1 & sibling_id==1
	replace district_error = 0 if F.district_error==1 & F.which_sib==2 & sibling_id==1
	replace district_error = 0 if F.district_error==0 & sibling_id==1
	replace district_error = 0 if district_error==1 & which_sib==1 & sibling_id==2
	replace district_error = 0 if original_gid==sibling_gid
	
	gen x = `1'
	
	replace x = `1'_sibd if district_error==1 & both_sib==0
	replace x = `1'_midd if district_error==1 & both_sib==1
	
	gen x_obs = `1'
	
	gen u_`1'_r$repnum = x_obs - x
	gen x_`1'_r$repnum = x
		
	global repnum = $repnum + 1
	
end

drop *_rho005_* *_rho01_* *_rho02_*  *_rho025_* *_rho035_* *_rho04_* *_rho05_*  *_rho055_* *_rho065_* *_rho07_* *_rho08_*  *_rho085_* *_rho095_* *_rho0975_* *_rho0999_*


* Get variables with simulated data:
qui ds simulation_rho*
global sim_variables "`r(varlist)'"
di "$sim_variables"



* Run simulations and save results in temporary files:
foreach var of global sim_variables {
	if strpos("`var'","_sibdistr") == 0 &  strpos("`var'","_middistr") == 0 {
		
		local fe_var = subinstr("`var'","simulation_","fe_",.)
		
		forvalues i=0(2)10 {
			preserve

			gen `var'_k`i' = sqrt((10-`i')/10)*`var' + sqrt(`i'/10)*`fe_var'
			gen `var'_k`i'_sibd = sqrt((10-`i')/10)*`var'_sibdistr + sqrt(`i'/10)*`fe_var'
			gen `var'_k`i'_midd = sqrt((10-`i')/10)*`var'_middistr + sqrt(`i'/10)*`fe_var'
			
			qui sum `var'_k`i'
			replace `var'_k`i' = (`var'_k`i' - r(mean)) / (r(sd))
			replace `var'_k`i'_sibd = (`var'_k`i'_sibd - r(mean)) / (r(sd))
			replace `var'_k`i'_midd = (`var'_k`i'_midd - r(mean)) / (r(sd))
			
			global repnum = 1
			forvalues r=1/10 {
				simulation `var'_k`i'
			}
			
			keep u_simulation_rho* x_simulation_rho*
			
			tempfile t_`var'_`i'
			save "`t_`var'_`i''", replace

			restore	
		}
		
	}
}


* Combine simulation results:
local j=1

clear
foreach var of global sim_variables {
	if strpos("`var'","_sibdistr") == 0 & strpos("`var'","_middistr") == 0 {
		forvalues i=0(2)10 {
			if `j'==1 {
				use "`t_`var'_`i''", clear
			} 
			else {
				merge 1:1 _n using "`t_`var'_`i''", nogenerate
			}
			local j=`j'+1
		}
	}
}


rename u_simulation_rho* urho*
rename x_simulation_rho* xrho*

foreach var of varlist urho* {
	local rho=substr("`var'",5,strpos("`var'","_")-5)
	local k=substr("`var'",strpos("`var'","_k")+2,strpos("`var'","_r")-strpos("`var'","_k")-2)
	local sim=substr("`var'",strpos("`var'","_")+1,strpos("`var'","_k")-strpos("`var'","_")-1)
	local r=substr("`var'",strpos("`var'","_r")+2,.)
	local num = `sim'*10+`r'-10
	
	rename `var' u_rho`rho'_k`k'_`num'
}

foreach var of varlist xrho* {
	local rho=substr("`var'",5,strpos("`var'","_")-5)
	local k=substr("`var'",strpos("`var'","_k")+2,strpos("`var'","_r")-strpos("`var'","_k")-2)
	local sim=substr("`var'",strpos("`var'","_")+1,strpos("`var'","_k")-strpos("`var'","_")-1)
	local r=substr("`var'",strpos("`var'","_r")+2,.)
	local num = `sim'*10+`r'-10
	
	rename `var' x_rho`rho'_k`k'_`num'
}

order *, sequential

gen i=_n

* Get variables for reshape:
qui ds u_rho*_k*_1 x_rho*_k*_1
global reshape_variables=subinstr("`r(varlist)'","_1","_",.)
di "$reshape_variables"

reshape long "$reshape_variables", i(i) j(r)

rename u_*_ u_*
rename x_*_ x_*







*** Correlations of error and x:
foreach var of varlist u_* {
	if substr("`var'",-3,.)!="k10" {	
		local x_var = subinstr("`var'","u_","x_",1)
		estpost correlate `var' `x_var'
		est store corr_`var'
		
		ci2 `var' `x_var', corr
		matrix A = r(lb) \ r(ub)
		matrix colnames A = `x_var'
		estadd matrix ci_corr=A
	}
}

* Table:
esttab corr_u_rho0_*, ///
	cells(b(fmt(3)) ci_corr[1](fmt(3) par("[" "")) & ci_corr[2](fmt(3) par("" "]"))) incelldelimiter(",") ///
	collabels(none) nonumber ///
	mlabel("0%" "20%" "40%" "60%" "80%", lhs("Spatial autocorrelation (rho)")) ///
	mgroups("Variance share from time variation", pattern(1 0 0 0 0)) ///
	rename(x_rho0_k2 x_rho0_k0 x_rho0_k4 x_rho0_k0 x_rho0_k6 x_rho0_k0 x_rho0_k8 x_rho0_k0) ///
	coeflabels(x_rho0_k0 "rho = 0.00") ///
	noobs nonotes ///
	varwidth(30)
	
esttab corr_u_rho015_*, ///
	cells(b(fmt(3)) ci_corr[1](fmt(3) par("[" "")) & ci_corr[2](fmt(3) par("" "]"))) incelldelimiter(",") ///
	collabels(none) nonumber ///
	mlabel("0%" "20%" "40%" "60%" "80%", lhs("Spatial autocorrelation (rho)")) ///
	mgroups("Variance share from time variation", pattern(1 0 0 0 0)) ///
	rename(x_rho015_k2 x_rho015_k0 x_rho015_k4 x_rho015_k0 x_rho015_k6 x_rho015_k0 x_rho015_k8 x_rho015_k0) ///
	coeflabels(x_rho015_k0 "rho = 0.15") ///
	noobs nonotes ///
	varwidth(30)
	
esttab corr_u_rho03_*, ///
	cells(b(fmt(3)) ci_corr[1](fmt(3) par("[" "")) & ci_corr[2](fmt(3) par("" "]"))) incelldelimiter(",") ///
	collabels(none) nonumber ///
	mlabel("0%" "20%" "40%" "60%" "80%", lhs("Spatial autocorrelation (rho)")) ///
	mgroups("Variance share from time variation", pattern(1 0 0 0 0)) ///
	rename(x_rho03_k2 x_rho03_k0 x_rho03_k4 x_rho03_k0 x_rho03_k6 x_rho03_k0 x_rho03_k8 x_rho03_k0) ///
	coeflabels(x_rho03_k0 "rho = 0.30") ///
	noobs nonotes ///
	varwidth(30)
	
esttab corr_u_rho045_*, ///
	cells(b(fmt(3)) ci_corr[1](fmt(3) par("[" "")) & ci_corr[2](fmt(3) par("" "]"))) incelldelimiter(",") ///
	collabels(none) nonumber ///
	mlabel("0%" "20%" "40%" "60%" "80%", lhs("Spatial autocorrelation (rho)")) ///
	mgroups("Variance share from time variation", pattern(1 0 0 0 0)) ///
	rename(x_rho045_k2 x_rho045_k0 x_rho045_k4 x_rho045_k0 x_rho045_k6 x_rho045_k0 x_rho045_k8 x_rho045_k0) ///
	coeflabels(x_rho045_k0 "rho = 0.45") ///
	noobs nonotes ///
	varwidth(30)
	
esttab corr_u_rho06_*, ///
	cells(b(fmt(3)) ci_corr[1](fmt(3) par("[" "")) & ci_corr[2](fmt(3) par("" "]"))) incelldelimiter(",") ///
	collabels(none) nonumber ///
	mlabel("0%" "20%" "40%" "60%" "80%", lhs("Spatial autocorrelation (rho)")) ///
	mgroups("Variance share from time variation", pattern(1 0 0 0 0)) ///
	rename(x_rho06_k2 x_rho06_k0 x_rho06_k4 x_rho06_k0 x_rho06_k6 x_rho06_k0 x_rho06_k8 x_rho06_k0) ///
	coeflabels(x_rho06_k0 "rho = 0.60") ///
	noobs nonotes ///
	varwidth(30)
	
esttab corr_u_rho075_*, ///
	cells(b(fmt(3)) ci_corr[1](fmt(3) par("[" "")) & ci_corr[2](fmt(3) par("" "]"))) incelldelimiter(",") ///
	collabels(none) nonumber ///
	mlabel("0%" "20%" "40%" "60%" "80%", lhs("Spatial autocorrelation (rho)")) ///
	mgroups("Variance share from time variation", pattern(1 0 0 0 0)) ///
	rename(x_rho075_k2 x_rho075_k0 x_rho075_k4 x_rho075_k0 x_rho075_k6 x_rho075_k0 x_rho075_k8 x_rho075_k0) ///
	coeflabels(x_rho075_k0 "rho = 0.75") ///
	noobs nonotes ///
	varwidth(30)
	
esttab corr_u_rho09_*, ///
	cells(b(fmt(3)) ci_corr[1](fmt(3) par("[" "")) & ci_corr[2](fmt(3) par("" "]"))) incelldelimiter(",") ///
	collabels(none) nonumber ///
	mlabel("0%" "20%" "40%" "60%" "80%", lhs("Spatial autocorrelation (rho)")) ///
	mgroups("Variance share from time variation", pattern(1 0 0 0 0)) ///
	rename(x_rho09_k2 x_rho09_k0 x_rho09_k4 x_rho09_k0 x_rho09_k6 x_rho09_k0 x_rho09_k8 x_rho09_k0) ///
	coeflabels(x_rho09_k0 "rho = 0.90") ///
	noobs nonotes ///
	varwidth(30)

	
	
	

* Latex:
esttab corr_u_rho0_* using "${OUTPUT}/output/tablefragments/error_correlations.tex", ///
	cells(b(fmt(3)) ci_corr[1](fmt(3) par("[" "")) & ci_corr[2](fmt(3) par("" "]"))) incelldelimiter(",") ///
	collabels(none) nonumber ///
	mlabel("0\%" "20\%" "40\%" "60\%" "80\%" , lhs("Spatial autocorrelation ($\rho$)") prefix({) suffix(})) ///
	mgroups("Variance share from time variation (k)", pattern(1 0 0 0 0) ///
	span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) ///
	rename(x_rho0_k2 x_rho0_k0 x_rho0_k4 x_rho0_k0 x_rho0_k6 x_rho0_k0 x_rho0_k8 x_rho0_k0) ///
	coeflabels(x_rho0_k0 "$\rho= 0.00$") ///
	noobs nonotes ///
	compress replace booktabs fragment
	
esttab corr_u_rho015_* using "${OUTPUT}/output/tablefragments/error_correlations.tex", ///
	cells(b(fmt(3)) ci_corr[1](fmt(3) par("[" "")) & ci_corr[2](fmt(3) par("" "]"))) incelldelimiter(",") ///
	collabels(none) nonumber ///
	mlabel(none) ///
	rename(x_rho015_k2 x_rho015_k0 x_rho015_k4 x_rho015_k0 x_rho015_k6 x_rho015_k0 x_rho015_k8 x_rho015_k0) ///
	coeflabels(x_rho015_k0 "$\rho = 0.15$") ///
	noobs nonotes ///
	compress append booktabs fragment
	
esttab corr_u_rho03_* using "${OUTPUT}/output/tablefragments/error_correlations.tex", ///
	cells(b(fmt(3)) ci_corr[1](fmt(3) par("[" "")) & ci_corr[2](fmt(3) par("" "]"))) incelldelimiter(",") ///
	collabels(none) nonumber ///
	mlabel(none) ///
	rename(x_rho03_k2 x_rho03_k0 x_rho03_k4 x_rho03_k0 x_rho03_k6 x_rho03_k0 x_rho03_k8 x_rho03_k0) ///
	coeflabels(x_rho03_k0 "$\rho = 0.30$") ///
	noobs nonotes ///
	compress append booktabs fragment
	
esttab corr_u_rho045_* using "${OUTPUT}/output/tablefragments/error_correlations.tex", ///
	cells(b(fmt(3)) ci_corr[1](fmt(3) par("[" "")) & ci_corr[2](fmt(3) par("" "]"))) incelldelimiter(",") ///
	collabels(none) nonumber ///
	mlabel(none) ///
	rename(x_rho045_k2 x_rho045_k0 x_rho045_k4 x_rho045_k0 x_rho045_k6 x_rho045_k0 x_rho045_k8 x_rho045_k0) ///
	coeflabels(x_rho045_k0 "$\rho = 0.45$") ///
	noobs nonotes ///
	compress append booktabs fragment
	
esttab corr_u_rho06_* using "${OUTPUT}/output/tablefragments/error_correlations.tex", ///
	cells(b(fmt(3)) ci_corr[1](fmt(3) par("[" "")) & ci_corr[2](fmt(3) par("" "]"))) incelldelimiter(",") ///
	collabels(none) nonumber ///
	mlabel(none) ///
	rename(x_rho06_k2 x_rho06_k0 x_rho06_k4 x_rho06_k0 x_rho06_k6 x_rho06_k0 x_rho06_k8 x_rho06_k0) ///
	coeflabels(x_rho06_k0 "$\rho = 0.60$") ///
	noobs nonotes ///
	compress append booktabs fragment
	
esttab corr_u_rho075_* using "${OUTPUT}/output/tablefragments/error_correlations.tex", ///
	cells(b(fmt(3)) ci_corr[1](fmt(3) par("[" "")) & ci_corr[2](fmt(3) par("" "]"))) incelldelimiter(",") ///
	collabels(none) nonumber ///
	mlabel(none) ///
	rename(x_rho075_k2 x_rho075_k0 x_rho075_k4 x_rho075_k0 x_rho075_k6 x_rho075_k0 x_rho075_k8 x_rho075_k0) ///
	coeflabels(x_rho075_k0 "$\rho = 0.75$") ///
	noobs nonotes ///
	compress append booktabs fragment
	
esttab corr_u_rho09_* using "${OUTPUT}/output/tablefragments/error_correlations.tex", ///
	cells(b(fmt(3)) ci_corr[1](fmt(3) par("[" "")) & ci_corr[2](fmt(3) par("" "]"))) incelldelimiter(",") ///
	collabels(none) nonumber ///
	mlabel(none) ///
	rename(x_rho09_k2 x_rho09_k0 x_rho09_k4 x_rho09_k0 x_rho09_k6 x_rho09_k0 x_rho09_k8 x_rho09_k0) ///
	coeflabels(x_rho09_k0 "$\rho = 0.90$") ///
	noobs nonotes ///
	compress append booktabs fragment
	
	
	
	
	
	

*** Correlations of error and x - for non-zero errors only:
foreach var of varlist u_* {
	if substr("`var'",-3,.)!="k10" {	
		local x_var = subinstr("`var'","u_","x_",1)
		estpost correlate `var' `x_var' if `var'!=0
		est store corr_non0_`var'
		
		ci2 `var' `x_var' if `var'!=0, corr
		matrix A = r(lb) \ r(ub)
		matrix colnames A = `x_var'
		estadd matrix ci_corr=A
	}
}

* Table:
esttab corr_non0_u_rho0_*, ///
	cells(b(fmt(3)) ci_corr[1](fmt(3) par("[" "")) & ci_corr[2](fmt(3) par("" "]"))) incelldelimiter(",") ///
	collabels(none) nonumber ///
	mlabel("0%" "20%" "40%" "60%" "80%", lhs("Spatial autocorrelation (rho)")) ///
	mgroups("Variance share from time variation", pattern(1 0 0 0 0)) ///
	rename(x_rho0_k2 x_rho0_k0 x_rho0_k4 x_rho0_k0 x_rho0_k6 x_rho0_k0 x_rho0_k8 x_rho0_k0) ///
	coeflabels(x_rho0_k0 "rho = 0.00") ///
	noobs nonotes ///
	varwidth(30)
	
esttab corr_non0_u_rho015_*, ///
	cells(b(fmt(3)) ci_corr[1](fmt(3) par("[" "")) & ci_corr[2](fmt(3) par("" "]"))) incelldelimiter(",") ///
	collabels(none) nonumber ///
	mlabel("0%" "20%" "40%" "60%" "80%", lhs("Spatial autocorrelation (rho)")) ///
	mgroups("Variance share from time variation", pattern(1 0 0 0 0)) ///
	rename(x_rho015_k2 x_rho015_k0 x_rho015_k4 x_rho015_k0 x_rho015_k6 x_rho015_k0 x_rho015_k8 x_rho015_k0) ///
	coeflabels(x_rho015_k0 "rho = 0.15") ///
	noobs nonotes ///
	varwidth(30)
	
esttab corr_non0_u_rho03_*, ///
	cells(b(fmt(3)) ci_corr[1](fmt(3) par("[" "")) & ci_corr[2](fmt(3) par("" "]"))) incelldelimiter(",") ///
	collabels(none) nonumber ///
	mlabel("0%" "20%" "40%" "60%" "80%", lhs("Spatial autocorrelation (rho)")) ///
	mgroups("Variance share from time variation", pattern(1 0 0 0 0)) ///
	rename(x_rho03_k2 x_rho03_k0 x_rho03_k4 x_rho03_k0 x_rho03_k6 x_rho03_k0 x_rho03_k8 x_rho03_k0) ///
	coeflabels(x_rho03_k0 "rho = 0.30") ///
	noobs nonotes ///
	varwidth(30)
	
esttab corr_non0_u_rho045_*, ///
	cells(b(fmt(3)) ci_corr[1](fmt(3) par("[" "")) & ci_corr[2](fmt(3) par("" "]"))) incelldelimiter(",") ///
	collabels(none) nonumber ///
	mlabel("0%" "20%" "40%" "60%" "80%", lhs("Spatial autocorrelation (rho)")) ///
	mgroups("Variance share from time variation", pattern(1 0 0 0 0)) ///
	rename(x_rho045_k2 x_rho045_k0 x_rho045_k4 x_rho045_k0 x_rho045_k6 x_rho045_k0 x_rho045_k8 x_rho045_k0) ///
	coeflabels(x_rho045_k0 "rho = 0.45") ///
	noobs nonotes ///
	varwidth(30)
	
esttab corr_non0_u_rho06_*, ///
	cells(b(fmt(3)) ci_corr[1](fmt(3) par("[" "")) & ci_corr[2](fmt(3) par("" "]"))) incelldelimiter(",") ///
	collabels(none) nonumber ///
	mlabel("0%" "20%" "40%" "60%" "80%", lhs("Spatial autocorrelation (rho)")) ///
	mgroups("Variance share from time variation", pattern(1 0 0 0 0)) ///
	rename(x_rho06_k2 x_rho06_k0 x_rho06_k4 x_rho06_k0 x_rho06_k6 x_rho06_k0 x_rho06_k8 x_rho06_k0) ///
	coeflabels(x_rho06_k0 "rho = 0.60") ///
	noobs nonotes ///
	varwidth(30)
	
esttab corr_non0_u_rho075_*, ///
	cells(b(fmt(3)) ci_corr[1](fmt(3) par("[" "")) & ci_corr[2](fmt(3) par("" "]"))) incelldelimiter(",") ///
	collabels(none) nonumber ///
	mlabel("0%" "20%" "40%" "60%" "80%", lhs("Spatial autocorrelation (rho)")) ///
	mgroups("Variance share from time variation", pattern(1 0 0 0 0)) ///
	rename(x_rho075_k2 x_rho075_k0 x_rho075_k4 x_rho075_k0 x_rho075_k6 x_rho075_k0 x_rho075_k8 x_rho075_k0) ///
	coeflabels(x_rho075_k0 "rho = 0.75") ///
	noobs nonotes ///
	varwidth(30)
	
esttab corr_non0_u_rho09_*, ///
	cells(b(fmt(3)) ci_corr[1](fmt(3) par("[" "")) & ci_corr[2](fmt(3) par("" "]"))) incelldelimiter(",") ///
	collabels(none) nonumber ///
	mlabel("0%" "20%" "40%" "60%" "80%", lhs("Spatial autocorrelation (rho)")) ///
	mgroups("Variance share from time variation", pattern(1 0 0 0 0)) ///
	rename(x_rho09_k2 x_rho09_k0 x_rho09_k4 x_rho09_k0 x_rho09_k6 x_rho09_k0 x_rho09_k8 x_rho09_k0) ///
	coeflabels(x_rho09_k0 "rho = 0.90") ///
	noobs nonotes ///
	varwidth(30)

	
	
	

* Latex:
esttab corr_non0_u_rho0_* using "${OUTPUT}/output/tablefragments/nonzero_error_correlations.tex", ///
	cells(b(fmt(3)) ci_corr[1](fmt(3) par("[" "")) & ci_corr[2](fmt(3) par("" "]"))) incelldelimiter(",") ///
	collabels(none) nonumber ///
	mlabel("0\%" "20\%" "40\%" "60\%" "80\%" , lhs("Spatial autocorrelation ($\rho$)") prefix({) suffix(})) ///
	mgroups("Variance share from time variation (k)", pattern(1 0 0 0 0) ///
	span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) ///
	rename(x_rho0_k2 x_rho0_k0 x_rho0_k4 x_rho0_k0 x_rho0_k6 x_rho0_k0 x_rho0_k8 x_rho0_k0) ///
	coeflabels(x_rho0_k0 "$\rho= 0.00$") ///
	noobs nonotes ///
	compress replace booktabs fragment
	
esttab corr_non0_u_rho015_* using "${OUTPUT}/output/tablefragments/nonzero_error_correlations.tex", ///
	cells(b(fmt(3)) ci_corr[1](fmt(3) par("[" "")) & ci_corr[2](fmt(3) par("" "]"))) incelldelimiter(",") ///
	collabels(none) nonumber ///
	mlabel(none) ///
	rename(x_rho015_k2 x_rho015_k0 x_rho015_k4 x_rho015_k0 x_rho015_k6 x_rho015_k0 x_rho015_k8 x_rho015_k0) ///
	coeflabels(x_rho015_k0 "$\rho = 0.15$") ///
	noobs nonotes ///
	compress append booktabs fragment
	
esttab corr_non0_u_rho03_* using "${OUTPUT}/output/tablefragments/nonzero_error_correlations.tex", ///
	cells(b(fmt(3)) ci_corr[1](fmt(3) par("[" "")) & ci_corr[2](fmt(3) par("" "]"))) incelldelimiter(",") ///
	collabels(none) nonumber ///
	mlabel(none) ///
	rename(x_rho03_k2 x_rho03_k0 x_rho03_k4 x_rho03_k0 x_rho03_k6 x_rho03_k0 x_rho03_k8 x_rho03_k0) ///
	coeflabels(x_rho03_k0 "$\rho = 0.30$") ///
	noobs nonotes ///
	compress append booktabs fragment
	
esttab corr_non0_u_rho045_* using "${OUTPUT}/output/tablefragments/nonzero_error_correlations.tex", ///
	cells(b(fmt(3)) ci_corr[1](fmt(3) par("[" "")) & ci_corr[2](fmt(3) par("" "]"))) incelldelimiter(",") ///
	collabels(none) nonumber ///
	mlabel(none) ///
	rename(x_rho045_k2 x_rho045_k0 x_rho045_k4 x_rho045_k0 x_rho045_k6 x_rho045_k0 x_rho045_k8 x_rho045_k0) ///
	coeflabels(x_rho045_k0 "$\rho = 0.45$") ///
	noobs nonotes ///
	compress append booktabs fragment
	
esttab corr_non0_u_rho06_* using "${OUTPUT}/output/tablefragments/nonzero_error_correlations.tex", ///
	cells(b(fmt(3)) ci_corr[1](fmt(3) par("[" "")) & ci_corr[2](fmt(3) par("" "]"))) incelldelimiter(",") ///
	collabels(none) nonumber ///
	mlabel(none) ///
	rename(x_rho06_k2 x_rho06_k0 x_rho06_k4 x_rho06_k0 x_rho06_k6 x_rho06_k0 x_rho06_k8 x_rho06_k0) ///
	coeflabels(x_rho06_k0 "$\rho = 0.60$") ///
	noobs nonotes ///
	compress append booktabs fragment
	
esttab corr_non0_u_rho075_* using "${OUTPUT}/output/tablefragments/nonzero_error_correlations.tex", ///
	cells(b(fmt(3)) ci_corr[1](fmt(3) par("[" "")) & ci_corr[2](fmt(3) par("" "]"))) incelldelimiter(",") ///
	collabels(none) nonumber ///
	mlabel(none) ///
	rename(x_rho075_k2 x_rho075_k0 x_rho075_k4 x_rho075_k0 x_rho075_k6 x_rho075_k0 x_rho075_k8 x_rho075_k0) ///
	coeflabels(x_rho075_k0 "$\rho = 0.75$") ///
	noobs nonotes ///
	compress append booktabs fragment
	
esttab corr_non0_u_rho09_* using "${OUTPUT}/output/tablefragments/nonzero_error_correlations.tex", ///
	cells(b(fmt(3)) ci_corr[1](fmt(3) par("[" "")) & ci_corr[2](fmt(3) par("" "]"))) incelldelimiter(",") ///
	collabels(none) nonumber ///
	mlabel(none) ///
	rename(x_rho09_k2 x_rho09_k0 x_rho09_k4 x_rho09_k0 x_rho09_k6 x_rho09_k0 x_rho09_k8 x_rho09_k0) ///
	coeflabels(x_rho09_k0 "$\rho = 0.90$") ///
	noobs nonotes ///
	compress append booktabs fragment
	
	
	
	
	
	
*** Error histograms:
foreach var of varlist u_* {
	
	local rho=substr("`var'",6,strpos("`var'","_k")-6)
	if "`rho'"=="0" {
		local rho_decimal="0.0"
	}
	if "`rho'"!="0" {
		local rho_decimal=subinstr("`rho'","0","0.",1)
	}
	local k=substr("`var'",strpos("`var'","_k")+2,.)
	local k=`k'*10
	
	sum `var', detail
	sum `var' if `var'!=0, detail
	local min=floor(r(min))
	
	local title = "{it:{&rho}}=`rho_decimal', {it:k}=`k'%"
	
	hist `var', scheme(lean1) xtitle("") title("`title'", size(huge)) percent /// xscale(range(-7 7)) 
		yscale(range(0 100)) ///xlabel(-5 (5) 5) 
		ylabel(0 (20) 100)
	
	graph export "${OUTPUT}/output/graphs/error_histograms/error_hist_rho`rho'_k`k'.png", replace
	graph export "${OUTPUT}/output/graphs/error_histograms/error_hist_rho`rho'_k`k'.pdf", replace
	
	if `k'!=100 {	
		hist `var' if `var'!=0, start(`min') width(0.25) scheme(lean1) xtitle("") title("`title'", size(huge)) percent normal normopts(lcolor(red) lwidth(thick))  xscale(range(-10 10)) yscale(range(0 22)) xlabel(-10 (5) 10) ylabel(0 (5) 20)
		graph export "${OUTPUT}/output/graphs/error_histograms/nonzero/error_hist_rho`rho'_k`k'_nonzero.png", replace
		graph export "${OUTPUT}/output/graphs/error_histograms/nonzero/error_hist_rho`rho'_k`k'_nonzero.pdf", replace
	}
}