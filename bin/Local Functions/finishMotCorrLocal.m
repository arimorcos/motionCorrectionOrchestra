function finishMotCorrLocal()
%finishMotCorr.m function which runs on orchestra which completes motion
%correction
%
%INPUTS
%
%ASM 9/13

%get tiff
baseDir = 'K:\Data\2P Data\ResScan\';
if ~isdir(baseDir)
    baseDir = 'C:\';
end
origDir = cd(baseDir);
[tiffName,tiffPath] = uigetfile('*.tif','Select Local File');
tiffName = tiffName(1:regexp(tiffName,'.tif')-1);
tiffFile = fullfile(tiffPath,[tiffName,'.tif']);
cd(origDir);

%load shifts
load([tiffPath,tiffName,'_MotCorrOut.mat'],'xShifts','yShifts');

%cycle through files and save in segments to avoid too much memory
% framesPerCycle = 1000;
framesPerCycle = 1000;
nFrames = length(xShifts);
nCycles = ceil(nFrames/framesPerCycle);

%get max/min shifts
[maxXShift,minXShift,maxYShift,minYShift] = getMaxMinShift(xShifts,...
    yShifts);

%set up saving
saveName = [tiffPath,tiffName,'_motionCorrected.tif'];
options.comp = 'no';
options.color = false;
options.message = false;
options.ask = false;
options.append = true;

%check if file exists and delete if it does
if exist(saveName,'file')
    delete(saveName);
end

%create waitbar
hWait = waitbar(0,'Shifting tiff...');

for i = 1:nCycles
    
    %generate indices
    frameInd = (i-1)*framesPerCycle+1:min(i*framesPerCycle,nFrames);
    
    %load tiff file
    tiff = loadtiffAM(tiffFile,frameInd);
    
    %create shifted tiff
    [shiftTIFF] = adjustTIFF(tiff,xShifts(frameInd),yShifts(frameInd),...
        maxXShift,maxYShift,minXShift,minYShift);
%     [shiftTIFF] = adjustTIFF(tiff,xShifts(frameInd),yShifts(frameInd));
    
    %save tiff
    saveasbigtiff(uint16(shiftTIFF),saveName,options);
    
    %update waitbar
    waitbar(i/nCycles,hWait,sprintf('Shifting tiff... cycle %d/%d',i,nCycles));
    
    clear tiff shiftTIFF;
end

delete(hWait);
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