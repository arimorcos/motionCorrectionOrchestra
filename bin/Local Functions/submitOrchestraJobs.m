function submitOrchestraJobs(orchInfo,ind)
%submitOrchestraJobs.m Submits jobs for staggered file starts
%
%INPUTS
%orchInfo - structure containing necessary info
%ind of file
%
%ASM 10/13

%calculate nRuns and filesPerCall such that each job takes ~10 minutes
%(~10^4 operations -- maxShift^2 * filesPerCall)
waitbarText{ind} = untexlabel(['Calculating job breakdown for ',orchInfo.tiffBase{ind}]);
waitbar(0,orchInfo.h(ind),waitbarText{ind});

load([fullfile(orchInfo.tiffPaths{ind},orchInfo.tiffBase{ind}),'.mat'],'nFrames');
if nFrames < 3000
    filesPerCall = round(2500/orchInfo.maxShift^2);
else
    filesPerCall = round(15000/orchInfo.maxShift^2);
end
nRuns = ceil(nFrames/filesPerCall); %ceil to ensure the remainder of files don't get missed

%generate large random number to serve as job name
jobs.jobNameMotCorr = genJobName(10,false);
jobs.jobNameCat = genJobName(10,false);

%generate fileID
fileID = genJobName(10,false);

%submit commands to orchestra telling it to run motion correction
%     waitbar(0,hWait,'Submitting jobs...');
waitbarText{ind} = untexlabel(['Submitting jobs for ',orchInfo.tiffBase{ind}]);
waitbar(0,orchInfo.h(ind),waitbarText{ind});

refInfoFileLoc = [orchInfo.remotePath,'/',orchInfo.tiffBase{ind},'.mat'];
% command = ['cd ',orchInfo.remotePath,'; ./run_motionCorrect.sh run_motionCorrect ',...
%     jobs.jobNameMotCorr,' ',num2str(nRuns),' ',num2str(filesPerCall),...
%     ' \''',refInfoFileLoc,'\'' \''',[orchInfo.remotePath,'/motionOut'],'\'' ',...
%     jobs.jobNameCat,' ',fileID];
command = ['cd ',orchInfo.remotePath,'; ./run_motionCorrect_repeat.sh run_motionCorrect_repeat ',...
    jobs.jobNameMotCorr,' ',num2str(nRuns),' ',num2str(filesPerCall),...
    ' \''',refInfoFileLoc,'\'' \''',[orchInfo.remotePath,'/motionOut'],'\'' ',...
    jobs.jobNameCat,' ',fileID];
[~,result] = ssh2_command(orchInfo.ssh2_conn,command,0);
if isempty(result{1});delete(orchInfo.h(ind));error('bsub command failure'); end

%create a timer object to check job statuses
%     waitbar(0,hWait,'Jobs submitted successfully. Getting job status...');
waitbarText{ind} = untexlabel(['Jobs submitted successfully for ',...
    orchInfo.tiffBase{ind},'. Getting job status...']);
waitbar(0,orchInfo.h(ind),waitbarText{ind});

save([fullfile(orchInfo.tiffPaths{ind},orchInfo.tiffBase{ind}),'.mat'],...
    'jobs','-append');

motCorrTimer = timer('ExecutionMode','FixedSpacing','Period',5,'StartDelay',5,'Name','MotCorrTimer');
set(motCorrTimer,'TimerFcn',{@checkMotCorrOrchProgress,orchInfo.ssh2_conn,jobs,nRuns,...
    orchInfo.h(ind),motCorrTimer,orchInfo.tiffBase{ind}},...
    'StopFcn',{@copyMotCorrOutputFinish,orchInfo.ssh2_conn,orchInfo.h(ind),...
    orchInfo.tiffPaths{ind},orchInfo.remotePath,orchInfo.tiffBase{ind},...
    orchInfo,ind});
start(motCorrTimer);