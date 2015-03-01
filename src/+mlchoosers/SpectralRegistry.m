classdef SpectralRegistry < mlpatterns.Singleton
	%% SPECTRALREGISTRY 

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id$ 
	
    properties (Constant)
        ADC  = 'adc'
        ASE  = 'ase'
        ASL  = 'asl'
        CASL = 'casl'
        CISS = 'ciss'
        C15O = 'co'
        DWI  = 'dwi'
        EP2D = 'ep2d'
        EPI  = 'epi'
        FLAIR = 'flair'
        IR   = 'ir'
        GRE  = 'gre'
        H15O = 'ho'
        MPR  = 'mpr'
        MPRAGE = 'mprage'
        O15O = 'oo'
        PASL = 'pasl'
        PCASL = 'pcasl'
        SWI  = 'swi'
        T1   = 't1'
        T2   = 't2'
        TOF  = 'tof'
        TR   = 'tr'
    end 

    methods (Static)
        function this  = instance(qualifier)
            %% INSTANCE uses string qualifiers to switch behaviors 
            
            persistent uniqueInstance            
            if (exist('qualifier','var') && ischar(qualifier))
                switch (qualifier)
                    case 'initialize'
                        uniqueInstance = [];
                    otherwise % assume pnum
                        error('mlfourd:UnsupportedParamValue', 'SpectralRegistry.instance.qualifier->%s', qualifier);
                end
            end            
            if (isempty(uniqueInstance))
                this = mlchoosers.SpectralRegistry;
                uniqueInstance = this;
            else
                this = uniqueInstance;
            end
        end    
    end
    
    %% PRIVATE
    
	methods (Access = 'private')
 		function this = SpectralRegistry
            this = this@mlpatterns.Singleton;
 		end % ctor
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

