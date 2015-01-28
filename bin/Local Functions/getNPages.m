function nPages = getNPages(tiffFile,indStep)
%getNPages.m Function to discover the number of pages in a tiff stack
%
%INPUTS
%tiffFile - full file path of tiff
%
%OUTPUTS
%nPages - number of pages
%
%ASM 11/13

%create tiff object
tiff = Tiff(tiffFile,'r');

%initialize
lastDir = false; %last directory flag
if nargin < 2 || isempty(indStep)
    indStep = 1000; %initial step size
end
ind = 1; %first index

%use while loop to loop until found last directory
while ~lastDir
    try %try in case we try to set a directory which doesn't exist
        tiff.setDirectory(ind); %change to page ind
        if tiff.lastDirectory %if it's the last directory
            lastDir = true; %end the while loop
            nPages = ind; %set nPages to that
        end
    catch %if we passed the last directory 
        ind = ind - indStep; %go back to previous ind
        indStep = 0.1*indStep; %reduce step size
    end
    ind = ind + indStep; %increment step
end

%close
tiff.close();