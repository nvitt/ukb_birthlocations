***************************************************************************

clear
est clear
set matsize 11000



******User
global DRIVE 	"//rdsfcifs.acrc.bris.ac.uk/GeneEnvironment_Interactions/UKB/"
global OUTPUT	"C:/Users/pk20062/Dropbox/DONNI - UKB birth location accuracy/"



	


************************************
*** Birth coordinate simulations ***
************************************


*** OLS:
// load simulation output:
use "${OUTPUT}/output/simulations/birthloc_simulations_sibling_error.dta", clear
keep if rho<=0.975
replace bias=bias*(-100)
tostring rho, gen(rho_str) usedisplayformat

collapse (mean) bias, by(rho_str temporal_variance_percentage)

// format labels for rho:
levelsof rho_str, local(levels_rho)

local i=1
local ylabels=""
foreach lab in `levels_rho' {
	local ylabels `ylabels' `i' "{bf:`lab'}"
	local i=`i'+1
}

	
// heatplot in colour:	
heatplot bias rho_str i.temporal_variance_percentage, ///
	scheme(lean1) graphregion(margin(zero)) ///
	values(format(%3.1f) size(vsmall)) ///
	xtitle("{bf:Variance share from time variation}", size(small)) ///
	ytitle("{bf:Spatial autocorrelation ({it:{&rho}})}", size(small)) ///
	color(hcl reds, reverse intensity(.9)) ///
	cuts(0(1)100) ///
	xscale(noline alt) plotregion(margin(zero) lwidth(none)) ///
	yscale(reverse noline) ///
	xlabel(1 "{bf:0%}" 2 "{bf:20%}" 3 "{bf:40%}" 4 "{bf:60%}" 5 "{bf:80%}" 6 "{bf:100%}", noticks labgap(3pt) labsize(vsmall)) ///
	ylabel(`ylabels', noticks labgap(5pt) labsize(vsmall)) ///
	legend(off) ysize(4) xsize(4) ///
	title("Ordinary least squares", size(large)) ///
	text(-3 -0.3 "{bf:a}", size(huge)) ///
	graphregion(margin(0.5 5 0.5 0.5)) ///
	name(coordinates_ols, replace)
	
// export source data:	
reshape wide bias*, j(temporal_variance_percentage) i(rho_str)
export delimited "${OUTPUT}/output/graphs/attenuation_bias/common_scale/bias_coordinates_ols_sourcedata.csv", replace




*** Sibling fixed effects:
// load simulation output:
use "${OUTPUT}/output/simulations/birthloc_simulations_sibling_error_sibling_fe.dta", clear
keep if rho<=0.975
replace bias=bias*(-100)
tostring rho, gen(rho_str) usedisplayformat

collapse (mean) bias, by(rho_str temporal_variance_percentage)

// format labels for rho:
levelsof rho_str, local(levels_rho)

local i=1
local ylabels=""
foreach lab in `levels_rho' {
	local ylabels `ylabels' `i' "{bf:`lab'}"
	local i=`i'+1
}
	
// heatplot in colour:	
heatplot bias rho_str i.temporal_variance_percentage, ///
	scheme(lean1) graphregion(margin(zero)) ///
	values(format(%3.1f) size(vsmall)) ///
	xtitle("{bf:Variance share from time variation}", size(small)) ///
	ytitle("{bf:Spatial autocorrelation ({it:{&rho}})}", size(small)) ///
	color(hcl reds, reverse intensity(.9)) ///
	cuts(0(1)100) ///
	xscale(noline alt) plotregion(margin(zero) lwidth(none)) ///
	yscale(reverse noline) ///
	xlabel(1 "{bf:0%}" 2 "{bf:20%}" 3 "{bf:40%}" 4 "{bf:60%}" 5 "{bf:80%}" 6 "{bf:100%}", noticks labgap(3pt) labsize(vsmall)) ///
	ylabel(`ylabels', noticks labgap(5pt) labsize(vsmall)) ///
	legend(off) ysize(4) xsize(4) ///
	title("Sibling fixes effects", size(large)) ///
	text(-3 -0.3 "{bf:b}", size(huge)) ///
	graphregion(margin(5 0.5 0.5 0.5)) ///
	name(coordinates_fe, replace)
	
// export source data:	
reshape wide bias*, j(temporal_variance_percentage) i(rho_str)
export delimited "${OUTPUT}/output/graphs/attenuation_bias/common_scale/bias_coordinates_fe_sourcedata.csv", replace


	
*** Combined graph:
graph combine coordinates_ols coordinates_fe, scheme(s1mono) altshrink ysize(9cm) xsize(18cm)

graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/bias_coordinates_combined.png", replace width(2000)
graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/bias_coordinates_combined.pdf", replace
	
	
	



**************************
*** Parish simulations ***
**************************


*** OLS:
// load simulation output:
use "${OUTPUT}/output/simulations/parish_simulations_sibling_error.dta", clear
keep if rho<=0.975
replace bias=bias*(-100)
tostring rho, gen(rho_str) usedisplayformat

collapse (mean) bias, by(rho_str temporal_variance_percentage)

// format labels for rho:
levelsof rho_str, local(levels_rho)

local i=1
local ylabels=""
foreach lab in `levels_rho' {
	local ylabels `ylabels' `i' "{bf:`lab'}"
	local i=`i'+1
}
	
// heatplot in colour:	
heatplot bias rho_str i.temporal_variance_percentage, ///
	scheme(lean1) graphregion(margin(zero)) ///
	values(format(%3.1f) size(vsmall)) ///
	xtitle("{bf:Variance share from time variation}", size(small)) ///
	ytitle("{bf:Spatial autocorrelation ({it:{&rho}})}", size(small)) ///
	color(hcl reds, reverse intensity(.9)) ///
	cuts(0(1)100) ///
	xscale(noline alt) plotregion(margin(zero) lwidth(none)) ///
	yscale(reverse noline) ///
	xlabel(1 "{bf:0%}" 2 "{bf:20%}" 3 "{bf:40%}" 4 "{bf:60%}" 5 "{bf:80%}" 6 "{bf:100%}", noticks labgap(3pt) labsize(vsmall)) ///
	ylabel(`ylabels', noticks labgap(5pt) labsize(vsmall)) ///
	legend(off) ysize(4) xsize(4) ///
	title("Ordinary least squares", size(large)) ///
	text(-3 -0.3 "{bf:a}", size(huge)) ///
	graphregion(margin(0.5 5 0.5 0.5)) ///
	name(parish_ols, replace)
	
// export source data:	
reshape wide bias*, j(temporal_variance_percentage) i(rho_str)
export delimited "${OUTPUT}/output/graphs/attenuation_bias/common_scale/bias_parish_ols_sourcedata.csv", replace




*** Sibling fixed effects:
// load simulation output:
use "${OUTPUT}/output/simulations/parish_simulations_sibling_error_sibling_fe.dta", clear
keep if rho<=0.975
replace bias=bias*(-100)
tostring rho, gen(rho_str) usedisplayformat

collapse (mean) bias, by(rho_str temporal_variance_percentage)

// format labels for rho:
levelsof rho_str, local(levels_rho)

local i=1
local ylabels=""
foreach lab in `levels_rho' {
	local ylabels `ylabels' `i' "{bf:`lab'}"
	local i=`i'+1
}
	
// heatplot in colour:		
heatplot bias rho_str i.temporal_variance_percentage, ///
	scheme(lean1) graphregion(margin(zero)) ///
	values(format(%3.1f) size(vsmall)) ///
	xtitle("{bf:Variance share from time variation}", size(small)) ///
	ytitle("{bf:Spatial autocorrelation ({it:{&rho}})}", size(small)) ///
	color(hcl reds, reverse intensity(.9)) ///
	cuts(0(1)100) ///
	xscale(noline alt) plotregion(margin(zero) lwidth(none)) ///
	yscale(reverse noline) ///
	xlabel(1 "{bf:0%}" 2 "{bf:20%}" 3 "{bf:40%}" 4 "{bf:60%}" 5 "{bf:80%}" 6 "{bf:100%}", noticks labgap(3pt) labsize(vsmall)) ///
	ylabel(`ylabels', noticks labgap(5pt) labsize(vsmall)) ///
	legend(off) ysize(4) xsize(4) ///
	title("Sibling fixes effects", size(large)) ///
	text(-3 -0.3 "{bf:b}", size(huge)) ///
	graphregion(margin(5 0.5 0.5 0.5)) ///
	name(parish_fe, replace)
	
// export source data:	
reshape wide bias*, j(temporal_variance_percentage) i(rho_str)
export delimited "${OUTPUT}/output/graphs/attenuation_bias/common_scale/bias_parish_fe_sourcedata.csv", replace


	
*** Combined graph:
graph combine parish_ols parish_fe, scheme(s1mono) altshrink ysize(9cm) xsize(18cm)

graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/bias_parish_combined.png", replace width(2000)
graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/bias_parish_combined.pdf", replace
	
	
	


	
	


****************************
*** District simulations ***
****************************


*** OLS:
// load simulation output:
use "${OUTPUT}/output/simulations/district_simulations_sibling_error.dta", clear
keep if rho<=0.975
replace bias=bias*(-100)
tostring rho, gen(rho_str) usedisplayformat

collapse (mean) bias, by(rho_str temporal_variance_percentage)

// format labels for rho:
levelsof rho_str, local(levels_rho)

local i=1
local ylabels=""
foreach lab in `levels_rho' {
	local ylabels `ylabels' `i' "{bf:`lab'}"
	local i=`i'+1
}

	
// heatplot in colour:	
heatplot bias rho_str i.temporal_variance_percentage, ///
	scheme(lean1) graphregion(margin(zero)) ///
	values(format(%3.1f) size(vsmall)) ///
	xtitle("{bf:Variance share from time variation}", size(small)) ///
	ytitle("{bf:Spatial autocorrelation ({it:{&rho}})}", size(small)) ///
	color(hcl reds, reverse intensity(.9)) ///
	cuts(0(1)100) ///
	xscale(noline alt) plotregion(margin(zero) lwidth(none)) ///
	yscale(reverse noline) ///
	xlabel(1 "{bf:0%}" 2 "{bf:20%}" 3 "{bf:40%}" 4 "{bf:60%}" 5 "{bf:80%}" 6 "{bf:100%}", noticks labgap(3pt) labsize(vsmall)) ///
	ylabel(`ylabels', noticks labgap(5pt) labsize(vsmall)) ///
	legend(off) ysize(4) xsize(4) ///
	title("Ordinary least squares", size(large)) ///
	text(-3 -0.3 "{bf:a}", size(huge)) ///
	graphregion(margin(0.5 5 0.5 0.5)) ///
	name(district_ols, replace)
	
// export source data:	
reshape wide bias*, j(temporal_variance_percentage) i(rho_str)
export delimited "${OUTPUT}/output/graphs/attenuation_bias/common_scale/bias_district_ols_sourcedata.csv", replace




*** Sibling fixed effects:
// load simulation output:
use "${OUTPUT}/output/simulations/district_simulations_sibling_error_sibling_fe.dta", clear
keep if rho<=0.975
replace bias=bias*(-100)
tostring rho, gen(rho_str) usedisplayformat

collapse (mean) bias, by(rho_str temporal_variance_percentage)

// format labels for rho:
levelsof rho_str, local(levels_rho)

local i=1
local ylabels=""
foreach lab in `levels_rho' {
	local ylabels `ylabels' `i' "{bf:`lab'}"
	local i=`i'+1
}

	
// heatplot in colour:		
heatplot bias rho_str i.temporal_variance_percentage, ///
	scheme(lean1) graphregion(margin(zero)) ///
	values(format(%3.1f) size(vsmall)) ///
	xtitle("{bf:Variance share from time variation}", size(small)) ///
	ytitle("{bf:Spatial autocorrelation ({it:{&rho}})}", size(small)) ///
	color(hcl reds, reverse intensity(.9)) ///
	cuts(0(1)100) ///
	xscale(noline alt) plotregion(margin(zero) lwidth(none)) ///
	yscale(reverse noline) ///
	xlabel(1 "{bf:0%}" 2 "{bf:20%}" 3 "{bf:40%}" 4 "{bf:60%}" 5 "{bf:80%}" 6 "{bf:100%}", noticks labgap(3pt) labsize(vsmall)) ///
	ylabel(`ylabels', noticks labgap(5pt) labsize(vsmall)) ///
	legend(off) ysize(4) xsize(4) ///
	title("Sibling fixes effects", size(large)) ///
	text(-3 -0.3 "{bf:b}", size(huge)) ///
	graphregion(margin(5 0.5 0.5 0.5)) ///
	name(district_fe, replace)
	
// export source data:	
reshape wide bias*, j(temporal_variance_percentage) i(rho_str)
export delimited "${OUTPUT}/output/graphs/attenuation_bias/common_scale/bias_district_fe_sourcedata.csv", replace


	
*** Combined graph:
graph combine district_ols district_fe, scheme(s1mono) altshrink ysize(9cm) xsize(18cm)

graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/bias_district_combined.png", replace width(2000)
graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/bias_district_combined.pdf", replace