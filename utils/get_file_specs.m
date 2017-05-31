function file_specs = get_file_specs(directory, file_listing_txt)

    formatSpec = '%s %d %d %d %d %d %d';
    file_specs = readtable(fullfile(directory, file_listing_txt),...
                           'Delimiter','\t', 'Format', formatSpec);