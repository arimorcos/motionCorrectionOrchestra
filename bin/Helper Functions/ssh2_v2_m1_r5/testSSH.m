
%% establish connection
javaaddpath('D:\Dropbox\Matlab\Miscellaneous\ssh2_v2_m1_r5\ganymed-ssh2-build250\ganymed-ssh2-build250\ganymed-ssh2-build250.jar');
ssh2_conn = ssh2_config('orchestra.med.harvard.edu','ASM27','Atomicdog18');

%% print working directory
[ssh2_conn,result] = ssh2_command(ssh2_conn,'pwd',1);

%% issue basic commands
commStrBase = 'source ~/.bash_profile; ls; ';
commStr = [commStrBase];
[ssh2_conn,result] = ssh2_command(ssh2_conn,commStr,1);

%% close connection
ssh2_close(ssh2_conn);
