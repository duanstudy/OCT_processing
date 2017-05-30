function update_A_scan_ROI(directory, oct_extension)

    %% HOUSEKEEPING

        if nargin == 0
            directory = fullfile('.', 'data');
            oct_extension = 'img'; % TODO! update if you have mixed exts
        end

        curr_path = mfilename('fullpath');
        [curr_dir,filename,ext] = fileparts(curr_path);
        if isempty(curr_dir); curr_dir = pwd; end
        cd(curr_dir)
        
        % shared config for all the files
        config = read_config();
        
    %% Get file listing
    
        s = dir(fullfile(directory, ['*.', oct_extension]));
        file_list = {s.name}';
        no_of_files = length(file_list);
        disp([' - found ', num2str(no_of_files), ' image files'])
        
    %% Create the file listing for disk, and backup if needed
    
        fileOut = fullfile(directory, config.file_listing_txt);
    
        % if the text file exists alread
        if exist(fileOut, 'file') == 2
            disp(['The text file "', config.file_listing_txt, '" already exists'])
            
            % make backup
            % TODO! Add date to destination string, 
            % if you want to keep multiple backups without
            % overwriting
            source = fileOut;
            destination = [fileOut, '.bak'];
            [status,message,messageId] = copyfile(source, destination);
            
        else
            disp('This is the first time that you create file listing for this folder, correct?')
        end
        
        fid = fopen(fileOut, 'wt');
        
        
    %% Create cell for ouput
    
        config.crop_z_window = [55 75];
        config.crop_left_eye = [0 150];
        config.crop_right_eye = [362 512];
    
        z_min = config.crop_z_window(1);
        z_max = config.crop_z_window(2);
        left_min = config.crop_left_eye(1);
        left_max = config.crop_left_eye(2);
        right_min = config.crop_right_eye(1);
        right_max = config.crop_right_eye(2);
        
        for file = 1 : no_of_files
            
            output_cell{file, 1} = file_list{file};
            output_cell{file, 2} = z_min;
            output_cell{file, 3} = z_max;
            output_cell{file, 4} = left_min;
            output_cell{file, 5} = left_max;
            output_cell{file, 6} = right_min;
            output_cell{file, 7} = right_max;
            
        end
        
    %% Write to disk

        fprintf(fid, '%s\t%s\t%s\t%s\t%s\t%s\t%s\n', 'filename','z-min','z-max', ...
                                     'left_min','left_max','right_min','right_max');  % header        
                                 
        for i = 1:size(output_cell,1)
            fprintf(fid,'%s\t %d\t %d\t %d\t %d\t %d\t %d\t %d \n', output_cell{i,1},output_cell{i,2},output_cell{i,3},...
                                      output_cell{i,4},output_cell{i,5},output_cell{i,6},...
                                      output_cell{i,7});
        end
        fclose(fid);
        
        % TODO! Make a loop without the hard-coded indices
        
        
        
      
