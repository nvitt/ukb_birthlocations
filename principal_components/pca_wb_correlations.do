***************************************************************************

clear
est clear
set matsize 11000



******User
global DRIVE 	"//rdsfcifs.acrc.bris.ac.uk/GeneEnvironment_Interactions/UKB/"
global OUTPUT	"C:/Users/pk20062/Dropbox/DONNI - UKB birth location accuracy/output/"






*** Load sibling birth location dataset:
use "${DRIVE}GeographicID/Projects/NV_Papers/Birth locations/dta/sibling_birth_location_data.dta", clear

// ensure both siblings have distance data:
replace sibling_birth_distance=F.sibling_birth_distance if sibling_id==1 & family_id==F.family_id




*** Correlations for PC scores - LD removed and pruned:
est clear

forvalues i=1/6 {
	
	gen pca_wb_dist_0km = pca_wb_`i' if sibling_birth_distance==0
	gen pca_wb_dist_10km = pca_wb_`i' if sibling_birth_distance>0 & sibling_birth_distance<=10
	gen pca_wb_dist_20km = pca_wb_`i' if sibling_birth_distance>10 & sibling_birth_distance<=20
	gen pca_wb_dist_30km = pca_wb_`i' if sibling_birth_distance>20 & sibling_birth_distance<=30
	gen pca_wb_dist_40km = pca_wb_`i' if sibling_birth_distance>30 & sibling_birth_distance<=40
	gen pca_wb_dist_50km = pca_wb_`i' if sibling_birth_distance>40 & sibling_birth_distance<=50
	gen pca_wb_dist_75km = pca_wb_`i' if sibling_birth_distance>50 & sibling_birth_distance<=75
	gen pca_wb_dist_100km = pca_wb_`i' if sibling_birth_distance>75 & sibling_birth_distance<=100
	gen pca_wb_dist_200km = pca_wb_`i' if sibling_birth_distance>100 & sibling_birth_distance<=200
	gen pca_wb_dist_above200km = pca_wb_`i' if sibling_birth_distance>200 & sibling_birth_distance!=.
	
	estpost corr coord_pca_wb_`i' pca_wb_dist_* 
	est store corr_pca`i'
	
	// add confidence intervals:
	matrix A=J(2,10,.)
	ci2 coord_pca_wb_`i' pca_wb_dist_0km, corr
	matrix A[1,1]=r(lb)
	matrix A[2,1]=r(ub)
	ci2 coord_pca_wb_`i' pca_wb_dist_10km, corr
	matrix A[1,2]=r(lb)
	matrix A[2,2]=r(ub)
	ci2 coord_pca_wb_`i' pca_wb_dist_20km, corr
	matrix A[1,3]=r(lb)
	matrix A[2,3]=r(ub)
	ci2 coord_pca_wb_`i' pca_wb_dist_30km, corr
	matrix A[1,4]=r(lb)
	matrix A[2,4]=r(ub)
	ci2 coord_pca_wb_`i' pca_wb_dist_40km, corr
	matrix A[1,5]=r(lb)
	matrix A[2,5]=r(ub)
	ci2 coord_pca_wb_`i' pca_wb_dist_50km, corr
	matrix A[1,6]=r(lb)
	matrix A[2,6]=r(ub)
	ci2 coord_pca_wb_`i' pca_wb_dist_75km, corr
	matrix A[1,7]=r(lb)
	matrix A[2,7]=r(ub)
	ci2 coord_pca_wb_`i' pca_wb_dist_100km, corr
	matrix A[1,8]=r(lb)
	matrix A[2,8]=r(ub)
	ci2 coord_pca_wb_`i' pca_wb_dist_200km, corr
	matrix A[1,9]=r(lb)
	matrix A[2,9]=r(ub)
	ci2 coord_pca_wb_`i' pca_wb_dist_above200km, corr
	matrix A[1,10]=r(lb)
	matrix A[2,10]=r(ub)
	matrix colnames A = pca_wb_dist_0km pca_wb_dist_10km pca_wb_dist_20km pca_wb_dist_30km ///
			pca_wb_dist_40km pca_wb_dist_50km pca_wb_dist_75km pca_wb_dist_100km pca_wb_dist_200km ///
			pca_wb_dist_above200km
	estadd matrix ci_corr=A
	
	drop pca_wb_dist_*
	
}
	
	
coefplot corr_pca1 || corr_pca2 || corr_pca3 || corr_pca4 || corr_pca5 || corr_pca6, ///
			rename(pca_wb_dist_0km=0 pca_wb_dist_10km=1-10 pca_wb_dist_20km=11-20 pca_wb_dist_30km=21-30 ///
			pca_wb_dist_40km=31-40 pca_wb_dist_50km=41-50 pca_wb_dist_75km=51-75 pca_wb_dist_100km=76-100 pca_wb_dist_200km=101-200 pca_wb_dist_above200km=201-) ///
			ytitle("Correlation") ///
			bylabels("PC 1" "PC 2" "PC 3" "PC 4" "PC 5" "PC 6") ///
			ylabel(0 (0.2) 0.8) yscale(range(0 0.8)) ///
			xtitle("Distance to sibling's birth location (km)") ///
			xlabel(, angle(45)) byopts(cols(3)) ///
			ci(ci_corr) cirecast(rspike) /// alternative: cirecast(rarea)
			vertical baselevels omitted  scheme(s1mono) recast(line) ///
			xsize(18cm) ysize(13cm) ///
			

graph export "${OUTPUT}/graphs/principal_components/pc_correlations_wb.png", replace width(2000)
graph export "${OUTPUT}/graphs/principal_components/pc_correlations_wb.pdf", replace


// Source data for graph:
esttab corr_pca1 corr_pca2 corr_pca3 corr_pca4 corr_pca5 corr_pca6 using "${OUTPUT}/graphs/principal_components/pc_correlations_wb_source_data.csv", replace ///
			cells((b(fmt(5)) ci_corr[1](fmt(5))  ci_corr[2](fmt(5)))) ///
			mlabel("PC 1" "PC 2" "PC 3" "PC 4" "PC 5" "PC 6") nonumbers noobs ///
			collabel("Correlation" "95% CI lower bound"  "95% CI upper bound" , lhs("Distance to sibling's birth location (km)")) ///
			coeflabel(pca_wb_dist_0km "0" pca_wb_dist_10km "1-10" pca_wb_dist_20km "11-20" ///
			pca_wb_dist_30km "21-30" pca_wb_dist_40km "31-40" pca_wb_dist_50km "41-50" ///
			pca_wb_dist_75km "51-75" pca_wb_dist_100km "76-100" pca_wb_dist_200km "101-200" /// 
			pca_wb_dist_above200km "201-")
			
