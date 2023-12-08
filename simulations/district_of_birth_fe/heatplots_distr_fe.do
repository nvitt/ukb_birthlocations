***************************************************************************

clear
est clear
set matsize 11000



******User
global DRIVE 	"//rdsfcifs.acrc.bris.ac.uk/GeneEnvironment_Interactions/UKB/"
global OUTPUT	"C:/Users/pk20062/Dropbox/DONNI - UKB birth location accuracy/"





*** Pooled across different fixed effect SDs:

// load simulation output:
use "${OUTPUT}/output/simulations/district_simulations_district_fe.dta", clear
keep if rho<=0.975
replace bias=(bias/(sd_fe/sd_x))
tostring rho, gen(rho_str) usedisplayformat

collapse (mean) bias, by(rho_str r)

// format labels for rho:
levelsof rho_str, local(levels_rho)

local i=1
local ylabels=""
foreach lab in `levels_rho' {
	local ylabels `ylabels' `i' "{bf:`lab'}"
	local i=`i'+1
}

// heatplot in greyscale:
heatplot bias rho_str i.r, ///
	scheme(lean1) graphregion(margin(zero)) ///
	values(format(%3.2f) size(vsmall) transform(cond(@>-0.005 & @<0.005, 0.00, @))) ///
	xtitle("{bf:Correlation of X and fixed effects}", size(small)) ///
	ytitle("{bf:Spatial autocorrelation ({it:{&rho}})}", size(small)) ///
	color(hcl diverging, hue(0 0) chroma(0) intensity(.7)) ///
	cuts(-1(0.01)1) ///
	xscale(noline alt) plotregion(margin(zero) lwidth(none)) ///
	yscale(reverse noline) ///
	xlabel(1 "{bf:-0.95}" 2 "{bf:-0.75}" 3 "{bf:-0.50}" 4 "{bf:-0.25}" 5 "{bf:0.00}" 6 "{bf:0.25}" 7 "{bf:0.50}" 8 "{bf:0.75}" 9 "{bf:0.95}", noticks labgap(3pt) labsize(vsmall)) ///
	ylabel(`ylabels', noticks labgap(5pt) labsize(vsmall)) ///
	legend(off) ysize(4) xsize(4)
	
graph export "${OUTPUT}/output/graphs/district_fe_bias/bias_district_fe_pooled_bw.png", replace width(2000)
graph export "${OUTPUT}/output/graphs/district_fe_bias/bias_district_fe_pooled_bw.pdf", replace
	
// heatplot in colour:	
heatplot bias rho_str i.r, ///
	scheme(lean1) graphregion(margin(zero)) ///
	values(format(%3.2f) size(vsmall) transform(cond(@>-0.005 & @<0.005, 0.00, @))) ///
	xtitle("{bf:Correlation of X and fixed effects}", size(small)) ///
	ytitle("{bf:Spatial autocorrelation ({it:{&rho}})}", size(small)) ///
	color(hcl diverging, hue(10 10) chroma(80) luminance(25) power(1) intensity(.7)) ///
	cuts(-1(0.01)1) ///
	xscale(noline alt) plotregion(margin(zero) lwidth(none)) ///
	yscale(reverse noline) ///
	xlabel(1 "{bf:-0.95}" 2 "{bf:-0.75}" 3 "{bf:-0.50}" 4 "{bf:-0.25}" 5 "{bf:0.00}" 6 "{bf:0.25}" 7 "{bf:0.50}" 8 "{bf:0.75}" 9 "{bf:0.95}", noticks labgap(3pt) labsize(vsmall)) ///
	ylabel(`ylabels', noticks labgap(5pt) labsize(vsmall)) ///
	legend(off) ysize(4) xsize(4)
	
graph export "${OUTPUT}/output/graphs/district_fe_bias/bias_district_fe_pooled_colour.png", replace width(2000)
graph export "${OUTPUT}/output/graphs/district_fe_bias/bias_district_fe_pooled_colour.pdf", replace










*** Fixed effect SDs = 0.1:

// load simulation output:
use "${OUTPUT}/output/simulations/district_simulations_district_fe.dta", clear
keep if rho<=0.975 & sd_fe==0.1
replace bias=(bias/(sd_fe/sd_x))
tostring rho, gen(rho_str) usedisplayformat

collapse (mean) bias, by(rho_str r)

// format labels for rho:
levelsof rho_str, local(levels_rho)

local i=1
local ylabels=""
foreach lab in `levels_rho' {
	local ylabels `ylabels' `i' "{bf:`lab'}"
	local i=`i'+1
}

// heatplot in greyscale:
heatplot bias rho_str i.r, ///
	scheme(lean1) graphregion(margin(zero)) ///
	values(format(%3.2f) size(vsmall) transform(cond(@>-0.005 & @<0.005, 0.00, @))) ///
	xtitle("{bf:Correlation of X and fixed effects}", size(small)) ///
	ytitle("{bf:Spatial autocorrelation ({it:{&rho}})}", size(small)) ///
	color(hcl diverging, hue(0 0) chroma(0) intensity(.7)) ///
	cuts(-1(0.01)1) ///
	xscale(noline alt) plotregion(margin(zero) lwidth(none)) ///
	yscale(reverse noline) ///
	xlabel(1 "{bf:-0.95}" 2 "{bf:-0.75}" 3 "{bf:-0.50}" 4 "{bf:-0.25}" 5 "{bf:0.00}" 6 "{bf:0.25}" 7 "{bf:0.50}" 8 "{bf:0.75}" 9 "{bf:0.95}", noticks labgap(3pt) labsize(vsmall)) ///
	ylabel(`ylabels', noticks labgap(5pt) labsize(vsmall)) ///
	legend(off) ysize(4) xsize(4)
	
