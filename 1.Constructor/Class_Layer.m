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
        
        % Import parameters from Class_Plate
        plate           Class_Plate
        
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
                % Data base of Reddy (1984)
                % ------------------------------ %
                
%                 this.num_layer      = 2;
%                 
%                 for i = 1 : this.num_layer
%                     
%                     this.hl(i,1)    = 1 / 5 / this.num_layer;
%                     this.rho(i,1)   = 1600;
%                     this.E2(i,1)    = 1 * 10^9;
%                     this.E1(i,1)    = 40 * this.E2(i,1);
%                     this.G12(i,1)   = 0.6 * this.E2(i,1);
%                     this.G13(i,1)   = 0.6 * this.E2(i,1);
%                     this.G23(i,1)   = 0.5 * this.E2(i,1);
%                     this.nu12(i,1)  = 0.25;
%                     this.nu21(i,1)  = this.E2(i,1) * this.nu12(i,1)/ ...
%                         this.E1(i,1);
%                     
%                 end
%                 
%                 this.theta(1,1)     = 0;
%                 this.theta(2,1)     = pi/2;
%                 this.theta(3,1)     = pi/2;
%                 this.theta(4,1)     = 0;
                
%                 this.theta(1,1)     = -pi/4;
%                 this.theta(2,1)     = pi/4;

                % ------------------------------ %
                % Data base of Libresco and Nosier (1990)
                % ------------------------------ %
                
                % Structure I
                
%                 this.num_layer      = 3;
%                 
%                 for i = 1 : this.num_layer
%                     
%                     this.rho(i,1)   = 1389.31;
%                     this.nu12(i,1)  = 0.24;
%                     this.nu21(i,1)  = 0.0195;
%                     this.E1(i,1)    = 19.2 * 10^6 * 6894.76;
%                     this.E2(i,1)    = 1.56 * 10^6 * 6894.76;
%                     this.G12(i,1)   = 0.82 * 10^6 * 6894.76;
%                     this.G13(i,1)   = 0.82 * 10^6 * 6894.76;
%                     this.G23(i,1)   = 0.523 * 10^6 * 6894.76;
%                     
%                 end
%                 
%                 this.hl(1,1)        = (100/15)/4 * 0.0254;
%                 this.hl(2,1)        = 2 *(100/15)/4 * 0.0254;
%                 this.hl(3,1)        = (100/15)/4 * 0.0254;
%                 
%                 this.theta(1,1)     = 0;
%                 this.theta(2,1)     = pi/2;
%                 this.theta(3,1)     = 0;

                % Structure II
                
%                 this.num_layer      = 8;
%                 
%                 for i = 1 : this.num_layer
%                     
%                     this.rho(i,1)   = 1389.31;
%                     this.nu12(i,1)  = 0.25;
%                     this.nu21(i,1)  = 0.025;
%                     this.E1(i,1)    = 30 * 10^6;
%                     this.E2(i,1)    = 3 * 10^6;
%                     this.G12(i,1)   = 1.5 * 10^6;
%                     this.G13(i,1)   = 1.5 * 10^6;
%                     this.G23(i,1)   = 0.6 * 10^6;
%                     this.hl(i,1)    = 1 / this.num_layer;
%                 end
%                 
%                 this.theta(1,1)     = 0;
%                 this.theta(2,1)     = pi/2;
%                 this.theta(3,1)     = 0;
%                 this.theta(4,1)     = pi/2;
%                 this.theta(5,1)     = 0;
%                 this.theta(6,1)     = pi/2;
%                 this.theta(7,1)     = 0;
%                 this.theta(8,1)     = pi/2;

                % ------------------------------ %
                % Data base of Hause and Librescu (2005)
                % ------------------------------ %
                
%                 this.num_layer      = 11;
%                 
%                 for i = 1 : this.num_layer
%                     
%                     this.hl(i,1)    = 0.075 * 0.0254 / 5 ;
%                     this.rho(i,1)   = 1.5282 * 10^3 ;
%                     this.nu12(i,1)  = 0.25;
%                     this.nu21(i,1)  = 0.25;
%                     this.E1(i,1)    = 20.68 * 10^10;
%                     this.E2(i,1)    = 5.17 * 10^9;
%                     this.G12(i,1)   = 2.55 * 10^9;
%                     this.G13(i,1)   = 2.55 * 10^9;
%                     this.G23(i,1)   = 2.55 * 10^9;
%                     
%                 end
%                 
%                 this.hl(6,1)    = 0.5 * 0.0254;
%                 this.rho(6,1)   = 15.9984;
%                 this.nu12(6,1)  = 0.35;
%                 this.nu21(6,1)  = 0.35;
%                 this.E1(6,1)    = 6.8948 * 10^10;
%                 this.E2(6,1)    = 6.8948 * 10^10;
%                 this.G12(6,1)   = 1.027317 * 10^8;
%                 this.G13(6,1)   = 1.027317 * 10^8;
%                 this.G23(6,1)   = 62052703.429446;
%                     
%                 this.theta(1,1)     = pi/4;
%                 this.theta(2,1)     = -pi/4;
%                 this.theta(3,1)     = pi/4;
%                 this.theta(4,1)     = -pi/4;
%                 this.theta(5,1)     = pi/4;
%                 this.theta(6,1)     = 0;    
%                 this.theta(7,1)     = pi/4;
%                 this.theta(8,1)     = -pi/4;
%                 this.theta(9,1)     = pi/4;
%                 this.theta(10,1)     = -pi/4;
%                 this.theta(11,1)     = pi/4;
                 
                % ------------------------------ %
                % Data base of Wei and Dharani (2006)
                % ------------------------------ %
                
