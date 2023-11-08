classdef Class_Graphic
   
    % Description
    %
    % This class plot all graphics about laminated composite plates.
    % Version beta 1.0
    %
    
    %% Public Properties
    properties (SetAccess = public, GetAccess = public)
       
        plate               Class_Plate         % Calling Class_Plate
        layer               Class_Layer         % Calling Class_Layer
        result              Class_Result        % Calling Class_Result
        stress              Class_Stress        % Calling Class_Stress
                
    end
    
    %% Public Methods
    methods
       
        function this = Class_Graphic(result, stress)
            
            if (nargin > 0)
                
                % Functions
                this = this.Graph(result, stress);
                
            end
            
        end
        
    end
    
    %% Public Methods for Functions
    methods
       
        function this = Graph(this, result, stress)
        
            % Import parameters from other classes
            this.result                 = result;
            final_displacement          = this.result.final_displacement;
            
            % Import parameters from Class_Stress
            this.stress                 = stress;
            sol_stress                  = this.stress.sol_stress;
            
            % Interaction with the user 
            disp(" ");
            disp(" Types of Graphics");
            disp(" ");
            disp("1: \sigma_xx x z/h");
            disp("2: \sigma_yy x z/h");
            disp("3: \sigma_xy x z/h");
            disp("4: \sigma_yz x z/h");
            disp("5: \sigma_xz x z/h");
            disp("6: w0 x t");
            disp("Press any key to finish")
            disp(" ");
            number = input("Enter with number: ");
            
            while (number == 1 || number == 2 || number == 3 ...
                    || number == 4 || number == 5 || number == 6)
                
                if number == 1
                    
                    hold on
                    
                    plot(sol_stress(:,2), sol_stress(:,1));
                    xlabel('\sigma_x_x');
                    ylabel('z/h');
                    
                    hold off
                    
                elseif number == 2
                    
                    hold on
                    
                    plot(sol_stress(:,3), sol_stress(:,1));
                    xlabel('\sigma_y_y');
                    ylabel('z/h');
                    
                    hold off
                    
                elseif number == 3
                    
                    hold on
                    
                    plot(sol_stress(:,4), sol_stress(:,1));
                    xlabel('\sigma_x_y');
                    ylabel('z/h');
                    
                    hold off
                    
                elseif number == 4
                    
                    hold on
                    
                    plot(sol_stress(:,5), sol_stress(:,1));
                    xlabel('\sigma_y_z');
                    ylabel('z/h');
                    
                    hold off
                    
                elseif number == 5
                    
                    hold on
                    
                    plot(sol_stress(:,6), sol_stress(:,1));
                    xlabel('\sigma_x_z');
                    ylabel('z/h');
                    
                    hold off
                    
                elseif number == 6
                    
                    hold on
                    
                    plot(final_displacement(:,1), final_displacement(:,4));
                    xlabel('t');
                    ylabel('w_0/h');
                    
                    hold off
                    
                elseif not(isnumeric(number))
                    
                    disp("End to plot Graphics");
                    break
                    
                end
                
                % Interaction with the user
                disp(" ");
                disp(" Types of Graphics");
                disp(" ");
                disp("1: \sigma_xx x z/h");
                disp("2: \sigma_yy x z/h");
                disp("3: \sigma_xy x z/h");
                disp("4: \sigma_yz x z/h");
                disp("5: \sigma_xz x z/h");
                disp("6: w0/h x t");
                disp("Press another number key to finish")
                disp(" ");
                number = input("Enter with number: ");
                
            end
            
        end
        
    end
    
end