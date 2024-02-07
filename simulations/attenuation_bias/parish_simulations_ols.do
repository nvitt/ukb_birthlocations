***************************************************************************

clear
est clear
set matsize 11000



******User
global DRIVE 	"//rdsfcifs.acrc.bris.ac.uk/GeneEnvironment_Interactions/UKB/"
global OUTPUT	"C:/Users/pk20062/Dropbox/DONNI - UKB birth location accuracy/"



*** Set seed:
set seed 17041345



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





*** Load simulated parish-level data:
insheet using "${OUTPUT}gis_data/simulations/parish_spatial_simulations.txt", clear

rename g_unit pid

expand 395

bysort pid: gen birth_date=-274+_n

merge m:1 birth_date using "`birth_date_fe'"
drop _merge

local i=1
foreach var of varlist rho* {
		qui sum `var'
		replace `var' = (`var' - r(mean)) / (r(sd))
		
		rename birth_date_fe_`i' fe_`var'
		
		local i=`i'+1
}

order pid birth_date
sort pid birth_date

tempfile parish_date_data
save "`parish_date_data'"










*** Load sibling birth location dataset:
use "${DRIVE}GeographicID/Projects/NV_Papers/Birth locations/dta/sibling_birth_location_data.dta", clear


*** Set as panel:
sort family_id sibling_id
xtset family_id sibling_id





*** Sibling's parish:
gen sibling_pid = L.pid if sibling_id==2
replace sibling_pid = F.pid if sibling_id==1


*** Merge in nearest parish to midpoint between sibling birth locations:
gen double midpoint_easting = (birth_easting + L.birth_easting)/2 if sibling_id==2
replace midpoint_easting = (birth_easting + F.birth_easting)/2 if sibling_id==1
gen double midpoint_northing = (birth_northing + L.birth_northing)/2 if sibling_id==2
replace midpoint_northing = (birth_northing + F.birth_northing)/2 if sibling_id==1
merge m:1 midpoint_easting midpoint_northing using "${DRIVE}GeographicID/Projects/NV_Papers/Birth locations/dta/sibling_midpoint_data.dta", keepusing(midpoint_nearest_pid)
drop _merge

drop midpoint_easting midpoint_northing birth_easting birth_northing



*** Merge in simulated parish-level data based on own parish:
merge m:1 pid birth_date using "`parish_date_data'" // not matched parishes from birth location data are island parishes without direct neighbours for which we could not simulate spatial data
drop if _merge==2
drop _merge

rename rho* simulation_rho*





*** Merge in simulated parish-level data based on sibling's parish:
rename pid original_pid
rename sibling_pid pid

merge m:1 pid birth_date using "`parish_date_data'" // not matched parishes from birth location data are island parishes without direct neighbours for which we could not simulate spatial data
drop if _merge==2
drop _merge

rename rho* simulation_rho*_sibpar


rename pid sibling_pid 





*** Merge in simulated parish-level data based on midpoint between sibling's birth locations:
rename midpoint_nearest_pid pid

merge m:1 pid birth_date using "`parish_date_data'" // not matched parishes from birth location data are island parishes without direct neighbours for which we could not simulate spatial data
drop if _merge==2
drop _merge

rename rho* simulation_rho*_midpar


rename pid midpoint_nearest_pid





*** Limit sample to observations with valid par, sibpar and midpar simulated variables:
keep if simulation_rho0_1!=. & simulation_rho0_1_sibpar!=. & simulation_rho0_1_midpar!=.








*** Normalize simulated data and create measurement error variables:
sum simulation_rho*
foreach var of varlist simulation_rho* {
	if strpos("`var'","_sibpar") == 0 & strpos("`var'","_midpar") == 0 {
		qui sum `var'
		replace `var' = (`var' - r(mean)) / (r(sd))
		replace `var'_sibpar = (`var'_sibpar - r(mean)) / (r(sd))
		replace `var'_midpar = (`var'_midpar - r(mean)) / (r(sd))
		gen diff_`var' = `var' - `var'_sibpar
		gen mse_`var' = (`var' - `var'_sibpar)^2
	}
}
sum simulation_rho*
sum mse_* if original_pid==sibling_pid
sum mse_* if original_pid!=sibling_pid
sum mse_*











