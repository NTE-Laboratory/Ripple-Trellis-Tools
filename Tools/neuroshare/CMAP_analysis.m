clear all 
close all
clc

%% load files 
% AMP = [10,40,50,60,80,120,140,160,180,200,240,260,300];
cd('\\SSOE-BIOE-FS5\CuiShared\USERS\xiz149\Documents\MATLAB\sally_TrellisDoc\06132017\peroneal')
% cd('\\SSOE-BIOE-FS5\CuiShared\USERS\xiz149\Documents\MATLAB\sally_TrellisDoc\CMAP_nerveacute_Bradyvisit\peroneal data')
% cd('\\SSOE-BIOE-FS5\CuiShared\USERS\xiz149\Documents\MATLAB\sally_TrellisDoc\tibial data')
% cd('\\SSOE-BIOE-FS5\CuiShared\USERS\xiz149\Documents\MATLAB\sally_TrellisDoc\CMAP_experiment_1\CMAP export')


%%
AMP = [20,25,30,40,50,60,80,100,200,300,500,750,1000];
% AMP = [10,40,50,60,80,120,140,160,180,200,240,260,300];
stim = cell(length(AMP),1);
chan5 = cell(length(AMP),1);
chan9 = cell(length(AMP),1);
nervechan = cell(length(AMP),1);
nervechan_spike = cell(length(AMP),1);
for i = 1:length(AMP);
stim{i} = load(['chan5_',num2str(AMP(i)),'.mat']);
% stim_data = analogInputData_uV;
% stim_time = analogInputDataTime_s;
chan5{i}= load(['chan7_',num2str(AMP(i)),'.mat']); % 'chan 5' is for top record
% nervechan{i} = load(['chan_nerve5_',num2str(AMP(i)),'.mat']);
% nervechan_spike{i} = load(['chan_nerve5_',num2str(AMP(i)),'.mat']);

chan9{i}= load(['chan9_',num2str(AMP(i)),'.mat']); % 'chan9' is for bottom record
end


% chan5_data = analogInputData_uV;
% chan5_time = analogInputDataTime_s;


% chan9_data = analogInputData_uV;          
% chan9_time = analogInputDataTime_s;



%%
diff = cell(length(AMP),1);
subtract = cell(length(AMP),1);
for i = 1:length(AMP);
           
 diff{i} = chan9{i}.analogInputData_uV-chan5{i}.analogInputData_uV;
%  subtract{i} = diff{i}-stim{i}.analogInputData_uV;
end 
%% apply a filter to subtract and diff
Fs= 2000;
d = designfilt('bandstopiir','FilterOrder',2, ...
               'HalfPowerFrequency1',59,'HalfPowerFrequency2',61, ...
               'DesignMethod','butter','SampleRate',Fs);
  diffFilt = cell(length(AMP),1);
  CMAP_filt = cell(length(AMP),1);
  stimfilt = cell(length(AMP),1);
  chan5_filt = cell(length(AMP),1);
  chan9_filt = cell(length(AMP),1);
  
  for i = 1:length(AMP);
%    stimfilt{i} = filtfilt(d,stim{i}.stimData);
  diffFilt {i} = filtfilt(d,diff{i});
%   CMAP_filt {i} = filtfilt(d,subtract{i});
  chan5_filt{i} = filtfilt(d,chan5{i}.analogInputData_uV);
  chan9_filt{i} = filtfilt(d,chan9{i}.analogInputData_uV);
  end 
  
%% 
close all
figure,

for i = 1:length(AMP);
   subplot(5,3,i)
plot(stim{i}.time,stim{i}.stimData*10);hold on
% plot(nervechan{i}.analogInputDataTime_s,nervechan{i}.analogInputData_uV)
% plot(nervechan_spike{i}.analogInputDataTime_s*1000,nervechan_spike{i}.analogInputData_uV)
% plot(stim{i}.analogInputDataTime_s,stim{i}.stimData*100);hold on
% plot(stim{i}.analogInputDataTime_s,stim{i}.analogInputData_uV);hold on
% plot(stim{i}.analogInputDataTime_s,stimfilt{i});hold on

% hold on             
% plot(chan5{i}.analogInputDataTime_s,diffFilt{i},'red');hold on
% plot(chan5{i}.analogInputDataTime_s,diff{i});hold on
% plot(chan5{i}.analogInputDataTime_s,chan5_filt{i});
plot(chan5{i}.analogInputDataTime_s,-chan5{i}.analogInputData_uV);hold on
% plot(stim{i}.analogInputDataTime_s,chan5_filt{i});

% plot(stim{i}.analogInputDataTime_s,chan9_filt{i});
% % hold on
% plot(stim{i}.analogInputDataTime_s,CMAP_filt{i});
% title(num2str(AMP(i)))
% % xlim([6.20 6.25]);
% ylim([-1.5*10^3 2*10^3])
% legend('stim','CMAP')
% ylabel('CMAP (mV)')
% xlabel('Time(s)')
end 

%% try to plot intensity number 5
close
n = 3;
figure, 
plot(stim{n}.time,stim{n}.stimData*10)
% hold on
% plot(chan5{n}.analogInputDataTime_s,-diff{n})

%%  create snippets for CMAP
%find time/index of the first stim

% stim{5}.time(find(stim{5}.stimData ~= 0));
% 
% %   find(stim{5}.stimData ~= 0,1);
winSize = 1;
f_samp = 30000;

firstPt = find(stim{5}.stimData~=0,1);
window1 = [find(stim{5}.stimData~=0,1):find(stim{5}.stimData~=0,1)+f_samp-1];
figure, plot(stim{5}.time(window1),stim{5}.stimData(window1))
% figure, plot(chan5{5}.analogInputDataTime_s(window1),-chan5{5}.analogInputData_uV(window1))
