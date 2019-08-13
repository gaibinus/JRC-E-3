# Methods in the time domain:
# - selecting each nth sample
# - collapsing (averaging) each block of n samples
# - defining a new sampling grid, and calculating the signal at that point using interpolation (nearest neighbor,
# linear, quadratic, cubic, Gaussian, sinc-ish, etc). Also you could choose for irregularly spaced downsampling /
# content aware downsampling: varying the sampling density based on the information density in the signal. However,
# this is more the realm of signal compression algorithms.
