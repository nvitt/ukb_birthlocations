***************************************************************************

clear
est clear
set matsize 11000



******User
global DRIVE 	"//rdsfcifs.acrc.bris.ac.uk/GeneEnvironment_Interactions/UKB/"
global OUTPUT	"C:/Users/pk20062/Dropbox/DONNI - UKB birth location accuracy/output/"






*** Load sibling birth location dataset:
use "${DRIVE}GeographicID/Projects/NV_Papers/Birth locations/dta/sibling_birth_location_data.dta", clear


// Average population density for sibling pair:
egen average_sibling_pop_density_4070 = mean(pop_density_1940_1970), by(family_id)




******************************************************
*** Comparison across population density quartiles ***
******************************************************

sum average_sibling_pop_density_4070, detail
local p25 = r(p25)
local p50 = r(p50)
local p75 = r(p75)


// All:
reg district_different age_gap, hc3
est store diff_distr

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store diff_distr_pars

// Q1:
reg district_different age_gap if average_sibling_pop_density_4070<=`p25', hc3
est store diff_distr_q1

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store diff_distr_q1_pars

// Q2:
reg district_different age_gap if average_sibling_pop_density_4070>`p25' & average_sibling_pop_density_4070<=`p50', hc3
est store diff_distr_q2

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store diff_distr_q2_pars

// Q3:
reg district_different age_gap if average_sibling_pop_density_4070>`p50' & average_sibling_pop_density_4070<=`p75', hc3
est store diff_distr_q3

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store diff_distr_q3_pars

// Q4:
reg district_different age_gap if average_sibling_pop_density_4070>`p75', hc3
est store diff_distr_q4

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store diff_distr_q4_pars


	
	
*** Regression table:
esttab diff_distr_q1 diff_distr_q2 diff_distr_q3 diff_distr_q4, ///
	cells(b(fmt(3)) ci(fmt(3) par)) ///
	mgroup("Quartiles of district-level population density:", pattern(1 0 0 0)) ///
	collabels(none) ///
	mlabel("Q1" "Q2" "Q3" "Q4") ///
	coeflabels(age_gap "Age gap (years)" _cons "Constant") ///
	noobs nonotes ///
	stats(N, fmt(0) labels("N (sibling pairs)")) ///
	varwidth(20)
	
esttab diff_distr_q1_pars diff_distr_q2_pars diff_distr_q3_pars diff_distr_q4_pars, ///
	cells(b(fmt(3)) ci(fmt(3) par)) ///
	mgroup("Quartiles of district-level population density:", pattern(1 0 0 0)) ///
	collabels(none) ///
	mlabel("Q1" "Q2" "Q3" "Q4") ///
	coeflabels(q "q" p "p") ///
	noobs nonotes ///
	stats(N, fmt(0) labels("N (sibling pairs)")) ///
	varwidth(20)
	
	
// Latex:
esttab diff_distr_q1 diff_distr_q2 diff_distr_q3 diff_distr_q4 using "${OUTPUT}/tablefragments/distr_diff_regression_by_popdensity_tablefragment.tex", ///
	cells(b(fmt(3)) ci(fmt(3) par)) ///
	collabels(none) ///
	mgroup("Quartiles of district-level population density:", pattern(1 0 0 0) ///
	span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) ///
	mlabel("Q1" "Q2" "Q3" "Q4", prefix({) suffix(})) ///
	refcat(age_gap "\textbf{Regression coefficients:}", nolabel) ///
	coeflabels(age_gap "Age gap (years)" _cons "Constant") ///
	noobs nonotes ///
	compress replace booktabs fragment
	
esttab diff_distr_q1_pars diff_distr_q2_pars diff_distr_q3_pars diff_distr_q4_pars using "${OUTPUT}/tablefragments/distr_diff_regression_by_popdensity_tablefragment.tex", ///
	cells(b(fmt(3)) ci(fmt(3) par)) ///
	collabels(none) ///
	mlabel(none) nonumbers ///
	refcat(q "\textbf{Derived probabilities:}", nolabel) ///
	coeflabels(q "$\hat{q}$ (move probability)" p "$\hat{p}$ (error probability)") ///
	noobs nonotes ///
	stats(N, fmt(%9.0fc) labels("N (sibling pairs)") layout(\multicolumn{1}{c}{@})) ///
	compress append booktabs fragment
