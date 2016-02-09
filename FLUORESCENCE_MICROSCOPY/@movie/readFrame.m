function [img] = readFrame(obj,framenumber)
    %reads one frame
    if obj.input == 1 % tif
        img = double(imread([obj.pname filesep obj.fnames{framenumber}]));
    else
       i_fits = ceil(framenumber/obj.N_frame_per_fits);    % index of fits file
       framenumber_effective = mod(framenumber-1, obj.N_frame_per_fits) +1;
       img = fitsread([obj.pname filesep obj.fname{i_fits}],  'Info', obj.info{i_fits}, ...
           'PixelRegion',{[1 obj.sizeX], [1 obj.sizeY], [framenumber_effective framenumber_effective]}) ...
           + obj.add_upon_reading;  % fits - add_uppon_reading is either 0 or 2^15 (added as offset if intercept is 0)

    end
end
