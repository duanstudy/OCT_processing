function update_A_scan_ROI(directory, file_list, oct_extension)

    %% HOUSEKEEPING

        if nargin == 0
            directory = fullfile('.', 'data');
            oct_extension = 'img'; % TODO! update if you have mixed exts
            s = dir(fullfile(directory, ['*.', oct_extension]));
            file_list = {s.name}';            
        end

        curr_path = mfilename('fullpath');
        [curr_dir,filename,ext] = fileparts(curr_path);
        if isempty(curr_dir); curr_dir = pwd; end
        cd(curr_dir)
        
        % shared config for all the files
        config = read_config();
        no_of_files = length(file_list);
        
        
    %% Create the file listing for disk, and backup if needed
    
        fileOut = fullfile(directory, config.file_listing_txt);
        file_specs_empty = 0;
    
        % if the text file exists alread
        if exist(fileOut, 'file') == 2
            disp(['The text file "', config.file_listing_txt, '" already exists'])
            
            % make backup
            datestring = datestr(now);
            datestring = strrep(datestring, ':', '');
            datestring = strrep(datestring, '-', '');
            datestring = strrep(datestring, ' ', '');            
            
            % if you want to keep multiple backups without
            % overwriting
            source = fileOut;
            destination = [fileOut, '.', datestring, '.bak.txt'];
            [status,message,messageId] = copyfile(source, destination);
            
            % check if there are new files
            file_specs = get_file_specs(directory, config.file_listing_txt);
            
        else
            disp('This is the first time that you create file listing for this folder, correct?')
            file_specs_empty = 1;
        end
        
       
        
        
    %% Create cell for ouput
    
        z_min = config.crop_z_window(1);
        z_max = config.crop_z_window(2);
        left_min = config.crop_left_eye(1);
        left_max = config.crop_left_eye(2);
        right_min = config.crop_right_eye(1);
        right_max = config.crop_right_eye(2);
        
        for file = 1 : no_of_files
            
            % the files with custom coordinates already
            if file_specs_empty == 0
                try 
                    coords_ind = check_if_coords(file_list{file}, file_specs.filename);            
                catch err
                    if strcmp(err.identifier, 'MATLAB:table:UnrecognizedVarName')
                        % for now some reason, the headers are gone and we
                        % cannot reference with the field names?
                        error('header fields are just as var1 / var2 / var3 / etc., they would need to have actually the variable names')                    
                    else
                        err
                    end
                end
            else
                coords_ind = [];
            end
            
            if isempty(coords_ind)
                disp(['+ New file = ', file_list{file}, ' detected, initialized with fixed coordinates to: ', config.file_listing_txt])
                output_cell{file, 1} = file_list{file};
                output_cell{file, 2} = z_min;
                output_cell{file, 3} = z_max;
                output_cell{file, 4} = left_min;
                output_cell{file, 5} = left_max;
                output_cell{file, 6} = right_min;
                output_cell{file, 7} = right_max;
                
            else
                disp(['| Not changing the coordinate values for ', file_list{file}])
                % Strictly speaking we are reading the contents of the file
                % and then writing on the text file, so if there are some
                % weird I/O problems, you will start to get garbage on your
                % text files.
                output_cell{file, 1} = file_specs.filename{file};
                output_cell{file, 2} = file_specs.z_min(file);
                output_cell{file, 3} = file_specs.z_max(file);
                output_cell{file, 4} = file_specs.left_min(file);
                output_cell{file, 5} = file_specs.left_max(file);
                output_cell{file, 6} = file_specs.right_min(file);
                output_cell{file, 7} = file_specs.right_max(file);
                
                % TODO! Check first if there are _ANY_ new files, and then
                % determine if something needs to be done, as now every
                % time some files values are written
                
            end
            
        end
        
    %% Write to disk

        write_coords_to_disk(fileOut, output_cell)
      
