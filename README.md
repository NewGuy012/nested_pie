[![View pie_nested on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/122167-pie_nested)

# pie_nested
Create a nested pie chart.

## Syntax:
**pie_nested(C)**

**pie_nested(C, Name, Value, ...)**

**h = pie_nested(_)**

## Input Arguments:
*(Required)*

- **C** - The data points used to plot the nested pie chart. It is a nested cell array of numerical values, starting with the inner most pie chart.
          [nested cell]

## Output Arguments:
*(Optional)*
- **h**                - Figure handle of spider plot.
                         [figure object]

## Name-Value Pair Arguments:
*(Optional)*

- **RhoLower**       -  Used to specify the starting radius of the inner most nested pie chart.
                        [0.2 (default) | scalar value between (0, 1)]

- **EdgeColor**       - Used to specify the edge color of the wedges.
                        [black (default) | RGB triplet | hexadecimal color code]

- **LineWidth**       - Used to specify the edge line width of the wedges.
                        [2 (default) | scalar value]

- **LineStyle**       - Used to specify edge line style of the wedges.
                        ['-' (default) | '--' | ':' | '-.' | 'none']

- **WedgeColors**     - Used to specify the colors of the individual wedges.
                        [lines colormap (default) | cell array of RGB triplet]

- **PercentStatus**   - Used to specify whether or not to display percentage text.
                        ['on' (default) | 'off']

- **PercentPrecision**- Used to specify the percentage text decimal places.
                        [2 (default) | integer value]

- **LabelFontSize**   - Used to specify the font size of the outer most labels.
                        [cell array of chars | string array]

- **FillTransparency**- Used to specify the fill transparency of the wedges.
                        [scalar value between (0, 1)]

- **LabelInterpreter**- Used to specify the interpreter for the labels.
                        ['none' | 'tex' | 'latex']

## Examples:
### Example 1: Nested pie chart
```matlab
% Initialize data points
inner_pie = [0.1, 0.15, 0.2, 0.05, 0.3, 0.2];
outer_pie = [0.25, 0.25, 0.5];
C = {...
    inner_pie,... % Inner pie must come first!
    outer_pie};

% Spider plot
pie_nested(C);

% Title
title('Nested Pie Chart');

% Legend properties
legend_str = cell(length(inner_pie), 1);
for ii = 1:length(legend_str)
    inner_value = inner_pie(ii);
    legend_str{ii} = sprintf('Inner Pie #%i: %.1f%%', ii, inner_value*100);
end
lg =legend(legend_str, 'Location', 'southoutside');
lg.Title.String = 'Inner Pie';
```
<p align="center">
  <img src="screenshot/example1.PNG">
</p>


## Author:
Moses Yoo, (juyoung.m.yoo at gmail dot com)

## Special Thanks:
Special thanks to the following people for their feature recommendations and bug finds.

[![View pie_nested on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/122167-pie_nested)