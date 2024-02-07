***************************************************************************

clear
est clear
set matsize 11000



******User
global DRIVE 	"//rdsfcifs.acrc.bris.ac.uk/GeneEnvironment_Interactions/UKB/"
global OUTPUT	"C:/Users/pk20062/Dropbox/DONNI - UKB birth location accuracy/output/"




*** Load sibling birth location dataset:
use "${DRIVE}GeographicID/Projects/NV_Papers/Birth locations/dta/sibling_birth_location_data.dta", clear







*** Descriptive statistics:
replace average_sibling_pgi_ea = . if sibling_id==1

estpost tabstat female birth_year educ_years educ_degree educ_upper_secondary age_gap average_sibling_pgi_ea rural urban_municipal metropolitan pop_density_1940_1970 census51_age_left_ed_0_14_sh sibling_birth_distance parish_different district_different county_different sibling_distance_above_0km sibling_distance_above_5km sibling_distance_above_10km sibling_distance_above_20km sibling_distance_above_30km sibling_distance_above_50km, statistics(mean sd min max count) column(statistics)
est store descriptives
		

* Table:
esttab descriptives, ///
			cells("mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2)) count(fmt(%9.0fc))") nonumber ///
			collabel("Mean" "SD" "Min" "Max" "N") mlabel(none) ///
			refcat(female "Individual characteristics:" age_gap "Family characteristics:" ///
			rural "District of birth characteristics:" sibling_birth_distance "Birth location differences:", nolabel) ///
			coeflabel(female "Female" birth_year "Year of birth" educ_years "Years of education" ///
			educ_degree "Degree qualification" educ_upper_secondary "Upper secondary qualification" age_gap "Age gap (years)" ///
			average_sibling_pgi_ea "Mean PGI for education" rural "Rural district" urban_municipal "Urban / municipal district" ///
			metropolitan "Metropolitan district" pop_density_1940_1970 "Average population density 1940-70" ///
			census51_age_left_ed_0_14_sh "Share left FT education by 14 (1951)" sibling_birth_distance "Distance (km)" ///
			parish_different "Different parish" district_different "Different district" county_different "Different county" ///
			sibling_distance_above_0km "Sibling distance > 0km" sibling_distance_above_5km "Sibling distance > 5km" ///
			sibling_distance_above_10km "Sibling distance > 10km" sibling_distance_above_20km "Sibling distance > 20km" ///
			sibling_distance_above_30km "Sibling distance > 30km" sibling_distance_above_50km "Sibling distance > 50km") ///
			noobs varwidth(40)	


// Latex export:
esttab descriptives using "${OUTPUT}/tablefragments/descriptives.tex", ///
			cells("mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2)) count(fmt(%9.0fc))") nonumber ///
			collabel("Mean" "SD" "Min" "Max" "N", prefix({) suffix(})) mlabel(none) ///
			refcat(female "\textbf{Individual characteristics:}" age_gap "\addlinespace \textbf{Family characteristics:}" ///
			rural "\addlinespace \textbf{District of birth characteristics:}" sibling_birth_distance "\addlinespace \textbf{Birth location differences:}", nolabel) ///
			coeflabel(female "Female" birth_year "Year of birth" educ_years "Years of education" ///
			educ_degree "Degree qualification" educ_upper_secondary "Upper secondary qualification" age_gap "Age gap (years)" ///
			average_sibling_pgi_ea "Mean PGI for education" rural "Rural district" urban_municipal "Urban / municipal district" ///
			metropolitan "Metropolitan district" pop_density_1940_1970 "Average population density 1940-70" ///
			census51_age_left_ed_0_14_sh "Share left FT education by 14 (1951)" sibling_birth_distance "Distance (km)" ///
			parish_different "Different parish" district_different "Different district" county_different "Different county" ///
			sibling_distance_above_0km "Sibling distance > 0km" sibling_distance_above_5km "Sibling distance > 5km" ///
			sibling_distance_above_10km "Sibling distance > 10km" sibling_distance_above_20km "Sibling distance > 20km" ///
			sibling_distance_above_30km "Sibling distance > 30km" sibling_distance_above_50km "Sibling distance > 50km") ///
			noobs ///
			compress replace booktabs fragment
			
			

			
		

			
*** Comparison of descriptive statistics:
use "${DRIVE}GeographicID/Projects/NV_Papers/Birth locations/dta/sibling_sample_comparison.dta", clear

estpost tabstat female birth_year educ_years educ_degree educ_upper_secondary  rural urban_municipal metropolitan pop_density_1940_1970 census51_age_left_ed_0_14_sh, statistics(mean sd min max count) column(statistics)
est store descriptives_full_ukb

estpost tabstat female birth_year educ_years educ_degree educ_upper_secondary  rural urban_municipal metropolitan pop_density_1940_1970 census51_age_left_ed_0_14_sh if sibling_sample==1, statistics(mean sd min max count) column(statistics)
est store descriptives_siblings


* Table:
esttab descriptives_siblings descriptives_full_ukb, ///
			cells("mean(fmt(2)) sd(fmt(2)) count(fmt(%9.0fc))") nonumber ///
			collabel("Mean" "SD" "N") mlabel("Sibling sample" "Full UKB sample") ///
			refcat(female "Individual characteristics:" ///
			rural "District of birth characteristics:", nolabel) ///
			coeflabel(female "Female" birth_year "Year of birth" educ_years "Years of education" ///
			educ_degree "Degree qualification" educ_upper_secondary "Upper secondary qualification" ///
			rural "Rural district" urban_municipal "Urban / municipal district" ///
			metropolitan "Metropolitan district" pop_density_1940_1970 "Average population density 1940-70" ///
			census51_age_left_ed_0_14_sh "Share left FT education by 14 (1951)") ///
			noobs varwidth(40)	


// Latex export:
esttab descriptives_siblings descriptives_full_ukb using "${OUTPUT}/tablefragments/descriptives_sample_comparison.tex", ///
			cells("mean(fmt(2)) sd(fmt(2)) count(fmt(%9.0fc))") nonumber ///
			collabel("Mean" "SD" "N", prefix({) suffix(})) ///
			mlabel("Sibling sample" "Full UKB sample", ///
			prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
			refcat(female "\textbf{Individual characteristics:}" ///
			rural "\addlinespace \textbf{District of birth characteristics:}", nolabel) ///
			coeflabel(female "Female" birth_year "Year of birth" educ_years "Years of education" ///
			educ_degree "Degree qualification" educ_upper_secondary "Upper secondary qualification" ///
			rural "Rural district" urban_municipal "Urban / municipal district" ///
			metropolitan "Metropolitan district" pop_density_1940_1970 "Average population density 1940-70" ///
			census51_age_left_ed_0_14_sh "Share left FT education by 14 (1951)") ///
			noobs ///
			compress replace booktabs fragment