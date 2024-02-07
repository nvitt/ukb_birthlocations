***************************************************************************

clear
est clear
set matsize 11000



******User
global DRIVE 	"//rdsfcifs.acrc.bris.ac.uk/GeneEnvironment_Interactions/UKB/"
global OUTPUT	"C:/Users/pk20062/Dropbox/DONNI - UKB birth location accuracy/output/"






*** Load sibling birth location dataset:
use "${DRIVE}GeographicID/Projects/NV_Papers/Birth locations/dta/sibling_birth_location_data.dta", clear





**************************************************************
*** Comparison across birth cohorts - district differences ***
**************************************************************


// All cohorts:
reg district_different age_gap, hc3
est store diff_distr

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store diff_distr_pars

// 1939-1944:
reg district_different age_gap if L.birth_year>=1939 & L.birth_year<=1944, hc3
est store diff_distr_39_44

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store diff_distr_39_44_pars

// 1945-1949:
reg district_different age_gap if L.birth_year>=1945 & L.birth_year<=1949, hc3
est store diff_distr_45_49

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store diff_distr_45_49_pars

// 1950-1954:
reg district_different age_gap if L.birth_year>=1950 & L.birth_year<=1954, hc3
est store diff_distr_50_54

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store diff_distr_50_54_pars

// 1955-1959:
reg district_different age_gap if L.birth_year>=1955 & L.birth_year<=1959, hc3
est store diff_distr_55_59

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store diff_distr_55_59_pars

// 1960-1968:
reg district_different age_gap if L.birth_year>=1960 & L.birth_year<=1968, hc3
est store diff_distr_60_68

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store diff_distr_60_68_pars



*** Regression table - full sample:
esttab diff_distr_39_44 diff_distr_45_49 diff_distr_50_54 diff_distr_55_59 diff_distr_60_68, ///
	cells(b(fmt(3)) ci(fmt(3) par)) ///
	mgroup("Different birth district:", pattern(1 0 0 0 0)) ///
	collabels(none) ///
	mlabel("1939-44" "1945-49" "1950-54" "1955-59" "1960-68") ///
	coeflabels(age_gap "Age gap (years)" _cons "Constant") ///
	noobs nonotes ///
	stats(N, fmt(0) labels("N (sibling pairs)")) ///
	varwidth(20)
	
esttab diff_distr_39_44_pars diff_distr_45_49_pars diff_distr_50_54_pars diff_distr_55_59_pars diff_distr_60_68_pars, ///
	cells(b(fmt(3)) ci(fmt(3) par)) ///
	mgroup("Different birth district:", pattern(1 0 0 0 0)) ///
	collabels(none) ///
	mlabel("1939-44" "1945-49" "1950-54" "1955-59" "1960-68") ///
	coeflabels(q "q" p "p") ///
	noobs nonotes ///
	stats(N, fmt(0) labels("N (sibling pairs)")) ///
	varwidth(20)
	
	
// Latex:
esttab diff_distr_39_44 diff_distr_45_49 diff_distr_50_54 diff_distr_55_59 diff_distr_60_68 using "${OUTPUT}/tablefragments/distr_diff_regression_by_cohort_tablefragment.tex", ///
	cells(b(fmt(3)) ci(fmt(3) par)) ///
	collabels(none) ///
	mgroup("Different birth district:", pattern(1 0 0 0 0) ///
	span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) ///
	mlabel("1939-44" "1945-49" "1950-54" "1955-59" "1960-68", prefix({) suffix(})) ///
	refcat(age_gap "\textbf{Regression coefficients:}", nolabel) ///
	coeflabels(age_gap "Age gap (years)" _cons "Constant") ///
	noobs nonotes ///
	compress replace booktabs fragment
	
esttab diff_distr_39_44_pars diff_distr_45_49_pars diff_distr_50_54_pars diff_distr_55_59_pars diff_distr_60_68_pars using "${OUTPUT}/tablefragments/distr_diff_regression_by_cohort_tablefragment.tex", ///
	cells(b(fmt(3)) ci(fmt(3) par)) ///
	collabels(none) ///
	mlabel(none) nonumbers ///
	refcat(q "\textbf{Derived probabilities:}", nolabel) ///
	coeflabels(q "$\hat{q}$ (move probability)" p "$\hat{p}$ (error probability)") ///
	noobs nonotes ///
	stats(N, fmt(%9.0fc) labels("N (sibling pairs)") layout(\multicolumn{1}{c}{@})) ///
	compress append booktabs fragment
