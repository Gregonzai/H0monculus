package CoSo;
use Dancer ':syntax';
use File::Spec;
use File::Slurp::Unicode;
use RDF::Trine;
use RDF::Query;
use Data::Dumper qw<Dumper>;
use Encode;
use utf8;
use URI::Encode qw<uri_decode>;

our $VERSION = '0.1';

# colors
my $colors = {
	'<http://anat.org/anat-region>'                      => '#e6e6e6',
	'<http://anat.org/anat-region-UC>'    	             => '#e6e6e6',
	'<http://anat.org/anat-sous-region-UC>'              => '#e6e6e6',
	'<http://anat.org/anat-region-ceinture>'             => '#e6e6e6',
	'<http://anat.org/anat-region-apendiculaire>'        => '#e6e6e6',
	'<http://anat.org/anat-region-sgmt>'                 => '#e6e6e6',
	'<http://anat.org/anat-region-arti>'                 => '#e6e6e6',
	'<http://anat.org/MS-region-anat>'    	             => '#dfcacc',
	'<http://anat.org/Sys-support-mvt>'                  => '#dfcacc',
	'<http://anat.org/MS-region-paroi-cavite-ant>'       => '#dfcacc',
	'<http://anat.org/MS-region-paroi-cavite-post>'      => '#dfcacc',
	'<http://anat.org/MS-paroi-ant>'    	             => '#d4b9bd',
	'<http://anat.org/MS-axe-central>'    	             => '#dfcacc',
	'<http://anat.org/MS-paroi-post>'    	             => '#e9dadb',
	'<http://anat.org/MS-region-3-membres>'    	     => '#9b9feb',
	'<http://anat.org/MS-region-9-cplx-arti>'    	     => '#d883cf',
	'<http://anat.org/cavite>'                           => '#6b6b6b',
	'<http://anat.org/cavite-ant>'                       => '#6b6b6b',
	'<http://anat.org/sinus-aerien>'                     => '#6b6b6b',
	'<http://anat.org/cavite-ext>'                       => '#6b6b6b',
	'<http://anat.org/cavite-post>'                      => '#6b6b6b',
	'<http://anat.org/monde-ext>'                        => '#000000',
	'<http://anat.org/OA-region-anat>'    	             => '#eeddb8',
	'<http://anat.org/Sys-support-arti>'                 => '#eeddb8',
	'<http://anat.org/OA-paroi-ant>'    	             => '#e8d2a3',
	'<http://anat.org/OA-axe-central>'    	             => '#eeddb8',
	'<http://anat.org/OA-paroi-post>'    	             => '#f5e8ce',
	'<http://anat.org/OS-region-anat>'    	             => '#cecece',
	'<http://anat.org/Sys-support>'    	             => '#cecece',
	'<http://anat.org/OS-paroi-ant>'    	             => '#bfbfbf',
	'<http://anat.org/OS-axe-central>'    	             => '#cecece',
	'<http://anat.org/OS-paroi-post>'    	             => '#dddddd',
	'<http://anat.org/ARTI-region-anat>'   	             => '#f7f5aa',
	'<http://anat.org/Sys-glissement>'   	             => '#f7f5aa',
	'<http://anat.org/ARTI-paroi-ant>'    	             => '#f5f193',
	'<http://anat.org/ARTI-axe-central>'   	             => '#f7f5aa',
	'<http://anat.org/ARTI-paroi-post>'    	             => '#fcf7c2',
	'<http://anat.org/LGMT-region-anat>'   	             => '#e9f1b7',
	'<http://anat.org/Sys-organisation-arti>'            => '#e9f1b7',
	'<http://anat.org/LGMT-paroi-ant>'    	             => '#e2eca2',
	'<http://anat.org/LGMT-axe-central>'   	             => '#e9f1b7',
	'<http://anat.org/LGMT-paroi-post>'    	             => '#f1f6cc',
	'<http://anat.org/MSCL-region-anat>'   	             => '#fcd8e3',
	'<http://anat.org/Sys-mobilisateur>'                 => '#fcd8e3',
	'<http://anat.org/MSCL-paroi-ant>'    	             => '#fccbda',
	'<http://anat.org/MSCL-axe-central>'   	             => '#fcd8e3',
	'<http://anat.org/MSCL-paroi-post>'    	             => '#fde4ec',
	'<http://anat.org/bone>'    	                     => '#8c9291',
	'<http://anat.org/short-bone>'    	             => '#8c9291',
	'<http://anat.org/long-bone>'    	             => '#8c9291',
	'<http://anat.org/flat-bone>'    	             => '#8c9291',
	'<http://anat.org/mini-bone>'    	             => '#8c9291',
	'<http://anat.org/sesamoid-bone>'    	             => '#8c9291',
	'<http://anat.org/bone-group>'			     => '#8c9291',
	'<http://anat.org/bone-structure>'    	             => '#a7a8a8',
	'<http://anat.org/bone-meta-structure>'              => '#a7a8a8',
	'<http://anat.org/dent>'			     => '#a7a8a8',
	'<http://anat.org/dent-groupe>'			     => '#a7a8a8',
	'<http://anat.org/bone-description>'		     => '#d5d5d5',
	'<http://anat.org/bone-foramen>'		     => '#d5d5d5',
	'<http://anat.org/bone-canal>'			     => '#d5d5d5',
	'<http://anat.org/surf-insrt-mscl>'	             => '#cf7585',
	'<http://anat.org/surf-insrt-lgmt>'	             => '#b8c285',
	'<http://anat.org/surf-insrt-capsule-arti>'          => '#b8c285',
	'<http://anat.org/surf-insrt-bourse-arti>'           => '#b8c285',
	'<http://anat.org/surface-articulaire>'              => '#dbd023',
	'<http://anat.org/cartilage-articulaire>'            => '#dbd023',
	'<http://anat.org/carti-structure>'   	             => '#c7be36',
	'<http://anat.org/ligament>'   	                     => '#abc235',
	'<http://anat.org/groupe-ligamentaire>'              => '#abc235',
	'<http://anat.org/capsule-arti>'                     => '#abc235',
	'<http://anat.org/bourse-synoviale>'                 => '#abc235',
	'<http://anat.org/str-diaphragmatiq>'                => '#cf2d49',
	'<http://anat.org/muscle>'   	                     => '#ba1327',
	'<http://anat.org/chef-musculaire>'                  => '#ba1327',
	'<http://anat.org/tendon>'    	                     => '#cf7585',
	'<http://anat.org/attache-musculaire>'               => '#cf7585',
	'<http://anat.org/groupe-tendineux>'                 => '#cf7585',
	'<http://anat.org/muscle-visceral>'		     => '#de5c3b',
	'<http://anat.org/muscle-visceral-volontaire>'       => '#de5c3b',
	'<http://anat.org/groupe-musculaire>'                => '#ba1327',
	'<http://anat.org/fascia>'    	                     => '#dfcacc',
	'<http://anat.org/Sys-Organique>'    	             => '#f4dcc3',
	'<http://anat.org/glande-dig>'    	             => '#c8673a',
#	'<http://anat.org/glande-oeil>'    	             => '#',
	'<http://anat.org/glande-repro>'    	             => '#cc75b7',
#	'<http://anat.org/glande-endo-ant>'    	             => '#',
#	'<http://anat.org/glande-endo-post>'    	     => '#',
	'<http://anat.org/Sys-liquidien>'    	             => '#ffd6db',
	'<http://anat.org/circu-sanguine>'    	             => '#ffbcda',
	'<http://anat.org/artr-circu-sanguine>'    	     => '#f69a88',
	'<http://anat.org/vein-circu-sanguine>'    	     => '#c1cbff',
	'<http://anat.org/capi-circu-sanguine>'    	     => '#e4a9ff',
	'<http://anat.org/circu-nourriciere>'    	     => '#ffbcda',
	'<http://anat.org/artr-circu-nourriciere>'    	     => '#f69a88',
	'<http://anat.org/vein-circu-nourriciere>'    	     => '#c1cbff',
	'<http://anat.org/capi-circu-nourriciere>'    	     => '#e4a9ff',
	'<http://anat.org/circu-fonctionnelle>'    	     => '#ffbcda',
	'<http://anat.org/artr-circu-fonctionnelle>'         => '#f69a88',
	'<http://anat.org/vein-circu-fonctionnelle>'         => '#c1cbff',
	'<http://anat.org/capi-circu-fonctionnelle>'         => '#e4a9ff',
	'<http://anat.org/organe-sanguin>'    	             => '#ff2d34',
	'<http://anat.org/organe-sanguin-subdi>'    	     => '#ff2d34',
	'<http://anat.org/artere>'    	                     => '#ff0000',
	'<http://anat.org/veine>'    	                     => '#002aff',
	'<http://anat.org/capilaires>'    	             => '#9c00ff',
	'<http://anat.org/Sys-liquidien-para>'    	     => '#ceebb4',
	'<http://anat.org/sous-sys-liquidien-para>'    	     => '#ceebb4',
	'<http://anat.org/organe-lymph>' 	   	     => '#78c730',
	'<http://anat.org/organe-lymph-1aire>'    	     => '#78c730',
	'<http://anat.org/organe-lymph-1aire-subdi>'   	     => '#78c730',
	'<http://anat.org/organe-lymph-2aire>'    	     => '#949160',
	'<http://anat.org/organe-lymph-2aire-subdi>'   	     => '#949160',
	'<http://anat.org/ganglion-lymph>'    	             => '#949160',
	'<http://anat.org/tissu-lymph-muqueuse>'	     => '#949160',
	'<http://anat.org/vaisseau-lymph>'    	             => '#5aff00',
	'<http://anat.org/Sys-transition>'    	             => '#f4dcc3',
	'<http://anat.org/Sys-echange-air>'    	             => '#e2f3ff',
	'<http://anat.org/sous-sys-echange-air>'     	     => '#e2f3ff',
	'<http://anat.org/organe-respi>'    	             => '#7499ff',
	'<http://anat.org/organe-respi-subdi>'    	     => '#7499ff',
	'<http://anat.org/conduit-air>'    	             => '#c6e6ff',
	'<http://anat.org/gd-conduit-air>'    	             => '#c6e6ff',
	'<http://anat.org/Sys-assimilation>'   	             => '#f2be9d',
	'<http://anat.org/sous-sys-assimilation>'            => '#f2be9d',
	'<http://anat.org/organe-dig>'   	             => '#c8673a',
	'<http://anat.org/organe-dig-subdi>'   	             => '#c8673a',
	'<http://anat.org/viscere-dig>'   	             => '#e68445',
	'<http://anat.org/viscere-dig-subdi>'   	     => '#e68445',
	'<http://anat.org/conduit-dig>'   	             => '#e68445',
	'<http://anat.org/gd-conduit-dig>'   	             => '#e68445',
	'<http://anat.org/conduit-salive>'   	             => '#e68445',
	'<http://anat.org/viscere-bile>'   	             => '#9fb038',
	'<http://anat.org/viscere-bile-subdi>'   	     => '#9fb038',
	'<http://anat.org/conduit-bile>'   	             => '#9fb038',
	'<http://anat.org/conduit-suc-pancreas>'   	     => '#e6a145',
	'<http://anat.org/Sys-evacuation>'   	             => '#fff6b2',
	'<http://anat.org/sous-sys-evacuation>'              => '#fff6b2',
	'<http://anat.org/organe-urinaire>'   	             => '#ffba00',
	'<http://anat.org/organe-urinaire-subdi>'   	     => '#ffba00',
	'<http://anat.org/viscere-urinaire>'   	             => '#ffe100',
	'<http://anat.org/conduit-urinaire>'   	             => '#ffe100',
	'<http://anat.org/gd-conduit-urinaire>'   	     => '#ffe100',
	'<http://anat.org/conduit-urinaire-subdi>'   	     => '#ffe100',
	'<http://anat.org/Sys-creation>'   	             => '#e5b8da',
	'<http://anat.org/sous-sys-creation>'   	     => '#e5b8da',
	'<http://anat.org/organe-genital>'   	             => '#cc75b7',
	'<http://anat.org/viscere-genital>'   	             => '#e8879f',
	'<http://anat.org/viscere-genital-subdi>'            => '#e8879f',
	'<http://anat.org/conduit-genital>'   	             => '#e8879f',
	'<http://anat.org/gd-conduit-genital>' 	             => '#e8879f',
	'<http://anat.org/Sys-vers-terre>'   	             => '#f4dcc3',
	'<http://anat.org/VASCU-region>'   	             => '#de8ccf',
	'<http://anat.org/ARTR-region>'   	             => '#f69a88',
	'<http://anat.org/VEIN-region>'   	             => '#c1cbff',
	'<http://anat.org/LYMPH-region>'   	             => '#b5ff8c',
	'<http://anat.org/Sys-liquidien-SNC>'    	     => '#e2e293',
	'<http://anat.org/sous-sys-liquidien-SNC>'    	     => '#e2e293',
};
# sizes
my $sizes = {
	'<http://anat.org/anat-region>'    	             => '2',
	'<http://anat.org/anat-region-UC>'    	             => '2',
	'<http://anat.org/anat-sous-region-UC>'              => '1',
	'<http://anat.org/anat-region-ceinture>'             => '2',
	'<http://anat.org/anat-region-apendiculaire>'        => '2',
	'<http://anat.org/anat-region-sgmt>'                 => '1',
	'<http://anat.org/anat-region-arti>'                 => '1',
	'<http://anat.org/MS-region-anat>'    	             => '1',
	'<http://anat.org/Sys-support-mvt>'    	             => '4',
	'<http://anat.org/MS-region-paroi-cavite-ant>'       => '1',
	'<http://anat.org/MS-region-paroi-cavite-post>'      => '1',
	'<http://anat.org/MS-paroi-ant>'    	             => '0',
	'<http://anat.org/MS-axe-central>'    	             => '0',
	'<http://anat.org/MS-paroi-post>'    	             => '0',
	'<http://anat.org/MS-region-3-membres>'    	     => '1',
	'<http://anat.org/MS-region-9-cplx-arti>'    	     => '1',
	'<http://anat.org/cavite>'                           => '1',
	'<http://anat.org/cavite-ant>'                       => '1',
	'<http://anat.org/sinus-aerien>'                     => '1',
	'<http://anat.org/cavite-ext>'                       => '1',
	'<http://anat.org/cavite-post>'                      => '1',
	'<http://anat.org/monde-ext>'                        => '0',
	'<http://anat.org/OA-region-anat>'  	             => '1',
	'<http://anat.org/Sys-support-arti>'           	     => '4',
	'<http://anat.org/OA-paroi-ant>'    	             => '0',
	'<http://anat.org/OA-axe-central>'    	             => '0',
	'<http://anat.org/OA-paroi-post>'    	             => '0',
	'<http://anat.org/OS-region-anat>'    	             => '1',
	'<http://anat.org/Sys-support>'    	             => '4',
	'<http://anat.org/OS-paroi-ant>'    	             => '0',
	'<http://anat.org/OS-axe-central>'    	             => '0',
	'<http://anat.org/OS-paroi-post>'    	             => '0',
	'<http://anat.org/ARTI-region-anat>'                 => '1',
	'<http://anat.org/Sys-glissement>'   	             => '4',
	'<http://anat.org/ARTI-paroi-ant>'    	             => '0',
	'<http://anat.org/ARTI-axe-central>'   	             => '0',
	'<http://anat.org/ARTI-paroi-post>'    	             => '0',
	'<http://anat.org/LGMT-region-anat>'    	     => '1',
	'<http://anat.org/Sys-organisation-arti>'            => '4',
	'<http://anat.org/LGMT-paroi-ant>'    	             => '0',
	'<http://anat.org/LGMT-axe-central>'   	             => '0',
	'<http://anat.org/LGMT-paroi-post>'    	             => '0',
	'<http://anat.org/MSCL-region-anat>'                 => '1',
	'<http://anat.org/Sys-mobilisateur>'                 => '4',
	'<http://anat.org/MSCL-paroi-ant>'    	             => '0',
	'<http://anat.org/MSCL-axe-central>'   	             => '0',
	'<http://anat.org/MSCL-paroi-post>'    	             => '0',
	'<http://anat.org/bone>'    	           	     => '1',
	'<http://anat.org/short-bone>'    	             => '1',
	'<http://anat.org/long-bone>'    	             => '1',
	'<http://anat.org/flat-bone>'    	             => '1',
	'<http://anat.org/mini-bone>'    	             => '0',
	'<http://anat.org/sesamoid-bone>'    	             => '0',
	'<http://anat.org/bone-group>'			     => '1',
	'<http://anat.org/bone-structure>'		     => '0',
	'<http://anat.org/bone-meta-structure>'              => '1',
	'<http://anat.org/bone-description>'		     => '0',
	'<http://anat.org/bone-foramen>'		     => '1',
	'<http://anat.org/bone-canal>'			     => '0',
	'<http://anat.org/dent>'			     => '0',
	'<http://anat.org/dent-groupe>'			     => '1',
	'<http://anat.org/surf-insrt-mscl>'	             => '0',
	'<http://anat.org/surf-insrt-lgmt>'	             => '0',
	'<http://anat.org/surf-insrt-capsule-arti>'          => '0',
	'<http://anat.org/surf-insrt-bourse-arti>'           => '0',
	'<http://anat.org/surface-articulaire>'              => '0',
	'<http://anat.org/cartilage-articulaire>'            => '0',
	'<http://anat.org/carti-structure>'	             => '1',
	'<http://anat.org/ligament>'   	                     => '0',
	'<http://anat.org/groupe-ligamentaire>'              => '1',
	'<http://anat.org/capsule-arti>'                     => '0',
	'<http://anat.org/bourse-synoviale>'                 => '0',
	'<http://anat.org/str-diaphragmatiq>'                => '2',
	'<http://anat.org/muscle>'    	                     => '1',
	'<http://anat.org/chef-musculaire>'                  => '0',
	'<http://anat.org/muscle-visceral-volontaire>'       => '1',
	'<http://anat.org/tendon>'    	                     => '0',
	'<http://anat.org/attache-musculaire>'               => '0',
	'<http://anat.org/groupe-tendineux>'                 => '1',
	'<http://anat.org/groupe-musculaire>'                => '2',
	'<http://anat.org/fascia>'    	                     => '0',
	'<http://anat.org/Sys-Organique>'    	             => '4',
	'<http://anat.org/glande-dig>'    	             => '0',
	'<http://anat.org/glande-oeil>'    	             => '0',
	'<http://anat.org/glande-repro>'    	             => '0',
	'<http://anat.org/glande-endo-ant>'    	             => '0',
	'<http://anat.org/glande-endo-post>'    	     => '0',
	'<http://anat.org/Sys-liquidien>'    	             => '2',
	'<http://anat.org/circu-sanguine>'    	             => '1',
	'<http://anat.org/circu-sanguine-sbdi>'              => '0',
	'<http://anat.org/circu-nourriciere>'    	     => '1',
	'<http://anat.org/circu-nourriciere-subdi>'    	     => '0',
	'<http://anat.org/circu-fonctionnelle>'    	     => '1',
	'<http://anat.org/circu-fonctionnelle-subdi>'        => '0',
	'<http://anat.org/organe-sanguin>'    	             => '3',
	'<http://anat.org/organe-sanguin-subdi>'    	     => '1',
	'<http://anat.org/artere>'    	                     => '0',
	'<http://anat.org/veine>'    	                     => '0',
	'<http://anat.org/capilaires>'    	             => '0',
	'<http://anat.org/Sys-liquidien-para>'    	     => '2',
	'<http://anat.org/sous-sys-liquidien-para>'    	     => '0',
	'<http://anat.org/organe-lymph>'    		     => '0',
	'<http://anat.org/organe-lymph-1aire>'    	     => '3',
	'<http://anat.org/organe-lymph-1aire-subdi>'   	     => '0',
	'<http://anat.org/organe-lymph-2aire>'    	     => '3',
	'<http://anat.org/organe-lymph-2aire-subdi>'   	     => '0',
	'<http://anat.org/ganglion-lymph>'    	             => '0',
	'<http://anat.org/tissu-lymph-muqueuse>'	     => '0',
	'<http://anat.org/vaisseau-lymph>'    	             => '0',
	'<http://anat.org/Sys-transition>'    	             => '0',
	'<http://anat.org/Sys-echange-air>'    	             => '2',
	'<http://anat.org/anat:sous-sys-echange-air>'        => '1',
	'<http://anat.org/organe-respi>'    	             => '3',
	'<http://anat.org/organe-respi-subdi>'    	     => '0',
	'<http://anat.org/conduit-air>'    	             => '0',
	'<http://anat.org/gd-conduit-air>'    	             => '1',
	'<http://anat.org/Sys-assimilation>'   	             => '2',
	'<http://anat.org/sous-sys-assimilation>'            => '1',
	'<http://anat.org/organe-dig>'   	             => '3',
	'<http://anat.org/organe-dig-subdi>'   	             => '0',
	'<http://anat.org/viscere-dig>'   	             => '3',
	'<http://anat.org/viscere-dig-subdi>'   	     => '0',
	'<http://anat.org/conduit-dig>'   	             => '0',
	'<http://anat.org/gd-conduit-dig>'   	             => '1',
	'<http://anat.org/conduit-salive>'   	             => '0',
	'<http://anat.org/viscere-bile>'   	             => '3',
	'<http://anat.org/viscere-bile-subdi>'   	     => '0',
	'<http://anat.org/conduit-bile>'   	             => '0',
	'<http://anat.org/conduit-suc-pancreas>'   	     => '0',
	'<http://anat.org/Sys-evacuation>'   	             => '2',
	'<http://anat.org/sous-sys-evacuation>'              => '1',
	'<http://anat.org/organe-urinaire>'   	             => '3',
	'<http://anat.org/organe-urinaire-subdi>'   	     => '0',
	'<http://anat.org/viscere-urinaire>'   	             => '3',
	'<http://anat.org/conduit-urinaire>'   	             => '0',
	'<http://anat.org/gd-conduit-urinaire>'   	     => '1',
	'<http://anat.org/conduit-urinaire-subdi>'   	     => '0',
	'<http://anat.org/Sys-creation>'   	             => '2',
	'<http://anat.org/sous-sys-creation>'   	     => '1',
	'<http://anat.org/organe-genital>'   	             => '3',
	'<http://anat.org/viscere-genital>'   	             => '3',
	'<http://anat.org/viscere-genital-subdi>'            => '0',
	'<http://anat.org/conduit-genital>'   	             => '0',
	'<http://anat.org/gd-conduit-genital>' 	             => '1',
	'<http://anat.org/Sys-vers-terre>'   	             => '2',
	'<http://anat.org/VASCU-region>'   	             => '1',
	'<http://anat.org/ARTR-region>'   	             => '1',
	'<http://anat.org/VEIN-region>'   	             => '1',
	'<http://anat.org/LYMPH-region>'   	             => '1',
	'<http://anat.org/Sys-liquidien-SNC>'    	     => '2',
	'<http://anat.org/sous-sys-liquidien-SNC>'    	     => '0',
};

