***************************************************************************

clear
est clear
set matsize 11000



******User
global DRIVE 	"//rdsfcifs.acrc.bris.ac.uk/GeneEnvironment_Interactions/UKB/"
global OUTPUT	"C:/Users/pk20062/Dropbox/DONNI - UKB birth location accuracy/output/"






*** Load sibling birth location dataset:
use "${DRIVE}GeographicID/Projects/NV_Papers/Birth locations/dta/sibling_birth_location_data.dta", clear




	
	
	
	
*******************
*** Regressions ***
*******************

* Different parishes:
reg parish_different age_gap, hc3
est store different_parish

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store different_parish_pars


* Different districts:
reg district_different age_gap, hc3
est store different_district

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store different_district_pars


* Different counties:
reg county_different age_gap, hc3
est store different_county

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store different_county_pars
	
	
* Different birth coordinates:
reg sibling_distance_above_0km age_gap, hc3
est store different_0km

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store different_0km_pars
	
	
* Distance of birth coordinates > 5km:
reg sibling_distance_above_5km age_gap, hc3
est store different_5km

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store different_5km_pars
	
	
* Distance of birth coordinates > 10km:
reg sibling_distance_above_10km age_gap, hc3
est store different_10km

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store different_10km_pars
	
	
* Distance of birth coordinates > 20km:
reg sibling_distance_above_20km age_gap, hc3
est store different_20km

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store different_20km_pars
	
	
* Distance of birth coordinates > 30km:
reg sibling_distance_above_30km age_gap, hc3
est store different_30km

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store different_30km_pars
	
	
* Distance of birth coordinates > 40km:
reg sibling_distance_above_40km age_gap, hc3
est store different_40km

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store different_40km_pars
	
	
* Distance of birth coordinates > 50km:
reg sibling_distance_above_50km age_gap, hc3
est store different_50km

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store different_50km_pars
	
	
	
*** Regression table - full sample:
esttab different_parish different_district different_county different_0km different_5km different_10km different_30km different_50km, ///
	cells(b(fmt(3)) ci(fmt(3) par)) ///
	collabels(none) ///
	mgroup("Different birth location:", pattern(1 0 0 0 0 0 0)) ///
	mlabel("Parish" "District" "County" "d>0km" "d>5km" "d>10km" "d>30km" "d>50km") ///
	coeflabels(age_gap "Age gap (years)" _cons "Constant") ///
	noobs nonotes ///
	stats(N, fmt(0) labels("N (sibling pairs)")) ///
	varwidth(20)
	
esttab different_parish_pars different_district_pars different_county_pars different_0km_pars different_5km_pars different_10km_pars different_30km_pars different_50km_pars, ///
	cells(b(fmt(3)) ci(fmt(3) par)) ///
	collabels(none) ///
	mgroup("Different birth location:", pattern(1 0 0 0 0 0 0)) ///
	mlabel("Parish" "District" "County" "d>0km" "d>5km" "d>10km" "d>30km" "d>50km") ///
	coeflabels(q "q" p "p") ///
	noobs nonotes ///
	stats(N, fmt(0) labels("N (sibling pairs)")) ///
	varwidth(20)
	
	
	
// Latex:
esttab different_parish different_district different_county different_0km different_5km different_10km different_30km different_50km using "${OUTPUT}/tablefragments/differences_regression_tablefragment.tex", ///
	cells(b(fmt(3)) ci(fmt(3) par)) ///
	collabels(none) ///
	mgroup("Different birth location:", pattern(1 0 0 0 0 0 0) ///
	span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) ///
	mlabel("Parish" "District" "County" "d>0km" "d>5km" "d>10km" "d>30km" "d>50km", prefix({) suffix(})) ///
	refcat(age_gap "\textbf{Regression coefficients:}", nolabel) ///
	coeflabels(age_gap "Age gap (years)" _cons "Constant") ///
	noobs nonotes ///
	compress replace booktabs fragment
	
esttab different_parish_pars different_district_pars different_county_pars different_0km_pars different_5km_pars different_10km_pars different_30km_pars different_50km_pars using "${OUTPUT}/tablefragments/differences_regression_tablefragment.tex", ///
	cells(b(fmt(3)) ci(fmt(3) par)) ///
	collabels(none) ///
	mlabel(none) nonumbers ///
	refcat(q "\textbf{Derived probabilities:}", nolabel) ///
	coeflabels(q "$\hat{q}$ (move probability)" p "$\hat{p}$ (error probability)") ///
	noobs nonotes ///
	stats(N, fmt(%9.0fc) labels("N (sibling pairs)") layout(\multicolumn{1}{c}{@})) ///
	compress append booktabs fragment
	


	
	

	
	
**************
*** Graphs ***
**************

est clear

*** Graph with share of siblings born in different parishes:
mean parish_different if age_gap_rounded<=15, over(age_gap_rounded)
est store different_parish_mean

coefplot different_parish_mean, ///
			rename(c.parish_different@0.age_gap_rounded=0 ///
			c.parish_different@1.age_gap_rounded=1 c.parish_different@2.age_gap_rounded=2 ///
			c.parish_different@3.age_gap_rounded=3 c.parish_different@4.age_gap_rounded=4 ///
			c.parish_different@5.age_gap_rounded=5 c.parish_different@6.age_gap_rounded=6 ///
			c.parish_different@7.age_gap_rounded=7 c.parish_different@8.age_gap_rounded=8 ///
			c.parish_different@9.age_gap_rounded=9 c.parish_different@10.age_gap_rounded=10 ///
			c.parish_different@11.age_gap_rounded=11 c.parish_different@12.age_gap_rounded=12 ///
			c.parish_different@13.age_gap_rounded=13 c.parish_different@14.age_gap_rounded=14 ///
			c.parish_different@15.age_gap_rounded=15 ) at(_coef) ///
			/// title("Share of siblings born in different parishes") ///
			ytitle("Share") ///
			ylabel(0 (0.2) 1) yscale(range(-0.05 1)) ///
			yline(0, lpattern(solid) lwidth(medthin) lcolor(gs10)) ///
			xtitle("Age gap, in years") ///
			vertical baselevels omitted  scheme(s1mono)	

graph export "${OUTPUT}/graphs/share_different_parish.png", replace
graph export "${OUTPUT}/graphs/share_different_parish.pdf", replace


// with fitted line:
reg parish_different age_gap if age_gap_rounded<=15, hc3
margins, at(age_gap=(0(1)15)) post
est store different_parish
	
coefplot 	(different_parish, at recast(line) noci lcolor(gs10) lpattern(dash)) ///
			(different_parish_mean, ///
				rename(c.parish_different@0.age_gap_rounded=0 ///
				c.parish_different@1.age_gap_rounded=1 c.parish_different@2.age_gap_rounded=2 ///
				c.parish_different@3.age_gap_rounded=3 c.parish_different@4.age_gap_rounded=4 ///
				c.parish_different@5.age_gap_rounded=5 c.parish_different@6.age_gap_rounded=6 ///
				c.parish_different@7.age_gap_rounded=7 c.parish_different@8.age_gap_rounded=8 ///
				c.parish_different@9.age_gap_rounded=9 c.parish_different@10.age_gap_rounded=10 ///
				c.parish_different@11.age_gap_rounded=11 c.parish_different@12.age_gap_rounded=12 ///
				c.parish_different@13.age_gap_rounded=13 c.parish_different@14.age_gap_rounded=14 ///
				c.parish_different@15.age_gap_rounded=15 ) ///
				at(_coef) baselevels omitted mcolor(gs6) msymbol(O) ciopts(lcolor(gs6))), ///
			/// title("Share of siblings born in different parishes") ///
			ytitle("Share") ///
			ylabel(0 (0.2) 1) yscale(range(-0.05 1)) ///
			yline(0, lpattern(solid) lwidth(medthin) lcolor(gs10)) ///
			xtitle("Age gap, in years") ///
			vertical  scheme(s1mono) legend(off)

graph export "${OUTPUT}/graphs/share_different_parish_lfit.png", replace
graph export "${OUTPUT}/graphs/share_different_parish_lfit.pdf", replace
			
			


*** Graph with share of siblings born in different districts:
mean district_different if age_gap_rounded<=15, over(age_gap_rounded)
est store different_district_mean

