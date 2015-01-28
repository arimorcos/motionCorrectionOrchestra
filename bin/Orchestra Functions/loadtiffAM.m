function [outIm,varargout] = loadtiffAM(path,ind,stripNum)

%create tiff
tiff = Tiff(path, 'r');

% if nargin < 4
%     checkExist = false;
% end

if nargin < 3
    stripNum = [];
end

if nargin < 2 || isempty(ind)
    nFrames = getNPages(path);
    ind = 1:nFrames;
end

if ~isnan(ind) 
    %get nFrames
    nFrames = length(ind);

    %get height, width and datatype
    tiff.setDirectory(ind(1));
    nCol = tiff.getTag('ImageWidth');
    nRows = tiff.getTag('ImageLength');
%     sampleForm = tiff.getTag('SampleFormat');
    sampleForm = 2;
%     bitsPerSamp = tiff. getTag('BitsPerSample');
    bitsPerSamp = 16;

    %initialize output
    if isempty(stripNum)
        outIm = zeros(nRows,nCol,nFrames,DataType(sampleForm,bitsPerSamp));
    else
        stripSize = zeros(1,length(stripNum));
        for i = 1:length(stripNum)
            stripSize(i) = size(tiff.readEncodedStrip(stripNum(i)),1);
        end
        outIm = zeros(sum(stripSize),nCol,nFrames,DataType(sampleForm,bitsPerSamp));
    end

    %cycle through each frame and read
    for i = 1:nFrames

    %     if checkExist
    %         if ~exist(path,'file') %if file no longer exists
    %             error('loadtiffAM:FileDisconnected','File no longer found');
    %         end
    %     end

        %change to proper frame
        tiff.setDirectory(ind(i));

        %load in frame
        if isempty(stripNum)
            outIm(:,:,i) = tiff.read();
        else
            for j = 1:length(stripNum)
                startInd = cumsum(stripSize(1:(j-1)))+1;
                if isempty(startInd); startInd = 1;end
                startInd = startInd(end);
                stopInd = cumsum(stripSize(1:j));
                stopInd = stopInd(end);
                outIm(startInd:stopInd,:,i) = tiff.readEncodedStrip(stripNum(j));
            end
        end

    end
else
    outIm = [];
end

% Scanimage metadata: Tiffs saved by Scanimage contain useful metadata in
% form of a struct. This data can be requested as a second output argument.
scanimage = [];
if nargout > 1 && any(strcmp('ImageDescription',tiff.getTagNames))
    imgDesc = tiff.getTag('ImageDescription');
    imgDescC = regexp(imgDesc, 'scanimage\..+? = .+?(?=\n)', 'match');
    imgDescC = strrep(imgDescC, '<nonscalar struct/object>', 'NaN');
    for e = imgDescC;
    	eval([e{:} ';']);
    end
%     scanimage = scanimage.SI4;
    varargout{1} = scanimage;
end
if nargout > 2
    varargout{2} = imgDesc;
end

%close tiff
tiff.close();


function out = DataType(sf, bpp)
switch sf
    case 1
        switch bpp
            case 8
                out = 'uint8';
            case 16
                out = 'uint16';
            case 32
                out = 'uint32';
        end
    case 2
        switch bpp
            case 8
                out = 'int8';
            case 16
                out = 'int16';
            case 32
                out = 'int32';
        end
    case 3
        switch bpp
            case 32
                out = 'single';
            case 64
                out = 'double';
        end
end
