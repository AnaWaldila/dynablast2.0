classdef Class_Layer
    
    % =================================================================== %
    % DESCRIPTION
    
    % This code open the constructor mode, where defines the layer's
    % characteristics. This parameters are about geometrical and phisical
    % characteristics.
    
    % Variables
    % num_layer:        numbers of layers
    % hl:               thickness for each layer
    % rho:              material's density (kg/m³)
    % theta:            fiber orientation
    % nu12 and nu21:    coefficients of Poisson
    % E1 and E2:        Young's modulus (N/m²)
    % G12, G13 and G23: Shear Moduli
    
    % =================================================================== %
    
    %% Public attributes
    properties (SetAccess = public, GetAccess = public)
        
        % Create new parameters
        num_layer       = 0;
        hl              = sym([]);
        rho             = sym([]);
        theta           = sym([]);
        nu12            = sym([]);
        nu21            = sym([]);
        E1              = sym([]);
        E2              = sym([]);
        G12             = sym([]);
        G13             = sym([]);
        G23             = sym([]);
        
    end
    
    %% Constructor method
    
    methods
        
        % Constructor function
        function this = Class_Layer(num_layer, h1, rho, theta, nu12, ...
                nu21, E1, E2, G12, G13, G23)
            
            if (nargin > 0)
                
                this.num_layer  = num_layer;
                this.hl         = h1;
                this.rho        = rho;
                this.theta      = theta;
                this.nu12       = nu12;
                this.nu21       = nu21;
                this.E1         = E1;
                this.E2         = E2;
                this.G12        = G12;
                this.G13        = G13;
                this.G23        = G23;
                
            else

                % ------------------------------ %
                % Data base of Kazanci and Mecitoglu (2008)
                % ------------------------------ %
                
                this.num_layer      = 7;

                for i = 1 : this.num_layer

                    this.hl(i,1)    = 1.96 * 0.001 / this.num_layer;
                    this.rho(i,1)   = 1800;
                    this.nu12(i,1)  = 0.11;
                    this.nu21(i,1)  = 0.11;
                    this.E1(i,1)    = 24.14*10^9;
                    this.E2(i,1)    = 24.14*10^9;
                    this.G12(i,1)   = 3.79*10^9;
                    this.G13(i,1)   = 3.79*10^9;
                    this.G23(i,1)   = 3.79*10^9;

                end

                this.theta(1,1)     = 0;
                this.theta(2,1)     = pi/2;
                this.theta(3,1)     = 0;
                this.theta(4,1)     = pi/2;
                this.theta(5,1)     = 0;
                this.theta(6,1)     = pi/2;
                this.theta(7,1)     = 0;
                
            end
            
        end
        
    end
    
end