%                 this.num_layer  = 3;
%                 
%                 this.hl(1,1)    = 4.76 * 0.001;
%                 this.rho(1,1)   = 2500;
%                 this.nu12(1,1)  = 0.25;
%                 this.nu21(1,1)  = 0.25;
%                 this.E1(1,1)    = 72*10^9;
%                 this.E2(1,1)    = 72*10^9;
%                 this.G12(1,1)   = this.E1(1,1)/2/(1+this.nu12(1,1));
%                 this.G13(1,1)   = this.E1(1,1)/2/(1+this.nu12(1,1));
%                 this.G23(1,1)   = this.E1(1,1)/2/(1+this.nu12(1,1));
%                 
%                 this.hl(2,1)    = 1.52 * 0.001;
%                 this.rho(2,1)   = 1100;
%                 this.nu12(2,1)  = 0.4918;
%                 this.nu21(2,1)  = 0.4918;
%                 this.E1(2,1)    = 0.98*10^9;
%                 this.E2(2,1)    = 0.98*10^9;
%                 this.G12(2,1)   = 0.33*10^9;
%                 this.G13(2,1)   = 0.33*10^9;
%                 this.G23(2,1)   = 0.33*10^9;
%                 
%                 this.hl(3,1)    = 4.76 * 0.001;
%                 this.rho(3,1)   = 2500;
%                 this.nu12(3,1)  = 0.25;
%                 this.nu21(3,1)  = 0.25;
%                 this.E1(3,1)    = 72*10^9;
%                 this.E2(3,1)    = 72*10^9;
%                 this.G12(3,1)   = this.E1(3,1)/2/(1+this.nu12(3,1));
%                 this.G13(3,1)   = this.E1(3,1)/2/(1+this.nu12(3,1));
%                 this.G23(3,1)   = this.E1(3,1)/2/(1+this.nu12(3,1));
%                     
%                 this.theta(1,1) = 0;
%                 this.theta(2,1) = 0;
%                 this.theta(3,1) = 0;

                % ------------------------------ %
                % Data base of Kazanci (2017)
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
                
                this.theta(1,1)     = pi/2;
                this.theta(2,1)     = 0;
                this.theta(3,1)     = pi/2;
                this.theta(4,1)     = 0;
                this.theta(5,1)     = pi/2;
                this.theta(6,1)     = 0;
                this.theta(7,1)     = pi/2;
                
                % ------------------------------ %
                % Data base of Kazanci and Mecitoglu (2008)
                % Data base of Kazanci et al. (2004)
                % ------------------------------ %
                
%                 this.num_layer      = 7;
%                 
%                 for i = 1 : this.num_layer
%                     
%                     this.hl(i,1)    = 1.96 * 0.001 / this.num_layer;
%                     this.rho(i,1)   = 1800;
%                     this.nu12(i,1)  = 0.11;
%                     this.nu21(i,1)  = 0.11;
%                     this.E1(i,1)    = 24.14*10^9;
%                     this.E2(i,1)    = 24.14*10^9;
%                     this.G12(i,1)   = 3.79*10^9;
%                     this.G13(i,1)   = 3.79*10^9;
%                     this.G23(i,1)   = 3.79*10^9;
%                     
%                 end
%                 
%                 this.theta(1,1)     = 0;
%                 this.theta(2,1)     = pi/2;
%                 this.theta(3,1)     = 0;
%                 this.theta(4,1)     = pi/2;
%                 this.theta(5,1)     = 0;
%                 this.theta(6,1)     = pi/2;
%                 this.theta(7,1)     = 0;
                
                % ------------------------------ %
                % Data base of Upadhyay et al (2011)
                % ------------------------------ %
                
