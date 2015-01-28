function catSaveOrchimRegisterOutput(outputPath,fileStr,refFile,fileID)
%catOrchOutput.m Function to concatenate output of motion correction on
%orchestra and save
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
load(refFile);

%initialize final tiff
shiftTIFF = zeros(height,width,nFrames);

%for each file
for i = 1:nFiles
    
    %load in arrays
    load(fileList{i});
    
    %store new tiffs
    shiftTIFF(:,:,shiftInd) = shiftFrames;    
end

%save tiff
[tiffPath,tiffName] = fileparts(tiffLoc);
cd(tiffPath);
addpath(tiffPath);
saveName = [tiffPath,'/',tiffName,'_motionCorrected.tif'];
saveasbigtiff(uint16(shiftTIFF),saveName);

%delete files
cd(outputPath);
delete(fileList{:});

%cd to orig dir
cd(origDir);