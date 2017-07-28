CONTENTS BOUNDARY ELEMENT METHOD DIRECTORY

The following files are present

anaSolveSphere      - my analytical solver for spherical geometries for validating the methods used
bemCheckModel       - to check and validate a model's geometry
bemEEMatrix         - Create the potential to potential integral equations (sub function of bemMatrixPP)
bemEJMatrix         - Create the current density to options integral equations (sub function of bemMatrixPP as well)
bemGenerateSphere   - Create a spherical model for testing the accuracy of the boundary element method
bemMatrixPP         - Compute the boundary element method transfer matrix from potential at inner surface to the one at the outer surface
bemPlotSurface      - A simple function to plot the geometries and potential distributions using matlab's graphics tools
bemValidate         - A script for validating the boundary element method using spherical geometries
errMAG              - Magnifiction error norm
errRDM              - The relative difference measure error norm
errRDMS             - The relative difference measure* error, same as RDM only not susceptible to magnification errors
errRMS              - The RMS error measure
triCCW              - Make a surface CCW (sub function of bemCheckModel)

CURRENT STATE OF SOFTWARE
The bem works well for phantom spherical data, however still some significant magnification errors occur when applying it to the
cage data. I suspect it is due to an not exact fitting of the datapoints of the cage in the total geometry. The nodes may be off by
5 or even 10mm. Since the cage is not completely rigid another problem is that the shape of the cage may have altered a little from
experiment to discretisation. The cage was discretisized in two stages, combining the data resulted in the given geometry, but between
both sets already some differences were seen order f a few millimetres. The cage is not a solid entity but consists of two halves that are
put around the heart and they can move a little in respect to eachother. Another concern is the discretisation, the electrodes are folded around
a grid and the node points were taken from the outside, but in fact most electrodes have a contact surface that stretches from inside to outside of
the grid on which the were wound.
