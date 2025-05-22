classdef Class_Solution
    
    % =================================================================== %
    % DESCRIPTION
    
    % This class calculates Navier general solutions for laminated
    % composite plates. Specific solutions as static/dynamic analysis are
    % developed in others scripts (see Class_SolutionNavierStatic.m and
    % Class_SolutionNavierDynamic.m).
    % It is important to know that Navier solution is only applied for
    % simply supported boundary conditions.
    
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
        layer       Class_Layer
        analysis    Class_Analysis
        pmt         Class_Parameters
        material    Class_Material
        effort      Class_Effort
        energy      Class_Energy
        bc          Class_BoundaryConditions
        
        % Creating new parameters
        var_num         = syms; % Variational Equation when it is replacing 
                                % symbolic parameters from numeric parameters
        sol_disp        = syms; % Final equations based on plate
                                % displacements
        eq_galerkin     = syms; % Galerkin's equation
        final_galerkin  = syms; % Galerkin's equation considering some type 
                                % of analysi
        omega           = syms; % Natural frequency
        omega_barra     = syms; % Nondimentional natural frequency
        
    end
    
    %% Public Methods
    methods
        
        function this = Class_Solution(plate, layer, analysis, pmt, ...
                material, effort, energy, bc)
            
            if (nargin > 0)
                
                disp("Structure                          - PLATE");
                % Functions
                this = this.Equation_Disp_Plate...
                    (analysis, effort, energy, bc);
                this = this.Gallerkin_Plate...
                    (plate, analysis, pmt, bc);
                this = this.Final_Equation_Plate...
                    (plate, layer, analysis, material);
                        
            end
            
        end
        
    end
    
    %% Public Methods for Plate Functions
    methods
        
        % Final Equations based on Displacement
        function this = Equation_Disp_Plate...
                (this, analysis, effort, energy, bc)
            
            disp("Start - Class_Solution()           - Equation_Disp()");
            
            % Import parameters from Class_Analysis
            this.analysis       = analysis;
            theory              = this.analysis.theory;
            dynamic             = this.analysis.dynamic;
            
            % Import parameters from Class_Effort
            this.effort         = effort;
            I                   = this.effort.I;
            N_b                 = this.effort.N_b;
            M_b                 = this.effort.M_b;
            P_b                 = this.effort.P_b;
            R_s                 = this.effort.R_s;
            Q_s                 = this.effort.Q_s;
            
            % Import parameters from Class_Energy
            this.energy         = energy;
            VE                  = this.energy.VE;
            
            % Import parameters from Class_BoundaryConditions
            this.bc             = bc;
            q                   = this.bc.q;
            d0                  = this.bc.d0;
            
            % Symbolic General Parameters
            syms x y z P
            syms u0(x,y,t) v0(x,y,t) w0(x,y,t) tx(x,y,t) ty(x,y,t)
            
            % Symbolic definitions about forces and moments applications
            % Nij = int(\sigma(i,j), z)
            syms Nxx(x,y,z) Nyy(x,y,z) Nxy(x,y,z)
            % Mij = int(\sigma(i,j) * z, z)
            syms Mxx(x,y,z) Myy(x,y,z) Mxy(x,y,z)
            % Pij = int(\sigma(i,j) * z^3, z)
            syms Pxx(x,y,z) Pyy(x,y,z) Pxy(x,y,z)
            % Qij = int(\sigma(i,j), z)
            syms Qxx(x,y,z) Qyy(x,y,z)
            % Rij = int(\sigma(i,j) * z^2, z)
            syms Rxx(x,y,z) Ryy(x,y,z)
          
            % Replacing parameters by values calulated before
            % 1.1 Replacing rotary inertia
            this.var_num        = ...
                vpa(Class_GeneralFunction.Effort_Parameters...
                (I, VE, length(VE)),5);
            
            %1.2. Calculating efforts
            N_b                 = ...
                vpa(Class_GeneralFunction.Effort_Parameters...
                (I, N_b, length(N_b)),5);
            M_b                 = ...
                vpa(Class_GeneralFunction.Effort_Parameters...
                (I, M_b, length(M_b)),5);
            P_b                 = ...
                vpa(Class_GeneralFunction.Effort_Parameters...
                (I, P_b, length(P_b)),5);
            
            if (theory == 2 || theory == 3 || theory == 5)
                R_s             = ...
                    vpa(Class_GeneralFunction.Effort_Parameters...
                    (I, R_s, length(R_s)),5);
                Q_s             = ...
                    vpa(Class_GeneralFunction.Effort_Parameters...
                    (I, Q_s, length(Q_s)),5);
            end
            
            % 1.3. Replacing numerical efforts in Variational Equation
            this.var_num        = expand(formula(subs(this.var_num, ...
                [Nxx(x,y,z), Nyy(x,y,z), Nxy(x,y,z), ...
                Mxx(x,y,z), Myy(x,y,z), Mxy(x,y,z), ...
                Pxx(x,y,z), Pyy(x,y,z), Pxy(x,y,z), ...
                Qyy(x,y,z), Qxx(x,y,z), ...
                Ryy(x,y,z), Rxx(x,y,z)], ...
                [N_b(1,1), N_b(2,1), N_b(3,1), ...
                M_b(1,1), M_b(2,1), M_b(3,1), ...
                P_b(1,1), P_b(2,1), P_b(3,1), ...
                Q_s(1,1), Q_s(2,1), ...
                R_s(1,1), R_s(2,1)])));
            
            % 1.4. If the dynamic analysisis is a free vibration analysis, 
            % P = 0
            if (dynamic == 2)
                this.var_num    = subs(this.var_num, P, 0);
            end
            
            % 1.5. Replacing displacements and rotations from Fourier
            % expressions
            if (theory == 1 || theory == 4)
                
                this.sol_disp   = formula(subs(this.var_num, ...
                    [u0, v0, w0, P], [d0(1,1), d0(2,1), d0(3,1), q]));
                
            else
                
                input_data      = formula([u0, v0, w0, tx, ty, P]);
                output_data     = formula([d0(1,1), d0(2,1), d0(3,1), ...
                    d0(4,1), d0(5,1), q]);
                this.sol_disp   = formula(subs(this.var_num, ...
                    input_data, output_data));
                
            end
            
            disp("End   - Class_Solution()           - Equation_Disp()");
            disp(" ");
            
        end
        
        % =============================================================== %
        
        % Function to calculate all equations by Gallerkin's method - only
        % for analysis with von Karman Theory
        function this = Gallerkin_Plate(this, plate, analysis, pmt, bc)
            
            disp("Start - Class_Solution()           - Gallerkin()");
            
            % Import parameters from Class_Plate
            this.plate      = plate;
            a               = this.plate.a;
            b               = this.plate.b;
            
            % Import parameters from Class_Analysis
            this.analysis   = analysis;
            theory          = this.analysis.theory;
            
            % Import parameters from Class_Parameters
            this.pmt        = pmt;
            coeff_fourier   = this.pmt.coeff_fourier;
            
            % Import parameters from Class_BoundaryConditions
            this.bc         = bc;
            d0              = this.bc.d0;
            
            % Symbolic General Parameters
            syms x y m n t
            
            % Gallerkin's method only for analysis with von Karman theory
            if (theory == 1)
                
                % U displacement
                equ = int(int(subs(this.sol_disp(1,1) * ...
                    d0(1,1) / coeff_fourier(1,1), [m n], [1 1]), ...
                    x, 0, a), y, 0, b);
                
                % V displacement
                eqv = int(int(subs(this.sol_disp(2,1) * ...
                    d0(2,1) / coeff_fourier(1,2), [m n], [1 1]), ...
                    x, 0, a), y, 0, b);
                
                % W displacement
                eqw = subs(this.sol_disp(3,1) * ...
                    d0(3,1) / coeff_fourier(1,3), [m n], [1 1]);
                eqw = int(eqw, x, 0, a);
                eqw = simplify(expand(eqw),500);
                eqw = int(eqw, y, 0, b);
                
                this.eq_galerkin = [equ; eqv; eqw];
                
            elseif (theory == 2 || theory == 3)
                
                % U displacement
                equ = int(int(subs(this.sol_disp(1,1) * ...
                    d0(1,1) / coeff_fourier(1,1), [m n], [1 1]), ...
                    x, 0, a), y, 0, b);
                
                % V displacement
                eqv = int(int(subs(this.sol_disp(2,1) * ...
                    d0(2,1) / coeff_fourier(1,2), [m n], [1 1]), ...
                    x, 0, a), y, 0, b);
                
                % W displacement
                eqw = formula(subs(this.sol_disp(3,1) * ...
                    d0(3,1) / coeff_fourier(1,3), [m n], [1 1]));
                eqw = int(int(eqw, y, 0, b), x, 0, a);
                
                % TX rotation
                eqtx = int(int(subs(this.sol_disp(4,1) * ...
                    d0(4,1) / coeff_fourier(1,4), [m n], [1 1]), ...
                    x, 0, a), y, 0, b);
                
                % TY rotation
                eqty = int(int(subs(this.sol_disp(5,1) * ...
                    d0(5,1) / coeff_fourier(1,5), [m n], [1 1]), ...
                    x, 0, a), y, 0, b);
                
                this.eq_galerkin = [equ; eqv; eqw; eqtx; eqty];
                
            elseif (theory == 4)
                
                % U displacement
                equ = int(int(subs(this.sol_disp(1,1) * ...
                    d0(1,1) / coeff_fourier(1,1), [m n], [1 1]), ...
                    x, 0, a), y, 0, b);
                equ = subs(equ, diff(coeff_fourier(1,3),t,t), 0);
                
                % V displacement
                eqv = int(int(subs(this.sol_disp(2,1) * ...
                    d0(2,1) / coeff_fourier(1,2), [m n], [1 1]), ...
                    x, 0, a), y, 0, b);
                eqv = subs(eqv, diff(coeff_fourier(1,3),t,t), 0);
                
                % W displacement
                eqw = subs(this.sol_disp(3,1) * ...
                    d0(3,1) / coeff_fourier(1,3), [m n], [1 1]);
                eqw = subs(eqw, [diff(coeff_fourier(1,1),t,t), ...
                    diff(coeff_fourier(1,2),t,t)], [0, 0]);
                
                eqw = simplify(expand(eqw),500);
                eqw = int(eqw, x, 0, a);
                
                eqw = simplify(expand(eqw),500);
                eqw  = int(eqw, y, 0, b);
                
                this.eq_galerkin = [equ; eqv; eqw];
            
            end

            disp("End   - Class_Solution()           - Gallerkin()");
            disp(" ");
            
        end
        
        % =============================================================== %
        % 
        function this = Final_Equation_Plate(this, plate, layer, ...
                analysis, material)
            
            disp("Start - Final_Equation()           - Gallerkin()");
            
            % Import parameters from Class_Plate
            this.plate          = plate;
            a                   = this.plate.a;
            
            % Import parameters from Class_Layer
            this.layer          = layer;
            rho                 = this.layer.rho;
            E2                  = this.layer.E2;
            
            % Import parameters from Class_Analysis
            this.analysis       = analysis;
            nonlinear           = this.analysis.nonlinear;
            dynamic             = this.analysis.dynamic;
            theory              = this.analysis.theory;
            
            % Import parameters from Class_Effort
            this.material       = material;
            h                   = this.material.h;
            
            % Verificating the type of analysis.
            % It is important to see that if the analysis is about small
            % displacements for CLPT, FSPT and HSPT (all those cases are
            % presented by Reddy, 2003), so the nonlinear parameters are
            % equal to zero. If not, none of nonlinear parameters are equal
            % to zero.
            if (theory == 1 || theory == 2 || theory == 3)
               
                if (dynamic == 0) && (nonlinear == 0)
                    % Case of static analysis and small displacements
                    
                    % Symbolic variables
                    syms Umn Vmn Wmn Xmn Ymn
                    
                    % Replacing parameters
                    this.final_galerkin = expand(this.eq_galerkin);
                    
                    this.final_galerkin = subs(this.final_galerkin, ...
                        [Wmn^2, Wmn^3, Wmn * Umn, ...
                        Wmn * Vmn, Wmn * Xmn, Wmn * Ymn], [0 0 0 0 0 0]);
                    
                    this.final_galerkin = expand(this.final_galerkin);
                    
                elseif (dynamic == 1) && (nonlinear == 0)
                    % Case of blast load and small displacements
                    
                    % Symbolic variables
                    syms t Umn(t) Vmn(t) Wmn(t) Xmn(t) Ymn(t)
                    
                    % Replacing parameters
                    this.final_galerkin = expand(this.eq_galerkin);
                    
                    this.final_galerkin = subs(this.final_galerkin, ...
                        [Wmn(t)^2, Wmn(t)^3, Wmn(t) * Umn(t), ...
                        Wmn(t) * Vmn(t), Wmn(t) * Xmn(t), ...
                        Wmn(t) * Ymn(t)], [0 0 0 0 0 0]);
                    
                    this.final_galerkin = expand(this.final_galerkin);
                    
                elseif (dynamic == 2) && (nonlinear == 0)
                   
                    % In this case is considered small displacement and
                    % free vibration case
                   
                    % Symbolic variables
                    syms omg t
                    syms U0 V0 W0 X0 Y0
                
                    % Equation galerkin when it is replacing Fourier
                    % parameters for free vibration expressions
                    % (exponential expression)
                    % Here it is need to divide by exp because Matlab not
                    % simplify eq_galerkin when appears an exp expression
                    this.final_galerkin = ...
                        expand(this.eq_galerkin / exp(omg * t * 1.0i));
                    
                    % Verificating the type of theory
                    if theory == 1
                        var             = [U0 V0 W0];
                    else
                        var             = [U0 V0 W0 X0 Y0];
                    end
                    
                    % Based on the analysis is about small displacements,
                    % some parameters need to be zero. 
                    this.final_galerkin = subs(this.final_galerkin, ...
                        [W0^2, W0^3, W0 * U0, W0 * V0, ...
                        W0 * X0, W0 * Y0], [0 0 0 0 0 0]);
                    this.final_galerkin = expand(this.final_galerkin);
                
                    % Converting equations in matrix
                    [A,~]               = ...
                        equationsToMatrix(this.final_galerkin, var);
                
                    % Solving matrix and finding natural frequency
                    this.omega          = min(abs(solve(det(A),omg)));
                    this.omega_barra    = this.omega * (a^2 / h) * ...
                        (rho(1,1) / E2(1,1))^(1/2);
                    
                elseif (dynamic == 0 || dynamic == 1) && (nonlinear == 1)
                    
                    this.final_galerkin = this.eq_galerkin;
                    
                end
                
            else
                % Case of theory == 4 and theory == 5
                % Both cases NEEDS to calculate with nonlinear parameters
                this.final_galerkin     = this.eq_galerkin;
                
            end
            
            disp("End   - Final_Equation()           - Gallerkin()");
            disp(" ");
            
        end
        
    end
    
end