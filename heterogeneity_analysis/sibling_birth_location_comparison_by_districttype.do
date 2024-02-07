***************************************************************************

clear
est clear
set matsize 11000



******User
global DRIVE 	"//rdsfcifs.acrc.bris.ac.uk/GeneEnvironment_Interactions/UKB/"
global OUTPUT	"C:/Users/pk20062/Dropbox/DONNI - UKB birth location accuracy/output/"






*** Load sibling birth location dataset:
use "${DRIVE}GeographicID/Projects/NV_Papers/Birth locations/dta/sibling_birth_location_data.dta", clear




******************************************
*** Transitions between district types ***
******************************************

preserve

gen district_type_short = .
replace district_type_short = 1 if rural==1
replace district_type_short = 2 if urban_municipal==1
replace district_type_short = 3 if metropolitan==1
label define lb_district_type 1 "Rural" 2 "Urban / municipal" 3 "Metropolitan"
label values district_type_short lb_district_type

keep family_id sibling_id gid district_type_short
reshape wide district_type gid, i(family_id) j(sibling_id)



gen district_change = 0 if gid1==gid2
replace district_change = 1 if gid1!=gid2 & district_type_short2==1
replace district_change = 2 if gid1!=gid2 & district_type_short2==2
replace district_change = 3 if gid1!=gid2 & district_type_short2==3
label define lb_district_change 0 "Same district" 1 "Different - rural" 2 "Different - urban / municipal" 3 "Different - metropolitan"
label values district_change lb_district_change


table district_type_short1 district_change
estpost tabulate district_type_short1 district_change
est store transitions_by_districttype

* Tables:
esttab transitions_by_districttype, ///
	cell(rowpct(fmt(2) par("" "%")) b(fmt(0) par)) ///
	unstack noobs nonumber nomtitle collabels(none) ///
	varlabels(, blist(Total "{hline @width}{break}"))

// Latex:
esttab transitions_by_districttype using "${OUTPUT}/tablefragments/district_transitions_by_districttype.tex", ///
	cell(rowpct(fmt(2) par("" "\%")) b(fmt(%9.0fc) par("\multicolumn{1}{c}{(" ")}"))) ///
	unstack noobs nonumber nomtitle collabels(none) ///
	varlabels(, blist(Total "\midrule ")) ///
	eqlabels("" "Rural" "Urban / muncipal" "Metropolitan" "", prefix({) suffix(}) ///
	begin(" & \multicolumn{5}{c}{\textbf{2nd sibling:}} \\ \cmidrule(lr){2-6} & \multicolumn{1}{c}{Same district} &\multicolumn{3}{c}{Different district} & \multicolumn{1}{c}{Total} \\ \cmidrule(lr){2-2} \cmidrule(lr){3-5} \cmidrule(lr){6-6} ") lhs("\textbf{1st sibling:}")) ///
	compress replace booktabs fragment
	
restore






****************************************
*** Comparison across district types ***
****************************************


// All districts:
reg district_different age_gap, hc3
est store diff_distr

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store diff_distr_pars

// Rural districts:
reg district_different age_gap if L.rural==1, hc3
est store diff_distr_rural

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store diff_distr_rural_pars

// Urban / municipal districts:
reg district_different age_gap if L.urban_municipal==1, hc3
est store diff_distr_urban

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store diff_distr_urban_pars

// Metropolitan districts:
reg district_different age_gap if L.metropolitan==1, hc3
est store diff_distr_metro

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store diff_distr_metro_pars


	
	
*** Regression table:
esttab diff_distr_rural diff_distr_urban diff_distr_metro, ///
	cells(b(fmt(3)) ci(fmt(3) par)) ///
	mgroup("Different birth district:", pattern(1 0 0)) ///
	collabels(none) ///
	mlabel("Rural" "Urban / municipal" "Metropolitan") ///
	coeflabels(age_gap "Age gap (years)" _cons "Constant") ///
	noobs nonotes ///
	stats(N, fmt(0) labels("N (sibling pairs)")) ///
	varwidth(20)
	
esttab diff_distr_rural_pars diff_distr_urban_pars diff_distr_metro_pars, ///
	cells(b(fmt(3)) ci(fmt(3) par)) ///
	mgroup("Different birth district:", pattern(1 0 0)) ///
	collabels(none) ///
	mlabel("Rural" "Urban / municipal" "Metropolitan") ///
	coeflabels(q "q" p "p") ///
	noobs nonotes ///
	stats(N, fmt(0) labels("N (sibling pairs)")) ///
	varwidth(20)
	
	
// Latex:
esttab diff_distr_rural diff_distr_urban diff_distr_metro using "${OUTPUT}/tablefragments/distr_diff_regression_by_dtype_tablefragment.tex", ///
	cells(b(fmt(3)) ci(fmt(3) par)) ///
	collabels(none) ///
	mgroup("Different birth district:", pattern(1 0 0) ///
	span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span})) ///
	mlabel("Rural" "Urban / municipal" "Metropolitan", prefix({) suffix(})) ///
	refcat(age_gap "\textbf{Regression coefficients:}", nolabel) ///
	coeflabels(age_gap "Age gap (years)" _cons "Constant") ///
	noobs nonotes ///
	compress replace booktabs fragment
	
esttab diff_distr_rural_pars diff_distr_urban_pars diff_distr_metro_pars using "${OUTPUT}/tablefragments/distr_diff_regression_by_dtype_tablefragment.tex", ///
	cells(b(fmt(3)) ci(fmt(3) par)) ///
	collabels(none) ///
	mlabel(none) nonumbers ///
	refcat(q "\textbf{Derived probabilities:}", nolabel) ///
	coeflabels(q "$\hat{q}$ (move probability)" p "$\hat{p}$ (error probability)") ///
	noobs nonotes ///
	stats(N, fmt(%9.0fc) labels("N (sibling pairs)") layout(\multicolumn{1}{c}{@})) ///
	compress append booktabs fragment
