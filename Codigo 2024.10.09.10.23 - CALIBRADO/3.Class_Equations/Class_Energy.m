classdef Class_Energy
    
    % =================================================================== %
    % DESCRIPTION
    
    % This class calculates equations about energy in a laminated composite
    % plate, based on plate's efforts.
    % Version beta 1.0
    
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
        effort      Class_Effort
        
        % Create new parameters
        SE          = syms;     % Equation about strain energy
        WE          = syms;     % Equation about work energy
        KE          = syms;     % Equation about kinetic energy
        RE          = syms;     % Equation about damping energy
        
        dSE         = syms;     % Variational equation strain energy
        dWE         = syms;     % Variational equation work energy
        dKE         = syms;     % Variational equation kinetic energy
        dRE         = syms;     % Variational equation damping energy
        
        VE          = syms;     % Variational Equation
        
    end
    
    %% Public Methods
    methods
        
        function this = Class_Energy(plate, analysis, effort)
            
            if (nargin > 0)
                
                disp("Structure                          - PLATE");
                % Functions
                this = this.Strain_Energy_Plate(effort);
                this = this.Work_Energy_Plate();
                this = this.Kinetic_Energy_Plate(analysis, effort);
                this = this.Damping_Energy_Plate(plate, analysis);
                this = this.Variational_Equation_Plate();

            end
            
        end
        
    end
    
    %% Public Methods for Plate Functions
    methods
        
        % Function to calculate Strain Energy
        function this = Strain_Energy_Plate(this, effort)
            
            disp("Start - Class_Energy()             - Strain_Energy()");
            
            % Symbolic General Parameters
            syms x y z t
            
            % Symbolic General Parameters - Displacements and Rotations
            syms u0(x,y,t) v0(x,y,t) w0(x,y,t) tx(x,y,t) ty(x,y,t)
            
            % Symbolic definitions about stress
            syms sxx(x,y,z) syy(x,y,z) sxy(x,y,z) sxz(x,y,z) syz(x,y,z)
            
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
            
            % Import values from Class_Effort
            this.effort     = effort;
            strain          = this.effort.strain;
            
            % Strain Energy
            func_energy     = sxx * strain(1,1) + syy * strain(2,1) + ...
                sxy * strain(3,1) + syz * strain(4,1) + ...
                sxz * strain(5,1);
            func_energy     = simplify(expand(int(func_energy,z)));
            
            % Strain energy equation when it is considering symbolic
            % definitions about forces and moments applications
            this.SE         = subs(func_energy, ...
                [int(sxx,z)     , int(syy,z)      , int(sxy,z), ...
                int(sxx * z,z)  , int(syy * z,z)  , int(sxy * z,z), ...
                int(sxx * z^3,z), int(syy * z^3,z), int(sxy * z^3,z), ...
                int(syz,z)      , int(sxz,z), ...
                int(syz * z^2,z), int(sxz * z^2,z)], ...
                [Nxx, Nyy, Nxy, ...
                Mxx, Myy, Mxy, ...
                Pxx, Pyy, Pxy, ...
                Qyy, Qxx, ...
                Ryy, Rxx]);
            
            % Variational Equation - Strain Energy
            this.dSE        = formula(functionalDerivative(this.SE, ...
                [u0(x,y,t), v0(x,y,t), w0(x,y,t), tx(x,y,t), ty(x,y,t)]));
            
            disp("End   - Class_Energy()             - Strain_Energy()");
            disp(" ");
            
        end
        
        % =============================================================== %
        
        % Function to calculate external work energy
        function this = Work_Energy_Plate(this)
            
            disp("Start - Class_Energy()             - Work_Energy()");
            
            % Symbolic General Parameters
            syms x y t P
            
            % Variational parameters - Displacements and Rotations
            % Start with 'delta'
            syms du0(x,y,t) dv0(x,y,t) dw0(x,y,t) dtx(x,y,t) dty(x,y,t)
            
            % Work Energy
            this.WE     = P * dw0;
            
            % Variational Equation - Work Energy
            this.dWE        = formula(functionalDerivative(this.WE, ...
                [du0(x,y,t), dv0(x,y,t), dw0(x,y,t), ...
                dtx(x,y,t), dty(x,y,t)]));
            
            disp("End   - Class_Energy()             - Work_Energy()");
            disp(" ");
            
        end
        
        % =============================================================== %
        
        % Function to calculate kinetic energy
        function this = Kinetic_Energy_Plate(this, analysis, effort)
            
            disp("Start - Class_Energy()             - Kinetic_Energy()");
            
            % Import values from Class_Analysis
            this.analysis   = analysis;
            dynamic         = this.analysis.dynamic;
            
            % Import values from Class_Effort
            this.effort     = effort;
            ui              = this.effort.ui;
            
            % Symbolic General Parameters
            syms x y z t
            
            % Symbolic General Parameters - Displacements and Rotations
            syms u0(x,y,t) v0(x,y,t) w0(x,y,t) tx(x,y,t) ty(x,y,t)
            
            % Variational parameters - Displacements and Rotations
            % Start with 'delta'
            syms du0(x,y,t) dv0(x,y,t) dw0(x,y,t) dtx(x,y,t) dty(x,y,t)
            
            % Parameters for Integral - see Reddy (2004)
            syms I0 I1 I2 I3 I4 I5 I6 rho
            
            % Verifing the type of analysis
            if (dynamic == 0)
                
                this.dKE    = [0; 0; 0; 0; 0];
                
            elseif (dynamic == 1 || dynamic == 2)
                % Replacing parameters - Variational Case
                delta_u     = subs(ui(1,1), ...
                    [u0 v0 w0 tx ty], [du0 dv0 dw0 dtx dty]);
                
                delta_v     = subs(ui(2,1), ...
                    [u0 v0 w0 tx ty], [du0 dv0 dw0 dtx dty]);
                
                delta_w     = subs(ui(3,1), ...
                    [u0 v0 w0 tx ty], [du0 dv0 dw0 dtx dty]);
                
                % Auxiliar equations to calculate kinetic energy
                % Function to integrate
                func_energy = rho * expand(...
                    diff(ui(1,1), t) * diff(delta_u, t) + ...
                    diff(ui(2,1), t) * diff(delta_v, t) + ...
                    diff(ui(3,1), t) * diff(delta_w, t));
                
                % Integration aux function and replace parameters to Ii
                func_energy = simplify(...
                    expand(int(func_energy, z, 'Hold', true)));
                
                % Replacing parameters to function Ii - See Reddy's book
                this.KE     = subs(expand(func_energy), ...
                    [rho * int(1, z, 'Hold', true), ...
                    rho * int(z, z, 'Hold', true), ...
                    rho * int(z^2, z,'Hold', true), ...
                    rho * int(z^3, z, 'Hold', true), ...
                    rho * int(z^4, z, 'Hold', true), ...
                    rho * int(z^5, z, 'Hold', true), ...
                    rho * int(z^6, z, 'Hold', true)], ...
                    [I0, I1, I2, I3, I4, I5, I6]);
                
                this.dKE    = formula(functionalDerivative(this.KE, ...
                    [du0(x,y,t), dv0(x,y,t), dw0(x,y,t), ...
                    dtx(x,y,t), dty(x,y,t)]));
            end
            
            disp("End   - Class_Energy()             - Kinetic_Energy()");
            disp(" ");
            
        end
        
        % =============================================================== %
        
        function this = Damping_Energy_Plate(this, plate, analysis)
            
            disp("Start - Class_Energy()             - Damping_Energy()");
            
            % Import values from Class_Analysis
            this.analysis   = analysis;
            dynamic         = this.analysis.dynamic;
            
            % Import values from Class_Plate
            this.plate      = plate;
            c               = this.plate.c;
            
            if (dynamic == 0)
                % Do nothing
            elseif (dynamic == 1 || dynamic == 2)
                
                % Symbolic General Parameters
                syms x y t
                
                % Symbolic General Parameters - Displacements and Rotations
                syms u0(x,y,t) v0(x,y,t) w0(x,y,t)
                
                % Auxiliar equations to calculate damping energy
                % Function to integrate
                % this.RE = c * (diff(u0,t) * diff(du0,t) + ...
                % diff(v0,t) * diff(dv0,t) + diff(w0,t) * diff(dw0,t));
                
                % First derivative dtu = diff(u,t)
                syms dtu0(x,y,t) dtv0(x,y,t) dtw0(x,y,t)
                syms dtx0(x,y,t) dty0(x,y,t)
                
                % Auxiliar equations to calculate damping energy
                % Function to integrate
                this.RE = c * (dtu0^2 + dtv0^2 + dtw0^2);
                
            end
            
            % Variational Equation - Damping Energy
            if isempty(this.RE)
                this.dRE = [0; 0; 0; 0; 0];
            else
                
                this.dRE = formula(functionalDerivative(this.RE, ...
                    [dtu0(x,y,t), dtv0(x,y,t), dtw0(x,y,t), ...
                    dtx0(x,y,t), dty0(x,y,t)]));
                
                % Replacing variables in damping energy
                this.dRE = formula(subs(this.dRE, ...
                    [dtu0, dtv0, dtw0], [diff(u0,t),diff(v0,t),diff(w0,t)]));
                
            end
            
            disp("End   - Class_Energy()             - Damping_Energy()");
            disp(" ");
            
        end
        
        % =============================================================== %
        
        % Final Equations base on displacement
        function this = Variational_Equation_Plate(this)
            
            disp("Start - Class_Energy()             - Equation_Displacement()");
            
            % Finally, the final variational equation. It can be see in
            % Reddy (2004), equation 3.3.15 (page 120)
            this.VE     = this.dSE - this.dWE - this.dKE - this.dRE;

            disp("End   - Class_Energy()             - Equation_Displacement()");
            disp(" ");
            
        end
        
    end
    
end