function [ img_bg, bg, bg_coarse, ALLIND ] = background_correct_interp( img, varargin )
% This function obtains an estimate for the (non-uniform) background in img
% Step 1 is finding the 1% lowest intensity  pixels in ROIs spread across img
% Step 2 is averaging all of these reference pixels onto the ROI centers
% Step 3 is interpolating between the ROI centers and image edges.
% Step 4 is subtracting the interpolated background from the raw image
% In the (optional) last step, a uniform background is determined from the 
% intensity histogram and once more subtracted from the image.

% INPUT:    original image
%           (optional:) spacing for interpolation mesh
%           (optional:) global offset true/false (for last step)
% OUTPUT:   background-corrected image
%           background
%           coarse background (before interpolation)
%           ALLIND: indices of pixels that were classified as background.

% parse input
p = inputParser;
addRequired(p, 'img', @isnumeric)
addParameter(p, 'mSize', [100 100], @isnumeric)
addParameter(p, 'offset', false, @islogical)

parse(p, img, varargin{:})

img = p.Results.img;
mSize = p.Results.mSize;

% find indices of background pixels
y_mesh = 1:.2*mSize(1):size(img,1);
x_mesh = 1:.2*mSize(2):size(img,2);
N_mesh = numel(y_mesh)*numel(x_mesh);
ALLIND = zeros(round(N_mesh*0.01*prod(2*mSize+1)),1);
counter = 0;
hcount = 0;
h = waitbar(hcount,'Searching for background reference pixels...');
for i = y_mesh
    for j = x_mesh
        [A,B] = meshgrid(max(1,i-mSize(1)):min(size(img,1),i+mSize(1)), ...
                        max(1,j-mSize(2)):min(size(img,2),j+mSize(2)));  
        C = reshape(cat(2,A',B'),[],2);
        sub_ind = sub2ind(size(img), C(:,1), C(:,2));
        sub_img = img(sub_ind);
        tmpL = ceil(0.01*numel(sub_ind));
        [~,tmpI] = sort(sub_img);
        ALLIND(counter+(1:tmpL)) = sub_ind(tmpI(1:tmpL));
        counter = counter + tmpL;
        hcount = hcount+1;
        waitbar(hcount/N_mesh,h);
    end
end
close(h)
ALLIND = unique(nonzeros(ALLIND));
[ALLY,ALLX] = ind2sub(size(img),ALLIND);

% project (average) on grid positions
y_mesh = 1:mSize(1):size(img,1);
if y_mesh(end) < size(img,1)
    y_mesh = [y_mesh size(img,1)];
end
x_mesh = 1:mSize(2):size(img,2);
if x_mesh(end) < size(img,2);
    x_mesh = [x_mesh size(img,2)];
end
V = zeros(numel(y_mesh),numel(x_mesh));
for i = 2:length(y_mesh)-1
    for j = 2:length(x_mesh)-1
        tmpI = ALLIND(ALLY>y_mesh(i)-mSize(1) & ALLY<y_mesh(i)+mSize(1) ...
                        & ALLX>x_mesh(j)-mSize(2) & ALLX<x_mesh(j)+mSize(2));
        V(i,j) = mean(img(tmpI));
    end
end

% horizontal edges (minimum of adjacent e.g. 101 pixels)
for i = [1 length(y_mesh)]
    for j = 2:length(x_mesh)-1
        V(i,j) = min(img(y_mesh(i), ...
            x_mesh(j)-mSize(2):min(size(img,2),x_mesh(j)+mSize(2))));
    end
end

% vertical edges (minimum of adjacent e.g. 101 pixels)
for j = [1 length(x_mesh)]
    for i = 2:length(y_mesh)-1
        V(i,j) = min(img(y_mesh(i)-mSize(1):min(size(img,1),y_mesh(i)+mSize(1)), ...
            x_mesh(j)));
    end
end

% corners (minimum of adjacent e.g. 101 pixels)
for i = [1 length(y_mesh)]
    for j = [1 length(x_mesh)]
        V(i,j) = min([img(y_mesh(i),max(1,x_mesh(j)-mSize(2)):min(size(img,2),x_mesh(j)+mSize(2))) ...
            (img(max(1,y_mesh(i)-mSize(1)):min(size(img,1),y_mesh(i)+mSize(1)),x_mesh(j)))']);
    end
end

% interpolate to full image grid
[X,Y] = meshgrid(x_mesh,y_mesh);
[Xq,Yq] = meshgrid(1:size(img,2),1:size(img,1));
bg = interp2(X,Y,V,Xq,Yq);
bg_coarse = V;

% subtract interpolated background from image
img_bg = double(img)-bg;

% optional final step: determine offset from histogram and subtract.
if p.Results.offset
    [H, edges] = histcounts(img_bg(:),min(img_bg(:)):max(img_bg(:)));
    H = smooth(H,10);
    [~,index] = max(H);
    offset = (edges(index)+edges(index+1))/2;
    bg = bg+offset;
    img_bg = img_bg-offset;
end
end

