% Calculating slope angle of DEM
% Xn: DEM
% slope: slope angle
function slope=GetSlope(X)
Xn=double(X);
slope=double(90.0*ones(size(Xn)));
for i=2:size(Xn,1)-1
    for j=2:size(Xn,2)-1
        dx=(2*Xn(i,j+1)+Xn(i-1,j+1)+Xn(i+1,j+1)-2*Xn(i,j-1)-Xn(i-1,j-1)-Xn(i+1,j-1))/(8.0*30.0);
		dy=(2*Xn(i+1,j)+Xn(i+1,j+1)+Xn(i+1,j-1)-2*Xn(i-1,j)-Xn(i-1,j-1)-Xn(i-1,j+1))/(8.0*30.0);
		slope(i,j)=atan(sqrt(dx^2+dy^2))*57.29578;
    end        
end
end
