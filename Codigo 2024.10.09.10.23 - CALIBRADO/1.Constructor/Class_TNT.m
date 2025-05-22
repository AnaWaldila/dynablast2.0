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
    % R:        Distance (m)
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
    % 3 for 'Friedlander + Cubic Equation (calculate tm) - Reis Calibration'  
    % 4 for 'Friedlander + Cubic Equation - Experimental Data'
    % 5 for 'Expanded Friedlander - Rigby Calibration'
    % 6 for 'Expanded Friedlander - Experimental Data'
    
    % =================================================================== %
    
    %% Public attributes
    properties (SetAccess = public, GetAccess = public)
        
        Z           = 5;   
        W           = 10;
        R           = 10.772;
        type        = 2;  
        db_pmax     = 73124.4386;   
        db_pmin     = 22223.6654;
        db_td       = 0.006776128;  
        db_id       = 177.5103356;
        db_im       = 206.1268062;
        db_expo     = 1.094;
        equation    = 5;
                
    end
    
    %% Constructor method
    methods
        
        % =============================================================== %
        
        % Constructor function
        function tnt = Class_TNT(Z, W, R, type, ...
                db_pmax, db_pmin, db_td, db_id, db_im, db_expo, equation)
            
            if (nargin > 0)
                tnt.Z           = Z;
                tnt.W           = W;
                tnt.R           = R;
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
                % Data base of Kazanci and Mecitoglu (2008)
                % ------------------------------ %
                
                tnt.Z           = 8.5405;
                tnt.W           = 0.1087;
                tnt.R           = tnt.Z * tnt.W^(1/3);
                tnt.type        = 1;
                tnt.db_pmax     = 28900;
                tnt.db_pmin     = 0;
                tnt.db_td       = 0.0018;
                tnt.db_id       = 0;
                tnt.db_im       = 0;
                tnt.db_expo     = 0.35;
                tnt.equation    = 6;

            end
            
        end
        
    end
    
end