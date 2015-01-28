function copyMotCorrOutputFinish(src,evnt,ssh2_struct,hWait,localPath,remotePath,...
    tiffBase,orchInfo,ind)
%copyMotCorrOutputFinish.m Function to copy the motCorr output file from
%orchestra, shift the tiff and save
%
%INPUTS
%ssh2_struct - ssh2_struc created by ssh2_config
%hWait - waitbar handle
%localPath - path where file should be saved
%tiffBase - baseName of tiff
%remotePath - path containing orchestra output
%orchInfo - orchInfo file for submitting next job
%ind - index of file to start
%
%ASM 10/13

%initialize file names
matTiffName = [tiffBase,'_MotCorrOut.mat'];
shiftTiffName = [tiffBase,'_motionCorrected.tif'];

%copy files
scp_get(ssh2_struct, matTiffName, localPath, remotePath);

%update waitbar
waitbar(0,hWait,'Creating shifted tiff...');

%update matTiff and shiftTiff
matTiffName = fullfile(localPath,matTiffName);
shiftTiffName = fullfile(localPath,shiftTiffName);
tiffFile = fullfile(localPath,[tiffBase,'.tif']);

%load shifts
load(matTiffName,'xShifts','yShifts');

%get max/min shifts
[maxXShift,minXShift,maxYShift,minYShift] = getMaxMinShift(xShifts,...
    yShifts);

%initialize variables for saving
framesPerCycle = 1000;
nFrames = length(xShifts);
nCycles = ceil(nFrames/framesPerCycle);
options.comp = 'no';
options.color = false;
options.message = false;
options.ask = false;
options.append = true;

%check if file exists and delete if it does
if exist(shiftTiffName,'file')
    delete(shiftTiffName);
end

for i = 1:nCycles
    
    %generate indices
    frameInd = (i-1)*framesPerCycle+1:min(i*framesPerCycle,nFrames);
    
    %load tiff file
    tiff = loadtiffAM(tiffFile,frameInd);
    
    %create shifted tiff
    [shiftTIFF] = adjustTIFF(tiff,xShifts(frameInd),yShifts(frameInd),...
        maxXShift,maxYShift,minXShift,minYShift);
    
    %convert to uint16
    shiftTIFF = uint16(shiftTIFF);
    
    %save tiff
    saveasbigtiff(shiftTIFF,shiftTiffName,options);
    
    %clear variables
    clear tiff shiftTIFF;
    
    %update waitbar
    waitbar(i/nCycles,hWait,'Creating shifted tiff...');
end

%delete waitbar
delete(orchInfo.h(ind));

%delete remote files
matTiff = [remotePath,'/',tiffBase,'.mat'];
origTiff = [remotePath,'/',tiffBase,'.tif'];
origMat = [remotePath,'/',tiffBase,'.mat'];
ssh2_command(ssh2_struct,['rm ',matTiff],0);
ssh2_command(ssh2_struct,['rm ',origTiff],0);
ssh2_command(ssh2_struct,['rm ',origMat],0);

%submit next set of jobs
if ind < length(orchInfo.tiffBase)
    ind = ind + 1;
    submitOrchestraJobs(orchInfo,ind);
end

end

function [maxXShift,minXShift,maxYShift,minYShift] = getMaxMinShift(xShifts,...
    yShifts)
%find the maximum and minimum offsets
maxXShift = max(xShifts);
maxYShift = max(yShifts);
minXShift = min(xShifts);
minYShift = min(yShifts);

%shift them appropriately to find the shifts which will gauruntee that you
%never get any blank pixels on the edge
maxXShift = ceil(maxXShift);
maxYShift = ceil(maxYShift);
minXShift = floor(minXShift);
minYShift = floor(minYShift);

end

