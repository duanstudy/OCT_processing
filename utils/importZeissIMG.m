function Z = importZeissIMG(path, imName)
    
	fileInfo = dir(fullfile(path, imName)); % file info
	fileSize = fileInfo.bytes / (1024 * 1024); % in MBs

    % The img files contain the volume of collected data in 
    % unsigned integer with 128 B-scans of 512 A-scans, 
    % where each A-scan has 1024 pixels. Represents 6mm by 6mm by 2mm on the eye.
    % The data is stored by B-scan in the order that they were acquired, 
    % from the inferior retina to the superior retina.

	% Open as raw image file then
	row = 1024; 
	col = 512; 
	z = 128;
	fid=fopen(fullfile(path, imName),'r');
	I=fread(fid,row*col*z,'uint8=>uint8'); 
	Z=reshape(I,col,row,z); 

	% rotate image 90deg counter-clockwise
	Z = rot90(Z);