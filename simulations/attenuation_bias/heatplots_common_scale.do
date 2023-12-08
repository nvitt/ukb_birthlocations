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

// heatplot in greyscale:
heatplot bias rho_str i.temporal_variance_percentage, ///
	scheme(lean1) graphregion(margin(zero)) ///
	values(format(%3.1f) size(vsmall)) ///
	xtitle("{bf:Variance share from time variation}", size(small)) ///
	ytitle("{bf:Spatial autocorrelation ({it:{&rho}})}", size(small)) ///
	color(hcl grays, reverse intensity(.7)) ///
	cuts(0(1)100) ///
	xscale(noline alt) plotregion(margin(zero) lwidth(none)) ///
	yscale(reverse noline) ///
	xlabel(1 "{bf:0%}" 2 "{bf:20%}" 3 "{bf:40%}" 4 "{bf:60%}" 5 "{bf:80%}" 6 "{bf:100%}", noticks labgap(3pt) labsize(vsmall)) ///
	ylabel(`ylabels', noticks labgap(5pt) labsize(vsmall)) ///
	legend(off) ysize(4) xsize(4)

graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/bias_birth_coordinates_bw.png", replace width(2000)
graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/bias_birth_coordinates_bw.pdf", replace
	
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
	legend(off) ysize(4) xsize(4)
	
graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/bias_birth_coordinates_colour.png", replace width(2000)
graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/bias_birth_coordinates_colour.pdf", replace
	
	
	



****************************************************
*** Birth coordinate simulations - Fixed effects ***
****************************************************

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

// heatplot in greyscale:
heatplot bias rho_str i.temporal_variance_percentage, ///
	scheme(lean1) graphregion(margin(zero)) ///
	values(format(%3.1f) size(vsmall)) ///
	xtitle("{bf:Variance share from time variation}", size(small)) ///
	ytitle("{bf:Spatial autocorrelation ({it:{&rho}})}", size(small)) ///
	color(hcl grays, reverse intensity(.7)) ///
	cuts(0(1)100) ///
	xscale(noline alt) plotregion(margin(zero) lwidth(none)) ///
	yscale(reverse noline) ///
	xlabel(1 "{bf:0%}" 2 "{bf:20%}" 3 "{bf:40%}" 4 "{bf:60%}" 5 "{bf:80%}" 6 "{bf:100%}", noticks labgap(3pt) labsize(vsmall)) ///
	ylabel(`ylabels', noticks labgap(5pt) labsize(vsmall)) ///
	legend(off) ysize(4) xsize(4)
	
graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/fe_bias_birth_coordinates_bw.png", replace width(2000)
graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/fe_bias_birth_coordinates_bw.pdf", replace
	
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
	legend(off) ysize(4) xsize(4)
	
graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/fe_bias_birth_coordinates_colour.png", replace width(2000)
graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/fe_bias_birth_coordinates_colour.pdf", replace
	
	
	



**************************
*** Parish simulations ***
**************************

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

// heatplot in greyscale:
heatplot bias rho_str i.temporal_variance_percentage, ///
	scheme(lean1) graphregion(margin(zero)) ///
	values(format(%3.1f) size(vsmall)) ///
	xtitle("{bf:Variance share from time variation}", size(small)) ///
	ytitle("{bf:Spatial autocorrelation ({it:{&rho}})}", size(small)) ///
	color(hcl grays, reverse intensity(.7)) ///
	cuts(0(1)100) ///
	xscale(noline alt) plotregion(margin(zero) lwidth(none)) ///
	yscale(reverse noline) ///
	xlabel(1 "{bf:0%}" 2 "{bf:20%}" 3 "{bf:40%}" 4 "{bf:60%}" 5 "{bf:80%}" 6 "{bf:100%}", noticks labgap(3pt) labsize(vsmall)) ///
	ylabel(`ylabels', noticks labgap(5pt) labsize(vsmall)) ///
	legend(off) ysize(4) xsize(4)
	
graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/bias_parish_bw.png", replace width(2000)
graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/bias_parish_bw.pdf", replace
	
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
	legend(off) ysize(4) xsize(4)
	
graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/bias_parish_colour.png", replace width(2000)
graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/bias_parish_colour.pdf", replace
	
	
	



******************************************
*** Parish simulations - Fixed effects ***
******************************************

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

// heatplot in greyscale:
heatplot bias rho_str i.temporal_variance_percentage, ///
	scheme(lean1) graphregion(margin(zero)) ///
	values(format(%3.1f) size(vsmall)) ///
	xtitle("{bf:Variance share from time variation}", size(small)) ///
	ytitle("{bf:Spatial autocorrelation ({it:{&rho}})}", size(small)) ///
	color(hcl grays, reverse intensity(.7)) ///
	cuts(0(1)100) ///
	xscale(noline alt) plotregion(margin(zero) lwidth(none)) ///
	yscale(reverse noline) ///
	xlabel(1 "{bf:0%}" 2 "{bf:20%}" 3 "{bf:40%}" 4 "{bf:60%}" 5 "{bf:80%}" 6 "{bf:100%}", noticks labgap(3pt) labsize(vsmall)) ///
	ylabel(`ylabels', noticks labgap(5pt) labsize(vsmall)) ///
	legend(off) ysize(4) xsize(4)
	
graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/fe_bias_parish_bw.png", replace width(2000)
graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/fe_bias_parish_bw.pdf", replace
	
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
	legend(off) ysize(4) xsize(4)
	
graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/fe_bias_parish_colour.png", replace width(2000)
graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/fe_bias_parish_colour.pdf", replace
	
	
	



****************************
*** District simulations ***
****************************

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

// heatplot in greyscale:
heatplot bias rho_str i.temporal_variance_percentage, ///
	scheme(lean1) graphregion(margin(zero)) ///
	values(format(%3.1f) size(vsmall)) ///
	xtitle("{bf:Variance share from time variation}", size(small)) ///
	ytitle("{bf:Spatial autocorrelation ({it:{&rho}})}", size(small)) ///
	color(hcl grays, reverse intensity(.7)) ///
	cuts(0(1)100) ///
	xscale(noline alt) plotregion(margin(zero) lwidth(none)) ///
	yscale(reverse noline) ///
	xlabel(1 "{bf:0%}" 2 "{bf:20%}" 3 "{bf:40%}" 4 "{bf:60%}" 5 "{bf:80%}" 6 "{bf:100%}", noticks labgap(3pt) labsize(vsmall)) ///
	ylabel(`ylabels', noticks labgap(5pt) labsize(vsmall)) ///
	legend(off) ysize(4) xsize(4)
	
graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/bias_district_bw.png", replace width(2000)
graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/bias_district_bw.pdf", replace
	
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
	legend(off) ysize(4) xsize(4)
	
graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/bias_district_colour.png", replace width(2000)
graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/bias_district_colour.pdf", replace
	
	
	



********************************************
*** District simulations - Fixed effects ***
********************************************

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

// heatplot in greyscale:
heatplot bias rho_str i.temporal_variance_percentage, ///
	scheme(lean1) graphregion(margin(zero)) ///
	values(format(%3.1f) size(vsmall)) ///
	xtitle("{bf:Variance share from time variation}", size(small)) ///
	ytitle("{bf:Spatial autocorrelation ({it:{&rho}})}", size(small)) ///
	color(hcl grays, reverse intensity(.7)) ///
	cuts(0(1)100) ///
	xscale(noline alt) plotregion(margin(zero) lwidth(none)) ///
	yscale(reverse noline) ///
	xlabel(1 "{bf:0%}" 2 "{bf:20%}" 3 "{bf:40%}" 4 "{bf:60%}" 5 "{bf:80%}" 6 "{bf:100%}", noticks labgap(3pt) labsize(vsmall)) ///
	ylabel(`ylabels', noticks labgap(5pt) labsize(vsmall)) ///
	legend(off) ysize(4) xsize(4)
	
graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/fe_bias_district_bw.png", replace width(2000)
graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/fe_bias_district_bw.pdf", replace
	
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
	legend(off) ysize(4) xsize(4)
	
graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/fe_bias_district_colour.png", replace width(2000)
graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/fe_bias_district_colour.pdf", replace
