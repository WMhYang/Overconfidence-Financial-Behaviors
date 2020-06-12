clear
set more off

* set directory
cd "C:/Users/Thinkpad/Perspective/Overconfidence-Financial-Behaviors/codes"

global data_dir "../data"
global outputs_dir "../outputs"
global tables_dir "${outputs_dir}/tables"
global figures_dir "${outputs_dir}/figures"
global logs_dir "${outputs_dir}/logs"

* capture log
cap log using "${logs_dir}/analysis_log.smcl", name(analysis_NFCS) text replace

* import data
import excel "${data_dir}/overconfidence_measure.xlsx", ///
	sheet("overconfidence_measure") firstrow
	
* count overconfident and not overconfident households in the learning set
count if overconfidence == 1
count if overconfidence == 0

* generate key variables
*** age
gen age2 = age^2
*** income
gen logincome = log(income)
gen logincome2 = logincome^2
*** financial literacy measure (measured by factor analysis score and normalized)
***** factor analysis
gen interest_q_c = interest_q == 1
gen inflation_q_c = inflation_q == 1
gen bond_q_c = bond_q == 1
gen mortgage_q_c = mortgage_q == 1
gen mutual_q_c = mutual_q == 1
factor *q_c, pcf
predict score
***** normalization
summ score
gen fin_lit = (score - r(min)) / (r(max) - r(min))

* summary statistics
estpost tabstat retire_dummy precaution_dummy fin_par_dummy female_dummy ///
	age nonwhite_dummy marital_dummy income high_school_dummy college_dummy ///
	fin_lit overconfidence_* ///
	[aw=weights], statistics(p10 p50 p90 mean sd N) columns(statistics)

estout using "${tables_dir}/sum_stat.tex", ///
	cells("p10 p50 p90 mean(fmt(a3)) sd(fmt(a3)) count(label(#Obs.))") ///
	varlabels(`e(var)') sty(tex) replace

local household_X "age age2 logincome logincome2 female_dummy nonwhite_dummy marital_dummy high_school_dummy college_dummy"

* baseline regressions with svm
*** retirement readiness
***** without state dummies
logit retire_dummy overconfidence_svm fin_lit `household_X' i.year [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_svm fin_lit) post
outreg2 using "${tables_dir}/SVM.tex", tex replace addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, No) ///
	ctitle("Readiness")

***** with state dummies
logit retire_dummy overconfidence_svm fin_lit `household_X' i.year i.state_cate [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_svm fin_lit) post
outreg2 using "${tables_dir}/SVM.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Readiness")
	
*** precautionary saving
***** without state dummies
logit precaution_dummy overconfidence_svm fin_lit `household_X' i.year [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_svm fin_lit) post
outreg2 using "${tables_dir}/SVM.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, No) ///
	ctitle("Precaution")

***** with state dummies
logit precaution_dummy overconfidence_svm fin_lit `household_X' i.year i.state_cate [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_svm fin_lit) post
outreg2 using "${tables_dir}/SVM.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Precaution")
	
*** financial market participation
***** without state dummies
logit fin_par_dummy overconfidence_svm fin_lit `household_X' i.year [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_svm fin_lit) post
outreg2 using "${tables_dir}/SVM.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, No) ///
	ctitle("Participation")

***** with state dummies
logit fin_par_dummy overconfidence_svm fin_lit `household_X' i.year i.state_cate [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_svm fin_lit) post
outreg2 using "${tables_dir}/SVM.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Participation")

* baseline regressions with forest
*** retirement readiness
***** without state dummies
logit retire_dummy overconfidence_forest fin_lit `household_X' i.year [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_forest fin_lit) post
outreg2 using "${tables_dir}/Forest.tex", tex replace addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, No) ///
	ctitle("Readiness")

***** with state dummies
logit retire_dummy overconfidence_forest fin_lit `household_X' i.year i.state_cate [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_forest fin_lit) post
outreg2 using "${tables_dir}/Forest.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Readiness")
	
*** precautionary saving
***** without state dummies
logit precaution_dummy overconfidence_forest fin_lit `household_X' i.year [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_forest fin_lit) post
outreg2 using "${tables_dir}/Forest.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, No) ///
	ctitle("Precaution")