graph export "${OUTPUT}/output/graphs/district_fe_bias/bias_district_fe_sdfe_0_1_bw.png", replace width(2000)
graph export "${OUTPUT}/output/graphs/district_fe_bias/bias_district_fe_sdfe_0_1_bw.pdf", replace
	
// heatplot in colour:	
heatplot bias rho_str i.r, ///
	scheme(lean1) graphregion(margin(zero)) ///
	values(format(%3.2f) size(vsmall) transform(cond(@>-0.005 & @<0.005, 0.00, @))) ///
	xtitle("{bf:Correlation of X and fixed effects}", size(small)) ///
	ytitle("{bf:Spatial autocorrelation ({it:{&rho}})}", size(small)) ///
	color(hcl diverging, hue(10 10) chroma(80) luminance(25) power(1) intensity(.7)) ///
	cuts(-1(0.01)1) ///
	xscale(noline alt) plotregion(margin(zero) lwidth(none)) ///
	yscale(reverse noline) ///
	xlabel(1 "{bf:-0.95}" 2 "{bf:-0.75}" 3 "{bf:-0.50}" 4 "{bf:-0.25}" 5 "{bf:0.00}" 6 "{bf:0.25}" 7 "{bf:0.50}" 8 "{bf:0.75}" 9 "{bf:0.95}", noticks labgap(3pt) labsize(vsmall)) ///
	ylabel(`ylabels', noticks labgap(5pt) labsize(vsmall)) ///
	legend(off) ysize(4) xsize(4)
	
graph export "${OUTPUT}/output/graphs/district_fe_bias/bias_district_fe_sdfe_0_1_colour.png", replace width(2000)
graph export "${OUTPUT}/output/graphs/district_fe_bias/bias_district_fe_sdfe_0_1_colour.pdf", replace










*** Fixed effect SDs = 0.5:

// load simulation output:
use "${OUTPUT}/output/simulations/district_simulations_district_fe.dta", clear
keep if rho<=0.975 & sd_fe==0.5
replace bias=(bias/(sd_fe/sd_x))
tostring rho, gen(rho_str) usedisplayformat

collapse (mean) bias, by(rho_str r)

// format labels for rho:
levelsof rho_str, local(levels_rho)

local i=1
local ylabels=""
foreach lab in `levels_rho' {
	local ylabels `ylabels' `i' "{bf:`lab'}"
	local i=`i'+1
}

// heatplot in greyscale:
heatplot bias rho_str i.r, ///
	scheme(lean1) graphregion(margin(zero)) ///
	values(format(%3.2f) size(vsmall) transform(cond(@>-0.005 & @<0.005, 0.00, @))) ///
	xtitle("{bf:Correlation of X and fixed effects}", size(small)) ///
	ytitle("{bf:Spatial autocorrelation ({it:{&rho}})}", size(small)) ///
	color(hcl diverging, hue(0 0) chroma(0) intensity(.7)) ///
	cuts(-1(0.01)1) ///
	xscale(noline alt) plotregion(margin(zero) lwidth(none)) ///
	yscale(reverse noline) ///
	xlabel(1 "{bf:-0.95}" 2 "{bf:-0.75}" 3 "{bf:-0.50}" 4 "{bf:-0.25}" 5 "{bf:0.00}" 6 "{bf:0.25}" 7 "{bf:0.50}" 8 "{bf:0.75}" 9 "{bf:0.95}", noticks labgap(3pt) labsize(vsmall)) ///
	ylabel(`ylabels', noticks labgap(5pt) labsize(vsmall)) ///
	legend(off) ysize(4) xsize(4)
	
