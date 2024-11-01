function [Parameters] = IDF(D,I,R)
% Parameters is an array of structures, each structure contains six fields, 
%   namely R, a, b, c, d and Ih, representing the return period, 
%   four parameters and the Intensity calculated by the analytical formula. 
% This function collects four analytical formulas, see the documentation 
%   for details.

ft1 = fittype('(a+b)/(x+c)^d', 'independent', 'x', 'coefficients', ...
    {'a', 'b', 'c', 'd'});
options1 = fitoptions('Method', 'NonlinearLeastSquares', ...
                     'Lower', [-Inf, -Inf, -6,-27], ... 
                     'Upper', [Inf, Inf, Inf,Inf], ...
                     'StartPoint',[0.17, 0.7, 0.03, 0.27]); 
ft2 = fittype('(a+b)/(x^c+d)', 'independent', 'x', 'coefficients', ...
    {'a', 'b', 'c', 'd'});
options2 = fitoptions('Method', 'NonlinearLeastSquares', ...
                     'Lower', [-Inf, -Inf,-Inf, -Inf], ... 
                     'Upper', [Inf, Inf, Inf,Inf], ...
                     'StartPoint',[0.4, 0.6, 0.6, 0.6]);

dD=1:0.01:24;
for i=1:1:length(R)
    F= fit(D', I(i,:)', ft1, options1);
    Parameters(i).R=R(i);
    Parameters(i).a=F.a/R(i);
    Parameters(i).b=F.b;
    Parameters(i).c=F.c;
    Parameters(i).d=F.d;
    Parameters(i).Ih=(F.a+F.b)./(dD+F.c).^F.d;
    Parameters(i).Type=1;
end
for i=1:1:length(R)
    F= fit(D', I(i,:)', ft2, options2);
    Parameters(i+2).R=R(i);
    Parameters(i+2).a=F.a/R(i);
    Parameters(i+2).b=F.b;
    Parameters(i+2).c=F.c;
    Parameters(i+2).d=F.d;
    Parameters(i+2).Ih=(F.a+F.b)./(dD.^F.c+F.d);
    Parameters(i+2).Type=2;
end
for i=1:1:length(R)
    ft= fittype(['(a*',num2str(R(i)),'^b)/(x+c)^d'], 'independent', 'x', ...
        'coefficients',{'a', 'b', 'c', 'd'});
    F = fit(D', I(i,:)', ft,'StartPoint',[0.7, 0.7, 0.1, 0.4]);
    Parameters(i+4).R=R(i);
    Parameters(i+4).a=F.a/R(i);
    Parameters(i+4).b=F.b;
    Parameters(i+4).c=F.c;
    Parameters(i+4).d=F.d;
    Parameters(i+4).Ih=(F.a*R(i)^F.b)./(dD+F.c).^F.d;
    Parameters(i+4).Type=3;
end
for i=1:1:length(R)
    ft= fittype(['(a*',num2str(R(i)),'^b)/(x^c+d)'], 'independent', 'x', ...
        'coefficients',{'a', 'b', 'c', 'd'});
    F = fit(D', I(i,:)', ft,'StartPoint',[0.5, 0.5, 0.5, 0.5]);
    Parameters(i+6).R=R(i);
    Parameters(i+6).a=F.a/R(i);
    Parameters(i+6).b=F.b;
    Parameters(i+6).c=F.c;
    Parameters(i+6).d=F.d;
    Parameters(i+6).Ih=(F.a*R(i)^F.b)./(dD.^F.c+F.d);
    Parameters(i+6).Type=4;
end
end