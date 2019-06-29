clear all;%%2595 5191 ͳ�Ʋ�ָ���ͼ 650

a_cc=freadbkB('F:\��ֽ��\ROI17\tflt_17\AW3D30\20151202-20160210.tflt',620,'cpxfloat32');

s_cc=freadbkB('F:\��ֽ��\ROI17\tflt_17\SRTM1\20151202-20160210.tflt',620,'cpxfloat32');

t_cc=freadbkB('F:\��ֽ��\ROI17\tflt_17\TDM90\20151202-20160210.tflt',620,'cpxfloat32');

cc=freadbkB('F:\��ֽ��\ROI17\tflt_17\Fusion\20151202-20160210.tflt',620,'cpxfloat32');

a_data=angle(a_cc);
%a_data=a_unw(a_cc>0);
%a_data=a_unw(a_cc>0&a_cc<=0.5);
%[f_a,xi_a]=ksdensity(a_data);

s_data=angle(s_cc);
%s_data=s_unw(s_cc>0);
%s_data=s_unw(s_cc>0&s_cc<=0.5);
%[f_s,xi_s]=ksdensity(s_data);

t_data=angle(t_cc);
%t_data=t_unw(t_cc>0);
%t_data=t_unw(t_cc>0&t_cc<=0.5);
%[f_t,xi_t]=ksdensity(t_data);

data=angle(cc);
%data=unw(cc>0);
%data=unw(cc>0&cc<=0.5);
%[f,xi]=ksdensity(data);

a_data(a_data==0)=[];
s_data(s_data==0)=[];
t_data(t_data==0)=[];
data(data==0)=[];
std1=[std(a_data(:)) std(s_data(:)) std(t_data(:)) std(data(:))];

figure(1)
imagesc(a_data);
figure(2)
imagesc(data);

%��λ�ֲ���-4~4
rad_a=[];pdf_a=[];
for k=-3.14:0.05:3.14
    tmp=a_data(a_data>=k & a_data<k+0.1);
    pdf_a=[pdf_a,size(tmp,2)/size(a_data,2)];
    rad_a=[rad_a,k];
end

rad_s=[];pdf_s=[];
for k=-10:0.1:10
    tmp=s_data(s_data>=k & s_data<k+0.1);
    pdf_s=[pdf_s,size(tmp,2)/size(s_data,2)];
    rad_s=[rad_s,k];
end

rad_t=[];pdf_t=[];
for k=-10:0.1:10
    tmp=t_data(t_data>=k & t_data<k+0.1);
    pdf_t=[pdf_t,size(tmp,2)/size(t_data,2)];
    rad_t=[rad_t,k];
end

rad=[];pdf=[];
for k=-10:0.1:10
    tmp=data(data>=k & data<k+0.1);
    pdf=[pdf,size(tmp,2)/size(data,2)];
    rad=[rad,k];
end
%%%------PDF-------%%%
clear all;
load pdf;
figure;
set(gcf,'unit','centimeters','Position',[11 5 23.363 11.165]);
ax1=subplot(1,2,1);
hold on
plot(rad_a,pdf_a,'c-')
plot(rad_s,pdf_s,'b-')
plot(rad_t,pdf_t,'y-')
plot(rad,pdf,'r-')
set(ax1,'Units','centimeters','Position',[1.64 1.1 9.631 9.79]);
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
annotation(gcf,'textbox','Units','centimeters',...
    'Position',[1.7198 5.7414 3.9421 2.9898],...
    'String',{'Standard Deviation:';'AW3D30:3.09';'SRTM1:2.78';'TDM90:3.04';'Proposed:2.61'},...
    'LineStyle','none',...
    'FontSize',11,...
    'HorizontalAlignment','left',...
    'VerticalAlignment','top',...
    'BackgroundColor',[1 1 1],...
    'FitBoxToText','on',...
    'FaceAlpha',0);
leg1=legend('AW3D30','SRTM1','TDM90','Proposed');
set(leg1,'FontSize',11,'Units','centimeters','Position',[7.541 8.7 3.678 2.156]);
xlabel('Unwarpped differential phase:rad');
ylabel('PDF/(%)');
box on

ax2=subplot(1,2,2);
set(ax2,'Units','centimeters','Position',[13.5 1.1 9.631 9.79]);
hold on
plot(rad_a15,pdf_a15,'c-')
plot(rad_s15,pdf_s15,'b-')
plot(rad_t15,pdf_t15,'y-')
plot(rad15,pdf15,'r-')

annotation(gcf,'textbox','Units','centimeters',...
    'Position',[13.466 10.16 1.1642 0.82021],...
    'String',{'(b)'},...
    'LineStyle','none',...
    'FontSize',12,...
    'HorizontalAlignment','left',...
    'VerticalAlignment','top',...
    'BackgroundColor',[1 1 1],...
    'FitBoxToText','on',...
    'FaceAlpha',0);
annotation(gcf,'textbox','Units','centimeters',...
    'Position',[13.6 5.7414 3.9421 2.9898],...
    'String',{'Standard Deviation:';'AW3D30:3.55';'SRTM1:4.23';'TDM90:3.83';'Proposed:3.39'},...
    'LineStyle','none',...
    'FontSize',11,...
    'HorizontalAlignment','left',...
    'VerticalAlignment','top',...
    'BackgroundColor',[1 1 1],...
    'FitBoxToText','on',...
    'FaceAlpha',0);
leg2=legend('AW3D30','SRTM1','TDM90','Proposed');
set(leg2,'FontSize',11,'Units','centimeters','Position',[19.385 8.683 3.678 2.156]);
xlabel('Unwarpped differential phase:rad');
ylabel('PDF/(%)');
box on
%%%------PDF-------%%%

hold on
plot(xi_a(xi_a>-3.14 & xi_a<3.14)',f_a(xi_a>-3.14 & xi_a<3.14)','b');          % c y
plot(xi_s(xi_s>-3.14 & xi_s<3.14)',f_s(xi_s>-3.14 & xi_s<3.14)','y');
plot(xi_t(xi_t>-3.14 & xi_t<3.14)',f_t(xi_t>-3.14 & xi_t<3.14)','c');
plot(xi(xi>-3.14 & xi<3.14)',f(xi>-3.14 & xi<3.14)','r');
legend('aw3d30','srtm1','tdm90','fusion')


max(max(data(:)))
min(min(data(:)))
data=randn(1,1000);
[mu,sigma]=normfit(data);
d=pdf('norm',data,mu,sigma);
figure
plot(data,d);

x = randn(1,1000);%xΪԭʼ����
subplot(1,2,1);

plot(x);
title('ԭʼ����');
hold on;
%���������ĸ����ܶ�
xi1=-3:0.1:3;
[f1,xi1]=ksdensity(data);
%����ͼ��
subplot(1,2,2);
hold on
plot(xi,f,'b');
plot(xi1,f1,'r');
title('�����ܶȷֲ�(PDF)');
hold on
tabulate(data);




data = randn(1000);
N = histcounts(data, 'BinLimits', [-3.14 3.14], 'BinMethod', 'integers', 'Normalization', 'pdf');
plot(N);
xlabel('Integer value');
ylabel('Probability');