***** with state dummies
logit precaution_dummy overconfidence_forest fin_lit `household_X' i.year i.state_cate [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_forest fin_lit) post
outreg2 using "${tables_dir}/Forest.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Precaution")
	
*** financial market participation
***** without state dummies
logit fin_par_dummy overconfidence_forest fin_lit `household_X' i.year [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_forest fin_lit) post
outreg2 using "${tables_dir}/Forest.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, No) ///
	ctitle("Participation")

***** with state dummies
logit fin_par_dummy overconfidence_forest fin_lit `household_X' i.year i.state_cate [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_forest fin_lit) post
outreg2 using "${tables_dir}/Forest.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Participation")
	
* baseline regressions with logistic
*** retirement readiness
***** without state dummies
logit retire_dummy overconfidence_logit fin_lit `household_X' i.year [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_logit fin_lit) post
outreg2 using "${tables_dir}/Logit.tex", tex replace addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, No) ///
	ctitle("Readiness")

***** with state dummies
logit retire_dummy overconfidence_logit fin_lit `household_X' i.year i.state_cate [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_logit fin_lit) post
outreg2 using "${tables_dir}/Logit.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Readiness")
	
*** precautionary saving
***** without state dummies
logit precaution_dummy overconfidence_logit fin_lit `household_X' i.year [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_logit fin_lit) post
outreg2 using "${tables_dir}/Logit.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, No) ///
	ctitle("Precaution")

***** with state dummies
logit precaution_dummy overconfidence_logit fin_lit `household_X' i.year i.state_cate [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_logit fin_lit) post
outreg2 using "${tables_dir}/Logit.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Precaution")
	
*** financial market participation
***** without state dummies
logit fin_par_dummy overconfidence_logit fin_lit `household_X' i.year [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_logit fin_lit) post
outreg2 using "${tables_dir}/Logit.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, No) ///
	ctitle("Participation")

***** with state dummies
logit fin_par_dummy overconfidence_logit fin_lit `household_X' i.year i.state_cate [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_logit fin_lit) post
outreg2 using "${tables_dir}/Logit.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Participation")
	
* baseline regressions with Bernoulli NB
*** retirement readiness
***** without state dummies
logit retire_dummy overconfidence_bnb fin_lit `household_X' i.year [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_bnb fin_lit) post
outreg2 using "${tables_dir}/BNB.tex", tex replace addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, No) ///
	ctitle("Readiness")

***** with state dummies
logit retire_dummy overconfidence_bnb fin_lit `household_X' i.year i.state_cate [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_bnb fin_lit) post
outreg2 using "${tables_dir}/BNB.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Readiness")
	
*** precautionary saving
***** without state dummies
logit precaution_dummy overconfidence_bnb fin_lit `household_X' i.year [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_bnb fin_lit) post
outreg2 using "${tables_dir}/BNB.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, No) ///
	ctitle("Precaution")

***** with state dummies
logit precaution_dummy overconfidence_bnb fin_lit `household_X' i.year i.state_cate [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_bnb fin_lit) post
outreg2 using "${tables_dir}/BNB.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Precaution")
	
*** financial market participation
***** without state dummies
logit fin_par_dummy overconfidence_bnb fin_lit `household_X' i.year [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_bnb fin_lit) post
outreg2 using "${tables_dir}/BNB.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, No) ///
	ctitle("Participation")

***** with state dummies
logit fin_par_dummy overconfidence_bnb fin_lit `household_X' i.year i.state_cate [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_bnb fin_lit) post
outreg2 using "${tables_dir}/BNB.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Participation")

* baseline regressions with KNN
*** retirement readiness
***** without state dummies
logit retire_dummy overconfidence_knn fin_lit `household_X' i.year [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_knn fin_lit) post
outreg2 using "${tables_dir}/KNN.tex", tex replace addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, No) ///
	ctitle("Readiness")

***** with state dummies
logit retire_dummy overconfidence_knn fin_lit `household_X' i.year i.state_cate [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_knn fin_lit) post
outreg2 using "${tables_dir}/KNN.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Readiness")
	
*** precautionary saving
***** without state dummies
logit precaution_dummy overconfidence_knn fin_lit `household_X' i.year [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_knn fin_lit) post
outreg2 using "${tables_dir}/KNN.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, No) ///
	ctitle("Precaution")

