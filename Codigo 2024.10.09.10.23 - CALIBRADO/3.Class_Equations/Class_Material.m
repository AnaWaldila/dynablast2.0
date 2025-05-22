classdef Class_Material
    
    % =================================================================== %
    % DESCRIPTION
    
    % This class calculate basicaly parameters from stiffness matrix.
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
        layer       Class_Layer
        
        % Create new parameters
        h           = 0;                % Total height in a plate
        
        zi          = sym([]);          % Matrix about z coordinate for
                                        % each layer
        Qij         = sym([]);          % Parameters of reduced stiffnesses
        Q           = sym([]);          % Stiffness matrix
        Qb          = sym([]);          % Stiffness matrix of bending
        Qs          = sym([]);          % Stiffness matrix of shear
                       
    end
    
    %% Public Methods
    methods
        
        function this = Class_Material(layer)
            
            if (nargin > 0)
                
                % Functions
                this = this.Height(layer);
                this = this.Layer_zi(layer);
                this = this.Matrix_Qij(layer);
                this = this.Matrix_Q(layer);
                this = this.Matrix_Qb(layer);
                this = this.Matrix_Qs(layer);
                
            end
            
        end
        
    end
    
    %% Public Methods for Functions
    methods
        
        % Function to calculate the total height in a plate
        function this = Height(this,layer)
            
            disp("Start - Class_Material()           - Height()");
            
            % Import parameters from Class_Layer
            this.layer  = layer;
            num_layer   = this.layer.num_layer;
            hl          = this.layer.hl;
            
            for i = 1: num_layer
               this.h   = this.h + hl(i,1);
            end
            
            disp("End   - Class_Material()           - Height()");
            disp(" ");
            
        end
        
        % =============================================================== %
        
        % Function to calculate coordinates zi in laminated plate
        function this = Layer_zi(this, layer)
            
            disp("Start - Class_Material()           - Layer_zi()");
            
            % Import parameters from Class_Layer
            this.layer          = layer;
            num_layer           = this.layer.num_layer;
            hl                  = this.layer.hl;
                        
            this.zi(1,1)        = this.h * (1/2);
            
            for i = 2 : (num_layer + 1)
                
                this.zi(i,1)    = (this.zi(i-1,1) - hl(i-1,1));
                
            end
            
            this.zi             = (-1) * this.zi;
            
            disp("End   - Class_Material()           - Layer_zi()");
            disp(" ");
            
        end
        
        % =============================================================== %
        
        % Parameters Qij of Constitutive Matrix (considerating local axis)
        function this = Matrix_Qij(this, layer)
            
            disp("Start - Class_Material()           - Matrix_Qij()");
            
            % Import parameters from Class_Layer
            this.layer  = layer;
            num_layer   = this.layer.num_layer;
            
            E1          = this.layer.E1;
            E2          = this.layer.E2;
            G12         = this.layer.G12;
            G13         = this.layer.G13;
            G23         = this.layer.G23;
            nu12        = this.layer.nu12;
            nu21        = this.layer.nu21;

            % For each layer, it is necessary to create a new matrix Qij
            % So, in this case, it is a matrix of matrices. The third
            % parameter in Qij(:,:,i) represents the coordinate of the
            % layer
            
            for i = 1 : num_layer
                
                % Matrix of matrices about sttifness (all layers)
                % Local axis
                this.Qij(1,1,i) = E1(i,1) / (1 - nu12(i,1) * nu21(i,1));
                
                this.Qij(1,2,i) = nu12(i,1) * E2(i,1) / ...
                    (1 - nu12(i,1) * nu21(i,1));
                
                this.Qij(2,1,i) = this.Qij(1,2,i);
                
                this.Qij(2,2,i) = E2(i,1) / (1 - nu12(i,1) * nu21(i,1));
                
                this.Qij(4,4,i) = G23(i,1);
                
                this.Qij(5,5,i) = G13(i,1);
                
                this.Qij(6,6,i) = G12(i,1);
                
            end
            
            disp("End   - Class_Material()           - Matrix_Qij()");
            disp(" ");
            
        end
        
        % =============================================================== %
        
        % Constitutive Matrix (considerating global axis)
        function this = Matrix_Q(this, layer)
            
            disp("Start - Class_Material()           - Matrix_Q()");
            
            % Import parameters from Class_Layer
            this.layer  = layer;
            num_layer   = this.layer.num_layer;
            theta       = this.layer.theta;
            
            % For each layer, it is necessary to create a new matrix Qij
            % So, in this case, it is a matrix of matrices. The third
            % parameter in Qij(:,:,i) represents the coordinate of the
            % layer
            
            for i = 1 : num_layer
                
                c             = cos(theta(i,1));
                s             = sin(theta(i,1));
                
                % Matrix of stiffness - Bending stiffness
                this.Q(1,1,i) = this.Qij(1,1,i) * c^4 + ...
                    this.Qij(2,2,i) * s^4 + 2 * (this.Qij(1,2,i) + ...
                    2 * this.Qij(6,6,i)) * s^2 * c^2;
                
                this.Q(1,2,i) = (this.Qij(1,1,i) + this.Qij(2,2,i) - ...
                    4 * this.Qij(6,6,i)) * s^2 * c^2 + ...
                    this.Qij(1,2,i) * (c^4 + s^4);
                
                this.Q(1,6,i) = (this.Qij(1,1,i) - this.Qij(1,2,i) - ...
                    2 * this.Qij(6,6,i)) * c^3 * s - (this.Qij(2,2,i) - ...
                    this.Qij(1,2,i) - 2 * this.Qij(6,6,i)) * s^3 * c;
                
                
                this.Q(2,1,i) = this.Q(1,2,i);
                
                this.Q(2,2,i) = this.Qij(1,1,i) * s^4 + ...
                    this.Qij(2,2,i) * c^4 + 2 * (this.Qij(1,2,i) + ...
                    2 * this.Qij(6,6,i)) * s^2 * c^2;
                
                this.Q(2,6,i) = (this.Qij(1,1,i) - this.Qij(1,2,i) - ...
                    2 * this.Qij(6,6,i)) * c * s^3 - (this.Qij(2,2,i) - ...
                    this.Qij(1,2,i) - 2 * this.Qij(6,6,i)) * c^3 * s;
                
                
                this.Q(6,1,i) = this.Q(1,6,i);
                
                this.Q(6,2,i) = this.Q(2,6,i);
                
                this.Q(6,6,i) = (this.Qij(1,1,i) + this.Qij(2,2,i) - ...
                    2* this.Qij(1,2,i) - 2 * this.Qij(6,6,i)) * ...
                    s^2 * c^2 + this.Qij(6,6,i) * (s^4 + c^4);
                
                % Matrix of stiffness - Shear stiffness
                this.Q(4,4,i) = this.Qij(4,4,i) * c^2 + ...
                    this.Qij(5,5,i) * s^2;
                
                this.Q(4,5,i) = (this.Qij(5,5,i) - ...
                    this.Qij(4,4,i)) * c * s;
                
                this.Q(5,4,i) = this.Q(4,5,i);
                
                this.Q(5,5,i) = this.Qij(5,5,i) * c^2 + ...
                    this.Qij(4,4,i) * s^2;
                
            end
            
            disp("End   - Class_Material()           - Matrix_Q()");
            disp(" ");
            
        end
        
        % =============================================================== %
        
        % Constitutive Matrix (considerating global axis) for bending
        function this = Matrix_Qb(this, layer)
            
            disp("Start - Class_Material()           - Matrix_Qb()");
            
            % Import parameters from Class_Layer
            this.layer  = layer;
            num_layer   = this.layer.num_layer;
            
            % For each layer, it is necessary to create a new matrix Qb
            % So, in this case, it is a matrix of matrices. The third
            % parameter in Qb(:,:,i) represents the coordinate of the
            % layer
            for i = 1 : num_layer
                
                this.Qb(1,1,i) = this.Q(1,1,i);
                this.Qb(1,2,i) = this.Q(1,2,i);
                this.Qb(1,3,i) = this.Q(1,6,i);
                
                this.Qb(2,1,i) = this.Q(1,2,i);
                this.Qb(2,2,i) = this.Q(2,2,i);
                this.Qb(2,3,i) = this.Q(2,6,i);
                
                this.Qb(3,1,i) = this.Q(1,6,i);
                this.Qb(3,2,i) = this.Q(2,6,i);
                this.Qb(3,3,i) = this.Q(6,6,i);
                
            end
            
            disp("End   - Class_Material()           - Matrix_Qb()");
            disp(" ");
            
        end
        
        % =============================================================== %
        
        % Constitutive Matrix (considerating global axis) for bending
        function this = Matrix_Qs(this, layer)
            
            disp("Start - Class_Material()           - Matrix_Qs()");
            
            % Import parameters from Class_Layer
            this.layer  = layer;
            num_layer   = this.layer.num_layer;
            
            % For each layer, it is necessary to create a new matrix Qs
            % So, in this case, it is a matrix of matrices. The third
            % parameter in Qs(:,:,i) represents the coordinate of the
            % layer
            for i = 1 : num_layer
                
                this.Qs(1,1,i) = this.Q(4,4,i);
                this.Qs(1,2,i) = this.Q(4,5,i);
                this.Qs(2,1,i) = this.Q(4,5,i);
                this.Qs(2,2,i) = this.Q(5,5,i);
                
            end
            
            disp("End   - Class_Material()           - Matrix_Qs()");
            disp(" ");
            
        end
        
    end
        
end
