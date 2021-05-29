**tvsc - Treatment vs Control groups means and differences**
=====

## Description

`tvsc` is a command that generates balance tables. The command tests for statistically significant difference between the categories defined in the `by(varname)`. It uses `reghdfe` to estimates the differences with fixed effects.

## Install

```stata
net install tvsc, from("https://raw.githubusercontent.com/rrmaximiliano/tvsc/main") replace
```

## Usage

Let's first generate a treatment variable using the `census` dataset.

```stata
*** Load dataset
    sysuse census, clear 

*** Create treatment variable
    set seed 01237846
    gen treatment = (runiform()<.5)
```

### Example 1: Raw differences with standard errors for treatment, control, and differences


```stata
. tvsc divorce marriage, by(treatment)

---------------------------------------------------
                Treatment      Control   Difference
---------------------------------------------------
divorce         18,379.07    30,425.36    -12046.29
               (2,630.31)   (7,183.07)   (7,011.02)
marriage        40,064.50    57,421.09    -17356.59
               (6,472.19)  (11,808.47)  (12,747.12)
---------------------------------------------------
```

### Example 2: Raw differences with standard deviations for treatment, control, and standard errors for differences

```stata
. tvsc divorce marriage, by(treatment) sd

---------------------------------------------------
                Treatment      Control   Difference
---------------------------------------------------
divorce         18,379.07    30,425.36    -12046.29
              (13,918.27)  (33,691.57)   (7,011.02)
marriage        40,064.50    57,421.09    -17356.59
              (34,247.63)  (55,386.64)  (12,747.12)
---------------------------------------------------
```

### Example 3: Differences with clustered standard errors

```stata
. tvsc divorce marriage, by(treatment) clus_id(region)

---------------------------------------------------
                Treatment      Control   Difference
---------------------------------------------------
divorce         18,379.07    30,425.36    -12046.29
               (2,630.31)   (7,183.07)   (7,374.89)
marriage        40,064.50    57,421.09    -17356.59
               (6,472.19)  (11,808.47)  (11,261.94)
---------------------------------------------------
```

### Example 4: Same as example 3 plus differences with fixed effects

```stata
. tvsc divorce marriage, by(treatment) clus_id(region) strat_id(region)

----------------------------------------------------------------
                Treatment      Control         Diff      FE Diff
----------------------------------------------------------------
divorce         18,379.07    30,425.36    -12046.29    -13692.48
               (2,630.31)   (7,183.07)   (7,374.89)   (8,755.31)
marriage        40,064.50    57,421.09    -17356.59    -20555.04
               (6,472.19)  (11,808.47)  (11,261.94)  (12,263.35)
----------------------------------------------------------------
```

### Example 5: Same as example 4 plus labels

```stata
. tvsc divorce marriage, by(treatment) clus_id(region) strat_id(region) labels

------------------------------------------------------------------------
                        Treatment      Control         Diff      FE Diff
------------------------------------------------------------------------
Number of divorces      18,379.07    30,425.36    -12046.29    -13692.48
                       (2,630.31)   (7,183.07)   (7,374.89)   (8,755.31)
Number of marriages     40,064.50    57,421.09    -17356.59    -20555.04
                       (6,472.19)  (11,808.47)  (11,261.94)  (12,263.35)
------------------------------------------------------------------------
```

## Exporting

`tvsc` does not have a native way to export the results. However, you can use the `esttab` command from the `estout` package to export the results to excel, word, or latex. You can use the options `cells()` and specified what estimates you want to include. For example:

```stata
*** ssc install estout, replace
// Latex Table
. local style "nomtitle nonumbers noobs b(3) se(3) booktabs"

. quietly tvsc divorce marriage, by(treatment) clus_id(region) stra_id(region) labels
. esttab, `style' cells("mu_2(fmt(%9.2fc)) mu_1(fmt(%9.2fc)) mu_3(fmt(%9.2fc))" "se_2(par) se_1(par) se_3(par)") 

{
\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}
\begin{tabular}{l*{1}{ccc}}
\toprule
            &   mu\_2/se\_2&   mu\_1/se\_1&   mu\_3/se\_3\\
\midrule
divorce     &   18,379.07&   30,425.36&   -12046.29\\
            &  (2,630.31)&  (7,183.07)&  (7,374.89)\\
marriage    &   40,064.50&   57,421.09&   -17356.59\\
            &  (6,472.19)& (11,808.47)& (11,261.94)\\
\bottomrule
\end{tabular}
}

// Latex Table, just the body
. local style "label nolines nogaps fragment nomtitle nonumbers noobs nodep collabels(none) booktabs b(3) se(3)"

. quietly tvsc divorce marriage, by(treatment) clus_id(region) stra_id(region) labels
. esttab, `style' cells("mu_2(fmt(%9.2fc)) mu_1(fmt(%9.2fc)) mu_3(fmt(%9.2fc))" "se_2(par) se_1(par) se_3(par)") 

Number of divorces  &   18,379.07&   30,425.36&   -12046.29\\
                    &  (2,630.31)&  (7,183.07)&  (7,374.89)\\
Number of marriages &   40,064.50&   57,421.09&   -17356.59\\
                    &  (6,472.19)& (11,808.47)& (11,261.94)\\
```

In this example, `mu_2` is equivalent to the treatment group, `mu_1` to the control group, and `mu_3` to the difference. If you want to include stars to the estimates, you can add `star pvalue(d_p)` to the `cells` options like this:

```stata
. quietly tvsc divorce marriage, by(treatment)
. esttab, `style' cells("mu_2(fmt(%9.2fc)) mu_1(fmt(%9.2fc)) mu_3(fmt(%9.2fc) star pvalue(d_p))" "se_2(par) se_1(par) se_3(par)") 

Number of divorces  &   18,379.07&   30,425.36&   -12046.29\sym{*}  \\
                    &  (2,630.31)&  (7,183.07)&  (7,011.02)         \\
Number of marriages &   40,064.50&   57,421.09&   -17356.59         \\
                    &  (6,472.19)& (11,808.47)& (12,747.12)         \\
```

## Author

I do not consider myself the author of this command since it draws from ado files that were written before by [Profe Mauricio Romero](https://mauricio-romero.com/). I just adapted it to have more options and to be downloadable.

In case you would like to contact me, you can email me at: [rodriguezramirez@worldbank.org](mailto:rodriguezramirez@worldbank.org)