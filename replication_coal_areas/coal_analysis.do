***************************************************************************

clear
est clear
set matsize 11000



******User
global DRIVE 	"//rdsfcifs.acrc.bris.ac.uk/GeneEnvironment_Interactions/UKB/"
global OUTPUT	"C:/Users/pk20062/Dropbox/DONNI - UKB birth location accuracy/output/"






*** Load sibling birth location dataset:
use "${DRIVE}GeographicID/Projects/NV_Papers/Birth locations/dta/sibling_birth_location_data.dta", clear

// migration groups:
gen coal_migration_group = .
replace coal_migration_group = 1 if coal_area_birth==1 & coal_area_current==0 // moved away
replace coal_migration_group = 2 if coal_area_birth==0 & coal_area_current==0 // stayed away
replace coal_migration_group = 3 if coal_area_birth==0 & coal_area_current==1 // moved into
replace coal_migration_group = 4 if coal_area_birth==1 & coal_area_current==1 // stayed
label define lb_migration 1 "moved away from coal area" 2 "stayed in non-coal area" 3 "moved into coal area" 4  "stayed in coal area"
label values coal_migration_group lb_migration

// standardize:
foreach var of varlist educ_years h_bmi_0 h_IMPbodyfat_0 h_standingheight_0  c_health_0 {
	sum `var' 
	replace `var'=(`var'-r(mean))/r(sd)
}


	
	
	
	
	
	
*******************
*** Regressions ***
*******************

* Different coal area status of birth location:
reg coal_area_birth_different age_gap, hc3
est store different_coal

nlcom (q: _b[age_gap]) (p: 1-sqrt(1-_b[_cons])), post
est store different_coal_pars





****************************************
*** Phenotypes by coal area at birth ***
****************************************

* Education:
// all siblings:
mean educ_years, over(coal_area_birth) cluster(family_id)
est store educ_coal_all

lincom c.educ_years@0.coal_area_birth - c.educ_years@1.coal_area_birth

// siblings with same coal area status at birth:
mean educ_years if coal_area_birth_different==0 | (F.coal_area_birth_different==0 & F.family_id==family_id), over(coal_area_birth) cluster(family_id)
est store educ_coal_same

lincom c.educ_years@0.coal_area_birth - c.educ_years@1.coal_area_birth


* Body fat:
// all siblings:
mean h_IMPbodyfat_0, over(coal_area_birth) cluster(family_id)
est store fat_coal_all
lincom c.h_IMPbodyfat_0@0.coal_area_birth - c.h_IMPbodyfat_0@1.coal_area_birth

// siblings with same coal area status at birth:
mean h_IMPbodyfat_0 if coal_area_birth_different==0 | (F.coal_area_birth_different==0 & F.family_id==family_id), over(coal_area_birth) cluster(family_id)
est store fat_coal_same
lincom c.h_IMPbodyfat_0@0.coal_area_birth - c.h_IMPbodyfat_0@1.coal_area_birth


* Height:
// all siblings:
mean h_standingheight_0, over(coal_area_birth) cluster(family_id)
est store height_coal_all
lincom h_standingheight_0@0.coal_area_birth - h_standingheight_0@1.coal_area_birth

// siblings with same coal area status at birth:
mean h_standingheight_0 if coal_area_birth_different==0 | (F.coal_area_birth_different==0 & F.family_id==family_id), over(coal_area_birth) cluster(family_id)
est store height_coal_same
lincom h_standingheight_0@0.coal_area_birth - h_standingheight_0@1.coal_area_birth


* BMI:
// all siblings:
mean h_bmi_0, over(coal_area_birth) cluster(family_id)
est store bmi_coal_all
lincom h_bmi_0@0.coal_area_birth - h_bmi_0@1.coal_area_birth

// siblings with same coal area status at birth:
mean h_bmi_0 if coal_area_birth_different==0 | (F.coal_area_birth_different==0 & F.family_id==family_id), over(coal_area_birth) cluster(family_id)
est store bmi_coal_same
lincom h_bmi_0@0.coal_area_birth - h_bmi_0@1.coal_area_birth


* Overall health:
// all siblings:
mean c_health_0, over(coal_area_birth) cluster(family_id)
est store health_coal_all
lincom c_health_0@0.coal_area_birth - c_health_0@1.coal_area_birth

