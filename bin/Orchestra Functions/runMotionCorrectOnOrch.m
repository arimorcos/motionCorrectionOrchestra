function runMotionCorrectOnOrch(iInd,filesPerCall,refInfoFile,outName,fileID)
%runMotionCorrectOnOrch.m Function called by bsub which actually calls the
%run times

outName = [outName,'/',num2str(fileID),'_call_',sprintf('%04d',iInd)];


%load refFrame and other
load(refInfoFile);

%generate callArray
callArray = (iInd-1)*filesPerCall + 1:min(iInd*filesPerCall,nFrames);

%call motionCorrection
motionCorrectOrch(tiffLoc, refFrameID, callArray, maxShift, corrThresh,...
    minSamp, interpLevel, outName)