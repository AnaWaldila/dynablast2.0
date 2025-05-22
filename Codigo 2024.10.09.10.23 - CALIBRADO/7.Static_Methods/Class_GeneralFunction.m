classdef Class_GeneralFunction
    
    % =================================================================== %
    % DESCRIPTION
    
    % This class is an auxiliar class to calculate parameters from
    % Classical Plate Theory, First Shear Order Theory,
    % High Shear Order Theory, Classical von Karman Theory and High Order
    % von Karman Theory
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
    
    %% Static Methods
    methods (Static)
        
        % This function calculates the stiffenesses matrices
        function [A, B, D, E, F, H] = Matrix_Stiffness...
                (num_layer, Q, zi)

            A = sym(zeros(6,6));
            B = sym(zeros(6,6));
            D = sym(zeros(6,6));
            E = sym(zeros(6,6));
            F = sym(zeros(6,6));
            H = sym(zeros(6,6));

            for i = 1 : num_layer
                A(:,:) = A(:,:) + Q(:,:,i) * ...
                    (zi(i+1,1) - zi(i,1));
                B(:,:) = B(:,:) + (1/2) * Q(:,:,i) * ...
                    (zi(i+1,1)^2 - zi(i,1)^2);
                D(:,:) = D(:,:) + (1/3) * Q(:,:,i) * ...
                    (zi(i+1,1)^3 - zi(i,1)^3);
                E(:,:) = E(:,:) + (1/4) * Q(:,:,i) * ...
                    (zi(i+1,1)^4 - zi(i,1)^4);
                F(:,:) = F(:,:) + (1/5) * Q(:,:,i) * ...
                    (zi(i+1,1)^5 - zi(i,1)^5);
                H(:,:) = H(:,:) + (1/7) * Q(:,:,i) * ...
                    (zi(i+1,1)^7 - zi(i,1)^7);
            end

            % for i = 1 : num_layer
            %   A(:,:) = A(:,:) + Q(:,:,i) * h;
            %   B(:,:) = B(:,:) + (1/2) * Q(:,:,i) * h^2;
            %   D(:,:) = D(:,:) + (1/3) * Q(:,:,i) * h^3;
            %   E(:,:) = E(:,:) + (1/4) * Q(:,:,i) * h^4;
            %   F(:,:) = F(:,:) + (1/5) * Q(:,:,i) * h^5;
            %   H(:,:) = H(:,:) + (1/7) * Q(:,:,i) * h^7;
            % end

            
        end
        
        % =============================================================== %
        
        % Function to calculate the matrix of inertia's moment
        function [matrix_inertia] = Moment_Inertia(num_layer, rho, zi)
            
            % matrix_inertia = [I0 I1 I2 I3 I4 I5 I6]
            % Ii = sum(int(rho(k) * z(k)^(i-1),z))
            
            % Symbolic General Parameters
            syms z
            
            % Starting matrix
            matrix_inertia = sym(zeros(1,7));
            
            for i = 1 : num_layer
                
                for j = 1 : 7
                    
                    matrix_inertia(1,j) = matrix_inertia(1,j) + ...
                        int(rho(i,1) * z^(j-1), z, zi(i,1), zi(i + 1,1));
                    
                end
                
            end
            
        end
        
        % =============================================================== %
        
        % Function to replace matrices A, B, D, E, F, H, I to real values
        function [final_matrix] = Effort_Parameters(I, equation, eq_length)
            
            % Next step is to replace all variables above into eq_fourier.
            % This is a long way, but it is necessary.
            syms I0 I1 I2 I3 I4 I6
            
            var = [I0 I1 I2 I3 I4 I6];
            
            % Create a new matrix
            final_matrix = sym(zeros(eq_length,1));
            
            for i = 1 : eq_length
                final_matrix(i,1) = subs(equation(i,1), ...
                    var,[I(1,1), I(1,2), I(1,3), I(1,4), I(1,5), I(1,7)]);
            end
            
        end
        
    end
    
end