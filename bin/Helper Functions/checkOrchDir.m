function filesExist = checkOrchDir(ssh2_conn,remotePath,checkFiles,filesToTransfer)
%checkOrchDir.m function to check if orchestra directory exists and create
%it if it doesn't. Also checks if filesToTransfer exist
%
%INPUTS
%ssh2_conn - ssh2 connection structure created by ssh2_config
%remotePath - path (including directory) to check 
%checkFiles - whether or not filesToTransfer should be checked
%filesToTransfer - cell array of files to transfer
%
%OUTPUTS
%filesExist - 1 x length(filesToTransfer) logical of whether files exist

if nargin < 4; filesToTransfer = cell(1,2); end

%break up path to get parent directory
[parent,childDir] = fileparts(remotePath);

%get list of directories
command = ['cd ',parent,'; ls -d */'];
directories = ssh2_simple_command(ssh2_conn.hostname,ssh2_conn.username,...
    ssh2_conn.password,command,0);

%remove end slashes
directories = cellfun(@(x) x(1:end-1),directories,'UniformOutput',false);

%search for path
match = strcmp(directories,childDir);

%make directory if it doesn't exist
if ~any(match) %if directory doesn't exist
   
    command = ['mkdir -p ',remotePath];
    ssh2_simple_command(ssh2_conn.hostname,ssh2_conn.username,...
        ssh2_conn.password,command,0);
    
    %no files exist so set all to 0
    filesExist = false(1,length(filesToTransfer));
    
else %if directory does exist
    if checkFiles
        filesExist = false(1,length(filesToTransfer));

        for i=1:length(filesToTransfer) %for each file
            command = ['cd ',remotePath,'; ls ',filesToTransfer{i}];
            result = ssh2_simple_command(ssh2_conn.hostname,ssh2_conn.username,...
                ssh2_conn.password,command,0);
            
            if strcmp(result{1},filesToTransfer{i}) %if file matches
                filesExist(i) = true;
            elseif isempty(result{1}) %if empty result
                filesExist(i) = false;
            else
                error('Return from file list is neither empty nor matches file');
            end
        end
    end
end


end