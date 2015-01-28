#!/bin/bash

run_motionCorrect(){
    
    #run motion correction
	bsub -J $1[1-$2] -q short -W 12:00 -r -R "rusage[tmp=5000,mem=10000]" -R "select[scratch1]" -o motionOut/motion_call%I_job%J.out /opt/matlab-2013b/bin/matlab -nojvm -nodisplay -r "runMotionCorrectOnOrch(\$LSB_JOBINDEX,$3,$4,$5,$7)"
	
    #concatenate results
    bsub -J $6 -q short -W 12:00 -r -R "select[scratch1]" -w 'done("'$1'")' -o motionOut/cat_job%J.out /opt/matlab-2013b/bin/matlab -nojvm -nodisplay -r "catOrchOutput($5,'call_',$4,$7)"
	
	}
	
#call arguments verbatim
$@