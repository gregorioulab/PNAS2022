close all, clear all
rgb = [0 0 .8; 0.8 0 0];
% select panel to plot 'fig_5a', 'fig_5b', 'fig_5c', 'fig_5d' or 'fig_5e'
select_panel = 'fig_5d';
switch select_panel
    case 'fig_5a'
        load('fig_5a.mat')
      
        % restrict data in the late delay period
        accuracies(132:147, :, :) = [];
        accuracies(:, 132:147, :) = [];
        
        figure('color',[1 1 1]);
        clims = [40 100];
        imagesc(mean(accuracies,3), clims);
        set(gca,'YDir','normal');
        % requires function customcolormap: https://www.mathworks.com/matlabcentral/fileexchange/69470-custom-colormap
        mycolormap = customcolormap(linspace(0,1,9), {'#cd002b','#f66e44','#ffd97f','#def4f9','#abd9e9','#73add2','#4873b5','#363ba8','#313691'});
        colormap(mycolormap);
        % otherwise use Matlab's colormap
        % colormap('jet');
        
        c = colorbar;
        c.Label.String = 'Decoding accuracy (% correct)';
        
        ylims = get(gca,'ylim');
        % plot the delay period onset
        hold on;
        plot([86 86], [0 size(accuracies,1)], '--w', 'LineWidth', 2);
        plot([0 size(accuracies,1)], [86 86], '--w', 'LineWidth', 2);
        rectangle('Position',[131 0 2 ylims(2)],'EdgeColor','w','FaceColor','w'), hold on,
        rectangle('Position',[0 131 ylims(2) 2],'EdgeColor','w','FaceColor','w')
        
        xlabel('Train time (s)')
        ylabel('Test time (s)')
        
        ax = gca;
        set(ax, 'xtick', [26:30:131,132:20:156]);
        set(ax, 'xticklabels', [0.3:0.3:1.3+0.1,-0.3:0.2:0+0.1]);
        set(ax, 'ytick', [26:30:131,132:20:156]);
        set(ax, 'yticklabels', [0.3:0.3:1.3+0.1,-0.3:0.2:0+0.1]);
 
    case 'fig_5b';
        load('fig_5b.mat');
        
        figure('color',[1 1 1])
        imagesc(xaxis, 1: size(all_clusts,1), all_clusts)
        
        set(gca,'YDir','normal')
        
        height = 0;
        for iClust = 1: 2
            rectangle('Position',[0,height,0.08,sum(select_idx{iClust})],'FaceColor',rgb(iClust,:),'EdgeColor',rgb(iClust,:),'LineWidth',3)
            height = height + sum(select_idx{iClust});
        end
        
        colormap hot
        hc = colorbar;
        
        caxis([2 20])
        ylims = get(gca,'ylim');
        line([0.9 0.9], [ylims(1) ylims(2)], 'color', 'w', 'linestyle', '--')
        
        set(gca,'XTick',0:0.3:1.8)
        set(gca,'XTickLabel',[0:0.3:1.2,-0.3,0])
        set(gca,'YTick',20:40:ylims(2))
        hc.Ticks = hc.Ticks(1):4:hc.Ticks(end);
        
        xlabel('Time(s)')
        ylabel('Unit Number')
        ylabel(hc, 'Percentage of Explained Variance (z-scored)');
        
        rectangle('Position',[1.35 0 .01 ylims(2)],'EdgeColor','w','FaceColor','w')
    case 'fig_5c'
        load('fig_5c.mat');
        
        figure('color', [1 1 1]);
                
        zerotime    = 301;
        time_window = 100;
        time_step   = 10;
        init_time   = [101 1701];
        end_time    = [1701 2202];
        time = [init_time(1)+time_window/2:time_step:end_time(1)-time_window/2,init_time(2)+time_window/2:time_step:end_time(2)-time_window/2];
        time = time-zerotime;
        time(152:end) = time(152:end) - 100;
        time(152:161) = [];
        h = [];
        nClusts = max(clust_indices{:});
        for iUnitClust = 1: nClusts
            null = null_accuracies{iUnitClust};
            % restrict data in the late delay period
            accuracies{iUnitClust}(:,152:161) = [];
            null(:,152:161)                   = [];
            
            mean_accuracies = mean(accuracies{iUnitClust},1);
            h(iUnitClust) = plot(time, mean_accuracies(1,:), 'Color',rgb(iUnitClust, :),'LineWidth',3); hold on,
            p_1 = demo_chance(accuracies{iUnitClust}, null);
            sign1_t = zeros(1,size(mean_accuracies,2));
            for t=1:length(time)
                sign1_t = demo_st_level(sign1_t,time,t,p_1,0.001);
            end
            hold on,
            demo_plot_sign_line(time, {sign1_t}, 102, 2+iUnitClust, rgb(iUnitClust,:));
        end
        
        % compare the two conditions using a cluster-based permutation test
        % requires function permutest: https://www.mathworks.com/matlabcentral/fileexchange/71737-permutest
        [clusters, p_values] = permutest(accuracies{1}', accuracies{2}', 0, 0.001, 10^3, 1);
        ylims = get(gca, 'ylim');
        obsDiff = mean(accuracies{1},1)-mean(accuracies{2},1);
        for iClust = 1: length(clusters)
            if p_values(iClust)<0.001
                if mean(obsDiff(clusters{iClust})) > 0
                    color = rgb(1,:);
                else
                    color = rgb(2,:);
                end
                for ii = 1: length(clusters{iClust})
                    line([time(clusters{iClust}(1))  time(clusters{iClust}(end))], [ylims(1)+0.5 ylims(1)+0.5],'linewidth',4, 'color',color), hold on,
                end
            end
        end
        
        xlim([time(1) time(end)]);
        ylim([20 110]);
        
        ax = gca;
        ax.YTick = 20:20:100;
        set(ax, 'xtick', [0:300:900, 1100: 200:1400, 1500:200:1800]);
        set(ax, 'xticklabels', [0:0.3:0.9, 1.1:0.2:1.4, -0.3:0.2:0]);
        
        plot([900 900], [0 ylims(2)], '--k', 'LineWidth', 0.8);
        plot([0 0],     [0 ylims(2)], '--k', 'LineWidth', 0.8);
        plot([time(1) time(end)], [100/3 100/3], '--k');
        
        rectangle('Position',[1350 0 100 ylims(2)],'EdgeColor','k','FaceColor','w'), hold on,
        
        legend(h, {['group 1, n=',num2str(sum(clust_indices{:}==1))],['group 2, n=',num2str(sum(clust_indices{:}==2))]},'location','best'); legend('boxoff');
    case 'fig_5d'
        load('fig_5d.mat');

        figure('color',[1 1 1])
        
        timo = time(1+3:end-3);
        for iGroup = 1:2
            mean_data = mean(data{iGroup},2);
            dataBaseline(iGroup)     = mean(mean_data(time<0));
            dataBaseline_trl{iGroup} = prctile(data{iGroup}(time<0,:),95)-dataBaseline(iGroup);
            
            mean_data = mean_data - dataBaseline(iGroup);
            
            h(iGroup)=plot(timo, mean_data,'Color',rgb(iGroup, :),'LineWidth',3); hold on,
        end
    
        ax = gca;
        ylim([-2 14])
        xlim([timo(1), timo(end)])
        ylims = get(gca,'ylim');
        set(ax, 'xtick', [0:300:900, 1100: 200:1400, 1500:200:1800]);
        set(ax, 'xticklabels', [0:0.3:0.9, 1.1:0.2:1.4, -0.3:0.2:0]);
        
        plot([900 900],ylims,  '--k', 'LineWidth', 0.8);
        plot([0 0],ylims,  '--k', 'LineWidth', 0.8);
        xlabel('Time(s)');
        ylabel('Multidimensional Velocity (Hz/sec)');
        legend([h(1),h(2)],'group 1','group 2','location','best');
        legend('boxoff')
        
        tmp1 = data{1}-dataBaseline(1);
        tmp2 = data{2}-dataBaseline(2);
        
        % compare the two conditions using a cluster-based permutation test
        % requires function permutest: https://www.mathworks.com/matlabcentral/fileexchange/71737-permutest
        [clusters, p_values] = permutest(tmp1, tmp2, 0, 0.001, 10^3, 1);
        ylims = get(gca, 'ylim');
        obsDiff = mean(tmp1,2)-mean(tmp2,2);
        for iClust = 1: length(clusters)
            if p_values(iClust)<0.001
                for ii = 1: length(clusters{iClust})
                    if obsDiff(clusters{iClust}(ii)) > 0
                        color = rgb(1,:);
                    else
                        color = rgb(2,:);
                    end
                    line([timo(clusters{iClust}(1))  timo(clusters{iClust}(end))], [ylims(1)+1 ylims(1)+1],'linewidth',4, 'color',color)
                end
            end
        end

        demo_makeSignBar( dataBaseline_trl{1}', tmp1', timo, 1000, [.5 .5 .5], rgb(1,:), 1, -0.6)
        demo_makeSignBar( dataBaseline_trl{2}', tmp2', timo, 1000, [.5 .5 .5], rgb(2,:), 1, -0.3)
        rectangle('Position',[1310 ylims(1) 180 ylims(2)-ylims(1)],'EdgeColor','k','FaceColor','w'), hold on,
    case 'fig_5e'
        load('fig_5e.mat')
        
        nTimes = size(accuracies,1);
        pvals  = nan(nTimes,nTimes);
        for ii=1:nTimes
            for jj=1:nTimes
                pvals(jj,ii) = (sum(diag_accuracies(ii,ii,:)<mean(accuracies(jj,ii,:))))/(size(diag_accuracies,3));
            end
        end
        
        % restrict data in the late delay period
        accuracies(132:147, :, :) = [];
        accuracies(:, 132:147, :) = [];
        pvals(132:147, :)  = [];
        pvals(:, 132:147)  = [];
        
        figure('color',[1 1 1]);
        clims = [25 90];
        imagesc(mean(accuracies,3), clims);
        set(gca,'YDir','normal');
        % requires function customcolormap: https://www.mathworks.com/matlabcentral/fileexchange/69470-custom-colormap
        mycolormap = customcolormap(linspace(0,1,9), {'#cd002b','#f66e44','#ffd97f','#def4f9','#abd9e9','#73add2','#4873b5','#363ba8','#313691'});
        colormap(mycolormap);
        % otherwise use Matlab's colormap
        % colormap('jet');
        
        c = colorbar;
        c.Label.String = 'Decoding accuracy (% correct)';
        
        ylims = get(gca,'ylim');
        
        % contour
        sign = pvals<0.01;
        sign = imgaussfilt(double(sign),3);
        hold on,
        contour(1:size(accuracies,1),1:size(accuracies,2),sign,1,'Linewidth',2,'LineColor',[0.16 0.24 0.24],'LineStyle','--');
        
        % plot the delay period onset
        hold on;
        plot([86 86], [0 size(pvals,1)], '--w', 'LineWidth', 2);
        plot([0 size(pvals,1)], [86 86], '--w', 'LineWidth', 2);
        rectangle('Position',[131 0 2 ylims(2)],'EdgeColor','w','FaceColor','w'), hold on,
        rectangle('Position',[0 131 ylims(2) 2],'EdgeColor','w','FaceColor','w')
        
        xlabel('Train time (s)')
        ylabel('Test time (s)')
        
        ax = gca;
        set(ax, 'xtick', [26:30:131,132:20:156]);
        set(ax, 'xticklabels', [0.3:0.3:1.3+0.1,-0.3:0.2:0+0.1]);
        set(ax, 'ytick', [26:30:131,132:20:156]);
        set(ax, 'yticklabels', [0.3:0.3:1.3+0.1,-0.3:0.2:0+0.1]);
end