coefplot different_district_mean, ///
			rename(c.district_different@0.age_gap_rounded=0 ///
			c.district_different@1.age_gap_rounded=1 c.district_different@2.age_gap_rounded=2 ///
			c.district_different@3.age_gap_rounded=3 c.district_different@4.age_gap_rounded=4 ///
			c.district_different@5.age_gap_rounded=5 c.district_different@6.age_gap_rounded=6 ///
			c.district_different@7.age_gap_rounded=7 c.district_different@8.age_gap_rounded=8 ///
			c.district_different@9.age_gap_rounded=9 c.district_different@10.age_gap_rounded=10 ///
			c.district_different@11.age_gap_rounded=11 c.district_different@12.age_gap_rounded=12 ///
			c.district_different@13.age_gap_rounded=13 c.district_different@14.age_gap_rounded=14 ///
			c.district_different@15.age_gap_rounded=15 ) at(_coef) ///
			/// title("Share of siblings born in different districts") ///
			ytitle("Share") ///
			ylabel(0 (0.2) 1) yscale(range(-0.05 1)) ///
			yline(0, lpattern(solid) lwidth(medthin) lcolor(gs10)) ///
			xtitle("Age gap, in years") ///
			vertical baselevels omitted  scheme(s1mono)	

graph export "${OUTPUT}/graphs/share_different_district.png", replace
graph export "${OUTPUT}/graphs/share_different_district.pdf", replace


// with fitted line:
reg district_different age_gap if age_gap_rounded<=15, hc3
margins, at(age_gap=(0(1)15)) post
est store different_district
	
coefplot 	(different_district, at recast(line) noci lcolor(gs10) lpattern(dash)) ///
			(different_district_mean, ///
				rename(c.district_different@0.age_gap_rounded=0 ///
				c.district_different@1.age_gap_rounded=1 c.district_different@2.age_gap_rounded=2 ///
				c.district_different@3.age_gap_rounded=3 c.district_different@4.age_gap_rounded=4 ///
				c.district_different@5.age_gap_rounded=5 c.district_different@6.age_gap_rounded=6 ///
				c.district_different@7.age_gap_rounded=7 c.district_different@8.age_gap_rounded=8 ///
				c.district_different@9.age_gap_rounded=9 c.district_different@10.age_gap_rounded=10 ///
				c.district_different@11.age_gap_rounded=11 c.district_different@12.age_gap_rounded=12 ///
				c.district_different@13.age_gap_rounded=13 c.district_different@14.age_gap_rounded=14 ///
				c.district_different@15.age_gap_rounded=15 ) ///
				at(_coef) baselevels omitted mcolor(gs6) msymbol(O) ciopts(lcolor(gs6))), ///
			/// title("Share of siblings born in different districts") ///
			ytitle("Share") ///
			ylabel(0 (0.2) 1) yscale(range(-0.05 1)) ///
			yline(0, lpattern(solid) lwidth(medthin) lcolor(gs10)) ///
			xtitle("Age gap, in years") ///
			vertical  scheme(s1mono) legend(off)

graph export "${OUTPUT}/graphs/share_different_district_lfit.png", replace
graph export "${OUTPUT}/graphs/share_different_district_lfit.pdf", replace
	
	
	




*** Graph with share of siblings born in different counties:
mean county_different if age_gap_rounded<=15, over(age_gap_rounded)
est store different_county_mean

coefplot different_county_mean, ///
			rename(c.county_different@0.age_gap_rounded=0 ///
			c.county_different@1.age_gap_rounded=1 c.county_different@2.age_gap_rounded=2 ///
			c.county_different@3.age_gap_rounded=3 c.county_different@4.age_gap_rounded=4 ///
			c.county_different@5.age_gap_rounded=5 c.county_different@6.age_gap_rounded=6 ///
			c.county_different@7.age_gap_rounded=7 c.county_different@8.age_gap_rounded=8 ///
			c.county_different@9.age_gap_rounded=9 c.county_different@10.age_gap_rounded=10 ///
			c.county_different@11.age_gap_rounded=11 c.county_different@12.age_gap_rounded=12 ///
			c.county_different@13.age_gap_rounded=13 c.county_different@14.age_gap_rounded=14 ///
			c.county_different@15.age_gap_rounded=15 ) at(_coef) ///
			/// title("Share of siblings born in different counties") ///
			ytitle("Share") ///
			ylabel(0 (0.2) 1) yscale(range(-0.05 1)) ///
			yline(0, lpattern(solid) lwidth(medthin) lcolor(gs10)) ///
			xtitle("Age gap, in years") ///
			vertical baselevels omitted  scheme(s1mono)	

graph export "${OUTPUT}/graphs/share_different_county.png", replace
graph export "${OUTPUT}/graphs/share_different_county.pdf", replace


// with fitted line:
reg county_different age_gap if age_gap_rounded<=15, hc3
margins, at(age_gap=(0(1)15)) post
est store different_county

coefplot 	(different_county, at recast(line) noci lcolor(gs10) lpattern(dash)) ///
			(different_county_mean, ///
				rename(c.county_different@0.age_gap_rounded=0 ///
				c.county_different@1.age_gap_rounded=1 c.county_different@2.age_gap_rounded=2 ///
				c.county_different@3.age_gap_rounded=3 c.county_different@4.age_gap_rounded=4 ///
				c.county_different@5.age_gap_rounded=5 c.county_different@6.age_gap_rounded=6 ///
				c.county_different@7.age_gap_rounded=7 c.county_different@8.age_gap_rounded=8 ///
				c.county_different@9.age_gap_rounded=9 c.county_different@10.age_gap_rounded=10 ///
				c.county_different@11.age_gap_rounded=11 c.county_different@12.age_gap_rounded=12 ///
				c.county_different@13.age_gap_rounded=13 c.county_different@14.age_gap_rounded=14 ///
				c.county_different@15.age_gap_rounded=15 ) ///
				at(_coef) baselevels omitted mcolor(gs6) msymbol(O) ciopts(lcolor(gs6))), ///
			/// title("Share of siblings born in different counties") ///
			ytitle("Share") ///
			ylabel(0 (0.2) 1) yscale(range(-0.05 1)) ///
			yline(0, lpattern(solid) lwidth(medthin) lcolor(gs10)) ///
			xtitle("Age gap, in years") ///
			vertical  scheme(s1mono) legend(off)

graph export "${OUTPUT}/graphs/share_different_county_lfit.png", replace
graph export "${OUTPUT}/graphs/share_different_county_lfit.pdf", replace
	
	
	
	
	
	

*** Graph with share of siblings with different birth coordinates:
mean sibling_distance_above_0km if age_gap_rounded<=15, over(age_gap_rounded)
est store different_0km_mean

coefplot different_0km_mean, ///
			rename(c.sibling_distance_above_0km@0.age_gap_rounded=0 ///
			c.sibling_distance_above_0km@1.age_gap_rounded=1 c.sibling_distance_above_0km@2.age_gap_rounded=2 ///
			c.sibling_distance_above_0km@3.age_gap_rounded=3 c.sibling_distance_above_0km@4.age_gap_rounded=4 ///
			c.sibling_distance_above_0km@5.age_gap_rounded=5 c.sibling_distance_above_0km@6.age_gap_rounded=6 ///
			c.sibling_distance_above_0km@7.age_gap_rounded=7 c.sibling_distance_above_0km@8.age_gap_rounded=8 ///
			c.sibling_distance_above_0km@9.age_gap_rounded=9 c.sibling_distance_above_0km@10.age_gap_rounded=10 ///
			c.sibling_distance_above_0km@11.age_gap_rounded=11 c.sibling_distance_above_0km@12.age_gap_rounded=12 ///
			c.sibling_distance_above_0km@13.age_gap_rounded=13 c.sibling_distance_above_0km@14.age_gap_rounded=14 ///
			c.sibling_distance_above_0km@15.age_gap_rounded=15 ) at(_coef) ///
			/// title("Share of siblings with different birth coordinates") ///
			ytitle("Share") ///
			ylabel(0 (0.2) 1) yscale(range(-0.05 1)) ///
			yline(0, lpattern(solid) lwidth(medthin) lcolor(gs10)) ///
			xtitle("Age gap, in years") ///
			vertical baselevels omitted  scheme(s1mono)	

graph export "${OUTPUT}/graphs/share_distance_0km.png", replace
graph export "${OUTPUT}/graphs/share_distance_0km.pdf", replace


