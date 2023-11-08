classdef Class_Draw
    
    % This class is only for to draw all layers in software and all 
    % graphics
    
    %% Static Methods
    methods (Static)
        
        % Function to draw the graphic
        function plotGraphic(graphic_local, x_axes, y_axes, x_label, y_label)
            % Plot Graphic
            hold(graphic_local,'on');
            plot(graphic_local, x_axes, y_axes, 'color', [0 0 0], ...
                'LineWidth',0.5);
            xlabel(graphic_local, x_label);
            ylabel(graphic_local, y_label);
            hold(graphic_local,'off');
            
        end
        
    end
end