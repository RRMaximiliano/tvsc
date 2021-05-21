*** Globals
    // Path
    if "`c(username)'" == "ifyou" {
    	global project "D:/Documents/GitHub/tvsc"
    }
    
    global outputs  "${project}/outputs"
    global tables   "${outputs}/tables"

    // Tables
	global stars1	"label nolines nogaps fragment nomtitle nonumbers noobs nodep star(* 0.10 ** 0.05 *** 0.01) collabels(none) booktabs b(3) se(3)"

*** Load dataset
    sysuse census, clear 

*** Create treatment variable
    set seed 01237846
    gen random = uniform()
    gen treatment = (random > 0.5)
    drop random 

*** TvsC
    local   vars        ///
            divorce     ///
            marriage
        
        
    tvsc `vars', by(treatment) clus_id(region) strat_id(region)

*** Esttab
    // Only Treatment, Control, and Raw Differences
	esttab using "${tables}/t1.tex", replace ${stars1}		///
		cells("mu_2(fmt(%9.2fc)) mu_1(fmt(%9.2fc)) mu_3(fmt(%9.2fc))" "se_2(par) se_1(par) se_3(par)") 
  
*** Esttab
    // Only Treatment, Control, and Differences with Fixed Effects
	esttab using "${tables}/t2.tex", replace ${stars1}		///
		cells("mu_2(fmt(%9.2fc)) mu_1(fmt(%9.2fc)) mu_4(fmt(%9.2fc))" "se_2(par) se_1(par) se_4(par)") 	        
        
*** Esttab
    // Treatment, Control, Raw Diff, and Diff with FE
	esttab using "${tables}/t3.tex", replace ${stars1}		///    
		cells("mu_2(fmt(%9.2fc)) mu_1(fmt(%9.2fc)) mu_3(fmt(%9.2fc)) mu_4(fmt(%9.2fc))" "se_2(par) se_1(par) se_3(par) se_4(par)") 	               