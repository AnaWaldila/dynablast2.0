classdef Class_Analysis
    
    % =================================================================== %
    % DESCRIPTION
    
    % This code open the constructor mode, where defines the
    % characteristics of the analysis
    
    % Variables
    % theory:           type of theory (1 = classical plate theory, 2 = first
    %                   order plate theory, 3 = high order plate theory, 
    %                   4 = classica von Karman theory, 
    %                   5 = expanded von Karman theory)
    % dynamic:          dynamic's analysis (0 off, 1 = on for explosive load, 
    %                   2 = free vibration)
    % negative:         negative phase (0 for not and 1 for yes)
    % nonlinear:        nonlinear effect (0 for not and 1 for yes)
    % time:             time of analisys (s)
    % gen_button:       General analysis or advanced analysis 
    %                   (0 = general button, 1 = advanced butto)
    % ss_analysis:      calculate the stress and strain based on the point of
    %                   analysis for each interval of time (0 = off, 1 =
    %                   on)
    
    % =================================================================== %
    
    %% Public attributes
    properties (SetAccess = public, GetAccess = public)
                        
        theory          = 1;  % Define which theory the user choose
        dynamic         = 1;  % Dynamic analysis
        negative        = 1;  % Negative phase
        nonlinear       = 0;  % Defines if the nonlinearity is ON or OFF
        time            = 0;  % Defines the time of the analysis
        gen_button      = 0;  % Verificate the button (general button = 0, 
                              % advanced button = 1)
        ss_analysis     = 0;  % Calculate the strain and stress vectors of 
                              % analysis
                
    end
    
    %% Constructor method
    methods
        
        % Constructor function
        function analysis = Class_Analysis...
                (theory, dynamic, negative, time, ss_analysis, gen_button)
            
            if (nargin > 0)
                
                analysis.theory         = theory;
                analysis.dynamic        = dynamic;
                analysis.negative       = negative;
                analysis.time           = time;
                analysis.ss_analysis    = ss_analysis;
                analysis.gen_button     = gen_button;
                                                
            else
                
                % ------------------------------ %
                % Data base of Kazanci and Mecitoglu (2008)
                % ------------------------------ %
                
                % analysis.theory         = 4;
                % analysis.structure      = 1;
                % analysis.dynamic        = 1;
                % analysis.negative       = 1;
                % analysis.nonlinear      = 0;
                % analysis.time           = 0.03;
                % analysis.gen_button     = 1;
                  
            end
            
        end
                
    end
    
end