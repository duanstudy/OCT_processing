function [desired_ind, name_picked] = find_index_for_name(data_cell, desired_input_name)

    desired_ind = [];
    for i = 1 : length(data_cell)        
        if strcmpi(desired_input_name, data_cell{i}.name) == 1
            desired_ind = i;            
        end        
    end
    
    if isempty(desired_ind) == 1
        warning(['Your desired name = ', desired_input_name, ' was not found! Using the first index now'])
        desired_ind = 1;
        name_picked = data_cell{desired_ind}.name;
    else
        name_picked = desired_input_name;
    end