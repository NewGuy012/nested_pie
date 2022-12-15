function p = pie_nested
%pie_nested

clc;
close all;

fig = figure;
background_color = 'w';

fig.Color = background_color;
ax = gca;
ax.Color = background_color;

% Axis limits
hold(ax, 'on');
axis(ax, 'square');
scaling_factor = 1.2;
axis(ax, [-1, 1, -1, 1] * scaling_factor);

pie_labels = {'RDU', 'FDU', 'Aero'};

% Axis properties
ax.XTickLabel = [];
ax.YTickLabel = [];
ax.XColor = 'none';
ax.YColor = 'none';

X = {{0.2, 0.05, 0.25, 0.1, 0.4};...
    {0.25, 0.25, 0.5}};

num_pie = length(X);

rho_lower = 0.2;
rho_upper = 1;
rho_range = rho_upper - rho_lower;

rho_interval = rho_range/num_pie;
rho = rho_lower:rho_interval:rho_upper;

c = turbo(8);

iCounter = 0;

for ii = 1:num_pie
    sub_pie = cell2mat(X{ii});

    if sum(sub_pie) ~= 1
        warning('Data does not sum to 1. Attempting to normalize data...');
        % Normalize data
        sub_pie = sub_pie / sum(sub_pie);
    end

    num_wedges = length(sub_pie);

    theta = 2 * pi * sub_pie;
    theta = cumsum(theta);
    theta = [0, theta];

    for jj = 1:num_wedges
        iCounter = iCounter + 1;

        theta_start = theta(jj);
        theta_end = theta(jj+1);

        rho_start = rho(ii);
        rho_end = rho(ii+1);

        theta_sides = [theta_start, theta_end, theta_end, theta_start, theta_start];
        rho_sides = [rho_start, rho_start, rho_end, rho_end, rho_start];

        x = [];
        y = [];
        interval_res = 0.01;

        for kk = 1:4
            interval = interval_res;
            if theta_sides(kk) > theta_sides(kk+1)
                interval = -interval_res;
            end

            theta_side = theta_sides(kk):interval:theta_sides(kk+1);
            rho_side = rho_sides(kk) * ones(1, length(theta_side));

            [x_cart, y_cart] = pol2cart(theta_side, rho_side);

            x = [x, x_cart];
            y = [y, y_cart];
        end

        patch(x, y, c(iCounter, :),...
            'EdgeColor', 'k',...
            'LineWidth', 1);
    end

    if ii ~= 1
        theta_diff = diff(theta)/2;
        theta_diff = theta(1:end-1) + theta_diff;

        rho_delta = diff(rho)/2;
        rho_diff = rho(1:end-1) + rho_delta;

        rho_diff = rho_diff(2:end);

        rho_labels = rho(end) + rho_delta;

        for jj = 1:length(rho_diff)


            rho_txt = rho_diff(jj);
            rho_label = rho_labels(jj);

            for kk = 1:length(theta_diff)
                theta_txt = theta_diff(kk);
                percent_txt = sprintf('%.1f%%', sub_pie(kk)*100);


                [x_txt, y_txt] = pol2cart(theta_txt, rho_txt);
                text(x_txt, y_txt, percent_txt,...
                    'Color', 'w',...
                    'FontWeight', 'bold',...
                    'HorizontalAlignment', 'center');

                [x_label, y_label] = pol2cart(theta_txt, rho_label);
                text(x_label, y_label, pie_labels{kk},...
                    'Color', 'k',...
                    'FontWeight', 'bold',...
                    'HorizontalAlignment', 'center');

            end
        end


    end
end

title('Nested Pie Chart');

inner_pie = cell2mat(X{1});
legend_str = cell(length(inner_pie), 1);

for ii = 1:length(inner_pie)
    legend_str{ii} = sprintf('Wedge #%i: %.2f%%', ii, inner_pie(ii)*100);
end

lg = legend(legend_str,...
    'Location', 'southoutside',...
    'NumColumns', 1);
lg.Title.String = 'Inner Pie';
end