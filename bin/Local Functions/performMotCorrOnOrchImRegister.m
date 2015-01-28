function performMotCorrOnOrchImRegister(silent,motCorrInfo)
%peformMotCorrOnOrch.m Master function to perform motion correction using
%the orchestra cluster at Harvard Medical School
%
%
%ASM 9/13

if nargin < 1 || isempty(silent)
    silent = false;
end

%debug mode
debug = false;
if debug
    tiffFile = 'D:\DATA\2P Data\ResScan\AP02\130914\AP02_2x_Stack__001_001.tif';
    [tiffPath,tiffName] = fileparts(tiffFile);
    tiffBase = tiffName;
    tiffName = [tiffBase,'.tif'];
    maxShift = 10;
    corrThresh = 0.75;
    minSamp = 75;
    interpLevel = 4;
    userName = '';
    password = '';
end

if ~debug && ~silent
    %ask user for file which should be motion corrected
%     [tiffName, tiffPath] = uigetfile('*.tif');
%     tiffFile = fullfile(tiffPath,tiffName);
    [tiffNames,tiffPaths,tiffFiles] = getTIFFNames();
    [~,tiffBase] = regexp(tiffNames,'.tif','match','split'); %remove .tif
    tiffBase = cellfun(@(x) x{1},tiffBase,'UniformOutput',false);
    
    if isempty(tiffNames)
        return;
    end
    
    %ask user for orchestra username and password
    [userName, password] = logindlg('Title','Orchestra Login Info');

    %ask user for motion correction parameters
    options.WindowStyle = 'normal';
    options.Resize = 'on';
    paramNames = {'Maximum Shift','Initial Correlation Threshold',...
        'Minimum Samples','Interpolation Level'};
    motCorrParam = inputdlg(paramNames,'Enter Motion Correction Parameters',...
        repmat([1 60],4,1),{'10','0.75','75','4'},options);

    %convert to double
    maxShift = str2double(motCorrParam{1});
    corrThresh = str2double(motCorrParam{2});
    minSamp = str2double(motCorrParam{3});
    interpLevel = str2double(motCorrParam{4});
elseif ~debug && silent
    tiffNames = motCorrInfo.tiffNames;
    tiffPaths = motCorrInfo.tiffPaths;
    tiffFiles = motCorrInfo.tiffFiles;
    userName = motCorrInfo.userName;
    password = motCorrInfo.password;
    maxShift = motCorrInfo.maxShift;
    corrThresh = motCorrInfo.corrThresh;
    minSamp = motCorrInfo.minSamp;
    interpLevel = motCorrInfo.interpLevel;
end

%create waitbar for each file
h = zeros(1,length(tiffFiles));
waitbarText = cell(1,length(tiffFiles));
for i = 1:length(tiffFiles)
    waitbarText{i} = untexlabel(['Preparing ',tiffBase{i},'.tif for motion correction...']);
    h(i) = waitbar(0,waitbarText{i},'Name','Motion Correction On Orch');
end
setWaitbarLoc(h);

%perform pre-processing
remotePath = ['/hms/scratch1/',userName,'/motionCorrect'];
for i = 1:length(tiffFiles)
    fprintf('%s \n',tiffFiles{i});
    preOrchMotionCorrect(tiffFiles{i},[remotePath,'/',tiffNames{i}],maxShift,...
        corrThresh,minSamp,interpLevel);
end

%establish ssh2 connection structure
% waitbar(0,hWait,'Initializing ssh connection...');
for i = 1:length(tiffFiles)
    waitbarText{i} = untexlabel('Initializing ssh connection...');
    waitbar(0,h(i),waitbarText{i});
end

hostName = 'orchestra.med.harvard.edu';
[packagePath,~] = fileparts(which('performMotCorrOnOrch.m')); %get path of package
javaaddpath(fullfile(packagePath,'bin','Helper Functions','ssh2_v2_m1_r5',... %add java library to path
    'ganymed-ssh2-build250','ganymed-ssh2-build250','ganymed-ssh2-build250.jar'));
ssh2_conn = ssh2_config(hostName,userName,password);

%copy bash files
copyBASHRC(ssh2_conn,userName);

%copy .tif and .mat to scratch1
% waitbar(0,hWait,'Copying files to Orchestra (this will take 3-5 minutes per file)');
for i = 1:length(tiffFiles)
    waitbarText{i} = untexlabel(['Waiting to copy ',...
        tiffBase{i},' to Orchestra']);
    waitbar(0,h(i),waitbarText{i});
