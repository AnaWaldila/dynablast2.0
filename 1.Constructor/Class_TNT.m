classdef Class_TNT

    % =================================================================== %
    % DESCRIPTION
    
    % This class is to construct the TNT parameters. Characteristics like
    % scalar distance, weight an type of explosion are presents here.
    % Considering the negative phase or not is presents.
    
    % Variables
    % sup:      type of support (0 for simple support and 1 for campled)
    % type_sup: type of support of membrane (1 for immovable, 2 for movable
    %           and 3 for stress free)
    % phase:    phase for analisys (1 for positive phase, 2 for negative 
    %           phase, 3 for free vibration)
    % type:     type of explosion (1 for Hemispherical and 2 for Spherical)
    % Z:        Scale distance (kg/m^1/3)
    % W:        TNT's mass (kg)
    % time:     time of analisys (s)
    % db_pamx:  Sobrepressure experimental data
    % db_pmin:  Underpressure experimental data
    % db_td:    positive time (positive phase) experimental data
    % db_tm:    negative time (negative phase) experimental data
    % db_id:    positive impulse (positive phase) experimental data
    % equation: 
    % 1 for 'Friedlander + Cubic Equation - Rigby Calibration', 
    % 2 for 'Friedlander + Cubic Equation (calculate tm) - Rigby Calibration', 
    % 3 for 'Friedlander + Cubic Equation (calculate tm) - Ana Calibration'  
    % 4 for 'Friedlander + Cubic Equation - Experimental Data'
    % 5 for 'Expanded Friedlander - Rigby Calibration'
    % 6 for 'Expanded Friedlander - Experimental Data'
    
    % =================================================================== %
    
    %% Public attributes
    properties (SetAccess = public, GetAccess = public)
        
        Z           = 0;   
        W           = 0;   
        type        = 0;  
        db_pmax     = 0;   
        db_pmin     = 0;
        db_td       = 0;  
        db_id       = 0;
        db_im       = 0;
        db_expo     = 0;
        equation    = 0;
                
    end
    
    %% Constructor method
    methods
        
        % =============================================================== %
        
        % Constructor function
        function tnt = Class_TNT(Z, W, type, ...
                db_pmax, db_pmin, db_td, db_id, db_im, db_expo, equation)
            
            if (nargin > 0)
                tnt.Z           = Z;
                tnt.W           = W;
                tnt.type        = type;
                tnt.db_pmax     = db_pmax;
                tnt.db_pmin     = db_pmin;
                tnt.db_td       = db_td;
                tnt.db_id       = db_id;
                tnt.db_im       = db_im;
                tnt.db_expo     = db_expo;
                tnt.equation    = equation;
                            
            else
                               
                % ------------------------------ %
                % Data base of Librescu and Nosier (1990)
                % ------------------------------ %
                
%                 tnt.Z           = 23.16841;
%                 tnt.W           = 2.6225;
%                 tnt.type        = 1;
%                 tnt.db_pmax     = 500 * 6894.76;
%                 tnt.db_pmin     = 0;
%                 tnt.db_td       = 0.1;
%                 tnt.db_id       = 0;
%                 tnt.db_im       = 0;
%                 tnt.db_expo     = 80 * tnt.db_td;
%                 tnt.equation    = 6;
 
                % ------------------------------ %
                % Data base of Hause and Librescu (2005)
                % ------------------------------ %

%                 tnt.Z           = 5;
%                 tnt.W           = 10;
%                 tnt.type        = 1;
%                 tnt.db_pmax     = 1.379 * 10^6 ;
%                 tnt.db_pmin     = 0;
%                 tnt.db_td       = 0.005;
%                 tnt.db_id       = 0;
%                 tnt.db_im       = 0;
%                 tnt.db_expo     = 0;
%                 tnt.equation    = 6;                
                
                % ------------------------------ %
                % Data base of Wei and Dharani (2006)
                % ------------------------------ %
                
%                 tnt.Z           = 23.16841;
%                 tnt.W           = 2.62;
%                 tnt.type        = 1;
%                 tnt.db_pmax     = 6894.8;
%                 tnt.db_pmin     = 0;
%                 tnt.db_td       = 7.7*0.001;
%                 tnt.db_id       = 0;
%                 tnt.db_im       = 0;
%                 tnt.db_expo     = 0.55;
%                 tnt.equation    = 6;

                % ------------------------------ %
                % Data base of Kazanci (2017)
                % ------------------------------ %
                
                tnt.Z           = 8.5405;
                tnt.W           = 0.1087;
                tnt.Z           = 8.54;
                tnt.W           = 0.122;
                tnt.type        = 1;
                tnt.db_pmax     = 28900;
                tnt.db_pmin     = 0;
                tnt.db_td       = 0.0018;
                tnt.db_id       = 0;
                tnt.db_im       = 0;
                tnt.db_expo     = 0.35;
                tnt.equation    = 5;

                % ------------------------------ %
                % Data base of Kazanci and Mecitoglu (2008)
                % Data base of Kazanci et al. (2004)
                % ------------------------------ %
                
%                 tnt.Z           = 8.5405;
%                 tnt.W           = 0.1087;
%                 tnt.type        = 1;
%                 tnt.db_pmax     = 28900;
%                 tnt.db_pmin     = 0;
%                 tnt.db_td       = 0.0018;
%                 tnt.db_id       = 0;
%                 tnt.db_im       = 0;
%                 tnt.db_expo     = 0.35;
%                 tnt.equation    = 6;

                % ------------------------------ %
                % Data base of Upadhyay et al (2011)
                % ------------------------------ %
                
%                 tnt.Z           = 5;
%                 tnt.W           = 10;
%                 tnt.type        = 1;
%                 tnt.db_pmax     = 3447000;
%                 tnt.db_pmin     = 0;
%                 tnt.db_td       = 0.1;
%                 tnt.db_id       = 0;
%                 tnt.db_im       = 0;
%                 tnt.db_expo     = 2;
%                 tnt.equation    = 6;

                % ------------------------------ %
                % Data base of Susler et al (2012)
                % ------------------------------ %
                
%                 tnt.Z           = 8.53933091690194;
%                 tnt.W           = 0.108808929917177;
%                 tnt.type        = 1;
%                 tnt.db_pmax     = 28906;
%                 tnt.db_pmin     = 0;
%                 tnt.db_td       = 0.0018;
%                 tnt.db_id       = 0;
%                 tnt.db_im       = 0;
%                 tnt.db_expo     = 0.35;
%                 tnt.equation    = 5;
                
                % ------------------------------ %
                % Data base of Amibili (2020)
                % ------------------------------ %
                
%                 tnt.Z           = 30;
%                 tnt.W           = 340.251472157926;
%                 tnt.type        = 1;
%                 tnt.db_pmax     = 50000;
%                 tnt.db_pmin     = 0;
%                 tnt.db_td       = 0.025;
%                 tnt.db_id       = 0;
%                 tnt.db_im       = 0;
%                 tnt.db_expo     = 0.82;
%                 tnt.equation    = 6;

                                
            end
            
        end
        
    end
    
end