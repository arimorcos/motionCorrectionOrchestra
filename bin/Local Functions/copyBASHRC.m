function copyBASHRC(ssh_conn,userName)
%copyBASHRC.m function to copy .bashrc to home directory
%
%INPUTS
%ssh_conn - ssh connection created by ssh2_config
%userName - username
%
%ASM 9/13

%get local path
[bashPath,~] = fileparts(which('copyBASHRC.m')); 

%create remotePath
remotePath = ['/home/',userName];

%copy
scp_simple_put(ssh_conn.hostname,ssh_conn.username,ssh_conn.password,...
    '.bashrc',remotePath,bashPath);
scp_simple_put(ssh_conn.hostname,ssh_conn.username,ssh_conn.password,...
    '.bash_profile',remotePath,bashPath);