%                 this.num_layer      = 3;
%                 
%                 for i = 1 : this.num_layer
%                     
%                     this.hl(i,1)    = 0.0425;
%                     this.rho(i,1)   = 1443;
%                     this.nu12(i,1)  = 0.24;
%                     this.nu21(i,1)  = 0.0196;
%                     this.E1(i,1)    = 132.4 * 10^9;
%                     this.E2(i,1)    = 10.8 * 10^9;
%                     this.G12(i,1)   = 5.6 * 10^9;
%                     this.G13(i,1)   = 5.6 * 10^9;
%                     this.G23(i,1)   = 5.6 * 10^9;
%                     
%                 end
%                 
%                 this.hl(2,1)    = 0.085;
%                     
%                 this.theta(1,1)     = 0;
%                 this.theta(2,1)     = pi/2;
%                 this.theta(3,1)     = 0;
                
                % ------------------------------ %
                % Data base of Susler et al (2012)
                % ------------------------------ %
%                 
%                 this.num_layer      = 6;
%                 
%                 for i = 1 : this.num_layer
%                     
%                     this.hl(i,1)    = 0.002 / this.num_layer;
%                     
%                     if (i == 1 || i == 2)
%                         
%                         this.rho(i,1)   = 1620;
%                         this.nu12(i,1)  = 0.318;
%                         this.nu21(i,1)  = 0.0217;
%                         this.E1(i,1)    = 135.14 * 10^9;
%                         this.E2(i,1)    = 9.24 * 10^9;
%                         this.G12(i,1)   = 6.27 * 10^9;
%                         this.G13(i,1)   = 6.27 * 10^9;
%                         this.G23(i,1)   = 0 * 10^9;
%                         this.theta(i,1) = 0;
%                         
%                     elseif (i == 3 || i == 4)
%                         
%                         this.rho(i,1)   = 1910;
%                         this.nu12(i,1)  = 0.115;
%                         this.nu21(i,1)  = 0.115;
%                         this.E1(i,1)    = 23.37 * 10^9;
%                         this.E2(i,1)    = 23.37 * 10^9;
%                         this.G12(i,1)   = 5.23 * 10^9;
%                         this.G13(i,1)   = 5.23 * 10^9;
%                         this.G23(i,1)   = 5.23 * 10^9;
%                         this.theta(i,1) = 0;
%                                                 
%                     elseif (i == 5 || i == 6)
%                         
%                         this.rho(i,1)   = 1450;
%                         this.nu12(i,1)  = 0.059;
%                         this.nu21(i,1)  = 0.059;
%                         this.E1(i,1)    = 62.74 * 10^9;
%                         this.E2(i,1)    = 62.74 * 10^9;
%                         this.G12(i,1)   = 4.37 * 10^9;
%                         this.G13(i,1)   = 4.37 * 10^9;
%                         this.G23(i,1)   = 4.37 * 10^9;
%                         this.theta(i,1) = 0;
%                                                 
%                     end
%                     
%                 end
                                
                % ------------------------------ %
                % Data base of Amibili (2020)
                % ------------------------------ %
                
%                 this.num_layer  = 3;
%                 
%                 this.hl(1,1)    = 12 * 0.001;
%                 this.rho(1,1)   = 2500;
%                 this.nu12(1,1)  = 0.22;
%                 this.nu21(1,1)  = this.nu12(1,1);
%                 this.E1(1,1)    = 70*10^9;
%                 this.E2(1,1)    = this.E1(1,1);
%                 this.G12(1,1)   = this.E1(1,1)/2/(1+this.nu12(1,1));
%                 this.G13(1,1)   = this.E1(1,1)/2/(1+this.nu12(1,1));
%                 this.G23(1,1)   = this.E1(1,1)/2/(1+this.nu12(1,1));
%                 
%                 this.hl(2,1)    = 1.52 * 0.001;
%                 this.rho(2,1)   = 1080;
%                 this.nu12(2,1)  = 0.476;
%                 this.nu21(2,1)  = this.nu12(2,1);
%                 this.E1(2,1)    = 1.1*10^9;
%                 this.E2(2,1)    = this.E1(2,1);
%                 this.G12(2,1)   = this.E1(2,1)/2/(1+this.nu12(2,1));
%                 this.G13(2,1)   = this.E1(2,1)/2/(1+this.nu12(2,1));
%                 this.G23(2,1)   = this.E1(2,1)/2/(1+this.nu12(2,1));
%                 
%                 this.hl(3,1)    = 12 * 0.001;
%                 this.rho(3,1)   = 2500;
%                 this.nu12(3,1)  = 0.22;
%                 this.nu21(3,1)  = this.nu12(3,1);
%                 this.E1(3,1)    = 70*10^9;
%                 this.E2(3,1)    = this.E1(3,1);
%                 this.G12(3,1)   = this.E1(3,1)/2/(1+this.nu12(3,1));
%                 this.G13(3,1)   = this.E1(3,1)/2/(1+this.nu12(3,1));
%                 this.G23(3,1)   = this.E1(3,1)/2/(1+this.nu12(3,1));
%                     
%                 this.theta(1,1)     = 0;
%                 this.theta(2,1)     = 0;
%                 this.theta(3,1)     = 0;

            end
            
        end
        
    end
    
end