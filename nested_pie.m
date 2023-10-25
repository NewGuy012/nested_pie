function varargout = nested_pie(C, varargin)
%nested_pie Create a nested pie chart.
%
% Syntax:
%   nested_pie(C)
%   nested_pie(C, Name, Value, ...)
%   h = nested_pie(_)
%
% Documentation:
%   Please refer to the MathWorks File Exchange or GitHub page for the
%   detailed documentation and examples.

% Pie properties
num_pie = length(C);
num_outmost = length(C{end});
label_text = cell(num_outmost, 1);

% Number of wedges
num_wedges = cellfun(@(C) length(C), C, 'UniformOutput', false);
num_wedges = cell2mat(num_wedges);
max_wedges = max(num_wedges);

% Default labels
for ii = 1:num_outmost
    label_text{ii} = sprintf('Label %i', ii);
end

% Pre-allocation
wedge_colors = cell(num_pie, 1);
percent_status = cell(num_pie, 1);

% Default arguments
rho_lower = 0.2;
edge_color = 'k';
line_width = 2;
line_style = '-';
wedge_colors(:) = {lines(max_wedges)};
percent_status(:) = {'on'};
percent_precision = 1;
percent_fontcolor = 'w';
percent_fontsize = 10;
percent_fontweight = 'bold';
percent_edgecolor = 'none';
percent_backgroundcolor = 'none';
fill_transparency = 1;
label_fontsize = 10;
label_fontcolor = 'k';
label_fontweight = 'bold';
label_edgecolor = 'none';
label_backgroundcolor = 'none';
label_rotation = 0;
label_offset = 0;
label_interpreter = 'none';
interval_res = 0.01;
axes_handle = gobjects;
ignore_percent = 0;
background_color = 'w';
legend_order = [];

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
            case 'percentprecision'
                percent_precision = value_arguments{ii};
            case 'percentfontcolor'
                percent_fontcolor = value_arguments{ii};
            case 'percentfontsize'
                percent_fontsize = value_arguments{ii};
            case 'percentfontweight'
                percent_fontweight = value_arguments{ii};
            case 'percentedgecolor'
                percent_edgecolor = value_arguments{ii};
            case 'percentbackgroundcolor'
                percent_backgroundcolor = value_arguments{ii};
            case 'labeltext'
                label_text = value_arguments{ii};
            case 'labelfontsize'
                label_fontsize = value_arguments{ii};
            case 'labelfontcolor'
                label_fontcolor = value_arguments{ii};
            case 'labelfontweight'
                label_fontweight = value_arguments{ii};
            case 'labeledgecolor'
                label_edgecolor = value_arguments{ii};
            case 'labelbackgroundcolor'
                label_backgroundcolor = value_arguments{ii};
            case 'labelrotation'
                label_rotation = value_arguments{ii};
            case 'labeloffset'
                label_offset = value_arguments{ii};
            case 'labelinterpreter'
                label_interpreter = value_arguments{ii};
            case 'filltransparency'
                fill_transparency = value_arguments{ii};
            case 'axeshandle'
                axes_handle = value_arguments{ii};
            case 'ignorepercent'
                ignore_percent = value_arguments{ii};
            case 'backgroundcolor'
                background_color = value_arguments{ii};
            case 'legendorder'
                legend_order = value_arguments{ii};
            otherwise
                error('Error: Please enter in a valid name-value pair.');
        end
    end

end

% Check if empty
if isempty(properties(axes_handle))
    % Figure and axes handles
    fig = figure;
    cla reset;
    ax = gca;
else
    % Figure and axes handles
    ax = axes_handle;
    fig = axes_handle.Parent;
end

% Check for output arguments
if nargout > 1
    error('Error: Too many output arguments assigned.');
end
varargout{1} = fig;

% Axes properties
if isprop(fig, "Color")
    fig.Color = background_color;
end
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

% Error checking
if rho_lower < 0 || rho_lower > 1
    error('Error: The starting radius must be a value between [0, 1].');
end

if length(label_text) ~= num_outmost
    error('Error: The label text must equal the length of the wedges in the outer most layer.');
end

% Initialize rho
rho_upper = 1;
rho_range = rho_upper - rho_lower;
rho_interval = rho_range/num_pie;
rho = rho_lower:rho_interval:rho_upper;
tol = eps(10);

