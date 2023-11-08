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
    
    % CASES
    % Case 1 - Parameter Z is variating
    % Case 2 - Parameter W is variating
    % Case 3 - Parameter W is variating
    % Case 4 - Parameter Z is variating
    % Case 5 - Parameter Z is variating
    % Case 6 - Parameter Z is variating
    % Case 7 - Parameter Z is variating
    
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
        energy      Class_Energy             % Plate's energy
        sol         Class_Solution           % Analysis's solution
        period      Class_NaturalPeriod      % Linear and nonlinear periods
        
        matrix_adv      = [];
        pressao         = [];
        tempo           = [];
        
    end
    
    %% Constructor Mode
    methods
        
        function this = Class_Advanced(tnt, plate, layer, analysis, ...
                advanalysis, pmt, bc, material, effort, energy, sol, ...
                period)
            
            if (nargin > 0)
                
                this.advanalysis    = advanalysis;
                adv_parameter       = this.advanalysis.adv_parameter;
                
                % Functions
                switch adv_parameter
                    case 1
                        this = this.Advanced_Calculus1...
                            (tnt, plate, analysis, pmt, material, ...
                            effort, bc, sol);
                    case 2
                        this = this.Advanced_Calculus2...
                            (tnt, plate, analysis, advanalysis, ...
                            pmt, material, effort, bc, sol);
                    case 3
                        this = this.Advanced_Calculus3...
                            (tnt, plate, analysis, pmt, material, ...
                            effort, bc, sol, period);
                    case 4
                        this = this.Advanced_Calculus4(tnt, plate, layer, ...
                            analysis, advanalysis, pmt, bc, material, effort, energy, sol, ...
                            period);
                    case 5
                        this = this.Advanced_Calculus5(plate, layer, ...
                            analysis, pmt, material, effort, energy);
                    case 6
                        this = Advanced_Calculus6(this, tnt, plate, ...
                            analysis, pmt, material, effort, bc, sol);
                end
                
            end
            
        end
        
    end
    
    %% Public Methods
    methods
        
        % Function to avaliate the behavior of displacement
        %(linear / nonlinear) for one case of W when Z is not constant
        function this = Advanced_Calculus1(this, tnt, plate, ...
                analysis, pmt, material, effort, bc, sol)
            
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
            
            % Calculating curve
            for i = 1 : N
                
                disp(" ---------- ");
                disp("Looping number: ")
                disp(i);
                disp(" ---------- ");
                
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
                
                % Create a new object result
                vt_result               = Class_Result...
                    (plate, analysis, vt_pmt, material, bc, ...
                    vt_static, vt_dynamic);
                
                major                   = vt_result.max_w0;
                
                this.matrix_adv(i,1)    = Z;
                this.matrix_adv(i,2)    = major;
                
                % This case we do not use the value Z implemented by the
                % user. We use a static initial value of Z and for each
                % loop this value needs to change a step determinated by
                % stepZ. So, in this case, we have to send a parameter to
                % the system and its needs to interpretate that an advaced
                % analysis. In this case, the parameter for this function
                % is n = 1, i.e, the last parameter in Major_Value.
                Z                       = Z + stepZ;
                
            end
            
        end
        
        % =============================================================== %
        
        % Function to avaliate the behavior of displacement nonlinear
        % for one case of Z when W_TNT is not constant
        function this = Advanced_Calculus2(this, tnt, plate, ...
                analysis, advanalysis, pmt, material, effort, bc, sol)
            
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
            
            for k = 1 : N
                
                disp(" ---------- ");
                disp("Looping number: ")
                disp(k);
                
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
                
                % Create a new object result
                vt_result          = Class_Result...
                    (plate, analysis, vt_pmt, material, bc, ...
                    vt_static, vt_dynamic);
                major               = vt_result.max_disp(1,2);
                
                % Instructions
                % i = 0: Negative Phase OFF
                % i = 1: Negative Phase ON
                MON(k, 1)           = major;
                
                % Atualizating in new constructor object
                vt_adv.W_initial    = vt_adv.W_initial + W_step;
                
            end
            
            % Create a matrix with results
            W_initial                   = 0.1;
            
            for i = 1 : N
                
                this.matrix_adv(i,1)    = W_initial;
                this.matrix_adv(i,2)    = MON(i,1);
                W_initial               = W_initial + W_step;
                
            end
            
        end
        
        % =============================================================== %
        
        % Calculating FAD - Variating W
        function this = Advanced_Calculus3(this, tnt, plate, analysis, ...
                pmt, material, effort, bc, sol, period)
            
            % Import all classes
            this.tnt            = tnt;
            this.plate          = plate;
            this.analysis       = analysis;
            this.pmt            = pmt;
            this.material       = material;
            this.effort         = effort;
            this.bc             = bc;
            this.sol            = sol;
            this.period         = period;
            
            % Import parameters from Class_NaturalPeriod
            TL                  = period.TL;
            
            % Import parameters from Class_Material
            h                   = this.material.h;
            
            % Replace the type of load equation.
            % In this case, if user choose an option of experimental data,
            % this software change to Rigby's calibration, because
            % experimental data not change blast wave's parameters.
            if (tnt.equation    == 4)
                tnt.equation    = 2;
            elseif (tnt.equation == 6)
                tnt.equation    = 5;
            end
            
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
            
            for i = 1 : N
                
                disp(" ---------- ");
                disp("Looping number: ")
                disp(i);
                
                % Create a new object pmt
                vt_pmt                  = Class_Parameters...
                    (tnt, plate, analysis, vt_adv);
                
                % Create a new object blast
                vt_blast                = Class_Blast(tnt, vt_pmt);
                td                      = vt_blast.td;
                
                % Create a new object static
                vt_static               = Class_SolutionStatic...
                    (analysis, vt_pmt, vt_blast, sol);
                
                final_displacement      = vt_static.mn_coeff(3,1);
                
                % Create a new object dynamic
                vt_dynamic              = Class_SolutionDynamic...
                    (tnt, analysis, vt_pmt, vt_blast, sol);
                
                disp(" ---------- ");
                disp("Looping number: ")
                disp(i);
                
                % Create a new object result
                vt_result               = Class_Result...
                    (plate, analysis, vt_pmt, material, bc, ...
                    vt_static, vt_dynamic);
                
                major                   = double(vt_result.max_disp(1,2) * h);
                
                % Completing matrix
                this.matrix_adv(i,1)    = td / TL;
                this.matrix_adv(i,2)    = major / final_displacement;
                
                % Atualizating in new constructor object
                vt_adv.W_initial        = vt_adv.W_initial + W_step;
                
            end
            
        end
        
        % =============================================================== %
        
        % Calculating plaste's behavior of td / nonlinear period
        function this = Advanced_Calculus4(this, tnt, plate, layer, ...
                analysis, advanalysis, pmt, bc, material, effort, energy, sol, ...
                period)
            
            % Import all constructor classes
            this.plate          = plate;
            this.layer          = layer;
            this.tnt            = tnt;
            this.analysis       = analysis;
            this.advanalysis    = advanalysis;
            this.pmt            = pmt;
            this.period         = period;
            
            % Import calculus classes
            this.bc             = bc;
            this.material       = material;
            this.effort         = effort;
            this.energy         = energy;
            this.sol            = sol;
            
            % Starting parameters
            Z         = 5;
            W_initial = this.pmt.W;
            % In this case not variate W
            W_final   = this.pmt.W;
            % Considering the user's value
            negative  = this.pmt.negative;
            
            % Initial parameters
            N = 35;                % Number of steps
            stepZ = (40 - Z) / N;   % Step Z
            
            % Calculating the curve
            for i = 1 : N
                
                % Create a new object adv
                vt_adv                  = Class_AdvAnalysis...
                    (adv_parameter, Z, W_initial, W_final, N, negative);
                
                [total, major, ~]       = General_Advanced...
                    (plate, layer, tnt, analysis, vt_adv, ...
                    material, effort, bc, sol);
                
                % Create object period with characteristics about
                % the object adv
                period                  = Class_NaturalPeriod(tnt, plate, ...
                    layer, analysis, advanalysis);
                TNL                     = period.TNL;
                
                this.matrix_adv(i,1)    = td / TNL;
                this.matrix_adv(i,2)    = total / TNL;
                this.matrix_adv(i,3)    = TNL;
                this.matrix_adv(i,4)    = major / h;
                
                Z = Z + stepZ;
                
            end
            
        end
        
        % Function to avaliate the behavior of displacement
        %(linear / nonlinear) for one case of W when Z is not constant
        function this = Advanced_Calculus5(this, plate, layer, ...
                analysis, pmt, material, effort, energy)
            
            % Import all  classes
            
            this.plate          = plate;
            this.layer          = layer;
            this.analysis       = analysis;
            this.pmt            = pmt;
            this.material       = material;
            this.effort         = effort;
            this.energy         = energy;
            
            % Starting parameter
            h                   = this.material.h;
            a                   = h;
            b                   = a;
            
            for i = 1 : 100
                
                disp(" ---------- ");
                disp("Looping number: ")
                disp(i);
                
                vt_plate                = Class_Plate(a, b, ...
                    plate.c, plate.K1, plate.m0, plate.n0, plate.xi, ...
                    plate.yi, plate.x0, plate.xa, plate.y0, plate.yb, ...
                    plate.q0, plate.SS, plate.TNL);
                
                vt_bc                   = Class_BoundaryConditions...
                    (vt_plate, analysis, pmt);
                vt_sol                  = Class_Solution...
                    (vt_plate, layer, analysis, pmt, material, effort, ...
                    energy, vt_bc);
                
                this.matrix_adv(i,1)    = vt_plate.a / h;
                this.matrix_adv(i,2)    = vt_sol.omega_barra;
                
                a                       = i * h;
                b                       = a;
                
                disp(vt_plate);
                
            end
            
        end
        % Function to avaliate the behavior of displacement
        %(linear / nonlinear) for one case of W when Z is not constant
        function this = Advanced_Calculus6(this, tnt, plate, ...
                analysis, pmt, material, effort, bc, sol)
            
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
            
            % Start parameters to advanced analysis
            % Start Value for Z
            Z                   = 5;
            % Initial value for W
            W_initial           = 10;
            % In this case not variate W
            W_final             = 100;
            % Considering the user's value
            negative            = this.pmt.negative;
            
            % Initial parameters for looping
            % Number of steps: 33
            N                   = 33;
            % Step Z
            stepZ               = (38 - Z) / N;
            
            for j = 1 : 10
                % Calculating curve
                for i = 1 : N
                    
                    disp(" ---------- ");
                    disp("Looping number i: ")
                    disp(i);
                    disp("Looping number i=j: ")
                    disp(j);
                    disp(" ---------- ");
                    
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
                    
                    % Create a new object result
                    vt_result               = Class_Result...
                        (plate, analysis, vt_pmt, material, bc, ...
                        vt_static, vt_dynamic);
                    
                    major                   = vt_result.max_disp(1,2);
                    
                    this.matrix_adv(i,1)    = Z;
                    this.matrix_adv(i,j+1)  = major;
                    
                    % This case we do not use the value Z implemented by the
                    % user. We use a static initial value of Z and for each
                    % loop this value needs to change a step determinated by
                    % stepZ. So, in this case, we have to send a parameter to
                    % the system and its needs to interpretate that an advaced
                    % analysis. In this case, the parameter for this function
                    % is n = 1, i.e, the last parameter in Major_Value.
                    Z                       = Z + stepZ;
                    
                end
                W_initial = W_initial + 100;
            end
            
        end
        
    end
    
    %% Static Methods
    methods (Static)
        
        function [total, major, ratio_stress] = General_Advanced...
                (plate, layer, tnt, analysis, adv, material, effort, bc, sol)
            
            % Create object to avaliate parameters
            vt_pmt          = Class_Parameters...
                (tnt, plate, analysis, adv);
            
            % Parameters from Class_Blast
            vt_blast        = Class_Blast(tnt, vt_pmt);
            td              = vt_blast.td;
            tm              = vt_blast.tm;
            total           = td + tm;
            
            % Parameters from Class_SolutionStatic
            vt_static       = Class_SolutionStatic...
                (plate, analysis, vt_pmt, bc, sol);
            
            % Parameters from Class_SolutionDynamic
            vt_dynamic      = Class_SolutionDynamic...
                (tnt, analysis, vt_pmt, vt_blast, sol);
            
            % Parameters from Class_Result
            vt_result       = Class_Result(plate, analysis, vt_pmt, ...
                bc, vt_blast, effort, vt_static, vt_dynamic);
            major           = vt_result.max_disp(1,3);
            
            % Parameters from Class_Stress
            vt_stress        = Class_Stress...
                (plate, layer, analysis, vt_pmt, material, ...
                effort, bc, vt_result);
            
            ratio_stress    = max(abs(vt_stress.sol_stress(:,2) / ...
                vt_stress.sol_stress(:,3)));
            
        end
        
    end
    
end