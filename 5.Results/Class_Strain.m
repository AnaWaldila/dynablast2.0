classdef Class_Strain

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
        blast               Class_Blast
        effort              Class_Effort
        bc                  Class_BoundaryConditions
        result              Class_Result
        
        % Create new parameters
        
        N           = 20;               % Number of intervals
        sol_strain  = [];               % Numerical strain in plate
        
    end
    
    %% Public Methods
    methods
        
        function this = Class_Strain(plate, layer, analysis, pmt, ...
                bc, blast, effort, result)
            
            if (nargin > 0)
                
                % Functions
                
                this = this.Strain(plate, layer, analysis, pmt, ...
                blast, effort, bc, result);
                
            end
            
        end
        
    end
    
    %% Public Methods for Functions
    methods
       
        % Function to calculate, numerically, the strain in all layers
        % Graphics to can plot: strain (bending or shear) x z / h
        function this = Strain(this, plate, layer, analysis, pmt, ...
                blast, effort, bc, result)
            
            disp("Start - Class_strain()             - strain()");
            
            % Symbolic General Parameters
            syms x y z t m n
            syms u0(x,y,t) v0(x,y,t) w0(x,y,t) tx(x,y,t) ty(x,y,t)
            
            % Import parameters from Class_Plate
            this.plate          = plate;
            a                   = this.plate.a;
            xi                  = this.plate.xi;
            yi                  = this.plate.yi;
            
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
            
            % Import parameters from Class_Blast
            this.blast          = blast;
            pmax                = this.blast.pmax;
            
            % Import paramters from Class_BoundaryConditions
            this.bc             = bc;
            d0                  = this.bc.d0;
            
            % Import parameters from Class_Effort
            this.effort         = effort;
            h                   = this.effort.h;
            strain              = this.effort.strain;
            zi                  = this.effort.zi;
            
            % Import parameters from Class_Result
            this.result         = result;
            final_displacement  = this.result.final_displacement * h;
            max_displacement    = this.result.max_disp * h;
                      
            % This part is to verificate if the analysis is CLPT. If it is
            % true, the input and output data are differents than FSPT and
            % TSPT analysis. 
            if (theory == 1 || theory == 4)
                input_data      = [u0, v0, w0];
            else
                input_data      = [u0, v0, w0, tx, ty];
            end
            
            % Verificating output data
            switch dynamic
                case 0
                    
                    % Import parameters from Class_Plate
                    m0                   = this.plate.m0;
                    n0                   = this.plate.n0;
                    
                    % Output Data
                    output_data          = final_displacement;
                    
                    if (theory == 1 || theory == 4)
                        output_fourier  = [0 0 0];
                    else
                        output_fourier  = [0 0 0 0 0];
                    end
                    
                case 1
                    
                    % Import paramters from Class_BoundaryConditions
                    output_data          = transpose(d0);
                    output_fourier       = max_displacement;
                    
                    % Estabilishing values for m and n paramters
                    m0                   = 1;
                    n0                   = 1;
                    
            end
            
            % Creating matrix to plot
            strain_xx        = [];
            strain_yy        = [];
            strain_xy        = [];
            strain_yz        = [];
            strain_xz        = [];
            total_height     = [];
                        
            exx              = zeros(this.N, num_layer);
            eyy              = zeros(this.N, num_layer);
            exy              = zeros(this.N, num_layer);
            eyz              = zeros(this.N, num_layer);
            exz              = zeros(this.N, num_layer);
            height           = zeros(this.N, num_layer);
            
            % Calculating strain
            for k = 1 : num_layer
                              
                start   = zi(k,1);
                step    = (zi(k,1) - zi(k+1,1)) / this.N;
                                
                % Looping to calculate the behavior of strain in each layer
                % using N intervals
                
                for i = 1 : this.N
                    
                    exx(i,k)       = subs(subs(subs(...
                        strain(1,1), input_data, output_data), ...
                        [z, x, y, m, n], [start, xi, yi, m0, n0]), ...
                        coeff_fourier, output_fourier);
                                      
                    eyy(i,k)       = subs(subs(subs(...
                        strain(2,1), input_data, output_data), ...
                        [z, x, y, m, n], [start, xi, yi, m0, n0]), ...
                        coeff_fourier, output_fourier);
                    
                    exy(i,k)       = subs(subs(subs(...
                        strain(3,1), input_data, output_data), ...
                        [z, x, y, m, n], [start, xi, yi, m0, n0]), ...
                        coeff_fourier, output_fourier);
                    
                    eyz(i,k)       = subs(subs(subs(...
                        strain(4,1), input_data, output_data), ...
                        [z, x, y, m, n], [start, xi, yi, m0, n0]), ...
                        coeff_fourier, output_fourier);
                    
                    exz(i,k)       = subs(subs(subs(...
                        strain(5,1), input_data, output_data), ...
                        [z, x, y, m, n], [start, xi, yi, m0, n0]), ...
                        coeff_fourier, output_fourier);
                    
                    height(i,k)    = start;
                    
                    start          = start - step;
                    
                end
                
                clear start step
                
            end
            
            % Creating a new vector with only one column
            for i = 1 : num_layer
                
                strain_xx           = cat(1, strain_xx, exx(:,i));
                strain_yy           = cat(1, strain_yy, eyy(:,i));
                strain_xy           = cat(1, strain_xy, exy(:,i));
                strain_xz           = cat(1, strain_xz, exz(:,i));
                strain_yz           = cat(1, strain_yz, eyz(:,i));
                total_height        = cat(1, total_height, height(:,i));
                
            end
            
            strain_xx               = strain_xx * (h/a)^2 / pmax;
            strain_yy               = strain_yy * (h/a)^2 / pmax;
            strain_xy               = strain_xy * (h/a) / pmax;
            strain_xz               = strain_xz * (h/a) / pmax;
            strain_yz               = strain_yz * (h/a) / pmax;
            
            % Final Vector
            this.sol_strain         = double(cat(2, total_height, ...
                    strain_xx, strain_yy, strain_xy, strain_yz, strain_xz));
                       
            disp("End   - Class_strain()             - strain()");
            disp(" ");
             
        end
        
    end
      
end