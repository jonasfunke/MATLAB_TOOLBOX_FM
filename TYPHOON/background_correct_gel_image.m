function imageDataBgCorrected = background_correct_gel_image(imageData, varargin)
%% Loads image, fits lanes according to step function convolved with gaussian
%   INPUTS: imageData from load_gel_image.m
%           'numberOfAreas' (optional parameter) = set number of areas for
%           bg correction, default is 1
%   OUTPUT:
%   imageData struct from load_gel_image.m with .images replaced by background corrected images
% Example = background_correct_gel_image(img, 'numberOfAreas', 4)

%% parse input
p = inputParser;
default_n_ref_bg = 1; % default for number of references for background correction

addRequired(p,'imageData');
addParameter(p,'numberOfAreas',default_n_ref_bg, @isnumeric); 

parse(p, imageData, varargin{:});
n_ref_bg = p.Results.numberOfAreas;  % number of references for background correction

%% apply background correction to images

images_bg = cell(imageData.nrImages, 1);
background = cell(imageData.nrImages, 1); % stores bckground values
for i=1:imageData.nrImages
    [images_bg{i}, background{i}] = correct_background(imageData.images{i}, 'areas', n_ref_bg); % subtract a constant from each image  
end
%% create imageDataBgCorrected structure, return imageDataBgCorrected structure

imageData.images=images_bg;
imageData.background = background;
imageDataBgCorrected=imageData;