// with fitted line:
reg sibling_distance_above_0km age_gap if age_gap_rounded<=15, hc3
margins, at(age_gap=(0(1)15)) post
est store different_0km
	
coefplot 	(different_0km, at recast(line) noci lcolor(gs10) lpattern(dash)) ///
			(different_0km_mean, ///
				rename(c.sibling_distance_above_0km@0.age_gap_rounded=0 ///
				c.sibling_distance_above_0km@1.age_gap_rounded=1 c.sibling_distance_above_0km@2.age_gap_rounded=2 ///
				c.sibling_distance_above_0km@3.age_gap_rounded=3 c.sibling_distance_above_0km@4.age_gap_rounded=4 ///
				c.sibling_distance_above_0km@5.age_gap_rounded=5 c.sibling_distance_above_0km@6.age_gap_rounded=6 ///
				c.sibling_distance_above_0km@7.age_gap_rounded=7 c.sibling_distance_above_0km@8.age_gap_rounded=8 ///
				c.sibling_distance_above_0km@9.age_gap_rounded=9 c.sibling_distance_above_0km@10.age_gap_rounded=10 ///
				c.sibling_distance_above_0km@11.age_gap_rounded=11 c.sibling_distance_above_0km@12.age_gap_rounded=12 ///
				c.sibling_distance_above_0km@13.age_gap_rounded=13 c.sibling_distance_above_0km@14.age_gap_rounded=14 ///
				c.sibling_distance_above_0km@15.age_gap_rounded=15 ) ///
				at(_coef) baselevels omitted mcolor(gs6) msymbol(O) ciopts(lcolor(gs6))), ///
			/// title("Share of siblings with different birth coordinates") ///
			ytitle("Share") ///
			ylabel(0 (0.2) 1) yscale(range(-0.05 1)) ///
			yline(0, lpattern(solid) lwidth(medthin) lcolor(gs10)) ///
			xtitle("Age gap, in years") ///
			vertical  scheme(s1mono) legend(off)

graph export "${OUTPUT}/graphs/share_distance_0km_lfit.png", replace
graph export "${OUTPUT}/graphs/share_distance_0km_lfit.pdf", replace





*** Graph with share of siblings born more than 5km apart:
mean sibling_distance_above_5km if age_gap_rounded<=15, over(age_gap_rounded)
est store different_5km_mean

coefplot different_5km_mean, ///
			rename(c.sibling_distance_above_5km@0.age_gap_rounded=0 ///
			c.sibling_distance_above_5km@1.age_gap_rounded=1 c.sibling_distance_above_5km@2.age_gap_rounded=2 ///
			c.sibling_distance_above_5km@3.age_gap_rounded=3 c.sibling_distance_above_5km@4.age_gap_rounded=4 ///
			c.sibling_distance_above_5km@5.age_gap_rounded=5 c.sibling_distance_above_5km@6.age_gap_rounded=6 ///
			c.sibling_distance_above_5km@7.age_gap_rounded=7 c.sibling_distance_above_5km@8.age_gap_rounded=8 ///
			c.sibling_distance_above_5km@9.age_gap_rounded=9 c.sibling_distance_above_5km@10.age_gap_rounded=10 ///
			c.sibling_distance_above_5km@11.age_gap_rounded=11 c.sibling_distance_above_5km@12.age_gap_rounded=12 ///
			c.sibling_distance_above_5km@13.age_gap_rounded=13 c.sibling_distance_above_5km@14.age_gap_rounded=14 ///
			c.sibling_distance_above_5km@15.age_gap_rounded=15 ) at(_coef) ///
			/// title("Share of siblings with birth location distance > 5km") ///
			ytitle("Share") ///
			ylabel(0 (0.2) 1) yscale(range(-0.05 1)) ///
			yline(0, lpattern(solid) lwidth(medthin) lcolor(gs10)) ///
			xtitle("Age gap, in years") ///
			vertical baselevels omitted  scheme(s1mono)	

graph export "${OUTPUT}/graphs/share_distance_5km.png", replace
graph export "${OUTPUT}/graphs/share_distance_5km.pdf", replace


// with fitted line:
reg sibling_distance_above_5km age_gap if age_gap_rounded<=15, hc3
margins, at(age_gap=(0(1)15)) post
est store different_5km
	
coefplot 	(different_5km, at recast(line) noci lcolor(gs10) lpattern(dash)) ///
			(different_5km_mean, ///
				rename(c.sibling_distance_above_5km@0.age_gap_rounded=0 ///
				c.sibling_distance_above_5km@1.age_gap_rounded=1 c.sibling_distance_above_5km@2.age_gap_rounded=2 ///
				c.sibling_distance_above_5km@3.age_gap_rounded=3 c.sibling_distance_above_5km@4.age_gap_rounded=4 ///
				c.sibling_distance_above_5km@5.age_gap_rounded=5 c.sibling_distance_above_5km@6.age_gap_rounded=6 ///
				c.sibling_distance_above_5km@7.age_gap_rounded=7 c.sibling_distance_above_5km@8.age_gap_rounded=8 ///
				c.sibling_distance_above_5km@9.age_gap_rounded=9 c.sibling_distance_above_5km@10.age_gap_rounded=10 ///
				c.sibling_distance_above_5km@11.age_gap_rounded=11 c.sibling_distance_above_5km@12.age_gap_rounded=12 ///
				c.sibling_distance_above_5km@13.age_gap_rounded=13 c.sibling_distance_above_5km@14.age_gap_rounded=14 ///
				c.sibling_distance_above_5km@15.age_gap_rounded=15 ) ///
				at(_coef) baselevels omitted mcolor(gs6) msymbol(O) ciopts(lcolor(gs6))), ///
			/// title("Share of siblings with birth location distance > 5km") ///
			ytitle("Share") ///
			ylabel(0 (0.2) 1) yscale(range(-0.05 1)) ///
			yline(0, lpattern(solid) lwidth(medthin) lcolor(gs10)) ///
			xtitle("Age gap, in years") ///
			vertical  scheme(s1mono) legend(off)

graph export "${OUTPUT}/graphs/share_distance_5km_lfit.png", replace
graph export "${OUTPUT}/graphs/share_distance_5km_lfit.pdf", replace





*** Graph with share of siblings born more than 10km apart:
mean sibling_distance_above_10km if age_gap_rounded<=15, over(age_gap_rounded)
est store different_10km_mean

coefplot different_10km_mean, ///
			rename(c.sibling_distance_above_10km@0.age_gap_rounded=0 ///
			c.sibling_distance_above_10km@1.age_gap_rounded=1 c.sibling_distance_above_10km@2.age_gap_rounded=2 ///
			c.sibling_distance_above_10km@3.age_gap_rounded=3 c.sibling_distance_above_10km@4.age_gap_rounded=4 ///
			c.sibling_distance_above_10km@5.age_gap_rounded=5 c.sibling_distance_above_10km@6.age_gap_rounded=6 ///
			c.sibling_distance_above_10km@7.age_gap_rounded=7 c.sibling_distance_above_10km@8.age_gap_rounded=8 ///
			c.sibling_distance_above_10km@9.age_gap_rounded=9 c.sibling_distance_above_10km@10.age_gap_rounded=10 ///
			c.sibling_distance_above_10km@11.age_gap_rounded=11 c.sibling_distance_above_10km@12.age_gap_rounded=12 ///
			c.sibling_distance_above_10km@13.age_gap_rounded=13 c.sibling_distance_above_10km@14.age_gap_rounded=14 ///
			c.sibling_distance_above_10km@15.age_gap_rounded=15 ) at(_coef) ///
			/// title("Share of siblings with birth location distance > 10km") ///
			ytitle("Share") ///
			ylabel(0 (0.2) 1) yscale(range(-0.05 1)) ///
			yline(0, lpattern(solid) lwidth(medthin) lcolor(gs10)) ///
			xtitle("Age gap, in years") ///
			vertical baselevels omitted  scheme(s1mono)	

graph export "${OUTPUT}/graphs/share_distance_10km.png", replace
graph export "${OUTPUT}/graphs/share_distance_10km.pdf", replace


// with fitted line:
reg sibling_distance_above_10km age_gap if age_gap_rounded<=15, hc3
margins, at(age_gap=(0(1)15)) post
est store different_10km
	
