***************************************************************************

clear
est clear
set matsize 11000



******User
global DRIVE 	"//rdsfcifs.acrc.bris.ac.uk/GeneEnvironment_Interactions/UKB/"
global OUTPUT	"C:/Users/pk20062/Dropbox/DONNI - UKB birth location accuracy/"






*** Load simulation output:
use "${OUTPUT}/output/simulations/examples_sibling_error.dta", clear
gen estimation="OLS"

append using "${OUTPUT}/output/simulations/examples_sibling_error_sibling_fe.dta"
replace estimation="FE" if estimation==""

count if n_unbiased==n_biased
count if n_unbiased!=n_biased

gen n=n_unbiased

keep varname bias n estimation


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

estpost tabstat bias if estimation=="OLS", by(group) nototal elabel
local label `e(labels)'
est store bias_ols

estpost tabstat bias if estimation=="FE", by(group) nototal elabel
local label `e(labels)'
est store bias_fe

// Table:
esttab bias_ols bias_fe, ///
			cells("mean(fmt(2))") nonumber ///
			collabel(none) mlabels("OLS" "Sibling FE") ///
			mgroups("Attenuation bias (%)", pattern(1 0)) ///
			coeflabel(`label') ///
			refcat(1 "Disease rates during 1st year of life:" 9 "Demographics during 1st year of life:" 14 "Demographics - 1951 census:", nolabel) ///
			noobs varwidth(50)
			
// Latex export:
esttab bias_ols bias_fe using "${OUTPUT}/output/tablefragments/bias_examples_combined.tex", ///
			cells("mean(fmt(2))") nonumber ///
			collabel(none) mlabels("OLS" "Sibling FE", prefix({) suffix(})) ///
			mgroups("Attenuation bias (\%)", pattern(1 0) ///
			span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) ///
			coeflabel(`label') ///
			refcat(1 "\textbf{Disease rates during 1st year of life:}" 9 "\textbf{Demographics during 1st year of life:}" 14 "\textbf{Demographics - 1951 census:}", nolabel) ///
			noobs ///
			compress replace booktabs fragment

			
			
			
			
collapse (mean) bias n, by(varname vartype group estimation)



*** Heatplot - version 1:
// heatplot in greyscale:
heatplot bias i.group estimation, ///
	scheme(lean1) graphregion(margin(zero)) ///
	values(format(%3.1f) size(vsmall)) ///
	xtitle("{bf:Estimation}", size(small)) ///
	ytitle("{bf:Exposure variables}", size(small) axis(3)) ///
	color(hcl grays, reverse intensity(.7)) ///
	cuts(0(1)100) ///
	xscale(reverse noline alt) plotregion(margin(zero) lwidth(none)) ///
	yscale(reverse noline axis(1)) ///
	yscale(off axis(2)) ///
	yscale(noextend axis(3)) ///
	xlabel(1 "{bf:Sibling FE}" 2 "{bf:OLS}", noticks labgap(1pt) labsize(vsmall)) ///
	ylabel(, noticks labgap(5pt) labsize(vsmall) axis(1)) ///
	ylabel(4.5 "Disease rates" 11 "Demographics" 21 "Demographics - 1951 census", noticks labsize(vsmall) axis(3) angle(90)) ///
	ytick(0.5 8.5 13.5 28.5, axis(3) tposition(inside)) ///
	legend(off) ysize(18cm) xsize(18cm) yaxis(1 2 3)

graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/bias_examples_bw_v1.png", replace width(2000)
graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/bias_examples_bw_v1.pdf", replace

// heatplot in colour:	
heatplot bias i.group estimation, ///
	scheme(lean1) graphregion(margin(zero)) ///
	values(format(%3.1f) size(vsmall)) ///
	xtitle("{bf:Estimation}", size(small)) ///
	ytitle("{bf:Exposure variables}", size(small) axis(3)) ///
	color(hcl reds, reverse intensity(.9)) ///
	cuts(0(1)100) ///
	xscale(reverse noline alt) plotregion(margin(zero) lwidth(none)) ///
	yscale(reverse noline axis(1)) ///
	yscale(off axis(2)) ///
	yscale(noextend axis(3)) ///
	xlabel(1 "{bf:Sibling FE}" 2 "{bf:OLS}", noticks labgap(1pt) labsize(vsmall)) ///
	ylabel(, noticks labgap(5pt) labsize(vsmall) axis(1)) ///
	ylabel(4.5 `""{bf:Disease rates}" "{bf:1st year of life}""' 11 `""{bf:Demographics}" "{bf:1st year of life}""' 21 `""{bf:Demographics}" "{bf:1951 census}""', noticks labsize(vsmall) axis(3) angle(90)) ///
	ytick(0.5 8.5 13.5 28.5, axis(3) tposition(inside)) ///
	legend(off) ysize(18cm) xsize(18cm) yaxis(1 2 3)

graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/bias_examples_colour_v1.png", replace width(2000)
graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/bias_examples_colour_v1.pdf", replace

	
	


*** Heatplot - version 2:
// add observations for category captions (and gaps):
preserve
set obs 58
gen group_new=group
replace group_new=0 if _n>=57
replace estimation="OLS" if _n==57
replace estimation="FE" if _n==58

replace group_new=group_new+1
replace group_new=group_new+2 if group_new>=10
replace group_new=group_new+2 if group_new>=17

set obs 60
replace group_new=11 if _n>=59
replace estimation="OLS" if _n==59
replace estimation="FE" if _n==60

set obs 62
replace group_new=18 if _n>=61
replace estimation="OLS" if _n==61
replace estimation="FE" if _n==62


// heatplot in greyscale:
heatplot bias group_new estimation, ///
	scheme(lean1) graphregion(margin(zero)) ///
	values(format(%3.1f) size(vsmall)) ///
	discrete ///
	xtitle("{bf:Estimation}", size(small)) ///
	ytitle("{bf:Exposure variables}", size(small)) ///
	color(hcl grays, reverse intensity(.7)) ///
	cuts(0(1)100) ///
	xscale(reverse noline alt) plotregion(margin(zero) lwidth(none)) ///
	yscale(reverse noline) ///
	xlabel(1 "{bf:Sibling FE}" 2 "{bf:OLS}", noticks labgap(3pt) labsize(vsmall)) ///
	ylabel(1 "{bf:Disease rates - 1st year of life:}" 11 "{bf:Demographics - 1st year of life:}" 18 "{bf:Demographics - 1951 census:}" ///
	2 "Diphtheria rate" 3 "Measles rate" 4 "Nonparalytic polio rate" 5 "Paralytic polio rate" ///
	6 "Pneumonia rate" 7 "Respiratory tuberculosis rate" 8 "Scarlet fever rate" 9 "Whooping cough rate" ///
	12 "Birth rate" 13 "Death rate" 14 "Illegitimacy rate" 15 "Infant mortality rate" 16 "Stillbirth rate" ///
	19 "Share housing density 0 - 1" 20 "Share housing density 1 - 1.5" 21 "Share housing density 1.5 - 2" ///
	22 "Share housing density 2 - 3" 23 "Share housing density 3+" 24 "Share in social class I" 25 "Share in social class II" ///
	26 "Share in social class III" 27 "Share in social class IV" 28 "Share in social class V"  ///
	29 "Share left FT education at 0-14" 30 "Share left FT education at 15" 31 "Share left FT education at 16" ///
	32 "Share left FT education at 17-19" 33 "Share left FT education at 20+" , noticks labgap(5pt) labsize(vsmall)) ///
	legend(off) ysize(21cm) xsize(18cm)
	
graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/bias_examples_bw_v2.png", replace width(2000)
graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/bias_examples_bw_v2.pdf", replace

// heatplot in colour:	
heatplot bias group_new estimation, ///
	scheme(lean1) graphregion(margin(zero)) ///
	values(format(%3.1f) size(vsmall)) ///
	discrete ///
	xtitle("{bf:Estimation}", size(small)) ///
	ytitle("{bf:Exposure variables}", size(small)) ///
	color(hcl reds, reverse intensity(.9)) ///
	cuts(0(1)100) ///
	xscale(reverse noline alt) plotregion(margin(zero) lwidth(none)) ///
	yscale(reverse noline) ///
	xlabel(1 "{bf:Sibling FE}" 2 "{bf:OLS}", noticks labgap(3pt) labsize(vsmall)) ///
	ylabel(1 "{bf:Disease rates - 1st year of life:}" 11 "{bf:Demographics - 1st year of life:}" 18 "{bf:Demographics - 1951 census:}" ///
	2 "Diphtheria rate" 3 "Measles rate" 4 "Nonparalytic polio rate" 5 "Paralytic polio rate" ///
	6 "Pneumonia rate" 7 "Respiratory tuberculosis rate" 8 "Scarlet fever rate" 9 "Whooping cough rate" ///
	12 "Birth rate" 13 "Death rate" 14 "Illegitimacy rate" 15 "Infant mortality rate" 16 "Stillbirth rate" ///
	19 "Share housing density 0 - 1" 20 "Share housing density 1 - 1.5" 21 "Share housing density 1.5 - 2" ///
	22 "Share housing density 2 - 3" 23 "Share housing density 3+" 24 "Share in social class I" 25 "Share in social class II" ///
	26 "Share in social class III" 27 "Share in social class IV" 28 "Share in social class V"  ///
	29 "Share left FT education at 0-14" 30 "Share left FT education at 15" 31 "Share left FT education at 16" ///
	32 "Share left FT education at 17-19" 33 "Share left FT education at 20+" , noticks labgap(5pt) labsize(vsmall)) ///
	legend(off) ysize(21cm) xsize(18cm)
	
graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/bias_examples_colour_v2.png", replace width(2000)
graph export "${OUTPUT}/output/graphs/attenuation_bias/common_scale/bias_examples_colour_v2.pdf", replace
	
restore	




*** Export source data:	
preserve

egen i=group(varname)
reshape wide bias n, i(i) j(estimation) string
sort group

gen vargroup="Disease rates - 1st year of life" if vartype==1
replace vargroup="Demographics - 1st year of life" if vartype==2 
replace vargroup="Demographics - 1951 census" if vartype==3

keep vargroup varname biasOLS nOLS biasFE nFE
order vargroup varname biasOLS nOLS biasFE nFE

export delimited "${OUTPUT}/output/graphs/attenuation_bias/common_scale/bias_examples_sourcedata.csv", replace

restore