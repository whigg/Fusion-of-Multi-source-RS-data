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
list=dir(fullfile('./Data/DEM_Data_1/ROI17/','*.tif'));
for k=1:length(list)
    LR(:,:,k)=double(imread(strcat('./Data/DEM_Data_1/ROI17/',list(k,1).name)));
end
TDMfile='./Data/DEM_Data_2/ROI17/TDM90_ROI17.tif';
im_l=double((imread(TDMfile)));

% load dictionary
load('./Dictionary/D_1024_0.1_8.mat');

% spare representation SR
 % paramenters for spare representation SR
sparse.lambda=0.01;   % sparsity regularization%%%
sparse.overlap=7;     % the more overlap the better (patch size 5x5)
sparse.up_scale=3;    % scaling factor, depending on the trained dictionary
sparse.maxIter=20;    % if 0, do not use backprojection


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
tam12=imresize(imread('./Data/DEM_Data_2/ROI14/WORLDDEM_ROI14.tif'),0.4,'bicubic');          tam12=tam12(2:end-2,2:end-2);%%
% result of bicubic
tam12=imread('./Data/DEM_Data_2/ROI14/WORLDDEM_ROI14.tif');

im_b=imresize(im_l,props.resFactor*sparse.up_scale,'bilinear');                         im_b=im_b(2:end-2,2:end-2);%%
toc
kri_roi=imread('./Data/DEM_Data_2/ROI4/TDM90_Kriging_ROI4.tif');                        kri_roi=kri_roi(2:end-2,2:end-2);%%
idw_roi=imread('./Data/DEM_Data_2/ROI4/TDM90_Idw_ROI4.tif');                            idw_roi=idw_roi(2:end-2,2:end-2);%%
HR=HR(2:end-2,2:end-2);HR_NSP=HR_NSP(2:end-2,2:end-2);
% compute_Statistics
rmse=[];
[a1,b1,c1,d1,e1,f1,g1]=compute_Stats(tam12,im_b);rmse=[rmse;a1,b1,c1,d1,e1,f1,g1];
[a1,b1,c1,d1,e1,f1,g1]=compute_Stats(tam12(kri_roi>-100000 & kri_roi<100000),kri_roi(kri_roi>-100000 & kri_roi<100000));rmse=[rmse;a1,b1,c1,d1,e1,f1,g1];
[a1,b1,c1,d1,e1,f1,g1]=compute_Stats(tam12(idw_roi>-100000 & idw_roi<100000),idw_roi(idw_roi>-100000 & idw_roi<100000));rmse=[rmse;a1,b1,c1,d1,e1,f1,g1];
%[a1,b1,c1,d1,e1,f1,g1]=compute_Stats(tam12,im_h);rmse=[rmse;a1,b1,c1,d1,e1,f1,g1];
[a1,b1,c1,d1,e1,f1,g1]=compute_Stats(tam12,LR(:,:,1));rmse=[rmse;a1,b1,c1,d1,e1,f1,g1];
[a1,b1,c1,d1,e1,f1,g1]=compute_Stats(tam12,LR(:,:,2));rmse=[rmse;a1,b1,c1,d1,e1,f1,g1];
%[a1,b1,c1,d1,e1,f1,g1]=compute_Stats(tam12,HR_NSP);rmse=[rmse;a1,b1,c1,d1,e1,f1,g1];
[a1,b1,c1,d1,e1,f1,g1]=compute_Stats(tam12,HR);rmse=[rmse;a1,b1,c1,d1,e1,f1,g1];

% 
%% write into geotiff file
%aw3d=LR(:,:,1);srtm1=LR(:,:,2);
roidir='.\Data\DEM_Data_2\ROI17\'; 
if exist (roidir,'dir')==7
    rmdir (roidir, 's');  	
end
mkdir (roidir);	

