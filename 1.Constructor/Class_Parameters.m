classdef Class_Parameters
    
    % =================================================================== %
    % DESCRIPTION
    
    % This class represents a verification with all parameters that are
    % presents in software: general analysis, advanced analysis and fourier
    % parameters.
    % For each case, some parameters changes for general or advanced
    % analysis. Because of this, a behavior of blast wave and plate's
    % parameters can change.
    
    % =================================================================== %
    
    %% Public attributes
    properties (SetAccess = public, GetAccess = public)
        
        % Import Classes
        plate           Class_Plate
        tnt             Class_TNT
        analysis        Class_Analysis
        advanalysis     Class_AdvAnalysis
        
        % Create new parameters
        boundary        = 0;    % Boundary conditions
        coeff_fourier   = 0     % Cofficient's Fourier Series
        Z               = 0;    % Variable about parameter Z
        W               = 0;    % Variable about parameter W
        negative        = 0;    % Variable about negative phase consideration
                                % negative = 0 (OFF), negative = 1 (ON)
        
    end
    
    %% Constructor Mode
    methods
        
        function this = Class_Parameters(tnt, plate, analysis, advanalysis)
            if (nargin > 0)
                
                % Functions
                this = this.Parameter_Boundary(plate);
                this = this.Parameter_Fourier(analysis);
                this = this.Parameter_Z(tnt, analysis, advanalysis);
                this = this.Parameter_W(tnt, analysis, advanalysis);
                this = this.Parameter_Negative(tnt, analysis, advanalysis);
            
            end
            
        end
                
    end
    
    %% Public Methods
    methods
       
        % Function about boundary conditions
        function this = Parameter_Boundary(this, plate)
            
            % Import parameters from Class_Plate
            this.plate      = plate;
            x0              = this.plate.x0;
            xa              = this.plate.xa;
            y0              = this.plate.y0;
            yb              = this.plate.yb;
            
            if (x0 == 1 && xa == 1 && y0 == 1 && yb == 1)
                this.boundary = 1; % Simply supported
            elseif (x0 == 2 && xa == 2 && y0 == 2 && yb == 2)
                this.boundary = 2; % Clamped
            end
            
        end
        
        % =============================================================== %
        
        % Function about Fourier parameter
        function this = Parameter_Fourier(this, analysis)
                       
            % Import parameters from Class_Analysis
            this.analysis   = analysis;
            dynamic         = this.analysis.dynamic;
            theory          = this.analysis.theory;
            
            switch dynamic
                
                case 0  % Static Analysis
                    
                    if (theory == 1 || theory == 4)
                        % Symbolic parameters from Fourier Series
                        syms Umn Vmn Wmn
                        this.coeff_fourier = [Umn Vmn Wmn];
                    else
                        % Symbolic parameters from Fourier Series
                        syms Umn Vmn Wmn Xmn Ymn
                        this.coeff_fourier = [Umn Vmn Wmn Xmn Ymn];
                    end
                    
                case 1  % Dynamic Analysis (blast load)
                    
                    if (theory == 1 || theory == 4)
                        % Symbolic parameters from Fourier Series
                        syms Umn(t) Vmn(t) Wmn(t)
                        this.coeff_fourier = [Umn(t) Vmn(t) Wmn(t)];
                    else
                        % Symbolic parameters from Fourier Series
                        syms Umn(t) Vmn(t) Wmn(t) Xmn(t) Ymn(t)
                        this.coeff_fourier = [Umn(t) Vmn(t) Wmn(t) ...
                            Xmn(t) Ymn(t)];
                    end
                    
                case 2 % Free Vibration
                    
                    if (theory == 1 || theory == 4)
                        % Symbolic parameters from Fourier Series
                        % omg = omega (natural frequency)
                        syms U0 V0 W0 omg t
                        this.coeff_fourier = [U0 V0 W0]...
                            * exp(1i * omg * t);
                    else
                        % Symbolic parameters from Fourier Series
                        syms U0 V0 W0 X0 Y0 omg t
                        this.coeff_fourier = [U0 V0 W0 X0 Y0]...
                            * exp(1i * omg * t);
                    end
                    
            end
            
        end
        
        % Function about parameter Z (scaled distance)
        function this = Parameter_Z(this, tnt, analysis, advanalysis)
            
            % Import Classes
            this.tnt            = tnt;
            this.analysis       = analysis;
            this.advanalysis    = advanalysis;
            
            button              = this.analysis.gen_button;
            parameter           = this.advanalysis.adv_parameter;
            
            switch button
                case 0  % General Button (Do not use advanced analysis)
                    this.Z           = this.tnt.Z;
                case 1  % Advanced Button
                    switch parameter
                        case 1  % Using advanced analysis (variating Z)
                            this.Z   = this.advanalysis.Z_initial;
                        case 2  % Using advanced analysis (variating W)
                            this.Z   = this.advanalysis.Z_initial;
                        case 3 % Using advanced analysis (DAF - Variating W)
                            this.Z   = this.tnt.Z;
                        case 4  % Using advanced analysis: variating total 
                                % time per structure's linear period
                            this.Z   = this.advanalysis.Z_initial;
                        case 5  % Using advanced analysis: variating total 
                                % time per structure's nonlinear period
                            this.Z   = this.advanalysis.Z_initial;
                        case 6 % Using advanced analysis: variating total Z
                               % and calculating stress in the middle of
                               % the plate
                            this.Z   = this.advanalysis.Z_initial;
                        case 7 % Using advanced analysis (DAF - Variating Z)
                            this.Z   = this.advanalysis.Z_initial;
                        case 8 % Using advanced analysis (General Equation)
                            this.Z   = this.advanalysis.Z_initial;
                            
                    end
            end
            
        end
        
        % =============================================================== %
        
        % Function about parameter W (TNT's weight)
        function this = Parameter_W(this, tnt, analysis, advanalysis)
            
            % Import Classes
            this.tnt            = tnt;
            this.analysis       = analysis;
            this.advanalysis    = advanalysis;
            
            button              = this.analysis.gen_button;
            parameter           = this.advanalysis.adv_parameter;
            
            switch button
                case 0  % General Button (Do not use advanced analysis)
                    this.W                  = this.tnt.W;
                case 1  % Advanced Button
                    switch parameter
                        case 1  % Using advanced analysis (variating Z)
                            this.W          = this.tnt.W;
                        case 2  % Using advanced analysis (variating W)
                            this.W          = this.advanalysis.W_initial;
                        case 3 % Usind advanced analysis (DAF)
                            this.W          = this.advanalysis.W_initial;
                        case 4  % Using advanced analysis: variating total 
                                % time per structure's linear period
                            this.W          = this.tnt.W;
                        case 5  % Using advanced analysis: variating total 
                                % time per structure's nonlinear period
                            this.W          = this.tnt.W;
                        case 6 % Using advanced analysis: variating total Z
                               % and calculating stress in the middle of
                               % the plate
                            this.W          = this.tnt.W;
                        case 7 % Using advanced analysis (DAF - Variating Z)
                            this.W          = this.tnt.W;
                        case 8 % Using advanced analysis (General Equation)
                            this.W          = this.advanalysis.W_initial;
                                                     
                    end
            end
            
        end
        
        % =============================================================== %
        
        % Function about parameter negative phase
        function this = Parameter_Negative(this, tnt, analysis, advanalysis)
            
            % Import Classes
            this.tnt            = tnt;
            this.analysis       = analysis;
            this.advanalysis    = advanalysis;
            
            button              = this.analysis.gen_button;
            parameter           = this.advanalysis.adv_parameter;
            
            % analysis about advanced analysis
            switch button
                case 0  % General Button (Do not use advanced analysis)
                    this.negative           = this.analysis.negative;
                case 1  % Advanced Button
                    switch parameter
                        case 1  % Using advanced analysis (variating Z)
                            this.negative   = this.analysis.negative;
                        case 2  % Using advanced analysis (variating W)
                            this.negative   = this.advanalysis.adv_negative;
                        case 3 % Usind advanced analysis (DAF)
                            this.negative   = this.analysis.negative;
                        case 4  % Using advanced analysis: variating total 
                                % time per structure's linear period
                            this.negative   = this.analysis.negative;
                        case 5  % Using advanced analysis: variating total 
                                % time per structure's nonlinear period
                            this.negative   = this.analysis.negative;
                        case 6 % Using advanced analysis: variating total Z
                               % and calculating stress in the middle of
                               % the plate
                            this.negative   = this.analysis.negative;
                        case 7 % Using advanced analysis (DAF - Variating Z)
                            this.negative   = this.analysis.negative;
                        case 8 % Using advanced analysis (General Equation)
                            this.negative   = this.analysis.negative;
                            
                    end
                    
            end
            
        end
        
    end
    
end