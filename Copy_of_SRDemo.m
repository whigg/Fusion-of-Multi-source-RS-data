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
list=dir(fullfile('./Data/DEM_Data_1/ROI14/','*.tif'));
for k=1:length(list)
    LR(:,:,k)=double(imread(strcat('./Data/DEM_Data_1/ROI14/',list(k,1).name)));
end
TDMfile='./Data/DEM_Data_2/ROI14/TDM90_ROI14.tif';
im_l=double((imread(TDMfile)));

% load dictionary
load('./Dictionary/0423/D_1024_0.1_8.mat');

% spare representation SR
 % paramenters for spare representation SR
sparse.lambda=0.01;   % sparsity regularization%%%
sparse.overlap=7;    % the more overlap the better (patch size 5x5)
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
ref=imresize(imread('./Data/DEM_Data_2/ROI14/WORLDDEM_ROI14.tif'),0.4,'bicubic');
aster=double(imread('./Data/DEM_Data_2/ROI14/ASTER_ROI14.tif'));
% result of bicubic
                                      
% compute_Statistics
rmse=[];
[a1,b1,c1,d1,e1,f1,g1]=compute_Stats(ref,LR(:,:,1));rmse=[rmse;a1,b1,c1,d1,e1,f1,g1];
[a1,b1,c1,d1,e1,f1,g1]=compute_Stats(ref,LR(:,:,2));rmse=[rmse;a1,b1,c1,d1,e1,f1,g1];
[a1,b1,c1,d1,e1,f1,g1]=compute_Stats(ref,aster);rmse=[rmse;a1,b1,c1,d1,e1,f1,g1];
[a1,b1,c1,d1,e1,f1,g1]=compute_Stats(ref,HR);rmse=[rmse;a1,b1,c1,d1,e1,f1,g1];

% 
%% write into geotiff file
aw3d30=LR(:,:,1);srtm1=LR(:,:,2);
roidir='.\Data\DEM_Data_2\ROI14\ROI14_\'; 
if exist (roidir,'dir')==7
    rmdir (roidir, 's');  	
end
mkdir (roidir);	

