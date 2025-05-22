classdef Class_Strain

    % =================================================================== %
    % DESCRIPTION

    % This class calculate all results of laminated composite plates based
    % on simple supported as a boundary condition. Moreover, the type of
    % analysis in that script is static.
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

    %% Public Properties
    properties (SetAccess = public, GetAccess = public)

        % Import Classes
        plate               Class_Plate
        layer               Class_Layer
        analysis            Class_Analysis
        pmt                 Class_Parameters
        blast               Class_Blast
        material            Class_Material
        effort              Class_Effort
        bc                  Class_BoundaryConditions
        dynamic_analysis    Class_SolutionDynamic
        result              Class_Result

        % Create new parameters
        N           = 20;               % Number of intervals
        sol_strain  = [];               % Numerical strain in plate

    end

    %% Public Methods
    methods

        function this = Class_Strain(plate, layer, analysis, pmt, ...
                bc, blast, material, effort, dynamic_analysis, result)

            if (nargin > 0)

                disp("Structure                          - PLATE");

                this.analysis       = analysis;
                dynamic             = this.analysis.dynamic;

                switch dynamic
                    case 0
                        this = this.Static_Strain_Plate(plate, layer, ...
                            analysis, pmt, blast, material, effort, result);
                    case 1
                        this = this.Dynamic_Strain_Plate(plate, analysis, ...
                            pmt, material, effort, bc, ...
                            dynamic_analysis, result);
                end

            end

        end

    end

    %% Public Methods for Functions
    methods

        % Function to calculate, numerically, the strain in all layers
        % Graphics to can plot: strain (bending or shear) x z / h
        function this = Static_Strain_Plate(this, plate, layer, ...
                analysis, pmt, blast, material, effort, result)

            disp("Start - Class_strain()             - strain()");

            % Symbolic General Parameters
            syms x y z m n
            syms u0(x,y,t) v0(x,y,t) w0(x,y,t) tx(x,y,t) ty(x,y,t)

            % Import parameters from Class_Plate
            this.plate          = plate;
            a                   = this.plate.a;
            xi                  = this.plate.xi;
            yi                  = this.plate.yi;
            m0                  = this.plate.m0;
            n0                  = this.plate.n0;

            % Import parameters from Class_Layer
            this.layer          = layer;
            num_layer           = this.layer.num_layer;

            % Import parameters from Class_Analysis
            this.analysis       = analysis;
            theory              = this.analysis.theory;

            % Import parameters from Class_Parameters
            this.pmt            = pmt;
            coeff_fourier       = this.pmt.coeff_fourier;

            % Import parameters from Class_Blast
            this.blast          = blast;
            pmax                = this.blast.pmax;

            % Import parameters from Class_Material
            this.material       = material;
            h                   = this.material.h;
            zi                  = this.material.zi;

            % Import parameters from Class_Effort
            this.effort         = effort;
            strain              = this.effort.strain;

            % Import parameters from Class_Result
            this.result         = result;
            final_displacement  = this.result.fd * h;

            % This part is to verificate if the analysis is CLPT. If it is
            % true, the input and output data are differents than FSPT and
            % TSPT analysis.
            if (theory == 1 || theory == 4)
                input_data      = [u0, v0, w0];
            else
                input_data      = [u0, v0, w0, tx, ty];
            end

            % Output Data
            output_data          = final_displacement;

            if (theory == 1 || theory == 4)
                output_fourier  = [0 0 0];
            else
                output_fourier  = [0 0 0 0 0];
            end

            % Creating matrix to plot
            strain_xx        = [];
            strain_yy        = [];
            strain_xy        = [];
            strain_yz        = [];
            strain_xz        = [];
            total_height     = [];

            exx              = zeros(this.N, num_layer);
            eyy              = zeros(this.N, num_layer);
            exy              = zeros(this.N, num_layer);
            eyz              = zeros(this.N, num_layer);
            exz              = zeros(this.N, num_layer);
            height           = zeros(this.N, num_layer);

            % Calculating strain
            for k = 1 : num_layer

                start   = zi(k,1);
                step    = (zi(k,1) - zi(k+1,1)) / this.N;

                % Looping to calculate the behavior of strain in each layer
                % using N intervals

                for i = 1 : this.N

                    exx(i,k)       = subs(subs(subs(...
                        strain(1,1), input_data, output_data), ...
                        [z, x, y, m, n], [start, xi, yi, m0, n0]), ...
                        coeff_fourier, output_fourier);

                    eyy(i,k)       = subs(subs(subs(...
                        strain(2,1), input_data, output_data), ...
                        [z, x, y, m, n], [start, xi, yi, m0, n0]), ...
                        coeff_fourier, output_fourier);

                    exy(i,k)       = subs(subs(subs(...
                        strain(3,1), input_data, output_data), ...
                        [z, x, y, m, n], [start, xi, yi, m0, n0]), ...
                        coeff_fourier, output_fourier);

                    eyz(i,k)       = subs(subs(subs(...
                        strain(4,1), input_data, output_data), ...
                        [z, x, y, m, n], [start, xi, yi, m0, n0]), ...
                        coeff_fourier, output_fourier);

                    exz(i,k)       = subs(subs(subs(...
                        strain(5,1), input_data, output_data), ...
                        [z, x, y, m, n], [start, xi, yi, m0, n0]), ...
                        coeff_fourier, output_fourier);

                    height(i,k)    = start;

                    start          = start - step;

                end

                clear start step

            end

            % Creating a new vector with only one column
            for i = 1 : num_layer

                strain_xx           = cat(1, strain_xx, exx(:,i));
                strain_yy           = cat(1, strain_yy, eyy(:,i));
                strain_xy           = cat(1, strain_xy, exy(:,i));
                strain_xz           = cat(1, strain_xz, exz(:,i));
                strain_yz           = cat(1, strain_yz, eyz(:,i));
                total_height        = cat(1, total_height, height(:,i));

            end

            strain_xx               = strain_xx * (h/a)^2 / pmax;
            strain_yy               = strain_yy * (h/a)^2 / pmax;
            strain_xy               = strain_xy * (h/a) / pmax;
            strain_xz               = strain_xz * (h/a) / pmax;
            strain_yz               = strain_yz * (h/a) / pmax;

            % Final Vector
            this.sol_strain         = double(cat(2, total_height, ...
                strain_xx, strain_yy, strain_xy, strain_yz, strain_xz));

            disp("End   - Class_strain()             - strain()");
            disp(" ");

        end

        % =============================================================== %
        % Function to calculate, numerically, the strain in the middle of
        % the plate in all time of analysis
        function this = Dynamic_Strain_Plate(this, plate, analysis, ...
                pmt, material, effort, bc, dynamic_analysis, result)

            disp("Start - Class_strain()             - Strain()");

            % Symbolic General Parameters
            syms x y z m n
            syms u0(x,y,t) v0(x,y,t) w0(x,y,t) tx(x,y,t) ty(x,y,t)
            
            % Creating the waitbar
            bar                     = waitbar(0.1, ...
                'Calculating the Strain Equation');

            % Import parameters from Class_Plate
            this.plate              = plate;
            xi                      = this.plate.xi;
            yi                      = this.plate.yi;
            m0                      = this.plate.m0;
            n0                      = this.plate.n0;

            % Import parameters from Class_Analysis
            this.analysis           = analysis;
            theory                  = this.analysis.theory;
            ss_analysis             = this.analysis.ss_analysis;

            % Import parameters from Class_Parameters
            this.pmt                = pmt;
            coeff_fourier           = this.pmt.coeff_fourier;

            % Import paramters from Class_BoundaryConditions
            this.bc             = bc;
            d0                  = this.bc.d0;

            % Import parameters from Class_Material
            this.material           = material;
            h                       = this.material.h;

            % Import parameters from Class_Effort
            this.effort             = effort;
            strain                  = this.effort.strain;

            % Import parameters from Class_Result
            this.result             = result;
            fd                      = this.result.fd;

            % Import parameters from Class_SolutionDynamic
            this.dynamic_analysis   = dynamic_analysis;
            mn_coeff                = this.dynamic_analysis.mn_coeff;

            % This part is to verificate if the analysis is CLPT. If it is
            % true, the input and output data are differents than FSPT and
            % TSPT analysis.
            if (theory == 1 || theory == 4)
                input_data          = [u0; v0; w0];
                output_fourier      = [mn_coeff(:,2), mn_coeff(:,4), ...
                                       mn_coeff(:,6)];
            else
                input_data          = [u0; v0; w0; tx; ty];
                output_fourier      = [mn_coeff(:,2), mn_coeff(:,4), ...
                                       mn_coeff(:,6), mn_coeff(:,8), ...
                                       mn_coeff(:,10)];
            end

            % Creating matrix to plot
            total_lenght            = length(mn_coeff);

            strain_equation         = subs(subs(strain, input_data, d0), ...
                    [z, x, y, m, n], [h/2, xi, yi, m0, n0]);

            exx                     = zeros(total_lenght, 1);
            eyy                     = zeros(total_lenght, 1);
            exy                     = zeros(total_lenght, 1);
            eyz                     = zeros(total_lenght, 1);
            exz                     = zeros(total_lenght, 1);

            if ss_analysis == 1

                % 90 = Waitbar before the loop is in 10%
                percent             = 0.9 / total_lenght;

                for i = 1 : total_lenght

                    waitbar(0.1 + i * percent, bar, 'Calculating Strain');

                    exx(i,1)        = subs(strain_equation(1,1), ...
                        coeff_fourier, output_fourier(i,:));

                    eyy(i,1)        = subs(strain_equation(2,1), ...
                        coeff_fourier, output_fourier(i,:));

                    exy(i,1)        = subs(strain_equation(3,1), ...
                        coeff_fourier, output_fourier(i,:));

                    eyz(i,1)        = subs(strain_equation(4,1), ...
                        coeff_fourier, output_fourier(i,:));

                    exz(i,1)        = subs(strain_equation(5,1), ...
                        coeff_fourier, output_fourier(i,:));

                end

            else

                waitbar(0.9, bar, 'No Strain to Calculate');
                pause(2);

            end

            % Final Vector
            this.sol_strain = double(cat(2, fd(:,1), ...
                exx, eyy, exy, eyz, exz));
            
            waitbar(1, bar, ...
                        'Ending of the Strain Calculation');

            close(bar);

            disp("End   - Class_strain()             - Strain()");
            disp(" ");

        end

    end

end