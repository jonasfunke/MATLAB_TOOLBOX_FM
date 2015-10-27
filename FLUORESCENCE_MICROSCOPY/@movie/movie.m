classdef movie < handle
    %TRACE_SELECTION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        frames; %all images to be read
        N_read = 300; % number of images to read in one portion
        counter = 1; % internal counter for reading the movie
        
        sequence; % sequence to be read, e.g. 101010
        first; % first image to be read
        last; % last image to be read
        
        pname; %pathname of file location
        fname; %filename of file
        
        sizeX; % number of pixel in X-dimension
        sizeY; % number of pixel in Y-dimension
        mov_length; % number of frames in thw whole movue
        
        info; %fits info
        h_min; %minimal heigth for peak fidning
        
        input; % 0=fits, 1=tiff-stack
        fnames; % cell with all filenames, only for tiff-stack
        
        N_frame_per_fits; % stores the number of frames in one fits-file
        
        drift; % stores displacement in x and y over whole movie through drift.
    end
      
end        