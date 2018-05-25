function [Sa_4 sigma_4] = SLV_2002_SINGLE_ENA(M, T, Rcd)
% by Rocio Segura, 18/10/2016
%
%
% Implements GMPE developed by Walter Silva, Nick Gregor and Robert Darragh
% and documented in �Development of regional hard rock attenuation relations for
% central and eastern north America� (2002).

%No site parameters are needed. The GMPE was developed for hard-rock site
% with Vs30 >= 2000 m/s (NEHRP site class A) only.
% HARD ROCK REGRESSION COEFFICIENTS FOR THE SINGLE CORNER MODEL WITH VARIABLE
% STRESS DROP AS A FUNCTION OF MOMENT MAGNITUDE (M)  - Table 3
%
%**************************************************************************
%--------------------------INPUT VARIABLES---------------------------------
% M      = moment magnitude
% T      = period (s); 
% Rcd    = closest distance to fault (km)
%
%--------------------------OUTPUT VARIABLES--------------------------------
% Sa    = median spectral acceleration prediction (g)
% sigma = logarithmic standard deviation of spectral acceleration
%         prediction (g)
%**************************************************************************

%----------------------COEFFICIENTS FOR ROCK SITES ------------------------
% Table of coefficients were provided by Table 2.
period = [10.000	5.000	3.000	2.000	1.600	1.000	0.750	0.500	0.400	0.300	0.240	0.200	0.160	0.150	0.120	0.100	0.080	0.070	0.060	0.055	0.050	0.040	0.032	0.025	0.020	0.010 999 998]';
  
cr = [-19.28945 2.59965 2.10000 0.00000 -1.43865 0.05802 0.00000 -0.26815 0.41060 1.34000
-15.41671 2.31029 2.30000 0.00000 -1.58264 0.06531 0.00000 -0.34272 0.44830 1.22110
-12.14626 2.00333 2.40000 0.00000 -1.73224 0.07698 0.00000 -0.35126 0.48540 1.08570
-9.33586 1.71687 2.50000 0.00000 -1.89335 0.09080 0.00000 -0.32809 0.51770 1.00740
-7.97047 1.55786 2.50000 0.00000 -1.96423 0.09820 0.00000 -0.30626 0.53400 0.94230
-4.96496 1.19548 2.60000 0.00000 -2.18581 0.11900 0.00000 -0.24566 0.56390 0.87010
-3.32213 1.00226 2.60000 0.00000 -2.27821 0.12880 0.00000 -0.20311  0.57870 0.87770
-1.43548 0.77358 2.60000 0.00000 -2.40928 0.14297 0.00000 -0.15233 0.59710 0.83940
-0.50467 0.67008 2.60000 0.00000 -2.46619 0.14872 0.00000 -0.12648 0.60750 0.82950
0.43668	0.55655	2.60000	0.00000	-2.54754 0.15729 0.00000 -0.10162 0.62040 0.83380
1.06963	0.49226	2.60000	0.00000	-2.59470 0.16186 0.00000 -0.08664 0.63040 0.82550
1.52694	0.45169	2.60000	0.00000	-2.62629 0.16462 0.00000 -0.07695 0.63930 0.82460
2.36181	0.38440	2.70000	0.00000	-2.73859 0.17274 0.00000 -0.06802 0.65160 0.82750
2.47996	0.37179	2.70000	0.00000	-2.75112 0.17386 0.00000 -0.06588 0.65680 0.83240
2.86034	0.34166	2.70000	0.00000	-2.78522 0.17656 0.00000 -0.06010 0.66980 0.84700
3.11592	0.31985	2.70000	0.00000	-2.81384 0.17885 0.00000 -0.05663 0.68170 0.84520
3.37375	0.29732	2.70000	0.00000	-2.84698 0.18144 0.00000 -0.05357 0.69020 0.84590
3.92488	0.25884	2.80000	0.00000	-2.94339 0.18762 0.00000 -0.05225 0.69610 0.85030
4.05039	0.24603	2.80000	0.00000	-2.96583 0.18937 0.00000 -0.05110 0.70360 0.85840
4.11372	0.23943	2.80000	0.00000	-2.97807 0.19032 0.00000 -0.05058 0.70840 0.85860
4.18102	0.23274	2.80000	0.00000	-2.99106 0.19131 0.00000 -0.05011 0.71430 0.86570
4.34191	0.21938	2.80000	0.00000	-3.01949 0.19332 0.00000 -0.04924 0.73160 0.87760
4.50147	0.20875	2.80000	0.00000	-3.04513 0.19494 0.00000 -0.04831 0.74390 0.88490
5.13460	0.16824	2.90000	0.00000	-3.15909 0.20195 0.00000 -0.04828 0.7511  0.88830
5.16438	0.15928	2.90000	0.00000	-3.18078 0.20386 0.00000 -0.04851 0.75370 0.89180
3.36079	0.22218	2.70000	0.00000	-2.98760 0.19761 0.00000 -0.05509 0.69690 0.84470
2.51086 0.76168 2.40000 0.0000 -2.72601 0.20021 0.0000 -0.10368 0.5550 NaN
3.16202 0.22398 2.70000 0.0000 -2.97147 0.19714 0.0000 -0.05620 0.6886 0.8379];   
  

%**************************************************************************
% FIND C COEFFICIENTS BY INTERPOLATING BETWEEN PERDIODS
%**************************************************************************
ilow = max(find(period<=T));
T_low = period(ilow);
ihigh = min(find(period>=T));
T_high = period(ihigh);
% if given period equals a period in the table, then no need to interpolate
if ihigh==ilow
        c = cr(ihigh,:);
% otherwise, interpolate between coeffients
else
        c_high = cr(ihigh,:);
        c_low = cr(ilow,:);
    for i=1:length(c_high)
        c(i) = interp1([T_low T_high], [c_low(i) c_high(i)], T);
    end
end

%**************************************************************************
% COMPUTE LOG MEAN SPECTRAL ACCELERAION
%**************************************************************************
logSa = c(1) + c(2)*M +(c(5) + c(6)*M)*log(Rcd+exp(c(3))) + c(8)*(M-6)^2; 

%**************************************************************************
% CONVERT SPECTRAL ACCELERATION FROM LOG SCALE
%**************************************************************************
Sa_4 = (exp(logSa));
%**************************************************************************
% DEFINE SIGMA Parametric
%**************************************************************************
 sigma_p = c(9);   
%**************************************************************************
% DEFINE SIGMA TOTAL
% c10 corresponds to sigma_Reg
%**************************************************************************
if T==999
   sigma_4=sigma_p;
else
sigma_4=c(10);
end