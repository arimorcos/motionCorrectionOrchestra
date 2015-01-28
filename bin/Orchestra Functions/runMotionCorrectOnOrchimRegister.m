function runMotionCorrectOnOrchimRegister(iInd,filesPerCall,refInfoFile,...
    outName,fileID)
%runMotionCorrectOnOrchimRegister.m Function called by bsub which actually calls the
%run times

outName = [outName,'/',num2str(fileID),'_call_',sprintf('%04d',iInd)];


%load refFrame and other
load(refInfoFile);

%get tiffInfo
tiffInfo = imfinfo(tiffLoc,'tiff');

%get nFrames
nFrames = length(tiffInfo);

%generate callArray
callArray = (iInd-1)*filesPerCall + 1:min(iInd*filesPerCall,nFrames);

%call motionCorrection
motionCorrectOrchimRegister(tiffLoc, refFrameID, tiffInfo, callArray,...
    outName);