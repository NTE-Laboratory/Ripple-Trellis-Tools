dataType = 'LFP'; 
dataChannel = 6;
plotStatus = false;
completeFilePath = 'D:\delin\Downloads\4-12-2021\spontaneous after cocaine.ns2';
extract_all_data
voltage_after=analogInputData_uV;
time_after=analogInputDataTime_s;
dataType = 'LFP'; 
dataChannel = 6;
plotStatus = false;
completeFilePath = 'D:\delin\Downloads\4-12-2021\spontaneous1.ns2';
extract_all_data
voltage_before=analogInputData_uV;
time_before=analogInputDataTime_s;



figure(1)
hold on
plot(time_after,voltage_after)
plot(time_before,voltage_before)
xlim([0 120])
ylim([-2000 3000])
ylabel('LFP potential (µV)')
xlabel('Time (S)')
legend('After Cocaine Injection','Before Cocaine Injection')

figure(2)
hold on
plot(time_after,voltage_after)
plot(time_before,voltage_before)
xlim([0 20])
ylim([-2000 3000])
ylabel('LFP potential (µV)')
xlabel('Time (S)')
legend('After Cocaine Injection','Before Cocaine Injection')


%% power spectrum
samprate=1000; % 1kHz
x=(0:(length(voltage_before)-1))*samprate/length(voltage_before);
yF = fft(voltage_before);
yPsd_before = abs(yF.*yF);    
norm = max(yPsd_before);    
yPsd_norm_before= yPsd_before./norm;

figure(3)
hold on
plot(x,yPsd_before)

figure(4)
hold on
plot(x,yPsd_norm_before)

x=(0:(length(voltage_after)-1))*samprate/length(voltage_after);
yF = fft(voltage_after);
yPsd_after = abs(yF.*yF);    
norm = max(yPsd_after);    
yPsd_norm_after=yPsd_after./norm;

figure(3)
plot(x,yPsd_after)

xlabel('Frequency (Hz)')
ylabel('Power spectral density (µV^2/Hz)')
% xlim([0 20])
legend('Before Cocaine Injection','After Cocaine Injection')


figure(4)
hold on
plot(x,yPsd_norm_after)
xlabel('Frequency (Hz)')
ylabel('Normalized Power spectral density (a.u.)')
% xlim([0 20])
legend('Before Cocaine Injection','After Cocaine Injection')


%%

win = floor(0.5*samprate); 
moveBy = floor(0.1*samprate);
%freqeuncy vector
freq = (0:win)*samprate/win;
% range of interest
Psd_index_range=[1,20;1,200];

%time vector
time = (1:moveBy:length(voltage_before)-win)/samprate-0.5;
%finds spectrogram of 0.5 second windows every 0.1 seconds for the entire%LFP data of a channel
t_before = (1:moveBy:length(voltage_before)-win)/samprate;
l = 1;
for k = 1:moveBy:length(voltage_before)-win    
    temp = fft(voltage_before(k:k+win));    
    allPsd_before(:,l) = abs(temp.*temp);    
%     norm = max(allPsd(:,l));    
%     allPsd(:,l) = allPsd(:,l)./norm;    
    l = l+1;
end
max_before=max(max(allPsd_before(Psd_index_range(1,:),Psd_index_range(2,:))));
min_before=min(min(allPsd_before(Psd_index_range(1,:),Psd_index_range(2,:))));
%time vector
time = (1:moveBy:length(voltage_after)-win)/samprate-0.5;
%finds spectrogram of 0.5 second windows every 0.1 seconds for the entire%LFP data of a channel
t_after = (1:moveBy:length(voltage_after)-win)/samprate;
l = 1;
for k = 1:moveBy:length(voltage_after)-win    
    temp = fft(voltage_after(k:k+win));    
    allPsd_after(:,l) = abs(temp.*temp);    
%     norm = max(allPsd(:,l));    
%     allPsd(:,l) = allPsd(:,l)./norm;    
    l = l+1;
end
max_after=max(max(allPsd_after(Psd_index_range(1,:),Psd_index_range(2,:))));
min_after=min(min(allPsd_after(Psd_index_range(1,:),Psd_index_range(2,:))));

figure
clf
pcolor(t_before,freq,allPsd_before)
view(2), 
shading('interp')
axis('tight')
c = colorbar;
c.Label.String = 'Power/Frequency (µV^2/Hz)';
ylim([0 20])
xlim([0 20])
caxis([min([min_before,min_after]), max([max_before,max_after])])
colormap(parula)
% ti = sprintf('Spectogram Channel %d',channel);
% title(ti);
title('Before Injection')
xlabel('Time (sec)');ylabel('Frequency (Hz)')

figure
clf
pcolor(t_after,freq,allPsd_after)
view(2), 
shading('interp')
axis('tight')
c = colorbar;
c.Label.String = 'Power/Frequency (µV^2/Hz)';
ylim([0 20])
xlim([0 20])
caxis([min([min_before,min_after]), max([max_before,max_after])])
colormap(parula)
% ti = sprintf('Spectogram Channel %d',channel);
% title(ti);
title('After Injection')
xlabel('Time (sec)');ylabel('Frequency (Hz)')