classdef Test_ImagingChoosers < MyTestCase
	%% TEST_IMAGINGCHOOSERS 
	%  Usage:  >> runtests tests_dir 
	%          >> runtests mlfourd.Test_ImagingChoosers % in . or the matlab path
	%          >> runtests mlfourd.Test_ImagingChoosers:test_nameoffunc
	%          >> runtests(mlfourd.Test_ImagingChoosers, Test_Class2, Test_Class3, ...)
	%  See also:  package xunit

	%  $Revision$
 	%  was created $Date$
 	%  by $Author$, 
 	%  last modified $LastChangedDate$
 	%  and checked into repository $URL$, 
 	%  developed on Matlab 8.1.0.604 (R2013a)
 	%  $Id$
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

	
	properties
        imp
    end
    
	methods         
        function test_theInputParser(this) 
            p = this.imp.theInputParser( ...
                'path', this.fslPath, 'returnType', 'fileprefix', 'fileprefixPattern', 't1_*');
            assertEqual(this.fslPath, p.Results.path);
            assertEqual('fileprefix', p.Results.returnType);
            assertEqual('t1_*',       p.Results.fileprefixPattern);
        end
        function test_ctor(this)
            assert(isa(this.imp, 'mlchoosers.ImagingChoosers'));
        end
        
 		function this = Test_ImagingChoosers(varargin) 
 			this = this@MyTestCase(varargin{:}); 
            this.imp = mlchoosers.ImagingChoosers(this.fslPath);
        end % ctor  
        
        
        function startUp(this)
            this.imp = this.imp.clearCache;
        end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

