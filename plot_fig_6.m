% add main folder and subfolders to the Matlab path 
close all, clear all
% select panel to plot 'fig_6a', 'fig_6b', 'fig_6c'
select_panel = 'fig_6c';
switch select_panel
    case 'fig_6a'
        load('fig_6a_mem.mat');
        acc_mem  = final_accuracy;
        null_mem = shuffled_accuracy;
        load('fig_6a_dyn.mat');
        acc_dyn  = final_accuracy;
        null_dyn = shuffled_accuracy;
        
        mean_accuracies = vertcat(mean(acc_mem),mean(acc_dyn));        
        
        figure('color', [1 1 1]);
        rgb = [0 0 0; 0.8 0 0];
        plot(time_binned, mean_accuracies(1,:), 'Color',rgb(1, :),'LineWidth',3); hold on,
        plot(time_binned, mean_accuracies(2,:), 'Color',rgb(2, :),'LineWidth',3); hold on,
        
        p_1 = demo_chance(acc_mem, null_mem);
        sign1_t = zeros(1,size(mean_accuracies,2));
        for t=1:length(time_binned)
            sign1_t = demo_st_level(sign1_t,time_binned,t,p_1(1,:),0.001);
        end
        demo_plot_sign_line(time_binned, {sign1_t}, 102, 2, rgb(1,:));
        p_2 = demo_chance(acc_dyn, null_dyn);
        sign2_t = zeros(1,size(mean_accuracies,2));
        for t=1:length(time_binned)
            [sign2_t] = demo_st_level(sign2_t,time_binned,t,p_2(1,:),0.001);
        end
        demo_plot_sign_line(time_binned, {sign1_t}, 102, 4, rgb(2,:));
        
        % compare the two conditions using a cluster-based permutation test
        % requires function permutest: https://www.mathworks.com/matlabcentral/fileexchange/71737-permutest
        [clusters, p_values] = permutest(acc_mem', acc_dyn', 0, 0.001, 10^3, 1);
        ylims = get(gca, 'ylim');
        obsDiff = mean(acc_mem,1)-mean(acc_dyn,1);
        for iClust = 1: length(clusters)
            if p_values(iClust)<0.001
                if mean(obsDiff(clusters{iClust})) > 0
                    color = rgb(1,:);
                else
                    color = rgb(2,:);
                end
                line([time_binned(clusters{iClust}(1))  time_binned(clusters{iClust}(end))], [ylims(1)-10 ylims(1)-10],'linewidth',4, 'color',color)
            end
        end
        
        xlim([30 time_binned(end)]);
        ylim([20 110]);
        ax = gca;
        ax.YTick = 20:20:100;
        ylims = get(gca,'ylim');
        xlabel('Time(s)');
        ylabel('Decoding accuarcy (% correct)');
        set(ax, 'xtick', [0:300:900, 1100: 200:1400, 1500:200:1800]);
        set(ax, 'xticklabels', [0:0.3:0.9, 1.1:0.2:1.4, -0.3:0.2:0]);
        rectangle('Position',[1350 0 100 ylims(2)],'EdgeColor','k','FaceColor','w'), hold on,
        hold on;
        plot([900 900], [0 100],  '--k', 'LineWidth', 0.8);
        chance = 100/3;
        plot([time_binned(1) time_binned(end)], [chance chance], '--k')
        legend('memory','dynamic','location','best')
        legend('boxoff')
    case 'fig_6b';
        load('fig_6b.mat');
        
        % Q is the basis of the shared subspace
        proj_delay = Q'*frmem;
        proj_cue   = Q'*frcue;
        
        % figure may differ from the original as trials projected into the subspace
        % were selected using a random permutation procedure
        figure('color',[1 1 1])
        plot(proj_delay(1,labels==1), proj_delay(2,labels==1),'ro', 'LineWidth', 2), hold on
        plot(proj_delay(1,labels==2), proj_delay(2,labels==2),'go', 'LineWidth', 2), hold on
        plot(proj_delay(1,labels==3), proj_delay(2,labels==3),'bo', 'LineWidth', 2), hold on
        plot(proj_cue(1,labels==1),   proj_cue(2,labels==1),  'r+', 'LineWidth', 2), hold on
        plot(proj_cue(1,labels==2),   proj_cue(2,labels==2),  'g+', 'LineWidth', 2), hold on
        plot(proj_cue(1,labels==3),   proj_cue(2,labels==3),  'b+', 'LineWidth', 2)
        xlabel('Subspace axis 1')
        ylabel('Subspace axis 2')
    case 'fig_6c'
        load('fig_6c.mat');
        
        nTimes = size(ct_accuracy,1);
        pvals  = nan(nTimes,nTimes);
        for ii=1:nTimes
            for jj=1:nTimes
                pvals(jj,ii) = (sum(ct_accuracy_diag(ii,ii,:)<mean(ct_accuracy(jj,ii,:))))/(size(ct_accuracy_diag,3));
            end
        end
        
        % restrict data in the late delay period
        ct_accuracy(132:147, :, :) = [];
        ct_accuracy(:, 132:147, :) = [];
        pvals(132:147, :)  = [];
        pvals(:, 132:147)  = [];
        
        figure('color',[1 1 1]);
        clims = [25 85];
        imagesc(mean(ct_accuracy,3), clims);
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
        sign = pvals<0.001;
        sign = imgaussfilt(double(sign),3);
        hold on,
        contour(1:size(ct_accuracy,1),1:size(ct_accuracy,2),sign,1,'Linewidth',2,'LineColor',[0.16 0.24 0.24],'LineStyle','--');
        
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

