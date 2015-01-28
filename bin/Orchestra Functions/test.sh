#!/bin/bash

test(){
    
    fileName="motionOut/motion_call1_job9133758562.out"
	fileData=$(tr '\n' ' ' <$fileName)
	echo $fileData
	
#call arguments verbatim
$@