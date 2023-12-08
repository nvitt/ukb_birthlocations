***************************************************************************

clear
est clear
set matsize 11000



******User
global DRIVE 	"//rdsfcifs.acrc.bris.ac.uk/GeneEnvironment_Interactions/UKB/"
global OUTPUT	"C:/Users/pk20062/Dropbox/DONNI - UKB birth location accuracy/"



*** Set seed:
set seed 17041026




*** Load sibling birth location dataset:
use "${DRIVE}GeographicID/Paper Data Extraction/NV_Papers/Birth locations/dta/sibling_birth_location_data.dta", clear




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
merge m:1 midpoint_easting midpoint_northing using "${DRIVE}GeographicID/Paper Data Extraction/NV_Papers/Birth locations/dta/sibling_midpoint_data.dta", keepusing(midpoint_nearest_gid)
drop _merge

drop midpoint_easting midpoint_northing birth_easting birth_northing






*** Merge in data based on own district:
merge m:1 gid birth_year birth_month using "${DRIVE}GeographicID/Paper Data Extraction/NV_Papers/Disease data/dta/1951_weighted_yfb_disease_district_panel.dta", keepusing(measles_1 scarlet_fever_1 w_cough_1 acute_polio_non_paralytic_1 acute_polio_paralytic_1 diphtheria_1 pneumonia_1 tuberculosis_respiratory_1)
drop if _merge==2
drop _merge

merge m:1 gid birth_year birth_month using "${DRIVE}GeographicID/Paper Data Extraction/NV_Papers/Disease data/dta/1951_weighted_yfb_vitals_district_panel.dta", keepusing(births_total_1 deaths_1 deathsunderoneyear_1 estimated_population_1 illegitimate_births_female_1 illegitimate_births_male_1 stillbirths_1)
replace stillbirths_1=. if birth_date<=tm(1947m12)
drop if _merge==2
drop _merge

drop census51_*
merge m:1 gid using "${DRIVE}GeographicID/Paper Data Extraction/NV_Papers/Disease data/dta/weighted_1951census_demographics.dta", keepusing(census51_social_class*_sh census51_density_*_pop_sh census51_age_left_ed_*_sh)
rename census51_* c51_*
drop if _merge==2
drop _merge

gen measles_r_age0 = ((measles_1) / (estimated_population_1))*100
gen scarlet_fever_age0 = ((scarlet_fever_1) / (estimated_population_1))*100
gen w_cough_r_age0 = ((w_cough_1) / (estimated_population_1))*100
gen polio_nonpar_r_age0 = ((acute_polio_non_paralytic_1) / (estimated_population_1))*100
gen polio_par_r_age0 = ((acute_polio_paralytic_1) / (estimated_population_1))*100
gen diphtheria_r_age0 = ((diphtheria_1) / (estimated_population_1))*100
gen pneumonia_r_age0 = ((pneumonia_1) / (estimated_population_1))*100
gen tb_resp_r_age0 = ((tuberculosis_respiratory_1) / (estimated_population_1))*100
gen birth_r_age0 = ((births_total_1) / (estimated_population_1))*1000
gen death_r_age0 = ((deaths_1) / (estimated_population_1))*1000
gen imr_age0 = ((deathsunderoneyear_1) / (births_total_1))*1000
gen illegitimacy_r_age0 = ((illegitimate_births_female_1+illegitimate_births_male_1) / (births_total_1))*100
gen stillbirth_r_age0 = ((stillbirths_1) / (births_total_1))*1000

drop measles_1 scarlet_fever_1 w_cough_1 acute_polio_non_paralytic_1 acute_polio_paralytic_1 diphtheria_1 pneumonia_1 tuberculosis_respiratory_1 ///
	births_total_1 deaths_1 deathsunderoneyear_1 estimated_population_1 illegitimate_births_female_1 illegitimate_births_male_1 stillbirths_1





*** Merge in data based on sibling's district:
rename gid original_gid
rename sibling_gid gid

merge m:1 gid birth_year birth_month using "${DRIVE}GeographicID/Paper Data Extraction/NV_Papers/Disease data/dta/1951_weighted_yfb_disease_district_panel.dta", keepusing(measles_1 scarlet_fever_1 w_cough_1 acute_polio_non_paralytic_1 acute_polio_paralytic_1 diphtheria_1 pneumonia_1 tuberculosis_respiratory_1)
drop if _merge==2
drop _merge

