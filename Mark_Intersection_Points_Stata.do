********************************************************************************
*																 			   *
*  Purpose:  			Marking intersection points between linear lines       *
*  Author: 				Fahad Mirza 										   *
*  Editor:				Fahad Mirza 										   *
*  Dated:  				September 21, 2025									   *
*  Last update: 		September 21, 2025									   *
*																 			   *
********************************************************************************	
	
	* Load example data
	sysuse uslifeexp, clear

	* Store reference value in local
	local ref_value = 59

	* Create a constant variable for the reference line which will be used to generate the difference between
	* actual and reference
	generate double y_ref = `ref_value'

	* Identify observations where the line crosses the reference
	generate double diff = le - y_ref

	* Generate variables to mark when a coordinate goes above or below the reference value
	generate double negposcross = .
	generate double posnegcross = .

	* Looping over observations to mark crossing instances and store them in variables generated in previous
	* step
	local intersect = 1
	forvalues i = 2/`=_N' {
		
		if (diff[`i'] <= 0 & diff[`=`i' + 1'] > 0) {
			replace negposcross = `intersect' in `i'
			local ++intersect
		}
	}

	local intersect = 1
	forvalues i = 2/`=_N' {
		
		if (diff[`i'] >= 0 & diff[`=`i' + 1'] < 0) {
			replace posnegcross = `intersect' in `i'
			local ++intersect
		}
	}

	* Generating the index value of observations that intersect with reference line
	* then store them in a local
	generate obs = _n 
	levelsof obs if !missing(negposcross), local(lista)
	levelsof obs if !missing(posnegcross), local(listb)

	* Combining locals that will hold all instances of intersections
	local int_obs `lista' `listb'


	* Interpolate the exact x-coordinate of the intersection
	* This is done by calculating the slope of the line between the points just above
	* and below the reference line
	foreach intersect_obs of local int_obs {
		
		local y1 = le[`intersect_obs']
		local y2 = le[`=`intersect_obs' + 1']
		
		local x1 = year[`intersect_obs']
		local x2 = year[`=`intersect_obs' + 1']
		
		local slope = (`y2' - `y1') / (`x2' - `x1')
		local x_intersect = (`ref_value' - `y1') / `slope' + `x1'
		
		local points "`points' (scatteri `ref_value' `x_intersect', mcolor(red) msymbol(Oh) msize(*0.5)) "
		
		summarize le, meanonly
		local xpoints "`xpoints' (scatteri `ref_value' `x_intersect' `r(min)' `x_intersect', recast(line) lcolor(black) lpattern(dash)) "
		
	}

	display "`points'"

	
	* Graph the trend line, yline, and the intersection point/s
	twoway 	(line le year, sort lalign(center)) ///
			(scatteri `ref_value' 1900 `ref_value' 2000, recast(line) lpattern(dash) lalign(center) lcolor(blck)) ///
			`xpoints' ///
			`points' ///
			, ///
			legend(off)


