function checkMotCorrOrchProgress(src,evnt,ssh2_conn,jobs,nRuns,...
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

%get userData
results = get(motCorrTimer,'UserData');

%if first run, initialize
if isempty(results)
    %initialize results
    results.isMotCorDone = false;
    results.isCatDone = false;
end

%get main job status from bjobs
checkFlag = true;
while checkFlag
    try
        jobStatus = ssh2_simple_command(ssh2_conn.hostname,ssh2_conn.username,ssh2_conn.password,...
            ['bjobs -a -J ',jobs.jobNameMotCorr],0);
        checkFlag = false;
    end
end

%find number of pending jobs
nPend = length(strfind([jobStatus{:}],'PEND'));
if isempty(nPend); nPend = 0; end %set to 0 if empty

%find number of running jobs
nRunning = length(strfind([jobStatus{:}],'RUN'));
if isempty(nRunning); nRunning = 0; end %set to 0 if empty

%find number of completed jobs
nDone = length(strfind([jobStatus{:}],'DONE'));
if isempty(nDone); nDone = 0; end %set to 0 if empty

%find number of suspended jobs
nSusp = length(strfind([jobStatus{:}],'SSUSP'));
if isempty(nSusp); nSusp = 0; end %set to 0 if empty
nPend = nPend + nSusp;

%find out if some jobs have vanished (more than an hour since completed)
nFound = nPend + nRunning + nDone;
if nFound < nRuns
    %add difference to nDone
    nDone = nDone + (nRuns - nFound);
end

if nDone == nRuns %if all jobs complete
    results.isMotCorDone = true;
end

if results.isMotCorDone
    
    %is catDone?
    if ~results.isCatDone
        catFlag = true;
        while catFlag
            try
                catJobStatus = ssh2_simple_command(ssh2_conn.hostname,ssh2_conn.username,...
                    ssh2_conn.password,['bjobs -a -J ',jobs.jobNameCat],0);
                catFlag = false;
            end
        end
        if length(strfind([catJobStatus{:}],'RUN')) == 1 %if concat is running
            waitbarText = untexlabel(['Concatenating output for ',tiffBase]);
            waitbar(0,h,waitbarText);
        elseif length(strfind([catJobStatus{:}],'DONE')) == 1
            results.isCatDone = true;
            stop(motCorrTimer);
            
            waitbarText = untexlabel(['Copying motCorr output for',tiffBase,' to local drive...']);
            waitbar(0,h,waitbarText);
            
            delete(motCorrTimer);
        end
    end
else
    %update waitbar
    waitbarText = untexlabel([tiffBase,' -- Total Jobs: ',num2str(nRuns),'  Pending: ',num2str(nPend),...
        '  Running: ',num2str(nRunning),'  Completed: ',num2str(nDone)]);
    waitbar(nDone/nRuns,h,waitbarText);
end

%store updated results
set(motCorrTimer,'UserData',results);

end
