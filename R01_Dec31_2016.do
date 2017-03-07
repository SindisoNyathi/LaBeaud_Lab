/**************************************************************
++ survival for hcc only
+++ prevalence/incidence only for aic
+++ #kids by number of visits
++ -longitudinal nature of data- survival analysis- done by visit. do it by date
rain data- add the data from dan
 -sensisitivty by site (west vs coast)- done. put in tables and add the fever/igg lagged and igm/igg lagged
 -prnt n = 200. check the sensitivity analysis
 -rdt ns1+/+igm =+. compare that to stfd igg incidence.- done. add to tables
 -pcr + copmared to igg at next visit (ab/bc/cd)- done add to tables. 
 
 set graphics on

dropmiss, force
dropmiss, force
dropmiss, force
dropmiss, force
dropmiss, force
save appended_september20.dta, replace
			replace studyid_a =lower(studyid_a)
	
	gen dupkey = "dup" if dup2 >1
	*gen begindate = datesamplecollected_a if datesamplecollected_a !=.
		
	*/	
rename visit VISIT
drop if dup>1
drop dup


drop if dup_visit >1

drop if visit ==2 
drop if visit >4
save lab, replace

use all_interviews.dta, clear
drop visit
encode id_visit, gen(visit)
*replace visit = visit +1
*replace visit = visit -1 if visit ==2
save all_interviews.dta, replace
drop v18 v19 v20
merge 1:1 id_wide visit using lab.dta
drop _merge



		keep studyid  id_wide site visit antigenused_ city Stanford_CHIKV_IGG cohort gender datesamplecollected_ dob  agemonths childage age2 gender  Stanford_CHIK~G Stanford_DENV~G visit datesamplecol~_ 

rename denvpcr_ pcr_denv
rename chikvpcr_ pcr_chikv
rename denvigg_ igg_kenya_denv
rename chikvigg_ igg_kenya_chikv
rename dengue_igg_sammy igg_sammy_denv

foreach var in igg_kenya_chikv igg_kenya_denv pcr_chikv pcr_denv igg_sammy_denv{
capture drop dos`var'
encode `var', gen(dos`var')
drop `var'
rename dos`var' `var' 
}
replace igg_kenya_chikv = . if igg_kenya_chikv<402
replace igg_kenya_chikv = . if igg_kenya_chikv==403|igg_kenya_chikv == 404|igg_kenya_chikv == 405| igg_kenya_chikv == 406
replace igg_kenya_chikv = 408 if igg_kenya_chikv==409



save  prevalent, replace

preserve
collapse (sum) Stanford_CHIKV_IGG Stanford_DENV_IGG, by(id_wide city)
gen denvexposed = . 
gen chikvexposed = . 
bysort id_wide: replace chikvexposed = 1 if Stanford_CHIKV_IGG >0 &Stanford_CHIKV_IGG<.
bysort id_wide: replace denvexposed  = 1 if Stanford_DENV_IGG >0 & Stanford_DENV_IGG<.
tab chikvexposed city, m
tab denvexposed city, m
restore
stop

*keep if Stanford_DENV_IGG!=.
*export excel using "/Users/amykrystosik/Box Sync/DENV CHIKV project/Personalized Datasets/Amy/CSVs nov216/prevalentchikv", firstrow(variables) replace
		
		replace city = "Msambweni" if city =="Milani" | city =="Nganja"
		

	
	foreach failvar of varlist Stanford_* pcr_denv igg_*{
	
						keep if cohort ==2
					
				if r(N_fail) > 0{
				display "number of failure events = "r(N_fail)							
				
				
						}
			restore
			

			preserve				
														di missing(`failvar')
														di `failvar'
							egen axis = axis(visit)
							di missing(`failvar')
							di `failvar'
			
				}	
					
										**********survival***************				
						
					
				if r(N_fail) > 0{
				display "number of failure events = "r(N_fail)							
				

			preserve 
		
														di missing(`failvar')
														di `failvar'
													di missing(`failvar')
														di `failvar'
			else {
				}		
							}	
			}