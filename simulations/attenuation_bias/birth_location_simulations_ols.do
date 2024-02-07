***************************************************************************

clear
est clear
set matsize 11000



******User
global DRIVE 	"//rdsfcifs.acrc.bris.ac.uk/GeneEnvironment_Interactions/UKB/"
global OUTPUT	"C:/Users/pk20062/Dropbox/DONNI - UKB birth location accuracy/"



*** Set seed:
set seed 14041619



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






*** Load unique birth locations in the UKB:
insheet using "${OUTPUT}gis_data/unique_birth_locations_detailed_rounded.csv", clear comma

collapse (sum) n, by(easting_rounded northing_rounded)

rename easting_rounded easting
rename northing_rounded northing

tempfile ukb_birth_locations
save "`ukb_birth_locations'"



*** Load unique midpoint locations between siblings:
use "${DRIVE}GeographicID/Projects/NV_Papers/Birth locations/dta/sibling_midpoint_data.dta", clear
keep midpoint_nearest_easting midpoint_nearest_northing
rename midpoint_nearest_easting easting
rename midpoint_nearest_northing northing

duplicates drop

tempfile midpoint_locations
save "`midpoint_locations'"





*** Load simulated location grid data:
insheet using "${OUTPUT}gis_data/simulations/birth_location_grid_spatial_simulations.txt", clear comma

merge 1:1 easting northing using "`ukb_birth_locations'"
rename _merge merge_birth_locations
drop n

merge 1:1 easting northing using "`midpoint_locations'"
keep if _merge==3 | merge_birth_locations==3
drop _merge merge_birth_locations

rename easting birth_easting
rename northing birth_northing

expand 395

bysort birth_easting birth_northing: gen birth_date=-274+_n

merge m:1 birth_date using "`birth_date_fe'"
drop _merge

local i=1
foreach var of varlist rho* {
		qui sum `var'
		replace `var' = (`var' - r(mean)) / (r(sd))
		
		rename birth_date_fe_`i' fe_`var'
		
		local i=`i'+1
}

order birth_easting birth_northing birth_date
sort birth_easting birth_northing birth_date

tempfile loc_date_data
save "`loc_date_data'"





*** Load sibling birth location dataset:
use "${DRIVE}GeographicID/Projects/NV_Papers/Birth locations/dta/sibling_birth_location_data.dta", clear


*** Set as panel:
sort family_id sibling_id
xtset family_id sibling_id


*** Round birth location:
replace birth_easting = round((birth_easting-500),1000)+500
replace birth_northing = round((birth_northing-500),1000)+500


*** Sibling's birth location:
gen double sibling_easting = L.birth_easting if sibling_id==2
replace sibling_easting = F.birth_easting if sibling_id==1

gen double sibling_northing = L.birth_northing if sibling_id==2
replace sibling_northing = F.birth_northing if sibling_id==1


*** Merge in nearest grid coordinates to midpoint between sibling birth locations:
gen midpoint_easting = (birth_easting + sibling_easting)/2
gen midpoint_northing = (birth_northing + sibling_northing)/2
merge m:1 midpoint_easting midpoint_northing using "${DRIVE}GeographicID/Projects/NV_Papers/Birth locations/dta/sibling_midpoint_data.dta", keepusing(midpoint_nearest_easting midpoint_nearest_northing)
drop _merge

drop midpoint_easting midpoint_northing








*** Merge in birth location variable based on own birth location:
merge m:1 birth_easting birth_northing birth_date using "`loc_date_data'"
drop if _merge==2
drop _merge

rename rho* simulation_rho*





*** Merge in birth location variable based on sibling's birth location:
rename birth_easting original_easting
rename sibling_easting birth_easting
rename birth_northing original_northing
rename sibling_northing birth_northing

merge m:1 birth_easting birth_northing birth_date using "`loc_date_data'"
drop if _merge==2
drop _merge

rename rho* simulation_rho*_sibloc

rename birth_easting sibling_easting
rename birth_northing sibling_northing