my $file = 'h0moncule';

my $store  = RDF::Trine::Store->temporary_store;
my $model  = RDF::Trine::Model->new($store);
my $parser = RDF::Trine::Parser->new('turtle');

my $rdf = read_file($file);
my $uri = 'file://' . File::Spec->rel2abs($file);
$parser->parse_into_model($uri, $rdf, $model);

get '/individuals' => sub {

	my $query = RDF::Query->new( 'SELECT ?subject ?surclass WHERE {
		?subject <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2002/07/owl#Class> .
		OPTIONAL { ?subject <http://www.w3.org/2000/01/rdf-schema#subClassOf> ?surclass }
	}' );
	my $iterator = $query->execute( $model );

	my @classes;
	while (my $row = $iterator->next) {
		my $class = {};
		$$class{subject} = $$row{subject}->as_string;
		$$class{subject} =~ s/^<|>$//g;
		$$class{label} = get_label("<$$class{subject}>");

		add_subclasses($class);

		push @classes, $class if ! $$row{surclass};
	}

	my $query2 = RDF::Query->new( 'SELECT ?subject ?type WHERE {
		?subject <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?type
	}' );
	my $iterator2 = $query2->execute( $model );

	my @data;
	while (my $row = $iterator2->next) {
		my $line = {};
		$$line{subject} = $$row{subject}->as_string;
		$$line{subject} =~ s/^<|>$//g;
		$$line{label} = get_label("<$$line{subject}>");
		$$line{type} = $$row{type}->as_string;
		$$line{type} =~ s/^<|>$//g;
		$$line{typelabel} = get_label("<$$line{type}>");
		push @data, $line if $$line{type} ne 'http://www.w3.org/2002/07/owl#Restriction'
		                 and $$line{type} ne 'http://www.w3.org/2002/07/owl#ObjectProperty'
		                 and $$line{type} ne 'http://www.w3.org/2002/07/owl#Class'
		                 and $$line{type} ne 'http://www.w3.org/2002/07/owl#AllDifferent'
		                 and $$line{type} ne 'http://www.w3.org/2002/07/owl#Ontology'
		                 and $$line{type} ne 'http://www.w3.org/2002/07/owl#FunctionalProperty'
		                 and $$line{type} ne 'http://www.w3.org/2002/07/owl#InverseFunctionalProperty'
		                 and $$line{type} ne 'http://www.w3.org/2002/07/owl#TransitiveProperty'
		                 ;
	}

	template 'individuals.tt', {
		classes => \@classes,
		results => \@data
	};
};

get '/classes' => sub {

	my $query = RDF::Query->new( 'SELECT ?subject ?surclass WHERE {
		?subject <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2002/07/owl#Class> .
		OPTIONAL { ?subject <http://www.w3.org/2000/01/rdf-schema#subClassOf> ?surclass }
	}' );
	my $iterator = $query->execute( $model );

	my @classes;
	while (my $row = $iterator->next) {
		my $class = {};
		$$class{subject} = $$row{subject}->as_string;
		$$class{subject} =~ s/^<|>$//g;
		$$class{label} = get_label("<$$class{subject}>");

		add_subclasses($class);

		push @classes, $class if ! $$row{surclass};
	}

	template 'classes.tt', {
		classes => \@classes,
	};
};

sub count {
	my $uri = shift;

	my $query = RDF::Query->new("SELECT (COUNT(?s) AS ?count) WHERE { ?s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> $uri }");
	my $iterator = $query->execute($model);
	my $row = $iterator->next;

	return $$row{count}->as_string if $$row{count};
}

sub add_subclasses {
	my $parent = shift;
	$$parent{children} = ();

	my $query = RDF::Query->new( "SELECT ?subject WHERE {
		?subject <http://www.w3.org/2000/01/rdf-schema#subClassOf> <$$parent{subject}>
	}" );
	my $iterator = $query->execute( $model );
	while (my $row = $iterator->next) {
		my $class = {};
		$$class{subject} = $$row{subject}->as_string;
		$$class{instances} = count($$class{subject});
		$$class{subject} =~ s/^<|>$//g;
		$$class{label} = get_label("<$$class{subject}>");

		add_subclasses($class);

		push @{$$parent{children}}, $class;
	}
}

get '/graph' => sub {

	my $query = RDF::Query->new( 'SELECT ?s ?p ?o ?st ?ot ?sl ?ol WHERE { 
		?s ?p ?o . 
		OPTIONAL { ?s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?st } .
		OPTIONAL { ?o <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?ot } .
		OPTIONAL { ?s <http://www.w3.org/2000/01/rdf-schema#label> ?sl } .
		OPTIONAL { ?o <http://www.w3.org/2000/01/rdf-schema#label> ?ol } }' );
	my $iterator = $query->execute( $model );

	my @statements;
	while (my $row = $iterator->next) {	
		my $statement = {};
		$$statement{subject} = $$row{s}->as_string;
		$$statement{subject_label} = $$row{sl} ? $$row{sl}->as_string : labelize_uri($$statement{subject});
		$$statement{subject_label} =~ s/^"|"$//g;
		$$statement{subject} =~ s/^<|>$//g;
		$$statement{predicate} = $$row{p}->as_string;
		$$statement{predicate} =~ s/^<|>$//g;
		$$statement{object} = $$row{o}->as_string;
		$$statement{object_label}  = $$row{ol} ? $$row{ol}->as_string : labelize_uri($$statement{object});
		$$statement{object_label} =~ s/^"|"$//g;
		$$statement{object} =~ s/^<|>$//g;

		$$statement{subject_color} = ($$row{st} and $$colors{$$row{st}}) ? $$colors{$$row{st}} : '#000000';
		$$statement{object_color}  = ($$row{ot} and $$colors{$$row{ot}}) ? $$colors{$$row{ot}} : '#000000';

		$$statement{subject_size} = ($$row{st} and $$sizes{$$row{st}}) ? $$sizes{$$row{st}} : '0';
		$$statement{object_size}  = ($$row{ot} and $$sizes{$$row{ot}}) ? $$sizes{$$row{ot}} : '0';

		push @statements, $statement if $$statement{predicate} ne 'http://www.w3.org/2000/01/rdf-schema#label'
									and $$statement{predicate} ne 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'
									and $$statement{predicate} ne 'http://www.w3.org/2000/01/rdf-schema#subClassOf'
									and $$statement{predicate} ne 'http://www.w3.org/2000/01/rdf-schema#range'
									and $$statement{predicate} ne 'http://www.w3.org/2000/01/rdf-schema#domain'
									and $$statement{predicate} ne 'http://www.w3.org/2002/07/owl#inverseOf'
									;
	}

	template 'graph.tt', { statements => \@statements };
};

sub labelize {
	my $node = shift;
	my $label;
	if ( $node->is_literal ) {
		$label = $node->as_string;
		$label =~ s/^"|"$//g;
	} else {
		$label = get_label($node);
	}
	return $label;
}

sub get_label {
	my $uri = shift;
	my $label;
	my $query = RDF::Query->new( "SELECT ?o WHERE { $uri <http://www.w3.org/2000/01/rdf-schema#label> ?o }" );
	my $iterator = $query->execute( $model );
	while (my $row = $iterator->next) {
		$label = $$row{o}->as_string;
		$label =~ s/^"|"$//g;
	}
	$label = labelize_uri($uri) unless $label;
	return $label;
}

sub get_type {
	my $uri = shift;
	my $type;
	my $query = RDF::Query->new( "SELECT ?o WHERE { $uri <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?o }" );
	if ($query) {
		my $iterator = $query->execute( $model );
		while (my $row = $iterator->next) {
			$type = $$row{o}->as_string;
			$type =~ s/^<|>$//g;
		}
	}
	return $type;
}

sub get_surclass {
	my $uri = shift;
	my $breadcrumb = shift;

	my $parent;
	my $query = RDF::Query->new( "SELECT ?o WHERE { $uri <http://www.w3.org/2000/01/rdf-schema#subClassOf> ?o }" );
	my $iterator = $query->execute( $model );
	while (my $row = $iterator->next) {
		$parent = $$row{o}->as_string;
		$parent =~ s/^<|>$//g;
	}

	if ($parent) {
		push @$breadcrumb, { url => $parent, label => get_label("<$parent>") };
		return get_surclass("<$parent>", $breadcrumb);
	} else {
		return $breadcrumb;
	}
}

sub labelize_uri {
	my $uri = shift;
	my $label = decode_utf8(uri_decode($uri));
	$label =~ s/(.*)(\/|\#)(.*?)>$/$3/;
	return $label;
}

sub sinogram_details {
	my $uri = shift;

	my @aspects;
	my $query = RDF::Query->new( "SELECT ?o WHERE { $uri <http://co-so.org/has-meaning-aspect> ?o }" );
	my $iterator = $query->execute( $model );
	while (my $row = $iterator->next) {
		my $aspect = {};
		$$aspect{text} = $$row{o}->as_string;

		my @combinations;
		my $query2 = RDF::Query->new( "SELECT ?sc ?wc ?cm WHERE {
			$uri <http://co-so.org/has-meaning-aspect> $$aspect{text} .
			?sc <http://co-so.org/contains-sinogram> $uri .
			?sc <http://co-so.org/contains-meaning-aspect> $$aspect{text} .
			OPTIONAL { ?sc <http://co-so.org/has-combination-meaning> ?cm } .
			OPTIONAL { ?wc <http://co-so.org/corresponding-vietnamese-sinogram-combination> ?sc } .
		}" );
		my $iterator2 = $query2->execute( $model );
		while (my $row2 = $iterator2->next) {
			my $combination = {};
			$$combination{subject} = $$row2{sc}->as_string;
			$$combination{subject} =~ s/^<|>$//g;
			$$combination{subject_label} = labelize_uri("<$$combination{subject}>");
			$$combination{meaning} = $$row2{cm};
			$$combination{words} = $$row2{wc}->as_string;
			$$combination{words} =~ s/^<|>$//g;
			$$combination{words_label} = get_label("<$$combination{words}>");
			push @combinations, $combination;
		}
		$$aspect{combinations} = \@combinations;

		push @aspects, $aspect;
	}

	return {
		aspects => \@aspects,
	}
}

sub sinogram_combination_details {
	my $uri = shift;

	my @sinograms;
	my $query = RDF::Query->new( "SELECT ?sg ?ma WHERE {
		$uri <http://co-so.org/contains-sinogram> ?sg .
		$uri <http://co-so.org/contains-meaning-aspect> ?ma .
		?sg <http://co-so.org/has-meaning-aspect> ?ma
	}" );
	my $iterator = $query->execute( $model );
	while (my $row = $iterator->next) {
		my $sinogram = {};
		$$sinogram{subject} = $$row{sg}->as_string;
		$$sinogram{subject_label} = labelize_uri($$sinogram{subject});
		$$sinogram{subject} =~ s/^<|>$//g;
		$$sinogram{aspect} = $$row{ma}->as_string;

		push @sinograms, $sinogram;
	}

	return {
		sinograms => \@sinograms,
	}
}

get qr{/desc/(?<uri> .*)$}x => sub {
	my $uri = decode_utf8(uri_decode(captures->{uri}));

	my $title = get_label("<$uri>");
	my $type = get_type("<$uri>");
	my $color = ($type and $$colors{"<$type>"}) ? $$colors{"<$type>"} : '#000000';
	my $type_label = get_label("<$type>") if $type;
	my $breadcrumb = get_surclass("<$type>", ()) if $type;
	my @breadcrumb = reverse @$breadcrumb if $breadcrumb;

	my $details;
	my $te = engine 'template';
	$details = $te->render($te->view('sinogram_details'), sinogram_details("<$uri>"))
		if $type eq 'http://co-so.org/chu-han'
		or $type eq 'http://co-so.org/chu-nom';
	$details = $te->render($te->view('sinogram_combination_details'), sinogram_combination_details("<$uri>"))
		if $type eq 'http://co-so.org/vietnamese-sinogram-combination';

	my @statements;
	my @extendedstatements;
	my @veryextendedstatements;

	my $query = RDF::Query->new( "DESCRIBE <$uri>" );
	my $iterator = $query->execute( $model );
	while (my $st = $iterator->next) {
		my $statement = {};
		$$statement{subject} = $st->subject->as_string;
		$$statement{subject} =~ s/^<|>$//g;
		$$statement{predicate} = $st->predicate->as_string;
		$$statement{predicate} =~ s/^<|>$//g;
		$$statement{object} = $st->object->as_string;
		$$statement{object} =~ s/^<|>$//g;
		$$statement{subject_label} = get_label("<$$statement{subject}>");
		$$statement{predicate_label} = get_label("<$$statement{predicate}>");
		$$statement{object_label} = labelize($st->object);
		$$statement{is_literal} = $st->object->is_literal;

		my $st = get_type("<$$statement{subject}>");
		my $ot = get_type("<$$statement{object}>");

		$$statement{subject_color} = ($st and $$colors{"<$st>"}) ? $$colors{"<$st>"} : '#000000';
		$$statement{object_color}  = ($ot and $$colors{"<$ot>"}) ? $$colors{"<$ot>"} : '#000000';

		push @statements, $statement if $$statement{predicate} ne 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'
									 and $$statement{predicate} ne 'http://www.w3.org/2000/01/rdf-schema#label';
	}

	 for my $statement (@statements) {
	 	for (($$statement{subject}, $$statement{object})) {
	 		my $query2 = RDF::Query->new( "DESCRIBE <$_>" ) or next;
	 		my $iterator2 = $query2->execute( $model );
	 		while (my $st = $iterator2->next) {
	 			my $statement = {};
	 			$$statement{subject} = $st->subject->as_string;
	 			$$statement{subject} =~ s/^<|>$//g;
	 			$$statement{predicate} = $st->predicate->as_string;
	 			$$statement{predicate} =~ s/^<|>$//g;
	 			$$statement{object} = $st->object->as_string;
	 			$$statement{object} =~ s/^<|>$//g;
	 			$$statement{subject_label} = get_label("<$$statement{subject}>");
	 			$$statement{predicate_label} = get_label("<$$statement{predicate}>");
	 			$$statement{object_label} = labelize($st->object);
	 			$$statement{is_literal} = $st->object->is_literal;

	 			my $st = get_type("<$$statement{subject}>");
	 			my $ot = get_type("<$$statement{object}>");

	 			$$statement{subject_color} = ($st and $$colors{"<$st>"}) ? $$colors{"<$st>"} : '#000000';
	 			$$statement{object_color}  = ($ot and $$colors{"<$ot>"}) ? $$colors{"<$ot>"} : '#000000';

	 			push @extendedstatements, $statement if $$statement{predicate} ne 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'
	 												 and $$statement{predicate} ne 'http://www.w3.org/2000/01/rdf-schema#label';
	 		}
	 	}
	 }

#	 for my $statement (@extendedstatements) {
#	 	for (($$statement{subject}, $$statement{object})) {
#	 		my $query2 = RDF::Query->new( "DESCRIBE <$_>" ) or next;
#	 		my $iterator2 = $query2->execute( $model );
#	 		while (my $st = $iterator2->next) {
#	 			my $statement = {};
#	 			$$statement{subject} = $st->subject->as_string;
#	 			$$statement{subject} =~ s/^<|>$//g;
#	 			$$statement{predicate} = $st->predicate->as_string;
#	 			$$statement{predicate} =~ s/^<|>$//g;
#	 			$$statement{object} = $st->object->as_string;
#	 			$$statement{object} =~ s/^<|>$//g;
#	 			$$statement{subject_label} = get_label("<$$statement{subject}>");
#	 			$$statement{predicate_label} = get_label("<$$statement{predicate}>");
#	 			$$statement{object_label} = labelize($st->object);
#	 			$$statement{is_literal} = $st->object->is_literal;


#	 			my $st = get_type("<$$statement{subject}>");
#	 			my $ot = get_type("<$$statement{object}>");

#	 			$$statement{subject_color} = ($st and $$colors{"<$st>"}) ? $$colors{"<$st>"} : '#000000';
#	 			$$statement{object_color}  = ($ot and $$colors{"<$ot>"}) ? $$colors{"<$ot>"} : '#000000';
#				
#	 			push @veryextendedstatements, $statement if $$statement{predicate} ne 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'
#	 													 and $$statement{predicate} ne 'http://www.w3.org/2000/01/rdf-schema#label';
#	 		}
#	 	}
#	 }

	template 'desc.tt', {
		breadcrumb => \@breadcrumb,
		uri => $uri,
		title => $title,
		type => $type,
		color => $color,
		type_label => $type_label,
		details => $details,
		statements => \@statements,
		extendedstatements => \@extendedstatements,
		veryextendedstatements => \@veryextendedstatements,
	};
};

true;
