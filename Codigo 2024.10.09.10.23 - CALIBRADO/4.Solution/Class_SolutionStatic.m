classdef Class_SolutionStatic
    
    % =================================================================== %
    % DESCRIPTION
    
    % This class calculate solution of laminated composite plates based on
    % simple supported as a boundary condition. Moreover, the type of
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
        plate       Class_Plate
        analysis    Class_Analysis
        pmt         Class_Parameters
        sol         Class_Solution
        blast       Class_Blast
        
        % Create new parameters
        mn_coeff            = syms;     % Parameters Fourier series
               
    end
    
    %% Public Methods
    methods
        
        function this = Class_SolutionStatic(plate, analysis, pmt, ...
                blast, sol)
            
            if (nargin > 0)
                
                disp("Structure                          - PLATE");
                % Functions
                this = this.Parameter_Fourier(plate, analysis, pmt, blast, sol);
                        
            end
            
        end
        
    end
    
    %% Public Methods for Plate Functions
    methods
        
        % Function to calculate Fourier's parameters
        function this = Parameter_Fourier(this, plate, analysis, pmt, ...
                blast, sol)
            
            disp("Start - Class_SolutionStatic()     - Parameter_Fourier()");
            
            syms t P
            
            % Import parameters from Class_Plate
            this.plate      = plate;
            q0              = this.plate.q0;
            
            % Import parameters from Class_Analysis
            this.analysis   = analysis;
            dynamic         = this.analysis.dynamic;
            theory          = this.analysis.theory;
            gen_button      = this.analysis.gen_button;
            
            % Import parameters from Class_Parameters
            this.pmt        = pmt;
            coeff_fourier   = this.pmt.coeff_fourier;
            
            % Import parameters from Class_Solution
            this.sol        = sol;
            final_galerkin  = this.sol.final_galerkin;
            
            % Replaceing parameters first and second derivatives for zero
            if (theory == 1 || theory == 4)
                
                final_galerkin = subs(final_galerkin, ...
                    [diff(coeff_fourier(1,1), t, t), ...
                    diff(coeff_fourier(1,2), t, t), ...
                    diff(coeff_fourier(1,3), t, t), ...
                    diff(coeff_fourier(1,1), t), ...
                    diff(coeff_fourier(1,2), t), ...
                    diff(coeff_fourier(1,3), t)], ...
                    [0 0 0 0 0 0]);
                
            else
                
                final_galerkin = subs(final_galerkin, ...
                    [diff(coeff_fourier(1,1), t, t), ...
                    diff(coeff_fourier(1,2), t, t), ...
                    diff(coeff_fourier(1,3), t, t), ...
                    diff(coeff_fourier(1,4), t, t), ...
                    diff(coeff_fourier(1,5), t, t), ...
                    diff(coeff_fourier(1,1), t), ...
                    diff(coeff_fourier(1,2), t), ...
                    diff(coeff_fourier(1,3), t), ...
                    diff(coeff_fourier(1,4), t), ...
                    diff(coeff_fourier(1,5), t)], ...
                    [0 0 0 0 0 0 0 0 0 0]);
                
            end
            
            % Reply P for load
            % First, avaliate which dynamic analysis the user inputed
            switch dynamic
                case 0 % static
                    q               = q0;
                case 1 % blast wave
                    % Import parameters from Class_Blast
                    this.blast      = blast;
                    pmax            = this.blast.pmax;
                    q               = pmax;
                case 2 % free vibration
                    q               = 0;
            end
            
            final_galerkin          = subs(final_galerkin, P, q);
            
            % Calculating solution
            if (theory == 2 || theory == 3)
                
                % Symbolic General Parameters
                syms Umn Vmn Wmn Xmn Ymn
                
                % ------------------------------------------------------- %
                % This case is only for gen_button == 1, because when this
                % button is ON, default of coeff_fourier in depends on
                % time. So, wer need to replace to original case for static
                % analysis.
                if gen_button == 1
                    adv_fourier     = [Umn Vmn Wmn Xmn Ymn];
                    final_galerkin  = subs(final_galerkin, ...
                        coeff_fourier, adv_fourier);
                    coeff_fourier   = adv_fourier;
                end
                
                % ------------------------------------------------------- %
                
                % Solution
                solution            = solve(final_galerkin, coeff_fourier);
                
                for i = 1 : length(solution.Umn)
                    
                    if isreal(solution.Umn(i,1))
                        u           = solution.Umn(i,1);
                    end
                    
                    if isreal(solution.Vmn(i,1))
                        v           = solution.Vmn(i,1);
                    end
                    
                    if isreal(solution.Wmn(i,1))
                        w           = solution.Wmn(i,1);
                    end
                    
                    if isreal(solution.Xmn(i,1))
                        tx          = solution.Xmn(i,1);
                    end
                    
                    if isreal(solution.Ymn(i,1))
                        ty          = solution.Ymn(i,1);
                    end
                    
                end
                
                this.mn_coeff       = [u; v; w; tx; ty];
                
            elseif (theory == 1 || theory == 4)
                
                % Symbolic General Parameters
                syms Umn Vmn Wmn
                
                % ------------------------------------------------------- %
                % This case is only for gen_button == 1, because when this
                % button is ON, default of coeff_fourier in depends on
                % time. So, wer need to replace to original case for static
                % analysis.
                if gen_button == 1
                    adv_fourier     = [Umn Vmn Wmn];
                    final_galerkin  = subs(final_galerkin, ...
                        coeff_fourier, adv_fourier);
                    coeff_fourier   = adv_fourier;
                end
                % ------------------------------------------------------- %
                
                solution            = solve(final_galerkin, coeff_fourier);
                
                for i = 1 : length(solution.Umn)
                    
                    if isreal(solution.Umn(i,1))
                        u           = solution.Umn(i,1);
                    end
                    
                    if isreal(solution.Vmn(i,1))
                        v           = solution.Vmn(i,1);
                    end
                    
                    if isreal(solution.Wmn(i,1))
                        w           = solution.Wmn(i,1);
                    end
                    
                end
                
                this.mn_coeff       = [u; v; w];
                
            elseif (theory == 5)
                
                % Symbolic General Parameters
                syms Umn Vmn Wmn Xmn Ymn
                
                % ------------------------------------------------------- %
                % This case is only for gen_button == 1, because when this
                % button is ON, default of coeff_fourier in depends on
                % time. So, wer need to replace to original case for static
                % analysis.
                if gen_button == 1
                    adv_fourier     = [Umn Vmn Wmn Xmn Ymn];
                    final_galerkin  = subs(final_galerkin, ...
                        coeff_fourier, adv_fourier);
                    coeff_fourier   = adv_fourier;
                end
                % ------------------------------------------------------- %
                
                % Use fsolve for static analysis
                x0                  = [0;0;0;0;0];
                
                fun                 = @(x) root5d(x, final_galerkin, ...
                    coeff_fourier);
                
                x                   = fsolve(fun, x0);
                
                % Replace mn_coeff
                this.mn_coeff       = [x(1,1); x(2,1); x(3,1); ...
                    x(4,1); x(5,1)];
                
            end
            
            disp("End   - Class_SolutionStatic()     - Parameter_Fourier()");
            disp(" ");
            
        end
        
    end
    
end