coefplot 	(different_10km, at recast(line) noci lcolor(gs10) lpattern(dash)) ///
			(different_10km_mean, ///
				rename(c.sibling_distance_above_10km@0.age_gap_rounded=0 ///
				c.sibling_distance_above_10km@1.age_gap_rounded=1 c.sibling_distance_above_10km@2.age_gap_rounded=2 ///
				c.sibling_distance_above_10km@3.age_gap_rounded=3 c.sibling_distance_above_10km@4.age_gap_rounded=4 ///
				c.sibling_distance_above_10km@5.age_gap_rounded=5 c.sibling_distance_above_10km@6.age_gap_rounded=6 ///
				c.sibling_distance_above_10km@7.age_gap_rounded=7 c.sibling_distance_above_10km@8.age_gap_rounded=8 ///
				c.sibling_distance_above_10km@9.age_gap_rounded=9 c.sibling_distance_above_10km@10.age_gap_rounded=10 ///
				c.sibling_distance_above_10km@11.age_gap_rounded=11 c.sibling_distance_above_10km@12.age_gap_rounded=12 ///
				c.sibling_distance_above_10km@13.age_gap_rounded=13 c.sibling_distance_above_10km@14.age_gap_rounded=14 ///
				c.sibling_distance_above_10km@15.age_gap_rounded=15 ) ///
				at(_coef) baselevels omitted mcolor(gs6) msymbol(O) ciopts(lcolor(gs6))), ///
			/// title("Share of siblings with birth location distance > 10km") ///
			ytitle("Share") ///
			ylabel(0 (0.2) 1) yscale(range(-0.05 1)) ///
			yline(0, lpattern(solid) lwidth(medthin) lcolor(gs10)) ///
			xtitle("Age gap, in years") ///
			vertical  scheme(s1mono) legend(off)

graph export "${OUTPUT}/graphs/share_distance_10km_lfit.png", replace
graph export "${OUTPUT}/graphs/share_distance_10km_lfit.pdf", replace





*** Graph with share of siblings born more than 20km apart:
mean sibling_distance_above_20km if age_gap_rounded<=15, over(age_gap_rounded)
est store different_20km_mean

coefplot different_20km_mean, ///
			rename(c.sibling_distance_above_20km@0.age_gap_rounded=0 ///
			c.sibling_distance_above_20km@1.age_gap_rounded=1 c.sibling_distance_above_20km@2.age_gap_rounded=2 ///
			c.sibling_distance_above_20km@3.age_gap_rounded=3 c.sibling_distance_above_20km@4.age_gap_rounded=4 ///
			c.sibling_distance_above_20km@5.age_gap_rounded=5 c.sibling_distance_above_20km@6.age_gap_rounded=6 ///
			c.sibling_distance_above_20km@7.age_gap_rounded=7 c.sibling_distance_above_20km@8.age_gap_rounded=8 ///
			c.sibling_distance_above_20km@9.age_gap_rounded=9 c.sibling_distance_above_20km@10.age_gap_rounded=10 ///
			c.sibling_distance_above_20km@11.age_gap_rounded=11 c.sibling_distance_above_20km@12.age_gap_rounded=12 ///
			c.sibling_distance_above_20km@13.age_gap_rounded=13 c.sibling_distance_above_20km@14.age_gap_rounded=14 ///
			c.sibling_distance_above_20km@15.age_gap_rounded=15 ) at(_coef) ///
			/// title("Share of siblings with birth location distance > 20km") ///
			ytitle("Share") ///
			ylabel(0 (0.2) 1) yscale(range(-0.05 1)) ///
			yline(0, lpattern(solid) lwidth(medthin) lcolor(gs10)) ///
			xtitle("Age gap, in years") ///
			vertical baselevels omitted  scheme(s1mono)	

graph export "${OUTPUT}/graphs/share_distance_20km.png", replace
graph export "${OUTPUT}/graphs/share_distance_20km.pdf", replace


// with fitted line:
reg sibling_distance_above_20km age_gap if age_gap_rounded<=15, hc3
margins, at(age_gap=(0(1)15)) post
est store different_20km
	
coefplot 	(different_20km, at recast(line) noci lcolor(gs10) lpattern(dash)) ///
			(different_20km_mean, ///
				rename(c.sibling_distance_above_20km@0.age_gap_rounded=0 ///
				c.sibling_distance_above_20km@1.age_gap_rounded=1 c.sibling_distance_above_20km@2.age_gap_rounded=2 ///
				c.sibling_distance_above_20km@3.age_gap_rounded=3 c.sibling_distance_above_20km@4.age_gap_rounded=4 ///
				c.sibling_distance_above_20km@5.age_gap_rounded=5 c.sibling_distance_above_20km@6.age_gap_rounded=6 ///
				c.sibling_distance_above_20km@7.age_gap_rounded=7 c.sibling_distance_above_20km@8.age_gap_rounded=8 ///
				c.sibling_distance_above_20km@9.age_gap_rounded=9 c.sibling_distance_above_20km@10.age_gap_rounded=10 ///
				c.sibling_distance_above_20km@11.age_gap_rounded=11 c.sibling_distance_above_20km@12.age_gap_rounded=12 ///
				c.sibling_distance_above_20km@13.age_gap_rounded=13 c.sibling_distance_above_20km@14.age_gap_rounded=14 ///
				c.sibling_distance_above_20km@15.age_gap_rounded=15 ) ///
				at(_coef) baselevels omitted mcolor(gs6) msymbol(O) ciopts(lcolor(gs6))), ///
			/// title("Share of siblings with birth location distance > 20km") ///
			ytitle("Share") ///
			ylabel(0 (0.2) 1) yscale(range(-0.05 1)) ///
			yline(0, lpattern(solid) lwidth(medthin) lcolor(gs10)) ///
			xtitle("Age gap, in years") ///
			vertical  scheme(s1mono) legend(off)

graph export "${OUTPUT}/graphs/share_distance_20km_lfit.png", replace
graph export "${OUTPUT}/graphs/share_distance_20km_lfit.pdf", replace





*** Graph with share of siblings born more than 30km apart:
mean sibling_distance_above_30km if age_gap_rounded<=15, over(age_gap_rounded)
est store different_30km_mean

coefplot different_30km_mean, ///
			rename(c.sibling_distance_above_30km@0.age_gap_rounded=0 ///
			c.sibling_distance_above_30km@1.age_gap_rounded=1 c.sibling_distance_above_30km@2.age_gap_rounded=2 ///
			c.sibling_distance_above_30km@3.age_gap_rounded=3 c.sibling_distance_above_30km@4.age_gap_rounded=4 ///
			c.sibling_distance_above_30km@5.age_gap_rounded=5 c.sibling_distance_above_30km@6.age_gap_rounded=6 ///
			c.sibling_distance_above_30km@7.age_gap_rounded=7 c.sibling_distance_above_30km@8.age_gap_rounded=8 ///
			c.sibling_distance_above_30km@9.age_gap_rounded=9 c.sibling_distance_above_30km@10.age_gap_rounded=10 ///
			c.sibling_distance_above_30km@11.age_gap_rounded=11 c.sibling_distance_above_30km@12.age_gap_rounded=12 ///
			c.sibling_distance_above_30km@13.age_gap_rounded=13 c.sibling_distance_above_30km@14.age_gap_rounded=14 ///
			c.sibling_distance_above_30km@15.age_gap_rounded=15 ) at(_coef) ///
			/// title("Share of siblings with birth location distance > 30km") ///
			ytitle("Share") ///
			ylabel(0 (0.2) 1) yscale(range(-0.05 1)) ///
			yline(0, lpattern(solid) lwidth(medthin) lcolor(gs10)) ///
			xtitle("Age gap, in years") ///
			vertical baselevels omitted  scheme(s1mono)	

graph export "${OUTPUT}/graphs/share_distance_30km.png", replace
graph export "${OUTPUT}/graphs/share_distance_30km.pdf", replace


// with fitted line:
reg sibling_distance_above_30km age_gap if age_gap_rounded<=15, hc3
margins, at(age_gap=(0(1)15)) post
est store different_30km
	
