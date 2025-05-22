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
        R               = 0;    % Variable about parameter R
        negative        = 0;    % Variable about negative phase consideration
                                % negative = 0 (OFF), negative = 1 (ON)
        
    end
    
    %% Constructor Mode
    methods
        
        function this = Class_Parameters(tnt, plate, analysis, advanalysis)
            if (nargin > 0)
                
                disp("Structure                          - PLATE");
                % Functions
                this    = this.Parameter_Fourier_Plate(analysis);

                % Functions
                this = this.Parameter_Boundary(plate);
                this = this.Parameter_Z(tnt, analysis, advanalysis);
                this = this.Parameter_W(tnt, analysis, advanalysis);
                this = this.Parameter_R(tnt, analysis, advanalysis);
                this = this.Parameter_Negative(tnt, analysis, advanalysis);
            
            end
            
        end
                
    end
    
    %% Public Methods for Plate Functions
    methods
        
        % Function about Fourier parameter
        function this = Parameter_Fourier_Plate(this, analysis)
                       
            % Import parameters from Class_Analysis
            this.analysis   = analysis;
            dynamic         = this.analysis.dynamic;
            theory          = this.analysis.theory;
            
            switch dynamic
                
                case 0  % Static Analysis
                    
                    % Symbolic parameters from Fourier Series
                        syms Umn Vmn Wmn

                    if (theory == 1 || theory == 4)
                        this.coeff_fourier = [Umn Vmn Wmn];
                    else
                        % Symbolic parameters from Fourier Series
                        syms Xmn Ymn
                        this.coeff_fourier = [Umn Vmn Wmn Xmn Ymn];
                    end
                    
                case 1  % Dynamic Analysis (blast load)

                    % Symbolic parameters from Fourier Series
                    syms t Umn(t) Vmn(t) Wmn(t)

                    if (theory == 1 || theory == 4)
                        this.coeff_fourier = [Umn(t) Vmn(t) Wmn(t)];
                    else
                        % Symbolic parameters from Fourier Series
                        syms Xmn(t) Ymn(t)
                        this.coeff_fourier = [Umn(t) Vmn(t) Wmn(t) ...
                            Xmn(t) Ymn(t)];
                    end
                    
                case 2 % Free Vibration
                    
                    % Symbolic parameters from Fourier Series
                    % omg = omega (natural frequency)
                    syms U0 V0 W0 omg t

                    if (theory == 1 || theory == 4)
                        this.coeff_fourier = [U0 V0 W0]...
                            * exp(1i * omg * t);
                    else
                        % Symbolic parameters from Fourier Series
                        syms X0 Y0 omg t
                        this.coeff_fourier = [U0 V0 W0 X0 Y0]...
                            * exp(1i * omg * t);
                    end
                    
            end
            
        end
        
    end
    
    % =================================================================== %
    % =================================================================== %
    % =================================================================== %
    %% Public Methods for General Functions
    methods
       
        % Function about boundary conditions
        function this = Parameter_Boundary(this, plate)
            
            % Import parameters from Class_Plate
            this.plate          = plate;
            SSCC                = this.plate.SSCC;
            
            if (SSCC == 0 || SSCC == 1)
                this.boundary   = 1;
            else
                this.boundary   = 2;
            end
            
        end
        
        % =============================================================== %
        
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
                    if parameter == 4
                        this.Z      = this.tnt.Z;
                    else
                        this.Z      = this.advanalysis.Z_initial;
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
                    if parameter == 2 || parameter == 4 || ...
                            parameter == 8 || parameter == 9
                        this.W         = this.advanalysis.W_initial;
                    else
                        this.W         = this.tnt.W;
                    end

            end
            
        end
        
        % =============================================================== %
        
        % Function about parameter R (scaled distance)
        function this = Parameter_R(this, tnt, analysis, advanalysis)
            
            this.tnt            = tnt;
            this.analysis       = analysis;
            this.advanalysis    = advanalysis;
            
            button              = this.analysis.gen_button;
            %parameter           = this.advanalysis.adv_parameter;
            
            switch button
                case 0  % General Button (Do not use advanced analysis)
                    this.R      = this.tnt.R;
                case 1  % Advanced Button
                    this.R      = this.tnt.R;
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
                    if parameter == 2
                        this.negative  = this.advanalysis.adv_negative;
                    else
                        this.negative  = this.analysis.negative;
                    end
                    
            end
            
        end
        
    end
    
end