%% Initialization

% Clear workspace
clear
clc

% Add path to canvas, cross, and images folders
addpath('1.Constructor', '2.Type_Load', '3.Class_Equations', ...
    '4.Solution', '5.Results', '6.Control', '7.Static_Methods', 'GUI');

%% Start up app
% App_Main;

%% Start up app
clear
clc
tic
plate   = Class_Plate();
layer   = Class_Layer();
tnt     = Class_TNT();
ana     = Class_Analysis();
adv     = Class_AdvAnalysis();
control = Class_Control(plate, layer, tnt, ana, adv);
toc