graph export "${OUTPUT}/output/graphs/district_fe_bias/bias_district_fe_sdfe_0_5_bw.png", replace width(2000)
graph export "${OUTPUT}/output/graphs/district_fe_bias/bias_district_fe_sdfe_0_5_bw.pdf", replace
	
// heatplot in colour:	
heatplot bias rho_str i.r, ///
	scheme(lean1) graphregion(margin(zero)) ///
	values(format(%3.2f) size(vsmall) transform(cond(@>-0.005 & @<0.005, 0.00, @))) ///
	xtitle("{bf:Correlation of X and fixed effects}", size(small)) ///
	ytitle("{bf:Spatial autocorrelation ({it:{&rho}})}", size(small)) ///
	color(hcl diverging, hue(10 10) chroma(80) luminance(25) power(1) intensity(.7)) ///
	cuts(-1(0.01)1) ///
	xscale(noline alt) plotregion(margin(zero) lwidth(none)) ///
	yscale(reverse noline) ///
	xlabel(1 "{bf:-0.95}" 2 "{bf:-0.75}" 3 "{bf:-0.50}" 4 "{bf:-0.25}" 5 "{bf:0.00}" 6 "{bf:0.25}" 7 "{bf:0.50}" 8 "{bf:0.75}" 9 "{bf:0.95}", noticks labgap(3pt) labsize(vsmall)) ///
	ylabel(`ylabels', noticks labgap(5pt) labsize(vsmall)) ///
	legend(off) ysize(4) xsize(4)
	
graph export "${OUTPUT}/output/graphs/district_fe_bias/bias_district_fe_sdfe_0_5_colour.png", replace width(2000)
graph export "${OUTPUT}/output/graphs/district_fe_bias/bias_district_fe_sdfe_0_5_colour.pdf", replace










*** Fixed effect SDs = 1:

// load simulation output:
use "${OUTPUT}/output/simulations/district_simulations_district_fe.dta", clear
keep if rho<=0.975 & sd_fe==1
replace bias=(bias/(sd_fe/sd_x))
tostring rho, gen(rho_str) usedisplayformat

collapse (mean) bias, by(rho_str r)

// format labels for rho:
levelsof rho_str, local(levels_rho)

local i=1
local ylabels=""
foreach lab in `levels_rho' {
	local ylabels `ylabels' `i' "{bf:`lab'}"
	local i=`i'+1
}

// heatplot in greyscale:
heatplot bias rho_str i.r, ///
	scheme(lean1) graphregion(margin(zero)) ///
	values(format(%3.2f) size(vsmall) transform(cond(@>-0.005 & @<0.005, 0.00, @))) ///
	xtitle("{bf:Correlation of X and fixed effects}", size(small)) ///
	ytitle("{bf:Spatial autocorrelation ({it:{&rho}})}", size(small)) ///
	color(hcl diverging, hue(0 0) chroma(0) intensity(.7)) ///
	cuts(-1(0.01)1) ///
	xscale(noline alt) plotregion(margin(zero) lwidth(none)) ///
	yscale(reverse noline) ///
	xlabel(1 "{bf:-0.95}" 2 "{bf:-0.75}" 3 "{bf:-0.50}" 4 "{bf:-0.25}" 5 "{bf:0.00}" 6 "{bf:0.25}" 7 "{bf:0.50}" 8 "{bf:0.75}" 9 "{bf:0.95}", noticks labgap(3pt) labsize(vsmall)) ///
	ylabel(`ylabels', noticks labgap(5pt) labsize(vsmall)) ///
	legend(off) ysize(4) xsize(4)
	
graph export "${OUTPUT}/output/graphs/district_fe_bias/bias_district_fe_sdfe_1_bw.png", replace width(2000)
graph export "${OUTPUT}/output/graphs/district_fe_bias/bias_district_fe_sdfe_1_bw.pdf", replace
	
