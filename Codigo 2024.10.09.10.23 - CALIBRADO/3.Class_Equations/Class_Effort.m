classdef Class_Effort
    
    % =================================================================== %
    % DESCRIPTION
    
    % This class calculate parameters to plate's efforts based on some
    % plate's theories: Classical Plate Theory, First Shear Order Theory,
    % High Shear Order Theory, Classical von Karman Theory and High Order
    % von Karman Theory
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
        material    Class_Material
        
        % Create new parameters
        
        ui          = sym([]);          % General displacement in plate in
        
        e0          = sym(zeros(3,1));  % Parameters from strain
        ek0         = sym(zeros(3,1));  % Parameters from strain 
        ek2         = sym(zeros(3,1));  % Parameters from strain
        g0          = sym(zeros(2,1));  % Parameters from strain
        g2          = sym(zeros(2,1));  % Parameters from strain
        
        strain_b    = sym([]);          % Strain matrix of bending
        strain_s    = sym([]);          % Strain matrix of shear
        strain      = sym([]);          % Final Strain Matrix
        
        stress_b    = sym([]);          % Matrix of bending stress
        stress_s    = sym([]);          % Matrix of shear stress
        stress      = sym([]);          % Final Stress Matrixx
        
        Ab          = sym(zeros(3,3));  % Bending matrix to calculate efforts
        Bb          = sym(zeros(3,3));  % Bending matrix to calculate efforts
        Db          = sym(zeros(3,3));  % Bending matrix to calculate efforts
        Eb          = sym(zeros(3,3));  % Bending matrix to calculate efforts
        Fb          = sym(zeros(3,3));  % Bending matrix to calculate efforts
        Hb          = sym(zeros(3,3));  % Bending matrix to calculate efforts
        I           = zeros(7,1);       % Mass inertia
        
        As          = sym(zeros(2,2));  % Shear matrix to calculate efforts
        Ds          = sym(zeros(2,2));  % Shear matrix to calculate efforts
        Fs          = sym(zeros(2,2));  % Shear matrix to calculate efforts
        
        N_b         = sym(zeros(3,1));  % Nij effort for all plate
        M_b         = sym(zeros(3,1));  % Mij effort for all plate
        P_b         = sym(zeros(3,1));  % Pij effort for all plate
        Q_s         = sym(zeros(2,1));  % Qij effort for all plate
        R_s         = sym(zeros(2,1));  % Rij effort for all plate
                        
    end
    
    %% Public Methods
    methods
        
        function this = Class_Effort(plate, layer, analysis, material)
            
            if (nargin > 0)
                
                disp("Structure                          - PLATE");
                % Functions
                this = this.Matrix_CoeffEffort_Plate...
                    (layer, material);
                this = this.General_Displacements_Plate...
                    (analysis, material);
                this = this.Strain_Plate(analysis, material);
                this = this.Stress_Plate(layer, material);
                this = this.Effort_Plate(plate, analysis);
                                       
            end
            
        end
        
    end
    
    %% Public Methods for Plate Functions
    methods
       
        % Function to calculate effort's coefficients matrices
        function this = Matrix_CoeffEffort_Plate(this, layer, material)
            
            disp("Start - Class_Effort()             - Matrix_CoeffEffort()");
            
            % Import parameters from Class_Layer
            this.layer      = layer;
            num_layer       = this.layer.num_layer;
            rho             = this.layer.rho;
            
            % Import parameters from Class_Material
            this.material   = material;
            zi              = this.material.zi;
            Q               = this.material.Q;
            
            % Here, replacing symbolic parameters to numeric parameters
            % To solve, numerically, this equation, and that can be
            % adaptated for a selected plate, it is necessary to calculate
            % all matrices of stiffness (Class_Effort) and the matrix of
            % inertia's moment.
            [A, B, D, E, F, H]  = Class_GeneralFunction.Matrix_Stiffness...
                (num_layer, Q, zi);
            [this.I]            = Class_GeneralFunction.Moment_Inertia...
                (num_layer, rho, zi);
            
            % Matrix Aij
