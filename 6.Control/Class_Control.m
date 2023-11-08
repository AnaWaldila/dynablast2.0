 classdef Class_Control
    
   % =================================================================== %
    % DESCRIPTION
    
    % This class is the most important in software, because its control the
    % order that scrips will be function.
    
    % =================================================================== % 
    
    %% Public attributes
    properties (SetAccess = public, GetAccess = public)
        
        % Import Classes - Constructor
        plate           Class_Plate            % Plate's properties
        layer           Class_Layer            % Layer's properties
        tnt             Class_TNT              % TNT's properties
        analysis        Class_Analysis         % Type Analysis propertie
        advanalysis     Class_AdvAnalysis      % Type of Advanced Analysis
                
        % Create new parameters 
        vt_pmt              = [];
        vt_blast            = [];
        vt_material         = [];
        vt_effort           = [];
        vt_energy           = [];
        vt_bc               = [];
        vt_sol              = [];
        vt_static           = [];
        vt_dynamic          = [];
        vt_result           = [];
        vt_stress           = [];
        vt_strain           = [];
        vt_period           = [];
        vt_advresult        = [];
        vt_graphic          = [];
                           
    end
    
    %% Constructor Mode
    methods
        
        function this = Class_Control...
                (plate, layer, tnt, analysis, advanalysis)
            
            if (nargin > 0)
                
                % Import parameters from Class_Analysis
                this.analysis       = analysis;
                dynamic             = this.analysis.dynamic;
                gen_button          = this.analysis.gen_button;
                
                switch gen_button
                    
                    case 0
                        % General Analysis
                        if (dynamic == 0)
                            this    = this.Static_Analysis(tnt, plate, ...
                                layer, analysis, advanalysis);
                        else
                            this    = this.Dynamic_Analysis(tnt, plate, ...
                                layer, analysis, advanalysis);
                        end
                        
                    case 1
                        % Advanced Analysis
                        this        = this.Advanced_Analysis...
                            (tnt, plate, layer, analysis, advanalysis);
                        
                end
                
            end
            
        end
                
    end
    
    %% Public Methods
    methods
        
        % Function to calculate the nondamped natural frequency
        function this = Natural_Frequency...
                (this, tnt, plate, layer, analysis, advanalysis)
            
            % Import Constructor Classes
            this.tnt                = tnt;
            this.plate              = plate;
            this.layer              = layer;
            this.analysis           = analysis;
            this.advanalysis        = advanalysis;
            
            % Change values of constructor classes
            plate.c                 = 0;
            plate.TNL               = 1;
            
            % Create new object
            this.vt_pmt             = Class_Parameters...
                (tnt, plate, analysis, advanalysis);
            
            this.vt_blast           = Class_Blast(tnt, this.vt_pmt);
            
            this.vt_period          = Class_NaturalPeriod(tnt, plate, ...
                layer, analysis, advanalysis);
            
        end
        
        % =============================================================== %
        
        % Function to calculate static analysis
        function this = Static_Analysis...
                (this, tnt, plate, layer, analysis, advanalysis)
            
            % Import Constructor Classes
            this.tnt                = tnt;
            this.plate              = plate;
            this.layer              = layer;
            this.analysis           = analysis;
            this.advanalysis        = advanalysis;
            
            % Creating new objects based on their main classes
            this.vt_pmt             = Class_Parameters...
                (tnt, plate, analysis, advanalysis);
            
            this.vt_material        = Class_Material(layer);
            
            this.vt_effort          = Class_Effort...
                (plate, layer, analysis, this.vt_material);
            
            this.vt_energy          = Class_Energy...
                (plate, analysis, this.vt_effort);
            
            this.vt_bc              = Class_BoundaryConditions...
                (plate, analysis, this.vt_pmt);
            
            this.vt_sol             = Class_Solution...
                (plate, analysis, this.vt_pmt, this.vt_effort, ...
                this.vt_energy, this.vt_bc);
            
            this.vt_static          = Class_SolutionStatic...
                (analysis, this.vt_pmt, this.vt_blast, this.vt_sol);
             
            this.vt_result          = Class_Result...
                (plate, analysis, this.vt_pmt, this.vt_material, ...
                this.vt_bc, this.vt_static, this.vt_dynamic);
            
            this.vt_stress          = Class_Stress...
                (plate, layer, analysis, this.vt_pmt, this.vt_material, ...
                this.vt_effort, this.vt_bc, this.vt_result);
            
            this.vt_graphic         = Class_Graphic(this.vt_result, ...
                this.vt_stress);
            
            filename = 'static.xlsx';
            writematrix(this.vt_stress.sol_stress,filename,'Sheet',1)
            
        end
        
        % =============================================================== %
        
        % Function to calculate dynamic analysis
        function this = Dynamic_Analysis...
                (this, tnt, plate, layer, analysis, advanalysis)
                        
            % Import Constructor Classes
            this.tnt                = tnt;
            this.plate              = plate;
            this.layer              = layer;
            this.analysis           = analysis;
            this.advanalysis        = advanalysis;
            
            % Creating new objects based on their main classes
            this.vt_pmt             = Class_Parameters...
                (tnt, plate, analysis, advanalysis);
            
            this.vt_material        = Class_Material(layer);
            
            this.vt_effort          = Class_Effort...
                (plate, layer, analysis, this.vt_material);
            
            this.vt_energy          = Class_Energy...
                (plate, analysis, this.vt_effort);
            
            this.vt_bc              = Class_BoundaryConditions...
                (plate, analysis, this.vt_pmt);
            
            this.vt_blast           = Class_Blast(tnt, this.vt_pmt);
             
            this.vt_sol             = Class_Solution...
                (plate, layer, analysis, this.vt_pmt, ...
                this.vt_material, this.vt_effort, ...
                this.vt_energy, this.vt_bc);
            
            if (this.analysis.dynamic == 1)
                % Case considering the blast load
                
                this.vt_dynamic     = Class_SolutionDynamic...
                    (tnt, analysis, this.vt_pmt, this.vt_blast, this.vt_sol);
                
                this.vt_result      = Class_Result...
                    (plate, analysis, this.vt_pmt, this.vt_material, ...
                    this.vt_bc, this.vt_static, this.vt_dynamic);
                
                eq                  = this.vt_result.final_displacement;
                plot(eq(:,1), eq(:,2))
                
                filename            = 'dynamic_displacement.xlsx';
                writematrix(this.vt_result.final_displacement,...
                    filename,'Sheet',1)
                
            end
            
        end
        
        % =============================================================== %
        
        % Function to calculate dynamic analysis
        function this = Advanced_Analysis...
                (this, tnt, plate, layer, analysis, advanalysis)
           
            % Import Constructor Classes
            this.tnt                = tnt;
            this.plate              = plate;
            this.layer              = layer;
            this.analysis           = analysis;
            this.advanalysis        = advanalysis;
            
            % Creating new objects based on their main classes
            this.vt_pmt             = Class_Parameters...
                (tnt, plate, analysis, advanalysis);
            
            this.vt_material        = Class_Material(layer);
            
            this.vt_effort          = Class_Effort...
                (plate, layer, analysis, this.vt_material);
            
            this.vt_energy          = Class_Energy...
                (plate, analysis, this.vt_effort);
            
            this.vt_bc              = Class_BoundaryConditions...
                (plate, analysis, this.vt_pmt);
            
            this.vt_blast           = Class_Blast(tnt, this.vt_pmt);
            
            this.vt_sol             = Class_Solution...
                (plate, layer, analysis, this.vt_pmt, ...
                this.vt_material, this.vt_effort, ...
                this.vt_energy, this.vt_bc);
            
            % Verificating the type of dynamic analysis
            if analysis.dynamic == 1
                this.vt_dynamic     = Class_SolutionDynamic...
                    (tnt, analysis, this.vt_pmt, this.vt_blast, this.vt_sol);
            end
            
            % Verificating the type of adv_parameter
            if advanalysis.adv_parameter == 3
                this.vt_period      = Class_NaturalPeriod(tnt, plate, ...
                layer, analysis, advanalysis);
            end
            
            this.vt_advresult       = Class_Advanced(tnt, plate, layer, ...
                analysis, advanalysis, this.vt_pmt, this.vt_bc, ...
                this.vt_material, this.vt_effort, this.vt_energy, ...
                this.vt_sol, this.vt_period);
            
            eq = this.vt_advresult.matrix_adv;
            plot(eq(:,1), eq(:,2))
            
            filename = 'advanced_analysis.xlsx';
            writematrix(this.vt_advresult.matrix_adv,filename,'Sheet',1);
            
        end
    end
    
end