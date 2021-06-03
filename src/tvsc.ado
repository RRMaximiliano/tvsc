*! version 0.0.2  20may2021	Roro
capture program drop tvsc

program tvsc, eclass
  syntax  varlist [aw pw fw] [if] [in], by(varname)     ///
            [                                           ///
              CLUS_id(varname numeric)                  ///
              STRAT_id(varname numeric)                 ///
              controls(varlist fv)                      ///
              LABels                                    ///
              SD                                        ///
            ]

  marksample 	touse
  markout 	`touse' `by'
  tempname 	mu_1 mu_2 mu_3 mu_4 mu_5 se_1 se_2 se_3 se_4 se_5 sd_1 sd_2     ///
            d_p d_p2 d_p3 N_C N_T N_S N_FE N_FE2 S_S S_FE S_FE2
      
  // Cluster local
  local vce 
  if "`clus_id'" != "" {
      local vce "vce(cluster `clus_id')"
  }

  // Strat (Fixed Effects)
  local strata "absorb(`strat_id')"
  if "`strat_id'" == "" {
      local strata ""
  }
   
  // Create comparison
  quietly {
    capture drop TD*
    tab `by' , gen(TD) 
    
    // Loop over variables to get the estimates
    foreach var of local varlist {
      // Differences between groups
      reg `var' TD1 TD2  [`weight' `exp'] `if', nocons `vce'
      mat `N_S' = nullmat(`N_S'), e(N)
      mat `S_S' = nullmat(`S_S'), e(N_clust)
      test (_b[TD1] - _b[TD2] == 0)
      mat `d_p'  = nullmat(`d_p'), r(p)
      matrix A = e(b)
      lincom (TD1 - TD2)

      mat `mu_3' = nullmat(`mu_3'), A[1,2]-A[1,1]
      mat `se_3' = nullmat(`se_3'), r(se)
          
      // Group 1
      sum `var' [`weight' `exp'] if TD1==1 & e(sample)==1
      mat `mu_1' = nullmat(`mu_1'),   r(mean)
      mat `se_1' = nullmat(`se_1'),   r(sd)/sqrt(r(N))
          mat `sd_1' = nullmat(`sd_1'),   r(sd)        
      mat `N_C'  = nullmat(`N_C'),    r(N)

      // Group 2
      sum `var' [`weight' `exp'] if TD2==1 & e(sample)==1
      mat `mu_2' = nullmat(`mu_2'),   r(mean)
      mat `se_2' = nullmat(`se_2'),   r(sd)/sqrt(r(N))
          mat `sd_2' = nullmat(`sd_2'),   r(sd)
      mat `N_T'  = nullmat(`N_T'),    r(N)
      
      if "`strat_id'" != "" & "`controls'" == "" {
        capture reghdfe `var' TD1 TD2 [`weight' `exp'] `if',  `vce' `strata'
              
        // Error if reghdfe is not found
        if (_rc == 199) {
            display as error  "You need to install the reghdfe and ftools commands to get the Fixed Effects estimates"
            display as error  "Run" _newline "ssc install reghdfe" _newline "ssc install ftools"
            exit
        }
              
        mat `N_FE' = nullmat(`N_FE'), e(N)
        mat `S_FE' = nullmat(`S_FE'), e(N_clust)
        test (_b[TD1]- _b[TD2]== 0)
        mat `d_p2'  = nullmat(`d_p2'),r(p)
        matrix A = e(b)
        lincom (TD1 - TD2)
        
        mat `mu_4' = nullmat(`mu_4'), A[1,2]-A[1,1]
        mat `se_4' = nullmat(`se_4'), r(se)
      }
    
      else if "`strat_id'" != "" & "`controls'" != "" {
        capture reghdfe `var' TD1 TD2 [`weight' `exp'] `if',  `vce' `strata'
        
        mat `N_FE' = nullmat(`N_FE'), e(N)
        mat `S_FE' = nullmat(`S_FE'), e(N_clust)
        test (_b[TD1]- _b[TD2]== 0)
        mat `d_p2'  = nullmat(`d_p2'),r(p)
        matrix A = e(b)
        lincom (TD1 - TD2)
        
        mat `mu_4' = nullmat(`mu_4'), A[1,2]-A[1,1]
        mat `se_4' = nullmat(`se_4'), r(se)
      
        capture reghdfe `var' TD1 TD2 `controls' [`weight' `exp'] `if',  `vce' `strata'
       
        mat `N_FE2' = nullmat(`N_FE2'), e(N)
        mat `S_FE2' = nullmat(`S_FE2'), e(N_clust)
        test (_b[TD1]- _b[TD2]== 0)
        mat `d_p3'  = nullmat(`d_p3'),r(p)
        matrix A = e(b)
        lincom (TD1 - TD2)

        mat `mu_5' = nullmat(`mu_5'), A[1,2]-A[1,1]
        mat `se_5' = nullmat(`se_5'), r(se)
      }   
    } 

    // Matrices to return with esttab
    if "`strat_id'" != "" & "`controls'" == "" {
      foreach mat in mu_1 mu_2 mu_3 mu_4 se_1 se_2 se_3 se_4 sd_1 sd_2 d_p d_p2 N_C N_T N_S N_FE S_S S_FE {
        mat coln ``mat'' = `varlist'
        eret mat `mat' = ``mat''
      }
    }
        
    else if "`strat_id'" != "" & "`controls'" != "" {
      foreach mat in mu_1 mu_2 mu_3 mu_4 mu_5 se_1 se_2 se_3 se_4 se_5 sd_1 sd_2 d_p d_p2 d_p3 N_C N_T N_S N_FE N_FE2 S_S S_FE S_FE2 {
        mat coln ``mat'' = `varlist'
        eret mat `mat' = ``mat''
      }
    }

    else {
      foreach mat in mu_1 mu_2 mu_3 se_1 se_2 se_3 sd_1 sd_2 d_p N_C N_T N_S S_S {
        mat coln ``mat'' = `varlist'
        eret mat `mat' = ``mat''
      }
    }
    
    drop TD*
  }
  
      
  // Display results
  local viz "nomtitle nonumbers noobs b(3) se(3)"
  if "`labels'" != "" {
      local viz "`viz' label"
  }

  if "`sd'" != "" {
      if "`strat_id'" != "" & "`controls'" == "" {
          esttab, `viz' collabels("Treatment" "Control" "Diff" "FE Diff") /// 
              cells("mu_2(fmt(%9.2fc)) mu_1(fmt(%9.2fc)) mu_3(fmt(%9.2fc)) mu_4(fmt(%9.2fc))" "sd_2(par) sd_1(par) se_3(par) se_4(par)") 
      }
      
      else if "`strat_id'" != "" & "`controls'" != "" {
          esttab, `viz' collabels("Treatment" "Control" "Diff" "FE Diff" "FE Diff Controls") /// 
              cells("mu_2(fmt(%9.2fc)) mu_1(fmt(%9.2fc)) mu_3(fmt(%9.2fc)) mu_4(fmt(%9.2fc)) mu_5(fmt(%9.2fc))" "sd_2(par) sd_1(par) se_3(par) se_4(par) se_5(par)") 
      }

      else {
          esttab, `viz' collabels("Treatment" "Control" "Difference") /// 
              cells("mu_2(fmt(%9.2fc)) mu_1(fmt(%9.2fc)) mu_3(fmt(%9.2fc))" "sd_2(par) sd_1(par) se_3(par)") 
      }
  }

  else {
      if "`strat_id'" != "" & "`controls'" == "" {
          esttab, `viz' collabels("Treatment" "Control" "Diff" "FE Diff") /// 
              cells("mu_2(fmt(%9.2fc)) mu_1(fmt(%9.2fc)) mu_3(fmt(%9.2fc)) mu_4(fmt(%9.2fc))" "se_2(par) se_1(par) se_3(par) se_4(par)") 
      }
      
      else if "`strat_id'" != "" & "`controls'" != "" {
          esttab, `viz' collabels("Treatment" "Control" "Diff" "FE Diff" "FE Diff Controls") /// 
              cells("mu_2(fmt(%9.2fc)) mu_1(fmt(%9.2fc)) mu_3(fmt(%9.2fc)) mu_4(fmt(%9.2fc)) mu_5(fmt(%9.2fc))" "se_2(par) se_1(par) se_3(par) se_4(par) se_5(par)") 
      }

      else {
          esttab, `viz' collabels("Treatment" "Control" "Difference") /// 
              cells("mu_2(fmt(%9.2fc)) mu_1(fmt(%9.2fc)) mu_3(fmt(%9.2fc))" "se_2(par) se_1(par) se_3(par)") 
      }        
  }
    
end



