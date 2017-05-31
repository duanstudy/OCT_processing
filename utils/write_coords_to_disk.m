function write_coords_to_disk(fileOut, output_cell)

    fid = fopen(fileOut, 'wt');
        
    % header  
    fprintf(fid, '%s\t %s\t %s\t %s\t %s\t %s\t %s\n', 'filename','z-min','z-max', ...
                                 'left_min','left_max','right_min','right_max');       

    % TODO! Not very adaptive way of writing a lot of variables to disk
    % now! You way want to make a loop here that allows you to specify also
    % a lot more ROIs on top of the rough crop indices for example?

    % For example if you want to calculate the ratios from multiple retinal
    % locations, 
    
    % TODO! Now also the reading part (get_file_specs.m) is quickly written 
    % and decoupled from this function, and you want to make the functions so that you would
    % only need to change the fields from one place, and still both reading
    % and writing would work
                             
    for i = 1:size(output_cell,1)

        fprintf(fid,'%s\t %d\t %d\t %d\t %d\t %d\t %d\n', ...
                    output_cell{i,1},output_cell{i,2},output_cell{i,3},...
                    output_cell{i,4},output_cell{i,5},output_cell{i,6},...
                    output_cell{i,7});
    end
    fclose(fid);

    % TODO! Make a loop without the hard-coded indices