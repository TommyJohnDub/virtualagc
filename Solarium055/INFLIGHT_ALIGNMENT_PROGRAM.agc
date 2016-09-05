### FILE="Main.annotation"
# Copyright:	Public domain.
# Filename:	INFLIGHT_ALIGNMENT_PROGRAM.agc
# Purpose:	Part of the source code for Solarium build 55. This
#		is for the Command Module's (CM) Apollo Guidance
#		Computer (AGC), for Apollo 6.
# Assembler:	yaYUL --block1
# Contact:	Jim Lawton <jim DOT lawton AT gmail DOT com>
# Website:	www.ibiblio.org/apollo/index.html
# Page scans:	www.ibiblio.org/apollo/ScansForConversion/Solarium055/
# Mod history:	2009-10-03 JL	Created.

## Page 366

		SETLOC	44000

SWAYSTAT	CAF	SIX		# PROGRAM START AND INITIAL CONDITIONS
		TS	DTCOUNT		# SET DTCOUNT = 6
		TS	DTCOUNT +1
		CAF	ONE
		TS	SWAYPULS	# SET FIRST PIPA PULSE = +1
		TS	SWAYPULS +1
		CAF	ONE
		TC	WAITLIST
		CADR	SWAYROTY
		CAF	ONE
		AD	PHAZING
		TC	WAITLIST
		CADR	SWAYROTZ
		RELINT
		TC	ENDOFJOB



SWAYROTZ	XCH	LP		# STORE LP IN LPRUPT
		XCH	LPRUPT
		CAF	ONE		# SET INDEX PIPSLECT FOR SELECTION OF
		TS	PIPSLECT	# PIPA TO BE INCREMENTED
		TC	SWAYROTY +4
		
SWAYROTY	XCH	LP
		XCH	LPRUPT
		CAF	ZERO
		TS	PIPSLECT
		
		CS	ZERO
		INDEX	PIPSLECT
		XCH	PIPAY
		INDEX	PIPSLECT
		AD	SWAYPULS
		INDEX	PIPSLECT
		XCH	PIPAY
		CCS	A
		AD	ONE		# INCREMENT PIPA COUNTER IF PULSE
		TC	ADDINC +1
		TC	ADDINC
		TC	ENDCHEC



ADDINC		CS	ONE
		INDEX	PIPSLECT
		AD	PIPAY
		INDEX	PIPSLECT
## Page 367
		XCH	PIPAY



ENDCHEC		CCS	ENDSROT		# IF ENDSROT = +1 EXIT PROGRAM
		TC	CDTTHREE	# WHEN DTCOUNT = 6
		TC	TIMCALC
		TC	CDTTHREE
CDTTHREE	CS	SIX
		INDEX	PIPSLECT
		AD	DTCOUNT
		CCS	A
		TC	TIMCALC		# EXIT ON DTCOUNT = 6
		TC	ENDSWAY
		TC	TIMCALC
		TC	ENDSWAY



TIMCALC		INDEX	PIPSLECT
		CCS	DTCOUNT
		TC	DIMCOUNT	# ACC NOW CONTAINS DTCOUNT - 1
		TC	ALTPULSS	# IF DTCOUNT NORZ CHANGE
		TC	ALTPULSS	# SIGN OF SWAYPULSE
		NOOP
ALTPULSS	INDEX	PIPSLECT
		CS	SWAYPULS
		INDEX	PIPSLECT
		TS	SWAYPULS
		CAF	THIRTEEN	# AND RESTART DTCOUNT AT 13
DIMCOUNT	INDEX	PIPSLECT
		TS	DTCOUNT		# DTCOUNT NOW DIMISHED BY ONE
					# OR RESET TO 13
		INDEX	PIPSLECT
		INDEX	DTCOUNT		# SELECT APPROPRIATE DELTA T FROM LIST
		CAF	DELTA
		EXTEND
		MP	TPERIOD		# AND MULTIPLY BY PERIOD
		AD	FIVE		# ROUND RESULT
		EXTEND
		MP	ONETENTH
		TS	RUPTSTOR +3	# TIME (DT) TILL NEXT INTERRUPT 10MS
NEXTRUPT	CCS	PIPSLECT
		TC	ZPIPRUPT	# CALL WAITLIST FOR ZPIPA
		XCH	RUPTSTOR +3
		TC	WAITLIST	# CALL WAITLIST FOR YPIPA
		CADR	SWAYROTY
		TC	ENDSWAY
		
ZPIPRUPT	XCH	RUPTSTOR +3
## Page 368
		TC	WAITLIST
		CADR	SWAYROTZ
ENDSWAY		XCH	LPRUPT		# REPLACE LP
		EXTEND
		MP	BIT1
		TC	TASKOVER	# END OF SWAY ROUTINE

## Page 369

# MEMORY ASSIGNMENTS



