classdef Class_Analysis
    
    % =================================================================== %
    % DESCRIPTION
    
    % This code open the constructor mode, where defines the
    % characteristics of the analysis
    
    % Variables
    % theory:       type of theory (1 = classical plate theory, 2 = first
    %               order plate theory, 3 = high order plate theory, 
    %               4 = classica von Karman theory, 
    %               5 = expanded von Karman theory)
    % dynamic:      dynamic's analysis (0 off, 1 = on for explosive load, 
    %               2 = free vibration)
    % negative:     negative phase (0 for not and 1 for yes)
    % nonlinear:    nonlinear effect (0 for not and 1 for yes)
    % time:         time of analisys (s)
    % gen_button:   General analysis or advanced analysis 
    %               (0 = general button, 1 = advanced butto)
    
    % =================================================================== %
    
    %% Public attributes
    properties (SetAccess = public, GetAccess = public)
        
        theory          = 1;  % Defines which theory the user choose
        dynamic         = 1;  % Dynamic analysis
        negative        = 1;  % Negative phase
        nonlinear       = 0;  % Defines if the nonlinearity is ON or OFF
        time            = 0;  % Defines the time of the analysis
        gen_button      = 0;  % Verificate the button (general button = 0, 
                            % advanced button = 1)
                
    end
    
    %% Constructor method
    methods
        
        % =============================================================== %
        
        % Constructor function
        function analysis = Class_Analysis...
                (theory, dynamic, negative, time, gen_button)
            if (nargin > 0)
                
                analysis.theory         = theory;
                analysis.dynamic        = dynamic;
                analysis.negative       = negative;
                analysis.time           = time;
                analysis.gen_button     = gen_button;
                                                
            else
                
                % ------------------------------ %
                % Data base of Reddy (1985)
                % ------------------------------ %
                
%                 analysis.theory         = 2;
%                 analysis.dynamic        = 2;
%                 analysis.negative       = 0;
%                 analysis.time           = 0.08;
%                 analysis.gen_button     = 1;
                                  
                % ------------------------------ %
                % Data base of Libresco and Nosier (1990)
                 
%                 analysis.theory         = 3;
%                 analysis.dynamic        = 1;
%                 analysis.negative       = 1;
%                 analysis.nonlinear      = 0;
%                 analysis.time           = 0.04;
%                 analysis.gen_button     = 0;
                  
                % ------------------------------ %
                % Data base of Hause and Librescu (2005)
                % ------------------------------ %
                
%                 analysis.theory         = 1;
%                 analysis.dynamic        = 1;
%                 analysis.negative       = 0;
%                 analysis.nonlinear      = 0;
%                 analysis.time           = 0.015;
%                 analysis.gen_button     = 0;

                % ------------------------------ %
                % Data base of Wei and Dharani (2006)
                % ------------------------------ %
                
%                 analysis.theory         = 3;
%                 analysis.dynamic        = 1;
%                 analysis.negative       = 1;
%                 analysis.nonlinear      = 0;
%                 analysis.time           = 0.1;
%                 analysis.gen_button     = 1;

                % ------------------------------ %
                % Data base of Kazanci (2017)
                % ------------------------------ %
                
                analysis.theory         = 4;
                analysis.dynamic        = 1;
                analysis.negative       = 1;
                analysis.nonlinear      = 0;
                analysis.time           = 0.05;
                analysis.gen_button     = 1;

                % ------------------------------ %
                % Data base of Kazanci and Mecitoglu (2008)
                % Data base of Kazanci et al. (2004)
                % ------------------------------ %
                
%                 analysis.theory         = 4;
%                 analysis.dynamic        = 1;
%                 analysis.negative       = 1;
%                 analysis.nonlinear      = 0;
%                 analysis.time           = 0.05;
%                 analysis.gen_button     = 1;
                  
                % ------------------------------ %
                % Data base of Upadhyay et al (2011)
                % ------------------------------ %
                  
%                 analysis.theory         = 5;
%                 analysis.dynamic        = 1;
%                 analysis.negative       = 1;
%                 analysis.nonlinear      = 1;
%                 analysis.time           = 0.2;
%                 analysis.gen_button     = 0;
  
                % ------------------------------ %
                % Data base of Susler et al (2012)
                % ------------------------------ %
                  
%                 analysis.theory         = 4;
%                 analysis.dynamic        = 1;
%                 analysis.negative       = 1;
%                 analysis.time           = 0.02;
%                 analysis.gen_button     = 1;

                % ------------------------------ %
                % Data base of Amibili (2020)
                % ------------------------------ %
                
%                 analysis.theory         = 5;
%                 analysis.dynamic        = 1;
%                 analysis.negative       = 1;
%                 analysis.time           = 0.1;
%                 analysis.gen_button     = 0;

                
            end
        end
                
    end
    
end