%% 2D Quadcopter Parameters

% Physical constants
m   = 1.20;      % Total mass [kg]
Iyy = 0.025;     % Pitch moment of inertia [kg*m^2]
g   = 9.81;      % Gravity [m/s^2]

% Actuator limits for later controller design
T_hover = m*g;   % Hover thrust [N]
T_max   = 24;     % Maximum total thrust [N]
tau_max = 0.50;   % Maximum pitch torque [N*m]

% Initial flight state
x0     = 0;       % Horizontal position [m]
z0     = 1;       % Altitude [m]
theta0 = 0;       % Pitch angle [rad]