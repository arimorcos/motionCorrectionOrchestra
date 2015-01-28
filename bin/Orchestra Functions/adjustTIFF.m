function [shiftTIFF] = adjustTIFF(tiff,xShifts,yShifts,maxXShift,maxYShift,...
    minXShift,minYShift)
%adjustTIFF.m function to create new tiff with x/yShifts
%
%INPUTS
%tiff - tiff stack to be adjusted
%xShifts - 1 x nFrames vector of x shift values
%yShifts - 1 x nFrames vector of y shift values
%
%OUTPUTS
%shiftTiff - shifted tiff stack
%
%ASM 9/13 based off of playback_wholeframe_subpix CDH

%save the size of the movie
[height,width,nFrames] = size(tiff);

if nargin < 4
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

%calculate the new size of the movie which clips off the edges such that
%there are never any blank pixels
newHeight = height + minYShift - maxYShift;
newWidth = width + minXShift - maxXShift;

%initialize the matrix for the motion corrected movie
shiftTIFF = zeros(newHeight,newWidth,nFrames);

%loop over frames
for i = 1:nFrames

    %extract the current frame
    thisframe = double(tiff(:,:,i));

    %use linear interpolation to find the corrected movie at the standard
    %coordinates, given that the offsets are given relative to those
    %coordinates
    thisframe_interp = interp2((1:width)+xShifts(i),((1:height)+yShifts(i))',...
        thisframe,1:width,(1:height)','*linear');
   
    %save the result, clipping the edges as neccesary
    shiftTIFF(:,:,i) = thisframe_interp(1 + maxYShift:end + minYShift,...
        1 + maxXShift:end + minXShift);
end