 classdef Class_SolutionDynamic
     
    % =================================================================== %
    % DESCRIPTION
    
    % This class calculate solution of laminated composite plates based on
    % boundary condition. Moreover, the type of
    % analysis in that script is dynamic.
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
        tnt         Class_TNT
        analysis    Class_Analysis
        pmt         Class_Parameters
        blast       Class_Blast
        sol         Class_Solution
        
        % Create new parameters
        mn_coeff        = syms;             % Parameters Fourier series
        
        phase1          = [];               % Result for positive phase
        phase2          = [];               % Result for negative phase
        phase3          = [];               % Result for free vibration
        
    end
    
    %% Public Methods
    methods
        
        function this = Class_SolutionDynamic...
                (tnt, analysis, pmt, blast, sol)
            
            if (nargin > 0)
                
                disp("Structure                          - PLATE");
                % Functions
                this = this.Parameter_Fourier(tnt, analysis, pmt, blast, sol);

            end
            
        end
        
    end
    
    %% Public Methods for Plate Functions
    methods
        
        % Function to calculate Fourier's parameters
        function this = Parameter_Fourier(this, tnt, analysis, pmt, ...
                blast, sol)
            
            disp("Start - Class_SolutionDynamic()    - Parameter_Fourier()");
            
            % Import parameters from Class_TNT
            this.tnt        = tnt;
            equation        = this.tnt.equation;
                        
            % Import parameters from Class_Analysis
            this.analysis   = analysis;
            time            = this.analysis.time;
            theory          = this.analysis.theory;
            
            % Import parameters from Class_Parameters
            this.pmt        = pmt;
            negative        = this.pmt.negative;
            
            % Import parameters from Class_Blast
            this.blast      = blast;
            eq_p1           = this.blast.eq_p1;
            eq_p2           = this.blast.eq_p2;
            td              = this.blast.td;
            tm              = this.blast.tm;
            
            % Import parameters from Class_Solution
            this.sol        = sol;
            final_galerkin  = this.sol.final_galerkin;
            
            % Here is calculated the system of differential equation
            % considering the positive phase. After, it is analysed if
            % the negative phase exists and, finally, is calculated the
            % free vibration.
            syms P
            
            % 1.1. Replacing dynamic equation 
            galerkin_phase1 = subs(final_galerkin, P, eq_p1);
            
            % 1.2. Initial conditions
            if (theory == 1 || theory == 4)
                y0          = [0 0 0 0 0 0];
            elseif (theory == 2 || theory == 3)
                y0          = [0 0 0 0 0 0 0 0 0 0];
            end
            
            % 1.3. Calculating ode23 for positive phase
            [VF,~]          = odeToVectorField(galerkin_phase1);
            dy              = matlabFunction(VF, 'Vars',{'t','Y'});

            % Verificating the time
            if (time < td)
                % Considering this part as the total time of analysis 
                % less than the time of positive phase
                [t,y]           = ode23(dy,[0 time],y0);
                this.phase1     = [t,y];
                this.mn_coeff   = this.phase1;
                return;

            end

            [t,y]           = ode23(dy,[0 td],y0);
            this.phase1     = [t,y];
            
            % Clear parameters
            clear VF dy y0
            

            % Verificating if negative phase exists
            switch negative
                
                case 0
                    
                    % 2. Solution for Free Vibration
                    % 2.1. Initial conditions
                    y0          = this.phase1(end, :);
                    y0(:,1)     = [];
                    
                    % 2.2. Replacing dynamic equation of load to
                    % equation of free vibration
                    galerkin_phase3 = subs(final_galerkin, P, 0);
                    
                    % 2.5. Calculating ode23
                    [VF,~]      = odeToVectorField(galerkin_phase3);
                    dy          = matlabFunction(VF, 'Vars',{'t','Y'});
                    [t,y]       = ode23(dy,[td time],y0);
                    this.phase3 = [t,y];
                    
                    % 2.6. Final results
                    this.mn_coeff = cat(1, this.phase1, this.phase3);
                    
                case 1
                    
                    if (equation == 1 || equation == 2 || ...
                            equation == 3 || equation == 4)
                        
                        % 2. Solution for negative phase
                        % 2.1. Initial conditions
                        y0          = this.phase1(end, :);
                        y0(:,1)     = [];
                        
                        % 2.2. Replacing dynamic equation of load to
                        % equation of negative phase
                        galerkin_phase2 = subs(final_galerkin, P, eq_p2);
                        
                        % 2.3. Calculating ode23
                        [VF,~]      = odeToVectorField(galerkin_phase2);
                        dy          = matlabFunction(VF, 'Vars',{'t','Y'});

                        % Verifying the time
                        if (time < td + tm)
                            [t,y]   = ode23(dy,[td time],y0);
                            this.phase2 = [t,y];
                            this.mn_coeff = cat(1, this.phase1, ...
                                this.phase2);
                            return;
                        end

                        [t,y]       = ode23(dy,[td td + tm],y0);
                        this.phase2 = [t,y];
                        
                        % Clear parameters
                        clear VF dy y0
                        
                        % 3. Solution for Free Vibration
                        % 3.1. Initial conditions
                        y0          = this.phase2(end, :);
                        y0(:,1)     = [];
                        
                        % 3.2. Replacing dynamic equation of load to
                        % equation of free vibration
                        galerkin_phase3 = subs(final_galerkin, P, 0);
                        
                        % 3.5. Calculating ode23
                        [VF,~]      = odeToVectorField(galerkin_phase3);
                        dy          = matlabFunction(VF, 'Vars',{'t','Y'});
                        [t,y]       = ode23(dy,[td+tm time],y0);
                        this.phase3 = [t,y];
                        
                        % 3.6. Final results
                        this.mn_coeff = cat(1, this.phase1, this.phase2, ...
                            this.phase3);
                        
                    elseif (equation == 5 || equation == 6)
                        
                        % 2. Solution for negative phase
                        % 2.1. Initial conditions
                        y0          = this.phase1(end, :);
                        y0(:,1)     = [];
                        
                        % 2.2. Replacing dynamic equation of load to
                        % equation of negative phase
                        galerkin_phase2 = subs(final_galerkin, P, eq_p2);
                        
                        % 2.3. Calculating ode23
                        [VF,~]      = odeToVectorField(galerkin_phase2);
                        dy          = matlabFunction(VF, 'Vars',{'t','Y'});
                        [t,y]       = ode23(dy,[td time],y0);
                        this.phase2 = [t,y];
                                                
                        % 2.4. Final results
                        this.mn_coeff = cat(1, this.phase1, this.phase2);
                        
                    end
                    
            end
                                   
            disp("End   - Class_SolutionDynamic()    - Parameter_Fourier()");
            disp(" ");
            
        end
            
    end
    
end