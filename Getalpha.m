% Calculating adaptive alpha for BTV (SBTV)
function alpha=Getalpha(Xn)

yr1=nan*zeros(2,size(Xn,2));
yr2=nan*zeros(size(Xn,1)+4,2);
yr3=[yr1;Xn;yr1];yrr=[yr2 yr3 yr2];

alpha = zeros(size(Xn));% LR: L1N1*L2N2
for i=3:size(yrr,1)-2
    for j=3:size(yrr,2)-2
        tmpyrr=yrr(i-2:i+2,j-2:j+2);
	    ave=mean2(tmpyrr(~isnan(tmpyrr)));
		tmpabs=abs(tmpyrr-ave);
		tmpave=mean2(tmpabs(~isnan(tmpabs)));
		alpha(i-2,j-2)=1/(1+tmpave);
    end
end	
end