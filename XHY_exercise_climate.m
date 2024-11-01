% excrise: draw IDF curves
clear,clc
T=readtable('Point_Hourly.csv');
% plot time series of raw data
time=datenum(T.Var1(:,1));
p=T.Lower_Weather;
% remove negative precipitation value
n=find(p<0);
p(n)=nan;

% plot time series, chech rae data quality
figure(1)
plot(time,p,'LineWidth',1.5);
datetick('x');
xlabel('Time');
ylabel('Precipitation(mm/h)');
title('Hourly Precipitation: 1998-2016');
set(gca,'FontSize',12,'FontName','Times New Roman');
grid on;
axis tight
% estimate the NAN value distribution
m=find(isnan(p));
nan_y=year(time(m));
ybin=year(time(1)):1:year(time(end));
F=hist(nan_y,ybin);
figure(2)
plot(ybin,F,'LineWidth',1.5);
xlabel('Year');
ylabel('Number of Nan-value');
% title('Every year has NAN, no data in 1998 and 2015');
set(gca,'FontSize',12,'FontName','Times New Roman');
grid on;
axis tight

% aggregation data
D=1:1:24;% Duration
P=struct('Time',time,'Precip',p);
apd=aggregation(P,D);

% generate series of annual maxima
annual_max=get_annual_max(apd);

% fit GEV distribution
% Intensity: first row is 10-year, second row is 100-year
I=zeros(2,24);
figure(3)
t = tiledlayout(3, 8, 'TileSpacing', 'compact', 'Padding', 'compact');
% Return Period
R=[10,100];
% Mean Squared Error, MSE
mse=zeros(length(D),1);
for i=2:length(D)+1
    data= annual_max(:,i);
    [paramEsts, paramCIs] = gevfit(data);
    % paramEsts [k, sigma, mu]
    k=paramEsts(1);    % shape parameter k
    sigma=paramEsts(2);    % scale parameter sigma
    mu=paramEsts(3); % location parameter mu
    % Intensity
    I(1,i-1)=gevinv(1-1/R(1),k,sigma,mu);
    I(2,i-1)=gevinv(1-1/R(2),k,sigma,mu);
    
    dx=0.001;
    x1=min(data):dx:max(data);
    F=histcounts(data,length(x1));
    yc=cumsum(F/length(data));% empirical data

    x=min(data):0.001:max(data);
    ph=gevcdf(x,k,sigma,mu);% GEV fit
    mse(i-1)=mean((yc - ph).^2);% Mean Squared Error
    
    nexttile;
    plot(x,ph,'r','LineWidth',1.5);hold on
    plot(x1,yc,'b-','LineWidth',1.5);
    grid on
    xlabel('P(mm/h)');
    ylabel(['Probability ',num2str(i-1),'h']);
    set(gca,'FontName','Times New Roman');
end
h=legend('GEV fit','Empirical');
ax=gca;
pos = ax.Position;
h.Position = [0.951, 0.5, 0.04, 0.05];
h.Box="off";

% draw IDF curves
I10=I(1,:);I100=I(2,:);
t = tiledlayout(2,2, 'TileSpacing', 'compact', 'Padding', 'compact');
para= IDF(D,I,R);
xD=1:0.01:24;
formulas(1).express='$\\frac{%.2fR+(%.2f)}{(D+(%.4f))^{%.2f}}$';
formulas(2).express='$\\frac{%.2fR+%.2f}{D^{%.2f}+%.2f}$';
formulas(3).express='$\\frac{%.2fR^{%.2f}}{(D+%.2f)^{%.2f}}$';
formulas(4).express='$\\frac{%.2fR^{%.2f}}{D^{%.2f}+%.2f}$';

RMSE=[0.0920,0.8354,0.0919,0.8232,0.0926,0.8865,0.0950,1.1292];
Rsquare=[0.9985,0.9416,0.9985,0.9433,0.9985,0.9342,0.9984,0.8933];
figure(4)
for i=1:4
    nexttile;
    plot(D,I(1,:),'bd','LineWidth',1.5);hold on
    plot(D,I(2,:),'rd','LineWidth',1.5);
    plot(xD,para(2*i-1).Ih,'b','LineWidth',2);
    plot(xD,para(2*i).Ih,'r','LineWidth',2);
    formula1= sprintf(formulas(i).express, para(2*i-1).a, para(2*i-1).b, ...
        para(2*i-1).c, para(2*i-1).d);
    formula2= sprintf(formulas(i).express, para(2*i).a, para(2*i).b, ...
        para(2*i).c, para(2*i).d);    
    text(0.1,2,formula1, 'Interpreter', 'latex', 'FontSize', 15,'Color', ...
        [0 0 1]);
    text(12,7.5,formula2, 'Interpreter', 'latex', 'FontSize', 15,'Color', ...
        [1 0 0]);    
    text(18,16,sprintf('R^2(10y)=%.3f',Rsquare(2*i-1)),'FontName', ...
        'Times New Roman');
    text(18,14.5,sprintf('RMSE(10y)=%.3f',RMSE(2*i-1)),'FontName', ...
        'Times New Roman');
    text(18,13,sprintf('R^2(100y)=%.3f',Rsquare(2*i)),'FontName', ...
        'Times New Roman');
    text(18,11.5,sprintf('RMSE(100y)=%.3f',RMSE(2*i)),'FontName', ...
        'Times New Roman');
    xlabel('Duration (h)');
    ylabel('Intensity (mm/h)');
    legend('Return Period = 10y','Return Period = 100y');
    grid on
    set(gca,'FontName','Times New Roman');
end