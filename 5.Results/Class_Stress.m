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
        result              Class_Result
        
        % Create new parameters
        
        N           = 20;               % Number of intervals
        sol_stress  = [];               % Numerical Stress in plate
        
    end
    
    %% Public Methods
    methods
        
        function this = Class_Stress(plate, layer, analysis, pmt, ...
                material, effort, bc, result)
            
            if (nargin > 0)
                
                % Functions
                
                this = this.Stress(plate, layer, analysis, pmt, ...
                material, effort, bc, result);
                
            end
            
        end
        
    end
    
    %% Public Methods for Functions
    methods
       
        % Function to calculate, numerically, the stress in all layers
        % Graphics to can plot: stress (bending or shear) x z / h
        function this = Stress(this, plate, layer, analysis, pmt, ...
                material, effort, bc, result)
            
            disp("Start - Class_Stress()             - Stress()");
            
            % Symbolic General Parameters
            syms x y z t m n
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
            dynamic             = this.analysis.dynamic;
            
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
            mn_coeff            = this.result.final_displacement;
                      
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
            switch dynamic
                
                case 0
                    
                    % Calculating stress
                    for k = 1 : num_layer
                        
                        start           = linspace(zi(k,1), zi(k+1,1), ...
                                          this.N);
                        
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
                    
                case 1
                    
            end
            
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
        
    end
      
end