% Iterate through number of nested pies
for ii = 1:num_pie
    % Initialize
    sub_pie = C{ii}; % Convert from cell to numerical array
    num_wedge = num_wedges(ii);
    wedge_color = wedge_colors{ii};
    bEssentiallyEqual = false;

    % Compare taking into account floating-point number
    if abs(1 - sum(sub_pie)) <= tol
        bEssentiallyEqual = true;
    end

    % Check if data does not sum to one
    if ~bEssentiallyEqual
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
        p = patch(ax, x_patch, y_patch, wedge_color(jj, :),...
            'LineStyle', line_style,...
            'EdgeColor', edge_color,...
            'LineWidth', line_width,...
            'FaceAlpha', fill_transparency);
        p.Tag = sprintf('Layer %i, Wedge %i', ii, jj);
    end

    % Find midpoint of theta and rho
    theta_diff = diff(theta)/2;
    theta_diff = theta(1:end-1) + theta_diff;

    rho_wedge = rho(ii:ii+1);
    rho_delta = diff(rho_wedge)/2;
    rho_diff = rho_wedge(1:end-1) + rho_delta;
    rho_labels = rho_wedge(end) + rho_delta;

    % Iterate through rho midpoints
    for jj = 1:length(rho_diff)
        % Initialize
        rho_txt = rho_diff(jj);
        rho_label = rho_labels(jj);

        % Iterate through theta midpoints
        for kk = 1:length(theta_diff)
            % Initialize
            theta_txt = theta_diff(kk);
            sub_percent = sub_pie(kk)*100;

            % Check if display percent status
            if strcmp(percent_status{ii}, 'on')
                % Check if non-trivial amount
                if sub_percent > ignore_percent
                    % Format percentage text
                    precision_txt = sprintf('%i', percent_precision);
                    percent_txt = sprintf(['%.', precision_txt, 'f%%'], sub_percent);

                    % Convert from polar to cartesian
                    [x_txt, y_txt] = pol2cart(theta_txt, rho_txt);

                    % Display percentage text
                    text(x_txt, y_txt, percent_txt,...
                        'Color', percent_fontcolor,...
                        'FontWeight', percent_fontweight,...
                        'FontSize', percent_fontsize,...
                        'EdgeColor', percent_edgecolor,...
                        'BackgroundColor', percent_backgroundcolor,...
                        'HorizontalAlignment', 'center');
                end
            end

            % Only for outermost
            if ii == num_pie
                % Check if non-trivial amount
                if sub_percent > ignore_percent
                    % Convert from polar to cartesian
                    [x_label, y_label] = pol2cart(theta_txt, rho_label+label_offset);

                    [horz_align, vert_align] = quadrant_position(theta_txt);

                    % Display pie labels
                    text(ax, x_label, y_label, label_text{kk},...
                        'Color', label_fontcolor,...
                        'FontWeight', label_fontweight,...
                        'FontSize', label_fontsize,...
                        'EdgeColor', label_edgecolor,...
                        'BackgroundColor', label_backgroundcolor,...
                        'Rotation', label_rotation,...
                        'HorizontalAlignment', horz_align,...
                        'VerticalAlignment', vert_align,...
                        'Interpreter', label_interpreter);
                end
            end
        end
    end
end

% Check if legend order is valid
if ~isempty(legend_order) &&...
        isnumeric(legend_order) &&...
        length(legend_order) == num_pie &&...
        length(unique(legend_order)) == num_pie &&...
        max(legend_order) == num_pie

    % Get axes handle
    f = fig;
    h = f.Children;
    a = findobj(h, 'Type', 'axes');

    % Iterate in backwards order
    for ii = length(legend_order):-1:1
        % Initialize
        order = legend_order(ii);

        % Compose layer number
        tag_str = compose("Layer %i", order);

        % Patch handles
        p = a.Children;

        % Find relevant pie layer
        h = findobj(p, '-regexp', 'Tag', tag_str);

        % Stack from bottom
        uistack(h, "bottom");
    end
else
    error('Error: Please enter in valid number of pie layers to rearrange legend order.');
end

    function [horz_align, vert_align] = quadrant_position(theta_point)
        % Find out which quadrant the point is in
        if theta_point == 0
            quadrant = 0;
        elseif theta_point == pi/2
            quadrant = 1.5;
        elseif theta_point == pi
            quadrant = 2.5;
        elseif theta_point == 3*pi/2
            quadrant = 3.5;
        elseif theta_point == 2*pi
            quadrant = 0;
        elseif theta_point > 0 && theta_point < pi/2
            quadrant = 1;
        elseif theta_point > pi/2 && theta_point < pi
            quadrant = 2;
        elseif theta_point > pi && theta_point < 3*pi/2
            quadrant = 3;
        elseif theta_point > 3*pi/2 && theta_point < 2*pi
            quadrant = 4;
        end

        % Adjust label alignment depending on quadrant
        switch quadrant
            case 0
                horz_align = 'left';
                vert_align = 'middle';
            case 1
                horz_align = 'left';
                vert_align = 'bottom';
            case 1.5
                horz_align = 'center';
                vert_align = 'bottom';
            case 2
                horz_align = 'right';
                vert_align = 'bottom';
            case 2.5
                horz_align = 'right';
                vert_align = 'middle';
            case 3
                horz_align = 'right';
                vert_align = 'top';
            case 3.5
                horz_align = 'center';
                vert_align = 'top';
            case 4
                horz_align = 'left';
                vert_align = 'top';
        end
    end

end