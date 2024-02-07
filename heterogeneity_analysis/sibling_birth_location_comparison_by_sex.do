***************************************************************************

clear
est clear
set matsize 11000



******User
global DRIVE 	"//rdsfcifs.acrc.bris.ac.uk/GeneEnvironment_Interactions/UKB/"
global OUTPUT	"C:/Users/pk20062/Dropbox/DONNI - UKB birth location accuracy/output/"






*** Load sibling birth location dataset:
use "${DRIVE}GeographicID/Projects/NV_Papers/Birth locations/dta/sibling_birth_location_data.dta", clear



*************************************
*** Comparison by sex composition ***
*************************************


// All:
reg district_different age_gap, hc3
est store diff_distr

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store diff_distr_pars

// Both female:
reg district_different age_gap if female==1 & L.female==1, hc3
est store diff_distr_ff

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store diff_distr_ff_pars

// Mixed:
reg district_different age_gap if female!=L.female, hc3
est store diff_distr_fm

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store diff_distr_fm_pars

// Both male:
reg district_different age_gap if female==0 & L.female==0, hc3
est store diff_distr_mm

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store diff_distr_mm_pars


	
	
*** Regression table:
esttab diff_distr_ff diff_distr_fm diff_distr_mm, ///
	cells(b(fmt(3)) ci(fmt(3) par)) ///
	mgroup("Gender composition of sibling pair:", pattern(1 0 0)) ///
	collabels(none) ///
	mlabel("F/F" "F/M" "M/M") ///
	coeflabels(age_gap "Age gap (years)" _cons "Constant") ///
	noobs nonotes ///
	stats(N, fmt(0) labels("N (sibling pairs)")) ///
	varwidth(20)
	
esttab diff_distr_ff_pars diff_distr_fm_pars diff_distr_mm_pars, ///
	cells(b(fmt(3)) ci(fmt(3) par)) ///
	mgroup("Gender composition of sibling pair:", pattern(1 0 0)) ///
	collabels(none) ///
	mlabel("F/F" "F/M" "M/M") ///
	coeflabels(q "q" p "p") ///
	noobs nonotes ///
	stats(N, fmt(0) labels("N (sibling pairs)")) ///
	varwidth(20)
	
	
// Latex:
esttab diff_distr_ff diff_distr_fm diff_distr_mm using "${OUTPUT}/tablefragments/distr_diff_regression_by_gender_tablefragment.tex", ///
	cells(b(fmt(3)) ci(fmt(3) par)) ///
	collabels(none) ///
	mgroup("Gender composition of sibling pair:", pattern(1 0 0) ///
	span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) ///
	mlabel("F/F" "F/M" "M/M", prefix({) suffix(})) ///
	refcat(age_gap "\textbf{Regression coefficients:}", nolabel) ///
	coeflabels(age_gap "Age gap (years)" _cons "Constant") ///
	noobs nonotes ///
	compress replace booktabs fragment
	
esttab diff_distr_ff_pars diff_distr_fm_pars diff_distr_mm_pars using "${OUTPUT}/tablefragments/distr_diff_regression_by_gender_tablefragment.tex", ///
	cells(b(fmt(3)) ci(fmt(3) par)) ///
	collabels(none) ///
	mlabel(none) nonumbers ///
	refcat(q "\textbf{Derived probabilities:}", nolabel) ///
	coeflabels(q "$\hat{q}$ (move probability)" p "$\hat{p}$ (error probability)") ///
	noobs nonotes ///
	stats(N, fmt(%9.0fc) labels("N (sibling pairs)") layout(\multicolumn{1}{c}{@})) ///
	compress append booktabs fragment
