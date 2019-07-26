# imu-and-gps-integration

The presented code is for the tightly couple of inertial measurements with gnss pseudo-ranges. 
.mat files are some examples can directly be called from Main_INSGNSS.m or Main_Script.m files. These files include inertial measurements (Accelerations and angular velocities) as well as GNSS L1/L2 observations. The motion is estimated through an EKF; first the state is propagated using the constant-acceleration model, and further it is updated by gnss observations.
