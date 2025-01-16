function fig = nested_pie(C, options)
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
arguments
    C
    options.RhoLower = 0.2;
    options.ThetaInitial = 0;
    options.ThetaDirection = 'counterclockwise';
    options.EdgeColor = 'k';
    options.LineWidth = 2;
    options.LineStyle = '-';
    options.WedgeColors
    options.PercentStatus
    options.PercentPrecision = 1;
    options.PercentFontColor = 'w';
    options.PercentFontSize = 10;
    options.PercentFontWeight = 'bold';
    options.PercentEdgeColor = 'none';
    options.PercentBackgroundColor = 'none';
    options.LayerText = []
    options.LabelText string
    options.LabelToggle = 'on';
    options.LabelFontSize = 10;
    options.LabelFontColor = 'k';
    options.LabelFontWeight = 'bold';
    options.LabelEdgeColor = 'none';
    options.LabelBackgroundColor = 'none';
    options.LabelRotation = 0;
    options.LabelOffset = 0;
    options.LabelInterpreter = 'none';
    options.FillTransparency = 1;
    options.AxesHandle
    options.IgnorePercent = 0;
    options.BackgroundColor = 'w';
    options.LegendOrder = [];
    options.AxesZoom = 1.2;
end

% Pie properties
num_pie = numel(C);
num_outmost = numel(C{end});

% Number of wedges
num_wedges = cellfun(@numel, C);

% Default arguments
interval_res = 0.01;

% Check if default or user specified
if isfield(options, "WedgeColors")
    wedge_colors = options.WedgeColors;
else
    wedge_colors = repmat({lines(max(num_wedges(:)))}, num_pie,1);
end

if isfield(options, "PercentStatus")
    percent_status = options.PercentStatus;
else
    percent_status = repmat(matlab.lang.OnOffSwitchState.on, num_pie, 1);
end

if isfield(options, "LayerText")
    layer_txt = options.LayerText;
else
    layer_txt = [];
end

if isfield(options, "LabelText")
    label_text = options.LabelText;
elseif options.LabelToggle == "on"
    label_text = compose("Label %i", 1:num_outmost);
else
    label_text = [];
end

if isfield(options, "AxesHandle")
    ax = options.AxesHandle;
    fig = ax.Parent;
else
    fig = figure;
    ax = gca;
end

% Axes properties
if isprop(fig, "Color")
    fig.Color = options.BackgroundColor;
end
ax.Color = options.BackgroundColor;

% Axis properties
hold(ax, 'on');
axis(ax, 'square');
axis(ax, [-1, 1, -1, 1] * options.AxesZoom);

% Axis properties
ax.XTickLabel = [];
ax.YTickLabel = [];
ax.XColor = 'none';
ax.YColor = 'none';

% Error checking
if options.RhoLower < 0 ||...
        options.RhoLower > 1
    error('Error: The starting radius must be a value between [0, 1].');
end

if ~isempty(label_text) &&...
        numel(label_text) ~= num_outmost
    error('Error: The label text must equal the length of the wedges in the outer most layer.');
end

% Initialize rho
rho_upper = 1;
rho_range = rho_upper - options.RhoLower;
rho_interval = rho_range/num_pie;
rho = options.RhoLower:rho_interval:rho_upper;
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
    theta = theta + options.ThetaInitial;

    % Check for reverse direction
    if options.ThetaDirection == "clockwise"
        theta = theta * -1;
        theta = theta + 2*pi;
    end

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
            'LineStyle', options.LineStyle,...
            'EdgeColor', options.EdgeColor,...
            'LineWidth', options.LineWidth,...
            'FaceAlpha', options.FillTransparency);
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

            % Check if non-trivial amount
            if sub_percent > options.IgnorePercent
                % Convert from polar to cartesian
                [x_txt, y_txt] = pol2cart(theta_txt, rho_txt);

                % Check if display percent status
                if percent_status(ii) == "on"
                    % Format percentage text
                    precision_txt = sprintf('%i', options.PercentPrecision);
                    percent_txt = sprintf(['%.', precision_txt, 'f%%'], sub_percent);

                    % Display percentage text
                    text(x_txt, y_txt, percent_txt,...
                        'Color', options.PercentFontColor,...
                        'FontWeight', options.PercentFontWeight,...
                        'FontSize', options.PercentFontSize,...
                        'EdgeColor', options.PercentEdgeColor,...
                        'BackgroundColor', options.PercentBackgroundColor,...
                        'HorizontalAlignment', 'center');

                % Check if not empty
                elseif ~isempty(layer_txt)
                    % Current text
                    current_layer = layer_txt{ii};
                    current_txt = current_layer{kk};

                    % Display percentage text
                    text(x_txt, y_txt, current_txt,...
                        'Color', options.PercentFontColor,...
                        'FontWeight', options.PercentFontWeight,...
                        'FontSize', options.PercentFontSize,...
                        'EdgeColor', options.PercentEdgeColor,...
                        'BackgroundColor', options.PercentBackgroundColor,...
                        'HorizontalAlignment', 'center');
                end

                % Check if outermost pie layer
                if ii == num_pie &&...
                        ~isempty(label_text)
                    % Convert from polar to cartesian
                    [x_label, y_label] = pol2cart(theta_txt,...
                        rho_label + options.LabelOffset);

                    [horz_align, vert_align] = quadrant_position(theta_txt);

                    % Display pie labels
                    text(ax, x_label, y_label, label_text(kk),...
                        'Color', options.LabelFontColor,...
                        'FontWeight', options.LabelFontWeight,...
                        'FontSize', options.LabelFontSize,...
                        'EdgeColor', options.LabelEdgeColor,...
                        'BackgroundColor', options.LabelBackgroundColor,...
                        'Rotation', options.LabelRotation,...
                        'HorizontalAlignment', horz_align,...
                        'VerticalAlignment', vert_align,...
                        'Interpreter', options.LabelInterpreter);
                end
            end
        end
    end
end

% Check if legend order is valid
if ~isempty(options.LegendOrder) &&...
        isnumeric(options.LegendOrder) &&...
        length(options.LegendOrder) == num_pie &&...
        length(unique(options.LegendOrder)) == num_pie &&...
        max(options.LegendOrder) == num_pie

    % Get axes handle
    f = fig;
    h = f.Children;
    a = findobj(h, 'Type', 'axes');

    % Iterate in backwards order
    for ii = length(options.LegendOrder):-1:1
        % Initialize
        order = options.LegendOrder(ii);

        % Compose layer number
        tag_str = compose("Layer %i", order);

        % Patch handles
        p = a.Children;

        % Find relevant pie layer
        h = findobj(p, '-regexp', 'Tag', tag_str);

        % Stack from bottom
        uistack(h, "bottom");
    end

elseif ~isempty(options.LegendOrder)
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