merge m:1 gid birth_year birth_month using "${DRIVE}GeographicID/Paper Data Extraction/NV_Papers/Disease data/dta/1951_weighted_yfb_vitals_district_panel.dta", keepusing(births_total_1 deaths_1 deathsunderoneyear_1 estimated_population_1 illegitimate_births_female_1 illegitimate_births_male_1 stillbirths_1)
replace stillbirths_1=. if birth_date<=tm(1947m12)
drop if _merge==2
drop _merge

merge m:1 gid using "${DRIVE}GeographicID/Paper Data Extraction/NV_Papers/Disease data/dta/weighted_1951census_demographics.dta", keepusing(census51_social_class*_sh census51_density_*_pop_sh census51_age_left_ed_*_sh)
rename census51_* c51_*_sibd
drop if _merge==2
drop _merge

gen measles_r_age0_sibd = ((measles_1) / (estimated_population_1))*100
gen scarlet_fever_age0_sibd = ((scarlet_fever_1) / (estimated_population_1))*100
gen w_cough_r_age0_sibd = ((w_cough_1) / (estimated_population_1))*100
gen polio_nonpar_r_age0_sibd = ((acute_polio_non_paralytic_1) / (estimated_population_1))*100
gen polio_par_r_age0_sibd = ((acute_polio_paralytic_1) / (estimated_population_1))*100
gen diphtheria_r_age0_sibd = ((diphtheria_1) / (estimated_population_1))*100
gen pneumonia_r_age0_sibd = ((pneumonia_1) / (estimated_population_1))*100
gen tb_resp_r_age0_sibd = ((tuberculosis_respiratory_1) / (estimated_population_1))*100
gen birth_r_age0_sibd = ((births_total_1) / (estimated_population_1))*1000
gen death_r_age0_sibd = ((deaths_1) / (estimated_population_1))*1000
gen imr_age0_sibd = ((deathsunderoneyear_1) / (births_total_1))*1000
gen illegitimacy_r_age0_sibd = ((illegitimate_births_female_1+illegitimate_births_male_1) / (births_total_1))*100
gen stillbirth_r_age0_sibd = ((stillbirths_1) / (births_total_1))*1000

drop measles_1 scarlet_fever_1 w_cough_1 acute_polio_non_paralytic_1 acute_polio_paralytic_1 diphtheria_1 pneumonia_1 tuberculosis_respiratory_1 ///
	births_total_1 deaths_1 deathsunderoneyear_1 estimated_population_1 illegitimate_births_female_1 illegitimate_births_male_1 stillbirths_1

rename gid sibling_gid 





*** Merge in data based on midpoint district between sibling's birth locations:
rename midpoint_nearest_gid gid

merge m:1 gid birth_year birth_month using "${DRIVE}GeographicID/Paper Data Extraction/NV_Papers/Disease data/dta/1951_weighted_yfb_disease_district_panel.dta", keepusing(measles_1 scarlet_fever_1 w_cough_1 acute_polio_non_paralytic_1 acute_polio_paralytic_1 diphtheria_1 pneumonia_1 tuberculosis_respiratory_1)
drop if _merge==2
drop _merge

merge m:1 gid birth_year birth_month using "${DRIVE}GeographicID/Paper Data Extraction/NV_Papers/Disease data/dta/1951_weighted_yfb_vitals_district_panel.dta", keepusing(births_total_1 deaths_1 deathsunderoneyear_1 estimated_population_1 illegitimate_births_female_1 illegitimate_births_male_1 stillbirths_1)
replace stillbirths_1=. if birth_date<=tm(1947m12)
drop if _merge==2
drop _merge

merge m:1 gid using "${DRIVE}GeographicID/Paper Data Extraction/NV_Papers/Disease data/dta/weighted_1951census_demographics.dta", keepusing(census51_social_class*_sh census51_density_*_pop_sh census51_age_left_ed_*_sh)
rename census51_* c51_*_midd
drop if _merge==2
drop _merge

