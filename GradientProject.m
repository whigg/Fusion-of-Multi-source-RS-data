function G=GradientProject(Xn, LR, Hpsf) 

        [row_l, col_l] = size(LR);
        [row_h, col_h] = size(Xn);
        Zn=imfilter(Xn,Hpsf,'same');
		HRsd = imresize(Zn, [row_l, col_l], 'bicubic');
		Gsign=sign(HRsd-LR);
		G=imresize(Gsign,[row_h,col_h],'bicubic');
		
		