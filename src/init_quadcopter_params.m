% Nominal model values used by the controller
m_nominal   = 1.20;     % kg
Iyy_nominal = 0.025;    % kg*m^2

% Actual vehicle values used by the plant
m_plant     = 1.4;
Iyy_plant   = Iyy_nominal;

g = 9.81;               % m/s^2

T_hover = m_nominal*g;
T_max   = 24;
tau_max = 0.50;

x0     = 0;
z0     = 1;
theta0 = 0;
L = 0.30;          % distance from center to each rotor [m]
F_motor_max = 6;   % maximum thrust of one rotor [N]
