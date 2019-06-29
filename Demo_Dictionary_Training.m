% ========================================================================
% Demo codes for dictionary training by joint sparse coding
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

clear all; clc; close all;
addpath(genpath('RegularizedSC'));

TR_IMG_PATH_HR = 'Data/Training/Training_SRTM1';
TR_IMG_PATH_LR = 'Data/Training/Training_SRTM3';


dict_size   = 512;          % dictionary size
lambda      = 0.1;           % sparsity regularization
patch_size  = 9;             % image patch size
nSmp        =100000;         % number of patches to sample
upscale     = 3;             % upscaling factor

% randomly sample image patches
[Xh, Xl] = rnd_smp_patch(TR_IMG_PATH_HR, TR_IMG_PATH_LR, '*.tif', patch_size, nSmp, upscale);

% prune patches with small variances, threshould chosen based on the
% training data
[Xh, Xl] = patch_pruning(Xh, Xl, 2);

% joint sparse coding 
[Dh, Dl] = train_coupled_dict(Xh, Xl, dict_size, lambda, upscale);
dict_path = ['Dictionary/D_' num2str(dict_size) '_' num2str(lambda) '_' num2str(patch_size) '.mat' ];
save(dict_path, 'Dh', 'Dl');