// siblings with same coal area status at birth:
mean c_health_0 if coal_area_birth_different==0 | (F.coal_area_birth_different==0 & F.family_id==family_id), over(coal_area_birth) cluster(family_id)
est store health_coal_same
lincom c_health_0@0.coal_area_birth - c_health_0@1.coal_area_birth




* Graph:
coefplot 	(educ_coal_all, offset(-0.15) keep(*0.coal_area_birth) color(edkblue%30) fintensity(inten100) ciopts(recast(rcap) lcolor(black)) label("All sibs: non-coal")) ///
			(educ_coal_all, offset(-0.15) keep(*1.coal_area_birth) color(edkblue%70) fintensity(inten100) ciopts(recast(rcap) lcolor(black)) label("All sibs: coal")) /// 	
			(educ_coal_same, offset(+0.15) keep(*0.coal_area_birth) color(maroon%30) fintensity(inten100) ciopts(recast(rcap) lcolor(black)) label("Robust sibs: non-coal")) ///
			(educ_coal_same, offset(+0.15) keep(*1.coal_area_birth) color(maroon%70) fintensity(inten100) ciopts(recast(rcap) lcolor(black)) label("Robust sibs: coal")), bylabel("Years of education") || ///
			(fat_coal_all, offset(-0.15) keep(*0.coal_area_birth)) ///
			(fat_coal_all, offset(-0.15) keep(*1.coal_area_birth)) ///
			(fat_coal_same, offset(+0.15) keep(*0.coal_area_birth)) ///
			(fat_coal_same, offset(+0.15) keep(*1.coal_area_birth)), bylabel("Body fat")  || ///
			(height_coal_all, offset(-0.15) keep(*0.coal_area_birth)) ///
			(height_coal_all, offset(-0.15) keep(*1.coal_area_birth)) ///
			(height_coal_same, offset(+0.15) keep(*0.coal_area_birth)) ///
			(height_coal_same, offset(+0.15) keep(*1.coal_area_birth)), bylabel("Height")  || ///
			(bmi_coal_all, offset(-0.15) keep(*0.coal_area_birth)) ///
			(bmi_coal_all, offset(-0.15) keep(*1.coal_area_birth)) ///
			(bmi_coal_same, offset(+0.15) keep(*0.coal_area_birth)) ///
			(bmi_coal_same, offset(+0.15) keep(*1.coal_area_birth)), bylabel("BMI")  || ///
			(health_coal_all, offset(-0.15) keep(*0.coal_area_birth)) ///
			(health_coal_all, offset(-0.15) keep(*1.coal_area_birth)) ///
			(health_coal_same, offset(+0.15) keep(*0.coal_area_birth)) ///
			(health_coal_same, offset(+0.15) keep(*1.coal_area_birth)), bylabel("Overall health")  || ///
		, vertical level(68.268949) recast(bar) scheme(lean1) ///		
		nooffset  yscale(range(-.16 .16)) ylabel(-0.15 (0.05) 0.15) ///
		citop barwidth(0.25) ///
		rename(c.h_IMPbodyfat_0@0.coal_area_birth = c.educ_years@0.coal_area_birth c.h_IMPbodyfat_0@1.coal_area_birth = c.educ_years@1.coal_area_birth ///
		c.h_standingheight_0@0.coal_area_birth = c.educ_years@0.coal_area_birth c.h_standingheight_0@1.coal_area_birth = c.educ_years@1.coal_area_birth ///
		c.h_bmi_0@0.coal_area_birth = c.educ_years@0.coal_area_birth c.h_bmi_0@1.coal_area_birth = c.educ_years@1.coal_area_birth ///
		c.c_health_0@0.coal_area_birth = c.educ_years@0.coal_area_birth c.c_health_0@1.coal_area_birth = c.educ_years@1.coal_area_birth) ///
		coeflabels(c.educ_years@0.coal_area_birth = "non-coal" c.educ_years@1.coal_area_birth = "coal", ///
		labsize(normal)) ///
		graphregion(color(white)) ///
		plotregion(fcolor(white) lcolor(black) margin(0 1 1 1) lalign(outside)) ///
		ytitle("Phenotype (standardized)") ///
		legend(col(2) colfirst symy(*0.7) symx(*0.7) textw(*0.7) forcesize size(small)) yline(0, lcolor(gs10))  ysize(3) byopts(cols(5) legend(pos(6))) subtitle(, bmargin(vsmall))


graph export "${OUTPUT}/graphs/pheno_by_coal.png", replace
graph export "${OUTPUT}/graphs/pheno_by_coal.pdf", replace		


