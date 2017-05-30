 % visualize
function visualize_L0(im, S, timing, titStr)

    scrsz = get(0,'ScreenSize'); % get screen size for plotting
    fig = figure('Color', 'w');
    
    rows = 3;
    cols = 4;
    warning('No adaptive layout scheme, uses 3x3 grid now')
      
    numberOfLambdas = size(S,1);
    numberOfKappas = size(S,2);
    
    
    for i = 1 : numberOfLambdas
        
        for j = 1 : numberOfKappas 
            
            ind = (i-1)*2 + 1;
            % ind = i; % (i-1)*numberOfLambdas + j;
            
                s(ind) = subplot(rows,cols, ind);
            
                    imH(ind) = imshow(S{i,j}, []);
                    titH(ind) = title(titStr{i,j});
                
            ind = (i-1)*2 + 2;
            
                s(ind) = subplot(rows,cols, ind);
            
                    % normalize for difference 
                    imNorm = double(im) / max(double(im(:)));
                    SNorm = S{i,j} / max(S{i,j}(:));
                    diff = imNorm -SNorm;
                
                    imH(ind) = imshow(diff, []);
                    titH(ind) = title(['Diff, t = ', num2str(timing(i,j))]);
            
            
        end
        
                
    end
    
    set(titH, 'FontSize', 7)
    
    