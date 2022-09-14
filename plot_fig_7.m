% add main folder and subfolders to the Matlab path 
close all, clear all
% select panel to plot 'fig_7a','fig_7b','fig_7c'
select_panel = 'fig_7c';
switch select_panel
    case 'fig_7a';
        load('fig_7a_att.mat');
        acc_att   = all_accuracies;
        null_att  = null_accuracies;
        load('fig_7a_natt.mat');
        acc_natt  = all_accuracies;
        null_natt = null_accuracies;
        titlestr = 'Color';
    case 'fig_7b';
        load('fig_7b_att.mat');
        acc_att   = all_accuracies;
        null_att  = null_accuracies;
        load('fig_7b_natt.mat');
        acc_natt  = all_accuracies;
        null_natt = null_accuracies;
        titlestr = 'Orientation';
    case 'fig_7c'
        load('fig_7c_att.mat');
        acc_att   = all_accuracies;
        null_att  = null_accuracies;
        load('fig_7c_natt.mat');
        acc_natt  = all_accuracies;
        null_natt = null_accuracies;
        titlestr = 'Identity';
end
init_time    = 1;
end_time    = 1301;
zerotime    = 201;
time_window = 100;
time_step   = 10;
time = init_time+time_window/2:time_step:end_time-time_window/2;
time = time-zerotime;

figure('color', [1 1 1]);
rgb = [0 0 0; 0.8 0 0];
plot(time,mean(acc_natt,1),'color',rgb(1,:),'Linewidth',3), hold on 
plot(time,mean(acc_att,1), 'color',rgb(2,:),'Linewidth',3)
ylim([40 100]);
xlim([-150 1050]);

ax = gca;
ax.YTick = 50:25:100;
ylims = get(gca,'ylim');
chance   = 50;

rect = [0.1, 0.15, 1.3, .15];
plot([0     0], [0 100], '--k', 'LineWidth', 0.8);
plot([600 600], [0 100], '--k', 'LineWidth', 0.8);
plot([time(1) time(end)], [chance chance], '--k', 'Color', [0.5, 0.5, 0.5]);
title(titlestr)
xlabel('Time from array onset (s)')
ylabel('Decoding perfomance (% correct)')

% compare the two conditions using a cluster-based permutation test 
% requires function permutest: https://www.mathworks.com/matlabcentral/fileexchange/71737-permutest
[clusters, p_values] = permutest(acc_att', acc_natt', 0, 0.001, 10^3, 1);
obsDiff = mean(acc_att,1)-mean(acc_natt,1);
for iClust = 1: length(clusters)
    if p_values(iClust)<0.001
        if mean(obsDiff(clusters{iClust})) > 0
            color = rgb(2,:);
        else
            color = rgb(1,:);
        end
        line([time(clusters{iClust}(1)) time(clusters{iClust}(end))], [ylims(1)+5 ylims(1)+5],'linewidth',4, 'color',color)
    end
end
hold on
pValues = zeros(size(null_natt,2),2);
for iTime = 1:length(time)
    pValues(iTime,1) = (sum(mean(acc_natt(:,iTime))<null_natt(:,iTime))+1)/(size(null_natt,1)+1);
    pValues(iTime,2) = (sum(mean(acc_att(:,iTime)) <null_att(:,iTime))+1)/(size(null_att,1)+1);
end
for iTime = 1: length(time)
    if pValues(iTime,1)<=0.05
        line([time(iTime)-time_step/1.2  time(iTime)+time_step/1.2], [ylims(2)-2 ylims(2)-2], 'linewidth',4, 'color',rgb(1,:));
    end
    if pValues(iTime,2)<=0.05
        line([time(iTime)-time_step/1.2  time(iTime)+time_step/1.2], [ylims(2)-4 ylims(2)-4], 'linewidth',4, 'color',rgb(2,:));
    end
end

legend('non-attended stimulus','attended stimulus','location','best');
legend('boxoff')