coefplot 	(different_30km, at recast(line) noci lcolor(gs10) lpattern(dash)) ///
			(different_30km_mean, ///
				rename(c.sibling_distance_above_30km@0.age_gap_rounded=0 ///
				c.sibling_distance_above_30km@1.age_gap_rounded=1 c.sibling_distance_above_30km@2.age_gap_rounded=2 ///
				c.sibling_distance_above_30km@3.age_gap_rounded=3 c.sibling_distance_above_30km@4.age_gap_rounded=4 ///
				c.sibling_distance_above_30km@5.age_gap_rounded=5 c.sibling_distance_above_30km@6.age_gap_rounded=6 ///
				c.sibling_distance_above_30km@7.age_gap_rounded=7 c.sibling_distance_above_30km@8.age_gap_rounded=8 ///
				c.sibling_distance_above_30km@9.age_gap_rounded=9 c.sibling_distance_above_30km@10.age_gap_rounded=10 ///
				c.sibling_distance_above_30km@11.age_gap_rounded=11 c.sibling_distance_above_30km@12.age_gap_rounded=12 ///
				c.sibling_distance_above_30km@13.age_gap_rounded=13 c.sibling_distance_above_30km@14.age_gap_rounded=14 ///
				c.sibling_distance_above_30km@15.age_gap_rounded=15 ) ///
				at(_coef) baselevels omitted mcolor(gs6) msymbol(O) ciopts(lcolor(gs6))), ///
			/// title("Share of siblings with birth location distance > 30km") ///
			ytitle("Share") ///
			ylabel(0 (0.2) 1) yscale(range(-0.05 1)) ///
			yline(0, lpattern(solid) lwidth(medthin) lcolor(gs10)) ///
			xtitle("Age gap, in years") ///
			vertical  scheme(s1mono) legend(off)

graph export "${OUTPUT}/graphs/share_distance_30km_lfit.png", replace
graph export "${OUTPUT}/graphs/share_distance_30km_lfit.pdf", replace





*** Graph with share of siblings born more than 40km apart:
mean sibling_distance_above_40km if age_gap_rounded<=15, over(age_gap_rounded)
est store different_40km_mean

coefplot different_40km_mean, ///
			rename(c.sibling_distance_above_40km@0.age_gap_rounded=0 ///
			c.sibling_distance_above_40km@1.age_gap_rounded=1 c.sibling_distance_above_40km@2.age_gap_rounded=2 ///
			c.sibling_distance_above_40km@3.age_gap_rounded=3 c.sibling_distance_above_40km@4.age_gap_rounded=4 ///
			c.sibling_distance_above_40km@5.age_gap_rounded=5 c.sibling_distance_above_40km@6.age_gap_rounded=6 ///
			c.sibling_distance_above_40km@7.age_gap_rounded=7 c.sibling_distance_above_40km@8.age_gap_rounded=8 ///
			c.sibling_distance_above_40km@9.age_gap_rounded=9 c.sibling_distance_above_40km@10.age_gap_rounded=10 ///
			c.sibling_distance_above_40km@11.age_gap_rounded=11 c.sibling_distance_above_40km@12.age_gap_rounded=12 ///
			c.sibling_distance_above_40km@13.age_gap_rounded=13 c.sibling_distance_above_40km@14.age_gap_rounded=14 ///
			c.sibling_distance_above_40km@15.age_gap_rounded=15 ) at(_coef) ///
			/// title("Share of siblings with birth location distance > 40km") ///
			ytitle("Share") ///
			ylabel(0 (0.2) 1) yscale(range(-0.05 1)) ///
			yline(0, lpattern(solid) lwidth(medthin) lcolor(gs10)) ///
			xtitle("Age gap, in years") ///
			vertical baselevels omitted  scheme(s1mono)	

graph export "${OUTPUT}/graphs/share_distance_40km.png", replace
graph export "${OUTPUT}/graphs/share_distance_40km.pdf", replace


// with fitted line:
reg sibling_distance_above_40km age_gap if age_gap_rounded<=15, hc3
margins, at(age_gap=(0(1)15)) post
est store different_40km
	
coefplot 	(different_40km, at recast(line) noci lcolor(gs10) lpattern(dash)) ///
			(different_40km_mean, ///
				rename(c.sibling_distance_above_40km@0.age_gap_rounded=0 ///
				c.sibling_distance_above_40km@1.age_gap_rounded=1 c.sibling_distance_above_40km@2.age_gap_rounded=2 ///
				c.sibling_distance_above_40km@3.age_gap_rounded=3 c.sibling_distance_above_40km@4.age_gap_rounded=4 ///
				c.sibling_distance_above_40km@5.age_gap_rounded=5 c.sibling_distance_above_40km@6.age_gap_rounded=6 ///
				c.sibling_distance_above_40km@7.age_gap_rounded=7 c.sibling_distance_above_40km@8.age_gap_rounded=8 ///
				c.sibling_distance_above_40km@9.age_gap_rounded=9 c.sibling_distance_above_40km@10.age_gap_rounded=10 ///
				c.sibling_distance_above_40km@11.age_gap_rounded=11 c.sibling_distance_above_40km@12.age_gap_rounded=12 ///
				c.sibling_distance_above_40km@13.age_gap_rounded=13 c.sibling_distance_above_40km@14.age_gap_rounded=14 ///
				c.sibling_distance_above_40km@15.age_gap_rounded=15 ) ///
				at(_coef) baselevels omitted mcolor(gs6) msymbol(O) ciopts(lcolor(gs6))), ///
			/// title("Share of siblings with birth location distance > 40km") ///
			ytitle("Share") ///
			ylabel(0 (0.2) 1) yscale(range(-0.05 1)) ///
			yline(0, lpattern(solid) lwidth(medthin) lcolor(gs10)) ///
			xtitle("Age gap, in years") ///
			vertical  scheme(s1mono) legend(off)

graph export "${OUTPUT}/graphs/share_distance_40km_lfit.png", replace
graph export "${OUTPUT}/graphs/share_distance_40km_lfit.pdf", replace





*** Graph with share of siblings born more than 50km apart:
mean sibling_distance_above_50km if age_gap_rounded<=15, over(age_gap_rounded)
est store different_50km_mean

coefplot different_50km_mean, ///
			rename(c.sibling_distance_above_50km@0.age_gap_rounded=0 ///
			c.sibling_distance_above_50km@1.age_gap_rounded=1 c.sibling_distance_above_50km@2.age_gap_rounded=2 ///
			c.sibling_distance_above_50km@3.age_gap_rounded=3 c.sibling_distance_above_50km@4.age_gap_rounded=4 ///
			c.sibling_distance_above_50km@5.age_gap_rounded=5 c.sibling_distance_above_50km@6.age_gap_rounded=6 ///
			c.sibling_distance_above_50km@7.age_gap_rounded=7 c.sibling_distance_above_50km@8.age_gap_rounded=8 ///
			c.sibling_distance_above_50km@9.age_gap_rounded=9 c.sibling_distance_above_50km@10.age_gap_rounded=10 ///
			c.sibling_distance_above_50km@11.age_gap_rounded=11 c.sibling_distance_above_50km@12.age_gap_rounded=12 ///
			c.sibling_distance_above_50km@13.age_gap_rounded=13 c.sibling_distance_above_50km@14.age_gap_rounded=14 ///
			c.sibling_distance_above_50km@15.age_gap_rounded=15 ) at(_coef) ///
			/// title("Share of siblings with birth location distance > 50km") ///
			ytitle("Share") ///
			ylabel(0 (0.2) 1) yscale(range(-0.05 1)) ///
			yline(0, lpattern(solid) lwidth(medthin) lcolor(gs10)) ///
			xtitle("Age gap, in years") ///
			vertical baselevels omitted  scheme(s1mono)	

graph export "${OUTPUT}/graphs/share_distance_50km.png", replace
graph export "${OUTPUT}/graphs/share_distance_50km.pdf", replace


// with fitted line:
reg sibling_distance_above_50km age_gap if age_gap_rounded<=15, hc3
margins, at(age_gap=(0(1)15)) post
est store different_50km
	