*** Simulate with individual probability of incorrect parish p = 0.168 and annual move probability q = 0.009
keep if simulation_rho0_1!=. & simulation_rho0_1_sibpar!=.
sort family_id sibling_id
gen error_prob = (2*0.168-0.168^2) / (2*0.168 - 0.168^2 + 0.009 * age_gap) if original_pid!=sibling_pid
gen both_error_prob = 0.168^2 / (2*0.168-0.168^2) if original_pid!=sibling_pid

capture program drop simulation
program define simulation, rclass
	
	syntax varlist
		
	return local varname "`1'"
		
	cap drop parish_error both_sib which_sib x y x_obs mse u diff
	
	gen parish_error = rbinomial(1,error_prob) if sibling_id==2 & original_pid!=sibling_pid
	replace parish_error = 1 if parish_error==. & error_prob==1
	
	gen both_sib = rbinomial(1,both_error_prob) if parish_error==1
	replace both_sib = F.both_sib if sibling_id==1
	
	gen which_sib = 1+rbinomial(1,0.5) if parish_error==1 & both_sib==0
	
	replace parish_error = 1 if F.both_sib==1 & sibling_id==1
	replace parish_error = 1 if F.parish_error==1 & F.which_sib==1 & sibling_id==1
	replace parish_error = 0 if F.parish_error==1 & F.which_sib==2 & sibling_id==1
	replace parish_error = 0 if F.parish_error==0 & sibling_id==1
	replace parish_error = 0 if parish_error==1 & which_sib==1 & sibling_id==2
	replace parish_error = 0 if original_pid==sibling_pid
	
	gen x = `1'
	
	replace x = `1'_sibp if parish_error==1 & both_sib==0
	replace x = `1'_midp if parish_error==1 & both_sib==1
	
	gen y = x + rnormal(0,1)
	
	gen x_obs = `1'
	
	replace x=. if x_obs==. // to ensure consistent samples
	replace x_obs=. if x==. // to ensure consistent samples
	
	gen u = x_obs - x
	
	gen mse = (x_obs - x)^2
	
	sum mse
	return scalar mse = r(mean)
	
	sum mse if parish_error==0
	return scalar mse_same = r(mean)
	
	sum mse if parish_error==1
	return scalar mse_diff = r(mean)
	
	reg y x
	return scalar b_unbiased = _coef[x]
	return scalar n_unbiased = e(N)
	
	reg y x_obs
	return scalar b_biased = _coef[x_obs]
	return scalar n_biased = e(N)
	
	corr x_obs u, cov
	return scalar lambda = r(cov_12)/r(Var_1)
	
	gen diff=(parish_error==1 | L.parish_error==1) if sibling_id==2
	sum diff
	return scalar diff_par_share = r(mean)
	
end



* Get variables with simulated data:
qui ds simulation_rho*
global sim_variables "`r(varlist)'"
di "$sim_variables"


* Run simulations and save results in temporary files:
foreach var of global sim_variables {
	if strpos("`var'","_sibpar") == 0 & strpos("`var'","_midpar") == 0 {
		
		local fe_var = subinstr("`var'","simulation_","fe_",.)
		
		forvalues i=0(2)10 {
			preserve

			gen `var'_`i' = sqrt((10-`i')/10)*`var' + sqrt(`i'/10)*`fe_var'
			gen `var'_`i'_sibp = sqrt((10-`i')/10)*`var'_sibpar + sqrt(`i'/10)*`fe_var'
			gen `var'_`i'_midp = sqrt((10-`i')/10)*`var'_midpar + sqrt(`i'/10)*`fe_var'
			
			qui sum `var'_`i'
			replace `var'_`i' = (`var'_`i' - r(mean)) / (r(sd))
			replace `var'_`i'_sibp = (`var'_`i'_sibp - r(mean)) / (r(sd))
			replace `var'_`i'_midp = (`var'_`i'_midp - r(mean)) / (r(sd))
			
			tempfile t_`var'_`i'
			simulate2 varname=r(varname) mse=r(mse) mse_same=r(mse_same) mse_diff=r(mse_diff) b_unbiased=r(b_unbiased) ///
				b_biased=r(b_biased) lambda=r(lambda) bias=(r(b_biased)-r(b_unbiased)) diff_par_share=r(diff_par_share) ///
				n_unbiased=r(n_unbiased) n_biased=r(n_biased) ///
				, reps(100) saving("`t_`var'_`i''"): simulation `var'_`i'

			restore	
		}
		
	}
}