%             A                 = sym('A',[6 6]);
            this.Ab             = [A(1,1) A(1,2) A(1,6); ...
                                   A(1,2) A(2,2) A(2,6); ...
                                   A(1,6) A(2,6) A(6,6)];
            
            this.As             = [A(4,4) A(4,5); ...
                                   A(4,5) A(5,5)];
            
            % Matrix Bij
%             B                 = sym('B',[6 6]);
            this.Bb             = [B(1,1) B(1,2) B(1,6); ...
                                   B(1,2) B(2,2) B(2,6); ...
                                   B(1,6) B(2,6) B(6,6)];
            
            % Matrix Dij
%             D                 = sym('D',[6 6]);
            this.Db             = [D(1,1) D(1,2) D(1,6); ...
                                   D(1,2) D(2,2) D(2,6); ...
                                   D(1,6) D(2,6) D(6,6)];
            
            this.Ds             = [D(4,4) D(4,5); ...
                                   D(4,5) D(5,5)];
            
            % Matrix Eij
%             E                 = sym('E',[6 6]);
            this.Eb             = [E(1,1) E(1,2) E(1,6); ...
                                   E(1,2) E(2,2) E(2,6); ...
                                   E(1,6) E(2,6) E(6,6)];
            
            % Matrix Fij
%             F                 = sym('F',[6 6]);
            this.Fb             = [F(1,1) F(1,2) F(1,6); ...
                                   F(1,2) F(2,2) F(2,6); ...
                                   F(1,6) F(2,6) F(6,6)];
            
            this.Fs             = [F(4,4) F(4,5); ...
                                   F(4,5) F(5,5)];
            
            % Matrix Hij