coefplot 	(different_50km, at recast(line) noci lcolor(gs10) lpattern(dash)) ///
			(different_50km_mean, ///
				rename(c.sibling_distance_above_50km@0.age_gap_rounded=0 ///
				c.sibling_distance_above_50km@1.age_gap_rounded=1 c.sibling_distance_above_50km@2.age_gap_rounded=2 ///
				c.sibling_distance_above_50km@3.age_gap_rounded=3 c.sibling_distance_above_50km@4.age_gap_rounded=4 ///
				c.sibling_distance_above_50km@5.age_gap_rounded=5 c.sibling_distance_above_50km@6.age_gap_rounded=6 ///
				c.sibling_distance_above_50km@7.age_gap_rounded=7 c.sibling_distance_above_50km@8.age_gap_rounded=8 ///
				c.sibling_distance_above_50km@9.age_gap_rounded=9 c.sibling_distance_above_50km@10.age_gap_rounded=10 ///
				c.sibling_distance_above_50km@11.age_gap_rounded=11 c.sibling_distance_above_50km@12.age_gap_rounded=12 ///
				c.sibling_distance_above_50km@13.age_gap_rounded=13 c.sibling_distance_above_50km@14.age_gap_rounded=14 ///
				c.sibling_distance_above_50km@15.age_gap_rounded=15 ) ///
				at(_coef) baselevels omitted mcolor(gs6) msymbol(O) ciopts(lcolor(gs6))), ///
			/// title("Share of siblings with birth location distance > 50km") ///
			ytitle("Share") ///
			ylabel(0 (0.2) 1) yscale(range(-0.05 1)) ///
			yline(0, lpattern(solid) lwidth(medthin) lcolor(gs10)) ///
			xtitle("Age gap, in years") ///
			vertical  scheme(s1mono) legend(off)

graph export "${OUTPUT}/graphs/share_distance_50km_lfit.png", replace
graph export "${OUTPUT}/graphs/share_distance_50km_lfit.pdf", replace











*** Combined graph:

// Different birth parish:
coefplot 	(different_parish, at recast(line) noci lcolor(gs10) lpattern(dash)) ///
			(different_parish_mean, ///
				rename(c.parish_different@0.age_gap_rounded=0 ///
				c.parish_different@1.age_gap_rounded=1 c.parish_different@2.age_gap_rounded=2 ///
				c.parish_different@3.age_gap_rounded=3 c.parish_different@4.age_gap_rounded=4 ///
				c.parish_different@5.age_gap_rounded=5 c.parish_different@6.age_gap_rounded=6 ///
				c.parish_different@7.age_gap_rounded=7 c.parish_different@8.age_gap_rounded=8 ///
				c.parish_different@9.age_gap_rounded=9 c.parish_different@10.age_gap_rounded=10 ///
				c.parish_different@11.age_gap_rounded=11 c.parish_different@12.age_gap_rounded=12 ///
				c.parish_different@13.age_gap_rounded=13 c.parish_different@14.age_gap_rounded=14 ///
				c.parish_different@15.age_gap_rounded=15 ) ///
				at(_coef) baselevels omitted mcolor(gs6) msymbol(O) ciopts(lcolor(gs6))), ///
			title("Different birth parish", size(vlarge)) ///
			text(1.1 -2 "{bf:a}", size(vhuge)) ///
			graphregion(margin(10 5 5 5)) ///
			ytitle("Share") ///
			ylabel(0 (0.2) 1) yscale(range(-0.05 1)) ///
			yline(0, lpattern(solid) lwidth(medthin) lcolor(gs10)) ///
			xtitle("Age gap, in years") ///
			vertical  scheme(s1mono) legend(off) name(share_diff_parish_lfit, replace)
			
			
			
// Different birth district:
coefplot 	(different_district, at recast(line) noci lcolor(gs10) lpattern(dash)) ///
			(different_district_mean, ///
				rename(c.district_different@0.age_gap_rounded=0 ///
				c.district_different@1.age_gap_rounded=1 c.district_different@2.age_gap_rounded=2 ///
				c.district_different@3.age_gap_rounded=3 c.district_different@4.age_gap_rounded=4 ///
				c.district_different@5.age_gap_rounded=5 c.district_different@6.age_gap_rounded=6 ///
				c.district_different@7.age_gap_rounded=7 c.district_different@8.age_gap_rounded=8 ///
				c.district_different@9.age_gap_rounded=9 c.district_different@10.age_gap_rounded=10 ///
				c.district_different@11.age_gap_rounded=11 c.district_different@12.age_gap_rounded=12 ///
				c.district_different@13.age_gap_rounded=13 c.district_different@14.age_gap_rounded=14 ///
				c.district_different@15.age_gap_rounded=15 ) ///
				at(_coef) baselevels omitted mcolor(gs6) msymbol(O) ciopts(lcolor(gs6))), ///
			title("Different birth district", size(vlarge)) ///
			text(1.1 -2 "{bf:b}", size(vhuge)) ///
			graphregion(margin(10 5 5 5)) ///
			ytitle("Share") ///
			ylabel(0 (0.2) 1) yscale(range(-0.05 1)) ///
			yline(0, lpattern(solid) lwidth(medthin) lcolor(gs10)) ///
			xtitle("Age gap, in years") ///
			vertical  scheme(s1mono) legend(off) name(share_diff_district_lfit, replace)
			
			

// Different birth county:
coefplot 	(different_county, at recast(line) noci lcolor(gs10) lpattern(dash)) ///
			(different_county_mean, ///
				rename(c.county_different@0.age_gap_rounded=0 ///
				c.county_different@1.age_gap_rounded=1 c.county_different@2.age_gap_rounded=2 ///
				c.county_different@3.age_gap_rounded=3 c.county_different@4.age_gap_rounded=4 ///
				c.county_different@5.age_gap_rounded=5 c.county_different@6.age_gap_rounded=6 ///
				c.county_different@7.age_gap_rounded=7 c.county_different@8.age_gap_rounded=8 ///
				c.county_different@9.age_gap_rounded=9 c.county_different@10.age_gap_rounded=10 ///
				c.county_different@11.age_gap_rounded=11 c.county_different@12.age_gap_rounded=12 ///
				c.county_different@13.age_gap_rounded=13 c.county_different@14.age_gap_rounded=14 ///
				c.county_different@15.age_gap_rounded=15 ) ///
				at(_coef) baselevels omitted mcolor(gs6) msymbol(O) ciopts(lcolor(gs6))), ///
			title("Different birth county", size(vlarge)) ///
			text(1.1 -2 "{bf:c}", size(vhuge)) ///
			graphregion(margin(10 5 5 5)) ///
			ytitle("Share") ///
			ylabel(0 (0.2) 1) yscale(range(-0.05 1)) ///
			yline(0, lpattern(solid) lwidth(medthin) lcolor(gs10)) ///
			xtitle("Age gap, in years") ///
			vertical  scheme(s1mono) legend(off) name(share_diff_county_lfit, replace)
			
			

// Distance > 0km:			
coefplot 	(different_0km, at recast(line) noci lcolor(gs10) lpattern(dash)) ///
			(different_0km_mean, ///
				rename(c.sibling_distance_above_0km@0.age_gap_rounded=0 ///
				c.sibling_distance_above_0km@1.age_gap_rounded=1 c.sibling_distance_above_0km@2.age_gap_rounded=2 ///
				c.sibling_distance_above_0km@3.age_gap_rounded=3 c.sibling_distance_above_0km@4.age_gap_rounded=4 ///
				c.sibling_distance_above_0km@5.age_gap_rounded=5 c.sibling_distance_above_0km@6.age_gap_rounded=6 ///
				c.sibling_distance_above_0km@7.age_gap_rounded=7 c.sibling_distance_above_0km@8.age_gap_rounded=8 ///
				c.sibling_distance_above_0km@9.age_gap_rounded=9 c.sibling_distance_above_0km@10.age_gap_rounded=10 ///
				c.sibling_distance_above_0km@11.age_gap_rounded=11 c.sibling_distance_above_0km@12.age_gap_rounded=12 ///
				c.sibling_distance_above_0km@13.age_gap_rounded=13 c.sibling_distance_above_0km@14.age_gap_rounded=14 ///
				c.sibling_distance_above_0km@15.age_gap_rounded=15 ) ///
				at(_coef) baselevels omitted mcolor(gs6) msymbol(O) ciopts(lcolor(gs6))), ///
			title("Distance > 0km", size(vlarge)) ///
			text(1.1 -2 "{bf:d}", size(vhuge)) ///
			graphregion(margin(10 5 5 5)) ///
			ytitle("Share") ///
			ylabel(0 (0.2) 1) yscale(range(-0.05 1)) ///
			yline(0, lpattern(solid) lwidth(medthin) lcolor(gs10)) ///
			xtitle("Age gap, in years") ///
			vertical  scheme(s1mono) legend(off) name(share_distance_0km_lfit, replace)
			