end
for i = 1:length(tiffFiles)
    waitbarText{i} = untexlabel(['Copying ',...
        tiffBase{i},' to Orchestra (this will take 3-5 minutes per file)']);
    waitbar(0,h(i),waitbarText{i});
    
    filesToTransfer = {tiffNames{i},[tiffBase{i},'.mat']};
    filesExist = checkOrchDir(ssh2_conn,remotePath,true,filesToTransfer); %check if directory exists and create if necessary. Check if file exists
    transferFlag = askToOverwriteToOrch(filesExist, filesToTransfer); %ask user which files should be transfered
    if any(transferFlag) %if any of the files should be transfered
        scp_put(ssh2_conn,filesToTransfer(transferFlag),remotePath,tiffPaths{i}); %copy files
    end
    waitbar(1,h(i),waitbarText{i});
end

%delete everything in motionOut
ssh2_command(ssh2_conn,['rm -rf ',remotePath,'/motionOut']);

%ensure ~/motionOut exists
% waitbar(0,hWait,'Checking to make sure all necessary files present...');
for i = 1:length(tiffFiles)
    waitbarText{i} = 'Checking to make sure all necessary files present...';
    waitbar(0,h(i),waitbarText{i});
end
checkOrchDir(ssh2_conn,[remotePath,'/motionOut'],false);

%ensure all necessary files exist
necFiles = dir2cell(fullfile(packagePath,'bin','Orchestra Functions'));
necFiles = necFiles(~ismember(necFiles,{'.','..'})); %remove . and .. from dir
checkMFilesOrch(ssh2_conn,remotePath,necFiles,fullfile(packagePath,'bin','Orchestra Functions'),true);

for i = 1:length(tiffFiles)
    %calculate nRuns and filesPerCall such that each job takes ~10 minutes
    %(~10^4 operations -- maxShift^2 * filesPerCall)
%     waitbar(0,hWait,'Calculating job breakdown...');
    waitbarText{i} = untexlabel(['Calculating job breakdown for ',tiffBase{i}]);
    waitbar(0,h(i),waitbarText{i});
    
%     filesPerCall = round(2500/maxShift^2);
    filesPerCall = 20;
    load([fullfile(tiffPaths{i},tiffBase{i}),'.mat'],'nFrames');
    nRuns = ceil(nFrames/filesPerCall); %ceil to ensure the remainder of files don't get missed

    %generate large random number to serve as job name
    jobs.jobNameMotCorr = genJobName(10,false);
    jobs.jobNameCat = genJobName(10,false);
    
    %generate fileID
    fileID = genJobName(10,false);

    %submit commands to orchestra telling it to run motion correction
%     waitbar(0,hWait,'Submitting jobs...');
    waitbarText{i} = untexlabel(['Submitting jobs for ',tiffBase{i}]);
    waitbar(0,h(i),waitbarText{i});
    
    refInfoFileLoc = [remotePath,'/',tiffBase{i},'.mat'];
    command = ['cd ',remotePath,'; ./run_motionCorrectimRegister.sh run_motionCorrectimRegister ',...
        jobs.jobNameMotCorr,' ',num2str(nRuns),' ',num2str(filesPerCall),...
        ' \''',refInfoFileLoc,'\'' \''',[remotePath,'/motionOut'],'\'' ',...
        jobs.jobNameCat,' ',fileID];
    [~,result] = ssh2_command(ssh2_conn,command,0);
    if isempty(result{1});delete(hWait);error('bsub command failure'); end
    
    %create a timer object to check job statuses
%     waitbar(0,hWait,'Jobs submitted successfully. Getting job status...');
    waitbarText{i} = untexlabel(['Jobs submitted successfully for ',...
        tiffBase{i},'. Getting job status...']);
    waitbar(0,h(i),waitbarText{i});
    
    motCorrTimer = timer('ExecutionMode','FixedSpacing','Period',5,'StartDelay',5,'Name','MotCorrTimer');
    set(motCorrTimer,'TimerFcn',{@checkMotCorrOrchProgressimRegister,ssh2_conn,jobs,nRuns,...
        h(i),motCorrTimer,tiffBase{i}},'StopFcn',{@copyShiftedTiffFromOrch,ssh2_conn,tiffPaths{i},...
        tiffBase{i},remotePath,});
    start(motCorrTimer);
end






