function [locations] = setWaitbarLoc(handles,widthFac)
%setWaitbarLoc.m calculates waitbar locations
%
%INPUTS 
%nBars - number of waitbars
%widthFac - ability to modify width
%
%OUTPUTS
%locations - nBars x 4 array of locations
%
%ASM 10/13

if nargin < 2 || isempty(widthFac)
    widthFac = 600;
end

%get nBars
nBars = length(handles);

%get screen size
scrSize = get(0,'screenSize');

%set width and height
width = widthFac*scrSize(3)/1920;
height = 103*scrSize(4)/1200;

%determine bottom for first waitbar
center = scrSize(4)/2;
allBottom = center - (height*nBars)/2;

%determine left coordinate
left = scrSize(3) - width - 0.01*scrSize(3);

%initialize array
locations = zeros(nBars,4);

%set left coordinate, width and height
locations(:,1) = left;
locations(:,3) = width;
locations(:,4) = height;

%set locations for bottom
for i = 1:nBars
    locations(nBars-i+1,2) = allBottom + (i-1)*height;
    set(handles(nBars-i+1),'Units','Pixels','OuterPosition',locations(nBars-i+1,:));
    childrenWaitb = get(handles(nBars-i+1), 'Children'); 
    set(childrenWaitb, 'Units','normalized','Position',[0.05 0.3 0.9 0.2]);
end