DTCOUNT		EQUALS	AMEMORY		# YPIPA STATE COUNTER (0-7)
SWAYPULS	EQUALS	AMEMORY +2	# NEXT YPIPA PULSE (+1,-1)
PHAZING		EQUALS	AMEMORY +4	# TIME DELAY FOR ZPIPA START
					# INITIALIZED BY KEYBOARD
					# +XXXXX. E-2 SEC
					# MUST BE GREATER THAN 00001
ENDSROT		EQUALS	AMEMORY +5	# FLAG FOR PROGRAM EXIT
					# SET BY KEYBOARD
					# = 00001. TO END SWAYROUTINE
					# = +00000. TO CONTINUE
TPERIOD		EQUALS	AMEMORY +8D	# PERIOD OF SWAY
					# SET BY KEYBOARD
					# = XX.XXX SEC
PIPSLECT	EQUALS	AMEMORY +9D	# INDEX FOR PIPA SELECTION
DELTA		DEC	.05482		# DELTA  TO
		DEC	.03444		# 1
		DEC	.02833		# 2
		DEC	.02528		# 3
		DEC	.02356		# 4
		DEC	.02259		# 5
		DEC	.02213		# 6
		DEC	.02213		# 7
		DEC	.02259		# 8
		DEC	.02356		# 9
		DEC	.02528		# 10
		DEC	.02833		# 11
		DEC	.03444		# 12
		DEC	.1325		# 13
ONETENTH	DEC	E-1

## Page 370

# VERIFICATION ASSISTANVE FOR INFLIGHT



MYTEST		TC	INTPRET		#					456
		DMOVE	0		#					356
			ZERODP		# SET ANGLES TO ZERO AND TEST		256
		STORE	IGC		#					156
		
		NOLOD	0		#					056
		STORE	MGC		#					-56
		
		NOLOD	0		#					+56
		STORE	OGC
		
		ITC	0
			DOTEST
		
		COMP	0		# SET ANGLES TO -HALF AND TEST
			HALFDP
		STORE	IGC
		
		NOLOD	0
		STORE	MGC
		
		NOLOD	0
		STORE	OGC
		
		ITC	0
			DOTEST

CHGIGC		DMOVE	1		# CHANGE IGC,MGC, AND OGC AND TEST
		DAD
			AZIMUTH
			INCRMT
		STORE	IGC
		
		NOLOD	0
		STORE	AZIMUTH
		
		DSU	1
		BPL	ITC
			IGC
			HALFDP
			OUT
			DOTEST
		
CHGMGC		DMOVE	1		# CHANGE MGC AND OGC AND TEST
		DAD
			GYROCSW
## Page 371
			INCRMT
		STORE	MGC
		
		NOLOD	0
		STORE	GYROCSW
		
		DSU	1
		BPL	ITC
			MGC
			HALFDP
			RESETM
			DOTEST
		
CHGOGC		DMOVE	1		# RESET OGC AND TEST
		DAD
			PRELXGA
			INCRMT
		STORE	OGC
		
		NOLOD	0
		STORE	PRELXGA
		
		DSU	1
		BPL	ITC
			OGC
			HALFDP
			RESETO
			DOTEST
		
		ITC	0
			CHGOGC
		
RESETO		COMP	0		# RESET OGC TO-HALF
			HALFDP		# LOOP TO CHGMGC
		STORE	PRELXGA
		
		ITC	0
			CHGMGC

RESETM		COMP	0		# RESET MGC TO -HALF
			HALFDP		# LOOP TO CHGIGC
		STORE	GYROCSW
		
		ITC	0
			CHGIGC

INCRMT		2DEC	.20

OUT		EXIT	0		# END OF MAIN
LASTWORD	TC	ENDOFJOB
## Page 372

DOTEST		ITA	1
		VMOVE	ITC
			LATITUDE
			UNITX
			MYROT
		
		NOLOD	0
		STORE	STARAD
		
		VMOVE	1
		ITC
			UNITY
			MYROT
		
		NOLOD	0
		STORE	STARAD +6D
		
		VMOVE	0
			UNITX
		STORE	6D
		
		VMOVE	0
			UNITY
		STORE	12D
		
		ITC	0
			AXISGEN
		
		ITC	0		# SEND NEW VECTORS TO CALCGTA
			CALCGTA
		
		ITCI	0
			LATITUDE
MYROT		ITA	1		# INITIALIZE
		TEST	SWITCH
			S2
			NBSMBIT
			MYROT1
			NBSMBIT
		
MYROT1		AXT,1	1		# ROTATE X,Z  ABOUT  Y
		AXT,2	DMOVE
			4
			0
			IGC
		STORE	30D
		
		ITC	0
			ACCUROT
## Page 373
		AXT,1	1		#  ROTATE X,Y  ABOUT  Z
		AXT,2	DMOVE
			2
			4
			MGC
		STORE	30D
		
		ITC	0
			ACCUROT
		
		AXT,1	1		# ROTATE  Z,Y ABOUT  X
		AXT,2	DMOVE
			0
			2
			OGC
		STORE	30D
		
		ITC	0
			ACCUROT
		
		ITCI	0
			S2