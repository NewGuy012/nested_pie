function varargout = pie_nested(C, varargin)
%pie_nested Create a nested pie chart.
%
% Syntax:
%   pie_nested(C)
%   pie_nested(C, Name, Value, ...)
%   h = pie_nested(_)
%
% Documentation:
%   Please refer to the MathWorks File Exchange or GitHub page for the
%   detailed documentation and examples.

% Figure properties
fig = figure;
background_color = 'w';
fig.Color = background_color;

% Check for output arguments
if nargout > 1
    error('Error: Too many output arguments assigned.');
end
varargout{1} = fig;

% Axes properties
ax = gca;
ax.Color = background_color;

% Axis properties
hold(ax, 'on');
axis(ax, 'square');
scaling_factor = 1.2;
axis(ax, [-1, 1, -1, 1] * scaling_factor);

% Axis properties
ax.XTickLabel = [];
ax.YTickLabel = [];
ax.XColor = 'none';
ax.YColor = 'none';

% Pie properties
num_pie = length(C);
num_outmost = length(C{end});
pie_labels = cell(num_outmost, 1);

% Number of wedges
num_wedges = cellfun(@(C) length(C), C, 'UniformOutput', false);
num_wedges = cell2mat(num_wedges);
max_wedges = max(num_wedges);

% Default labels
for ii = 1:num_outmost
    pie_labels{ii} = sprintf('Label %i', ii);
end

% Pre-allocation
wedge_colors = cell(num_pie, 1);

% Default arguments
rho_lower = 0.2;
edge_color = 'k';
line_width = 2;
line_style = '-';
wedge_colors(:) = {lines(max_wedges)};
percent_status = 'on';
percent_precision = 2;
label_fontsize = 10;
fill_transparency = 1;
label_interpreter = 'none';
interval_res = 0.01;

% Number of optional arguments
numvarargs = length(varargin);

% Check if optional arguments were specified
if numvarargs > 1
    % Initialze name-value arguments
    name_arguments = varargin(1:2:end);
    value_arguments = varargin(2:2:end);

    % Iterate through name-value arguments
    for ii = 1:length(name_arguments)
        % Set value arguments depending on name
        switch lower(name_arguments{ii})
            case 'rholower'
                rho_lower = value_arguments{ii};
            case 'edgecolor'
                edge_color = value_arguments{ii};
            case 'linewidth'
                line_width = value_arguments{ii};
            case 'linestyle'
                line_style = value_arguments{ii};
            case 'wedgecolors'
                wedge_colors = value_arguments{ii};
            case 'percentstatus'
                percent_status = value_arguments{ii};
            case 'percent_precision'
                percent_precision = value_arguments{ii};
            case 'labelfontsize'
                label_fontsize = value_arguments{ii};
            case 'filltransparency'
                fill_transparency = value_arguments{ii};
            case 'labelinterpreter'
                label_interpreter = value_arguments{ii};
            otherwise
                error('Error: Please enter in a valid name-value pair.');
        end
    end

end

% Initialize rho
rho_upper = 1;
rho_range = rho_upper - rho_lower;
rho_interval = rho_range/num_pie;
rho = rho_lower:rho_interval:rho_upper;

% Iterate through number of nested pies
for ii = 1:num_pie
    % Initialize
    sub_pie = C{ii}; % Convert from cell to numerical array
    num_wedge = num_wedges(ii);
    wedge_color = wedge_colors{ii};

    % Check if data does not sum to one
    if sum(sub_pie) ~= 1
        % Display warning
        warning('Data does not sum to 1. Attempting to normalize data...');
        
        % Normalize data to add up to one
        sub_pie = sub_pie / sum(sub_pie);
    end

    % Initialize theta
    theta = 2 * pi * sub_pie;
    theta = cumsum(theta);
    theta = [0, theta]; %#ok<*AGROW> 

    % Iterate through number of wedges
    for jj = 1:num_wedge
        % Initialize
        theta_start = theta(jj);
        theta_end = theta(jj+1);

        rho_start = rho(ii);
        rho_end = rho(ii+1);

        % Make cyclic
        theta_sides = [theta_start, theta_end, theta_end, theta_start, theta_start];
        rho_sides = [rho_start, rho_start, rho_end, rho_end, rho_start];

        % Initialize
        x_patch = [];
        y_patch = [];
        
        % Iterate through a four-sided polygon
        for kk = 1:4
            % Initialize
            interval = interval_res;

            % Check if interval needs to be flipped
            if theta_sides(kk) > theta_sides(kk+1)
                interval = -interval_res;
            end

            % Polar coordinates of polygon
            theta_side = theta_sides(kk):interval:theta_sides(kk+1);
            rho_side = rho_sides(kk) * ones(1, length(theta_side));

            % Convert from polar to cartesian coordinates
            [x_cart, y_cart] = pol2cart(theta_side, rho_side);

            % Append to array
            x_patch = [x_patch, x_cart];
            y_patch = [y_patch, y_cart];
        end

        % Create patch object
        patch(x_patch, y_patch, wedge_color(jj, :),...
            'LineStyle', line_style,...
            'EdgeColor', edge_color,...
            'LineWidth', line_width,...
            'FaceAlpha', fill_transparency);
    end

    % For all wedges not in the innermost layer
    if ii ~= 1
        % Find midpoint of theta and rho
        theta_diff = diff(theta)/2;
        theta_diff = theta(1:end-1) + theta_diff;

        rho_delta = diff(rho)/2;
        rho_diff = rho(1:end-1) + rho_delta;
        rho_diff = rho_diff(2:end);
        rho_labels = rho(end) + rho_delta;

        % Iterate through rho midpoints
        for jj = 1:length(rho_diff)
            % Initialize
            rho_txt = rho_diff(jj);
            rho_label = rho_labels(jj);

            % Iterate through theta midpoints
            for kk = 1:length(theta_diff)
                % Check if display percent status
                if strcmp(percent_status, 'on')
                    % Initialize
                    theta_txt = theta_diff(kk);

                    % Format percentage text
                    precision_txt = sprintf('%i', percent_precision);
                    percent_txt = sprintf(['%.', precision_txt, 'f%%'], sub_pie(kk)*100);

                    % Convert from polar to cartesian
                    [x_txt, y_txt] = pol2cart(theta_txt, rho_txt);

                    % Display percentage text
                    text(x_txt, y_txt, percent_txt,...
                        'Color', 'w',...
                        'FontWeight', 'bold',...
                        'HorizontalAlignment', 'center');
                end

                % Only for outermost
                if ii == num_pie
                    % Convert from polar to cartesian
                    [x_label, y_label] = pol2cart(theta_txt, rho_label);

                    % Display pie labels
                    text(x_label, y_label, pie_labels{kk},...
                        'Color', 'k',...
                        'FontWeight', 'bold',...
                        'FontSize', label_fontsize,...
                        'HorizontalAlignment', 'center',...
                        'Interpreter', label_interpreter);
                end

            end
        end


    end
end

end