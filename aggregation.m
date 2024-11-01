function apd = aggregation(P,D)
% apd is an array of structures whose elements contain two fields, 
%   time and precip, where time represents the time and precip is 
%   the aggregation data.
% P is a structure containing two fields, Time and Precip, 
%   which store datenum and raw data, respectively.
% D is duration.

for i=1:length(D)
    Time=P.Time(1):datenum(0,0,0,D(i),0,0):P.Time(end);
    apd(i).time=Time';
    n=D(i);
    if n==1 % duration = 1h
        m=find(isnan(P.Precip));
        apd(i).precip=P.Precip;
        apd(i).precip(m)=[];
        apd(i).time(m)=[];
    else
        % window=n;
        % precip=movmean(P.Precip, window, 'Endpoints', 'discard');
        % remainder = mod(numel(P.Precip), window);
        % if remainder > 0
        %     
        %     lastWindowMean = mean(P.Precip(end-remainder + 1:end));
        %     precip = [precip;lastWindowMean];
        % end
        precip=zeros(length(Time),1);
        for j=1:1:length(Time)
            if j==length(Time)
                precip(j)=mean(P.Precip(n*j-(n-1):end),'omitmissing');
            else
                precip(j)=mean(P.Precip(n*j-(n-1):n*j),'omitmissing');
            end
        end
        apd(i).precip=precip;
        % remove the NAN
        m=find(isnan(precip));
        apd(i).precip(m)=[];
        apd(i).time(m)=[];
    end
end
end