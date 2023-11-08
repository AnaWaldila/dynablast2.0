classdef Class_NaturalPeriod
   
    % =================================================================== %
    % DESCRIPTION
    
    % This class presents the linear and nonlinear period of the plate.
    % This process was present by Yamaki [3] and calculated by Soudack [2].
    % Also that, Reis [1] presented the process of calculus.
    
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
    % [2] Soudack, A. C. Nonlinear Differential Equations Satisfied by the
    % Jacobian Elliptic Functions. Mathematics Magazine, Vol 37, 1964.
    % [3] Yamaki, N. Influence of Large Amplitudes on Flexural Vibrations of
    % Elastic Plates.
    % =================================================================== %
    
    %% Public attributes
    properties (SetAccess = public, GetAccess = public)
    
        % Import classes
        tnt         Class_TNT
        plate       Class_Plate
        layer       Class_Layer
        analysis    Class_Analysis
        advanalysis Class_AdvAnalysis
        blast       Class_Blast
        
        % Create new parameters
        TL      = 0;
        omega   = 0;
        
    end
    
    %% Constructor Mode
    methods
       
        function this = Class_NaturalPeriod(tnt, plate, layer, analysis, ...
                advanalysis)
            
            if (nargin > 0)
                
                this = this.LinearPeriod(tnt, plate, layer, analysis, ...
                advanalysis);
                
            end
            
        end
        
    end
    
    %% Public methods
    methods
       
        % Function to calculate the linear period
        function this = LinearPeriod(this, tnt, plate, layer, analysis, ...
                advanalysis)
            
            disp("Start - Class_NaturalPeriod()      - LinearPeriod()");
            
            % Import classes
            this.tnt            = tnt;
            this.plate          = plate;
            this.layer          = layer;
            this.analysis       = analysis;
            this.advanalysis    = advanalysis;
            
            % Import parameter
            adv_parameter       = this.advanalysis.adv_parameter;
                        
            % Creating new objects
            vt_pmt              = Class_Parameters...
                (tnt, plate, analysis, advanalysis);
            
            % Verificating the type of boundary conditions
            if vt_pmt.boundary == 1
                % Do nothing
            else
                analysis.theory = 4;
            end
            
            % Verificating if the analysis based on gen_button
            switch analysis.gen_button
                case 0
                    % Do nothing
                case 1
                    % if the user choosed the advanced analysis, it
                    % needs to veriticate if the adv.adv_parameter is equal
                    % to 3 (avaliating DAF). If the answer is YES, we
                    % change plate.TNT = 1 to plate.TNT = 0, because DAF is
                    % dependents of linear period.
                    if adv_parameter == 3
                        
                        plate.TNL = 0;
                        
                        % Moreover, we need to verificate which boundary
                        % condition is.
                        % Replace parameter
                        if vt_pmt.boundary == 1
                            analysis.theory = 1;
                        else
                            analysis.theory = 4;
                        end
                        
                    end
            end
            
            
            % Creating new objects
            vt_material         = Class_Material(layer);
            
            vt_effort           = Class_Effort(plate, layer, analysis, ...
                vt_material);
            
            vt_energy          = Class_Energy...
                (plate, analysis, vt_effort);
            
            vt_bc              = Class_BoundaryConditions...
                (plate, analysis, vt_pmt);
            
            vt_blast           = Class_Blast(tnt, vt_pmt);
            
            vt_sol             = Class_Solution...
                (plate, layer, analysis, vt_pmt, vt_material, ...
                vt_effort, vt_energy, vt_bc);
            
            vt_dynamic         = Class_SolutionDynamic...
                (tnt, analysis, vt_pmt, vt_blast, vt_sol);
            
            % Import paramters from Class_SolutionDynamic
            mn_coeff                = vt_dynamic.mn_coeff;
            
            % Finding local maxima in free vibration
            localmax                = islocalmax(mn_coeff(:,6));
            localmax                = cat(2, mn_coeff(:,1), ...
                mn_coeff(:,6), localmax);
            
            % Creating a new vector with all localmax paramters
            finalmax                = localmax(:,3) == 1;
            localmax                = localmax(finalmax,:);
            
            % Finding the linear period in free vibration behavior
            % Let's get the last parameter in vector localmax
            this.TL                 = localmax(end,1) - ...
                localmax(end-1,1);
            this.omega              = double(1 / this.TL);
            
            disp("End   - Class_NaturalPeriod()      - LinearPeriod()");
            disp(" ");
            
        end
        
    end
    
end