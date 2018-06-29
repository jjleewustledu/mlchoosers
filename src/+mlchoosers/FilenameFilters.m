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
            [~,fname] = filepartsx(fname, mlfourd.NIfTId.FILETYPE_EXT);
            [~,trial] = strtok(fname, '_');
            idx       = NaN;
            try
                trial = trial(2:4);
                idx   = str2double(trial);
            catch ME
                %%% handwarning(ME);
            end
        end         
 		function fn  = brightest(fns0)
            import mlfourd.* mlchoosers.*;
            imcmp = ImageFilters.brightest( ...
                    ImagingComponent.load(fns0));
            fn = imcmp.fqfilename; 
        end
        function fn  = highestSeriesNumber(fns0)
            import mlfourd.* mlchoosers.*;
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
        end
        function fns = isAtlas(fns0, varargin)
            patt = mlfourd.NamingRegistry.mniNames;
            fns = mlchoosers.FilenameFilters.isSomething(patt, fns0, varargin{:});
        end
        function fns = isBetted(fns0, not)
            fns0 = ensureCell(fns0);
            if (~exist('not','var'))
                not = false; 
            end
            fns  = {};
            if (~not)                    
                for f = 1:length(fns0)
                    if (mlfsl.BetBuilder.isbetted(fns0{f}))
                        fns = [fns fns0{f}];  %#ok<*AGROW>
                    end
                end
            else                    
                for f = 1:length(fns0)
                    if (~mlfsl.BetBuilder.isbetted(fns0{f}))
                        fns = [fns fns0{f}];
                    end
                end
            end
            if (1 == length(fns))
                fns = fns{1}; end
        end
        function fns = isFlirted(fns0, varargin)
            patt = mlfsl.FslRegistry.INTERIMAGE_TOKEN;             
            fns = mlchoosers.FilenameFilters.isSomething(patt, fns0, varargin{:});
        end
        function fns = isMcf(fns0, varargin)
            patt = mlfsl.FlirtVisitor.MCF_SUFFIX;
            fns = mlchoosers.FilenameFilters.isSomething(patt, fns0, varargin{:});
        end
        function fns = isMr(fns0, varargin)
            patt = mlfourd.NamingRegistry.FSL_NAMES;
            fns = mlchoosers.FilenameFilters.isSomething(patt, fns0, varargin{:});
        end
        function fns = isPet(fns0, varargin)
            import mlchoosers.* mlfourd.*;
            fns0    = ensureCell(fns0);
            pth0    = fileparts(fns0{1});
            fps     = FilenameFilters.isSomeFileprefix( ...
                      NamingRegistry.instance.tracerIds, fns0, varargin{:});
            fns     = cellfun(@(x) fullfile(pth0, x), filenames(fps), 'UniformOutput', false);
        end
        function fps = isSomeFileprefix(pattlist, fns0, not)
            import mlchoosers.*;
            fns0 = ensureCell(fns0);
            if (~exist('not','var'))
                not = false; end
            [~,fps] = cellfun(@(x) myfileparts(x), fns0, 'UniformOutput', false);
            fps     = FilenameFilters.isSomethingStartingWith( ...
                      pattlist, fps, not);
        end
        function fns = isSomething(pattlist, fns0, not)
            fns0 = ensureCell(fns0);
            if (~exist('not','var'))
                not = false; end
            fns = {};
            if (~not)
                for f = 1:length(fns0)
                    if (lstrfind(fns0{f}, pattlist))
                        fns = [fns fns0{f}]; end
                end
            else                
                for f = 1:length(fns0)
                    if (~lstrfind(fns0{f}, pattlist))
                        fns = [fns fns0{f}]; end
                end
            end
            if (1 == length(fns))
                fns = fns{1}; end
        end
        function fns = isSomethingStartingWith(pattlist, fns0, not)
            fns0 = ensureCell(fns0);
            if (~exist('not','var'))
                not = false; end
            fns = {};
            if (~not)
                for f = 1:length(fns0)
                    for p = 1:length(pattlist)
                        if (strncmp(fns0{f}, pattlist{p}, length(pattlist{p})))
                            fns = [fns fns0{f}]; end
                    end
                end
            else                
                for f = 1:length(fns0)
                    for p = 1:length(pattlist)
                        if (strncmp(fns0{f}, pattlist{p}, length(pattlist{p})))
                            fns = [fns fns0{f}]; end
                    end
                end
            end
            if (1 == length(fns))
                fns = fns{1}; end
        end
        function fn  = leastEntropy(fns0)
            import mlfourd.* mlchoosers.*;
            fn = FilenameFilters.imagingComponent2filenames( ...
                 ImageFilters.leastEntropy( ...
                 ImagingComponent.load(fns0)));
            % fn = ensureMatchedFileFormat(fn, ensureChar(fns0));
        end
        function fns = longestDuration(fns0)
            import mlfourd.* mlchoosers.*;
            fns = FilenameFilters.imagingComponent2filenames( ...
                  ImageFilters.longestDuration( ...
                  ImagingComponent.load(fns0)));
            %fns = ensureMatchedFileFormat(fns, fns0);
        end
        function fn  = lowestSeriesNumber(fns0)
            import mlfourd.* mlchoosers.*;
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
            import mlfourd.* mlchoosers.*;
            fns = FilenameFilters.imagingComponent2filenames( ...
                  ImageFilters.maximum(prp, ...
                  ImagingComponent.load(fns0)));
        end
        function fns = minimum(prp, fns0)
            import mlfourd.* mlchoosers.*;
            fns = FilenameFilters.imagingComponent2filenames( ...
                  ImageFilters.minimum(prp, ...
                  ImagingComponent.load(fns0)));
            % fns = ensureMatchedFileFormat(fns, fns0);
        end
        function fn  = mostEntropy(fns0)
            import mlfourd.* mlchoosers.*;
            fn = FilenameFilters.imagingComponent2filenames( ...
                 ImageFilters.mostEntropy( ...
                 ImagingComponent.load(fns0)));
            % fn = ensureMatchedFileFormat(fn, ensureChar(fns0));
        end
        function fns = mostPixels(fns0)
            import mlfourd.* mlchoosers.*;
            fns = FilenameFilters.imagingComponent2filenames( ...
                  ImageFilters.mostPixels( ...
                  ImagingComponent.load(fns0)));
        end
        function fns = notIsAtlas(fns0)
            patt = mlfourd.NamingRegistry.mniNames;
            fns = mlchoosers.FilenameFilters.notIsSomething(patt, fns0);
        end
        function fns = notIsBetted(fns0)
            fns = mlchoosers.FilenameFilters.isBetted(fns0, false);
            % fns = ensureMatchedFileFormat(fns, fns0);
        end
        function fns = notIsFlirted(fns0)
            patt = mlfsl.FslRegistry.INTERIMAGE_TOKEN;            
            fns = mlchoosers.FilenameFilters.notIsSomething(patt, fns0);
        end
        function fns = notIsMcf(fns0)
            patt = mlfsl.FlirtBuilder.MCF_SUFFIX;
            fns = mlchoosers.FilenameFilters.notIsSomething(patt, fns0);
        end
        function fns = notIsMr(fns0)
            patt = mlfourd.NamingRegistry.FSL_NAMES;
            fns = mlchoosers.FilenameFilters.notIsSomething(patt, fns0);
        end
        function fns = notIsPet(fns0)
            patt = mlfourd.NamingRegistry.instance.tracerIds;
            fns = mlchoosers.FilenameFilters.notIsSomething(patt, fns0);
        end
        function fns = notIsSomething(pattlist, fns0)
            fns = mlchoosers.FilenameFilters.isSomething(pattlist, fns0, false);
            %fns = ensureMatchedFileFormat(fns, fns0);
        end
        function fns = smallestVoxels(fns0)
            import mlfourd.* mlchoosers.*;
            fns = FilenameFilters.imagingComponent2filenames( ...
                  ImageFilters.smallestVoxels( ...
                  ImagingComponent.load(fns0)));
            %fns = ensureMatchedFileFormat(fns, fns0);
        end
        function fns = timeDependent(fns0)
            import mlfourd.* mlchoosers.*;
            fns = FilenameFilters.imagingComponent2filenames( ...
                  ImageFilters.timeDependent( ...
                  ImagingComponent.load(fns0)));
            %fns = ensureMatchedFileFormat(fns, fns0);
        end  
        function fns = timeIndependent(fns0)
            import mlfourd.* mlchoosers.*;
            fns = FilenameFilters.imagingComponent2filenames( ...
                  ImageFilters.timeIndependent( ...
                  ImagingComponent.load(fns0)));
            %fns = ensureMatchedFileFormat(fns, fns0);
        end  
    end 
    
    %% PRIVATE
    
    methods (Static, Access = 'private')
        function fns = imagingComponent2filenames(imcmp)
            assert(isa(imcmp, 'mlfourd.ImagingComponent'));
            fns   = cell(1,length(imcmp));
            for c = 1:length(imcmp)
                fns{c} = imcmp{c}.fqfilename;
            end
        end   
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end



