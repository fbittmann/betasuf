{smcl}
{* 2020-07-22}{...}
{hi:help betasuf}{...}
{hline}

{title:Title}

{pstd}{hi:betasuf} {hline 2} NEPS Beta SUF Variable Testing

{marker syntax}{...}
{title:Syntax}

{p 8 15 2}
{cmd:betasuf} {it:{help varlist}}
            [, {it:options}]

{synoptset 25 tabbed}{...}
{marker comopt}{synopthdr:options}
{synoptline}
{synopt :{opt nepsmiss}}define missing values using the package {helpb nepsmiss}.
  {p_end}
{synopt :{opt graph}}display and save graphs
  {p_end}


{synoptline}
{p 4 4 2}


{marker desc}{...}
{title:Description}

{pstd} {cmd:betasuf} helps checking for errors in NEPS Beta SUFs (scientific use files). The command searches for the most recent and
previous versions of a given variable in the SUF and presents helpful statistics to check for errors in
labels, coding or values. The command accepts factor variable notation. Nominal (e.g. federal state) or 
ordinal variables (Likert-scaled items) require the prefix i. Continuous variables (e.g. income, age) do not
require a prefix. The analyses are based on the scaling of the given variable. This command requires the packages {helpb fre} and {helpb catplot},
which must be manually installed. The command does not work with string variables.

{marker opt}{...}
{title:Options}

{marker comoptd}{it:{dlgtab:Options}}

{phang} {opt nepsmiss} runs nepsmiss on the given variable. This package has to be installed manually
as it is not a Stata default command, see: {browse "https://www.neps-data.de/Data-Center/Overview-and-Assistance/Stata-Tools"}. Note that
the data are preserved and the specification of nepsmiss does not change the dataset.

{phang} {opt graph} specifies that graphs are displayed and saved in the current working folder. This is helpful
for a quick visual inspection. Graphs are saved with the variable name as the prefix.


{marker ex}{...}
{title:Examples}


{pstd}Setup{p_end}
{phang2}{cmd:. use Stata\SC2_pTarget_D_9-0-0.dta, clear}{p_end}
{phang2}{cmd:. betasuf e66800d_g1 i.t723503, graph nepsmiss}{p_end}

	
{marker ref}{...}
{title:Installation & Updates}
{pstd} Most recent files are available from Github{p_end}

{phang2}{cmd:. net install betasuf, from(https://raw.github.com/fbittmann/betasuf/stable) replace}{p_end}


{title:Author}

{pstd} Felix Bittmann, Leibniz Institute for Educational Trajectories, felix.bittmann@lifbi.de

{pstd}Thanks for citing this software as follows:

{pmore}
Bittmann, Felix (2022): betasuf: Stata module to inspect NEPS Beta SUF variables.
Available from: https://github.com/fbittmann/betasuf.


{title:Also see}

{psee} Helpfile:  {helpb nepsmiss}{p_end}
