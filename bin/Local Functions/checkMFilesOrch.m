function checkMFilesOrch(ssh2_conn,remotePath,necessaryFiles,localPath,overwrite)
%checkMFilesOrch.m Function to check if necessary files exist on the
%orchestra cluster and to copy if necessary
%
%INPUTS
%ssh2_conn - ssh2 connection established by ssh2_config
%remotePath - path to directory where files should exist
%necessaryFiles - cell array of files
%localPath - path of local files
%overwrite - boolean to always transfer and overwrite
%
%ASM 9/13

%get list of files in path
command = ['cd ',remotePath,'; ls'];
fileList = ssh2_simple_command(ssh2_conn.hostname,ssh2_conn.username,...
    ssh2_conn.password,command,0);

%compare needed files to present files
if overwrite
    filesExist = zeros(size(necessaryFiles));
else
    filesExist = ismember(necessaryFiles,fileList);
end

if overwrite || ~all(filesExist) %if every file does not already exist
    
    %transfer files which need to be transfered
    scp_simple_put(ssh2_conn.hostname,ssh2_conn.username,ssh2_conn.password,...
        necessaryFiles(~filesExist),remotePath,localPath);
       
end

%make sure run_motionCorrect.sh is executable
ssh2_simple_command(ssh2_conn.hostname,ssh2_conn.username,ssh2_conn.password,...
    ['cd ',remotePath,'; chmod +x run_motionCorrect.sh'],0);
ssh2_simple_command(ssh2_conn.hostname,ssh2_conn.username,ssh2_conn.password,...
    ['cd ',remotePath,'; chmod +x run_motionCorrectimRegister.sh'],0);
ssh2_simple_command(ssh2_conn.hostname,ssh2_conn.username,ssh2_conn.password,...
    ['cd ',remotePath,'; chmod +x run_motionCorrect_repeat.sh'],0);
ssh2_simple_command(ssh2_conn.hostname,ssh2_conn.username,ssh2_conn.password,...
    ['cd ',remotePath,'; chmod +x motCorr_repeat.sh'],0);
end