*** Merge in birth location variable based on midpoint between sibling's birth locations:
rename midpoint_nearest_easting birth_easting
rename midpoint_nearest_northing birth_northing

merge m:1 birth_easting birth_northing birth_date using "`loc_date_data'"
drop if _merge==2
drop _merge

rename rho* simulation_rho*_midloc

rename birth_easting midpoint_nearest_easting
rename birth_northing midpoint_nearest_northing





*** Limit sample to observations with valid loc, sibloc and midloc simulated variables:
keep if simulation_rho0_1!=. & simulation_rho0_1_sibloc!=. & simulation_rho0_1_midloc!=.




*** Normalize simulated data and create measurement error variables:
sum simulation_rho*
foreach var of varlist simulation_rho* {
	if strpos("`var'","_sibloc") == 0 & strpos("`var'","_midloc") == 0 {
		qui sum `var'
		replace `var' = (`var' - r(mean)) / (r(sd))
		replace `var'_sibloc = (`var'_sibloc - r(mean)) / (r(sd))
		replace `var'_midloc = (`var'_midloc - r(mean)) / (r(sd))
		gen diff_`var' = `var' - `var'_sibloc
		gen mse_`var' = (`var' - `var'_sibloc)^2
	}
}
sum simulation_rho*
sum mse_* if original_easting==sibling_easting & original_northing==sibling_northing
sum mse_* if original_easting!=sibling_easting | original_northing!=sibling_northing
sum mse_*











*** Simulate with individual probability of incorrect location p = 0.284 and annual move probability q = 0.012
keep if simulation_rho0_1!=. & simulation_rho0_1_sibloc!=.
sort family_id sibling_id
gen error_prob = (2*0.284-0.284^2) / (2*0.284-0.284^2 + 0.012 * age_gap) if (original_easting!=sibling_easting | original_northing!=sibling_northing)
gen both_error_prob = 0.284^2 / (2*0.284-0.284^2) if (original_easting!=sibling_easting | original_northing!=sibling_northing)


capture program drop simulation
program define simulation, rclass
	
	syntax varlist
		
	return local varname "`1'"
		
	cap drop loc_error both_sib which_sib x y x_obs mse u diff
	
	gen loc_error = rbinomial(1,error_prob) if sibling_id==2 & (original_easting!=sibling_easting | original_northing!=sibling_northing)
	replace loc_error = 1 if loc_error==. & error_prob==1
	
	gen both_sib = rbinomial(1,both_error_prob) if loc_error==1
	replace both_sib = F.both_sib if sibling_id==1
	
	gen which_sib = 1+rbinomial(1,0.5) if loc_error==1 & both_sib==0
	
	replace loc_error = 1 if F.both_sib==1 & sibling_id==1
	replace loc_error = 1 if F.loc_error==1 & F.which_sib==1 & sibling_id==1
	replace loc_error = 0 if F.loc_error==1 & F.which_sib==2 & sibling_id==1
	replace loc_error = 0 if F.loc_error==0 & sibling_id==1
	replace loc_error = 0 if loc_error==1 & which_sib==1 & sibling_id==2
	replace loc_error = 0 if (original_easting==sibling_easting & original_northing==sibling_northing)
		
	gen x = `1'
	
	replace x = `1'_sibl if loc_error==1 & both_sib==0
	replace x = `1'_midl if loc_error==1 & both_sib==1
	
	gen y = x + rnormal(0,1)
	
	gen x_obs = `1'
	
	replace x=. if x_obs==. // to ensure consistent samples
	replace x_obs=. if x==. // to ensure consistent samples
	
	gen u = x_obs - x
	
	gen mse = (x_obs - x)^2
	
	sum mse
	return scalar mse = r(mean)
	
	sum mse if loc_error==0
	return scalar mse_same = r(mean)
	
	sum mse if loc_error==1
	return scalar mse_diff = r(mean)
	
	reg y x
	return scalar b_unbiased = _coef[x]
	return scalar n_unbiased = e(N)
	
	reg y x_obs
	return scalar b_biased = _coef[x_obs]
	return scalar n_biased = e(N)
	
	corr x_obs u, cov
	return scalar lambda = r(cov_12)/r(Var_1)
	
	gen diff=(loc_error==1 | L.loc_error==1) if sibling_id==2
	sum diff
	return scalar diff_loc_share = r(mean)	
	