* Combine simulation results:
clear
foreach var of global sim_variables {
	if strpos("`var'","_sibpar") == 0 & strpos("`var'","_midpar") == 0 {
		forvalues i=0(2)10 {
			append using "`t_`var'_`i''"
		}
	}
}

* Extract information on rho and number of spatial simulation:
gen rho = subinstr(substr(subinstr(varname,"simulation_rho","",.),1,strpos(subinstr(varname,"simulation_rho","",.),"_")-1),"0","0.",1)
destring rho, replace
format rho %9.3f

gen spatial_sim_no = substr(varname,strpos(subinstr(varname,"_","+",1),"_")+1,strpos(subinstr(varname,"_","+",2),"_")-strpos(subinstr(varname,"_","+",1),"_")-1)
destring spatial_sim_no, replace

gen temporal_variance_percentage = substr(varname,strpos(subinstr(varname,"_","+",2),"_")+1,.)
destring temporal_variance_percentage, replace
replace temporal_variance_percentage = temporal_variance_percentage*10

drop varname



*** Save simulation output:
save "${OUTPUT}/output/simulations/parish_simulations_sibling_error.dta", replace


*** Summary of the simulation output:
tabstat mse mse_same mse_diff b_unbiased b_biased lambda bias diff_par_share if temporal_variance_percentage==0, by(rho) stats(mean)
tabstat mse mse_same mse_diff b_unbiased b_biased lambda bias diff_par_share if temporal_variance_percentage==20, by(rho) stats(mean)
tabstat mse mse_same mse_diff b_unbiased b_biased lambda bias diff_par_share if temporal_variance_percentage==40, by(rho) stats(mean)
tabstat mse mse_same mse_diff b_unbiased b_biased lambda bias diff_par_share if temporal_variance_percentage==60, by(rho) stats(mean)
tabstat mse mse_same mse_diff b_unbiased b_biased lambda bias diff_par_share if temporal_variance_percentage==80, by(rho) stats(mean)
tabstat mse mse_same mse_diff b_unbiased b_biased lambda bias diff_par_share if temporal_variance_percentage==100, by(rho) stats(mean)

replace bias=bias*(-100)
tostring rho, gen(rho_str) usedisplayformat

estpost tabstat bias if rho<=0.975 & temporal_variance_percentage==0, by(rho_str) nototal elabel
local label `e(labels)'
est store bias_by_rho_temp0

estpost tabstat bias if rho<=0.975 & temporal_variance_percentage==20, by(rho_str) nototal elabel
local label `e(labels)'
est store bias_by_rho_temp20

estpost tabstat bias if rho<=0.975 & temporal_variance_percentage==40, by(rho_str) nototal elabel
local label `e(labels)'
est store bias_by_rho_temp40

estpost tabstat bias if rho<=0.975 & temporal_variance_percentage==60, by(rho_str) nototal elabel
local label `e(labels)'
est store bias_by_rho_temp60

estpost tabstat bias if rho<=0.975 & temporal_variance_percentage==80, by(rho_str) nototal elabel
local label `e(labels)'
est store bias_by_rho_temp80

estpost tabstat bias if rho<=0.975 & temporal_variance_percentage==100, by(rho_str) nototal elabel
local label `e(labels)'
est store bias_by_rho_temp100


// Table:
esttab bias_by_rho_*, ///
			cells("mean(fmt(2))") nonumber ///
			collabel(none) mlabel("0%" "20%" "40%" "60%" "80%" "100%", lhs("Spatial autocorrelation (rho)")) ///
			mgroups("Variance share from time variation", pattern(1 0 0 0 0 0)) ///
			coeflabel(`label') ///
			noobs varwidth(35)
			
			

// Latex export:
esttab bias_by_rho_* using "${OUTPUT}/output/tablefragments/bias_parish_simulations.tex", ///
			cells("mean(fmt(2))") nonumber ///
			collabel(none) mlabel("0\%" "20\%" "40\%" "60\%" "80\%" "100\%", lhs("Spatial autocorrelation (rho)") prefix({) suffix(})) ///
			mgroups("Variance share from time variation", pattern(1 0 0 0 0 0) ///
			span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) ///
			coeflabel(`label') ///
			noobs ///
			compress replace booktabs fragment