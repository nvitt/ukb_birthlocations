***************************************************************************

clear
est clear
set matsize 11000



******User
global DRIVE 	"//rdsfcifs.acrc.bris.ac.uk/GeneEnvironment_Interactions/UKB/"
global OUTPUT	"C:/Users/pk20062/Dropbox/DONNI - UKB birth location accuracy/"







*** Convert region shapefile to Stata file:
shp2dta using "${DRIVE}GeographicID/Shapefiles/Regions1945.shp", database("${OUTPUT}gis_data/historical_regions/1945_regions_GB_db") coordinates("${OUTPUT}gis_data/historical_regions/1945_regions_GB_coord") replace


*** Load sibling birth location dataset:
use "${DRIVE}GeographicID/Projects/NV_Papers/Birth locations/dta/sibling_birth_location_data.dta", clear






********************************************
*** Comparison across historical regions ***
********************************************

*** Use both siblings as observations (since they may have given different regions):
xtset
replace district_different = F.district_different if sibling_id==1
replace age_gap = F.age_gap if sibling_id==1




*** Different birth district:
* Estimate p separately for each region - but impose a single q for all:
reg district_different ibn.hist_rid age_gap, nocons cluster(family_id)
est store different_district_byregion

levelsof hist_rid if e(sample), local(counties)
local num: list sizeof local(counties)

matrix p_district_byregion = J(`num',5,.)
matrix colnames p_district_byregion = hist_rid p se ci_ll ci_ul

local j=1
foreach id in `counties' {
	qui nlcom (1-sqrt(1-_b[`id'.hist_rid]))
	matrix p_district_byregion[`j',1]=`id'
	matrix p_district_byregion[`j',2]=r(table)[1..2,1]'
	matrix p_district_byregion[`j',4]=r(table)[5..6,1]'
	local j=`j'+1
}
matlist p_district_byregion


// Get mapping from region IDs to region names:
preserve

keep hist_rid historical_region
duplicates drop

tempfile regions
save "`regions'"

restore


* Plot:
preserve
clear
svmat p_district_byregion, names(col)
format p %12.3f

// save source data:
merge m:1 hist_rid using "`regions'"
drop _merge
order historical_region p ci_ll ci_ul
sort historical_region
export delimited historical_region p ci_ll ci_ul using "${OUTPUT}/output/graphs/by_region/p_district_byregion_source_data.csv", replace

// merge map IDs:
rename hist_rid G_UNIT
merge 1:1 G_UNIT using "${OUTPUT}gis_data/historical_regions/1945_regions_GB_db.dta"

// map:
spmap p if G_UNIT!=8  using "${OUTPUT}gis_data/historical_regions/1945_regions_GB_coord.dta", ///
	id(_ID) clmethod(custom) clbreaks(0.1 0.15 0.2 0.25 0.3 0.35)  ///
	fcolor(Reds) ndfcolor(gs12) ///
	legend(pos(2) ring(1) region(lcolor(black) lwidth(thin)) title("{bf:Estimate of p}", size(small))) ///
	ysize(10) xsize(8)
gr_edit .legend.xoffset = -5
gr_edit .legend.yoffset = -5

graph export "${OUTPUT}/output/graphs/by_region/p_district_byregion.png", width(2000) replace
graph export "${OUTPUT}/output/graphs/by_region/p_district_byregion.pdf", replace

restore