end



* Get variables with simulated data:
qui ds simulation_rho*
global sim_variables "`r(varlist)'"
di "$sim_variables"


* Run simulations and save results in temporary files:
foreach var of global sim_variables {
	if strpos("`var'","_sibloc") == 0 & strpos("`var'","_midloc") == 0 {
		
		local fe_var = subinstr("`var'","simulation_","fe_",.)
		
		forvalues i=0(2)10 {
			preserve

			gen `var'_`i' = sqrt((10-`i')/10)*`var' + sqrt(`i'/10)*`fe_var'
			gen `var'_`i'_sibl = sqrt((10-`i')/10)*`var'_sibloc + sqrt(`i'/10)*`fe_var'
			gen `var'_`i'_midl = sqrt((10-`i')/10)*`var'_midloc + sqrt(`i'/10)*`fe_var'
			
			qui sum `var'_`i'
			replace `var'_`i' = (`var'_`i' - r(mean)) / (r(sd))
			replace `var'_`i'_sibl = (`var'_`i'_sibl - r(mean)) / (r(sd))
			replace `var'_`i'_midl = (`var'_`i'_midl - r(mean)) / (r(sd))
			
			tempfile t_`var'_`i'
			simulate2 varname=r(varname) mse=r(mse) mse_same=r(mse_same) mse_diff=r(mse_diff) b_unbiased=r(b_unbiased) ///
				b_biased=r(b_biased) lambda=r(lambda) bias=(r(b_biased)-r(b_unbiased)) diff_loc_share=r(diff_loc_share) ///
				n_unbiased=r(n_unbiased) n_biased=r(n_biased) ///
				, reps(100) saving("`t_`var'_`i''"): simulation `var'_`i'

			restore	
		}
		
	}
}

* Combine simulation results:
clear
foreach var of global sim_variables {
	if strpos("`var'","_sibloc") == 0 & strpos("`var'","_midloc") == 0 {
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
save "${OUTPUT}/output/simulations/birthloc_simulations_sibling_error.dta", replace


*** Summary of the simulation output:
tabstat mse mse_same mse_diff b_unbiased b_biased lambda bias diff_loc_share if temporal_variance_percentage==0, by(rho) stats(mean)
tabstat mse mse_same mse_diff b_unbiased b_biased lambda bias diff_loc_share if temporal_variance_percentage==20, by(rho) stats(mean)
tabstat mse mse_same mse_diff b_unbiased b_biased lambda bias diff_loc_share if temporal_variance_percentage==40, by(rho) stats(mean)
tabstat mse mse_same mse_diff b_unbiased b_biased lambda bias diff_loc_share if temporal_variance_percentage==60, by(rho) stats(mean)
tabstat mse mse_same mse_diff b_unbiased b_biased lambda bias diff_loc_share if temporal_variance_percentage==80, by(rho) stats(mean)
tabstat mse mse_same mse_diff b_unbiased b_biased lambda bias diff_loc_share if temporal_variance_percentage==100, by(rho) stats(mean)

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
esttab bias_by_rho_* using "${OUTPUT}/output/tablefragments/bias_birthloc_simulations.tex", ///
			cells("mean(fmt(2))") nonumber ///
			collabel(none) mlabel("0\%" "20\%" "40\%" "60\%" "80\%" "100\%", lhs("Spatial autocorrelation (rho)") prefix({) suffix(})) ///
			mgroups("Variance share from time variation", pattern(1 0 0 0 0 0) ///
			span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) ///
			coeflabel(`label') ///
			noobs ///
			compress replace booktabs fragment