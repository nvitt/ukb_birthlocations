***************************************************************************

clear
est clear
set matsize 11000



******User
global DRIVE 	"//rdsfcifs.acrc.bris.ac.uk/GeneEnvironment_Interactions/UKB/"
global OUTPUT	"C:/Users/pk20062/Dropbox/DONNI - UKB birth location accuracy/output/"





*** Load birth location data:
use "${DRIVE}GeographicID/Projects/NV_Papers/Birth locations/dta/repeat_birth_location_data.dta", clear



	
*******************
*** Regressions ***
*******************

* Different parishes:
reg parish_different, hc3
est store different_parish

nlcom (p: 1-sqrt(1-_b[_cons])), post
est store different_parish_pars


* Different districts:
reg district_different, hc3
est store different_district

nlcom (p: 1-sqrt(1-_b[_cons])), post
est store different_district_pars


* Different counties:
reg county_different, hc3
est store different_county

nlcom (p: 1-sqrt(1-_b[_cons])), post
est store different_county_pars

	
* Different birth coordinates:
reg birthloc_distance_above_0km, hc3
est store different_0km

nlcom (p: 1-sqrt(1-_b[_cons])), post
est store different_0km_pars
	
	
* Distance of birth coordinates > 5km:
reg birthloc_distance_above_5km, hc3
est store different_5km

nlcom (p: 1-sqrt(1-_b[_cons])), post
est store different_5km_pars
	
	
* Distance of birth coordinates > 10km:
reg birthloc_distance_above_10km, hc3
est store different_10km

nlcom (p: 1-sqrt(1-_b[_cons])), post
est store different_10km_pars
	
	
* Distance of birth coordinates > 20km:
reg birthloc_distance_above_20km, hc3
est store different_20km

nlcom (p: 1-sqrt(1-_b[_cons])), post
est store different_20km_pars
	
	
* Distance of birth coordinates > 30km:
reg birthloc_distance_above_30km, hc3
est store different_30km

nlcom (p: 1-sqrt(1-_b[_cons])), post
est store different_30km_pars
	
	
* Distance of birth coordinates > 40km:
reg birthloc_distance_above_40km, hc3
est store different_40km

nlcom (p: 1-sqrt(1-_b[_cons])), post
est store different_40km_pars
	
	
* Distance of birth coordinates > 50km:
reg birthloc_distance_above_50km, hc3
est store different_50km

nlcom (p: 1-sqrt(1-_b[_cons])), post
est store different_50km_pars




	
*** Regression table - full sample:
esttab different_parish different_district different_county different_0km different_5km different_10km different_30km different_50km, ///
	cells(b(fmt(3) star) se(fmt(3) par)) ///
	collabels(none) ///
	mgroup("Different birth location:", pattern(1 0 0 0 0 0 0)) ///
	mlabel("Parish" "District" "County" "d>0km" "d>5km" "d>10km" "d>30km" "d>50km") ///
	starlevels(* .1 ** .05 *** .01) ///
	coeflabels(_cons "Mean") ///
	noobs nonotes ///
	stats(N, fmt(0) labels("N")) ///
	varwidth(20)
	
esttab different_parish_pars different_district_pars different_county_pars different_0km_pars different_5km_pars different_10km_pars different_30km_pars different_50km_pars, ///
	cells(b(fmt(3) star) se(fmt(3) par)) ///
	collabels(none) ///
	mgroup("Different birth location:", pattern(1 0 0 0 0 0 0)) ///
	mlabel("Parish" "District" "County" "d>0km" "d>5km" "d>10km" "d>30km" "d>50km") ///
	starlevels(* .1 ** .05 *** .01) ///
	coeflabels(p "p") ///
	noobs nonotes ///
	stats(N, fmt(0) labels("N")) ///
	varwidth(20)
	
	
// Latex:
esttab different_parish different_district different_county different_0km different_5km different_10km different_30km different_50km using "${OUTPUT}/tablefragments/repeat_differences_tablefragment.tex", ///
	cells(b(fmt(3) star) se(fmt(3) par)) ///
	collabels(none) ///
	mgroup("Different birth location:", pattern(1 0 0 0 0 0 0) ///
	span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) ///
	mlabel("Parish" "District" "County" "d>0km" "d>5km" "d>10km" "d>30km" "d>50km", prefix({) suffix(})) ///
	starlevels(* .1 ** .05 *** .01) ///
	coeflabels(_cons "Mean") ///
	noobs nonotes ///
	compress replace booktabs fragment
	
esttab different_parish_pars different_district_pars different_county_pars different_0km_pars different_5km_pars different_10km_pars different_30km_pars different_50km_pars using "${OUTPUT}/tablefragments/repeat_differences_tablefragment.tex", ///
	cells(b(fmt(3) star) se(fmt(3) par)) ///
	collabels(none) ///
	mlabel(none) nonumbers ///
	starlevels(* .1 ** .05 *** .01) ///
	refcat(q "\textbf{Derived probability:}", nolabel) ///
	coeflabels(p "$\hat{p}$ (error probability)") ///
	noobs nonotes ///
	stats(N, fmt(%9.0fc) labels("N") layout(\multicolumn{1}{c}{@})) ///
	compress append booktabs fragment