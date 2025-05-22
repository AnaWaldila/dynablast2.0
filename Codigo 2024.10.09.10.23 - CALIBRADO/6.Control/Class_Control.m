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
        vt_advresult        = [];
                           
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
        
        % =============================================================== %
        
        % Function to calculate static analysis
        function this = Static_Analysis...
                (this, tnt, plate, layer, analysis, advanalysis)
                       
            % Creating a waitbar
            bar                     = waitbar(0, 'Loading Input Data');

            % Import Constructor Classes
            this.tnt                = tnt;
            this.plate              = plate;
            this.layer              = layer;
            this.analysis           = analysis;
            this.advanalysis        = advanalysis;
            
            % Import parameters from Class_Analaysis
            dynamic                 = this.analysis.dynamic;

            % Creating new objects based on their main classes
            this.vt_pmt             = Class_Parameters...
                (tnt, plate, analysis, advanalysis);
            
            waitbar(0.1, bar, 'Calculating Material Parameters');

            this.vt_material        = Class_Material(layer);
            
            waitbar(0.2, bar, 'Calculating Structure Efforts');

            this.vt_effort          = Class_Effort...
                (plate, layer, analysis, this.vt_material);
            
            this.vt_bc              = Class_BoundaryConditions...
                (plate, analysis, this.vt_pmt);
            
            waitbar(0.3, bar, 'Calculating Energy Equation');

            this.vt_energy          = Class_Energy...
                (plate, analysis, this.vt_effort);
            
            waitbar(0.4, bar, 'Calculating Blast Parameters');

            % Type of structure
            switch dynamic
                case 0
                    % Do nothing
                case 1
                    this.vt_blast = Class_Blast(tnt, this.vt_pmt);
                case 2
                    % Do nothing
            end

            waitbar(0.5, bar, ...
                'Calculating System of Differential Dynamic Equation');

            this.vt_sol             = Class_Solution...
                (plate, layer, analysis, this.vt_pmt, this.vt_material, ...
                this.vt_effort, this.vt_energy, this.vt_bc);
            
            this.vt_static          = Class_SolutionStatic...
                (plate, analysis, this.vt_pmt, this.vt_blast, this.vt_sol);
             
            this.vt_dynamic         = [];

            waitbar(0.6, bar, ...
                'Solving the System of Differential Equations');

            this.vt_result          = Class_Result...
                (plate, layer, this.vt_pmt, this.vt_blast, this.vt_material, ...
                this.vt_bc, this.vt_static, this.vt_dynamic);
            
            close(bar);

            this.vt_stress          = Class_Stress...
                (plate, layer, analysis, this.vt_pmt, this.vt_material, ...
                this.vt_effort, this.vt_bc, this.vt_dynamic, this.vt_result);
            
            bar                     = waitbar(0.9, 'Loading Tables...');
            pause(3);
            waitbar(1, bar, 'Loading Graphics...');
            pause(3);
            close(bar);
            
        end
        
        % =============================================================== %
        
        % Function to calculate dynamic analysis
        function this = Dynamic_Analysis...
                (this, tnt, plate, layer, analysis, advanalysis)
                        
            % Creating a waitbar
            bar                     = waitbar(0, 'Loading Input Data');

            % Import Constructor Classes
            this.tnt                = tnt;
            this.plate              = plate;
            this.layer              = layer;
            this.analysis           = analysis;
            this.advanalysis        = advanalysis;
            
            % Import parameters from Class_Analysis
            dynamic                 = this.analysis.dynamic;
            
            % Creating new objects based on their main classes
            this.vt_pmt             = Class_Parameters...
                (tnt, plate, analysis, advanalysis);
            
            waitbar(0.1, bar, 'Calculating Material Parameters');

            this.vt_material        = Class_Material(layer);
            
            waitbar(0.2, bar, 'Calculating Structure Efforts');

            this.vt_effort          = Class_Effort...
                (plate, layer, analysis, this.vt_material);
            
            this.vt_bc              = Class_BoundaryConditions...
                (plate, analysis, this.vt_pmt);
            
            waitbar(0.3, bar, 'Calculating Energy Equation');

            this.vt_energy          = Class_Energy...
                (plate, analysis, this.vt_effort);
            
            switch dynamic
                case 0 % Static Case
                    % Do nothing
                case 1 % Blast Wave
                    
                    waitbar(0.4, bar, 'Calculating Blast Parameters');

                    this.vt_blast   = Class_Blast(tnt, this.vt_pmt);
                    
                    waitbar(0.5, bar, ...
                        'Calculating System of Differential Dynamic Equation');

                    this.vt_sol     = Class_Solution...
                        (plate, layer, analysis, this.vt_pmt, ...
                        this.vt_material, this.vt_effort, ...
                        this.vt_energy, this.vt_bc);
                    
                    this.vt_dynamic = Class_SolutionDynamic...
                        (tnt, analysis, this.vt_pmt, this.vt_blast, this.vt_sol);
                    
                    waitbar(0.6, bar, ...
                        'Solving the System of Differential Equations');

                    this.vt_result  = Class_Result...
                        (plate, analysis, this.vt_blast, this.vt_pmt,  ...
                        this.vt_material, this.vt_bc, this.vt_static, ...
                        this.vt_dynamic);

                case 2 % Free Vibration
                    
                    waitbar(0.4, bar, 'Calculating Blast Parameters');

                    this.vt_blast   = Class_Blast(tnt, this.vt_pmt);
                    
                    waitbar(0.5, bar, ...
                        'Calculating System of Differential Dynamic Equation');

                    this.vt_sol     = Class_Solution...
                        (plate, layer, analysis, this.vt_pmt, ...
                        this.vt_material, this.vt_effort, ...
                        this.vt_energy, this.vt_bc);
                            
                    waitbar(0.6, bar, ...
                        'Solving the System of Differential Equations');
            
                    this.vt_result  = Class_Result...
                        (plate, analysis, this.vt_blast, this.vt_pmt, ...
                        this.vt_material, this.vt_bc, this.vt_static, ...
                        this.vt_dynamic);
                    
            end

            close(bar);

            % The waitbar is implemented in Class_Strain
            this.vt_strain          = Class_Strain(plate, layer, ...
                analysis, this.vt_pmt, this.vt_bc, this.vt_blast, ...
                this.vt_material, this.vt_effort, this.vt_dynamic, ...
                this.vt_result);

            this.vt_stress          = Class_Stress(plate, layer, ...
                analysis, this.vt_pmt, this.vt_material, ...
                this.vt_effort, this.vt_bc, this.vt_dynamic, ...
                this.vt_result);

            bar                     = waitbar(0.9, 'Loading Tables...');
            pause(3);
            waitbar(1, bar, 'Loading Graphics...');
            pause(3);
            close(bar);
            
        end
        
        % =============================================================== %
        
        % Function to calculate dynamic analysis
        function this = Advanced_Analysis...
                (this, tnt, plate, layer, analysis, advanalysis)
                   
            % Creating a waitbar
            bar                     = waitbar(0, 'Loading Input Data');

            % Import Constructor Classes
            this.tnt                = tnt;
            this.plate              = plate;
            this.layer              = layer;
            this.analysis           = analysis;
            this.advanalysis        = advanalysis;
            
            % Creating new objects based on their main classes
            this.vt_pmt             = Class_Parameters...
                (tnt, plate, analysis, advanalysis);
            
            waitbar(0.1, bar, 'Calculating Material Parameters');

            this.vt_material        = Class_Material(layer);
            
            waitbar(0.2, bar, 'Calculating Structure Efforts');

            this.vt_effort          = Class_Effort...
                (plate, layer, analysis, this.vt_material);
            
            this.vt_bc              = Class_BoundaryConditions...
                (plate, analysis, this.vt_pmt);
            
            waitbar(0.3, bar, 'Calculating Energy Equation');

            this.vt_energy          = Class_Energy...
                (plate, analysis, this.vt_effort);
            
            waitbar(0.4, bar, 'Calculating Blast Parameters');

            this.vt_blast           = Class_Blast(tnt, this.vt_pmt);
            
            waitbar(0.5, bar, ...
                    'Calculating System of Differential Dynamic Equation');

            this.vt_sol             = Class_Solution...
                (plate, layer, analysis, this.vt_pmt, ...
                this.vt_material, this.vt_effort, ...
                this.vt_energy, this.vt_bc);
            
            waitbar(0.6, bar, ...
                    'Starting Advanced Analysis');

            close(bar);

            this.vt_advresult       = Class_Advanced(tnt, plate, layer, ...
                analysis, advanalysis, this.vt_pmt, this.vt_bc, ...
                this.vt_material, this.vt_effort, this.vt_sol);
            
            bar                     = waitbar(0.9, 'Loading Tables...');
            pause(3);
            waitbar(1, bar, 'Loading Graphics...');
            pause(3);
            close(bar);
            
        end

    end
    
end