%             H                 = sym('H',[6 6]);
            this.Hb             = [H(1,1) H(1,2) H(1,6); ...
                                   H(1,2) H(2,2) H(2,6); ...
                                   H(1,6) H(2,6) H(6,6)];
            
            disp("End   - Class_Effort()             - Matrix_CoeffEffort()");
            disp(" ");
            
        end
        
        % =============================================================== %
        
        % Function to present all equations about total displacement
        % in laminated plate
        function this = General_Displacements_Plate...
                (this, analysis, material)
            
            disp("Start - Class_Effort()             - General_Displacements()");
            
            % Symbolic General Parameters
            syms x y z
            syms u0(x,y,t) v0(x,y,t) w0(x,y,t) tx(x,y,t) ty(x,y,t)
            
            % Import parameters from Class_Analysis
            this.analysis   = analysis;
            theory          = this.analysis.theory;
            
            % Import parameters from Class_Material
            this.material   = material;
            h               = this.material.h;
            
            % General displacements based on the theory
            switch theory
                case 1 % CLPT
                    
                    this.ui(1,1)    = u0 - z * diff(w0,x);
                    this.ui(2,1)    = v0 - z * diff(w0,y);
                    this.ui(3,1)    = w0;
                    
                case 2 % FSPT
                    
                    this.ui(1,1)    = u0 + z * tx;
                    this.ui(2,1)    = v0 + z * ty;
                    this.ui(3,1)    = w0;
                    
                case 3 % HSPT
                    
                    this.ui(1,1)    = u0 + z * tx - ...
                        (4 / 3 / h^2) * z^3 * (tx + diff(w0,x));
                    this.ui(2,1)    = v0 + z * ty - ...
                        (4 / 3 / h^2) * z^3 * (ty + diff(w0,y));
                    this.ui(3,1)    = w0;
                    
                case 4 % von Karman
                    
                    this.ui(1,1)    = u0 - z * diff(w0,x);
                    this.ui(2,1)    = v0 - z * diff(w0,y);
                    this.ui(3,1)    = w0;

            end
            
            disp("End   - Class_Effort()             - General_Displacements()");
            disp(" ");
            
        end
        
        % =============================================================== %
        
        % Function to calculate the strain matrix in laminate plate
        function this = Strain_Plate(this, analysis, material)
            
            disp("Start - Class_Effort()             - Strain()");
            
            % Symbolic General Parameters
            syms x y z
            syms u0(x,y,t) v0(x,y,t) w0(x,y,t) tx(x,y,t) ty(x,y,t)
            
            % Import parameters from Class_Analysis
            this.analysis   = analysis;
            theory          = this.analysis.theory;
            
            % Import parameters from Class_Material
            this.material   = material;
            h               = this.material.h;
            
            % Strain
            switch theory
                case 1 % CLPT
                    
                    this.e0(1,1)    = diff(u0,x);
                    this.e0(2,1)    = diff(v0,y);
                    this.e0(3,1)    = diff(u0,y) + diff(v0,x);
                    
                    this.ek0(1,1)   = - diff(w0,x,2);
                    this.ek0(2,1)   = - diff(w0,y,2);
                    this.ek0(3,1)   = - 2 * diff(diff(w0,x),y);
                    
                    this.ek2(1,1)   = 0;
                    this.ek2(2,1)   = 0;
                    this.ek2(3,1)   = 0;
                    
                    this.g0(1,1)    = 0;
                    this.g0(2,1)    = 0;
                    
                    this.g2(1,1)    = 0;
                    this.g2(2,1)    = 0;
                    
                case 2 % FSPT
                    
                    this.e0(1,1)    = diff(u0,x) + (1/2) * (diff(w0,x))^2;
                    this.e0(2,1)    = diff(v0,y) + (1/2) * (diff(w0,y))^2;
                    this.e0(3,1)    = diff(u0,y) + diff(v0,x) + ...
                                      diff(w0,x) * diff(w0,y);
                    
                    this.ek0(1,1)   = diff(tx,x);
                    this.ek0(2,1)   = diff(ty,y);
                    this.ek0(3,1)   = diff(tx,y) + diff(ty,x);
                    
                    this.ek2(1,1)   = 0;
                    this.ek2(2,1)   = 0;
                    this.ek2(3,1)   = 0;
                    
                    this.g0(1,1)    = ty + diff(w0,y);
                    this.g0(2,1)    = tx + diff(w0,x);
                    
                    this.g2(1,1)    = 0;
                    this.g2(2,1)    = 0;
                    
                case 3 % HSPT
                    
                    c1          = 4 / 3 / h^2;
                    c2          = 3 * c1;
                    
                    this.e0(1,1)    = diff(u0,x) + (1/2) * (diff(w0,x))^2;
                    this.e0(2,1)    = diff(v0,y) + (1/2) * (diff(w0,y))^2;
                    this.e0(3,1)    = diff(u0,y) + diff(v0,x) + ...
                                      diff(w0,x) * diff(w0,y);
                    
                    this.ek0(1,1)   = diff(tx,x);
                    this.ek0(2,1)   = diff(ty,y);
                    this.ek0(3,1)   = diff(tx,y) + diff(ty,x);
                    
                    this.ek2(1,1)   = (diff(tx,x) + diff(w0,x,2)) * (- c1);
                    this.ek2(2,1)   = (diff(ty,y) + diff(w0,y,2)) * (- c1);
                    this.ek2(3,1)   = (diff(tx,y) + diff(ty,x) + ...
                                       2 * diff(diff(w0,x),y)) * (- c1);
                    
                    this.g0(1,1)    = ty + diff(w0,y);
                    this.g0(2,1)    = tx + diff(w0,x);
                    
                    this.g2(1,1)    = (ty + diff(w0,y)) * (- c2);
                    this.g2(2,1)    = (tx + diff(w0,x)) * (- c2);
                    
                case 4 % von Karman
                    
                    this.e0(1,1)    = diff(u0,x) + (1/2) * (diff(w0,x))^2;
                    this.e0(2,1)    = diff(v0,y) + (1/2) * (diff(w0,y))^2;
                    this.e0(3,1)    = diff(u0,y) + diff(v0,x) + ...
                                      diff(w0,x) * diff(w0,y);
                    
                    this.ek0(1,1)   = - diff(w0,x,2);
                    this.ek0(2,1)   = - diff(w0,y,2);
                    this.ek0(3,1)   = - 2 * diff(diff(w0,x),y);
                    
                    this.ek2(1,1)   = 0;
                    this.ek2(2,1)   = 0;
                    this.ek2(3,1)   = 0;
                    
                    this.g0(1,1)    = 0;
                    this.g0(2,1)    = 0;
                    
                    this.g2(1,1)    = 0;
                    this.g2(2,1)    = 0;
                    
            end
            
            % Strain bending matrix
            this.strain_b           = this.e0 + z * this.ek0 + ...
                                      z^3 * this.ek2;
            
            %            [exx]
            % strain_b = [eyy]
            %            [exy]
            
            % Strain shear matrix
            this.strain_s           = this.g0 + z^2 * this.g2;
            
            % strain_s = [gyz]
            %            [gxz]
                        
            % Matrix strain
            this.strain             = cat(1,this.strain_b,this.strain_s);
                        
            disp("End   - Class_Effort()             - Strain()");
            disp(" ");
            
        end
        
        % =============================================================== %
        
        % Function to calculate the stress matrix in laminate plate
        function this = Stress_Plate(this, layer, material)
            
            disp("Start - Class_Effort()             - Stress()");
            
            % Import parameters from Class_Layer
            this.layer      = layer;
            num_layer       = this.layer.num_layer;
            
            % Import parameters from Class_Material
            this.material   = material;
            Qb              = this.material.Qb;
            Qs              = this.material.Qs;
            
            % For each layer, it is necessary to create a new matrix.
            % So, in this case, it is a matrix of matrices. The third
            % parameter in matrices represents the coordinate of the
            % layer
            
            for i = 1 : num_layer
                
                % Matrix of bending stress
                this.stress_b(:,:,i) = Qb(:,:,i) * this.strain_b;
                
                % Matrix of shear stress
                this.stress_s(:,:,i) = Qs(:,:,i) * this.strain_s;
                
            end
            
            % Matrix stress
            this.stress              = cat(1,this.stress_b,this.stress_s);
            
            %           [sxx]
            %           [syy]
            % stress =  [sxy]
            %           [syz]
            %           [sxz]
            
            disp("End   - Class_Effort()             - Stress()");
            disp(" ");
            
        end
        
        % =============================================================== %
        
        % Function to calculate all efforts in plate
        function this = Effort_Plate(this, plate, analysis)
            
            disp("Start - Class_Effort()             - Effort()");
            
            % Import parameters from Class_Plate
            this.plate      = plate;
            K1              = this.plate.K1;

            % Import parameters from Class_Analysis
            this.analysis   = analysis;
            theory          = this.analysis.theory;
            
            % Replacing parameters
            this.N_b        = this.Ab * this.e0 + this.Bb * this.ek0 + ...
                this.Eb * this.ek2;
            this.M_b        = this.Bb * this.e0 + this.Db * this.ek0 + ...
                this.Fb * this.ek2;
            this.P_b        = this.Eb * this.e0 + this.Fb * this.ek0 + ...
                this.Hb * this.ek2;
            
           if (theory == 2 || theory == 3)

               if theory == 3
                   K1       = 1;
               end

               this.Q_s     = K1 * (this.As * this.g0 + this.Ds * this.g2);
               this.R_s     = this.Ds * this.g0 + this.Fs * this.g2;
           end
                
            
            % Matrices of efforts based on all matrices above, see Akavic
            % (2005)
            
            %        [Nxx]
            % N_b =  [Nyy]
            %        [Nxy]
            
            %        [Mxx]
            % M_b =  [Myy]
            %        [Mxy]
            
            %        [Pxx]
            % P_b =  [Pyy]
            %        [Pxy]
            
            % R_s =  [Ryy]
            %        [Rxx]
             
            % Q_s =  [Qyy]
            %        [Qxx]
            
            disp("End   - Class_Effort()             - Effort()");
            disp(" ");
            
        end
        
    end
    
end