function catOrchOutput(outputPath,fileStr,refFile,fileID)
%catOrchOutput.m Function to concatenate output of motion correction on
%orchestra. 
%
%INPUTS
%outputPath - path of folder with orchestra output
%fileStr - base string of each .mat output file
%refFile - path of refFile
%fileID - unique file identifier for multiple jobs
%
%ASM 9/16/13

%cd to output path
origDir = cd(outputPath);

%get list of all files with fileStr as base
fileList = dir([num2str(fileID),'_',fileStr,'*.mat']);
fileList = {fileList(:).name};

%get number of files
nFiles = length(fileList);

%load in nFrames
load(refFile,'nFrames','tiffLoc');

%initialize arrays
xShiftsAll = zeros(1,nFrames);
yShiftsAll = zeros(1,nFrames);
corrThresholdsAll = zeros(1,nFrames);
numSamplesAll = zeros(1,nFrames);

%for each file
for i = 1:nFiles
    
    %load in arrays
    load(fileList{i});
    
    %store info
    xShiftsAll(shiftInd) = xShifts;
    yShiftsAll(shiftInd) = yShifts;
    corrThresholdsAll(shiftInd) = corrThresholds;
    numSamplesAll(shiftInd) = numSamples;
    
end

%rename variables
xShifts = xShiftsAll;
yShifts = yShiftsAll;
corrThresholds = corrThresholdsAll;
numSamples = numSamplesAll;

%get save location and save
[tiffPath,tiffName] = fileparts(tiffLoc);
save([tiffPath,'/',tiffName,'_MotCorrOut.mat'],'xShifts','yShifts','corrThresholds','numSamples')

%delete files
delete(fileList{:});

%cd to orig dir
cd(origDir);