tmpfile='./Data/DEM_Data_2/ROI14/TDM90_30_ROI14.tif';
[A,R]=geotiffread(tmpfile);info=geotiffinfo(tmpfile);
geotiffwrite(fullfile(roidir,'AW3D30_ROI14_.tif'),aw3d30,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
geotiffwrite(fullfile(roidir,'SRTM1_ROI14_.tif'),srtm1,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
geotiffwrite(fullfile(roidir,'ASTER_ROI14_.tif'),aster,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
geotiffwrite(fullfile(roidir,'Fusion_R_ROI14_.tif'),HR,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
%
geotiffwrite(fullfile(roidir,'bic-wdem_ROI14_.tif'),im_b-tam12,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
geotiffwrite(fullfile(roidir,'srtm1-wdem_ROI14_.tif'),srtm1-ref,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
geotiffwrite(fullfile(roidir,'aster-wdem_ROI14_.tif'),aster-ref,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
geotiffwrite(fullfile(roidir,'fusion-wdem_ROI14_.tif'),HR-ref,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);





%%----------------------------------------%%
%%计算统计量
tam12=imresize(imread('./Data/DEM_Data_2/ROI14/WORLDDEM_ROI14.tif'),0.4,'bicubic');   
im_b=imresize(imread('./Data/DEM_Data_2/ROI14/TDM90_ROI14.tif'),3,'bilinear'); 


aw3d30=imread('./Data/DEM_Data_2/ROI14/AW3D30_ROI14.tif'); 
srtm1=imread('./Data/DEM_Data_2/ROI14/SRTM1_ROI14.tif');
%aster=imread('./Data/DEM_Data_2/ROI14/ASTER_ROI14_.tif');
%HR=imread('./Data/DEM_Data_2/ROI14/ROI14_/Fusion_R_ROI14_.tif');
HR=imresize(imread('./Data/DEM_Data_2/ROI14/ROI14_/Fusion_R_ROI14_.tif'),2.5,'bicubic'); 
%%%---------%%%
ref=tam12(408:470,217:399);
im_b=im_b(408:470,217:399);
aw3d30=aw3d30(408:470,217:399);
srtm1=srtm1(408:470,217:399);
HR=HR(408:470,217:399);

rmse=[];
[a1,b1,c1,d1,e1,f1,g1]=compute_Stats(ref,im_b);rmse=[rmse;a1,b1,c1,d1,e1,f1,g1];
[a1,b1,c1,d1,e1,f1,g1]=compute_Stats(ref,aw3d30);rmse=[rmse;a1,b1,c1,d1,e1,f1,g1];
[a1,b1,c1,d1,e1,f1,g1]=compute_Stats(ref,srtm1);rmse=[rmse;a1,b1,c1,d1,e1,f1,g1];
[a1,b1,c1,d1,e1,f1,g1]=compute_Stats(ref,HR);rmse=[rmse;a1,b1,c1,d1,e1,f1,g1];


rmse=[];
[a1,b1,c1,d1,e1,f1,g1]=compute_Stats(ref,LR(:,:,1));rmse=[rmse;a1,b1,c1,d1,e1,f1,g1];
[a1,b1,c1,d1,e1,f1,g1]=compute_Stats(ref,LR(:,:,2));rmse=[rmse;a1,b1,c1,d1,e1,f1,g1];
[a1,b1,c1,d1,e1,f1,g1]=compute_Stats(ref,aster);rmse=[rmse;a1,b1,c1,d1,e1,f1,g1];
[a1,b1,c1,d1,e1,f1,g1]=compute_Stats(ref,HR);rmse=[rmse;a1,b1,c1,d1,e1,f1,g1];

%%计算差值等值线图
hold on


figure(1)
set(gcf,'unit','centimeters','position',[15.319 6.191 12.409 10.821]);
imagesc(im_b-ref);
%contourf(flipud(im_b-ref));
set(gca,'unit','centimeters','Position',[1 0.6 10 10]);
set(gca,'XTick',100:100:400,'YTick',100:100:400);
set(gca,'XTicklabel',{'3km','6km','9km','12km'},'FontSize',10.5);
set(gca,'YTicklabel',{'3km','6km','9km','12km'},'FontSize',10.5);
caxis([-15,15]);
colormap jet;
colorbar(gca,'Units','centimeters','Position',[11.2 0.7 0.5 9.9],'FontSize',10.5);
%16 26 33 40 50 

figure(2)
set(gcf,'unit','centimeters','position',[15.319 6.191 12.409 10.821]);
contourf(flipud(HR-ref));
set(gca,'unit','centimeters','Position',[1 0.6 10 10]);
set(gca,'XTick',100:100:400,'YTick',100:100:400);
set(gca,'XTicklabel',{'3km','6km','9km','12km'},'FontSize',10.5);
set(gca,'YTicklabel',{'3km','6km','9km','12km'},'FontSize',10.5);
caxis([-15,15]);
colormap jet;
colorbar(gca,'Units','centimeters','Position',[11.2 0.7 0.5 9.9],'FontSize',10.5);


figure(3)
set(gcf,'unit','centimeters','position',[15.319 6.191 12.409 10.821]);
contourf(flipud(aster-ref));
set(gca,'unit','centimeters','Position',[1 0.6 10 10]);
set(gca,'XTick',100:100:400,'YTick',100:100:400);
set(gca,'XTicklabel',{'3km','6km','9km','12km'},'FontSize',10.5);
set(gca,'YTicklabel',{'3km','6km','9km','12km'},'FontSize',10.5);
caxis([-15,15]);
colormap jet;
colorbar(gca,'Units','centimeters','Position',[11.2 0.7 0.5 9.9],'FontSize',10.5);


figure(4)  
set(gcf,'unit','centimeters','position',[15.319 6.191 12.409 10.821]);
contourf(flipud(HR-ref));
set(gca,'unit','centimeters','Position',[1 0.6 10 10]);
set(gca,'XTick',100:100:400,'YTick',100:100:400);
set(gca,'XTicklabel',{'3km','6km','9km','12km'},'FontSize',10.5);
set(gca,'YTicklabel',{'3km','6km','9km','12km'},'FontSize',10.5);
caxis([-15,15]);
colormap jet;
colorbar(gca,'Units','centimeters','Position',[11.2 0.7 0.5 9.9],'FontSize',10.5);


%%DEM原图 基于arcgis

