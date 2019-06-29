% =========================================================================
% Simple demo codes for image super-resolution via sparse representation
%
% Reference
%   J. Yang et al. Image super-resolution as sparse representation of raw
%   image patches. CVPR 2008.
%   J. Yang et al. Image super-resolution via sparse representation. IEEE 
%   Transactions on Image Processing, Vol 19, Issue 11, pp2861-2873, 2010
%
% Jianchao Yang
% ECE Department, University of Illinois at Urbana-Champaign
% For any questions, send email to jyang29@uiuc.edu
% =========================================================================

clear all; clc;

% read test image
im_l = imread('Data/Testing/TDM90ROI4.tif');

% set parameters
lambda = 0.4;                   % sparsity regularization
overlap = 5;                    % the more overlap the better (patch size 5x5)
up_scale = 3;                   % scaling factor, depending on the trained dictionary
maxIter = 60;                   % if 0, do not use backprojection


% load dictionary
load('Dictionary/D_1024_0.1_6.mat');

% change color space, work on illuminance only
%im_l_ycbcr = rgb2ycbcr(im_l);
im_l_y = im_l;
%im_l_cb = im_l_ycbcr(:, :, 2);
%im_l_cr = im_l_ycbcr(:, :, 3);

% image super-resolution based on sparse representation
% get initial X0
[im_h_y] = ScSR(im_l_y, up_scale, Dh, Dl, lambda, overlap);
im_test=im_h_y;
%SBTV SR
%get finial SR image
[im_h_y] = backprojection(im_h_y, im_l_y, maxIter);


% upscale the chrominance simply by "bicubic" 
[nrow, ncol] = size(im_h_y);
%im_h_cb = imresize(im_l_cb, [nrow, ncol], 'bicubic');
%im_h_cr = imresize(im_l_cr, [nrow, ncol], 'bicubic');

%im_h_ycbcr = zeros([nrow, ncol, 3]);
%im_h_ycbcr(:, :, 1) = im_h_y;
%im_h_ycbcr(:, :, 2) = im_h_cb;
%im_h_ycbcr(:, :, 3) = im_h_cr;
im_h = im_h_y;

% bicubic interpolation for reference
im_b = imresize(im_l, [nrow, ncol], 'bilinear');

% read ground truth image
im_file='Data/Testing/AW3D30ROI4.tif';
im = imread(im_file);

% compute PSNR for the illuminance channel
bb_rmse = compute_rmse(im, im_b);
sp_rmse = compute_rmse(im, im_h);

bb_psnr = 20*log10(255/bb_rmse);
sp_psnr = 20*log10(255/sp_rmse);

fprintf('RMSE for Bicubic Interpolation: %f dB\n', bb_rmse);
fprintf('RMSE for Sparse Representation Recovery: %f dB\n', sp_rmse);

% show the images
%figure, imagesc(im_h);
%title('Sparse Recovery');
%figure, imagesc(im_b);
%title('Bicubic Interpolation');

% write into geotiff file
[A,R]=geotiffread(im_file);
info=geotiffinfo(im_file);
geotiffwrite('Data/Testing/fusion.tif', im_h, R, 'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);
geotiffwrite('Data/Testing/bicubic_result.tif', im_b, R, 'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);