tmpfile='./Data/DEM_Data_2/ROI17/TDM90_30_ROI17.tif';
[A,R]=geotiffread(tmpfile);info=geotiffinfo(tmpfile);
geotiffwrite(fullfile(roidir,'BIC_ROI4_.tif'),im_b,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
geotiffwrite(fullfile(roidir,'Krig_ROI4_.tif'),kri_roi,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
geotiffwrite(fullfile(roidir,'IDW_ROI4_.tif'),idw_roi,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
geotiffwrite(fullfile(roidir,'Fusion_ROI17.tif'),HR,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
%
geotiffwrite(fullfile(roidir,'bic-tam12_ROI4.tif'),im_b-tam12,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
geotiffwrite(fullfile(roidir,'aw3d30-tam12_ROI4.tif'),double(aw3d30)-tam12,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
geotiffwrite(fullfile(roidir,'srtm1-tam12_ROI4.tif'),double(srtm1)-tam12,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
%geotiffwrite(fullfile(roidir,'fusion-nsp-tam12_ROI4_.tif'),HR_NSP-tam12,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
geotiffwrite(fullfile(roidir,'fusion-tam12_ROI4.tif'),HR-tam12,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
%


%%%




%%----------------------------------------%%
%%计算统计指标
tam12=imresize(imread('./Data/DEM_Data_2/ROI4/TDM12_ROI4.tif'),0.4,'bicubic');  
im_b=imread('./Data/DEM_Data_2/ROI4/ROI4_/TDM90_30_bic_ROI4.tif');
%kri_roi=imread('./Data/DEM_Data_2/ROI4/ROI4_/Krig_ROI4_.tif');
%idw_roi=imread('./Data/DEM_Data_2/ROI4/ROI4_/IDW_ROI4_.tif');
aw3d30=double(imread('./Data/DEM_Data_2/ROI4/ROI4_/AW3D30_ROI4.tif'));
srtm1=double(imread('./Data/DEM_Data_2/ROI4/ROI4_/SRTM1_ROI4.tif'));
%HR=imread('./Data/DEM_Data_2/ROI4/Fusion_ROI4_.tif');

rmse=[];
[a1,b1,c1,d1,e1,f1,g1]=compute_Stats(tam12,im_b);rmse=[rmse;a1,b1,c1,d1,e1,f1,g1];
%[a1,b1,c1,d1,e1,f1,g1]=compute_Stats(tam12(kri_roi>-100000 & kri_roi<100000),kri_roi(kri_roi>-100000 & kri_roi<100000));rmse=[rmse;a1,b1,c1,d1,e1,f1,g1];
%[a1,b1,c1,d1,e1,f1,g1]=compute_Stats(tam12(idw_roi>-100000 & idw_roi<100000),idw_roi(idw_roi>-100000 & idw_roi<100000));rmse=[rmse;a1,b1,c1,d1,e1,f1,g1];
[a1,b1,c1,d1,e1,f1,g1]=compute_Stats(tam12,aw3d30);rmse=[rmse;a1,b1,c1,d1,e1,f1,g1];
[a1,b1,c1,d1,e1,f1,g1]=compute_Stats(tam12,srtm1);rmse=[rmse;a1,b1,c1,d1,e1,f1,g1];
[a1,b1,c1,d1,e1,f1,g1]=compute_Stats(tam12,HR);rmse=[rmse;a1,b1,c1,d1,e1,f1,g1];

%%%计算差值等值线图
%%画在一张图
figure(1)
set(gcf,'unit','centimeters','position',[12.25 1.535 19.129 16.457]);
clim=[-15 15];
%%
ax1=subplot(2,2,1);
imagesc(aw3d30-tam12,clim);
set(ax1,'unit','centimeters','Position',[1 9.3 7 7]);
set(ax1,'XTick',100:100:400,'YTick',100:100:400);
set(ax1,'XTicklabel',{'3km','6km','9km','12km'},'FontSize',10.5);
set(ax1,'YTicklabel',{'3km','6km','9km','12km'},'FontSize',10.5);
colormap jet;
colorbar(ax1,'Units','centimeters','Position',[8.24 9.32 0.42 6.9],'FontSize',10.5);
caxis(clim);
annotation(gcf,'textbox','Units','centimeters',...
    'Position',[4.226 7.8317 1 1],...
    'String',{'(a)'},...
    'LineStyle','none',...
    'FontSize',14,...
    'HorizontalAlignment','left',...
    'VerticalAlignment','top',...
    'BackgroundColor',[1 1 1],...
    'FitBoxToText','on',...
    'FaceAlpha',0);
%%
ax2=subplot(2,2,2);
imagesc(srtm1-tam12,clim);
set(ax2,'unit','centimeters','Position',[10.7 9.3 7 7]);
set(ax2,'XTick',100:100:400,'YTick',100:100:400);
set(ax2,'XTicklabel',{'3km','6km','9km','12km'},'FontSize',10.5);
set(ax2,'YTicklabel',{'3km','6km','9km','12km'},'FontSize',10.5);
colormap jet;
colorbar(ax2,'Units','centimeters','Position',[17.94 9.32 0.42 6.9],'FontSize',10.5);
caxis(clim);
annotation(gcf,'textbox','Units','centimeters',...
    'Position',[13.936 7.8317 1 1],...
    'String',{'(b)'},...
    'LineStyle','none',...
    'FontSize',14,...
    'HorizontalAlignment','left',...
    'VerticalAlignment','top',...
    'BackgroundColor',[1 1 1],...
    'FitBoxToText','on',...
    'FaceAlpha',0);
%%
ax3=subplot(2,2,3);
imagesc(im_b-tam12,clim);
set(ax3,'unit','centimeters','Position',[1 1.1 7 7]);
set(ax3,'XTick',100:100:400,'YTick',100:100:400);
set(ax3,'XTicklabel',{'3km','6km','9km','12km'},'FontSize',10.5);
set(ax3,'YTicklabel',{'3km','6km','9km','12km'},'FontSize',10.5);
colormap jet;
colorbar(ax3,'Units','centimeters','Position',[8.24 1.12 0.42 6.9],'FontSize',10.5);
caxis(clim);
annotation(gcf,'textbox','Units','centimeters',...
    'Position',[4.226 -0.26421 1 1],...
    'String',{'(c)'},...
    'LineStyle','none',...
    'FontSize',14,...
    'HorizontalAlignment','left',...
    'VerticalAlignment','top',...
    'BackgroundColor',[1 1 1],...
    'FitBoxToText','on',...
    'FaceAlpha',0);
%%
ax4=subplot(2,2,4);
imagesc(HR-tam12,clim);
set(ax4,'unit','centimeters','Position',[10.7 1.1 7 7]);
set(ax4,'XTick',100:100:400,'YTick',100:100:400);
set(ax4,'XTicklabel',{'3km','6km','9km','12km'},'FontSize',10.5);
set(ax4,'YTicklabel',{'3km','6km','9km','12km'},'FontSize',10.5);
colormap jet;
colorbar(ax4,'Units','centimeters','Position',[17.94 1.12 0.42 6.9],'FontSize',10.5);
caxis(clim);
annotation(gcf,'textbox','Units','centimeters',...
    'Position',[13.936 -0.26421 1 1],...
    'String',{'(d)'},...
    'LineStyle','none',...
    'FontSize',14,...
    'HorizontalAlignment','left',...
    'VerticalAlignment','top',...
    'BackgroundColor',[1 1 1],...
    'FitBoxToText','on',...
    'FaceAlpha',0);
%%end


hold on
figure(3)
set(gcf,'unit','centimeters','position',[15.319 6.191 12.409 10.821]);
contourf(flipud(im_b-tam12));
%imagesc(im_b-tam12);
set(gca,'unit','centimeters','Position',[1 0.6 10 10]);
set(gca,'XTick',100:100:400,'YTick',100:100:400);
set(gca,'XTicklabel',{'3km','6km','9km','12km'},'FontSize',10.5);
set(gca,'YTicklabel',{'3km','6km','9km','12km'},'FontSize',10.5);
caxis([-15,15]);
colormap jet;
colorbar(gca,'Units','centimeters','Position',[11.2 0.7 0.5 9.9],'FontSize',10.5);
annotation(gcf,'textbox','Units','centimeters',...
    'Position',[1.6331 10.16 1.1642 0.82021],...
    'String',{'(a)'},...
    'LineStyle','none',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'VerticalAlignment','top',...
    'BackgroundColor',[1 1 1],...
    'FitBoxToText','on',...
    'FaceAlpha',0);
%16 26 33 40 50 

figure(2)
set(gcf,'unit','centimeters','position',[15.319 6.191 12.409 10.821]);
imagesc(aw3d30-tam12);
%contourf(flipud(aw3d30-tam12));
set(gca,'unit','centimeters','Position',[1 0.6 10 10]);
set(gca,'XTick',100:100:400,'YTick',100:100:400);
set(gca,'XTicklabel',{'3km','6km','9km','12km'},'FontSize',10.5);
set(gca,'YTicklabel',{'3km','6km','9km','12km'},'FontSize',10.5);
caxis([-15,15]);
colormap jet;
colorbar(gca,'Units','centimeters','Position',[11.2 0.7 0.5 9.9],'FontSize',10.5);

figure(3)
set(gcf,'unit','centimeters','position',[15.319 6.191 12.409 10.821]);
%imagesc(srtm1-tam12);
contourf(flipud(srtm1-tam12));
set(gca,'unit','centimeters','Position',[1 0.6 10 10]);
set(gca,'XTick',100:100:400,'YTick',100:100:400);
set(gca,'XTicklabel',{'3km','6km','9km','12km'},'FontSize',10.5);
set(gca,'YTicklabel',{'3km','6km','9km','12km'},'FontSize',10.5);
caxis([-15,15]);
colormap jet;
colorbar(gca,'Units','centimeters','Position',[11.2 0.7 0.5 9.9],'FontSize',10.5);


figure(4)  
set(gcf,'unit','centimeters','position',[15.319 6.191 12.409 10.821]);
imagesc(HR-tam12);
%contourf(flipud(HR-tam12));
set(gca,'unit','centimeters','Position',[1 0.6 10 10]);
set(gca,'XTick',100:100:400,'YTick',100:100:400);
set(gca,'XTicklabel',{'3km','6km','9km','12km'},'FontSize',10.5);
set(gca,'YTicklabel',{'3km','6km','9km','12km'},'FontSize',10.5);
caxis([-15,15]);
colormap jet;
colorbar(gca,'Units','centimeters','Position',[11.2 0.7 0.5 9.9],'FontSize',10.5);


%%DEM原图 基于arcgis

