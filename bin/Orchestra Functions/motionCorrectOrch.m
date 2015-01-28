function motionCorrectOrch(tiffLoc, refFrameID, testInd, maxShift,...
    corrThresh, minSamp, interpLevel, outName)
%motionCorrectOrch.m Calculates x and y shifts to minimize motion between a
%test frame and a reference frame. Optimized for the Orchestra cluster at
%HMS.
%
%INPUTS
%tiffLoc - filename (including path) of tiff
%refFrameID - index of reference frame
%testInd - array containing index of frame(s) to test
%maxShift - maximum shift to perform for correlation
%corrThresh - initial threshold for correlation. Used in centroid calc.
%minSamp - minimum number of samples above the correlation threshold for
%   acceptable motion correction
%interpLevel - level of interpolation (1 = no interpolation)
%outName - file name and path for .mat file to be saved
%
%OUTPUT
%no output but saves a file with xShifts and yShifts with '_frameID,'
%appended
%
%ASM 9/13/13 based off of track_subpixel_wholeframe_motion_varythresh CDH

%store number of comparisons
nComp = length(testInd);

%load the refFrameID, add to filesToLoad, and convert to 4 digit string
% refFrameID = sprintf('.Frame%04d',refFrameID);

% %convert frameIDs to load into strings
% filesToLoad = arrayfun(@(x) sprintf('.Frame%04d',x),testInd,'UniformOutput',false);
% 
% %find files matching pattern in tiffLoc
% testNames = whos('-file',tiffLoc,'-regexp',filesToLoad{:});
% testNames = {testNames(:).name};
% refName = whos('-file',tiffLoc,'-regexp',refFrameID);
% refName = refName(1).name;

% %load files
% filesToLoad = {testNames{:}, refName}; %#ok<CCAT>
% tFrames = load(tiffLoc, filesToLoad{:});

%load reference frame
refFrame = double(loadtiffAM(tiffLoc,refFrameID));
fprintf('Loaded refFrame\n');

%get frame size
[height, width] = size(refFrame);

%create testFrame array and load in testFrames
testFrames = double(loadtiffAM(tiffLoc,testInd));
% testFrames = zeros(height,weidth,length(testInd));
% for i = 1:length(testInd)
%     testFrames(:,:,i) = double(loadtiffAM(tiffLoc,testInd(i)));
% end    
fprintf('Loaded testFrames %s\n',datestr(now));

%calculate the total number of shifts
nShifts = 2*maxShift + 1;

%initialize cross correlation matrix
corrMat = zeros(nShifts,nShifts,nComp);

%get center of reference frame which will be compared 
centRefFrame = refFrame(1 + maxShift:height - maxShift,...
    1 + maxShift:width - maxShift);

%subtract mean from centRefFrame
centRefFrame = centRefFrame - mean(centRefFrame(:));

%reshape centRefFrame to vector
centRefFrame = reshape(centRefFrame, numel(centRefFrame), 1);

%copy refFrame for each comparison
centRefFrame = repmat(centRefFrame,[1 1 nComp]);

%calculate standard deviation
refFrameSTD = std(centRefFrame,0,1);
fprintf('Completed initialization %s\n',datestr(now));

%loop over all shift pairs
for xShift = -maxShift:maxShift
    for yShift = -maxShift:maxShift
        
        %cut out portion of frame for xShift,yShift pair
        tempTestFrames = testFrames(1 - yShift + maxShift:height - yShift - maxShift,...
            1 - xShift + maxShift:width - xShift - maxShift, :);
        
        %subtract the mean of each frame
        tempTestFrames = tempTestFrames - repmat(mean(mean(tempTestFrames,1),2),...
            [size(tempTestFrames,1) size(tempTestFrames,2) 1]);
        
        %reshape into a vector
        tempTestFrames = reshape(tempTestFrames, [numel(tempTestFrames(:,:,1)) 1 nComp]);
        
        %calculate the cross correlation for each frame
        corrMat(yShift + maxShift + 1, xShift + maxShift + 1,:) = ...
            mean(tempTestFrames.*centRefFrame,1)./(std(tempTestFrames,0,1).*refFrameSTD);
        
    end
end
fprintf('Completed shifts %s\n',datestr(now));

%initialize xShifts and yShifts
xShifts = zeros(1,nComp);
yShifts = zeros(1,nComp);
numSamples = zeros(1,nComp);
corrThresholds = zeros(1,nComp);

%generate interpolated shifts
interpShifts = -maxShift:1/interpLevel:maxShift;

%generate calculated shift values in meshgrid form
[xx, yy] = meshgrid(-maxShift:maxShift);

%generate interpolated shift values in meshgrid form
[xxi, yyi] = meshgrid(interpShifts);
fprintf('Complted interp initialization %s\n',datestr(now));

%track the centroid for each comparison
for i = 1:nComp
    
    %find centroid
    thisCorr = corrMat(:,:,i);
    
    %interpolate centroid
    thisCorrInterp = interp2(xx,yy,thisCorr,xxi,yyi);
    
    %decrease correlation threshold until number of samples is greater than
    %minSamp
    numSamplesHold = 0;
    corrThreshTemp = corrThresh;
    
    while numSamplesHold < minSamp
        
        
        %count the number of samples above threshold
        numSamples(i) = sum(thisCorrInterp(:) > corrThreshTemp);
        
        numSamplesHold = numSamples(i);
        if numSamplesHold < minSamp
            corrThreshTemp = corrThreshTemp - 0.025;
        end
    end
    
    %only show the thresholded centroid
    thisCorrInterp = thisCorrInterp.*(thisCorrInterp > corrThreshTemp);
    corrThresholds(i) = corrThreshTemp;
    
    %normalize centroid
    thisCorrInterp = thisCorrInterp/sum(thisCorrInterp(:));
    
    %calculate centroid center of mass
    xShifts(i) = sum(sum(thisCorrInterp.*xxi));
    yShifts(i) = sum(sum(thisCorrInterp.*yyi));
    
end
fprintf('Completed interpolation %s\n',datestr(now));

%store shiftInd for re-indexing
shiftInd = testInd;

%save relevant variables
save(outName,'shiftInd','xShifts','yShifts','corrThresholds','numSamples');

end