gen measles_r_age0_midd = ((measles_1) / (estimated_population_1))*100
gen scarlet_fever_age0_midd = ((scarlet_fever_1) / (estimated_population_1))*100
gen w_cough_r_age0_midd = ((w_cough_1) / (estimated_population_1))*100
gen polio_nonpar_r_age0_midd = ((acute_polio_non_paralytic_1) / (estimated_population_1))*100
gen polio_par_r_age0_midd = ((acute_polio_paralytic_1) / (estimated_population_1))*100
gen diphtheria_r_age0_midd = ((diphtheria_1) / (estimated_population_1))*100
gen pneumonia_r_age0_midd = ((pneumonia_1) / (estimated_population_1))*100
gen tb_resp_r_age0_midd = ((tuberculosis_respiratory_1) / (estimated_population_1))*100
gen birth_r_age0_midd = ((births_total_1) / (estimated_population_1))*1000
gen death_r_age0_midd = ((deaths_1) / (estimated_population_1))*1000
gen imr_age0_midd = ((deathsunderoneyear_1) / (births_total_1))*1000
gen illegitimacy_r_age0_midd = ((illegitimate_births_female_1+illegitimate_births_male_1) / (births_total_1))*100
gen stillbirth_r_age0_midd = ((stillbirths_1) / (births_total_1))*1000

drop measles_1 scarlet_fever_1 w_cough_1 acute_polio_non_paralytic_1 acute_polio_paralytic_1 diphtheria_1 pneumonia_1 tuberculosis_respiratory_1 ///
	births_total_1 deaths_1 deathsunderoneyear_1 estimated_population_1 illegitimate_births_female_1 illegitimate_births_male_1 stillbirths_1

rename gid midpoint_nearest_gid






*** Normalize and create MSE variables:
foreach var of varlist measles_r_age0 scarlet_fever_age0 w_cough_r_age0 polio_nonpar_r_age0 polio_par_r_age0 diphtheria_r_age0 pneumonia_r_age0 tb_resp_r_age0 birth_r_age0 death_r_age0 imr_age0 illegitimacy_r_age0 stillbirth_r_age0 c51_*_sh {
	sum `var'
	local mean = r(mean)
	local sd = r(sd)
	
	replace `var' = (`var' - `mean') / (`sd')
	replace `var'_sibd = (`var'_sibd - `mean') / (`sd')
	replace `var'_midd = (`var'_midd - `mean') / (`sd')
}










*** Simulate with individual probability of incorrect district p = 0.158 and annual move probability q = 0.009
sort family_id sibling_id
gen error_prob = (2*0.158-0.158^2) / (2*0.158 - 0.158^2 + 0.009 * age_gap) if original_gid!=sibling_gid
gen both_error_prob = 0.158^2 / (2*0.158-0.158^2) if original_gid!=sibling_gid

