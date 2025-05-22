classdef Class_AdvAnalysis
    
    % =================================================================== %
    % DESCRIPTION
    
    % This code open the constructor mode, where defines the
    % characteristics of the analysis
    
    % Variables
    % adv_parameter:    Parameter that defines the type of advanced 
    %                   analysis
    % adv_negative:     In advanced analysis, some analysis changes from 
    %                   negative phase = 0 (off) to negative phase = 1 (on)
    % Z_initial:        Some analysis needs an initial value for Z. 
    % W_initial:        Initial value for W that the user can choose for 
    %                   some analysis
    % W_final:          Final value for W that the user can choose for some
    %                   analysis
    % interval:         Some analysis needs the user choose a number of 
    %                   steps in looping
    
    % =================================================================== %
    
    %% Public attributes
    properties (SetAccess = public, GetAccess = public)
        
        adv_parameter   = 0;    % Parameter for each type of advanced 
                                % analysis
        adv_negative    = 0;    % Verificating negative phase
        Z_initial       = 0;    % First type of advanced analysis
        W_final         = 0;    % Final wieght fo TNT
        W_initial       = 0;
        interval        = 0;    % Number of intervals
        
    end
    
    %% Constructor method
    methods
        
        % =============================================================== %
        
        % Constructor function
        function adv = Class_AdvAnalysis...
                (adv_parameter, Z_initial, W_initial, ...
                W_final, interval, adv_negative)
            
            if (nargin > 0)
                
                adv.adv_parameter   = adv_parameter;
                adv.adv_negative    = adv_negative;
                
                adv.Z_initial       = Z_initial;
                adv.W_final         = W_final;
                adv.W_initial       = W_initial;
                adv.interval        = interval;
                             
            else
                
                adv.adv_parameter   = 1;
                adv.adv_negative    = 0;

                adv.Z_initial       = 8.54;
                adv.W_final         = 100;
                adv.W_initial       = 0.1;
                adv.interval        = 100;
                
            end
        end
                
    end
    
end