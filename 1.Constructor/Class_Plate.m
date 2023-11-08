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
    % x0:   type of boundary condition in x = 0
    % y0:   type of boundary condition in y = 0
    % xa:   type of boundary condition in x = a
    % yb:   type of boundary condition in y = b
    % SS:   type of simple support condition (1 for SS1; 2 for SS2)
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
        
        x0              = syms;
        xa              = syms;
        y0              = syms;
        yb              = syms;
        
        q0              = syms;
        
        SS              = syms;
        
        TNL             = syms;
        
    end
    
    %% Constructor method
    methods
        
        % =============================================================== %
        
        % Constructor function
        function this = Class_Plate(a, b, c, K1, m0, n0, xi, yi, ...
                x0, xa, y0, yb, q0, SS, TNL)
            
            if (nargin > 0)
                
                this.a              = a;
                this.b              = b;
                
                this.c              = c;
                
                this.K1             = K1;
                
                this.m0             = m0;
                this.n0             = n0;
                                
                this.xi             = xi;
                this.yi             = yi;
                
                this.x0             = x0;
                this.xa             = xa;
                this.y0             = y0;
                this.yb             = yb;
                
                this.q0             = q0;
                
                this.SS             = SS;
                
                this.TNL            = TNL; 
                
            else

                % ------------------------------ %
                % Data base of Reddy (1984)
                % ------------------------------ %
                
%                 this.a             = 1;
%                 this.b             = 1;
%                 
%                 this.c             = 0;
%                 
%                 this.K1            = 5/6;
%                 
%                 this.m0            = 1;
%                 this.n0            = 1;
%                 
%                 this.xi            = this.a/2;
%                 this.yi            = this.b/2;
%                 
%                 this.x0             = 1;
%                 this.xa             = 1;
%                 this.y0             = 1;
%                 this.yb             = 1;
% 
%                 this.q0             = 1;
%                 
%                 this.SS             = 1;
                
                % ------------------------------ %
                % Data base of Librescu and Nosier (1990)
                % ------------------------------ %
                
%                 this.a             = 2.54;
%                 this.b             = 2.54;
%                 
%                 this.c             = 0;
%                 
%                 this.K1            = 1;
%                 
%                 this.m0            = 1;
%                 this.n0            = 1;
%                 
%                 this.xi            = this.a/2;
%                 this.yi            = this.b/2;
%                 
%                 this.x0             = 1;
%                 this.xa             = 1;
%                 this.y0             = 1;
%                 this.yb             = 1;
%                 
%                 this.SS             = 1;
%                 
%                 this.TNL            = 1; 
                
                % ------------------------------ %
                % Data base of Hause and Librescu (2005)
                % ------------------------------ %
                
%                 this.a             = 0.6096;
%                 this.b             = 0.6096;
%                 
%                 this.c             = 58.0024;
%                 
%                 this.K1            = 1;
%                 
%                 this.m0            = 1;
%                 this.n0            = 1;
%                 
%                 this.xi            = this.a/2;
%                 this.yi            = this.b/2;
%                 
%                 this.x0             = 1;
%                 this.xa             = 1;
%                 this.y0             = 1;
%                 this.yb             = 1;
%                 
%                 this.SS             = 2;
%                 
%                 this.TNL            = 1;                
                
                % ------------------------------ %
                % Data base of Wei and Dharani (2006)
                % ------------------------------ %
                
%                 this.a             = 1.325;
%                 this.b             = 1.325;
%                 
%                 this.c             = 0;
%                 
%                 this.K1            = 1;
%                 
%                 this.m0            = 1;
%                 this.n0            = 1;
%                 
%                 this.xi            = this.a/2;
%                 this.yi            = this.b/2;
%                 
%                 this.x0             = 1;
%                 this.xa             = 1;
%                 this.y0             = 1;
%                 this.yb             = 1;
%                 
%                 this.SS             = 1;
%                 
%                 this.TNL            = 1; 
                
                % ------------------------------ %
                % Data base of Kazanci (2017)
                % ------------------------------ %
                 
                this.a             = 0.22;
                this.b             = 0.22;
                
                this.c             = 0;
                
                this.K1            = 1;
                
                this.m0            = 1;
                this.n0            = 1;
                
                this.xi            = this.a/2;
                this.yi            = this.b/2;
                
                this.x0             = 2;
                this.xa             = 2;
                this.y0             = 2;
                this.yb             = 2;
                
                this.SS             = 1;
                
                this.TNL            = 1; 

                % ------------------------------ %
                % Data base of Kazanci and Mecitoglu (2008)
                % Data base of Kazanci et al. (2004)
                % ------------------------------ %
                 
%                 this.a             = 0.22;
%                 this.b             = 0.22;
%                 
%                 this.c             = 0;
%                 
%                 this.K1            = 1;
%                 
%                 this.m0            = 1;
%                 this.n0            = 1;
%                 
%                 this.xi            = this.a/2;
%                 this.yi            = this.b/2;
%                 
%                 this.x0             = 1;
%                 this.xa             = 1;
%                 this.y0             = 1;
%                 this.yb             = 1;
%                 
%                 this.SS             = 1;
%                 
%                 this.TNL            = 1; 
                
                % ------------------------------ %
                % Data base of Upadhyay et al (2011)
                % ------------------------------ %
                
%                 this.a             = 2.54;
%                 this.b             = 2.54;
%                 
%                 this.c             = 0;
%                 
%                 this.K1            = 1;
%                 
%                 this.m0            = 1;
%                 this.n0            = 1;
%                 
%                 this.xi            = this.a/2;
%                 this.yi            = this.b/2;
%                 
%                 this.x0             = 1;
%                 this.xa             = 1;
%                 this.y0             = 1;
%                 this.yb             = 1;
%                 
%                 this.SS             = 1;
%                 
%                 this.TNL            = 1;                
                
                % ------------------------------ %
                % Data base of Susler et al (2012)
                % ------------------------------ %
                
%                 this.a             = 0.22;
%                 this.b             = 0.22;
%                 
%                 this.c             = 0;
%                 
%                 this.K1            = 1;
%                 
%                 this.m0            = 1;
%                 this.n0            = 1;
%                 
%                 this.xi            = this.a/2;
%                 this.yi            = this.b/2;
%                 
%                 this.x0             = 1;
%                 this.xa             = 1;
%                 this.y0             = 1;
%                 this.yb             = 1;
%                 
%                 this.SS             = 1;
%                 
%                 this.TNL            = 1;                
%                 
                % ------------------------------ %
                % Data base of Amibili (2020)
                % ------------------------------ %
                
%                 this.a             = 2;
%                 this.b             = 2;
%                 
%                 this.c             = 108.5775;
%                 
%                 this.K1            = 1;
%                 
%                 this.m0            = 1;
%                 this.n0            = 1;
%                 
%                 this.xi            = this.a/2;
%                 this.yi            = this.b/2;
%                 
%                 this.x0             = 1;
%                 this.xa             = 1;
%                 this.y0             = 1;
%                 this.yb             = 1;
%                 
%                 this.SS             = 1;
%                 
%                 this.TNL            = 1;
                
            end
        end
        
    end
    
end