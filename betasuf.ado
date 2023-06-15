

cap program drop betasuf
program define betasuf
	*! version 1.0.1  Felix Bittmann  2022-10-14
	syntax varlist(fv), [nepsmiss graph]
	
	if "`nepsmiss'" != "nepsmiss" {
		di as error "Warning! Nepsmiss not applied! Check for missing values with care!"
	}
		
	foreach VAR of local varlist {
		*Check for factor variables*
		local factor = 0
		if substr("`VAR'", 1, 2) == "i." {
			local factor = 1
			local VAR = substr("`VAR'", 3, .)
		}
		
		*Test for string variables*
		cap confirm numeric variable `VAR'
		if _rc != 0 {
			di as error "`VAR' is a string variable! Will be skipped!"
		}
		else {			
			preserve
			keep ID_t wave `VAR'
			
			*Nepsmiss*
			if "`nepsmiss'" == "nepsmiss" {
				cap qui nepsmiss `VAR'
				if _rc != 0 {
					di as error "Command nepsmiss not found. Please install fromh ttps://www.neps-data.de/Data-Center/Overview-and-Assistance/Stata-Tools"
					exit 199
				}
			}
			
			describe `VAR'
			codebook `VAR'
			tabstat `VAR', by(wave) statistics(count mean min max) nototal
			if `factor' == 1 {
				di as result "Tabulation over ALL waves"
				fre `VAR', all
				tab wave `VAR', miss
				qui levelsof `VAR', local(w)
				local lab: value label `VAR'
				label list `lab'
				labelbook `lab'
				labelbook `lab', problem
			}
				

			
			*Find out most recent wave with cases available*
			qui levelsof wave, local(w)
			local inuse ""	
			local last0 0			//Stores most recent waves with cases available
			local last1 0			//Stores the next older wave with cases available
			foreach WAVE in `w' {
				qui count if !missing(`VAR') & wave == `WAVE'
				if `r(N)' > 15 {
					local inuse `inuse' `WAVE'
					*di as result "Most recent Wave: `WAVE'"
					qui sum `VAR' if wave == `WAVE'
					local last1 `last0'
					local last0 `WAVE'
					
				}
			}
			
			*No earlier version found*
			if `last1' == 0 {
				qui count if wave == `last0' & !missing(`VAR')
				local valid0 = r(N)
				di as error "Caution: This is a new variable. No previous version has been found!"
				sum `VAR', det
				cap fre `VAR'
				if _rc != 0 {
					di as error "Command fre not found. Please install with ssc install fre, replace"
					exit 199
				}
				
				if `factor' == 1 & "`graph'" == "graph" {
					cap catplot `VAR',  vert ///
						blabel(bar, format(%6.2f)) perc note(N = `valid0') title("`VAR' / most recent wave: `last0'") ///
						note("N = `valid0'")
					if _rc != 0 {
						di as error "Command catplot not found. Please install with ssc install catplot, replace"
						exit 199
					}
					graph export "`VAR'_bar_charts.png", replace as(png) width(1920)
				}
				if `factor' == 0 & "`graph'" == "graph" {
					kdensity `VAR', title("`VAR'") note("N = `valid0'")
				}
				exit		
			}
			
			
			
			qui count if wave == `last0' & !missing(`VAR')
			local valid0 = r(N)
			qui count if wave == `last1' & !missing(`VAR')
			local valid1 = r(N)
			
			
			
			*Create long and wide datasets*
			tempfile data_long data_wide
			qui save `data_long', replace	
			keep if inlist(wave, `last0', `last1')
			clonevar outcome = `VAR'
			drop `VAR'
			gen recent = wave
			replace recent = 0 if recent == `last0'
			replace recent = 1 if recent == `last1'
			qui reshape wide outcome wave, i(ID_t) j(recent)
			label var outcome0 "Most recent wave (`last0')"
			label var outcome1 "Next older wave (`last1')"
			qui save `data_wide', replace
			use `data_long', clear
			
			****************************************************************************
			***Analyses only for factors*
			****************************************************************************
			if `factor' == 1 {
				if "`graph'" == "graph" {
					cap catplot `VAR' if wave == `last0', name(recent, replace) nodraw vert ///
						blabel(bar, format(%6.2f)) perc note(N = `valid0') title("Most recent wave: `last0'")
					if _rc != 0 {
						di as error "Command catplot not found. Please install with ssc install catplot, replace"
						exit 199
					}
					catplot `VAR' if wave == `last1', name(old, replace) nodraw vert ///
						blabel(bar, format(%6.2f)) perc note(N = `valid1') title("Next older wave: `last1'")
					graph combine recent old, title("`VAR'")
					graph export "`VAR'_bar_charts.png", replace as(png) width(1920)
				}
				
			
			di as result "*** Comparing labels and distributions ***"
			di as result "Most recent wave (`last0')"
			fre `VAR' if wave == `last0'
			di as result "Next older wave (`last1')"
			fre `VAR' if wave == `last1'
			

			use `data_wide', clear
			di as result "Cross tabulation"
			tab outcome0 outcome1, miss chi
			di as result "Correlation (Spearman's Rho)"
			spearman outcome0 outcome1
			}
			
			****************************************************************************
			*Analyses for continuous variables only*
			****************************************************************************
			if `factor' == 0 {
				use `data_wide', clear
				sum outcome0, det
				sum outcome1, det
				
				if "`graph'" == "graph" {
					twoway (kdensity outcome0) (kdensity outcome1), ///
						legend(order(1 "Most recent wave (`last0')" 2 "Next older wave (`last1')")) ///
						title("`VAR'") note("N = `valid0' / `valid1'")
					graph export "`VAR'_densities.png", replace as(png) width(1920)
							
				}
				
				stack outcome0 outcome1, into(stacked) clear
				label define _stack 1 "Most recent wave (`last0')" 2 "Next older wave (`last1')"
				label values _stack _stack
				ttest stacked, by(_stack)
				if "`graph'" == "graph" {
					graph box stacked, over(_stack) note("N = `valid0' / `valid1'") ytitle("") title("`VAR'")
					graph export "`VAR'_boxplots.png", replace as(png) width(1920)
				}
				
			}
			restore
		}
	}
end
