classdef FilenameFilters < mlchoosers.ImagingChoosersInterface
	%% FILENAMEFILTERS selects filenames by criteria for filecontents
	%  Version $Revision: 2467 $ was created $Date: 2013-08-10 21:27:41 -0500 (Sat, 10 Aug 2013) $ by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-08-10 21:27:41 -0500 (Sat, 10 Aug 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/FilenameFilters.m $
 	%  Developed on Matlab 7.14.0.739 (R2012a)
 	%  $Id: FilenameFilters.m 2467 2013-08-11 02:27:41Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

	methods (Static) 
        function fns = fileprefixPattern(fns0)
            dt = mlsystem.DirTool(fns0);
            fns = dt.fqfns;
        end
        function idx = getSeriesNumber(fname)
            assert(ischar(fname), 'FilenameFilters.getSeriesNumber.fname->%s', class(fname));
            [~,fname] = filepartsx(fname, mlfourd.NIfTIInterface.FILETYPE_EXT);
            [~,trial] = strtok(fname, '_');
            idx       = NaN;
            try
                trial = trial(2:4);
                idx   = str2double(trial);
            catch ME
                handwarning(ME);
            end
        end 
        
 		function fn  = brightest(fns0)
            import mlfourd.*;
            imcmp = ImageFilters.brightest( ...
                    ImagingComponent.load(fns0));
            fn = imcmp.filename; % ensureMatchedFileFormat(imcmp, ensureChar(fns0));
        end
        function fn  = highestSeriesNumber(fns0)
            import mlfourd.*;
            fns0    = ensureCell(fns0);
            fn      = fns0{1};
            highest = -Inf;
            for f = 1:length(fns0)
                sn = FilenameFilters.getSeriesNumber(fns0{f});
                if (~isnan(sn) && sn > highest)
                    highest = sn;
                    fn = fns0{f};
                end
            end
            % fn = ensureMatchedFileFormat(fn, ensureChar(fns0));
        end
        function fns = isAtlas(fns0, varargin)
            namelist = mlfourd.NamingRegistry.mniNames;
            fns = mlfourd.FilenameFilters.isSomething(namelist, fns0, varargin{:});
        end
        function fns = isBetted(fns0, varargin)
            import mlfourd.*;
            p   = FilenameFilters.filterParser(fns0, varargin{:});
            fns = FilenameFilters.filenameFilter(@criteria, fns0);
            %fns = ensureMatchedFileFormat(fns, fns0);
              
            function fn = criteria(fn0)
                import mlfsl.*;
                fn = '';
                if (p.Results.positive)
                    if ( BetBuilder.isbetted(fn0))
                        fn = fn0; return
                    end
                else
                    if (~BetBuilder.isbetted(fn0))
                        fn = fn0; return
                    end
                end
            end
        end
        function fns = isFlirted(fns0, varargin)
            namelist = mlchoosers.ImagingChoosersInterface.INTERIMAGE_TOKEN;             
            fns = mlfourd.FilenameFilters.isSomething(namelist, fns0, varargin{:});
        end
        function fns = isMcf(fns0, varargin)
            namelist = mlfsl.FlirtBuilder.MCF_SUFFIX;
            fns = mlfourd.FilenameFilters.isSomething(namelist, fns0, varargin{:});
        end
        function fns = isMr(fns0, varargin)
            namelist = mlfourd.NamingRegistry.FSL_NAMES;
            fns = mlfourd.FilenameFilters.isSomething(namelist, fns0, varargin{:});
        end
        function fns = isPet(fns0, varargin)
            namelist = mlfourd.NamingRegistry.instance.tracerIds;
            fns = mlfourd.FilenameFilters.isSomething(namelist, fns0, varargin{:});
        end
        function fns = isSomething(pattlist, fns0, varargin)
            import mlfourd.*;
            if (isempty(fns0)); fns = fns0; return; end
            fns0 = ensureCell(fns0);
            p    = FilenameFilters.filterParser(fns0, varargin{:});
            fns  = FilenameFilters.filenameFilter(@criteria, p.Results.fns);
            %fns  = ensureMatchedFileFormat(fns, p.Results.fns);
              
            function fn = criteria(fn0)
                fn = '';
                if (p.Results.positive)
                    if ( lstrfind(fn0, pattlist))
                        fn = fn0; return
                    end
                else
                    if (~lstrfind(fn0, pattlist))
                        fn = fn0; return
                    end
                end
            end
        end
        function fn  = leastEntropy(fns0)
            import mlfourd.*;
            fn = FilenameFilters.imagingComponentFilenames( ...
                 ImageFilters.leastEntropy( ...
                 ImagingComponent.load(fns0)));
            % fn = ensureMatchedFileFormat(fn, ensureChar(fns0));
        end
        function fns = longestDuration(fns0)
            import mlfourd.*;
            fns = FilenameFilters.imagingComponentFilenames( ...
                  ImageFilters.longestDuration( ...
                  ImagingComponent.load(fns0)));
            %fns = ensureMatchedFileFormat(fns, fns0);
        end
        function fn  = lowestSeriesNumber(fns0)
            import mlfourd.*;
            fns0   = ensureCell(fns0);
            fn     = fns0{1};
            lowest = Inf;
            for f = 1:length(fns0)
                sn = FilenameFilters.getSeriesNumber(fns0{f});
                if (~isnan(sn) && sn < lowest)
                    lowest = sn;
                    fn = fns0{f};
                end
            end
            % fn = ensureMatchedFileFormat(fn, ensureChar(fns0));
        end
        function fns = maximum(prp, fns0)
            import mlfourd.*;
            fns = FilenameFilters.imagingComponentFilenames( ...
                  ImageFilters.maximum(prp, ...
                  ImagingComponent.load(fns0)));
        end
        function fns = minimum(prp, fns0)
            import mlfourd.*;
            fns = FilenameFilters.imagingComponentFilenames( ...
                  ImageFilters.minimum(prp, ...
                  ImagingComponent.load(fns0)));
            % fns = ensureMatchedFileFormat(fns, fns0);
        end
        function fn  = mostEntropy(fns0)
            import mlfourd.*;
            fn = FilenameFilters.imagingComponentFilenames( ...
                 ImageFilters.mostEntropy( ...
                 ImagingComponent.load(fns0)));
            % fn = ensureMatchedFileFormat(fn, ensureChar(fns0));
        end
        function fns = mostPixels(fns0)
            import mlfourd.*;
            fns = FilenameFilters.imagingComponentFilenames( ...
                  ImageFilters.mostPixels( ...
                  ImagingComponent.load(fns0)));
        end
        function fns = notIsAtlas(fns0)
            namelist = mlfourd.NamingRegistry.mniNames;
            fns = mlfourd.FilenameFilters.notIsSomething(namelist, fns0);
        end
        function fns = notIsBetted(fns0)
            fns = mlfourd.FilenameFilters.isBetted(fns0, false);
            % fns = ensureMatchedFileFormat(fns, fns0);
        end
        function fns = notIsFlirted(fns0)
            namelist = mlchoosers.ImagingChoosersInterface.INTERIMAGE_TOKEN;            
            fns = mlfourd.FilenameFilters.notIsSomething(namelist, fns0);
        end
        function fns = notIsMcf(fns0)
            namelist = mlfsl.FlirtBuilder.MCF_SUFFIX;
            fns = mlfourd.FilenameFilters.notIsSomething(namelist, fns0);
        end
        function fns = notIsMr(fns0)
            namelist = mlfourd.NamingRegistry.FSL_NAMES;
            fns = mlfourd.FilenameFilters.notIsSomething(namelist, fns0);
        end
        function fns = notIsPet(fns0)
            namelist = mlfourd.NamingRegistry.instance.tracerIds;
            fns = mlfourd.FilenameFilters.notIsSomething(namelist, fns0);
        end
        function fns = notIsSomething(pattlist, fns0)
            fns = mlfourd.FilenameFilters.isSomething(pattlist, fns0, false);
            %fns = ensureMatchedFileFormat(fns, fns0);
        end
        function fns = smallestVoxels(fns0)
            import mlfourd.*;
            fns = FilenameFilters.imagingComponentFilenames( ...
                  ImageFilters.smallestVoxels( ...
                  ImagingComponent.load(fns0)));
            %fns = ensureMatchedFileFormat(fns, fns0);
        end
        function fns = timeDependent(fns0)
            import mlfourd.*;
            fns = FilenameFilters.imagingComponentFilenames( ...
                  ImageFilters.timeDependent( ...
                  ImagingComponent.load(fns0)));
            %fns = ensureMatchedFileFormat(fns, fns0);
        end  
    end 
    
    %% PRIVATE
    
    methods (Static, Access = 'private')
        function fns = imagingComponentFilenames(imcmp)
            assert(isa(imcmp, 'mlfourd.ImagingComponent'));
            fns   = cell(1,length(imcmp));
            for c = 1:length(imcmp)
                fns{c} = imcmp{c}.fqfilename;
            end
        end % imagingComponentFilenames           
        function p   = filterParser(fns, varargin)
            p = inputParser;
            addRequired(p, 'fns', @iscell);
            addOptional(p, 'positive', true, @islogical);
            parse(p, fns, varargin{:});
        end % static filterParser
        function fns = filenameFilter(fhandle, fns0)
            fns = {};
            g   = 1;
            for f = 1:length(fns0)
                tmp = fhandle(fns0{f});
                if (~isempty(tmp))
                    fns{g} = tmp; %#ok<AGROW>
                    g      = g +1 ;
                end
            end
        end % static filenameFilter
        function str = someIsName(name)
            assert(~isempty(name));
            str = ['is' upper(name(1)) lower(name(2:end))];
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

