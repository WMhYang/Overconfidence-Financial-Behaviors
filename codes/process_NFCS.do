clear
set more off

* set directory
cd "C:/Users/Thinkpad/Perspective/Overconfidence-Financial-Behaviors/codes"

global data_dir "../data"
global outputs_dir "../outputs"
global tables_dir "${outputs_dir}/tables"
global figures_dir "${outputs_dir}/figures"
global logs_dir "${outputs_dir}/logs"


* capture logs
cap log using "${logs_dir}/process_log.smcl", name(process_NFCS) text replace


* import 2012 data
import delimited "${data_dir}/NFCS 2012 State Data 130503.csv", ///
	case(preserve) clear

* keep only id and education since education is missing in the tracking data
keep ID A5_2012
save "${data_dir}/merge_2012.dta", replace

* import 2018 tracking data
import delimited "${data_dir}/NFCS 2018 State Tracking Data 190623.csv", ///
	case(preserve) clear

* year
gen year = TRACK
drop if year == 2009 // drop 2009 data because education cannot be merged

* national weight
gen weights = wgt_n2

* state
gen state_cate = STATEQ
tab state_cate, gen(state_dummy_)

* census division and region (for re-weighting)
gen cen_div_cate = CENSUSDIV
gen cen_reg_cate = CENSUSREG

* age (group mean)
gen age_cate = A3Ar_w
gen age = 20 if age_cate == 1
replace age = 30 if age_cate == 2
replace age = 40 if age_cate == 3
replace age = 50 if age_cate == 4
replace age = 60 if age_cate == 5
replace age = 70 if age_cate == 6

* gender
gen female_dummy = A3 == 2

* age/gender
gen age_gender_cate = A3B

* race
gen nonwhite_dummy = A4A_new_w == 2

* marital status
gen marital_dummy = A6 == 1

* education
*** merge with 2012 data
merge 1:1 ID using "${data_dir}/merge_2012.dta", keep(1 3) nogen
*** generate a new variable to unite different codings
gen educ_cate = 1 if A5_2015 == 1 | A5_2012 == 1
replace educ_cate = 2 if A5_2015 == 2 | A5_2012 == 2
replace educ_cate = 3 if A5_2015 == 3 | A5_2012 == 3
replace educ_cate = 4 if A5_2015 == 4 | A5_2012 == 4
replace educ_cate = 5 if A5_2015 == 5 | A5_2015 == 6 | A5_2012 == 5
replace educ_cate = 6 if A5_2015 == 7 | A5_2012 == 6
*** generate high school, college, and graduate dummy
gen high_school_dummy = 0 if educ_cate == 1
replace high_school_dummy = 1 if educ_cate > 1 & educ_cate < 7
gen college_dummy = 0 if educ_cate < 5
replace college_dummy = 1 if educ_cate > 4 & educ_cate < 7
gen graduate_dummy = 0 if educ_cate < 6
replace graduate_dummy = 1 if educ_cate == 6

* income (group mean)
gen income_cate = A8
gen income = 7500 if income_cate == 1
replace income = 20000 if income_cate == 2
replace income = 30000 if income_cate == 3
replace income = 42500 if income_cate == 4
replace income = 62500 if income_cate == 5
replace income = 87500 if income_cate == 6
replace income = 125000 if income_cate == 7
replace income = 200000 if income_cate == 8

* precautionary saving (treat DK and Refused as do not have precautionary saving)
gen precaution_dummy = J5 == 1

* retirement plan
destring(J8), replace
gen retire_young_dummy = J8 == 1
destring(J9), replace
gen retire_old_dummy = J9 == 1
gen retire_dummy = retire_young_dummy
replace retire_dummy = retire_old_dummy if retire_young_dummy == .

* financial market participation (treat missing as do not participate)
destring(B14), replace
gen fin_par_dummy = B14 == 1
replace fin_par_dummy = 0 if B14 == .

* perceived financial literacy (treat DK and Refused as neutrual)
gen math_perceived_cate = M1_2 if M1_2 != 98 & M1_2 != 99
replace math_perceived_cate = 4 if M1_2 == 98 | M1_2 == 99
gen fin_perceived_cate = M4 if M4 != 98 & M4 != 99
replace fin_perceived_cate = 4 if M4 == 98 | M4 == 99

* true financial literacy (1 - correct; 2 - DK/Refused; 3 - incorrect)
*** interest rate question
gen interest_q = 1 if M6 == 1
replace interest_q = 2 if M6 == 98 | M6 == 99
replace interest_q = 3 if M6 == 2 | M6 == 3
*** inflation question
gen inflation_q = 1 if M7 == 3
replace inflation_q = 2 if M7 == 98 | M7 == 99
replace inflation_q = 3 if M7 == 1 | M7 == 2
*** bond price question
gen bond_q = 1 if M8 == 2 
replace bond_q = 2 if M8 == 98 | M8 == 99
replace bond_q = 3 if M8 == 1 | M8 == 3 | M8 == 4
/*
*** compounded interest rate question
gen compound_q = 1 if M31 == 2
replace compound_q = 2 if M31 == 98 | M31 == 99
replace compound_q = 3 if M31 == 1 | M31 == 3 | M31 == 4
*/
*** mortgage question
gen mortgage_q = 1 if M9 == 1
replace mortgage_q = 2 if M9 == 98 | M9 == 99
replace mortgage_q = 3 if M9 == 2
*** mutual funds question
gen mutual_q = 1 if M10 == 2
replace mutual_q = 2 if M10 == 98 | M10 == 99
replace mutual_q = 3 if M10 == 1

* summary statistics
summ age female_dummy nonwhite_dummy marital_dummy high_school_dummy ///
	college_dummy graduate_dummy income precaution_dummy retire_dummy ///
	fin_par_dummy math_perceived_cate fin_perceived_cate interest_q inflation_q ///
	bond_q mortgage_q mutual_q [aw = weights]
	
* export data
keep year ID weights state_cate state_dummy_* cen_div_cate cen_reg_cate ///
	age_cate age female_dummy age_gender_cate nonwhite_dummy marital_dummy ///
	educ_cate high_school_dummy college_dummy graduate_dummy ///
	income_cate income precaution_dummy retire_dummy fin_par_dummy ///
	math_perceived_cate fin_perceived_cate interest_q ///
	inflation_q bond_q mortgage_q mutual_q

export delimited using "${data_dir}/processed_NFCS.csv", nolabel replace

* stop capturing log and translate into pdf
log close process_NFCS
translate "${logs_dir}/process_log.smcl"  "${logs_dir}/process_log.pdf", ///
	translator(smcl2pdf) replace
