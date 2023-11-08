classdef Class_BoundaryConditions
    
    % =================================================================== %
    % DESCRIPTION
    
    % This class calculates all displacements' and load's expressions for 
    % each type of boundary conditions
    
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
        
        % Create new parameters
        d0                  = sym([]);    % Equations for boundary cond.
        
        qmn                 = syms;       % Fourier parameter for load
        q                   = 0;          % Fourier load
        
    end
        
    %% Public Methods
    methods
        
        function this = Class_BoundaryConditions(plate, analysis, pmt)
            
            if (nargin > 0)
                
                this.pmt = pmt;
                boundary = this.pmt.boundary;
                
                % Functions
                switch boundary
                    case 1
                        this = this.Simple_Support(plate, analysis, pmt);
                    case 2
                        this = this.Clamped(plate, analysis, pmt);
                end
                
                this = this.Load_Plate(plate, pmt);
                
            end
            
        end
        
    end
    
    %% Public Methods
    methods
       
        function this = Simple_Support(this, plate, analysis, pmt)
            
            disp("Start - Class_BoundaryConditions() - Simple_Support()");
            
            % Import parameters from Class_Plate
            this.plate      = plate;
            a               = this.plate.a;
            b               = this.plate.b;
            SS              = this.plate.SS;
            
            % Import parameters from Class_Analysis
            this.analysis   = analysis;
            theory          = this.analysis.theory;
            
            % Import parameters from Class_Parameter
            this.pmt        = pmt;
            coeff_fourier   = this.pmt.coeff_fourier;
            
            % Symbolic General Parameters
            syms x y t m n omg t
            sym(pi)
               
            % Verificating the type of simple supported
            % Displacements and Rotations
            if (theory == 4)
                
                this.d0(1,1) = coeff_fourier(1,1) * ...
                    sin(2 * pi * x / a) * y^2 * (y - b)^2;
                this.d0(2,1) = coeff_fourier(1,2) * ...
                    sin(2 * pi * y / b) * x^2 * (x - a)^2;
                this.d0(3,1) = coeff_fourier(1,3) * ...
                    sin(pi * x / a) * sin(pi * y / b);
                
            else
                
                switch SS
                    
                    case 1 % Cross-ply case
                        
                        this.d0(1,1) = coeff_fourier(1,1) * ...
                            cos(m * pi * x / a) * sin(n * pi * y / b);
                        this.d0(2,1) = coeff_fourier(1,2) * ...
                            sin(m * pi * x / a) * cos(n * pi * y / b);
                        this.d0(3,1) = coeff_fourier(1,3) * ...
                            sin(m * pi * x / a) * sin(n * pi * y / b);
                        
                    case 2 % Angle-ply case
                        
                        this.d0(1,1) = coeff_fourier(1,1) * ...
                            sin(m * pi * x / a) * cos(n * pi * y / b);
                        this.d0(2,1) = coeff_fourier(1,2) * ...
                            cos(m * pi * x / a) * sin(n * pi * y / b);
                        this.d0(3,1) = coeff_fourier(1,3) * ...
                            sin(m * pi * x / a) * sin(n * pi * y / b);
                        
                end
                
            end
            
            % Rotations
            % If the option of analysis is CLPT (parameter = 1), this
            % case does not calculate tx_0 and ty_0.
            if (theory == 1 || theory == 4)
                % Do nothing
            else
                this.d0(4,1)        = coeff_fourier(1,4) * ...
                    cos(m * pi * x / a) * sin(n * pi * y / b);
                this.d0(5,1)        = coeff_fourier(1,5) * ...
                    sin(m * pi * x / a) * cos(n * pi * y / b);
            end
            
            disp("End   - Class_BoundaryConditions() - Simple_Support()");
            disp(" ");
            
        end
        
        % =============================================================== %
        
        function this = Clamped(this, plate, analysis, pmt)
           
            disp("Start - Class_BoundaryConditions() - Clamped()");
            
            % Import parameters from Class_Plate
            this.plate          = plate;
            a                   = this.plate.a;
            b                   = this.plate.b;
            
            % Import parameters from Class_Analysis
            this.analysis       = analysis;
            theory              = this.analysis.theory;
            
            % Import parameters from Class_Parameter
            this.pmt            = pmt;
            coeff_fourier       = this.pmt.coeff_fourier;
            
            % Symbolic General Parameters
            syms x y t m n
            
            % Displacements and Rotations
            if (theory == 4)
                
                this.d0(1,1) = coeff_fourier(1,1) * ...
                    (1 - cos(2 * pi * y / b)) * ...
                    x^2 * (x - a)^2 * (x - (a/2));
                
                this.d0(2,1) = coeff_fourier(1,2) * ...
                    (1 - cos(2 * pi * x / a)) * ...
                    y^2 * (y - b)^2 * (y - (b/2));
                
                this.d0(3,1) = coeff_fourier(1,3) * ...
                    (1 - cos(2 * pi * x / a)) * ...
                    (1 - cos(2 * pi * y / b));
            else
                %this.u_0    = coeff_fourier(1,1) * cos(X) * sin(Y);
                %this.v_0    = coeff_fourier(1,2) * sin(X) * cos(Y);
                %this.w_0    = coeff_fourier(1,3) * sin(X) * sin(Y);
            end
            
            % Rotations
            % If the option of analysis is CLPT (parameter = 1), this
            % case does not calculate tx_0 and ty_0.
            if (theory == 1 || theory == 4)
                % Do nothing
            else
                %this.tx_0   = coeff_fourier(1,4) * cos(X) * sin(Y);
                %this.ty_0   = coeff_fourier(1,5) * sin(X) * cos(Y);
            end
            
            disp("End   - Class_BoundaryConditions() - Clamped()");
            disp(" ");
            
        end
        
        % =============================================================== %
        
        % Final Equations of load
        function this = Load_Plate(this, plate, pmt)
            
            disp("Start - Class_BoundaryConditions() - Load_Plate()");
                        
            % Import parameters from Class_Plate
            this.plate      = plate;
            a               = this.plate.a;
            b               = this.plate.b;
            m0              = this.plate.m0;
            n0              = this.plate.n0;
            q0              = this.plate.q0;
            
            % Import parameters from Class_Parameter
            this.pmt        = pmt;
            boundary        = this.pmt.boundary;
            
            % Symbolic General Parameters
            syms x y t m n P
            
            % See this in Mendonça (2019), equation (12.12) - Uniform load
            if (mod(m0,2) == 0 || mod(n0,2) == 0)
                this.qmn    = 0;
%             elseif (m0 == 1 && n0 == 1)
%                 % Sinusoidal case
%                 this.qmn    = q0;
            else
                this.qmn    = 16 * P / (m * n * pi^2);
            end
            
            switch boundary
                
                case 1 % 
                    
                    this.q  = subs(this.qmn * sin(m * pi * x / a) * ...
                        sin(n * pi * y / b), [m n], [1 1]);
                    
                case 2
                    
                    this.q  = subs(this.qmn * sin(m * pi * x / a)^2 * ...
                        sin(n * pi * y / b)^2, [m n], [1 1]);
                    
            end
            
            disp("End   - Class_BoundaryConditions() - Load_Plate()");
            disp(" ");
            
        end
        
    end
    
end