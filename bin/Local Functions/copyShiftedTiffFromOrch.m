function copyShiftedTiffFromOrch(src,evnt,ssh2_struct,localPath,tiffBase,remotePath)
%copyShiftedTiffFromOrch.m function to copy files from orchestra back to
%start directory
%
%INPUTS 
%ssh2_struct - ssh2_struc created by ssh2_config
%localPath - path where file should be saved
%tiffBase - baseName of tiff
%remotePath - path containing orchestra output
%
%ASM 9/13

%get file names to copy
matTiff = [tiffBase,'_MotCorrOut.mat'];
shiftTiff = [tiffBase,'_motionCorrected.tif'];
filesToTransfer = {matTiff,shiftTiff};

%copy files
scp_get(ssh2_struct, filesToTransfer, localPath, remotePath);

%delete remote files
matTiff = [remotePath,'/',matTiff];
shiftTiff = [remotePath,'/',shiftTiff];
origTiff = [remotePath,'/',tiffBase,'.tif'];
origMat = [remotePath,'/',tiffBase,'.mat'];
ssh2_command(ssh2_struct,['rm ',matTiff],0);
ssh2_command(ssh2_struct,['rm ',shiftTiff],0);
ssh2_command(ssh2_struct,['rm ',origTiff],0);
ssh2_command(ssh2_struct,['rm ',origMat],0);




