
function [rmse,mae,mre,nmad,ave,max_,min_] = compute_Stats(im1, im2)

if size(im1, 3) == 3,
    im1 = rgb2ycbcr(im1);
    im1 = im1(:, :, 1);
end

if size(im2, 3) == 3,
    im2 = rgb2ycbcr(im2);
    im2 = im2(:, :, 1);
end

imdff = double(im2) - double(im1);
imdff = imdff(:);
% compute_rmse
rmse = sqrt(mean(imdff.^2));
% compute_mean
ave = mean(imdff);
% compute_max
max_ = max(imdff);
% compute_min
min_ = min(imdff);
% compute_MAE
mae=mean(abs(imdff));
% compute_MRE
ref=double(im1(:));
mre=100*mean(abs(imdff)./ref);
% compute_NMAD
med=median(imdff);
nmad=1.4826*median(abs(imdff-med));


end