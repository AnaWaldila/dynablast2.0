classdef Class_NavierFunctions
    
    % =================================================================== %
    % DESCRIPTION
    
    % General class to create some static functions for to calculate some
    % parameter in case of simple supported plate.
    
    % =================================================================== %
    
    %% Static methods    
    methods (Static)
        
        % =============================================================== %
        
        % Function to calculate Fourier series's parameters
        function [mn_coeff, sol_omega] = Fourier_Solution...
                (parameter, matrix_fourier, coefficients, dynamic, mm, nn)
            
            switch dynamic
                
                case 0  % Static Analysis
                    
                    % Here, the function equationsToMatrix can generate the
                    % matrix of coefficients and the matrix of
                    [A, B]      = (equationsToMatrix(matrix_fourier, ...
                        coefficients));
                    
                    % In this case, A\B is equal to A^(-1) * B, i.e. A^(-1) =
                    % inv(A) = inverse of matrix A.
                    % Substituting parameters m and n in parameters solution
                    mn_coeff    = A\B;
                    
                    % The omega's values is zero here because it is a
                    % static analysis.
                    sol_omega   = 0;
                    
                case 1
                    
                    % In this case, the function equationsToMatrix does not
                    % run when the variabels are differentiations as
                    % diff(Wmn(t), t, t), for example. So, first, we are
                    % getting this type of variables and, after, use the
                    % function equationsToMatrix.
                    
                    % Creating a new matrix - matrix_diff is a matrix for
                    % only differential expression's coeffitients, like
                    % diff(Umn(t),t,t)
                    % matrix_var is a matriz for only coeffitients which
                    % their variable is the first degree, like Umn(t).
                    matrix_diff = sym(zeros(length(matrix_fourier), 1));
                    matrix_var  = sym(zeros(length(matrix_fourier), 1));
                    
                    for i = 1 : length(matrix_fourier)
                        
                        % First, getting all coeffs for each variable of
                        % first degree
                        umn  = formula(coeffs(matrix_fourier(i,1), ...
                            coefficients(1,1)));
                        vmn  = formula(coeffs(matrix_fourier(i,1), ...
                            coefficients(1,2)));
                        wmn  = formula(coeffs(matrix_fourier(i,1), ...
                            coefficients(1,3)));
                        txmn = formula(coeffs(matrix_fourier(i,1), ...
                            coefficients(1,4)));
                        tymn = formula(coeffs(matrix_fourier(i,1), ...
                            coefficients(1,5)));
                        
                        % Second, verificating if each coeff is equal to
                        % equation. Matlab presents the equation if does
                        % not find the coeff.
                        if umn == matrix_fourier(i,1)
                            umn = [0, 0];
                        end
                        if vmn == matrix_fourier(i,1)
                            vmn = [0, 0];
                        end
                        if wmn == matrix_fourier(i,1)
                            wmn = [0, 0];
                        end
                        if txmn == matrix_fourier(i,1)
                            txmn = [0, 0];
                        end
                        if tymn == matrix_fourier(i,1)
                            tymn = [0, 0];
                        end
                        
                        % Third, this matrix only saves variable's
                        % coeffitients with first degree, as U(t), for
                        % instance.
                        matrix_var(i,1)     = simplify(expand( ...
                            (umn(1,2)   * coefficients(1,1) + ...
                            vmn(1,2)   * coefficients(1,2) + ...
                            wmn(1,2)   * coefficients(1,3) + ...
                            txmn(1,2)  * coefficients(1,4) + ...
                            tymn(1,2)  * coefficients(1,5))));
                        
                        % Fourth, save in a matrix the final equation. Pay
                        % attention, this equation only have the
                        % second order differential variables and all
                        % free degree parameters.
                        matrix_diff(i,1)    = simplify(expand(...
                            matrix_fourier(i,1) - matrix_var(i,1)));
                        
                        % Fifth, create new variables for to use the
                        % function equationsToMatrix.
                        syms t
                        syms dtumn dtvmn dtwmn dtxmn dtymn
                        
                        % Sixth, replacing these variables in matrix_diff
                        matrix_diff(i,1) = subs(matrix_diff(i,1), ...
                            [diff(coefficients(1,1),t,t), ...
                            diff(coefficients(1,2),t,t), ...
                            diff(coefficients(1,3),t,t), ...
                            diff(coefficients(1,4),t,t), ...
                            diff(coefficients(1,5),t,t)], ...
                            [dtumn, dtvmn, dtwmn, dtxmn, dtymn]);
                        
                    end
                    
                    % After complete the matrix_diff(:,1), it can possible
                    % to transforme the equation in a differentiation
                    % coefficient's matrix.
                    % Variables:
                    % var_diff: matrix of differential's coefficients of
                    % matrix_diff
                    % var_free: free variables of matrix_diff
                    % var_coeff: matrix of coefficients about linear
                    % parameters of matrix_var
                    [var_diff, ~]    = equationsToMatrix(...
                        matrix_diff(:,1), ...
                        [dtumn, dtvmn, dtwmn, dtxmn, dtymn]);
                    
                    [var_coeff, ~]     = equationsToMatrix(...
                        matrix_var(:,1), ...
                        [coefficients(1,1), coefficients(1,2), ...
                        coefficients(1,3), coefficients(1,4), ...
                        coefficients(1,5)]);
                    
                    % Before to calculate the frequency of natural
                    % vibration, we need to replace the values of 'm' and
                    % 'n' in equation above to have a double equation.
                    syms m n
                    var_diff    = double(subs(var_diff, [m n], [mm nn]));
                    var_coeff   = double(subs(var_coeff, [m n], [mm nn]));
                    
                    % It is necessary to delete because the determinant of
                    % final matrix is based on a square matrix
                    if parameter == 1
                        var_diff(:,4)   = [];
                        var_diff(:,4)   = [];
                        
                        var_coeff(:,4)  = [];
                        var_coeff(:,4)  = [];
                    end
                    % Fynaly, all coefficients [Umn, Vmn Wmn, Txmn, Tymn]
                    % can calculate based on the result above:
                    % For Vibration and, finally, to determine values of
                    % Umn, Vmn, Wmn, Txmn and Tymn, it is necessary to
                    % calculate the frequency of natural vibration, omega.
                    syms lambda
                    
                    % Now, it can be possible to solve the equation and
                    % find the real value of omega, Frequency of natural
                    % vibration.
                    % Moreover, we choose the first solution of omega,
                    % because this is the first vibration mode.
                    equation_det = det(var_coeff - lambda * var_diff);
                    sol_omega = sort(sqrt(double(solve(...
                        equation_det, lambda))));
                    sol_omega = sol_omega(1,1);
                    
                    % Variables Umn(t), Vmn(t), Wmn(t), Txmn(t) and Tymn(t)
                    % can rewrite as a expression based on exponential
                    % function. So, for free vibration can write:
                    syms U0mn V0mn W0mn Tx0mn Ty0mn
                    func_coeff  = Class_NavierFunctions.Dynamic_Equation(...
                        [U0mn V0mn W0mn Tx0mn Ty0mn], sol_omega);
                    
                    % Now, with function of Fourier's coefficients, it is
                    % possible to calculate all values of U0mn, V0mn, W0mn,
                    % Tx0mn and Ty0mn. The equation it can possible to see
                    % in Reddy's Book, page 380, equation 7.2.7a.
                    % Remember, this case is a free vibration
                    dynamic_eq  = (var_coeff - sol_omega^2 * var_diff);
                    
                    % Final solution of dynamic analysis. Values of U0mn,
                    % V0mn, W0mn, Tx0mn and Ty0mn
                    pmt_coeff   = eig(dynamic_eq);
                    
                    if parameter == 1
                        mn_coeff    = simplify(expand(subs(func_coeff, ...
                            [U0mn V0mn W0mn], ...
                            [pmt_coeff(1,1) pmt_coeff(2,1) ...
                            pmt_coeff(3,1)])));
                    else
                        mn_coeff    = simplify(expand(subs(func_coeff, ...
                            [U0mn V0mn W0mn Tx0mn Ty0mn], ...
                            [pmt_coeff(1,1) pmt_coeff(2,1) pmt_coeff(3,1) ...
                            pmt_coeff(4,1) pmt_coeff(5,1)])));
                    end
                    
            end
            
        end
        
        % =============================================================== %
                
        % Function to calculate Galerkin Equation
        function [final_galerkin] = Galerkin_Equation...
                (eq_galerkin, parameter, coeff_fourier)
           
            syms t
            
            % 1. Creating an equation, equal to zero
            galerkin       = eq_galerkin == 0;
            
            % 2. Isolating the highest parameter
            if (parameter == 1 || parameter == 4)
                galerkin   = ...
                    [isolate(galerkin(1,1), diff(coeff_fourier(1,1),t,t));
                    isolate(galerkin(2,1), diff(coeff_fourier(1,2),t,t));
                    isolate(galerkin(3,1), diff(coeff_fourier(1,3),t,t))];
                
            elseif (parameter == 2 || parameter == 3 || parameter == 5)
                galerkin   = ...
                    [isolate(galerkin(1,1), diff(coeff_fourier(1,1),t,t));
                    isolate(galerkin(2,1), diff(coeff_fourier(1,2),t,t));
                    isolate(galerkin(3,1), diff(coeff_fourier(1,3),t,t));
                    isolate(galerkin(4,1), diff(coeff_fourier(1,4),t,t));
                    isolate(galerkin(5,1), diff(coeff_fourier(1,5),t,t))];
                
            end
            
            % 3. Separate the highest differential order in each equation
            % In this case, we will verificate the coefficient of those
            % differential parameters. I.e, for instance, if the first
            % equation (diff(u,t,2)) has other second order derivative, it
            % is necessary to verificate the absolute value of this second
            % order parameter.
            if (parameter == 1 || parameter == 4)
                number_pmt  = 3;
            elseif (parameter == 2 || parameter == 3 || parameter == 5)
                number_pmt  = 5;
            end
            
            % Create a matrix with second order derivative's coefficients
            coefficient = zeros(number_pmt,number_pmt);
            for i = 1 : number_pmt
                
                for j = 1 : number_pmt
                    
                    if i ~= j
                        
                        equation        = coeffs(rhs(galerkin(i,1)), ...
                            diff(coeff_fourier(1,j), t, t));
                        if equation == rhs(galerkin(i,1))
                            equation    = [0 0];
                        end
                        
                    else
                        equation        = [0 0];
                    end
                    
                    coefficient(i,j)    = abs(equation(1,2));
                    clear equation
                    
                end
                
            end
            
            % 4. Eliminating parameters and creating a new vector
            for i = 1 : number_pmt
                
                for j = 1 : number_pmt
                
                    if (i~=j)
                        galerkin(i,1) = subs(galerkin(i,1), ...
                    diff(coeff_fourier(1,j), t, t), 0);
                
                    end
                    
%                     if (i~=j && abs(coefficient(i,j)) < 10e-5)
%                         galerkin(i,1) = subs(galerkin(i,1), ...
%                     diff(coeff_fourier(1,j), t, t), 0);
%                 
%                     end
                    
                end
                
            end
            
            final_galerkin = galerkin;
            
        end
                
    end
    
end