#!/bin/bash

motCorr_repeat(){
    
    jobIsDone=false;
	nMin=25
	startRunWaitTime=$((10*60))
	loadWaitTime=$((15*60))
	sleepTime=30
	maxWaitTime=$(($nMin*60))
	waitTime=$(($nMin*4))
	while [ "$jobIsDone" != "true" ]
    do
	
		jobName=$5"id"$LSB_JOBINDEX
	
		startTime=$(date +"%s")
		endTime=$((startTime + maxWaitTime))
		endRunTime=$((startTime + startRunWaitTime))
		endLoadTime=$((startTime + loadWaitTime))
		
		#submit job
		bsub -J $jobName -q short -W $waitTime -r -R "rusage[tmp=5000,mem=10000]" -o "motionOut/motion_call"$LSB_JOBINDEX"_job"$5".out" /opt/matlab-2013b/bin/matlab -nojvm -nodisplay -r "runMotionCorrectOnOrch($LSB_JOBINDEX,$1,$2,$3,$4)"
		
		#sleep 30; # sleep for 30 seconds to allow enough time for bjobs to work
		
		checkFlag=true
		
		#generate output file name
		userName=$(id -u -n)
		outName="/hms/scratch1/"$userName"/motionCorrect/motionOut/motion_call"$LSB_JOBINDEX"_job"$5".out"
		
		while [ "$checkFlag" == "true" ]
		do
		
			currTime=$(date +"%s")
			#echo "currTime is $currTime. Endtime is $endTime"
			if [ "$currTime" -ge "$endTime" ]; then #set check flag to false if past end time
				checkFlag=false;
				bkill -J $jobName #kill job
				echo "$jobName has been killed for total time"
			fi
		
			sleep $sleepTime #sleep for 1 second
			
			# JOBSTATUS=$(bjobs -a -J $jobName) #get job status
			
			# if [[ "$JOBSTATUS" == *DONE* ]] #if job is done
			# then
				# return
			# else #if not done
				
			# fi
			
			#check if output file exists
			if [ -f $outName ]
			then
				
				echo "$outName has been found ASM"
				
				#get file data
				fileData=$(tr '\n' ' ' <$outName)
				
				#find out if isempty
				fileLength=${#fileData}
				if [ $fileLength -eq 0 ] 
				then 
					
					#find out if it's been longer than startWaitTime
					if [ "$currTime" -ge "$endRunTime" ]; then
						checkFlag=false;
						bkill -J $jobName #kill job
						echo "$jobName has been killed for endRunTime"
					fi
				fi
				
				#find out if hasn't completed initialization
				if [[ "$fileData" != *testFrames* ]]
				then
					#find out if it's been longer than startWaitTime
					if [ "$currTime" -ge "$endLoadTime" ]; then
						checkFlag=false;
						bkill -J $jobName #kill job
						echo "$jobName has been killed for endLoadTime"
					fi
				fi
				
				#find out if is done
				if [[ "$fileData" == *Done* ]]
				then
					echo "$jobName has completed ASM"
					checkFlag=false
					jobIsDone=true
				fi
				
				
			fi
			
			
			
			
			
		done
	done
    
	
	}
	
#call arguments verbatim
$@
