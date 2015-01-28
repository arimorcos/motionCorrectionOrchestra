function checkMotCorrOrchProgressimRegister(src,evnt,ssh2_conn,jobs,nRuns,...
    h,motCorrTimer,tiffBase)
%checkOrchProgress.m Function called by timer to check the progress of
%motion correction on orchestra
%
%INPUTS
%ssh2_conn - ssh2 connection structure created by ssh2_config
%jobs - structure containing job names
%nRuns - total number of jobs
%h - handle of waitbar
%motCorrTimer - handle of timer
%tiffBase - name of tif
%
%ASM27 9/13

%get main job status from bjobs
[~,jobStatus] = ssh2_command(ssh2_conn,['bjobs -a -J ',jobs.jobNameMotCorr],0);

%find number of pending jobs
nPend = length(strfind([jobStatus{:}],'PEND'));
if isempty(nPend); nPend = 0; end %set to 0 if empty

%find number of running jobs
nRunning = length(strfind([jobStatus{:}],'RUN'));
if isempty(nRunning); nRunning = 0; end %set to 0 if empty

%find number of completed jobs
nDone = length(strfind([jobStatus{:}],'DONE'));
if isempty(nDone); nDone = 0; end %set to 0 if empty

%check to make sure number of jobs adds up to total
nFound = nRunning + nDone + nPend;
if nFound ~= nRuns
    disp('Job counts don''t match...');
end

if nDone == nRuns %if all jobs complete
    %get cat job status from bjobs
    [~,jobStatus] = ssh2_command(ssh2_conn,['bjobs -a -J ',jobs.jobNameCat],0);
    if length(strfind([jobStatus{:}],'DONE')) == 1 %if cat job complete
        stop(motCorrTimer);
        
        waitbarText = untexlabel(['Copying shifted ',tiffBase,' to local drive...']);
        waitbar(0,h,waitbarText);
        
        close(h); %close waitbar
        delete(motCorrTimer);
    else
        waitbarText = untexlabel(['Concatenating output for ',tiffBase]);
        waitbar(0,h,waitbarText);
    end
else
    %update waitbar
    waitbarText = untexlabel([tiffBase,' -- Total Jobs: ',num2str(nRuns),'  Pending: ',num2str(nPend),...
        '  Running: ',num2str(nRunning),'  Completed: ',num2str(nDone)]);
    waitbar(nDone/nRuns,h,waitbarText);
end


end
