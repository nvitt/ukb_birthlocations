***************************************************************************

clear
est clear
set matsize 11000



******User
global DRIVE 	"//rdsfcifs.acrc.bris.ac.uk/GeneEnvironment_Interactions/UKB/"
global OUTPUT	"C:/Users/pk20062/Dropbox/DONNI - UKB birth location accuracy/output/"






*** Load sibling birth location dataset:
use "${DRIVE}GeographicID/Projects/NV_Papers/Birth locations/dta/sibling_birth_location_data.dta", clear






********************************************************************************************
*** Comparison across mean sibling PGI for education and education levels in 1951 census ***
********************************************************************************************

keep if average_sibling_pgi_ea!=. & census51_age_left_ed_0_14_sh!=.

sum average_sibling_pgi_ea, detail
local pgi_p50 = r(p50)

sum census51_age_left_ed_0_14_sh, detail	
local censuseduc_p50 = r(p50)


// All:
reg district_different age_gap, hc3
est store diff_distr

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store diff_distr_pars

// low PGI, low education area:
reg district_different age_gap if average_sibling_pgi_ea<=`pgi_p50' & L.census51_age_left_ed_0_14_sh>`censuseduc_p50', hc3
est store diff_distr_lpgi_leduc

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store diff_distr_lpgi_leduc_pars

// high PGI, low education area:
reg district_different age_gap if average_sibling_pgi_ea>`pgi_p50' & L.census51_age_left_ed_0_14_sh>`censuseduc_p50', hc3
est store diff_distr_hpgi_leduc

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store diff_distr_hpgi_leduc_pars

// low PGI, high education area:
reg district_different age_gap if average_sibling_pgi_ea<=`pgi_p50' & L.census51_age_left_ed_0_14_sh<=`censuseduc_p50', hc3
est store diff_distr_lpgi_heduc

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store diff_distr_lpgi_heduc_pars


// high PGI, high education area:
reg district_different age_gap if average_sibling_pgi_ea>`pgi_p50' & L.census51_age_left_ed_0_14_sh<=`censuseduc_p50', hc3
est store diff_distr_hpgi_heduc

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store diff_distr_hpgi_heduc_pars

	
	
*** Regression table:
esttab diff_distr_lpgi_leduc diff_distr_hpgi_leduc diff_distr_lpgi_heduc diff_distr_hpgi_heduc, ///
	cells(b(fmt(3)) ci(fmt(3) par)) ///
	mgroup("Low education area" "High education area", pattern(1 0 1 0)) ///
	collabels(none) ///
	mlabel("Low PGI" "High PGI" "Low PGI" "High PGI") ///
	coeflabels(age_gap "Age gap (years)" _cons "Constant") ///
	noobs nonotes ///
	stats(N, fmt(0) labels("N (sibling pairs)")) ///
	varwidth(20)
	
esttab diff_distr_lpgi_leduc_pars diff_distr_hpgi_leduc_pars diff_distr_lpgi_heduc_pars diff_distr_hpgi_heduc_pars, ///
	cells(b(fmt(3)) ci(fmt(3) par)) ///
	mgroup("Low education area" "High education area", pattern(1 0 1 0)) ///
	collabels(none) ///
	mlabel("Low PGI" "High PGI" "Low PGI" "High PGI") ///
	coeflabels(q "q" p "p") ///
	noobs nonotes ///
	stats(N, fmt(0) labels("N (sibling pairs)")) ///
	varwidth(20)
	
	
// Latex:
esttab diff_distr_lpgi_leduc diff_distr_hpgi_leduc diff_distr_lpgi_heduc diff_distr_hpgi_heduc using "${OUTPUT}/tablefragments/distr_diff_regression_by_pgi_c51educ_tablefragment.tex", ///
	cells(b(fmt(3)) ci(fmt(3) par)) ///
	collabels(none) ///
	mgroup("Low education area" "High education area", pattern(1 0 1 0) ///
	span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) ///
	mlabel("Low PGI" "High PGI" "Low PGI" "High PGI", prefix({) suffix(})) ///
	coeflabels(age_gap "Age gap (years)" _cons "Constant") ///
	noobs nonotes ///
	compress replace booktabs fragment
	
esttab diff_distr_lpgi_leduc_pars diff_distr_hpgi_leduc_pars diff_distr_lpgi_heduc_pars diff_distr_hpgi_heduc_pars using "${OUTPUT}/tablefragments/distr_diff_regression_by_pgi_c51educ_tablefragment.tex", ///
	cells(b(fmt(3)) ci(fmt(3) par)) ///
	collabels(none) ///
	mlabel(none) nonumbers ///
	refcat(q "\textbf{Derived probabilities:}", nolabel) ///
	coeflabels(q "$\hat{q}$ (move probability)" p "$\hat{p}$ (error probability)") ///
	noobs nonotes ///
	stats(N, fmt(%9.0fc) labels("N (sibling pairs)") layout(\multicolumn{1}{c}{@})) ///
	compress append booktabs fragment

	
	
	