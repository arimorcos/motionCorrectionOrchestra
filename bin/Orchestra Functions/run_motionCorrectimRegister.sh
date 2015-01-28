#!/bin/bash

run_motionCorrectimRegister(){
    
    #run motion correction
	bsub -J $1[1-$2] -q short -W 30 -r -o motionOut/motion_call%I_job%J.out /opt/matlab/bin/matlab -nojvm -nodisplay -r "runMotionCorrectOnOrchimRegister(\$LSB_JOBINDEX,$3,$4,$5,$7)"
	
    #concatenate results
    bsub -J $6 -q short -W 2:00 -r -w 'done("'$1'")' -o motionOut/cat_job%J.out /opt/matlab/bin/matlab -nojvm -nodisplay -r "catSaveOrchimRegisterOutput($5,'call_',$4,$7)"
	
	}
	
#call arguments verbatim
$@