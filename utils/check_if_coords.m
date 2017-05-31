function coords_ind = check_if_coords(filename, list_of_filenames_with_coords)

    IndexC = strfind(list_of_filenames_with_coords, filename);
    if ~isempty(IndexC)
        coords_ind = find(not(cellfun('isempty', IndexC)));
    else
        % when the old list cell list is empty
        coords_ind = [];
    end