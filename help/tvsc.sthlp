{smcl}
{* 5 Nov 2019}{...}
{hline}
help for {hi:tvsc}
{hline}

{title:Title}

{phang2}{cmdab:tvsc} {hline 2} produces a balance table between treatment and control groups with or without fixed effects.

{title:Syntax}

{phang2}
{cmdab:tvsc} {it:varlist} [{help if:if}] [{help in:in}] [{help weight}]
, {cmdab:by(}{it:varname}{cmd:)} 
[
{cmdab:clus:_id(varname)}
{cmdab:strat:_id(varname)}
{cmdab:labels}
{cmdab:sd}
]

{phang2}where {it:varlist} is one or several variables.

{marker opts}{...}
{synoptset 23}{...}
{synopthdr:options}
{synoptline}
{pstd}{it:    {ul:{hi:Required options:}}}{p_end}

{synopt :{cmdab:by(}{it:varname}{cmd:)}}Variable that indicates the treatment status. The command expects 0 to be control and 1 to be treatment.{p_end}

{pstd}{it:    {ul:{hi:Optional options}}}{p_end}

{synopt :{cmdab:clus:_id(}{it:varname}{cmd:)}}Option to include clustered standard errors for the estimated differences.{p_end}
{synopt :{cmdab:strat:_id(}{it:varname}{cmd:)}}Option to include Fixed Effects in the estimation of the differences.{p_end}
{synopt :{cmdab:sd}}Include standard deviations instead of standard errors in the results table.{p_end}
{synopt :{cmdab:labels}}Include labels in the results table.{p_end}

{synoptline}

{title:Description}

{pstd}{cmdab:tvsc} is a command that generates balance tables.
    The command tests for statistically significant difference between the categories defined in the
	by(varname). It uses {cmdab:reghdfe} to estimates the differences with fixed effects.

{title:Examples}

{p 4 4 2}
First, let's create a dummy treatment variable:

        {com}*** Load dataset
        {com}. sysuse census, clear 

        {com}*** Create treatment variable
        {com}. set seed 01237846
        {com}. gen treatment = (runiform()<.5)

{p 4 4 2}
{hi:Example 1.} Raw differences with standard errors for treatment, control, and differences:

        {com}. tvsc divorce marriage, by(treatment)
        {res}
        {txt}{hline 48}
        {txt}           Treatment      Control      Diff
        {txt}{hline 48}
        {txt}divorce    {res}18,379.07    30,425.36    -12046.29
        {txt}           {res}(2,630.31)   (7,183.07)   (7,011.02)
        {txt}marriage   {res}40,064.50    57,421.09    -17356.59
        {txt}           {res}(6,472.19)  (11,808.47)  (12,747.12)
        {txt}{hline 48}

{p 4 4 2}
{hi:Example 2.} Raw differences with standard deviations for treatment, control, and standard errors for differences:

        {com}. tvsc divorce marriage, by(treatment) sd
        {res}
        {txt}{hline 48}
        {txt}           Treatment      Control      Diff
        {txt}{hline 48}
        {txt}divorce   {res}18,379.07    30,425.36    -12046.29
        {res}          {res}(13,918.27)  (33,691.57)   (7,011.02)
        {txt}marriage  {res}40,064.50    57,421.09    -17356.59
        {res}          {res}(34,247.63)  (55,386.64)  (12,747.12)
        {txt}{hline 48}

{p 4 4 2}
{hi:Example 3.} Differences with clustered standard errors:

        {com}. tvsc divorce marriage, by(treatment) clus_id(region)
        {res}
        {txt}{hline 48}
        {txt}           Treatment      Control      Diff
        {txt}{hline 48}
        {txt}divorce     {res}18,379.07    30,425.36    -12046.29
        {txt}            {res}(2,630.31)   (7,183.07)   (7,374.89)
        {txt}marriage    {res}40,064.50    57,421.09    -17356.59
        {txt}            {res}(6,472.19)  (11,808.47)  (11,261.94)
        {txt}{hline 48}

{p 4 4 2}
{hi:Example 4.} Same as example 3 plus differences with fixed effects:

        {com}. tvsc divorce marriage, by(treatment) clus_id(region) strat_id(region)
        {res}
        {txt}{hline 60}
        {txt}           Treatment      Control      Diff        FE Diff
        {txt}{hline 60}
        {txt}divorce    {res}18,379.07    30,425.36    -12046.29    -13692.48
        {txt}           {res}(2,630.31)   (7,183.07)   (7,374.89)   (8,755.31)
        {txt}marriage   {res}40,064.50    57,421.09    -17356.59    -20555.04
        {txt}           {res}(6,472.19)  (11,808.47)  (11,261.94)  (12,263.35)
        {txt}{hline 60}

{p 4 4 2}
{hi:Example 5.} Same as example 4 plus labels:

        {com}. tvsc divorce marriage, by(treatment) clus_id(region) strat_id(region) labels
        {res}
        {txt}{hline 72}
        {txt}                       Treatment      Control      Diff        FE Diff
        {txt}{hline 72}
        {txt}Number of divorces     {res}18,379.07    30,425.36    -12046.29    -13692.48
        {txt}                       {res}(2,630.31)   (7,183.07)   (7,374.89)   (8,755.31)
        {txt}Number of marriages    {res}40,064.50    57,421.09    -17356.59    -20555.04
        {txt}                       {res}(6,472.19)  (11,808.47)  (11,261.94)  (12,263.35)
        {txt}{hline 72}              

{title:Author}

{phang}Author: Rony Rodriguez Ramirez, DIME Analytics--The World Bank Group

