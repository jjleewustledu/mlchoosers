classdef ImageFilters < mlchoosers.ImagingChoosersInterface
	%% IMAGEFILTERS selects images by criteria
	%  Version $Revision: 2467 $ was created $Date: 2013-08-10 21:27:41 -0500 (Sat, 10 Aug 2013) $ by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-08-10 21:27:41 -0500 (Sat, 10 Aug 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/ImageFilters.m $
 	%  Developed on Matlab 7.14.0.739 (R2012a)
 	%  $Id: ImageFilters.m 2467 2013-08-11 02:27:41Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

	methods (Static)
 		function imcmp = brightest(imcmp) 
            imcmp = mlchoosers.ImageFilters.maximum('dipmean', imcmp);
        end
        function imcmp = highestSeriesNumber(imcmp)
            imcmp = mlfourd.ImagingComponent.load( ...
                    mlchoosers.FilenameFilters.highestSeriesNumber( ...
                    cellfun(@(x) x.fqfilename, imcmp.cell, 'UniformOutput', false)));
        end
        function imcmp = isBetted(imcmp, varargin)
            imcmp = mlfourd.ImagingComponent.load( ...
                    mlchoosers.FilenameFilters.isBetted( ...
                    cellfun(@(x) x.fqfilename, imcmp.cell, 'UniformOutput', false), varargin{:}));
        end
        function imcmp = isFlirted(imcmp, varargin)            
            imcmp = mlfourd.ImagingComponent.load( ...
                    mlchoosers.FilenameFilters.isFlirted( ...
                    cellfun(@(x) x.fqfilename, imcmp.cell, 'UniformOutput', false), varargin{:}));
        end 
        function imcmp = isMcf(imcmp, varargin)            
            imcmp = mlfourd.ImagingComponent.load( ...
                    mlchoosers.FilenameFilters.isMcf( ...
                    cellfun(@(x) x.fqfilename, imcmp.cell, 'UniformOutput', false), varargin{:}));
        end 
        function imcmp = isMr(imcmp, varargin)            
            imcmp = mlfourd.ImagingComponent.load( ...
                    mlchoosers.FilenameFilters.isMr( ...
                    cellfun(@(x) x.fqfilename, imcmp.cell, 'UniformOutput', false), varargin{:}));
        end 
        function imcmp = isPet(imcmp, varargin)
            imcmp = mlfourd.ImagingComponent.load( ...
                    mlchoosers.FilenameFilters.isPet( ...
                    cellfun(@(x) x.fqfilename, imcmp.cell, 'UniformOutput', false), varargin{:}));
        end
        function imcmp = longestDuration(imcmp)
            imcmp = mlchoosers.ImageFilters.maximum('duration', imcmp);
        end
        function imcmp = lowestSeriesNumber(imcmp)
            imcmp = mlfourd.ImagingComponent.load( ...
                    mlchoosers.FilenameFilters.lowestSeriesNumber( ...
                    cellfun(@(x) x.fqfilename, imcmp.cell, 'UniformOutput', false)));
        end
        function imcmp = maximum(prp, objs)
            %% MAXIMUM returns the ImagingComponent from an ImagingComposite with the maximum queried property
            %  imaging_component = maximum(property, imaging_composite)
            
            import mlfourd.* mlchoosers.*;
            imcmp = ImageFilters.extremum(@gt, prp, ...
                    ImagingComponent.load(objs));
        end % static maximum
        function imcmp = minimum(prp, objs)
            %% MINIMUM returns the ImagingComponent from an ImagingComposite with the minimum queried property
            %  imaging_component = minimum(property, imaging_composite)
            
            import mlfourd.* mlchoosers.*;
            imcmp = ImageFilters.extremum(@lt, prp, ...
                    ImagingComponent.load(objs));
        end % static minimum
        function imcmp = mostEntropy(imcmp)
            imcmp = mlchoosers.ImageFilters.maximum('entropy', imcmp);
        end
        function imcmp = leastEntropy(imcmp)
            imcmp = mlchoosers.ImageFilters.maximum('negentropy', imcmp);
        end
        function imcmp = mostPixels(imcmp)
            try
                imcmp = mlchoosers.ImageFilters.maximum('prodSize', imcmp);
            catch ME
                handexcept(ME);
            end
        end
        function imcmp = notIsBetted(imcmp)
            imcmp = mlchoosers.ImageFilters.isBetted(imcmp, true);
        end
        function imcmp = notIsFlirted(imcmp)
            imcmp = mlchoosers.ImageFilters.isFlirted(imcmp, true);
        end
        function imcmp = notIsMcf(imcmp)
            imcmp = mlchoosers.ImageFilters.isMcf(imcmp, true);
        end
        function imcmp = notIsMr(imcmp)
            imcmp = mlchoosers.ImageFilters.isMr(imcmp, true);
        end
        function imcmp = notIsPet(imcmp)
            imcmp = mlchoosers.ImageFilters.isPet(imcmp, true);
        end
        function imcmp = smallestVoxels(imcmp)
            imcmp = mlchoosers.ImageFilters.minimum('mmppix', imcmp);
        end
        function imcmp = timeDependent(imcmp, varargin)
            import mlfourd.* mlchoosers.*;
            p     = ImageFilters.filterParser(imcmp, varargin{:}); 
            imcmp = ImageFilters.imagingComponentFilter(@criteria, imcmp);
            
            function imcmp = criteria(imcmp0)
                imcmp = [];
                if (p.Results.positive)
                    if (imcmp0.duration > 3)
                        imcmp = imcmp0;
                    end
                else
                    if (1 == imcmp0.duration)
                        imcmp = imcmp0;
                    end
                end
            end
        end
    end
    
    %% PRIVATE
    
    methods (Static, Access = 'private')
        function imcmp = extremum(ineq, prp, imcmp0)
            assert(ischar(prp));
            if (length(imcmp0) < 2)
                imcmp = imcmp0;
            else
                import mlfourd.*;
                imcmp = ImagingComponent.load(imcmp0{1});
                for f = 2:length(imcmp0)
                    if (~isempty(imcmp0{f}))
                        if (  ineq(metric(imcmp0{f}), metric(imcmp)))
                            % replace
                            imcmp = ImagingComponent.load(imcmp0{f});
                        elseif (eq(metric(imcmp0{f}), metric(imcmp)))
                            % append
                            imcmp = imcmp.add(imcmp0{f});
                        end
                    end
                end
            end
            imcmp = mlfourd.ImagingComponent.load(imcmp);
            
            function m = metric(imcmp)
                m = norm(imcmp.(prp),2);
            end 
        end % static extremum        
        function p     = filterParser(imcmp, varargin)
            p = inputParser;
            addRequired(p, 'imcmp', @isimcmp);
            addOptional(p, 'positive', true, @islogical);
            parse(p, imcmp, varargin{:});
        end % static filterParser
        function imcmp = imagingComponentFilter(fhandle, imcmp0)
            import mlfourd.* mlchoosers.*;
            if (length(imcmp0) < 2)
                obj = ImagingSeries.createFromINIfTI(imcmp0.cachedNext);
            else
                cal = mlfourd.ImagingArrayList;
                for f = 1:length(imcmp0)
                    tmp = fhandle(imcmp0{f});
                    if (~isempty(tmp))
                        cal.add(tmp);
                    end
                end
                obj = ImagingComponent.load(cal);
            end
            imcmp = ImagingComponent.load(obj);
        end % static imagingComponentFilter
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

