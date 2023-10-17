
close all

%
load([pwd '/init_data/var_combos.mat'],'var_combos');
numPerBlock = 1000;
[lpp, ~]   = size(var_combos); 
maxNumBlocks = ceil(lpp/numPerBlock);
%
Sim_results = [];
for i = 1:maxNumBlocks
    resultsi = load([pwd '/result/Sim_results' num2str(i) '.mat']).Sim_results;
    Sim_results = [Sim_results, resultsi];
end
%}

if not(isfolder('data'))
    mkdir data
end

MGB_base0 = 0.0092;
MGB_evoked0 = 0.1069;

for x=1:21
MGBspks={};
HOspks={};
PVspks={};
SOMspks={};
totalSpks1 =[];
%totalSpks2 =[];
%totalSpks3 =[];
%totalSpks4 =[];


for i=1:150
    MGBspks{1,i} = Sim_results(i+(150*(x-1))).analysis.spktime.TC_MGB; %#ok<*SAGROW>
    HOspks{1,i} = Sim_results(i+(150*(x-1))).analysis.spktime.TC_HO;
    PVspks{1,i} = Sim_results(i+(150*(x-1))).analysis.spktime.TRN_PV;
    SOMspks{1,i} = Sim_results(i+(150*(x-1))).analysis.spktime.TRN_SOM;
    totalSpks1 = [totalSpks1 MGBspks{1,i}']; %#ok<*AGROW>
    %totalSpks2 = [totalSpks2 HOspks{1,i}'];
    %totalSpks3 = [totalSpks3
    %PVspks{1,i}'];
    %totalSpks4 = [totalSpks4 SOMspks{1,i}'];
end 




[psth_MGB, centers] = return_histogram(totalSpks1, 1000, 150, 31);
%[psth_HO, centers] = return_histogram(totalSpks2, 1000, 50, 31);
%[psth_PV, centers] = return_histogram(totalSpks3, 1000, 50, 31);
%[psth_SOM, centers] = return_histogram(totalSpks4, 1000, 50, 31);

MGB_FR{x} = psth_MGB;
MGB_base_FR(x)=mean(psth_MGB(201:400));
MGB_peak_FR(x)= max(psth_MGB(501:575));

%{
save([pwd '/data/MGBspks' varStr '.mat'],'MGBspks','psth_MGB','centers')
save([pwd '/data/HOspks' varStr '.mat'],'HOspks','psth_HO','centers')
save([pwd '/data/PVspks' varStr '.mat'],'PVspks','psth_PV','centers')
save([pwd '/data/SOMspks' varStr '.mat'],'SOMspks','psth_SOM','centers')
%}
end
%{
subplot(2,2,1);plotSpikeRaster(spks4,'PlotType','scatter');
subplot(2,2,2);plotSpikeRaster(spks3,'PlotType','scatter');
subplot(2,2,3);plotSpikeRaster(spks2,'PlotType','scatter');
subplot(2,2,4);plotSpikeRaster(spks1,'PlotType','scatter');
%}

%
MGB_FR=reshape(MGB_FR,3,[])';
MGB_base_FR=reshape(MGB_base_FR,3,[])';
MGB_peak_FR=reshape(MGB_peak_FR,3,[])';
%


save([pwd '/data/MGB_FR.mat'],'MGB_FR','MGB_peak_FR','MGB_base_FR')



%}