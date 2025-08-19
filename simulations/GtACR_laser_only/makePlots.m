
load data/MGB_FR.mat MGB_FR
MGB_FR_laser = MGB_FR;
load ../PV_SOM_inh/TRN_recip/data/MGB_FR.mat MGB_FR
MGB_FR_recip = MGB_FR;
load ../GJ_PV_SOM/PV_SOM_inh/TRN_recip/data/MGB_FR.mat MGB_FR
MGB_FR_gj = MGB_FR;
load ../recip_div_TRN_inh/data/MGB_FR.mat MGB_FR
MGB_FR_div = MGB_FR;
load ../recip_div_TRN_wSOMlat_inh/data/MGB_FR.mat MGB_FR
MGB_FR_div2 = MGB_FR;

MGB_evoked0 = 0.1069;

figure(1);

counter=1;

%{
%recip
subplot(5,2,counter);hold on
plot(MGB_FR_recip{1,1}/MGB_evoked0)
plot(MGB_FR_recip{1,37}/MGB_evoked0)
plot(MGB_FR_laser{1,2}/MGB_evoked0)
xlim([400 700]);
ylim([0 2]);

counter=counter+1;

subplot(5,2,counter);hold on
plot(MGB_FR_recip{1,1}/MGB_evoked0)
plot(MGB_FR_recip{1,73}/MGB_evoked0)
plot(MGB_FR_laser{1,3}/MGB_evoked0)
xlim([400 700]);
ylim([0 2]);

counter=counter+1;
%}

%recip + gj
subplot(4,2,counter);hold on
plot(MGB_FR_gj{1,1}/MGB_evoked0)
yline(mean(MGB_FR_gj{1,1}(400:499))/MGB_evoked0)
plot(MGB_FR_gj{1,37}/MGB_evoked0)
plot(MGB_FR_laser{2,2}/MGB_evoked0)
xlim([400 700]);
ylim([0 2]);
title("MGB response")
ylabel("FR (norm)")

counter=counter+1;

subplot(4,2,counter);hold on
plot(MGB_FR_gj{1,1}/MGB_evoked0)
yline(mean(MGB_FR_gj{1,1}(400:499))/MGB_evoked0)
plot(MGB_FR_gj{1,73}/MGB_evoked0)
plot(MGB_FR_laser{2,3}/MGB_evoked0)
xlim([400 700]);
ylim([0 2]);
title("MGB response")

counter=counter+1;

% recip + som intra
subplot(4,2,counter);hold on
plot(MGB_FR_recip{1,31}/MGB_evoked0)
yline(mean(MGB_FR_recip{1,31}(400:499))/MGB_evoked0)
plot(MGB_FR_recip{1,67}/MGB_evoked0)
plot(MGB_FR_laser{3,2}/MGB_evoked0)
xlim([400 700]);
ylim([0 2]);
ylabel("FR (norm)")

counter=counter+1;

subplot(4,2,counter);hold on
plot(MGB_FR_recip{1,31}/MGB_evoked0)
yline(mean(MGB_FR_recip{1,31}(400:499))/MGB_evoked0)
plot(MGB_FR_recip{1,103}/MGB_evoked0)
plot(MGB_FR_laser{3,3}/MGB_evoked0)
xlim([400 700]);
ylim([0 2]);

counter=counter+1;

% cross
subplot(4,2,counter);hold on
plot(MGB_FR_div{1,31}/MGB_evoked0)
yline(mean(MGB_FR_div{1,31}(400:499))/MGB_evoked0)
plot(MGB_FR_div{1,67}/MGB_evoked0)
plot(MGB_FR_laser{4,2}/MGB_evoked0)
xlim([400 700]);
ylim([0 2]);
ylabel("FR (norm)")

counter=counter+1;

subplot(4,2,counter);hold on
plot(MGB_FR_div{1,31}/MGB_evoked0)
yline(mean(MGB_FR_div{1,31}(400:499))/MGB_evoked0)
plot(MGB_FR_div{1,103}/MGB_evoked0)
plot(MGB_FR_laser{4,3}/MGB_evoked0)
xlim([400 700]);
ylim([0 2]);

counter=counter+1;

% cross + som intra
subplot(4,2,counter);hold on
plot(MGB_FR_div2{1,31}/MGB_evoked0)
yline(mean(MGB_FR_div2{1,31}(400:499))/MGB_evoked0)
plot(MGB_FR_div2{1,67}/MGB_evoked0)
plot(MGB_FR_laser{4,2}/MGB_evoked0)
xlim([400 700]);
ylim([0 2]);
ylabel("FR (norm)")
xlabel("time (ms)")

counter=counter+1;

subplot(4,2,counter);hold on
plot(MGB_FR_div2{1,31}/MGB_evoked0)
yline(mean(MGB_FR_div2{1,31}(400:499))/MGB_evoked0)
plot(MGB_FR_div2{1,103}/MGB_evoked0)
plot(MGB_FR_laser{4,3}/MGB_evoked0)
xlim([400 700]);
ylim([0 2]);
xlabel("time (ms)")

counter=counter+1;