// heatplot in colour:	
heatplot bias rho_str i.r, ///
	scheme(lean1) graphregion(margin(zero)) ///
	values(format(%3.2f) size(vsmall) transform(cond(@>-0.005 & @<0.005, 0.00, @))) ///
	xtitle("{bf:Correlation of X and fixed effects}", size(small)) ///
	ytitle("{bf:Spatial autocorrelation ({it:{&rho}})}", size(small)) ///
	color(hcl diverging, hue(10 10) chroma(80) luminance(25) power(1) intensity(.7)) ///
	cuts(-1(0.01)1) ///
	xscale(noline alt) plotregion(margin(zero) lwidth(none)) ///
	yscale(reverse noline) ///
	xlabel(1 "{bf:-0.95}" 2 "{bf:-0.75}" 3 "{bf:-0.50}" 4 "{bf:-0.25}" 5 "{bf:0.00}" 6 "{bf:0.25}" 7 "{bf:0.50}" 8 "{bf:0.75}" 9 "{bf:0.95}", noticks labgap(3pt) labsize(vsmall)) ///
	ylabel(`ylabels', noticks labgap(5pt) labsize(vsmall)) ///
	legend(off) ysize(4) xsize(4)
	
graph export "${OUTPUT}/output/graphs/district_fe_bias/bias_district_fe_sdfe_1_colour.png", replace width(2000)
graph export "${OUTPUT}/output/graphs/district_fe_bias/bias_district_fe_sdfe_1_colour.pdf", replace










*** Fixed effect SDs = 5:

// load simulation output:
use "${OUTPUT}/output/simulations/district_simulations_district_fe.dta", clear
keep if rho<=0.975 & sd_fe==5
replace bias=(bias/(sd_fe/sd_x))
tostring rho, gen(rho_str) usedisplayformat

collapse (mean) bias, by(rho_str r)

// format labels for rho:
levelsof rho_str, local(levels_rho)

local i=1
local ylabels=""
foreach lab in `levels_rho' {
	local ylabels `ylabels' `i' "{bf:`lab'}"
	local i=`i'+1
}

// heatplot in greyscale:
heatplot bias rho_str i.r, ///
	scheme(lean1) graphregion(margin(zero)) ///
	values(format(%3.2f) size(vsmall) transform(cond(@>-0.005 & @<0.005, 0.00, @))) ///
	xtitle("{bf:Correlation of X and fixed effects}", size(small)) ///
	ytitle("{bf:Spatial autocorrelation ({it:{&rho}})}", size(small)) ///
	color(hcl diverging, hue(0 0) chroma(0) intensity(.7)) ///
	cuts(-1(0.01)1) ///
	xscale(noline alt) plotregion(margin(zero) lwidth(none)) ///
	yscale(reverse noline) ///
	xlabel(1 "{bf:-0.95}" 2 "{bf:-0.75}" 3 "{bf:-0.50}" 4 "{bf:-0.25}" 5 "{bf:0.00}" 6 "{bf:0.25}" 7 "{bf:0.50}" 8 "{bf:0.75}" 9 "{bf:0.95}", noticks labgap(3pt) labsize(vsmall)) ///
	ylabel(`ylabels', noticks labgap(5pt) labsize(vsmall)) ///
	legend(off) ysize(4) xsize(4)
	
graph export "${OUTPUT}/output/graphs/district_fe_bias/bias_district_fe_sdfe_5_bw.png", replace width(2000)
graph export "${OUTPUT}/output/graphs/district_fe_bias/bias_district_fe_sdfe_5_bw.pdf", replace
	
// heatplot in colour:	
heatplot bias rho_str i.r, ///
	scheme(lean1) graphregion(margin(zero)) ///
	values(format(%3.2f) size(vsmall) transform(cond(@>-0.005 & @<0.005, 0.00, @))) ///
	xtitle("{bf:Correlation of X and fixed effects}", size(small)) ///
	ytitle("{bf:Spatial autocorrelation ({it:{&rho}})}", size(small)) ///
	color(hcl diverging, hue(10 10) chroma(80) luminance(25) power(1) intensity(.7)) ///
	cuts(-1(0.01)1) ///
	xscale(noline alt) plotregion(margin(zero) lwidth(none)) ///
	yscale(reverse noline) ///
	xlabel(1 "{bf:-0.95}" 2 "{bf:-0.75}" 3 "{bf:-0.50}" 4 "{bf:-0.25}" 5 "{bf:0.00}" 6 "{bf:0.25}" 7 "{bf:0.50}" 8 "{bf:0.75}" 9 "{bf:0.95}", noticks labgap(3pt) labsize(vsmall)) ///
	ylabel(`ylabels', noticks labgap(5pt) labsize(vsmall)) ///
	legend(off) ysize(4) xsize(4)
	
graph export "${OUTPUT}/output/graphs/district_fe_bias/bias_district_fe_sdfe_5_colour.png", replace width(2000)
graph export "${OUTPUT}/output/graphs/district_fe_bias/bias_district_fe_sdfe_5_colour.pdf", replace