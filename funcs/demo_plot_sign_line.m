% Function that plots a horizontal line above the graph that indicates the
% statistically significant difference between the two conditions and/or areas

function demo_plot_sign_line(time, data, ylim, offset, rgb)

        sign_t = data{1,1};
        for t=1:length(sign_t)-1   
            if sign_t(1,t)==3
                plot([time(t) time(t+1)], [ylim+offset ylim+offset], 'color', rgb(1,:), 'Linewidth', 3);
            end
        end

end