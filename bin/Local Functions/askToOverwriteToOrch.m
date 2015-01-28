function transferFlag = askToOverwriteToOrch(filesExist, filesToTransfer)
%askToOverwriteToOrch.m function to ask user which files should be
%overwritten
%
%INPUTS
%filesExist - logical of whether or not the files in filesToTransfer exist
%filesToTransfer - cell array of filenames to transfer
%
%OUTPUTS
%transferFlag - logical of whether or not each file should be transfered 
%
%ASM 9/13
transferFlag = true(size(filesToTransfer));
if all(filesExist) %if both of the files exist
    %ask user which file they'd like to move
    contAns = questdlg([filesToTransfer{1},' and ', filesToTransfer{2},...
        ' already exist on Orchestra. Would you like to re-copy?'],...
        'Files already exist',...
        'One','Both','Neither','Neither');
    
    switch contAns
        case 'One'
            contAns2 = questdlg('Which file would you like to overwrite?',...
                'File select',filesToTransfer{1},filesToTransfer{2},'Neither',filesToTransfer{1});
            switch contAns2
                case filesToTransfer{1}
                    transferFlag(2) = false;
                case filesToTransfer{2}
                    transferFlag(1) = false;
                case {'Neither',''}
                    transferFlag(:) = false;
            end
        case 'Both'
        case {'Neither',''}
            transferFlag(:) = false;
    end    
elseif filesExist(1) && ~filesExist(2) %if only the .tif exists
    contAns = questdlg([filesToTransfer{1},...
        ' already exist on Orchestra. Would you like to re-copy?'],...
        'File already exists',...
        'Yes','No','No');
    switch contAns
        case 'Yes'
        case 'No'
            transferFlag(1) = false;
    end
elseif filesExist(2) && ~filesExist(1) %if only the .mat exists
    contAns = questdlg([filesToTransfer{2},...
        ' already exists on Orchestra. Would you like to re-copy?'],...
        'File already exists',...
        'Yes','No','No');
    switch contAns
        case 'Yes'
        case 'No'
            transferFlag(2) = false;
    end
end