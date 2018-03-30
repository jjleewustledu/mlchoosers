classdef ImagingChoosersInterface 
	%% IMAGINGCHOOSERSINTERFACE is the abstract interface for ImagingChoosers, ImageFilters, FilenameFilters.
    
	%  $Revision$
 	%  was created $Date$
 	%  by $Author$, 
 	%  last modified $LastChangedDate$
 	%  and checked into repository $URL$, 
 	%  developed on Matlab 8.1.0.604 (R2013a)
 	%  $Id$
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

    properties (Constant)
        DEFAULT_SUFF = '_default';
    end  

	methods (Abstract, Static)
        obj = brightest(obj)
        obj = highestSeriesNumber(obj)
        obj = isMcf(obj)
        obj = isMr(obj)
        obj = isPet(obj)
        obj = leastEntropy(obj)
        obj = longestDuration(obj)
        obj = lowestSeriesNumber(obj)
        obj = maximum(obj)
        obj = minimum(obj)
        obj = mostEntropy(obj)
        obj = mostPixels(obj)
        obj = notIsMcf(obj)
        obj = notIsMr(obj)
        obj = notIsPet(obj)
        obj = smallestVoxels(obj)
        obj = timeDependent(obj)
        obj = not(obj)
    end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end


