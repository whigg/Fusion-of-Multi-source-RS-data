function OutImg = Normalize(InImg)
         ymax=255;ymin=0;
		 xmax=max(max(InImg));
		 xmin=min(min(InImg));
		 OutImg=round((ymax-ymin)*(InImg-xmin)/(xmax-xmin)+ymin);
end