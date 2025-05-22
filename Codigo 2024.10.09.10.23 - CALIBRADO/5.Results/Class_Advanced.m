classdef Class_Advanced
    
    % =================================================================== %
    % DESCRIPTION
    
    % This class presents another behavior of the plates. Seeing the
    % functions descriptions. All these function can be see in Reis [1].
    
    % Variables
    % type: type of explosion (1 for Hemispherical and 2 for Spherical)
    % sup: type of support (0 for simple support and 1 for campled)
    % type_sup: type of support of membrane (1 for immovable,
    % 2 for movable and 3 for stress free)
    % phase: phase for analisys (1 for positive phase,
    % 2 for negative phase, 3 for free vibration)
    % a: length for x direction (m)
    % beta: ratio a / b
    % E: Young's Modulus (N/m²)
    % h: tickness (m)
    % nu: Poisson's coeficient
    % rho: material's density (kg/m³)
    % Z: Scale distance (kg/m^1/3)
    % W: TNT's mass (kg)
    % time: time of analisys (s)
    % nonlinear: nonlinear effect (0 for not and 1 for yes)
    % negative: negative phase (0 for not and 1 for yes)
        
    % REFERENCES:
    % [1] Reis, A. W. Q. R. Análise dinâmica de placas considerando efeito
    % de membrana submetidas a carregamentos explosivos. Master's thesis.
    % (Master of Science in Civil Engineering) - Engineering Faculty, Rio
    % de Janeiro State University, Rio de Janeiro, 2019.
    % =================================================================== %
    
    %% Public attributes
    properties (SetAccess = public, GetAccess = public)
        
        % Import classes
        tnt         Class_TNT                % TNT's properties
        plate       Class_Plate              % Plate's properties
        layer       Class_Layer              % Layer's properties
        analysis    Class_Analysis           % Type Analysis propertie
        advanalysis Class_AdvAnalysis        % Advanced Analysis properties
        pmt         Class_Parameters         % Advanced Considerations
        bc          Class_BoundaryConditions % Plate's Boundary conditions
        material    Class_Material           % Plate's materials
        effort      Class_Effort             % Plate's effort
        sol         Class_Solution           % Analysis's solution
        
        matrix_adv      = [];
        vectorZ         = [];
        vectorR         = [];
        vectorW         = [];

        value_adv       = [];
        matrix_DispW    = [];
        matrix_DAF      = [];
        p               = [];
        A               = [];
        B               = [];
        C               = [];
        D               = [];
        E               = [];
        F               = [];
        
    end
    
    %% Constructor Mode
    methods
        
        function this = Class_Advanced(tnt, plate, layer, analysis, ...
                advanalysis, pmt, bc, material, effort, sol)
            
            if (nargin > 0)
                
                this.advanalysis    = advanalysis;
                adv_parameter       = this.advanalysis.adv_parameter;
                
                % Functions
                switch adv_parameter

                    case 1 % Case 1 - Z x uz / h
                        this = this.Advanced_Calculus1...
                            (tnt, plate, analysis, pmt, material, ...
                            effort, bc, sol);
                    case 2 % Case 2 - W x uz / h    
                        this = this.Advanced_Calculus2...
                            (tnt, plate, analysis, advanalysis, pmt, ...
                            material, effort, bc, sol);
                    case 3 % Case 3 - R x uz / h
                        this = this.Advanced_Calculus3...
                            (tnt, plate, analysis, pmt, material, ...
                            effort, bc, sol);
                    case 4 % Case 4 - td / TNL x FAD - Varying W   
                        this = this.Advanced_Calculus4...
                            (tnt, plate, layer, analysis, advanalysis, ...
                            pmt, material);
                    case 5 % Case 5 - td / TNL x FAD - Varying Z
                        this = this.Advanced_Calculus5(tnt, plate, ...
                            layer, analysis, advanalysis, pmt, material);
                    case 6 % Case 6 - td / TNL x FAD - Varying R 
                        this = this.Advanced_Calculus6(tnt, plate, ...
                            layer, analysis, advanalysis, pmt, material);
                    case 7 % Case 7 - td / TNL x uz / h 
                        this = this.Advanced_Calculus7(tnt, plate, layer, ...
                            analysis, advanalysis, pmt, material);
                    case 8 % Case 8 - General Equation 
                        this = this.Advanced_Calculus8(tnt, plate, ...
                            analysis, pmt, material, bc, sol);
                    case 9 % Case 9 - 3D Graphic - Surface
                        this = this.Advanced_Calculus9(tnt, plate, ...
                            analysis, pmt, material, bc, sol);
                end
                
            end
            
        end
        
    end
    
    %% Public Methods
    methods
        
        % Case 1 - Z x uz / h
        function this = Advanced_Calculus1(this, tnt, plate, ...
                analysis, pmt, material, effort, bc, sol)
            
            % Creating the waitbar
            bar                     = waitbar(0.1, ...
                'Loading parameters for Advanced Analysis');

            % Import all  classes
            this.tnt            = tnt;
            this.plate          = plate;
            this.analysis       = analysis;
            this.pmt            = pmt;
            this.material       = material;
            this.effort         = effort;
            this.bc             = bc;
            this.sol            = sol;
            
            % Import parameter from classes
            adv_parameter       = this.advanalysis.adv_parameter;
            
            % Replace the type of load equation.
            % In this case, if user choose an option of experimental data,
            % this software change to Rigby's calibration, because
            % experimental data not change blast wave's parameters.
            if (tnt.equation == 4)
                tnt.equation    = 2;
            elseif (tnt.equation == 6)
                tnt.equation    = 5;
            end
            
            % Changing the ss_analysis to 0
            analysis.ss_analysis = 0;

            % Start parameters to advanced analysis
            % Start Value for Z
            Z                   = 5;
            % Initial value for W
            W_initial           = this.pmt.W;
            % In this case not variate W
            W_final             = this.pmt.W;
            % Considering the user's value
            negative            = this.pmt.negative;
            
            % Initial parameters for looping
            % Number of steps
            N                   = 33;
            % Step Z
            stepZ               = (38 - Z) / N;

            % 90 = Waitbar before the loop is in 10%
            percent             = 0.9 / N;

            % Calculating curve
            for i = 1 : N

                loading         = 0.1 + i * percent;
                message         = sprintf...
                    ('Lopping... Percentage = %3.2f',loading*100);
                waitbar(loading, bar, message);

                % Create a new object adv
                vt_adv                  = Class_AdvAnalysis...
                    (adv_parameter, Z, W_initial, W_final, N, negative);
                
                % Create a new object pmt
                vt_pmt                  = Class_Parameters...
                    (tnt, plate, analysis, vt_adv);
                
                % Create a new object blast
                vt_blast                = Class_Blast(tnt, vt_pmt);
                
                % Create a new object static
                vt_static               = [];
                
                % Create a new object dynamic
                vt_dynamic              = Class_SolutionDynamic...
                    (tnt, analysis, vt_pmt, vt_blast, sol);

                disp(" ---------- ");
                disp("Looping number: ")
                disp(i);
                disp(" ---------- ");
                
                % Create a new object result
                vt_result               = Class_Result...
                    (plate, analysis, vt_blast, vt_pmt, material, bc, ...
                    vt_static, vt_dynamic);

                major                   = vt_result.max_w0;
                
                this.matrix_adv(i,1)    = Z;
                this.matrix_adv(i,2)    = abs(major);
                
                % This case we do not use the value Z implemented by the
                % user. We use a static initial value of Z and for each
                % loop this value needs to change a step determinated by
                % stepZ. So, in this case, we have to send a parameter to
                % the system and its needs to interpretate that an advaced
                % analysis. In this case, the parameter for this function
                % is n = 1, i.e, the last parameter in Major_Value.
                Z                       = Z + stepZ;
                
            end
             
            waitbar(1, bar, 'Ending of the Advanced Calculation');

            close(bar);
        
        end
        
        % =============================================================== %
        
        % Case 2 - W x uz / h
        function this = Advanced_Calculus2(this, tnt, plate, ...
                analysis, advanalysis, pmt, material, effort, bc, sol)
            
            % Creating the waitbar
            bar                     = waitbar(0.1, ...
                'Loading parameters for Advanced Analysis');

            % Import all constructor classes
            this.tnt            = tnt;
            this.plate          = plate;
            this.analysis       = analysis;
            this.advanalysis    = advanalysis;
            this.pmt            = pmt;
            this.material       = material;
            this.effort         = effort;
            this.bc             = bc;
            this.sol            = sol;
            
            % Replace the type of load equation.
            % In this case, if user choose an option of experimental data,
            % this software change to Rigby's calibration, because
            % experimental data not change blast wave's parameters.
            if (tnt.equation    == 4)
                tnt.equation    = 2;
            elseif (tnt.equation == 6)
                tnt.equation    = 5;
            end
            
            % Changing the ss_analysis to 0
            analysis.ss_analysis = 0;

            % Import parameter from classes
            Z                   = this.tnt.Z;
            adv_parameter       = this.advanalysis.adv_parameter;
            adv_negative        = this.advanalysis.adv_negative;
            N                   = this.advanalysis.interval;
            W_final             = this.advanalysis.W_final;
            
            % Initializing parameters
            adv_W_initial       = 0.1;
            W_step              = (W_final - adv_W_initial) / N;
            MON                 = zeros(N, 2);
            
            % Looping for case of negative phase
            % Looping use i is about negative phase
            % Create a new object adv
            vt_adv             = Class_AdvAnalysis(adv_parameter, ...
                Z, adv_W_initial, W_final, N, adv_negative);
            
            % Reset TNT's weigth
            vt_adv.W_initial   = 0.1;
            
            % 80 = Waitbar before the loop is in 10%
            percent             = 0.8 / N;

            for k = 1 : N
                
                loading         = 0.1 + k * percent;
                message         = sprintf...
                    ('Lopping... Percentage = %3.2f',loading*100);
                waitbar(loading, bar, message);

                % Create a new object pmt
                vt_pmt              = Class_Parameters...
                    (tnt, plate, analysis, vt_adv);
                
                % Create a new object blast
                vt_blast            = Class_Blast(tnt, vt_pmt);
                
                % Create a new object static
                vt_static           = [];
                
                % Create a new object dynamic
                vt_dynamic         = Class_SolutionDynamic...
                    (tnt, analysis, vt_pmt, vt_blast, sol);
                
                disp(" ---------- ");
                disp("Looping number: ")
                disp(k);
                disp(" ---------- ");
                
                % Create a new object result
                vt_result          = Class_Result...
                    (plate, analysis, vt_blast, vt_pmt, material, bc, ...
                    vt_static, vt_dynamic);
                major               = vt_result.max_disp(1,2);
                
                % Instructions
                % i = 0: Negative Phase OFF
                % i = 1: Negative Phase ON
                MON(k, 1)           = major;
                
                % Atualizating in new constructor object
                vt_adv.W_initial    = vt_adv.W_initial + W_step;
                
            end
            
            waitbar(0.9, bar, 'Creating the Matrix..');

            % Create a matrix with results
            W_initial                   = 0.1;
            
            for i = 1 : N
                
                this.matrix_adv(i,1)    = W_initial;
                this.matrix_adv(i,2)    = abs(MON(i,1));
                W_initial               = W_initial + W_step;
                
            end
            
            waitbar(1, bar, 'Ending of the Advanced Calculation');

            close(bar);
        
        end
        
        % =============================================================== %
        
        % Case 3 - R x uz / h
        function this = Advanced_Calculus3(this, tnt, plate, ...
                analysis, pmt, material, effort, bc, sol)
            
            % Creating the waitbar
            bar                 = waitbar(0.1, ...
                'Loading parameters for Advanced Analysis');

            % Import all  classes
            this.tnt            = tnt;
            this.plate          = plate;
            this.analysis       = analysis;
            this.pmt            = pmt;
            this.material       = material;
            this.effort         = effort;
            this.bc             = bc;
            this.sol            = sol;
            
            % Import parameter from classes
            adv_parameter       = this.advanalysis.adv_parameter;
            
            % Replace the type of load equation.
            % In this case, if user choose an option of experimental data,
            % this software change to Rigby's calibration, because
            % experimental data not change blast wave's parameters.
            if (tnt.equation == 4)
                tnt.equation    = 2;
            elseif (tnt.equation == 6)
                tnt.equation    = 5;
            end
            
            % Changing the ss_analysis to 0
            analysis.ss_analysis = 0;

            % Start parameters to advanced analysis
            % Start Value for Z
            Z                   = 5;
            Z_final             = 37;

            % Initial value for W
            W_initial           = this.pmt.W;
            % In this case not variate W
            W_final             = this.pmt.W;
            % Considering the user's value
            negative            = this.pmt.negative;
            
            % ------------------------------------------------------- %

            % Interval
            N                   = 100;

            % ------------------------------------------------------- %

            % Creating the interval of values of R based on the W value
            R                   = Z * W_initial^(1/3);
            R_final             = Z_final * W_initial^(1/3);

            stepR               = (R_final - R) / N;

            % ------------------------------------------------------- %

            % Creating a vector with all Z's calculated based on the R
            vector_Z            = zeros(N,1);
            vector_R            = zeros(N,1);
            vector_Z(1,1)       = 5;
            vector_R(1,1)       = R;

            for i = 2 : N
                R               = R + stepR;
                Z               = R / W_initial^(1/3);
                vector_R(i)     = R;
                vector_Z(i)     = Z;
            end

            % ------------------------------------------------------- %

            % 90 = Waitbar before the loop is in 10%
            percent             = 0.9 / N;

            % Calculating curve
            for i = 1 : N

                loading         = 0.1 + i * percent;
                message         = sprintf...
                    ('Lopping... Percentage = %3.2f',loading*100);
                waitbar(loading, bar, message);

                % Create a new object adv
                vt_adv          = Class_AdvAnalysis...
                    (adv_parameter, vector_Z(i,1), W_initial, W_final, ...
                    N, negative);
                
                % Create a new object pmt
                vt_pmt          = Class_Parameters...
                    (tnt, plate, analysis, vt_adv);
                
                % Create a new object blast
                vt_blast        = Class_Blast(tnt, vt_pmt);
                
                % Create a new object static
                vt_static       = [];
                
                % Create a new object dynamic
                vt_dynamic      = Class_SolutionDynamic...
                    (tnt, analysis, vt_pmt, vt_blast, sol);

                disp(" ---------- ");
                disp("Looping number: ")
                disp(i);
                disp(" ---------- ");
                
                % Create a new object result
                vt_result       = Class_Result...
                    (plate, analysis, vt_blast, vt_pmt, material, bc, ...
                    vt_static, vt_dynamic);

                major                   = vt_result.max_w0;
                
                this.matrix_adv(i,1)    = vector_R(i);
                this.matrix_adv(i,2)    = abs(major);
                
            end
             
            waitbar(1, bar, 'Ending of the Advanced Calculation');

            close(bar);
        
        end
        
        % =============================================================== %
        
        % Case 4 - td / TL x FAD - Varying W 
        function this = Advanced_Calculus4(this, tnt, plate, layer, ...
                analysis, advanalysis, pmt, material)
            
            % Creating the waitbar
            bar                     = waitbar(0.1, ...
                'Loading parameters for Advanced Analysis');

            % Import constructor classes
            this.tnt            = tnt;
            this.plate          = plate;
            this.layer          = layer;
            this.analysis       = analysis;
            this.advanalysis    = advanalysis;
            this.pmt            = pmt;
            
            % Import parameters from other classes
            this.material       = material;

            % We need to verify which boundary condition the user 
            % choosed. If SS1 or SS2, change the theory to 1 (CLPT), 
            % else, if the boundary condition is CCCC, change the theory 
            % to 4 (TvK)
            if (pmt.boundary        == 1)
                analysis.theory     = 1;
            else
                analysis.theory     = 4;
            end

            % Replace the type of load equation.
            % In this case, if user choose an option of experimental data,
            % this software change to Rigby's calibration, because
            % experimental data not change blast wave's parameters (Z).
            if (tnt.equation        == 4)
                tnt.equation        = 2;
            elseif (tnt.equation    == 6)
                tnt.equation        = 5;
            end
            
            % Changing the ss_analysis to 0
            analysis.ss_analysis = 0;

            % Creating new object Class_NaturalPeriod
            vt_period           = Class_NaturalPeriod(tnt, plate, layer, ...
                analysis, advanalysis);
            TL                  = vt_period.TNL;
            
            % Import parameters from Class_Material
            h                   = this.material.h;
            
            % Import parameter from classes
            Z                   = this.pmt.Z;
            adv_negative        = this.pmt.negative;
            adv_parameter       = this.advanalysis.adv_parameter;
            N                   = this.advanalysis.interval;
            W_final             = this.advanalysis.W_final;
            
            % Initializing parameters
            adv_W_initial       = 0.1;
            W_step              = (W_final - adv_W_initial) / N;
            
            % Looping for case of negative phase
            % Looping use i is about negative phase
            % Create a new object adv
            vt_adv             = Class_AdvAnalysis(adv_parameter, ...
                Z, adv_W_initial, W_final, N, adv_negative);
            
            % Reset TNT's weigth
            vt_adv.W_initial   = 0.1;
            
            % 90 = Waitbar before the loop is in 10%
            percent             = 0.9 / N;

            for i = 1 : N
                
                loading         = 0.1 + i * percent;
                message         = sprintf...
                    ('Lopping... Percentage = %3.2f',loading*100);
                waitbar(loading, bar, message);

                disp(" ---------- ");
                disp("Looping number: ")
                disp(i);
                disp(" ---------- ");
                
                % Creating new objects
                vt_pmt                  = Class_Parameters...
                    (tnt, plate, analysis, vt_adv);
                
                vt_blast                = Class_Blast(tnt, vt_pmt);

                vt_effort           = Class_Effort...
                    (plate, layer, analysis, material);

                vt_bc               = Class_BoundaryConditions...
                    (plate, analysis, pmt);

                vt_energy           = Class_Energy...
                    (plate, analysis, vt_effort);

                vt_sol              = Class_Solution...
                    (plate, layer, analysis, pmt, material, ...
                    vt_effort, vt_energy, vt_bc);

                vt_static               = Class_SolutionStatic...
                    (plate, analysis, vt_pmt, vt_blast, vt_sol);

                vt_dynamic              = Class_SolutionDynamic...
                    (tnt, analysis, vt_pmt, vt_blast, vt_sol);

                vt_result               = Class_Result...
                    (plate, analysis, vt_blast, vt_pmt, material, vt_bc, ...
                    vt_static, vt_dynamic);

                % Getting parameters
                td                      = vt_blast.td;                
                final_displacement      = vt_static.mn_coeff(3,1);
                major                   = double(vt_result.max_disp(1,2) * h);
                
                % Completing matrix
                this.matrix_adv(i,1)    = td / TL;
                this.matrix_adv(i,2)    = abs(major / final_displacement);
                
                % Updating in new constructor object
                vt_adv.W_initial        = vt_adv.W_initial + W_step;
                
            end
            
            waitbar(1, bar, 'Ending of the Advanced Calculation');

            close(bar);
        
        end
        
        % =============================================================== %
        
        % Case 5 - td / TL x FAD - Varying Z
        function this = Advanced_Calculus5(this, tnt, plate, layer, ...
                analysis, advanalysis, pmt, material)
            
            % Creating the waitbar
            bar                     = waitbar(0.1, ...
                'Loading parameters for Advanced Analysis');

            % Import constructor classes
            this.tnt            = tnt;
            this.plate          = plate;
            this.layer          = layer;
            this.analysis       = analysis;
            this.advanalysis    = advanalysis;
            this.pmt            = pmt;
            
            % Import parameters from other classes
            this.material       = material;

            % We need to verify which boundary condition the user 
            % choosed. If SS1 or SS2, change the theory to 1 (CLPT), 
            % else, if the boundary condition is CCCC, change the theory 
            % to 4 (TvK)
            if (pmt.boundary        == 1)
                analysis.theory     = 1;
            else
                analysis.theory     = 4;
            end

            % Replace the type of load equation.
            % In this case, if user choose an option of experimental data,
            % this software change to Rigby's calibration, because
            % experimental data not change blast wave's parameters (Z).
            if (tnt.equation        == 4)
                tnt.equation        = 2;
            elseif (tnt.equation    == 6)
                tnt.equation        = 5;
            end
            
            % Changing the ss_analysis to 0
            analysis.ss_analysis = 0;

            % Creating new object Class_NaturalPeriod
            vt_period           = Class_NaturalPeriod(tnt, plate, layer, ...
                analysis, advanalysis);
            TL                  = vt_period.TNL;
            
            % Import parameters from Class_Material
            h                   = this.material.h;
            
            % Start parameters to advanced analysis
            % Start Value for Z
            Z                   = 5;
            % Initial value for W
            W_initial           = this.pmt.W;
            % In this case not variate W
            W_final             = this.pmt.W;
            % Considering the user's value
            adv_negative        = this.pmt.negative;
            adv_parameter       = this.advanalysis.adv_parameter;
            
            % Initial parameters for looping
            % Number of steps
            N                   = 33;
            % Step Z
            stepZ               = (38 - Z) / N;

            % 90 = Waitbar before the loop is in 10%
            percent             = 0.9 / N;

            for i = 1 : N
                
                loading         = 0.1 + i * percent;
                message         = sprintf...
                    ('Lopping... Percentage = %3.2f',loading*100);
                waitbar(loading, bar, message);
                
                disp(" ---------- ");
                disp("Looping number: ")
                disp(i);
                disp(" ---------- ");
                
                % Create a new object adv
                vt_adv                  = Class_AdvAnalysis...
                    (adv_parameter, Z, W_initial, W_final, N, adv_negative);
                
                % Creating new objects
                vt_pmt                  = Class_Parameters...
                    (tnt, plate, analysis, vt_adv);
                
                vt_blast                = Class_Blast(tnt, vt_pmt);

                vt_effort           = Class_Effort...
                    (plate, layer, analysis, material);

                vt_bc               = Class_BoundaryConditions...
                    (plate, analysis, pmt);

                vt_energy           = Class_Energy...
                    (plate, analysis, vt_effort);

                vt_sol              = Class_Solution...
                    (plate, layer, analysis, pmt, material, ...
                    vt_effort, vt_energy, vt_bc);

                vt_static               = Class_SolutionStatic...
                    (plate, analysis, vt_pmt, vt_blast, vt_sol);

                vt_dynamic              = Class_SolutionDynamic...
                    (tnt, analysis, vt_pmt, vt_blast, vt_sol);

                vt_result               = Class_Result...
                    (plate, analysis, vt_blast, vt_pmt, material, vt_bc, ...
                    vt_static, vt_dynamic);

                % Getting parameters
                td                      = vt_blast.td;                
                final_displacement      = vt_static.mn_coeff(3,1);
                major                   = double(vt_result.max_disp(1,2) * h);
                
                % Completing matrix
                this.matrix_adv(i,1)    = td / TL;
                this.matrix_adv(i,2)    = abs(major / final_displacement);
                
                % Updating in new constructor object
                Z                       = Z + stepZ;
                
            end
            
            waitbar(1, bar, 'Ending of the Advanced Calculation');

            close(bar);
        
        end
         
        % =============================================================== %
        
        % Case 6 - td / TL x FAD - Varying R
        function this = Advanced_Calculus6(this, tnt, plate, layer, ...
                analysis, advanalysis, pmt, material)
            
            % Creating the waitbar
            bar                     = waitbar(0.1, ...
                'Loading parameters for Advanced Analysis');

            % Import constructor classes
            this.tnt            = tnt;
            this.plate          = plate;
            this.layer          = layer;
            this.analysis       = analysis;
            this.advanalysis    = advanalysis;
            this.pmt            = pmt;
            
            % Import parameters from other classes
            this.material       = material;

            % ------------------------------------------------------- %

            % We need to verify which boundary condition the user 
            % choosed. If SS1 or SS2, change the theory to 1 (CLPT), 
            % else, if the boundary condition is CCCC, change the theory 
            % to 4 (TvK)
            if (pmt.boundary    == 1)
                analysis.theory = 1;
            else
                analysis.theory = 4;
            end

            % ------------------------------------------------------- %

            % Replace the type of load equation.
            % In this case, if user choose an option of experimental data,
            % this software change to Rigby's calibration, because
            % experimental data not change blast wave's parameters (Z).
            if (tnt.equation        == 4)
                tnt.equation        = 2;
            elseif (tnt.equation    == 6)
                tnt.equation        = 5;
            end
            
            % ------------------------------------------------------- %

            % Changing the ss_analysis to 0
            analysis.ss_analysis    = 0;

            % Creating new object Class_NaturalPeriod
            vt_period               = Class_NaturalPeriod(tnt, plate, ...
                layer, analysis, advanalysis);
            TL                      = vt_period.TNL;
            
            % ------------------------------------------------------- %

            % Import parameters from Class_Material
            h                       = this.material.h;
            
            % ------------------------------------------------------- %

            % Start parameters to advanced analysis
            % Initial value for W
            W_initial               = this.pmt.W;
            % In this case not variate W
            W_final                 = this.pmt.W;
            % Considering the user's value
            adv_negative            = this.pmt.negative;
            adv_parameter           = this.advanalysis.adv_parameter;
            
            % ------------------------------------------------------- %

            % Interval
            N                       = 100;                % Number of steps

            % ------------------------------------------------------- %

            % Initial parameters

            Z                       = 5;
            Z_final                 = 37;

            % ------------------------------------------------------- %

            % Creating the interval of values of R based on the W value
            R                       = Z * W_initial^(1/3);
            R_final                 = Z_final * W_initial^(1/3);

            stepR                   = (R_final - R) / N;

            % ------------------------------------------------------- %

            % Creating a vector with all Z's calculated based on the R
            vector_Z                = zeros(N,1);
            vector_Z(1,1)           = 5;

            for i = 2 : N
                R                   = R + stepR;
                Z                   = R / W_initial^(1/3);
                vector_Z(i)         = Z;
            end

            % ------------------------------------------------------- %

            % 90 = Waitbar before the loop is in 10%
            percent                 = 0.9 / N;

            for i = 1 : N
                
                loading         = 0.1 + i * percent;
                message         = sprintf...
                    ('Lopping... Percentage = %3.2f',loading*100);
                waitbar(loading, bar, message);
                
                disp(" ---------- ");
                disp("Looping number: ")
                disp(i);
                disp(" ---------- ");
                
                % Create a new object adv
                vt_adv                  = Class_AdvAnalysis...
                    (adv_parameter, vector_Z(i), W_initial, W_final, ...
                    N, adv_negative);
                
                % Creating new objects
                vt_pmt                  = Class_Parameters...
                    (tnt, plate, analysis, vt_adv);
                
                vt_blast                = Class_Blast(tnt, vt_pmt);

                vt_effort               = Class_Effort...
                    (plate, layer, analysis, material);

                vt_bc                   = Class_BoundaryConditions...
                    (plate, analysis, pmt);

                vt_energy               = Class_Energy...
                    (plate, analysis, vt_effort);

                vt_sol                  = Class_Solution...
                    (plate, layer, analysis, pmt, material, ...
                    vt_effort, vt_energy, vt_bc);

                vt_static               = Class_SolutionStatic...
                    (plate, analysis, vt_pmt, vt_blast, vt_sol);

                vt_dynamic              = Class_SolutionDynamic...
                    (tnt, analysis, vt_pmt, vt_blast, vt_sol);

                vt_result               = Class_Result...
                    (plate, analysis, vt_blast, vt_pmt, material, vt_bc, ...
                    vt_static, vt_dynamic);

                % Getting parameters
                td                      = vt_blast.td;                
                final_displacement      = vt_static.mn_coeff(3,1);
                major                   = double(vt_result.max_disp(1,2) * h);
                
                % Completing matrix
                this.matrix_adv(i,1)    = td / TL;
                this.matrix_adv(i,2)    = abs(major / final_displacement);
                
            end
            
            waitbar(1, bar, 'Ending of the Advanced Calculation');

            close(bar);
        
        end
         
        % =============================================================== %
        
        % Case 7 - td / TNL x uz / h 
        function this = Advanced_Calculus7(this, tnt, plate, layer, ...
                analysis, advanalysis, pmt, material)
            
            % Creating the waitbar
            bar                     = waitbar(0.1, ...
                'Loading parameters for Advanced Analysis');

            % Import all constructor classes
            this.plate          = plate;
            this.layer          = layer;
            this.tnt            = tnt;
            this.analysis       = analysis;
            this.advanalysis    = advanalysis;
            this.pmt            = pmt;
            this.material       = material;

            % ------------------------------------------------------- %

            W_initial           = this.pmt.W;
            % In this case not variate W
            W_final             = this.pmt.W;
            % Considering the user's value
            negative            = this.pmt.negative;
            % Considering the user's value
            adv_parameter       = this.advanalysis.adv_parameter;

            % ------------------------------------------------------- %

            % If the user choosed the fourth advanced parameter, it
            % needs to verify boundary conditions
            plate.TNL           = 1;

            % ------------------------------------------------------- %

            % If the boundary condition is CCCC's types, change it
            % to the first type of boundary condition
            pmt.boundary        = 1;

            if analysis.theory == 1
                analysis.theory = 3;
            elseif analysis.theory == 4
                analysis.theory = 2;
            end

            % ------------------------------------------------------- %

            % Verifying the type of blast equation. If the equation
            % is based on the experimental data
            if tnt.equation == 4
                tnt.equation    = 3;
            elseif tnt.equation == 6
                tnt.equation    = 5;
            end

            % ------------------------------------------------------- %

            % Changing the ss_analysis to 0
            analysis.ss_analysis = 0;

            % ------------------------------------------------------- %

            % Initial parameters
            Z                   = 5;
            Z_final             = 37;
            N                   = 100;                % Number of steps
            stepZ               = (Z_final - Z) / N;   % Step Z

            % 90 = Waitbar before the loop is in 10%
            percent             = 0.9 / N;

            % Calculating the curve
            for i = 1 : N
                
                loading         = 0.1 + i * percent;
                message         = sprintf...
                    ('Lopping... Percentage = %3.2f',loading*100);
                waitbar(loading, bar, message);
                
                % Create object period with characteristics about
                % the object adv
                
                disp(" ---------- ");
                disp("Looping number: ")
                disp(i);
                disp(" ---------- ");
                
                % Creating a new objects
                vt_adv          = Class_AdvAnalysis...
                    (adv_parameter, Z, W_initial, W_final, N, negative);
                
                vt_pmt          = Class_Parameters...
                    (tnt, plate, analysis, vt_adv);

                vt_blast        = Class_Blast(tnt, vt_pmt);

                vt_effort       = Class_Effort...
                    (plate, layer, analysis, material);

                vt_energy       = Class_Energy...
                    (plate, analysis, vt_effort);

                vt_bc           = Class_BoundaryConditions...
                    (plate, analysis, vt_pmt);

                vt_sol          = Class_Solution...
                    (plate, layer, analysis, vt_pmt, material, ...
                    vt_effort, vt_energy, vt_bc);

                vt_static       = Class_SolutionStatic...
                    (plate, analysis, vt_pmt, vt_blast, vt_sol);

                vt_dynamic      = Class_SolutionDynamic...
                    (tnt, analysis, vt_pmt, vt_blast, vt_sol);

                vt_result       = Class_Result...
                    (plate, analysis, vt_blast, vt_pmt, material, ...
                    vt_bc, vt_static, vt_dynamic);

                vt_period       = Class_NaturalPeriod(tnt, ...
                    plate, layer, analysis, advanalysis);

                major           = vt_result.max_disp(1,2);

                td              = vt_blast.td;
                tm              = vt_blast.tm;
                total           = td + tm;

                this.matrix_adv(i,1)    = td / vt_period.TNL;
                this.matrix_adv(i,2)    = total / vt_period.TNL;
                this.matrix_adv(i,3)    = vt_period.TNL;
                this.matrix_adv(i,4)    = abs(major / material.h);
                
                Z                       = Z + stepZ;
                
            end
            
            waitbar(1, bar, 'Ending of the Advanced Calculation');

            close(bar);
        
        end
          
        % =============================================================== %
          
        % Case 8 - General Equation
        function this = Advanced_Calculus8(this, tnt, plate, analysis, ...
                pmt, material, bc, sol)
            
            % Creating the waitbar
            bar                     = waitbar(0.1, ...
                'Loading parameters for Advanced Analysis');

            % Import all  classes
            this.tnt            = tnt;
            this.plate          = plate;
            this.analysis       = analysis;
            this.pmt            = pmt;
            this.material       = material;
            this.bc             = bc;
            this.sol            = sol;
            
            % Import parameter from classes
            adv_parameter       = this.advanalysis.adv_parameter;
            
            % ------------------------------------------------------- %

            % Replace the type of load equation.
            % In this case, if user choose an option of experimental data,
            % this software change to Rigby's calibration, because
            % experimental data not change blast wave's parameters.
            if (tnt.equation == 4)
                tnt.equation    = 2;
            elseif (tnt.equation == 6)
                tnt.equation    = 5;
            end
            
            % ------------------------------------------------------- %

            % Changing the ss_analysis to 0
            analysis.ss_analysis = 0;

            % Start parameters to advanced analysis
            % Initial value for W
            W_initial           = this.pmt.W;
            % In this case not variate W
            W_final             = this.advanalysis.W_final;
            % Considering the user's value
            negative            = this.pmt.negative;
            
            % ------------------------------------------------------- %

            % Initial parameters for looping

            Z                   = 5;
            Z_final             = 37;
            
            NZ                  = (Z_final - Z);
            
            stepZ               = (Z_final - Z) / NZ;

            % Matrix about equation's coeffitients and TNT weight
            NW                  = 10;
            stepW               = NW;
            coef                = zeros(7, NW);

            % ------------------------------------------------------- %

            % Total of parameters
            N                   = NZ * NW;

            % ------------------------------------------------------- %

            % Calculating curve

            for j = 1 : NW

                Z = 5;

                for i = 1 : NZ

                    progress        = ((j - 1) * NZ + i) / N;
                    loading         = 0.1 + progress * 0.9;
                    message         = sprintf...
                        ('Lopping... Percentage = %3.2f',loading*100);
                    waitbar(loading, bar, message);

                    % Create a new object adv
                    vt_adv                  = Class_AdvAnalysis...
                        (adv_parameter, Z, W_initial, W_final, N, negative);

                    % Create a new object pmt
                    vt_pmt                  = Class_Parameters...
                        (tnt, plate, analysis, vt_adv);

                    % Create a new object blast
                    vt_blast                = Class_Blast(tnt, vt_pmt);

                    % Create a new object static
                    vt_static               = [];

                    % Create a new object dynamic
                    vt_dynamic              = Class_SolutionDynamic...
                        (tnt, analysis, vt_pmt, vt_blast, sol);

                    disp(" ---------- ");
                    disp("Looping number: ")
                    disp(i);
                    disp(" ---------- ");

                    % Create a new object result
                    vt_result               = Class_Result...
                        (plate, analysis, vt_blast, vt_pmt, material, bc, ...
                        vt_static, vt_dynamic);

                    major                   = vt_result.max_w0;

                    this.matrix_adv(i,1)        = Z;
                    this.matrix_adv(i,j + 1)    = abs(major);

                    % This case we do not use the value Z implemented by the
                    % user. We use a static initial value of Z and for each
                    % loop this value needs to change a step determinated by
                    % stepZ. So, in this case, we have to send a parameter to
                    % the system and its needs to interpretate that an advaced
                    % analysis. In this case, the parameter for this function
                    % is n = 1, i.e, the last parameter in Major_Value.
                    Z                       = Z + stepZ;

                end

                % Create a polynomial function and determinate their
                % coefficients
                x_axis          = this.matrix_adv(:,1);
                y_axis          = this.matrix_adv(:,j+1);
                this.p          = polyfit(x_axis, y_axis, 5);

                % Completing all spaces in coef matrix
                coef(1,j)       = this.p(1); % Coeff A of x^5
                coef(2,j)       = this.p(2); % Coeff B of x^4
                coef(3,j)       = this.p(3); % Coeff C of x^3
                coef(4,j)       = this.p(4); % Coeff D of x^2
                coef(5,j)       = this.p(5); % Coeff E of x^1
                coef(6,j)       = this.p(6); % Coeff F of x^0
                coef(7,j)       = W_initial;

                this.vectorW(j,1)   = W_initial;
                W_initial           = W_initial + stepW;

            end

            % Create a polynomial function about coefficient's behavior

            this.A = polyfit(coef(7,:), coef(1,:), 6);
            this.B = polyfit(coef(7,:), coef(2,:), 6);
            this.C = polyfit(coef(7,:), coef(3,:), 6);
            this.D = polyfit(coef(7,:), coef(4,:), 6);
            this.E = polyfit(coef(7,:), coef(5,:), 6);
            this.F = polyfit(coef(7,:), coef(6,:), 6);

            waitbar(1, bar, 'Ending of the Advanced Calculation');

            close(bar);
        
        end
         
        % =============================================================== %
          
        % Case 9 - 3D Graphic - Surface
        function this = Advanced_Calculus9(this, tnt, plate, analysis, ...
                pmt, material, bc, sol)
            
            % Creating the waitbar
            bar                     = waitbar(0.1, ...
                'Loading parameters for Advanced Analysis');

            % Import all  classes
            this.tnt            = tnt;
            this.plate          = plate;
            this.analysis       = analysis;
            this.pmt            = pmt;
            this.material       = material;
            this.bc             = bc;
            this.sol            = sol;
            
            % Import parameter from classes
            adv_parameter       = this.advanalysis.adv_parameter;
            
            % ------------------------------------------------------- %

            % Replace the type of load equation.
            % In this case, if user choose an option of experimental data,
            % this software change to Rigby's calibration, because
            % experimental data not change blast wave's parameters.
            if (tnt.equation == 4)
                tnt.equation    = 2;
            elseif (tnt.equation == 6)
                tnt.equation    = 5;
            end
            
            % ------------------------------------------------------- %

            % Changing the ss_analysis to 0
            analysis.ss_analysis = 0;

            % Start parameters to advanced analysis
            % Initial value for W
            W_initial           = this.pmt.W;
            % In this case not variate W
            W_final             = this.advanalysis.W_final;
            % Considering the user's value
            negative            = this.pmt.negative;
            % Number of steps
            stepW               = this.advanalysis.interval;
            
            % ------------------------------------------------------- %

            % Initial parameters for looping

            Z                   = 5;
            Z_final             = 37;
            
            NZ                  = (Z_final - Z);
            
            stepZ               = (Z_final - Z) / NZ;

            % Matrix about equation's coeffitients and TNT weight
            NW                  = stepW;
            
            % ------------------------------------------------------- %

            % Calculating vectors
            this.vectorZ        = zeros(NZ,NW);
            this.vectorR        = zeros(NZ,NW);
            this.vectorW        = zeros(NZ,NW);

            % ------------------------------------------------------- %

            % Total of parameters
            N                   = NZ * NW;

            % ------------------------------------------------------- %

            % Calculating curve

            for j = 1 : NW

                Z = 5;

                for i = 1 : NZ

                    progress        = ((j - 1) * NZ + i) / N;
                    loading         = 0.1 + progress * 0.9;
                    message         = sprintf...
                        ('Lopping... Percentage = %3.2f',loading*100);
                    waitbar(loading, bar, message);

                    % Create a new object adv
                    vt_adv                  = Class_AdvAnalysis...
                        (adv_parameter, Z, W_initial, W_final, NW, negative);

                    % Create a new object pmt
                    vt_pmt                  = Class_Parameters...
                        (tnt, plate, analysis, vt_adv);

                    % Create a new object blast
                    vt_blast                = Class_Blast(tnt, vt_pmt);

                    % Create a new object static
                    vt_static               = [];

                    % Create a new object dynamic
                    vt_dynamic              = Class_SolutionDynamic...
                        (tnt, analysis, vt_pmt, vt_blast, sol);

                    disp(" ---------- ");
                    disp(" W = " + W_initial + " kg")
                    disp(" Z = " + Z + " m/kg^(1/3)")
                    disp(" ---------- ");

                    % Create a new object result
                    vt_result               = Class_Result...
                        (plate, analysis, vt_blast, vt_pmt, material, bc, ...
                        vt_static, vt_dynamic);

                    major                   = vt_result.max_w0;

                    this.matrix_adv(i,j)    = abs(major);

                    this.vectorZ(i,j)       = Z;
                    this.vectorW(i,j)       = W_initial;
                    this.vectorR(i,j)       = Z * W_initial^(1/3);

                    % This case we do not use the value Z implemented by the
                    % user. We use a static initial value of Z and for each
                    % loop this value needs to change a step determinated by
                    % stepZ. So, in this case, we have to send a parameter to
                    % the system and its needs to interpretate that an advaced
                    % analysis. In this case, the parameter for this function
                    % is n = 1, i.e, the last parameter in Major_Value.
                    Z                       = Z + stepZ;

                end

                W_initial   = W_initial + stepW;

            end

            waitbar(1, bar, 'Ending of the Advanced Calculation');

            close(bar);
        
        end
         
    end
    
end