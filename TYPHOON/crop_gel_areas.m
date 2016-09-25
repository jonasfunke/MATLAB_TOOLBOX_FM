function [ imageData ] = crop_gel_areas( imageData )
% Select certain areas of interest from gel scans
% (often it is useful to do this prior to further analysis)
% Input: cell array of images
% Output: cell array of cropped images

for i = 1:length(imageData)
    cf = plot_image_ui(imageData{i});
    title('Crop gel: select area of gel for this evaluation', 'FontSize', 18)
    h = imrect(gca);
    setResizable(h,'true')
    cropos = round(wait(h));
    imageData{i} = imageData{i}(max(1,cropos(2)):min(size(imageData{i},1),sum(cropos([2 4]))), ...
                    max(1,cropos(1)):min(size(imageData{i},2),sum(cropos([1 3]))));
    close(cf)
end

