#!/bin/bash

run_motionCorrect_repeat(){
    
	userName=$(id -u -n)
	
    #run motion correction
	bsub -J $1[1-$2] -q short -W 12:00 -r -R "rusage[mem=1000]" -R "select[scratch1]" -o "/home/"$userName"/dump" "/home/"$userName"/motCorr_repeat.sh" motCorr_repeat $3 $4 $5 $7 $1
	
    #concatenate results
    bsub -J $6 -q short -W 20 -r -R "select[scratch1]" -w 'done("'$1'")' -o motionOut/cat_job%J.out /opt/matlab-2013b/bin/matlab -nojvm -nodisplay -r "catOrchOutput($5,'call_',$4,$7)"
	
	}
	
#call arguments verbatim
$@