% BTV SR based on spare representation

clear all;clc
tic
% paramenters
props.maxIter=25;               % Number of iterations
props.alpha=0.7;                % The exponential decay coefficientrmse%%%
props.beta=1;                   % Iteration step
props.lambda=0.005;             % Regularization coefficient
props.P=3;                      % The spatial window size (radius)
props.T=40;                     % Threshold used to eliminate outliers
props.resFactor=1;              % resample factor

% load images 
list=dir(fullfile('./Data/DEM_Data_1/ROI4/','*.tif'));
for k=1:length(list)
    LR(:,:,k)=double(imread(strcat('./Data/DEM_Data_1/ROI4/',list(k,1).name)));
end
TDMfile='./Data/DEM_Data_2/ROI4/TDM90_ROI4.tif';
im_l=double((imread(TDMfile)));

% load dictionary
load('./Dictionary/D_1024_0.1_9.mat');

% spare representation SR
 % paramenters for spare representation SR
sparse.lambda=0.01;   % sparsity regularization%%%
sparse.overlap=8;    % the more overlap the better (patch size 5x5)
sparse.up_scale=3;   % scaling factor, depending on the trained dictionary
sparse.maxIter=20;   % if 0, do not use backprojection


%% image super-resolution based on sparse representation
im_h=ScSR(im_l,Dh,Dl,sparse);
LR(:,:,size(LR,3)+1)=im_h;
%
%% BTV SR
% blur matrix
% Hpsf = fspecial('gaussian', [3 3], 1);

% super resolution
% initial image HR0
% im_h=imresize(im_h,props.resFactor,'bicubic');
HR0=imresize(LR(:,:,1),props.resFactor,'bicubic');
HR=RobustSR(LR,HR0,im_h, props);

%% verify the accuracy 
tam12=imresize(imread('./Data/DEM_Data_2/ROI4/TDM12_ROI4.tif'),0.4,'bicubic');          tam12=tam12(2:end-2,2:end-2);%%
% result of bicubic

im_b=imresize(im_l,props.resFactor*sparse.up_scale,'bilinear');                         im_b=im_b(2:end-2,2:end-2);%%
toc
kri_roi=imread('./Data/DEM_Data_2/ROI4/TDM90_Kriging_ROI4.tif');                        kri_roi=kri_roi(2:end-2,2:end-2);%%
idw_roi=imread('./Data/DEM_Data_2/ROI4/TDM90_Idw_ROI4.tif');                            idw_roi=idw_roi(2:end-2,2:end-2);%%
                                                                                        HR=HR(2:end-2,2:end-2);
% compute_Statistics
rmse=[];
[a1,b1,c1,d1,e1,f1,g1]=compute_Stats(tam12,im_b);rmse=[rmse;a1,b1,c1,d1,e1,f1,g1];
[a1,b1,c1,d1,e1,f1,g1]=compute_Stats(tam12(kri_roi>-100000 & kri_roi<100000),kri_roi(kri_roi>-100000 & kri_roi<100000));rmse=[rmse;a1,b1,c1,d1,e1,f1,g1];
[a1,b1,c1,d1,e1,f1,g1]=compute_Stats(tam12(idw_roi>-100000 & idw_roi<100000),idw_roi(idw_roi>-100000 & idw_roi<100000));rmse=[rmse;a1,b1,c1,d1,e1,f1,g1];
%[a1,b1,c1,d1,e1,f1,g1]=compute_Stats(tam12,im_h);rmse=[rmse;a1,b1,c1,d1,e1,f1,g1];
%[a1,b1,c1,d1,e1,f1,g1]=compute_Stats(tam12,LR(:,:,1));rmse=[rmse;a1,b1,c1,d1,e1,f1,g1];
%[a1,b1,c1,d1,e1,f1,g1]=compute_Stats(tam12,LR(:,:,2));rmse=[rmse;a1,b1,c1,d1,e1,f1,g1];
[a1,b1,c1,d1,e1,f1,g1]=compute_Stats(tam12,HR);rmse=[rmse;a1,b1,c1,d1,e1,f1,g1];

% 
%% write into geotiff file
%aw3d=LR(:,:,1);srtm1=LR(:,:,2);
roidir='.\Data\DEM_Data_2\ROI4\ROI4_\'; 
if exist (roidir,'dir')==7
    rmdir (roidir, 's');  	
end
mkdir (roidir);	

tmpfile='./Data/DEM_Data_2/ROI4/TDM90_30_ROI4.tif';
[A,R]=geotiffread(tmpfile);info=geotiffinfo(tmpfile);
geotiffwrite(fullfile(roidir,'BIC_ROI4_.tif'),im_b,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
geotiffwrite(fullfile(roidir,'Krig_ROI4_.tif'),kri_roi,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
geotiffwrite(fullfile(roidir,'IDW_ROI4_.tif'),idw_roi,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
geotiffwrite(fullfile(roidir,'Fusion_NEW1024_NR_ROI4.tif'),HR,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
%
geotiffwrite(fullfile(roidir,'BIC-tam12_ROI4_.tif'),im_b-tam12,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
geotiffwrite(fullfile(roidir,'Krig-tam12_ROI4_.tif'),kri_roi-tam12,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
geotiffwrite(fullfile(roidir,'IDW-tam12_ROI4_.tif'),idw_roi-tam12,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
geotiffwrite(fullfile(roidir,'fusion-nsp-tam12_ROI4_.tif'),nsp-tam12,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
%


%%%
tmpfile='./Data/DEM_Data_2/ROI8/TDM90_30_ROI8.tif';
[A,R]=geotiffread(tmpfile);info=geotiffinfo(tmpfile);
geotiffwrite('./Data/DEM_Data_2/ROI8/Fusion.tif',HR,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);

%% draw difference image
sr4=compute_rmse(tam12,im_b);

sr5=compute_rmse(tam12,HR);rmse=[rmse;sr4];rmse=[rmse;sr5];
%
figure(1)
lims=[-25 20];
imagesc(tam12-LR(:,:,1),lims);
colorbar

figure(2)
imagesc(tam12-HRX0,lims);
colorbar

figure(3)
imagesc(tam12-HR,lims);
colorbar

tam=imresize(imread('./Data/DEM_Data_2/ROI11/TDM90_ROI11.tif'),3,'bicubic');
 LR(:,:,size(LR,3)+1)=tam;

