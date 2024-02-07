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
reg parish_different c.age_gap##c.age_gap, hc3
est store different_parish

nlcom 	(q_1: _b[age_gap]+1*_b[c.age_gap#c.age_gap]) ///
		(q_3: _b[age_gap]+3*_b[c.age_gap#c.age_gap]) ///
		(q_5: _b[age_gap]+5*_b[c.age_gap#c.age_gap]) ///
		(q_6: _b[age_gap]+6*_b[c.age_gap#c.age_gap]) ///
		(q_9: _b[age_gap]+9*_b[c.age_gap#c.age_gap]) ///
		(q_10: _b[age_gap]+10*_b[c.age_gap#c.age_gap]) ///
		(q_15: _b[age_gap]+15*_b[c.age_gap#c.age_gap]) ///
		(p: 1-sqrt(1-_b[_cons])), post
est store different_parish_pars


* Different districts:
reg district_different c.age_gap##c.age_gap, hc3
est store different_district

nlcom 	(q_1: _b[age_gap]+1*_b[c.age_gap#c.age_gap]) ///
		(q_3: _b[age_gap]+3*_b[c.age_gap#c.age_gap]) ///
		(q_5: _b[age_gap]+5*_b[c.age_gap#c.age_gap]) ///
		(q_6: _b[age_gap]+6*_b[c.age_gap#c.age_gap]) ///
		(q_9: _b[age_gap]+9*_b[c.age_gap#c.age_gap]) ///
		(q_10: _b[age_gap]+10*_b[c.age_gap#c.age_gap]) ///
		(q_15: _b[age_gap]+15*_b[c.age_gap#c.age_gap]) ///
		(p: 1-sqrt(1-_b[_cons])), post
est store different_district_pars


* Different counties:
reg county_different c.age_gap##c.age_gap, hc3
est store different_county

nlcom 	(q_1: _b[age_gap]+1*_b[c.age_gap#c.age_gap]) ///
		(q_3: _b[age_gap]+3*_b[c.age_gap#c.age_gap]) ///
		(q_5: _b[age_gap]+5*_b[c.age_gap#c.age_gap]) ///
		(q_6: _b[age_gap]+6*_b[c.age_gap#c.age_gap]) ///
		(q_9: _b[age_gap]+9*_b[c.age_gap#c.age_gap]) ///
		(q_10: _b[age_gap]+10*_b[c.age_gap#c.age_gap]) ///
		(q_15: _b[age_gap]+15*_b[c.age_gap#c.age_gap]) ///
		(p: 1-sqrt(1-_b[_cons])), post
est store different_county_pars
	
	
* Different birth coordinates:
reg sibling_distance_above_0km c.age_gap##c.age_gap, hc3
est store different_0km

nlcom 	(q_1: _b[age_gap]+1*_b[c.age_gap#c.age_gap]) ///
		(q_3: _b[age_gap]+3*_b[c.age_gap#c.age_gap]) ///
		(q_5: _b[age_gap]+5*_b[c.age_gap#c.age_gap]) ///
		(q_6: _b[age_gap]+6*_b[c.age_gap#c.age_gap]) ///
		(q_9: _b[age_gap]+9*_b[c.age_gap#c.age_gap]) ///
		(q_10: _b[age_gap]+10*_b[c.age_gap#c.age_gap]) ///
		(q_15: _b[age_gap]+15*_b[c.age_gap#c.age_gap]) ///
		(p: 1-sqrt(1-_b[_cons])), post
est store different_0km_pars
	
	
* Distance of birth coordinates > 5km:
reg sibling_distance_above_5km c.age_gap##c.age_gap, hc3
est store different_5km

nlcom 	(q_1: _b[age_gap]+1*_b[c.age_gap#c.age_gap]) ///
		(q_3: _b[age_gap]+3*_b[c.age_gap#c.age_gap]) ///
		(q_5: _b[age_gap]+5*_b[c.age_gap#c.age_gap]) ///
		(q_6: _b[age_gap]+6*_b[c.age_gap#c.age_gap]) ///
		(q_9: _b[age_gap]+9*_b[c.age_gap#c.age_gap]) ///
		(q_10: _b[age_gap]+10*_b[c.age_gap#c.age_gap]) ///
		(q_15: _b[age_gap]+15*_b[c.age_gap#c.age_gap]) ///
		(p: 1-sqrt(1-_b[_cons])), post
est store different_5km_pars
	
	
* Distance of birth coordinates > 10km:
reg sibling_distance_above_10km c.age_gap##c.age_gap, hc3
est store different_10km

nlcom 	(q_1: _b[age_gap]+1*_b[c.age_gap#c.age_gap]) ///
		(q_3: _b[age_gap]+3*_b[c.age_gap#c.age_gap]) ///
		(q_5: _b[age_gap]+5*_b[c.age_gap#c.age_gap]) ///
		(q_6: _b[age_gap]+6*_b[c.age_gap#c.age_gap]) ///
		(q_9: _b[age_gap]+9*_b[c.age_gap#c.age_gap]) ///
		(q_10: _b[age_gap]+10*_b[c.age_gap#c.age_gap]) ///
		(q_15: _b[age_gap]+15*_b[c.age_gap#c.age_gap]) ///
		(p: 1-sqrt(1-_b[_cons])), post
est store different_10km_pars
	
	
* Distance of birth coordinates > 20km:
reg sibling_distance_above_20km c.age_gap##c.age_gap, hc3
est store different_20km

nlcom 	(q_1: _b[age_gap]+1*_b[c.age_gap#c.age_gap]) ///
		(q_3: _b[age_gap]+3*_b[c.age_gap#c.age_gap]) ///
		(q_5: _b[age_gap]+5*_b[c.age_gap#c.age_gap]) ///
		(q_6: _b[age_gap]+6*_b[c.age_gap#c.age_gap]) ///
		(q_9: _b[age_gap]+9*_b[c.age_gap#c.age_gap]) ///
		(q_10: _b[age_gap]+10*_b[c.age_gap#c.age_gap]) ///
		(q_15: _b[age_gap]+15*_b[c.age_gap#c.age_gap]) ///
		(p: 1-sqrt(1-_b[_cons])), post
est store different_20km_pars
	
	
* Distance of birth coordinates > 30km:
reg sibling_distance_above_30km c.age_gap##c.age_gap, hc3
est store different_30km

nlcom 	(q_1: _b[age_gap]+1*_b[c.age_gap#c.age_gap]) ///
		(q_3: _b[age_gap]+3*_b[c.age_gap#c.age_gap]) ///
		(q_5: _b[age_gap]+5*_b[c.age_gap#c.age_gap]) ///
		(q_6: _b[age_gap]+6*_b[c.age_gap#c.age_gap]) ///
		(q_9: _b[age_gap]+9*_b[c.age_gap#c.age_gap]) ///
		(q_10: _b[age_gap]+10*_b[c.age_gap#c.age_gap]) ///
		(q_15: _b[age_gap]+15*_b[c.age_gap#c.age_gap]) ///
		(p: 1-sqrt(1-_b[_cons])), post
est store different_30km_pars
	
	
* Distance of birth coordinates > 40km:
reg sibling_distance_above_40km c.age_gap##c.age_gap, hc3
est store different_40km

nlcom 	(q_1: _b[age_gap]+1*_b[c.age_gap#c.age_gap]) ///
		(q_3: _b[age_gap]+3*_b[c.age_gap#c.age_gap]) ///
		(q_5: _b[age_gap]+5*_b[c.age_gap#c.age_gap]) ///
		(q_6: _b[age_gap]+6*_b[c.age_gap#c.age_gap]) ///
		(q_9: _b[age_gap]+9*_b[c.age_gap#c.age_gap]) ///
		(q_10: _b[age_gap]+10*_b[c.age_gap#c.age_gap]) ///
		(q_15: _b[age_gap]+15*_b[c.age_gap#c.age_gap]) ///
		(p: 1-sqrt(1-_b[_cons])), post
est store different_40km_pars
	
	
* Distance of birth coordinates > 50km:
reg sibling_distance_above_50km c.age_gap##c.age_gap, hc3
est store different_50km

nlcom 	(q_1: _b[age_gap]+1*_b[c.age_gap#c.age_gap]) ///
		(q_3: _b[age_gap]+3*_b[c.age_gap#c.age_gap]) ///
		(q_5: _b[age_gap]+5*_b[c.age_gap#c.age_gap]) ///
		(q_6: _b[age_gap]+6*_b[c.age_gap#c.age_gap]) ///
		(q_9: _b[age_gap]+9*_b[c.age_gap#c.age_gap]) ///
		(q_10: _b[age_gap]+10*_b[c.age_gap#c.age_gap]) ///
		(q_15: _b[age_gap]+15*_b[c.age_gap#c.age_gap]) ///
		(p: 1-sqrt(1-_b[_cons])), post
est store different_50km_pars
	
	
*** Regression table - full sample:
esttab different_parish different_district different_county different_0km different_5km different_10km different_30km different_50km, ///
	cells(b(fmt(4)) ci(fmt(4) par)) ///
	collabels(none) ///
	mgroup("Different birth location:", pattern(1 0 0 0 0 0 0)) ///
	mlabel("Parish" "District" "County" "d>0km" "d>5km" "d>10km" "d>30km" "d>50km") ///
	coeflabels(age_gap "Age gap (years)" c.age_gap#c.age_gap "Age gap squared" _cons "Constant") ///
	noobs nonotes ///
	stats(N, fmt(0) labels("N (sibling pairs)")) ///
	varwidth(20)
	
esttab different_parish_pars different_district_pars different_county_pars different_0km_pars different_5km_pars different_10km_pars different_30km_pars different_50km_pars, ///
	cells(b(fmt(4)) ci(fmt(4) par)) ///
	collabels(none) ///
	mgroup("Different birth location:", pattern(1 0 0 0 0 0 0)) ///
	mlabel("Parish" "District" "County" "d>0km" "d>5km" "d>10km" "d>30km" "d>50km") ///
	keep(q_1 q_3 q_6 q_9 p) ///
	coeflabels(q_1 "q(agegap=1)" q_3 "q(agegap=3)" q_6 "q(agegap=6)" q_9 "q(agegap=9)" p "p") ///
	noobs nonotes ///
	stats(N, fmt(0) labels("N (sibling pairs)")) ///
	varwidth(20)
	

// Latex:
esttab different_parish different_district different_county different_0km different_5km different_10km different_30km different_50km using "${OUTPUT}/tablefragments/differences_regression_quadratic_tablefragment.tex", ///
	cells(b(fmt(4)) ci(fmt(4) par)) ///
	collabels(none) ///
	mgroup("Different birth location:", pattern(1 0 0 0 0 0 0) ///
	span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) ///
	mlabel("Parish" "District" "County" "d>0km" "d>5km" "d>10km" "d>30km" "d>50km", prefix({) suffix(})) ///
	refcat(age_gap "\textbf{Regression coefficients:}", nolabel) ///
	coeflabels(age_gap "Age gap (years)" c.age_gap#c.age_gap "Age gap squared" _cons "Constant") ///
	noobs nonotes ///
	compress replace booktabs fragment
	
esttab different_parish_pars different_district_pars different_county_pars different_0km_pars different_5km_pars different_10km_pars different_30km_pars different_50km_pars using "${OUTPUT}/tablefragments/differences_regression_quadratic_tablefragment.tex", ///
	cells(b(fmt(4)) ci(fmt(4) par)) ///
	collabels(none) ///
	mlabel(none) nonumbers ///
	keep(q_1 q_3 q_6 q_9 p) ///
	refcat(q_1 "\textbf{Derived probabilities:}", nolabel) ///
	coeflabels(q_1 "$\hat{q}(agegap=1)$" q_3 "$\hat{q}(agegap=3)$" q_6 "$\hat{q}(agegap=6)$" q_9 "$\hat{q}(agegap=9)$" p "$\hat{p}$") ///
	noobs nonotes ///
	stats(N, fmt(%9.0fc) labels("N (sibling pairs)") layout(\multicolumn{1}{c}{@})) ///
	compress append booktabs fragment



	
