	; setSoundProbability
	;   parameters: dividend, divisor,
	;		dividend segment, dividend offset,
	;		divisor segment, divisor offset
	;   probability of sound being played ~= dividend / divisor
	%macro setSoundProbability 6
		startBlockAt %3, %4
			dw %1
		endBlock
		
		startBlockAt %5, %6
			dw %2
		endBlock
	%endmacro
