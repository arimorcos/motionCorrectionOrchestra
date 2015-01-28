function frameID = findRefFrame(tiff,searchFrames)
%findRefFrame.m Finds reference frame for motion correction by determining
%frameID within middle 1/4 of frames with least motion
%
%INPUTS
%
%tiff - tiff stack to be motion corrected
%
%OUTPUTS frameID - index of reference frame
%
%ASM 9/13/13

if nargin < 2 || isempty(searchFrames)
    %find nFrames
    nFrames = size(tiff,3);

    %find search range
    searchFrames=[0.375*nFrames 0.625*nFrames]; %get 3/8 and 5/8 frame indices
    searchFrames = floor(searchFrames);
    
    cropTiff = tiff(:,:,searchFrames(1):searchFrames(2));
else
    cropTiff = tiff;
end

%determine minimum change get difference of firing between search frames
tempStill = abs(diff(cropTiff,1,3)); 

%take mean of each frame
tempStill = mean(mean(tempStill)); 

%compress 3rd dimension (mean difference value for each frame) to column
%vector
tempStill = squeeze(tempStill); 

%find the minimum mean pixel value, presumably corresponding to the least
%change from frame to frame within the search window
[~,minInd]=min(tempStill); 

frameID = searchFrames(1)+minInd-1;