// Distance > 5km:	
coefplot 	(different_5km, at recast(line) noci lcolor(gs10) lpattern(dash)) ///
			(different_5km_mean, ///
				rename(c.sibling_distance_above_5km@0.age_gap_rounded=0 ///
				c.sibling_distance_above_5km@1.age_gap_rounded=1 c.sibling_distance_above_5km@2.age_gap_rounded=2 ///
				c.sibling_distance_above_5km@3.age_gap_rounded=3 c.sibling_distance_above_5km@4.age_gap_rounded=4 ///
				c.sibling_distance_above_5km@5.age_gap_rounded=5 c.sibling_distance_above_5km@6.age_gap_rounded=6 ///
				c.sibling_distance_above_5km@7.age_gap_rounded=7 c.sibling_distance_above_5km@8.age_gap_rounded=8 ///
				c.sibling_distance_above_5km@9.age_gap_rounded=9 c.sibling_distance_above_5km@10.age_gap_rounded=10 ///
				c.sibling_distance_above_5km@11.age_gap_rounded=11 c.sibling_distance_above_5km@12.age_gap_rounded=12 ///
				c.sibling_distance_above_5km@13.age_gap_rounded=13 c.sibling_distance_above_5km@14.age_gap_rounded=14 ///
				c.sibling_distance_above_5km@15.age_gap_rounded=15 ) ///
				at(_coef) baselevels omitted mcolor(gs6) msymbol(O) ciopts(lcolor(gs6))), ///
			title("Distance > 5km", size(vlarge)) ///
			text(1.1 -2 "{bf:e}", size(vhuge)) ///
			graphregion(margin(10 5 5 5)) ///
			ytitle("Share") ///
			ylabel(0 (0.2) 1) yscale(range(-0.05 1)) ///
			yline(0, lpattern(solid) lwidth(medthin) lcolor(gs10)) ///
			xtitle("Age gap, in years") ///
			vertical  scheme(s1mono) legend(off) name(share_distance_5km_lfit, replace)
			

// Distance > 10km:	
coefplot 	(different_10km, at recast(line) noci lcolor(gs10) lpattern(dash)) ///
			(different_10km_mean, ///
				rename(c.sibling_distance_above_10km@0.age_gap_rounded=0 ///
				c.sibling_distance_above_10km@1.age_gap_rounded=1 c.sibling_distance_above_10km@2.age_gap_rounded=2 ///
				c.sibling_distance_above_10km@3.age_gap_rounded=3 c.sibling_distance_above_10km@4.age_gap_rounded=4 ///
				c.sibling_distance_above_10km@5.age_gap_rounded=5 c.sibling_distance_above_10km@6.age_gap_rounded=6 ///
				c.sibling_distance_above_10km@7.age_gap_rounded=7 c.sibling_distance_above_10km@8.age_gap_rounded=8 ///
				c.sibling_distance_above_10km@9.age_gap_rounded=9 c.sibling_distance_above_10km@10.age_gap_rounded=10 ///
				c.sibling_distance_above_10km@11.age_gap_rounded=11 c.sibling_distance_above_10km@12.age_gap_rounded=12 ///
				c.sibling_distance_above_10km@13.age_gap_rounded=13 c.sibling_distance_above_10km@14.age_gap_rounded=14 ///
				c.sibling_distance_above_10km@15.age_gap_rounded=15 ) ///
				at(_coef) baselevels omitted mcolor(gs6) msymbol(O) ciopts(lcolor(gs6))), ///
			title("Distance > 10km", size(vlarge)) ///
			text(1.1 -2 "{bf:f}", size(vhuge)) ///
			graphregion(margin(10 5 5 5)) ///
			ytitle("Share") ///
			ylabel(0 (0.2) 1) yscale(range(-0.05 1)) ///
			yline(0, lpattern(solid) lwidth(medthin) lcolor(gs10)) ///
			xtitle("Age gap, in years") ///
			vertical  scheme(s1mono) legend(off) name(share_distance_10km_lfit, replace)
			

// Distance > 20km:	
coefplot 	(different_20km, at recast(line) noci lcolor(gs10) lpattern(dash)) ///
			(different_20km_mean, ///
				rename(c.sibling_distance_above_20km@0.age_gap_rounded=0 ///
				c.sibling_distance_above_20km@1.age_gap_rounded=1 c.sibling_distance_above_20km@2.age_gap_rounded=2 ///
				c.sibling_distance_above_20km@3.age_gap_rounded=3 c.sibling_distance_above_20km@4.age_gap_rounded=4 ///
				c.sibling_distance_above_20km@5.age_gap_rounded=5 c.sibling_distance_above_20km@6.age_gap_rounded=6 ///
				c.sibling_distance_above_20km@7.age_gap_rounded=7 c.sibling_distance_above_20km@8.age_gap_rounded=8 ///
				c.sibling_distance_above_20km@9.age_gap_rounded=9 c.sibling_distance_above_20km@10.age_gap_rounded=10 ///
				c.sibling_distance_above_20km@11.age_gap_rounded=11 c.sibling_distance_above_20km@12.age_gap_rounded=12 ///
				c.sibling_distance_above_20km@13.age_gap_rounded=13 c.sibling_distance_above_20km@14.age_gap_rounded=14 ///
				c.sibling_distance_above_20km@15.age_gap_rounded=15 ) ///
				at(_coef) baselevels omitted mcolor(gs6) msymbol(O) ciopts(lcolor(gs6))), ///
			title("Distance > 20km", size(vlarge)) ///
			text(1.1 -2 "{bf:g}", size(vhuge)) ///
			graphregion(margin(10 5 5 5)) ///
			ytitle("Share") ///
			ylabel(0 (0.2) 1) yscale(range(-0.05 1)) ///
			yline(0, lpattern(solid) lwidth(medthin) lcolor(gs10)) ///
			xtitle("Age gap, in years") ///
			vertical  scheme(s1mono) legend(off) name(share_distance_20km_lfit, replace)
			

// Distance > 30km:	
coefplot 	(different_30km, at recast(line) noci lcolor(gs10) lpattern(dash)) ///
			(different_30km_mean, ///
				rename(c.sibling_distance_above_30km@0.age_gap_rounded=0 ///
				c.sibling_distance_above_30km@1.age_gap_rounded=1 c.sibling_distance_above_30km@2.age_gap_rounded=2 ///
				c.sibling_distance_above_30km@3.age_gap_rounded=3 c.sibling_distance_above_30km@4.age_gap_rounded=4 ///
				c.sibling_distance_above_30km@5.age_gap_rounded=5 c.sibling_distance_above_30km@6.age_gap_rounded=6 ///
				c.sibling_distance_above_30km@7.age_gap_rounded=7 c.sibling_distance_above_30km@8.age_gap_rounded=8 ///
				c.sibling_distance_above_30km@9.age_gap_rounded=9 c.sibling_distance_above_30km@10.age_gap_rounded=10 ///
				c.sibling_distance_above_30km@11.age_gap_rounded=11 c.sibling_distance_above_30km@12.age_gap_rounded=12 ///
				c.sibling_distance_above_30km@13.age_gap_rounded=13 c.sibling_distance_above_30km@14.age_gap_rounded=14 ///
				c.sibling_distance_above_30km@15.age_gap_rounded=15 ) ///
				at(_coef) baselevels omitted mcolor(gs6) msymbol(O) ciopts(lcolor(gs6))), ///
			title("Distance > 50km", size(vlarge)) ///
			text(1.1 -2 "{bf:h}", size(vhuge)) ///
			graphregion(margin(10 5 5 5)) ///
			ytitle("Share") ///
			ylabel(0 (0.2) 1) yscale(range(-0.05 1)) ///
			yline(0, lpattern(solid) lwidth(medthin) lcolor(gs10)) ///
			xtitle("Age gap, in years") ///
			vertical  scheme(s1mono) legend(off) name(share_distance_30km_lfit, replace)
			