// Source data:
local varnames `" "Years of education" "Body fat" "Height" "BMI" "Overall health" "'
local i=1

foreach x in educ fat height bmi health {
	local varname: word `i' of `varnames'
	if `i'==1 {
	esttab `x'_coal_all using "${OUTPUT}/graphs/pheno_by_coal_source_data.csv", replace ///
		cells((b(fmt(5)) se(fmt(5)) _N(fmt(0)))) ///
		mlabel(none) nonumbers noobs ///
		collabel("Mean" "Standard error" "N", lhs("Phenotype")) ///
		coeflabel(c.educ_years@0.coal_area_birth  "`varname'" c.educ_years@1.coal_area_birth  "`varname'") ///
		labcol2("All sibs: non-coal" "All sibs: coal", title("Sample")) ///
		rename(c.h_IMPbodyfat_0@0.coal_area_birth c.educ_years@0.coal_area_birth c.h_IMPbodyfat_0@1.coal_area_birth c.educ_years@1.coal_area_birth ///
		c.h_standingheight_0@0.coal_area_birth c.educ_years@0.coal_area_birth c.h_standingheight_0@1.coal_area_birth c.educ_years@1.coal_area_birth ///
		c.h_bmi_0@0.coal_area_birth c.educ_years@0.coal_area_birth c.h_bmi_0@1.coal_area_birth c.educ_years@1.coal_area_birth ///
		c.c_health_0@0.coal_area_birth c.educ_years@0.coal_area_birth c.c_health_0@1.coal_area_birth c.educ_years@1.coal_area_birth)
	}
	
	if `i'!=1 {
	esttab `x'_coal_all using "${OUTPUT}/graphs/pheno_by_coal_source_data.csv", append ///
		cells((b(fmt(5)) se(fmt(5)) _N(fmt(0)))) ///
		mlabel(none) nonumbers noobs ///
		collabel(none) ///
		coeflabel(c.educ_years@0.coal_area_birth  "`varname'" c.educ_years@1.coal_area_birth  "`varname'") ///
		labcol2("All sibs: non-coal" "All sibs: coal") ///
		rename(c.h_IMPbodyfat_0@0.coal_area_birth c.educ_years@0.coal_area_birth c.h_IMPbodyfat_0@1.coal_area_birth c.educ_years@1.coal_area_birth ///
		c.h_standingheight_0@0.coal_area_birth c.educ_years@0.coal_area_birth c.h_standingheight_0@1.coal_area_birth c.educ_years@1.coal_area_birth ///
		c.h_bmi_0@0.coal_area_birth c.educ_years@0.coal_area_birth c.h_bmi_0@1.coal_area_birth c.educ_years@1.coal_area_birth ///
		c.c_health_0@0.coal_area_birth c.educ_years@0.coal_area_birth c.c_health_0@1.coal_area_birth c.educ_years@1.coal_area_birth)
	}
	
	
	esttab `x'_coal_same using "${OUTPUT}/graphs/pheno_by_coal_source_data.csv", append ///
		cells((b(fmt(5)) se(fmt(5)) _N(fmt(0)))) ///
		mlabel(none) nonumbers noobs ///
		collabel(none) ///
		coeflabel(c.educ_years@0.coal_area_birth  "`varname'" c.educ_years@1.coal_area_birth  "`varname'") ///
		labcol2("Robust sibs: non-coal" "Robust sibs: coal") ///
		rename(c.h_IMPbodyfat_0@0.coal_area_birth c.educ_years@0.coal_area_birth c.h_IMPbodyfat_0@1.coal_area_birth c.educ_years@1.coal_area_birth ///
		c.h_standingheight_0@0.coal_area_birth c.educ_years@0.coal_area_birth c.h_standingheight_0@1.coal_area_birth c.educ_years@1.coal_area_birth ///
		c.h_bmi_0@0.coal_area_birth c.educ_years@0.coal_area_birth c.h_bmi_0@1.coal_area_birth c.educ_years@1.coal_area_birth ///
		c.c_health_0@0.coal_area_birth c.educ_years@0.coal_area_birth c.c_health_0@1.coal_area_birth c.educ_years@1.coal_area_birth)
	
	local i=`i'+1
}





**************************************************
*** Phenotypes by coal area migration at birth ***
**************************************************

* Education:
// all siblings:
mean educ_years, over(coal_migration_group) cluster(family_id)
est store educ_migr_all
reg educ_years i.coal_migration_group, cluster(family_id)

// siblings with same coal area status at birth:
mean educ_years if coal_area_birth_different==0 | (F.coal_area_birth_different==0 & F.family_id==family_id), over(coal_migration_group) cluster(family_id)
est store educ_migr_same
reg educ_years i.coal_migration_group if coal_area_birth_different==0 | (F.coal_area_birth_different==0 & F.family_id==family_id), cluster(family_id)


* Body fat:
// all siblings:
mean h_IMPbodyfat_0, over(coal_migration_group) cluster(family_id)
est store fat_migr_all
reg h_IMPbodyfat_0 i.coal_migration_group, cluster(family_id)

// siblings with same coal area status at birth:
mean h_IMPbodyfat_0 if coal_area_birth_different==0 | (F.coal_area_birth_different==0 & F.family_id==family_id), over(coal_migration_group) cluster(family_id)
est store fat_migr_same
reg h_IMPbodyfat_0 i.coal_migration_group if coal_area_birth_different==0 | (F.coal_area_birth_different==0 & F.family_id==family_id), cluster(family_id)


* Height:
// all siblings:
mean h_standingheight_0, over(coal_migration_group) cluster(family_id)
est store height_migr_all
reg h_standingheight_0 i.coal_migration_group, cluster(family_id)

// siblings with same coal area status at birth:
mean h_standingheight_0 if coal_area_birth_different==0 | (F.coal_area_birth_different==0 & F.family_id==family_id), over(coal_migration_group) cluster(family_id)
est store height_migr_same
reg h_standingheight_0 i.coal_migration_group if coal_area_birth_different==0 | (F.coal_area_birth_different==0 & F.family_id==family_id), cluster(family_id)


* BMI:
// all siblings:
mean h_bmi_0, over(coal_migration_group) cluster(family_id)
est store bmi_migr_all
reg h_bmi_0 i.coal_migration_group, cluster(family_id)

// siblings with same coal area status at birth:
mean h_bmi_0 if coal_area_birth_different==0 | (F.coal_area_birth_different==0 & F.family_id==family_id), over(coal_migration_group) cluster(family_id)
est store bmi_migr_same
reg h_bmi_0 i.coal_migration_group if coal_area_birth_different==0 | (F.coal_area_birth_different==0 & F.family_id==family_id), cluster(family_id)


* Overall health:
// all siblings:
mean c_health_0, over(coal_migration_group) cluster(family_id)
est store health_migr_all
reg c_health_0 i.coal_migration_group, cluster(family_id)

// siblings with same coal area status at birth:
mean c_health_0 if coal_area_birth_different==0 | (F.coal_area_birth_different==0 & F.family_id==family_id), over(coal_migration_group) cluster(family_id)
est store health_migr_same
reg c_health_0 i.coal_migration_group if coal_area_birth_different==0 | (F.coal_area_birth_different==0 & F.family_id==family_id), cluster(family_id)




* Graph:
coefplot 	(educ_migr_all, offset(-0.15) keep(*1.coal_migration_group) color(edkblue%20) fintensity(inten100) ciopts(recast(rcap) lcolor(black)) label("All sibs: moved away from coal")) ///
			(educ_migr_all, offset(-0.15) keep(*2.coal_migration_group) color(edkblue%40) fintensity(inten100) ciopts(recast(rcap) lcolor(black)) label("All sibs: stayed in non-coal")) /// 	
			(educ_migr_all, offset(-0.15) keep(*3.coal_migration_group) color(edkblue%60) fintensity(inten100) ciopts(recast(rcap) lcolor(black)) label("All sibs: moved into coal")) /// 	
			(educ_migr_all, offset(-0.15) keep(*4.coal_migration_group) color(edkblue%80) fintensity(inten100) ciopts(recast(rcap) lcolor(black)) label("All sibs: stayed in coal")) /// 	
			(educ_migr_same, offset(+0.15) keep(*1.coal_migration_group) color(maroon%20) fintensity(inten100) ciopts(recast(rcap) lcolor(black)) label("Robust sibs: moved away from coal")) ///
			(educ_migr_same, offset(+0.15) keep(*2.coal_migration_group) color(maroon%40) fintensity(inten100) ciopts(recast(rcap) lcolor(black)) label("Robust sibs: stayed in non-coal")) ///
			(educ_migr_same, offset(+0.15) keep(*3.coal_migration_group) color(maroon%60) fintensity(inten100) ciopts(recast(rcap) lcolor(black)) label("Robust sibs: moved into coal")) ///
			(educ_migr_same, offset(+0.15) keep(*4.coal_migration_group) color(maroon%80) fintensity(inten100) ciopts(recast(rcap) lcolor(black)) label("Robust sibs: stayed in coal")), bylabel("Years of education") || ///
			(fat_migr_all, offset(-0.15) keep(*1.coal_migration_group)) ///
			(fat_migr_all, offset(-0.15) keep(*2.coal_migration_group)) /// 	
			(fat_migr_all, offset(-0.15) keep(*3.coal_migration_group)) /// 	
			(fat_migr_all, offset(-0.15) keep(*4.coal_migration_group)) /// 	
			(fat_migr_same, offset(+0.15) keep(*1.coal_migration_group)) ///
			(fat_migr_same, offset(+0.15) keep(*2.coal_migration_group)) ///
			(fat_migr_same, offset(+0.15) keep(*3.coal_migration_group)) ///
			(fat_migr_same, offset(+0.15) keep(*4.coal_migration_group)), bylabel("Body fat") || ///
			(height_migr_all, offset(-0.15) keep(*1.coal_migration_group)) ///
			(height_migr_all, offset(-0.15) keep(*2.coal_migration_group)) /// 	
			(height_migr_all, offset(-0.15) keep(*3.coal_migration_group)) /// 	
			(height_migr_all, offset(-0.15) keep(*4.coal_migration_group)) /// 	
			(height_migr_same, offset(+0.15) keep(*1.coal_migration_group)) ///
			(height_migr_same, offset(+0.15) keep(*2.coal_migration_group)) ///
			(height_migr_same, offset(+0.15) keep(*3.coal_migration_group)) ///
			(height_migr_same, offset(+0.15) keep(*4.coal_migration_group)), bylabel("Height") || ///
			(bmi_migr_all, offset(-0.15) keep(*1.coal_migration_group)) ///
			(bmi_migr_all, offset(-0.15) keep(*2.coal_migration_group)) /// 	
			(bmi_migr_all, offset(-0.15) keep(*3.coal_migration_group)) /// 	
			(bmi_migr_all, offset(-0.15) keep(*4.coal_migration_group)) /// 	
			(bmi_migr_same, offset(+0.15) keep(*1.coal_migration_group)) ///
			(bmi_migr_same, offset(+0.15) keep(*2.coal_migration_group)) ///
			(bmi_migr_same, offset(+0.15) keep(*3.coal_migration_group)) ///
			(bmi_migr_same, offset(+0.15) keep(*4.coal_migration_group)), bylabel("BMI") || ///
			(health_migr_all, offset(-0.15) keep(*1.coal_migration_group)) ///
			(health_migr_all, offset(-0.15) keep(*2.coal_migration_group)) /// 	
			(health_migr_all, offset(-0.15) keep(*3.coal_migration_group)) /// 	
			(health_migr_all, offset(-0.15) keep(*4.coal_migration_group)) /// 	
			(health_migr_same, offset(+0.15) keep(*1.coal_migration_group)) ///
			(health_migr_same, offset(+0.15) keep(*2.coal_migration_group)) ///
			(health_migr_same, offset(+0.15) keep(*3.coal_migration_group)) ///
			(health_migr_same, offset(+0.15) keep(*4.coal_migration_group)), bylabel("Overall health") || ///
		, vertical level(68.268949) recast(bar) scheme(lean1) ///		
		nooffset yscale(range(-0.31 0.31)) ylabel(-0.3 (0.1) 0.3) ///
		citop barwidth(0.25) ///
		rename(c.h_IMPbodyfat_0@1.coal_migration_group = c.educ_years@1.coal_migration_group c.h_IMPbodyfat_0@2.coal_migration_group = c.educ_years@2.coal_migration_group ///
		c.h_IMPbodyfat_0@3.coal_migration_group = c.educ_years@3.coal_migration_group c.h_IMPbodyfat_0@4.coal_migration_group = c.educ_years@4.coal_migration_group ///
		c.h_standingheight_0@1.coal_migration_group = c.educ_years@1.coal_migration_group c.h_standingheight_0@2.coal_migration_group = c.educ_years@2.coal_migration_group ///
		c.h_standingheight_0@3.coal_migration_group = c.educ_years@3.coal_migration_group c.h_standingheight_0@4.coal_migration_group = c.educ_years@4.coal_migration_group ///
		c.h_bmi_0@1.coal_migration_group = c.educ_years@1.coal_migration_group c.h_bmi_0@2.coal_migration_group = c.educ_years@2.coal_migration_group ///
		c.h_bmi_0@3.coal_migration_group = c.educ_years@3.coal_migration_group c.h_bmi_0@4.coal_migration_group = c.educ_years@4.coal_migration_group ///
		c.c_health_0@1.coal_migration_group = c.educ_years@1.coal_migration_group c.c_health_0@2.coal_migration_group = c.educ_years@2.coal_migration_group ///
		c.c_health_0@3.coal_migration_group = c.educ_years@3.coal_migration_group c.c_health_0@4.coal_migration_group = c.educ_years@4.coal_migration_group) ///
		coeflabels(c.educ_years@1.coal_migration_group = "C -> NC" c.educ_years@2.coal_migration_group = "NC" ///
		c.educ_years@3.coal_migration_group = "NC -> C" c.educ_years@4.coal_migration_group = "C", ///
		labsize(small)) ///
		graphregion(color(white)) ///
		plotregion(fcolor(white) lcolor(black) margin(0 1 1 1) lalign(outside)) ///
		ytitle("Phenotype (standardized)") ///
		legend(col(2) colfirst symy(*0.7) symx(*0.7) textw(*0.7) forcesize size(small)) yline(0, lcolor(gs10))  ysize(3) byopts(cols(5) legend(pos(6))) subtitle(, bmargin(vsmall))

		
graph export "${OUTPUT}/graphs/pheno_by_migration.png", replace
graph export "${OUTPUT}/graphs/pheno_by_migration.pdf", replace	


// Source data:
local varnames `" "Years of education" "Body fat" "Height" "BMI" "Overall health" "'
local i=1

