function [ avg_frame ] = average_image(obj, N_min, N_frame )
    % generate average image, starting from N_min frame for N_frame, until N_max
    
    N_max=N_min+N_frame;

        if N_max <= 0 ||  N_max >= obj.mov_length   % adjust to full movie lenght
            N_max = obj.mov_length; 
        end
        
        avg_frame = zeros(obj.sizeX, obj.sizeY);

        go_on = 1;
        obj.counter = N_min; %start frame for averaging 
        N = 0;
        
        while go_on
            [movie, frames, go_on]  = obj.readNext;

            if N+length(frames) < N_max
                avg_frame = avg_frame + sum(movie,3);
                N = N + length(frames);
            else
                k = min(N_max-N, length(frames));
                avg_frame = avg_frame + sum(movie(:,:,1:k),3);
                N = N + k;
                go_on = 0;
            end
        end
        
    avg_frame = avg_frame ./ N; 
    
    display(['Average image generate with frames ' num2str(obj.counter) ' to ' num2str(N_max)])
    
end