% add main folder and subfolders to the Matlab path 

zerotime    = 301;
time_window = 100;
time_step   = 10;
init_time   = [101 1701];
end_time    = [1701 2202];

time = [init_time(1)+time_window/2:time_step:end_time(1)-time_window/2,init_time(2)+time_window/2:time_step:end_time(2)-time_window/2];
time = time - zerotime;

% select panel to plot 'fig_4b', 'fig_4c'
select_panel = 'fig_4b';
switch select_panel
    case 'fig_4b';
        label = 'Multidimensional distance (Hz)';
        load('fig_4b.mat');
    case 'fig_4c'
        label = 'Multidimensional Velocity (Hz/sec)';
        load('fig_4c.mat');
        time = time(1+step:end-step);
end

figure('color',[1 1 1])
rgb = [0 0 0; 0.8 0 0];
for iCond = 1:2
    mean_data = mean(data{iCond},2);
    dataBaseline(iCond)     = mean(mean_data(time<0));
    dataBaseline_trl{iCond} = mean(data{iCond}(time<0,:),1)-dataBaseline(iCond);
    
    mean_data = mean_data - dataBaseline(iCond);
    
    h(iCond)=plot(time, mean_data,'Color',rgb(iCond, :),'LineWidth',3); hold on,
end

ax = gca;
xlim([time(1), time(end)])
ylims = get(gca,'ylim');
set(ax, 'xtick', [0:300:900, 1100: 200:1400, 1500:200:1800]);
set(ax, 'xticklabels', [0:0.3:0.9, 1.1:0.2:1.4, -0.3:0.2:0]);

array_pres = 0; cue_pres = 900;
plot([cue_pres cue_pres],ylims,  '--k', 'LineWidth', 0.8);
plot([array_pres array_pres],ylims,  '--k', 'LineWidth', 0.8);
xlabel('Time from cue onset (s)');
ylabel(label);
legend([h(1),h(2)],'spatial','color','location','best');
legend('boxoff')

tmp1 = data{1}([1:151,162:end],:,:)-dataBaseline(1);
tmp2 = data{2}([1:151,162:end],:,:)-dataBaseline(2);

% compare the two conditions using a cluster-based permutation test
% requires function permutest: https://www.mathworks.com/matlabcentral/fileexchange/71737-permutest
[clusters, p_values] = permutest(tmp1, tmp2, 0, 0.001, 10^4, 1);
ylims = get(gca, 'ylim');
obsDiff = mean(tmp1,2)-mean(tmp2,2);
for iClust = 1: length(clusters)
    if p_values(iClust)<0.001
        for ii = 1: length(clusters{iClust})
            if obsDiff(ii) > 0
                color = rgb(1,:);
            else
                color = rgb(2,:);
            end
            line([time(clusters{iClust}(1))  time(clusters{iClust}(end))], [ylims(1)+3 ylims(1)+3],'linewidth',4, 'color',color)
        end
    end
end
switch select_panel
    case 'fig_4b';
        set(ax, 'ytick', 0:40:ylims(2));
        set(ax, 'yticklabels',0:40:ylims(2));
        demo_makeSignBar( dataBaseline_trl{1}', tmp1', time, 1000, [.5 .5 .5], rgb(1,:), 1, 5)
        demo_makeSignBar( dataBaseline_trl{2}', tmp2', time, 1000, [.5 .5 .5], rgb(2,:), 1, 8)
        rectangle('Position',[1350 ylims(1) 100 ylims(2)-ylims(1)],'EdgeColor','k','FaceColor','w'), hold on,
    case 'fig_4c'
        demo_makeSignBar( velBaseline_trl{1}', tmp1', timeo, 1000, [.5 .5 .5], rgb(1,:), 1, -1)
        demo_makeSignBar( velBaseline_trl{2}', tmp2', timeo, 1000, [.5 .5 .5], rgb(2,:), 1, -2)
        rectangle('Position',[1310 ylims(1) 180 ylims(2)-ylims(1)],'EdgeColor','k','FaceColor','w'), hold on,
end
