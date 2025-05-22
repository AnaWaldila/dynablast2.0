classdef Class_Stress

    % =================================================================== %
    % DESCRIPTION
    
    % This class calculate all results of laminated composite plates based 
    % on simple supported as a boundary condition. Moreover, the type of
    % analysis in that script is static.
    % References:
    % [1] AMABILI, M., BALASUBRAMANIAN, GARZIERA, R., ROYER-CARFAGNI, G. 
    % Blast Loads and Nonlinear Vibrations of Laminated Glass Plates in an
    % Enhanced Shear Deformation Theory. Composite Structures, 2020.
    % [2] AKAVCI, S. S. Analysis of Thick Laminated Composite Plates on an
    % Elastic Foundations with the use of Various Plate Theory. Mechanics
    % of Composite Materials, 2005.
    % [3] KAZANCI, Z. Nonlinear Transient Response of a Laminated Composite
    % Plate Under Time-Dependent Pulse. IEEE, 2009.
    % [4] Reddy, J. N. Mechanics of Laminated Composite Plates and Shells: 
    % Theory and Analysis, 2nd edition, CRC Press, Boca Raton, FL, USA, 2004.
    
    % =================================================================== %
    
    %% Public Properties
    properties (SetAccess = public, GetAccess = public)
        
        % Import Classes
        plate               Class_Plate
        layer               Class_Layer
        analysis            Class_Analysis
        pmt                 Class_Parameters
        material            Class_Material
        effort              Class_Effort
        bc                  Class_BoundaryConditions
        dynamic_analysis    Class_SolutionDynamic   
        result              Class_Result
        
        % Create new parameters
        N           = 20;               % Number of intervals
        sol_stress  = [];               % Numerical Stress in plate
        
    end
    
    %% Public Methods
    methods
        
        function this = Class_Stress(plate, layer, analysis, pmt, ...
                material, effort, bc, dynamic_analysis, result)
            
            if (nargin > 0)
                
                disp("Structure                          - PLATE");

                this.analysis       = analysis;
                dynamic             = this.analysis.dynamic;

                switch dynamic
                    case 0
                        this = this.Static_Stress_Plate(plate, layer, ...
                            analysis, pmt, material, effort, bc, result);
                    case 1
                        this = this.Dynamic_Stress_Plate(plate, analysis, ...
                            pmt, material, effort, bc, ...
                            dynamic_analysis, result);
                end

            end
            
        end
        
    end
    
    %% Public Methods for Plate Functions
    methods
       
        % Function to calculate, numerically, the stress in all layers
        % Graphics to can plot: stress (bending or shear) x z / h
        function this = Static_Stress_Plate(this, plate, layer, ...
                analysis, pmt, material, effort, bc, result)
            
            disp("Start - Class_Stress()             - Stress()");
            
            % Symbolic General Parameters
            syms x y z m n
            syms u0(x,y,t) v0(x,y,t) w0(x,y,t) tx(x,y,t) ty(x,y,t)
            
            % Import parameters from Class_Plate
            this.plate          = plate;
            a                   = this.plate.a;
            xi                  = this.plate.xi;
            yi                  = this.plate.yi;
            m0                  = this.plate.m0;
            n0                  = this.plate.n0;
            q0                  = this.plate.q0;
            
            % Import parameters from Class_Layer
            this.layer          = layer;
            num_layer           = this.layer.num_layer;
            
            % Import parameters from Class_Analysis
            this.analysis       = analysis;
            theory              = this.analysis.theory;
            
            % Import parameters from Class_Parameters
            this.pmt            = pmt;
            coeff_fourier       = this.pmt.coeff_fourier;
            
            % Import paramters from Class_BoundaryConditions
            this.bc             = bc;
            d0                  = this.bc.d0;
            
            % Import parameters from Class_Material
            this.material       = material;
            h                   = this.material.h;
            zi                  = this.material.zi;
            
            % Import parameters from Class_Effort
            this.effort         = effort;
            stress              = this.effort.stress;
            
            % Import parameters from Class_Result
            this.result         = result;
            mn_coeff            = this.result.fd;
                      
            % This part is to verificate if the analysis is CLPT. If it is
            % true, the input and output data are differents than FSPT and
            % TSPT analysis. 
            if (theory == 1 || theory == 4)
                input_data      = formula([u0, v0, w0]);
            else
                input_data      = formula([u0, v0, w0, tx, ty]);
            end
            
            sxx              = zeros(this.N, num_layer);
            syy              = zeros(this.N, num_layer);
            sxy              = zeros(this.N, num_layer);
            syz              = zeros(this.N, num_layer);
            sxz              = zeros(this.N, num_layer);
            height           = zeros(this.N, num_layer);
            
            % Verificating output data
            % Calculating stress
            for k = 1 : num_layer

                start        = linspace(zi(k,1), zi(k+1,1), this.N);

                % Looping to calculate the behavior of stress in
                % each layer using N intervals

                for i = 1 : this.N

                    sxx(i,k) = subs(subs(subs(stress(1,1,k), ...
                        input_data, transpose(d0)), ...
                        coeff_fourier, transpose(mn_coeff)), ...
                        [x y m n z], [xi yi m0 n0 start(1,i)]);

                    syy(i,k)    = subs(subs(subs(stress(2,1,k), ...
                        input_data, transpose(d0)), ...
                        coeff_fourier, transpose(mn_coeff)), ...
                        [x y m n z], [xi yi m0 n0 start(1,i)]);

                    sxy(i,k)    = subs(subs(subs(stress(3,1,k), ...
                        input_data, transpose(d0)), ...
                        coeff_fourier, transpose(mn_coeff)), ...
                        [x y m n z], [xi yi m0 n0 start(1,i)]);

                    syz(i,k)    = subs(subs(subs(stress(4,1,k), ...
                        input_data, transpose(d0)), ...
                        coeff_fourier, transpose(mn_coeff)), ...
                        [x y m n z], [xi yi m0 n0 start(1,i)]);

                    sxz(i,k)    = subs(subs(subs(stress(5,1,k), ...
                        input_data, transpose(d0)), ...
                        coeff_fourier, transpose(mn_coeff)), ...
                        [x y m n z], [xi yi m0 n0 start(1,i)]);

                    height(i,k) = start(1,i);

                end

            end

            clear start step
                    
            
            % Creating matrix to plot
            stress_xx        = [];
            stress_yy        = [];
            stress_xy        = [];
            stress_yz        = [];
            stress_xz        = [];
            total_height     = [];
                        
            % Creating a new vector with only one column
            for i = 1 : num_layer
                
                stress_xx           = cat(1, stress_xx, sxx(:,i));
                stress_yy           = cat(1, stress_yy, syy(:,i));
                stress_xy           = cat(1, stress_xy, sxy(:,i));
                stress_yz           = cat(1, stress_yz, syz(:,i));
                stress_xz           = cat(1, stress_xz, sxz(:,i));
                total_height        = cat(1, total_height, height(:,i));
                
            end
            
            stress_xx               = stress_xx * (h/a)^2 / q0;
            stress_yy               = stress_yy * (h/a)^2 / q0;
            stress_xy               = stress_xy * (h/a)^2 / q0;
            stress_yz               = stress_yz * (h/a) / q0;
            stress_xz               = stress_xz * (h/a) / q0;
            total_height            = total_height / h;
            
            % Final Vector
            this.sol_stress         = double(cat(2, total_height, ...
                    stress_xx, stress_yy, stress_xy, stress_yz, stress_xz));
                       
            disp("End   - Class_Stress()             - Stress()");
            disp(" ");
             
        end
        
        % =============================================================== %
        % Function to calculate, numerically, the stress in all layers
        % Graphics to can plot: stress (bending or shear) x z / h
        function this = Dynamic_Stress_Plate(this, plate, analysis, ...
                pmt, material, effort, bc, dynamic_analysis, result)
            
            disp("Start - Class_Stress()             - Stress()");
            
            % Symbolic General Parameters
            syms x y z m n
            syms u0(x,y,t) v0(x,y,t) w0(x,y,t) tx(x,y,t) ty(x,y,t)
            
            % Creating the waitbar
            bar                     = waitbar(0.1, ...
                'Calculating the Stress Equation');

            % Import parameters from Class_Plate
            this.plate          = plate;
            xi                  = this.plate.xi;
            yi                  = this.plate.yi;
            m0                  = this.plate.m0;
            n0                  = this.plate.n0;
                        
            % Import parameters from Class_Analysis
            this.analysis       = analysis;
            theory              = this.analysis.theory;
            ss_analysis             = this.analysis.ss_analysis;
            
            % Import parameters from Class_Parameters
            this.pmt            = pmt;
            coeff_fourier       = this.pmt.coeff_fourier;
            
            % Import paramters from Class_BoundaryConditions
            this.bc             = bc;
            d0                  = this.bc.d0;
            
            % Import parameters from Class_Material
            this.material       = material;
            h                   = this.material.h;
            
            % Import parameters from Class_Effort
            this.effort         = effort;
            stress              = this.effort.stress;

            % Import parameters from Class_Result
            this.result             = result;
            fd                      = this.result.fd;
            
            % Import parameters from Class_SolutionDynamic
            this.dynamic_analysis   = dynamic_analysis;
            mn_coeff                = this.dynamic_analysis.mn_coeff;

            % This part is to verificate if the analysis is CLPT. If it is
            % true, the input and output data are differents than FSPT and
            % TSPT analysis.
            if (theory == 1 || theory == 4)
                input_data          = [u0; v0; w0];
                output_fourier      = [mn_coeff(:,2), mn_coeff(:,4), ...
                                       mn_coeff(:,6)];
            else
                input_data          = [u0; v0; w0; tx; ty];
                output_fourier      = [mn_coeff(:,2), mn_coeff(:,4), ...
                                       mn_coeff(:,6), mn_coeff(:,8), ...
                                       mn_coeff(:,10)];
            end
            
            % Creating matrix to plot
            total_lenght            = length(mn_coeff);

            stress_equation         = subs(subs(stress, input_data, d0), ...
                    [z, x, y, m, n], [h/2, xi, yi, m0, n0]);

            sxx                     = zeros(total_lenght, 1);
            syy                     = zeros(total_lenght, 1);
            sxy                     = zeros(total_lenght, 1);
            syz                     = zeros(total_lenght, 1);
            sxz                     = zeros(total_lenght, 1);
            
            if ss_analysis == 1

                % 90 = Waitbar before the loop is in 10%
                percent             = 0.9 / total_lenght;

                for i = 1 : total_lenght

                    waitbar(0.1 + i * percent, bar, 'Calculating Stress');

                    sxx(i,1)        = subs(stress_equation(1,1), ...
                        coeff_fourier, output_fourier(i,:));

                    syy(i,1)        = subs(stress_equation(2,1), ...
                        coeff_fourier, output_fourier(i,:));

                    sxy(i,1)        = subs(stress_equation(3,1), ...
                        coeff_fourier, output_fourier(i,:));

                    syz(i,1)        = subs(stress_equation(4,1), ...
                        coeff_fourier, output_fourier(i,:));

                    sxz(i,1)        = subs(stress_equation(5,1), ...
                        coeff_fourier, output_fourier(i,:));

                end

            else

                waitbar(0.9, bar, 'No Stress to Calculate');
                pause(2);

            end

            % Final Vector
            this.sol_stress     = double(cat(2, fd(:,1), ...
                    sxx, syy, sxy, syz, sxz));
               
            waitbar(1, bar, ...
                        'Ending of the Stress Calculation');

            close(bar);
        
            disp("End   - Class_Stress()             - Stress()");
            disp(" ");
             
        end

    end
    
end