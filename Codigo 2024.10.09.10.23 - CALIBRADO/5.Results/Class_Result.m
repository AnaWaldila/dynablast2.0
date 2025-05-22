classdef Class_Result
    
    % =================================================================== %
    % DESCRIPTION
    
    % This class calculate all displacements of laminated composite plates.
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
        analysis            Class_Analysis
        pmt                 Class_Parameters
        blast               Class_Blast
        material            Class_Material
        bc                  Class_BoundaryConditions
        static_analysis     Class_SolutionStatic
        dynamic_analysis    Class_SolutionDynamic
        
        % Create new parameters
        max_w0              = 0;
        max_disp            = [];       % Maximun value of dynamic
        % displacement
        max_time            = 0;        % Time of maximun displacement
        fd                  = [];       % Final dynamic displacements
        % displacement
        pressure            = [];       % Final pressure
        
    end
    
    %% Public Methods
    methods
        
        function this = Class_Result(plate, analysis, blast, ...
                pmt, material, bc, static_analysis, dynamic_analysis)
            
            if (nargin > 0)
                
                disp("Structure                          - PLATE");
                
                % Functions
                this = this.Displacement_Plate...
                    (plate, analysis, pmt, material, ...
                    bc, static_analysis, dynamic_analysis);
                this = this.Pressure(analysis, blast, dynamic_analysis);

            end
            
        end
        
    end
    
    %% Public Methods for General Functions
    methods
        
        % Function to calculate pressure
        function this = Pressure(this, analysis, blast, dynamic_analysis)
            
            disp("Start - Class_Result()             - Pressure()");
            
            syms t
            
            % Import parameters from Class_Plate
            this.analysis                   = analysis;
            dynamic                         = this.analysis.dynamic;
            negative                        = this.analysis.negative;
            
            % Import parameters from Class_Blast
            this.blast                      = blast;
            
            switch dynamic
                case 0
                    
                    % Import parameters from Class_Blast
                    pmax                    = this.blast.pmax;
                    
                    % Import parameters from Class_SolutionStatic
                    this.pressure           = pmax;
                    
                case 1
                    
                    % Import parameters from Class_Blast
                    eq_p1                   = this.blast.eq_p1;
                    eq_p2                   = this.blast.eq_p2;
                    
                    % Import parameters from Class_SolutionDynamic
                    this.dynamic_analysis   = dynamic_analysis;
                    phase1                  = this.dynamic_analysis.phase1;
                    phase2                  = this.dynamic_analysis.phase2;
                    
                    % Verificating if the blast wave has negative phase
                    switch negative
                        case 0
                            
                            % Calculating pressure for positive phase
                            positive_phase          = ...
                                zeros(length(phase1),1);
                            positive_phase(:,1)     = ...
                                subs(eq_p1, t, phase1(:,1));
                            
                            % Final pressure
                            phases                  = positive_phase;
                            final_time              = phase1(:,1);
                            
                        case 1
                            
                            % Calculating pressure for positive phase
                            
                            positive_phase          = ...
                                zeros(length(phase1),1);
                            positive_phase(:,1)     = ...
                                subs(eq_p1, t, phase1(:,1));
                            
                            % Calculating pressure for negative phase
                            if (isempty(phase2))
                                len                 = length(this.fd);
                                len_pp              = length(phase1);
                                final_len           = len - len_pp;
                                
                                negative_phase      = zeros(final_len,1);
                                phase2              = zeros(final_len,1);
                            else
                                negative_phase      = ...
                                    zeros(length(phase2),1);
                            end

                            negative_phase(:,1)     = ...
                                subs(eq_p2, t, phase2(:,1));
                            
                            % Final pressure
                            phases                  = cat(1, positive_phase, ...
                                negative_phase);
                            final_time              = cat(1, phase1(:,1), ...
                                phase2(:,1));
                            
                    end
                    
                    this.pressure           = cat(2,final_time,phases);
                    
            end
            
            disp("End   - Class_Result()             - Pressure()");
            disp(" ");
            
        end
        
    end
    
    % =================================================================== %
    % =================================================================== %
    % =================================================================== %
    
    %% Public Methods for Plate Functions
    methods
        
        % This function calculates the behavior of the plate, i.e.,
        % displacement x time
        function this = Displacement_Plate(this, plate, analysis, pmt, ...
                material, bc, static_analysis, dynamic_analysis)
                        
            disp("Start - Class_Result()             - Displacement()");
            
            % Import parameters from Class_Plate
            this.plate              = plate;
            xi                      = this.plate.xi;
            yi                      = this.plate.yi;
            
            % Import parameters from Class_Analysis
            this.analysis           = analysis;
            dynamic                 = this.analysis.dynamic;
            gen_button              = this.analysis.gen_button;
            
            % Import parameters from Class_Parameters
            this.pmt                = pmt;
            coeff_fourier           = this.pmt.coeff_fourier;
            
            % Import parameters from Class_Effort
            this.material           = material;
            h                       = this.material.h;
            
            % Import parameters from Class_SolutionNavier
            this.bc                 = bc;
            d0                      = transpose(this.bc.d0);
            
            % Import parameters from Class_Solution
            switch dynamic
                
                case 0
                    
                    % Import parameters from Class_SolutionStatic
                    this.static_analysis    = static_analysis;
                    mn_coeff                = this.static_analysis.mn_coeff;
                    
                    this.fd                 = mn_coeff;
                    
                case 1
                    
                    % Import parameters from Class_SolutionDynamic
                    this.dynamic_analysis   = dynamic_analysis;
                    mn_coeff                = this.dynamic_analysis.mn_coeff;
                    
                    % Symbolic parameters
                    syms x y m n
                    
                    % Verificating the type of analysis
                    switch gen_button
                        
                        case 0
                            
                            % Final Displacement Equations
                            this.fd(:,1)    =  mn_coeff(:,1);
                            
                            this.fd(:,2)    = subs(subs(d0(1,3), ...
                                coeff_fourier(1,3), mn_coeff(:,6)), ...
                                [x y m n], [xi yi 1 1]) / h; % W
                            
                        case 1
                            
                            % Final Displacement Equations
                            this.fd(:,1)    =  mn_coeff(:,1);
                            
                            this.fd(:,2)    = ...
                                subs(subs(d0(1,3), ...
                                coeff_fourier(1,3), mn_coeff(:,6)), ...
                                [x y m n], [xi yi 1 1]) / h; % W
                            
                            % Calculating maximun displacement (abs)
                            this.max_w0     = max(abs(this.fd(:,2)));
                            
                            % Finding the time for max displacement (abs)
                            [row_w0, ~]     = find(abs(...
                                this.fd(:,2)) == this.max_w0);
                            this.max_time   = this.fd(row_w0,1);
                            
                            % Get the number of lines
                            [total_row,~]   = size(this.max_time);
                            
                            if total_row > 1
                                this.max_time = this.max_time(1,1);
                            end
                            
                            %Finding displacement about the time for maximum
                            % abs displacement
                            [row_time, ~]   = find(...
                                this.fd(:,1) == this.max_time);
                            this.max_disp(1,2) = ...
                                this.fd(row_time,2); % W0
                            
                    end
                    
            end
            
            disp("End   - Class_Result()             - Displacement()");
            disp(" ");
            
        end
        
    end
    
end