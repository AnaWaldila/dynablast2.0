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
        
        % =============================================================== %
        
        % Function to draw the 2 graphics
        function plotGraphic2(graphic_local, x_axes, y_axes1, y_axes2, ...
                x_label, y_label, legend1, legend2)

            hold(graphic_local,'on')
            plot(graphic_local, x_axes, y_axes1, 'color', [0 0 0], ...
                'LineWidth',0.5);
            plot(graphic_local, x_axes, y_axes2, ':', 'color', [0 0 0], ...
                'LineWidth',1);
            legend(graphic_local, strcat(leg, legend1), ...
                strcat(leg, legend2));
            xlabel(graphic_local, x_label);
            ylabel(graphic_local, y_label);
            hold(graphic_local,'off')

        end
        
        % =============================================================== %
        
        % Function to draw the 2 graphics
        function plotGraphic4(graphic_local, x_axes, y_axes1, y_axes2, ...
                y_axes3, y_axes4, x_label, y_label, ...
                legend1, legend2, legend3, legend4)

            hold(graphic_local,'on')

            plot(graphic_local, x_axes, y_axes1, 'color', [0 0 0], ...
                'LineWidth',0.5);
            plot(graphic_local, x_axes, y_axes2, ':', 'color', [0 0 0], ...
                'LineWidth',1);
            plot(graphic_local, x_axes, y_axes3, '--', 'color', [0 0 0], ...
                'LineWidth',1);
            plot(graphic_local, x_axes, y_axes4, '-.', 'color', [0 0 0], ...
                'LineWidth',1);

            legend(graphic_local, legend1, legend2, legend3, legend4);
            xlabel(graphic_local, x_label);
            ylabel(graphic_local, y_label);
            hold(graphic_local,'off')

        end
        
        % =============================================================== %
        
        % Function to draw the 3D graphic
        function plotGraphic3D(x_axes, y_axes, z_axes)

            % Plot Graphic
            
            %%hold(graphic_local,'on')
            surf(x_axes, y_axes, z_axes,'FaceAlpha',0.5);
            xlabel('W_T_N_T (kg)');
            ylabel('R (m)');
            zlabel('u_z / h')

            %%hold(graphic_local,'off')
            
        end 

    end
    
end