function TPSprocessDemotion(ew,ns,origin)
tic
clc
clear
ew='./Data/DEM_Data_2/ROI15/AW3D30_EW_ROI15.tif';
ns='./Data/DEM_Data_2/ROI15/AW3D30_NS_ROI15.tif';
origin='./Data/DEM_Data_1/ROI15/AW3D30_ROI15.tif';

%读取ew影像，并计算ewmin,ewmax锁定数据范围
ew1=double(imread(ew));
ewmin=mean2(ew1)-1.96*std(ew1(:),0);
ewmax=mean2(ew1)+1.96*std(ew1(:),0);
%读取ns影像，并计算nsmin,nsmax锁定数据范围
ns1=double(imread(ns));
nsmin=mean2(ns1)-1.96*std(ns1(:),0);
nsmax=mean2(ns1)+1.96*std(ns1(:),0);
%将异常值置NAN
ew1(ew1<ewmin | ew1>ewmax)=nan;
ns1(ns1<nsmin | ns1>nsmax)=nan;

%读取origin影像
[A,R]=geotiffread(origin);
info=geotiffinfo(origin);
[m,n]=size(A);


%对EW/NS中值滤波
[ewX,ewY,ew_med]=medfilter(ew1,9);%9
[nsX,nsY,ns_med]=medfilter(ns1,9);

%ew_med=medfilt2(ew1,[9 9]);
%ns_med=medfilt2(ns1,[9 9]);


%对EW影像,通过tps函数拟合，获得拟合系数
 %对EW get:ew_out
%[fittemodel,gof]=createFit(ewX,ewY,ew_med);
[fittemodel,~]=createFit(ewX,ewY,ew_med);
m1=1:m;m2=repmat(m1,1,n);
n1=1:n;n2=repelem(n1,m);

ew_D=fittemodel(m2,n2);
ew_out=reshape(ew_D,m,n);
 %对NS get:ns_out
%[fittemodel,gof]=createFit(nsX,nsY,ns_med);
[fittemodel,~]=createFit(nsX,nsY,ns_med);
ns_D=fittemodel(m2,n2);
ns_out=reshape(ns_D,m,n);


%在原图上补偿
out=DemotionCubic(A,ew_out,ns_out);
%写入文件
outfilename=[origin(1:end-4),'-buchang.tif'];
geotiffwrite(outfilename,out,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);

toc
end

%-----------------%中值滤波
function [X,Y,MEDA]=medfilter(input,rad)
% for example: radius=1, windows(3*3)
X=[];Y=[];MEDA=[];
input=double(input);
radius=(rad-1)/2;
[m,n]=size(input);
% pad input image
yu=nan*zeros(radius,n);yuu=[yu;input;yu];
yl=nan*zeros(m+2*radius,radius);
input_pad=[yl yuu yl];


%output=zeros(m,n);
[m1,n1]=size(input_pad);
for i=radius+1:9:n1-radius
    for j=radius+1:9:m1-radius		
			
        %x=i+radius;y=j+radius;
		neighbordhood=input_pad(j-radius:j+radius,i-radius:i+radius);
		med=median(neighbordhood(~isnan(neighbordhood(:))));
		XX=j-radius;YY=i-radius;
		X=[X,XX];Y=[Y,YY];
		if isnan(med)
		   MEDA=[MEDA,0];
		else
		   MEDA=[MEDA,med];
		end
    end
end
end

%-----------------%双三次插值去位移
function out=DemotionCubic(in,ew,ns)
input=double(in);
[m,n]=size(input);
a=input(1,:);c=input(m,:);
b=[input(1,1),input(1,1),input(:,1)',input(m,1),input(m,1)];
d=[input(1,n),input(1,n),input(:,n)',input(m,n),input(m,n)];
a1=[a;a;input;c;c];b1=[b;b;a1';d;d];f1=b1';

out=zeros(size(input));
for i=1:m
    for j=1:n		
        u=ns(i,j);v=ew(i,j);
		ii=i+u+2;jj=j+v+2;
		i1=floor(ii);j1=floor(jj);
		u1=ii-i1;v1=jj-j1;
		A=[sw(1+u1) sw(u1) sw(1-u1) sw(2-u1)]; % matrix A
        C=[sw(1+v1);sw(v1);sw(1-v1);sw(2-v1)]; % matrix C
        B=[f1(i1-1,j1-1) f1(i1-1,j1) f1(i1-1,j1+1) f1(i1-1,j1+2);
           f1(i1,j1-1) f1(i1,j1) f1(i1,j1+1) f1(i1,j1+2);
           f1(i1+1,j1-1) f1(i1+1,j1) f1(i1+1,j1+1) f1(i1+1,j1+2);
           f1(i1+2,j1-1) f1(i1+2,j1) f1(i1+2,j1+1) f1(i1+2,j1+2)]; % matrix B
        out(i,j)=(A*B*C);
    end
end
end

%-----------------%function sw
function s=sw(x)
w=abs(x);
if w<1&&w>=0
  s=1-2*w.^2+w.^3;
elseif w>=1&&w<2
  s=4-8*w+5*w.^2-w.^3;
else 
  s=0;
end
end