***** with state dummies
logit precaution_dummy overconfidence_knn fin_lit `household_X' i.year i.state_cate [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_knn fin_lit) post
outreg2 using "${tables_dir}/KNN.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Precaution")
	
*** financial market participation
***** without state dummies
logit fin_par_dummy overconfidence_knn fin_lit `household_X' i.year [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_knn fin_lit) post
outreg2 using "${tables_dir}/KNN.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, No) ///
	ctitle("Participation")

***** with state dummies
logit fin_par_dummy overconfidence_knn fin_lit `household_X' i.year i.state_cate [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_knn fin_lit) post
outreg2 using "${tables_dir}/KNN.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Participation")

* baseline regressions with MLP
*** retirement readiness
***** without state dummies
logit retire_dummy overconfidence_mlp fin_lit `household_X' i.year [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_mlp fin_lit) post
outreg2 using "${tables_dir}/MLP.tex", tex replace addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, No) ///
	ctitle("Readiness")

***** with state dummies
logit retire_dummy overconfidence_mlp fin_lit `household_X' i.year i.state_cate [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_mlp fin_lit) post
outreg2 using "${tables_dir}/MLP.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Readiness")
	
*** precautionary saving
***** without state dummies
logit precaution_dummy overconfidence_mlp fin_lit `household_X' i.year [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_mlp fin_lit) post
outreg2 using "${tables_dir}/MLP.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, No) ///
	ctitle("Precaution")

***** with state dummies
logit precaution_dummy overconfidence_mlp fin_lit `household_X' i.year i.state_cate [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_mlp fin_lit) post
outreg2 using "${tables_dir}/MLP.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Precaution")
	
*** financial market participation
***** without state dummies
logit fin_par_dummy overconfidence_mlp fin_lit `household_X' i.year [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_mlp fin_lit) post
outreg2 using "${tables_dir}/MLP.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, No) ///
	ctitle("Participation")

***** with state dummies
logit fin_par_dummy overconfidence_mlp fin_lit `household_X' i.year i.state_cate [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_mlp fin_lit) post
outreg2 using "${tables_dir}/MLP.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Participation")
	
* generate financial literacy indicators and intersactions
summ fin_lit, d
gen fin_low_dummy = fin_lit == 0
gen fin_high_dummy = fin_lit == 1

local household_X "age age2 logincome logincome2 female_dummy nonwhite_dummy marital_dummy high_school_dummy college_dummy"
* heterogeneous effects with SVM
*** retirement readiness
***** without state dummies
logit retire_dummy overconfidence_svm `household_X' ///
	i.year i.state_cate if fin_low_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_svm) post
outreg2 using "${tables_dir}/SVM_het.tex", tex replace addstat(Pseudo R-squared, r2) ///
	addtext(Sample, Low Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Readiness")

***** with state dummies
logit retire_dummy overconfidence_svm `household_X' ///
	i.year i.state_cate if fin_high_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_svm) post
outreg2 using "${tables_dir}/SVM_het.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Sample, High Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Readiness")
	
*** precautionary saving
***** low true literacy subgroup
logit precaution_dummy overconfidence_svm `household_X' ///
	i.year i.state_cate if fin_low_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_svm) post
outreg2 using "${tables_dir}/SVM_het.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Sample, Low Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Precaution")

***** high true literacy subgroup
logit precaution_dummy overconfidence_svm `household_X' ///
	i.year i.state_cate if fin_high_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_svm) post
outreg2 using "${tables_dir}/SVM_het.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Sample, High Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Precaution")
	
*** financial market participation
***** low true literacy subgroup
logit fin_par_dummy overconfidence_svm `household_X' ///
	i.year i.state_cate if fin_low_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_svm) post
outreg2 using "${tables_dir}/SVM_het.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Sample, Low Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Participation")

***** high true literacy subgroup
logit fin_par_dummy overconfidence_svm `household_X' ///
	i.year i.state_cate if fin_high_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_svm) post
outreg2 using "${tables_dir}/SVM_het.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Sample, High Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Participation")

* heterogeneous effects with random forest
*** retirement readiness
***** without state dummies
logit retire_dummy overconfidence_forest `household_X' ///
	i.year i.state_cate if fin_low_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_forest) post