// Distance > 50km:	
coefplot 	(different_50km, at recast(line) noci lcolor(gs10) lpattern(dash)) ///
			(different_50km_mean, ///
				rename(c.sibling_distance_above_50km@0.age_gap_rounded=0 ///
				c.sibling_distance_above_50km@1.age_gap_rounded=1 c.sibling_distance_above_50km@2.age_gap_rounded=2 ///
				c.sibling_distance_above_50km@3.age_gap_rounded=3 c.sibling_distance_above_50km@4.age_gap_rounded=4 ///
				c.sibling_distance_above_50km@5.age_gap_rounded=5 c.sibling_distance_above_50km@6.age_gap_rounded=6 ///
				c.sibling_distance_above_50km@7.age_gap_rounded=7 c.sibling_distance_above_50km@8.age_gap_rounded=8 ///
				c.sibling_distance_above_50km@9.age_gap_rounded=9 c.sibling_distance_above_50km@10.age_gap_rounded=10 ///
				c.sibling_distance_above_50km@11.age_gap_rounded=11 c.sibling_distance_above_50km@12.age_gap_rounded=12 ///
				c.sibling_distance_above_50km@13.age_gap_rounded=13 c.sibling_distance_above_50km@14.age_gap_rounded=14 ///
				c.sibling_distance_above_50km@15.age_gap_rounded=15 ) ///
				at(_coef) baselevels omitted mcolor(gs6) msymbol(O) ciopts(lcolor(gs6))), ///
			title("Distance > 50km", size(vlarge)) ///
			text(1.1 -2 "{bf:i}", size(vhuge)) ///
			graphregion(margin(10 5 5 5)) ///
			ytitle("Share") ///
			ylabel(0 (0.2) 1) yscale(range(-0.05 1)) ///
			yline(0, lpattern(solid) lwidth(medthin) lcolor(gs10)) ///
			xtitle("Age gap, in years") ///
			vertical  scheme(s1mono) legend(off) name(share_distance_50km_lfit, replace)
			
// Combine:			
graph combine share_diff_parish_lfit share_diff_district_lfit share_diff_county_lfit share_distance_0km_lfit share_distance_5km_lfit share_distance_10km_lfit share_distance_20km_lfit share_distance_30km_lfit share_distance_50km_lfit, scheme(s1mono) altshrink ysize(15cm) xsize(18cm)

graph export "${OUTPUT}/graphs/share_different_birth_locations_combined.png", replace
graph export "${OUTPUT}/graphs/share_different_birth_locations_combined.pdf", replace







*** Source data for combined graph:
cap erase "${OUTPUT}/graphs/share_different_birth_locations_combined_source_data.csv"
tokenize `c(alpha)'
local i=1

foreach x in parish district county {
	
	esttab different_`x'_mean different_`x' using "${OUTPUT}/graphs/share_different_birth_locations_combined_source_data.csv", append ///
		cells((b(fmt(5) pattern(1 0)) ci_l(fmt(5) pattern(1 0)) ci_u(fmt(5) pattern(1 0)) b(fmt(5) pattern(0 1)) )) ///
		title("Figure 1``i'': Different birth `x'") note(" ") ///
		mlabel(none) nonumbers noobs ///
		collabel("Share" "95% CI lower bound"  "95% CI upper bound" "Linear fit", lhs("Age gap")) ///
		coeflabel(c.`x'_different@0.age_gap_rounded  "0" ///
		c.`x'_different@1.age_gap_rounded  "1" ///
		c.`x'_different@2.age_gap_rounded  "2" ///
		c.`x'_different@3.age_gap_rounded  "3" ///
		c.`x'_different@4.age_gap_rounded  "4" ///
		c.`x'_different@5.age_gap_rounded  "5" ///
		c.`x'_different@6.age_gap_rounded  "6" ///
		c.`x'_different@7.age_gap_rounded  "7" ///
		c.`x'_different@8.age_gap_rounded  "8" ///
		c.`x'_different@9.age_gap_rounded  "9" ///
		c.`x'_different@10.age_gap_rounded  "10" ///
		c.`x'_different@11.age_gap_rounded  "11" ///
		c.`x'_different@12.age_gap_rounded  "12" ///
		c.`x'_different@13.age_gap_rounded  "13" ///
		c.`x'_different@14.age_gap_rounded  "14" ///
		c.`x'_different@15.age_gap_rounded  "15") ///
		rename(1._at c.`x'_different@0.age_gap_rounded ///
		2._at c.`x'_different@1.age_gap_rounded ///
		3._at c.`x'_different@2.age_gap_rounded ///
		4._at c.`x'_different@3.age_gap_rounded ///
		5._at c.`x'_different@4.age_gap_rounded ///
		6._at c.`x'_different@5.age_gap_rounded ///
		7._at c.`x'_different@6.age_gap_rounded ///
		8._at c.`x'_different@7.age_gap_rounded ///
		9._at c.`x'_different@8.age_gap_rounded ///
		10._at c.`x'_different@9.age_gap_rounded ///
		11._at c.`x'_different@10.age_gap_rounded ///
		12._at c.`x'_different@11.age_gap_rounded ///
		13._at c.`x'_different@12.age_gap_rounded ///
		14._at c.`x'_different@13.age_gap_rounded ///
		15._at c.`x'_different@14.age_gap_rounded ///
		16._at c.`x'_different@15.age_gap_rounded)
		
		local i=`i'+1
	
}


foreach x in 0km 5km 10km 20km 30km 50km {
		
	esttab different_`x'_mean different_`x' using "${OUTPUT}/graphs/share_different_birth_locations_combined_source_data.csv", append ///
		cells((b(fmt(5) pattern(1 0)) ci_l(fmt(5) pattern(1 0)) ci_u(fmt(5) pattern(1 0)) b(fmt(5) pattern(0 1)) )) ///
		title("Figure 1``i'': Distance > `x'") note(" ") ///
		mlabel(none) nonumbers noobs ///
		collabel("Share" "95% CI lower bound"  "95% CI upper bound" "Linear fit", lhs("Age gap")) ///
		coeflabel(c.sibling_distance_above_`x'@0.age_gap_rounded  "0" ///
		c.sibling_distance_above_`x'@1.age_gap_rounded  "1" ///
		c.sibling_distance_above_`x'@2.age_gap_rounded  "2" ///
		c.sibling_distance_above_`x'@3.age_gap_rounded  "3" ///
		c.sibling_distance_above_`x'@4.age_gap_rounded  "4" ///
		c.sibling_distance_above_`x'@5.age_gap_rounded  "5" ///
		c.sibling_distance_above_`x'@6.age_gap_rounded  "6" ///
		c.sibling_distance_above_`x'@7.age_gap_rounded  "7" ///
		c.sibling_distance_above_`x'@8.age_gap_rounded  "8" ///
		c.sibling_distance_above_`x'@9.age_gap_rounded  "9" ///
		c.sibling_distance_above_`x'@10.age_gap_rounded  "10" ///
		c.sibling_distance_above_`x'@11.age_gap_rounded  "11" ///
		c.sibling_distance_above_`x'@12.age_gap_rounded  "12" ///
		c.sibling_distance_above_`x'@13.age_gap_rounded  "13" ///
		c.sibling_distance_above_`x'@14.age_gap_rounded  "14" ///
		c.sibling_distance_above_`x'@15.age_gap_rounded  "15") ///
		rename(1._at c.sibling_distance_above_`x'@0.age_gap_rounded ///
		2._at c.sibling_distance_above_`x'@1.age_gap_rounded ///
		3._at c.sibling_distance_above_`x'@2.age_gap_rounded ///
		4._at c.sibling_distance_above_`x'@3.age_gap_rounded ///
		5._at c.sibling_distance_above_`x'@4.age_gap_rounded ///
		6._at c.sibling_distance_above_`x'@5.age_gap_rounded ///
		7._at c.sibling_distance_above_`x'@6.age_gap_rounded ///
		8._at c.sibling_distance_above_`x'@7.age_gap_rounded ///
		9._at c.sibling_distance_above_`x'@8.age_gap_rounded ///
		10._at c.sibling_distance_above_`x'@9.age_gap_rounded ///
		11._at c.sibling_distance_above_`x'@10.age_gap_rounded ///
		12._at c.sibling_distance_above_`x'@11.age_gap_rounded ///
		13._at c.sibling_distance_above_`x'@12.age_gap_rounded ///
		14._at c.sibling_distance_above_`x'@13.age_gap_rounded ///
		15._at c.sibling_distance_above_`x'@14.age_gap_rounded ///
		16._at c.sibling_distance_above_`x'@15.age_gap_rounded)
		
		local i=`i'+1
	
}