foreach x in educ fat height bmi health {
	local varname: word `i' of `varnames'
	if `i'==1 {
	esttab `x'_migr_all using "${OUTPUT}/graphs/pheno_by_migration_source_data.csv", replace ///
		cells((b(fmt(5)) se(fmt(5)) _N(fmt(0)))) ///
		mlabel(none) nonumbers noobs ///
		collabel("Mean" "Standard error" "N", lhs("Phenotype")) ///
		coeflabel(c.educ_years@1.coal_migration_group  "`varname'" c.educ_years@2.coal_migration_group  "`varname'" ///
		c.educ_years@3.coal_migration_group  "`varname'" c.educ_years@4.coal_migration_group  "`varname'") ///
		labcol2("All sibs: C -> NC" "All sibs: NC" "All sibs: NC -> C" "All sibs: C", title("Sample")) ///
		rename(c.h_IMPbodyfat_0@1.coal_migration_group c.educ_years@1.coal_migration_group c.h_IMPbodyfat_0@2.coal_migration_group c.educ_years@2.coal_migration_group ///
		c.h_IMPbodyfat_0@3.coal_migration_group c.educ_years@3.coal_migration_group c.h_IMPbodyfat_0@4.coal_migration_group c.educ_years@4.coal_migration_group ///
		c.h_standingheight_0@1.coal_migration_group c.educ_years@1.coal_migration_group c.h_standingheight_0@2.coal_migration_group c.educ_years@2.coal_migration_group ///
		c.h_standingheight_0@3.coal_migration_group c.educ_years@3.coal_migration_group c.h_standingheight_0@4.coal_migration_group c.educ_years@4.coal_migration_group ///
		c.h_bmi_0@1.coal_migration_group c.educ_years@1.coal_migration_group c.h_bmi_0@2.coal_migration_group c.educ_years@2.coal_migration_group ///
		c.h_bmi_0@3.coal_migration_group c.educ_years@3.coal_migration_group c.h_bmi_0@4.coal_migration_group c.educ_years@4.coal_migration_group ///
		c.c_health_0@1.coal_migration_group c.educ_years@1.coal_migration_group c.c_health_0@2.coal_migration_group c.educ_years@2.coal_migration_group ///
		c.c_health_0@3.coal_migration_group c.educ_years@3.coal_migration_group c.c_health_0@4.coal_migration_group c.educ_years@4.coal_migration_group)
		
	}
	
	if `i'!=1 {
	esttab `x'_migr_all using "${OUTPUT}/graphs/pheno_by_migration_source_data.csv", append ///
		cells((b(fmt(5)) se(fmt(5)) _N(fmt(0)))) ///
		mlabel(none) nonumbers noobs ///
		collabel(none) ///
		coeflabel(c.educ_years@1.coal_migration_group  "`varname'" c.educ_years@2.coal_migration_group  "`varname'" ///
		c.educ_years@3.coal_migration_group  "`varname'" c.educ_years@4.coal_migration_group  "`varname'") ///
		labcol2("All sibs: C -> NC" "All sibs: NC" "All sibs: NC -> C" "All sibs: C") ///
		rename(c.h_IMPbodyfat_0@1.coal_migration_group c.educ_years@1.coal_migration_group c.h_IMPbodyfat_0@2.coal_migration_group c.educ_years@2.coal_migration_group ///
		c.h_IMPbodyfat_0@3.coal_migration_group c.educ_years@3.coal_migration_group c.h_IMPbodyfat_0@4.coal_migration_group c.educ_years@4.coal_migration_group ///
		c.h_standingheight_0@1.coal_migration_group c.educ_years@1.coal_migration_group c.h_standingheight_0@2.coal_migration_group c.educ_years@2.coal_migration_group ///
		c.h_standingheight_0@3.coal_migration_group c.educ_years@3.coal_migration_group c.h_standingheight_0@4.coal_migration_group c.educ_years@4.coal_migration_group ///
		c.h_bmi_0@1.coal_migration_group c.educ_years@1.coal_migration_group c.h_bmi_0@2.coal_migration_group c.educ_years@2.coal_migration_group ///
		c.h_bmi_0@3.coal_migration_group c.educ_years@3.coal_migration_group c.h_bmi_0@4.coal_migration_group c.educ_years@4.coal_migration_group ///
		c.c_health_0@1.coal_migration_group c.educ_years@1.coal_migration_group c.c_health_0@2.coal_migration_group c.educ_years@2.coal_migration_group ///
		c.c_health_0@3.coal_migration_group c.educ_years@3.coal_migration_group c.c_health_0@4.coal_migration_group c.educ_years@4.coal_migration_group)
	}
	
	
	esttab `x'_migr_same using "${OUTPUT}/graphs/pheno_by_migration_source_data.csv", append ///
		cells((b(fmt(5)) se(fmt(5)) _N(fmt(0)))) ///
		mlabel(none) nonumbers noobs ///
		collabel(none) ///
		coeflabel(c.educ_years@1.coal_migration_group  "`varname'" c.educ_years@2.coal_migration_group  "`varname'" ///
		c.educ_years@3.coal_migration_group  "`varname'" c.educ_years@4.coal_migration_group  "`varname'") ///
		labcol2("Robust sibs: C -> NC" "Robust sibs: NC" "Robust sibs: NC -> C" "Robust sibs: C") ///
		rename(c.h_IMPbodyfat_0@1.coal_migration_group c.educ_years@1.coal_migration_group c.h_IMPbodyfat_0@2.coal_migration_group c.educ_years@2.coal_migration_group ///
		c.h_IMPbodyfat_0@3.coal_migration_group c.educ_years@3.coal_migration_group c.h_IMPbodyfat_0@4.coal_migration_group c.educ_years@4.coal_migration_group ///
		c.h_standingheight_0@1.coal_migration_group c.educ_years@1.coal_migration_group c.h_standingheight_0@2.coal_migration_group c.educ_years@2.coal_migration_group ///
		c.h_standingheight_0@3.coal_migration_group c.educ_years@3.coal_migration_group c.h_standingheight_0@4.coal_migration_group c.educ_years@4.coal_migration_group ///
		c.h_bmi_0@1.coal_migration_group c.educ_years@1.coal_migration_group c.h_bmi_0@2.coal_migration_group c.educ_years@2.coal_migration_group ///
		c.h_bmi_0@3.coal_migration_group c.educ_years@3.coal_migration_group c.h_bmi_0@4.coal_migration_group c.educ_years@4.coal_migration_group ///
		c.c_health_0@1.coal_migration_group c.educ_years@1.coal_migration_group c.c_health_0@2.coal_migration_group c.educ_years@2.coal_migration_group ///
		c.c_health_0@3.coal_migration_group c.educ_years@3.coal_migration_group c.c_health_0@4.coal_migration_group c.educ_years@4.coal_migration_group)
	
	local i=`i'+1
}	