outreg2 using "${tables_dir}/Forest_het.tex", tex replace addstat(Pseudo R-squared, r2) ///
	addtext(Sample, Low Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Readiness")

***** with state dummies
logit retire_dummy overconfidence_forest `household_X' ///
	i.year i.state_cate if fin_high_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_forest) post
outreg2 using "${tables_dir}/Forest_het.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Sample, High Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Readiness")
	
*** precautionary saving
***** low true literacy subgroup
logit precaution_dummy overconfidence_forest `household_X' ///
	i.year i.state_cate if fin_low_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_forest) post
outreg2 using "${tables_dir}/Forest_het.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Sample, Low Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Precaution")

***** high true literacy subgroup
logit precaution_dummy overconfidence_forest `household_X' ///
	i.year i.state_cate if fin_high_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_forest) post
outreg2 using "${tables_dir}/Forest_het.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Sample, High Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Precaution")
	
*** financial market participation
***** low true literacy subgroup
logit fin_par_dummy overconfidence_forest `household_X' ///
	i.year i.state_cate if fin_low_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_forest) post
outreg2 using "${tables_dir}/Forest_het.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Sample, Low Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Participation")

***** high true literacy subgroup
logit fin_par_dummy overconfidence_forest `household_X' ///
	i.year i.state_cate if fin_high_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_forest) post
outreg2 using "${tables_dir}/Forest_het.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Sample, High Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Participation")

* heterogeneous effects with logistic
*** retirement readiness
***** without state dummies
logit retire_dummy overconfidence_logit `household_X' ///
	i.year i.state_cate if fin_low_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_logit) post
outreg2 using "${tables_dir}/Logit_het.tex", tex replace addstat(Pseudo R-squared, r2) ///
	addtext(Sample, Low Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Readiness")

***** with state dummies
logit retire_dummy overconfidence_logit `household_X' ///
	i.year i.state_cate if fin_high_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_logit) post
outreg2 using "${tables_dir}/Logit_het.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Sample, High Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Readiness")
	
*** precautionary saving
***** low true literacy subgroup
logit precaution_dummy overconfidence_logit `household_X' ///
	i.year i.state_cate if fin_low_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_logit) post
outreg2 using "${tables_dir}/Logit_het.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Sample, Low Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Precaution")

***** high true literacy subgroup
logit precaution_dummy overconfidence_logit `household_X' ///
	i.year i.state_cate if fin_high_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_logit) post
outreg2 using "${tables_dir}/Logit_het.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Sample, High Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Precaution")
	
*** financial market participation
***** low true literacy subgroup
logit fin_par_dummy overconfidence_logit `household_X' ///
	i.year i.state_cate if fin_low_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_logit) post
outreg2 using "${tables_dir}/Logit_het.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Sample, Low Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Participation")

***** high true literacy subgroup
logit fin_par_dummy overconfidence_logit `household_X' ///
	i.year i.state_cate if fin_high_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_logit) post
outreg2 using "${tables_dir}/Logit_het.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Sample, High Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Participation")	
	
* heterogeneous effects with Bernoulli NB
*** retirement readiness
***** without state dummies
logit retire_dummy overconfidence_bnb `household_X' ///
	i.year i.state_cate if fin_low_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_bnb) post
outreg2 using "${tables_dir}/BNB_het.tex", tex replace addstat(Pseudo R-squared, r2) ///
	addtext(Sample, Low Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Readiness")

***** with state dummies
logit retire_dummy overconfidence_bnb `household_X' ///
	i.year i.state_cate if fin_high_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_bnb) post
outreg2 using "${tables_dir}/BNB_het.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Sample, High Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Readiness")
	
*** precautionary saving
***** low true literacy subgroup
logit precaution_dummy overconfidence_bnb `household_X' ///
	i.year i.state_cate if fin_low_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_bnb) post
outreg2 using "${tables_dir}/BNB_het.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Sample, Low Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Precaution")

***** high true literacy subgroup
logit precaution_dummy overconfidence_bnb `household_X' ///
	i.year i.state_cate if fin_high_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_bnb) post
outreg2 using "${tables_dir}/BNB_het.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Sample, High Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Precaution")
	
*** financial market participation
***** low true literacy subgroup
logit fin_par_dummy overconfidence_bnb `household_X' ///
	i.year i.state_cate if fin_low_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_bnb) post
