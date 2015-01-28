#!/bin/bash

finishMotionCorrectManual(){

	#save modified tiff
	bsub -q short -W 12:00 -r -R "rusage[tmp=30000,mem=30000]" -o motionOut/finishMotCorr_manual.out /opt/matlab/bin/matlab -nojvm -nodisplay -r "finishMotCorr($1)"
	
	}
	
#call arguments verbatim
$@
