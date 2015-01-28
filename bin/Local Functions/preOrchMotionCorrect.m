function preOrchMotionCorrect(tiffFile,tiffLoc,maxShift,corrThresh,...
    minSamp,interpLevel) %#ok<INUSD>
%preOrchMotionCorrect.m Function to pre-process tiff files for motion
%correction using the orchestra cluster
%
%INPUTS
%tiffPath - path to the tiff files used
%tiffLoc - path to tiff on remote server
%maxShift - maximum shift
%corrThresh - initial correlation threshold
%minSamp - minimum number of samples above threshold
%interpLevel - degree of interpolation
%
%ASM 9/13/13

%check if processed file exists
[~,tiffBase] = regexp(tiffFile,'.tif','match','split'); %remove .tif
tiffMat = [tiffBase{1},'.mat'];
if exist(tiffMat,'file') == 2 %if file exists
    %ask user if they'd like to continue
    contAns = questdlg(['Pre-processing file for ',tiffBase, 'already exists. Would you like ',...
        'to re-run with new parameters, completely, or not at all?'],...
        'Pre-processing file already exists',...
        'New Parameters','Complete re-run','Do Nothing','New Parameters');
    
    %process answer
    switch contAns
        case 'New Parameters'
            refFrameFlag = false;
        case 'Complete re-run'
            refFrameFlag = true;
        case {'Do Nothing',''}
            return;
    end 
else
    refFrameFlag = true;
end

if refFrameFlag
    %display notification
    fprintf('Loading tiff...');

    %get tiff name
    [tiffPath,tiffName] = fileparts(tiffFile);

    %get number of frames
    nFrames = getNPages(tiffFile);
    searchFrames=[0.375*nFrames 0.625*nFrames]; %get 3/8 and 5/8 frame indices
    searchFrames = floor(searchFrames);
    
    %first, load in the tiff file
    tiff = loadtiffAM(tiffFile,searchFrames(1):searchFrames(2));
    fprintf('Complete\n');
    
    %get height and width
    [height, width] = size(tiff);

    %determine reference frame
    fprintf('Finding reference frame...');
    refFrameID = findRefFrame(tiff,searchFrames);
    fprintf('Complete\n');

    %save refFrame ID to same file
    fprintf('Saving reference frame...');
    save(tiffMat,'refFrameID','tiffLoc','maxShift',...
        'corrThresh','minSamp','interpLevel','nFrames','height','width');
    fprintf('Complete\n');
else
    save(tiffMat,'maxShift','corrThresh','minSamp','interpLevel','-append');
end