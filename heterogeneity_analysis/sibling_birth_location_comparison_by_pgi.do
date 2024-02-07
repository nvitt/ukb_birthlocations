***************************************************************************

clear
est clear
set matsize 11000



******User
global DRIVE 	"//rdsfcifs.acrc.bris.ac.uk/GeneEnvironment_Interactions/UKB/"
global OUTPUT	"C:/Users/pk20062/Dropbox/DONNI - UKB birth location accuracy/output/"






*** Load sibling birth location dataset:
use "${DRIVE}GeographicID/Projects/NV_Papers/Birth locations/dta/sibling_birth_location_data.dta", clear






********************************************************
*** Comparison across mean sibling PGI for education ***
********************************************************

sum average_sibling_pgi_ea, detail
local pgi_p25 = r(p25)
local pgi_p50 = r(p50)
local pgi_p75 = r(p75)


// All:
reg district_different age_gap, hc3
est store diff_distr

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store diff_distr_pars

// Q1:
reg district_different age_gap if average_sibling_pgi_ea<=`pgi_p25', hc3
est store diff_distr_q1

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store diff_distr_q1_pars

// Q2:
reg district_different age_gap if average_sibling_pgi_ea>`pgi_p25' & average_sibling_pgi_ea<=`pgi_p50', hc3
est store diff_distr_q2

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store diff_distr_q2_pars

// Q3:
reg district_different age_gap if average_sibling_pgi_ea>`pgi_p50' & average_sibling_pgi_ea<=`pgi_p75', hc3
est store diff_distr_q3

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store diff_distr_q3_pars

// Q4:
reg district_different age_gap if average_sibling_pgi_ea>`pgi_p75' & average_sibling_pgi_ea!=., hc3
est store diff_distr_q4

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store diff_distr_q4_pars


	
	
*** Regression table:
esttab diff_distr_q1 diff_distr_q2 diff_distr_q3 diff_distr_q4, ///
	cells(b(fmt(3)) ci(fmt(3) par)) ///
	mgroup("Quartiles of PGI for education:", pattern(1 0 0 0)) ///
	collabels(none) ///
	mlabel("Q1" "Q2" "Q3" "Q4") ///
	coeflabels(age_gap "Age gap (years)" _cons "Constant") ///
	noobs nonotes ///
	stats(N, fmt(0) labels("N (sibling pairs)")) ///
	varwidth(20)
	
esttab diff_distr_q1_pars diff_distr_q2_pars diff_distr_q3_pars diff_distr_q4_pars, ///
	cells(b(fmt(3)) ci(fmt(3) par)) ///
	mgroup("Quartiles of PGI for education:", pattern(1 0 0 0)) ///
	collabels(none) ///
	mlabel("Q1" "Q2" "Q3" "Q4") ///
	coeflabels(q "q" p "p") ///
	noobs nonotes ///
	stats(N, fmt(0) labels("N (sibling pairs)")) ///
	varwidth(20)
	
	
// Latex:
esttab diff_distr_q1 diff_distr_q2 diff_distr_q3 diff_distr_q4 using "${OUTPUT}/tablefragments/distr_diff_regression_by_pgi_educ_tablefragment.tex", ///
	cells(b(fmt(3)) ci(fmt(3) par)) ///
	collabels(none) ///
	mgroup("Quartiles of PGI for education:", pattern(1 0 0 0) ///
	span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) ///
	mlabel("Q1" "Q2" "Q3" "Q4", prefix({) suffix(})) ///
	coeflabels(age_gap "Age gap (years)" _cons "Constant") ///
	noobs nonotes ///
	compress replace booktabs fragment
	
esttab diff_distr_q1_pars diff_distr_q2_pars diff_distr_q3_pars diff_distr_q4_pars using "${OUTPUT}/tablefragments/distr_diff_regression_by_pgi_educ_tablefragment.tex", ///
	cells(b(fmt(3)) ci(fmt(3) par)) ///
	collabels(none) ///
	mlabel(none) nonumbers ///
	refcat(q "\textbf{Derived probabilities:}", nolabel) ///
	coeflabels(q "$\hat{q}$ (move probability)" p "$\hat{p}$ (error probability)") ///
	noobs nonotes ///
	stats(N, fmt(%9.0fc) labels("N (sibling pairs)") layout(\multicolumn{1}{c}{@})) ///
	compress append booktabs fragment