capture program drop simulation
program define simulation, rclass
	
	syntax varlist
		
	return local varname "`1'"
	
	cap drop district_error both_sib which_sib x y x_obs diff
	
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
	
	gen y = x + rnormal(0,1)
	
	gen x_obs = `1'
	
	reghdfe y x, absorb(i.family_id)
	return scalar b_unbiased = _coef[x]
	
	reghdfe y x_obs, absorb(i.family_id)
	return scalar b_biased = _coef[x_obs]
	
	gen diff=(district_error==1 | L.district_error==1) if sibling_id==2
	sum diff
	return scalar diff_distr_share = r(mean)
	
end



* Run simulations and save results in temporary files:
foreach var of varlist measles_r_age0 scarlet_fever_age0 w_cough_r_age0 polio_nonpar_r_age0 polio_par_r_age0 diphtheria_r_age0 pneumonia_r_age0 tb_resp_r_age0 birth_r_age0 death_r_age0 imr_age0 illegitimacy_r_age0 stillbirth_r_age0 c51_*_sh {
	preserve

		keep if `var'!=. & `var'_sibd!=. & `var'_midd!=.
		tempfile t_`var'
		simulate2 varname=r(varname) b_unbiased=r(b_unbiased) ///
			b_biased=r(b_biased) bias=(r(b_biased)-r(b_unbiased)) diff_distr_share=r(diff_distr_share) ///
			, reps(1000) saving("`t_`var''"): simulation `var'

	restore	

}

* Combine simulation results:
clear
foreach var in measles_r_age0 scarlet_fever_age0 w_cough_r_age0 polio_nonpar_r_age0 polio_par_r_age0 diphtheria_r_age0 pneumonia_r_age0 tb_resp_r_age0 birth_r_age0 death_r_age0 imr_age0 illegitimacy_r_age0 stillbirth_r_age0 c51_social_class1_sh c51_social_class2_sh c51_social_class3_sh c51_social_class4_sh c51_social_class5_sh c51_density_0to1_pop_sh c51_density_1to15_pop_sh c51_density_15to2_pop_sh c51_density_2to3_pop_sh c51_density_3plus_pop_sh c51_age_left_ed_0_14_sh c51_age_left_ed_15_sh c51_age_left_ed_16_sh c51_age_left_ed_17_19_sh c51_age_left_ed_20plus_sh {
	append using "`t_`var''"
}
replace bias=bias*(-100)





*** Save simulation output:
save "${OUTPUT}/output/simulations/examples_sibling_error_sibling_fe.dta", replace




*** Summary of the simulation output:
gen vartype=1 if inlist(varname,"measles_r_age0","scarlet_fever_age0","w_cough_r_age0","polio_nonpar_r_age0","polio_par_r_age0","diphtheria_r_age0","pneumonia_r_age0","tb_resp_r_age0")
replace vartype=2 if inlist(varname,"birth_r_age0","death_r_age0","imr_age0","illegitimacy_r_age0","stillbirth_r_age0")
replace vartype=3 if vartype==.

replace varname="Measles rate" if varname=="measles_r_age0"
replace varname="Scarlet fever rate" if varname=="scarlet_fever_age0"
replace varname="Whooping cough rate" if varname=="w_cough_r_age0"
replace varname="Nonparalytic polio rate" if varname=="polio_nonpar_r_age0"
replace varname="Paralytic polio rate" if varname=="polio_par_r_age0"
replace varname="Diphtheria rate" if varname=="diphtheria_r_age0"
replace varname="Pneumonia rate" if varname=="pneumonia_r_age0"
replace varname="Respiratory tuberculosis rate" if varname=="tb_resp_r_age0"
replace varname="Birth rate" if varname=="birth_r_age0"
replace varname="Death rate" if varname=="death_r_age0"
replace varname="Infant mortality rate" if varname=="imr_age0"
replace varname="Illegitimacy rate" if varname=="illegitimacy_r_age0"
replace varname="Stillbirth rate" if varname=="stillbirth_r_age0"

replace varname="Share in social class 1" if varname=="c51_social_class1_sh" 
replace varname="Share in social class 2" if varname=="c51_social_class2_sh" 
replace varname="Share in social class 3" if varname=="c51_social_class3_sh" 
replace varname="Share in social class 4" if varname=="c51_social_class4_sh" 
replace varname="Share in social class 5" if varname=="c51_social_class5_sh" 
replace varname="Share housing density 0 - 1" if varname=="c51_density_0to1_pop_sh" 
replace varname="Share housing density 1 - 1.5" if varname=="c51_density_1to15_pop_sh" 
replace varname="Share housing density 1.5 - 2" if varname=="c51_density_15to2_pop_sh" 
replace varname="Share housing density 2 - 3" if varname=="c51_density_2to3_pop_sh" 
replace varname="Share housing density 3+" if varname=="c51_density_3plus_pop_sh" 
replace varname="Share left FT education at 0-14" if varname=="c51_age_left_ed_0_14_sh" 
replace varname="Share left FT education at 15" if varname=="c51_age_left_ed_15_sh" 
replace varname="Share left FT education at 16" if varname=="c51_age_left_ed_16_sh" 
replace varname="Share left FT education at 17-19" if varname=="c51_age_left_ed_17_19_sh" 
replace varname="Share left FT education at 20+" if varname=="c51_age_left_ed_20plus_sh"


sort vartype
egen group = group(vartype varname)
labmask group, values(varname)

tabstat b_unbiased b_biased bias diff_distr_share, by(group) stats(mean)

estpost tabstat bias, by(group) nototal elabel
local label `e(labels)'
est store bias


// Table:
esttab bias, ///
			cells("mean(fmt(2))") nonumber ///
			collabel(none) mlabel("Attenuation bias (%)") ///
			coeflabel(`label') ///
			refcat(1 "Disease rates during 1st year of life:" 9 "Demographics during 1st year of life:" 14 "Demographics - 1951 census:", nolabel) ///
			noobs varwidth(50)
			
			

// Latex export:
esttab bias using "${OUTPUT}/output/tablefragments/bias_examples_sibling_fe_v3.tex", ///
			cells("mean(fmt(2))") nonumber ///
			collabel(none) mlabel("Attenuation bias (\%)", prefix({) suffix(})) ///
			coeflabel(`label') ///
			refcat(1 "\textbf{Disease rates during 1st year of life:}" 9 "\textbf{Demographics during 1st year of life:}" 14 "\textbf{Demographics - 1951 census:}", nolabel) ///
			noobs ///
			compress replace booktabs fragment