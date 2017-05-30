function write_coords_to_disk(fileOut, output_cell)

    fid = fopen(fileOut, 'wt');
        
    % header  
    fprintf(fid, '%s\t %s\t %s\t %s\t %s\t %s\t %s\n', 'filename','z-min','z-max', ...
                                 'left_min','left_max','right_min','right_max');       

    for i = 1:size(output_cell,1)

        fprintf(fid,'%s\t %d\t %d\t %d\t %d\t %d\t %d\n', ...
                    output_cell{i,1},output_cell{i,2},output_cell{i,3},...
                    output_cell{i,4},output_cell{i,5},output_cell{i,6},...
                    output_cell{i,7});
    end
    fclose(fid);

    % TODO! Make a loop without the hard-coded indices