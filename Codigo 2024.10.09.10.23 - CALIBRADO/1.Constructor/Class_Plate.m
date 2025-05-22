classdef Class_Plate
    
    % =================================================================== %
    % DESCRIPTION
    
    % This code open the constructor mode, where defines the plate's
    % characteristics. This parameters are about geometrical and phisical
    % characteristics. 
    
    % Variables
    % a:    length for x direction (m)
    % b:    length for y direction (m)
    % c:    damping's coefficient
    % K1:   shear correction factors in the 2-3 and 1-3 planes, 
    %       respectively.
    % m0:   number of parameters in Fourier series
    % n0:   number of parameters in Fourier series
    % xi:   coordinate in x axis that is analyzed
    % yi:   coordinate in y axis that is analyzed
    % SSCC: type of simple support condition (1 for SS1; 2 for SS2; 3 for CC)
    % TNL:  nonlinear period (0 for NOT and 1 for YES)
    %
    % Designing of the plate:
    
%     /_\ Y
%      |
%      |
%      |____________________ (a,b)
%      |                    |
%      |                    |
%      |        (xi,yi)     |
%      |          °         |
%      |                    |
%      |                    |
%      |____________________|___________\ X
%                                       /
    
    % =================================================================== %
    
    %% Public attributes
    properties (SetAccess = public, GetAccess = public)
        
        a               = syms;
        b               = syms;
        
        c               = syms;
        
        K1              = syms;
        
        m0              = syms;
        n0              = syms;
        
        xi              = syms;
        yi              = syms;

        q0              = syms;
        
        SSCC            = syms;
        
        TNL             = syms;
        
    end
    
    %% Constructor method
    methods
        
        % =============================================================== %
        
        % Constructor function
        function this = Class_Plate(a, b, c, K1, m0, n0, xi, yi, ...
                q0, SSCC, TNL)
            
            if (nargin > 0)
                
                this.a              = a;
                this.b              = b;
                
                this.c              = c;
                
                this.K1             = K1;
                
                this.m0             = m0;
                this.n0             = n0;
                                
                this.xi             = xi;
                this.yi             = yi;

                this.q0             = q0;
                
                this.SSCC           = SSCC;
                
                this.TNL            = TNL; 
                
            else

                % ------------------------------ %
                % Data base of Kazanci and Mecitoglu (2008)
                % ------------------------------ %
                 
                this.a             = 0.22;
                this.b             = 0.22;

                this.c             = 0;

                this.K1            = 1;

                this.m0            = 1;
                this.n0            = 1;

                this.xi            = this.a/2;
                this.yi            = this.b/2;

                this.x0             = 1;
                this.xa             = 1;
                this.y0             = 1;
                this.yb             = 1;

                this.SS             = 1;

                this.TNL            = 1; 
                
            end
            
        end
        
    end
    
end