outreg2 using "${tables_dir}/BNB_het.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Sample, Low Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Participation")

***** high true literacy subgroup
logit fin_par_dummy overconfidence_bnb `household_X' ///
	i.year i.state_cate if fin_high_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_bnb) post
outreg2 using "${tables_dir}/BNB_het.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Sample, High Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Participation")
	
* heterogeneous effects with KNN
*** retirement readiness
***** without state dummies
logit retire_dummy overconfidence_knn `household_X' ///
	i.year i.state_cate if fin_low_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_knn) post
outreg2 using "${tables_dir}/KNN_het.tex", tex replace addstat(Pseudo R-squared, r2) ///
	addtext(Sample, Low Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Readiness")

***** with state dummies
logit retire_dummy overconfidence_knn `household_X' ///
	i.year i.state_cate if fin_high_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_knn) post
outreg2 using "${tables_dir}/KNN_het.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Sample, High Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Readiness")
	
*** precautionary saving
***** low true literacy subgroup
logit precaution_dummy overconfidence_knn `household_X' ///
	i.year i.state_cate if fin_low_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_knn) post
outreg2 using "${tables_dir}/KNN_het.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Sample, Low Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Precaution")

***** high true literacy subgroup
logit precaution_dummy overconfidence_knn `household_X' ///
	i.year i.state_cate if fin_high_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_knn) post
outreg2 using "${tables_dir}/KNN_het.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Sample, High Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Precaution")
	
*** financial market participation
***** low true literacy subgroup
logit fin_par_dummy overconfidence_knn `household_X' ///
	i.year i.state_cate if fin_low_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_knn) post
outreg2 using "${tables_dir}/KNN_het.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Sample, Low Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Participation")

***** high true literacy subgroup
logit fin_par_dummy overconfidence_knn `household_X' ///
	i.year i.state_cate if fin_high_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_knn) post
outreg2 using "${tables_dir}/KNN_het.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Sample, High Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Participation")
	
* heterogeneous effects with MLP
*** retirement readiness
***** without state dummies
logit retire_dummy overconfidence_mlp `household_X' ///
	i.year i.state_cate if fin_low_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_mlp) post
outreg2 using "${tables_dir}/MLP_het.tex", tex replace addstat(Pseudo R-squared, r2) ///
	addtext(Sample, Low Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Readiness")

***** with state dummies
logit retire_dummy overconfidence_mlp `household_X' ///
	i.year i.state_cate if fin_high_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_mlp) post
outreg2 using "${tables_dir}/MLP_het.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Sample, High Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Readiness")
	
*** precautionary saving
***** low true literacy subgroup
logit precaution_dummy overconfidence_mlp `household_X' ///
	i.year i.state_cate if fin_low_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_mlp) post
outreg2 using "${tables_dir}/MLP_het.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Sample, Low Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Precaution")

***** high true literacy subgroup
logit precaution_dummy overconfidence_mlp `household_X' ///
	i.year i.state_cate if fin_high_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_mlp) post
outreg2 using "${tables_dir}/MLP_het.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Sample, High Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Precaution")
	
*** financial market participation
***** low true literacy subgroup
logit fin_par_dummy overconfidence_mlp `household_X' ///
	i.year i.state_cate if fin_low_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_mlp) post
outreg2 using "${tables_dir}/MLP_het.tex", tex append addstat(Pseudo R-squared, r2) ///
	addtext(Sample, Low Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Participation")

***** high true literacy subgroup
logit fin_par_dummy overconfidence_mlp `household_X' ///
	i.year i.state_cate if fin_high_dummy == 1 [pw=weights]
scalar r2 = e(r2_p)
margins, dydx(overconfidence_mlp) post
outreg2 using "${tables_dir}/MLP_het.tex", tex word append addstat(Pseudo R-squared, r2) ///
	addtext(Sample, High Lit., Demo. chars., Yes, Year dummies, Yes, State dummies, Yes) ///
	ctitle("Participation")

* stop capturing log and translate into pdf
log close analysis_NFCS
translate "${logs_dir}/analysis_log.smcl"  "${logs_dir}/analysis_log.pdf", ///
	translator(smcl2pdf) replace

