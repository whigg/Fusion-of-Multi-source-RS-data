function [fitresult, gof] = createFit(VarName1, VarName2, VarName3)
%CREATEFIT(VARNAME1,VARNAME2,VARNAME3)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : VarName1
%      Y Input : VarName2
%      Z Output: VarName3
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  另请参阅 FIT, CFIT, SFIT.

%  由 MATLAB 于 03-Jul-2018 15:22:20 自动生成


%% Fit: 'untitled fit 1'.
[xData, yData, zData] = prepareSurfaceData( VarName1, VarName2, VarName3 );

% Set up fittype and options.
ft = 'thinplateinterp';

% Fit model to data.
[fitresult, gof] = fit( [xData, yData], zData, ft, 'Normalize', 'on' );

% Plot fit with data.
% figure( 'Name', 'untitled fit 1' );
% h = plot( fitresult, [xData, yData], zData );
% legend( h, 'untitled fit 1', 'VarName3 vs. VarName1, VarName2', 'Location', 'NorthEast' );
% % Label axes
% xlabel VarName1
% ylabel VarName2
% zlabel VarName3
% grid on
% view( 89.7, 90.0 );


