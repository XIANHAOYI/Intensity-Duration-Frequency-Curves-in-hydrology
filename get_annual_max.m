function annual_max = get_annual_max(apd)
% annual_max is an array of annual maxima with the year in the first 
%   column and the annual precipitation maxima corresponding to 
%   Duration after the second column.
time_y=year(apd(1).time(1)):1:year(apd(1).time(end));
annual_max=zeros(length(time_y),25);
annual_max(:,1)=time_y';
for i=1:1:length(apd)
    for j=1:1:length(time_y)
        m=find(year(apd(i).time)==time_y(j));
        X=max(apd(i).precip(m),[],'omitnan');
        if ~isnan(X)
            annual_max(j,i+1)=X;
        else
            annual_max(j,i+1)=nan;
        end
    end
end
end