function [tiffNames,tiffPaths,tiffFiles] = getTIFFNames(baseDir)
%getTIFFNames.m Gets tiff file names from user
%
%OUTPUTS
%tiffNames - cell array of tiff file names
%tiffPaths - cell array of tiff paths
%tiffFiles - cell array of full tiff file names
%
%ASM 10/13

if nargin > 0 
    origDir = cd(baseDir);
end

%initialize cells
tiffNames = {};
tiffPaths = {};
tiffFiles = {};

getFiles = true;

while getFiles
    
    %get tif files in folder
    [tempTifFileNames,tempTifPath] = ...
        uigetfile('*.tif','Select Tiff Files','MultiSelect','on');
    
    %duplicate tiffPath
    tempTifPath = repmat({tempTifPath},1,length(tempTifFileNames));
    
    %check if canceled
    if isequal(tempTifFileNames,0) && isempty(tiffNames) %if canceled
        disp('No .tif files selected');
        return;
    elseif isequal(tempTifFileNames,0) && ~isempty(tiffNames) 
        cancelFlag = true;
    else
        cancelFlag = false;
    end
    
    if ~cancelFlag
        %if only one file selected
        if ischar(tempTifFileNames)
            tempTifFileNames = {tempTifFileNames};
        end

        %create cell array of file names
        tiffNames = cat(2,tiffNames,tempTifFileNames);
        tiffPaths = cat(2,tiffPaths,tempTifPath);
        
        tempTifFiles = cell(size(tempTifFileNames));
        for i = 1:length(tempTifFileNames)
            tempTifFiles{i} = fullfile(tempTifPath{i},tempTifFileNames{i});
        end
        tiffFiles = cat(2,tiffFiles,tempTifFiles);
    end
    
    
    %check if more folders
    moreFiles = questdlg('Are there more files?');
    switch moreFiles
        case 'Yes'
            getFiles = true;
        case {'No','Cancel'}
            getFiles = false;
    end
end

if nargin > 0 
    cd(origDir);
end