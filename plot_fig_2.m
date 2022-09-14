close all, clear
% add main folder and subfolders to the Matlab path 
% select panel to plot 'fig_2a' or 'fig_2b
select_panel = 'fig_2a';
switch select_panel
    case 'fig_2a';
        area = 'vlPFC';
        area_spatial  = load('fig_2a_spatial.mat');
        area_color    = load('fig_2a_color.mat');
    case 'fig_2b'
        area = 'FEF';
        area_spatial  = load('fig_2b_spatial.mat');
        area_color    = load('fig_2b_color.mat');
end

acc_spatial  = area_spatial.all_accuracies;
acc_color    = area_color.all_accuracies;
null_spatial = area_spatial.null_accuracies;
null_color   = area_color.null_accuracies;
num_neur     = [area_spatial.num_neur, area_color.num_neur];

idx = all(acc_spatial==0,2); acc_spatial(idx,:)=[];
idx = all(acc_color==0,2)  ; acc_color(idx,:)  =[];

mean_accuracies = vertcat(mean(acc_spatial),mean(acc_color));
sem_accuracies  = vertcat(std(acc_spatial), std(acc_color));

% x-axis
zerotime    = 301;
time_window = 100;
time_step   = 10;
init_time   = [101  1701];
end_time    = [1701 2202];
time = [init_time(1)+time_window/2:time_step:end_time(1)-time_window/2,init_time(2)+time_window/2:time_step:end_time(2)-time_window/2];
time = time-zerotime;

% restrict data in the late delay period
mean_accuracies(:,152:161) = [];
sem_accuracies(:,152:161)  = [];
acc_spatial(:,152:161)     = [];
acc_color(:,152:161)       = [];
null_spatial(:,152:161)    = [];
null_color(:,152:161)      = [];
time(152:161)              = [];
time(152:end) = time(152:end)-100;

% create the plot
figure('color', [1 1 1])
rgb = [0 0 0; 0.8 0 0];
plot(time, mean_accuracies(1,:), 'Color',rgb(1, :),'LineWidth',3); hold on,
plot(time, mean_accuracies(2,:), 'Color',rgb(2, :),'LineWidth',3); hold on,
    
xlim([time(1) time(end)]);
ylim([20 110]);

ax = gca;
ax.YTick = 20:20:100;
ylims = get(gca,'ylim');
set(ax, 'xtick', [0:300:900, 1100: 200:1400, 1500:200:1800]);
set(ax, 'xticklabels', [0:0.3:0.9, 1.1:0.2:1.4, -0.3:0.2:0]);
cue_pres = 900;
array_pres = 0;

% compare the two conditions using a cluster-based permutation test 
% requires function permutest: https://www.mathworks.com/matlabcentral/fileexchange/71737-permutest
idx = time>=0;
[clusters, p_values] = permutest(acc_spatial', acc_color', 0, 0.001, 10^3, 1);
obsDiff = mean(acc_spatial,1)-mean(acc_color,1);
for iClust = 1: length(clusters)
    if p_values(iClust)<0.001
        if mean(obsDiff(clusters{iClust})) > 0
            color = rgb(1,:);
        else
            color = rgb(2,:);
        end
        line([time(clusters{iClust}(1)) time(clusters{iClust}(end))], [ylims(1)+5 ylims(1)+5],'linewidth',4, 'color',color)
    end
end

% plot significance relative to chance
p_1 = demo_chance(acc_spatial, null_spatial);
sign1_t = zeros(1,size(mean_accuracies,2));
for t=1:length(time)
    sign1_t = demo_st_level(sign1_t,time,t,p_1(1,:),0.001);
end
demo_plot_sign_line(time, {sign1_t}, 102, 2, rgb(1,:));
if ~isempty(acc_color)
p_1 = demo_chance(acc_color, null_color);
sign1_t = zeros(1,size(mean_accuracies,3));
for t=1:length(time)
    sign1_t = demo_st_level(sign1_t,time,t,p_1(1,:),0.001);
end
demo_plot_sign_line(time, {sign1_t}, 102, 4, rgb(2,:));
end

% chance level
chance = 100/3;
plot([time(1) time(end)], [chance chance], '--', 'Color', [0.5, 0.5, 0.5]);
plot([0 0],     [20 110],  '--', 'Color', [0.5, 0.5, 0.5]);
plot([900 900], [20 110],  '--', 'Color', [0.5, 0.5, 0.5]);

rectangle('Position',[1350 0 100 ylims(2)],'EdgeColor','k','FaceColor','w'), hold on,

xlabel('Time(s)');
ylabel('Decoding accuarcy (% correct)');
title(area);
legend('spatial cue','color cue', 'location','best');
legend('boxoff');

