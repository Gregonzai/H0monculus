package H0monculus;
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
	'<http://anat.org/Sys-support-mvt>'                  => '#dfcacc',
	'<http://anat.org/MS-region-paroi-cavite-ant>'       => '#dfcacc',
	'<http://anat.org/MS-region-paroi-cavite-post>'      => '#dfcacc',
	'<http://anat.org/portion-peau>'                     => '#ffcece',
	'<http://anat.org/orifice-groupe>'                   => '#6b6b6b',
	'<http://anat.org/orifice>'                          => '#6b6b6b',
	'<http://anat.org/cavite>'                           => '#6b6b6b',
	'<http://anat.org/cavite-ant>'                       => '#6b6b6b',
	'<http://anat.org/sinus-aerien>'                     => '#6b6b6b',
	'<http://anat.org/cavite-ext>'                       => '#6b6b6b',
	'<http://anat.org/cavite-post>'                      => '#6b6b6b',
	'<http://anat.org/paroi-cavitaire>'                  => '#6b6b6b',
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
	'<http://anat.org/orifice-osseux>'		     => '#d5d5d5',
	'<http://anat.org/cloison-osseuse>'		     => '#d5d5d5',
	'<http://anat.org/cloison-osteo-carti>'		     => '#d5d5d5',
	'<http://anat.org/surf-insrt-mscl>'	             => '#cf7585',
	'<http://anat.org/surf-insrt-lgmt>'	             => '#b8c285',
	'<http://anat.org/surf-insrt-capsule-arti>'          => '#b8c285',
	'<http://anat.org/surf-insrt-bourse-arti>'           => '#b8c285',
	'<http://anat.org/surface-articulaire>'              => '#dbd023',
	'<http://anat.org/cartilage-articulaire>'            => '#dbd023',
	'<http://anat.org/carti-structure>'   	             => '#c7be36',
	'<http://anat.org/carti-structure-groupe>'           => '#c7be36',
	'<http://anat.org/ligament>'   	                     => '#abc235',
	'<http://anat.org/raphe>'   	                     => '#abc235',
	'<http://anat.org/feuillet-ligamentaire>'            => '#abc235',
	'<http://anat.org/groupe-ligamentaire>'              => '#abc235',
	'<http://anat.org/structure-fibreuse>'               => '#abc235',
	'<http://anat.org/retinaculum>'                      => '#abc235',
	'<http://anat.org/capsule-arti>'                     => '#abc235',
	'<http://anat.org/membrane-synoviale>'               => '#abc235',
	'<http://anat.org/str-diaphragmatiq>'                => '#cf2d49',
	'<http://anat.org/muscle>'   	                     => '#ba1327',
	'<http://anat.org/chef-musculaire>'                  => '#ba1327',
	'<http://anat.org/tendon>'    	                     => '#cf7585',
	'<http://anat.org/attache-musculaire>'               => '#cf7585',
	'<http://anat.org/groupe-tendineux>'                 => '#cf7585',
	'<http://anat.org/muscle-visceral>'		     => '#de5c3b',
	'<http://anat.org/muscle-visceral-volontaire>'       => '#de5c3b',
	'<http://anat.org/muscle-visc-sphincter>'            => '#de5c3b',
	'<http://anat.org/groupe-musculaire>'                => '#ba1327',
	'<http://anat.org/fascia>'    	                     => '#dfcacc',
	'<http://anat.org/muqueuse>'   	                     => '#ffb2b2',
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
	'<http://anat.org/canal-lacrymal>'    	             => '#00ccff',
	'<http://anat.org/Sys-transition>'    	             => '#f4dcc3',
	'<http://anat.org/organe-vocal>'    	             => '#e2f3ff',
	'<http://anat.org/organe-vision>'    	             => '#333c33',
	'<http://anat.org/Sys-echange-gaz>'    	             => '#e2f3ff',
	'<http://anat.org/sous-sys-echange-gaz>'     	     => '#e2f3ff',
	'<http://anat.org/organe-respi>'    	             => '#7499ff',
	'<http://anat.org/organe-respi-subdi>'    	     => '#7499ff',
	'<http://anat.org/scissure-pulmoraire>'    	     => '#7499ff',
	'<http://anat.org/conduit-aerien>'    	             => '#c6e6ff',
	'<http://anat.org/gd-conduit-aerien>'                => '#c6e6ff',
	'<http://anat.org/groupe-conduit-aerien>'            => '#c6e6ff',
	'<http://anat.org/cavite-aerienne>'    	             => '#c6e6ff',
	'<http://anat.org/canal-aerien>'    	             => '#c6e6ff',
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
	'<http://anat.org/Sys-support-mvt>'    	             => '4',
	'<http://anat.org/MS-region-paroi-cavite-ant>'       => '1',
	'<http://anat.org/MS-region-paroi-cavite-post>'      => '1',
	'<http://anat.org/portion-peau>'                     => '0',
	'<http://anat.org/orifice-groupe>'                   => '1',
	'<http://anat.org/orifice>'                          => '0',
	'<http://anat.org/cavite>'                           => '1',
	'<http://anat.org/cavite-ant>'                       => '1',
	'<http://anat.org/sinus-aerien>'                     => '1',
	'<http://anat.org/cavite-ext>'                       => '1',
	'<http://anat.org/cavite-post>'                      => '1',
	'<http://anat.org/paroi-cavitaire>'                  => '0',
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
	'<http://anat.org/bone>'    	           	     => '0',
	'<http://anat.org/short-bone>'    	             => '0',
	'<http://anat.org/long-bone>'    	             => '0',
	'<http://anat.org/flat-bone>'    	             => '0',
	'<http://anat.org/mini-bone>'    	             => '0',
	'<http://anat.org/sesamoid-bone>'    	             => '0',
	'<http://anat.org/bone-group>'			     => '1',
	'<http://anat.org/bone-structure>'		     => '0',
	'<http://anat.org/bone-meta-structure>'              => '1',
	'<http://anat.org/bone-description>'		     => '0',
	'<http://anat.org/bone-foramen>'		     => '1',
	'<http://anat.org/bone-canal>'			     => '0',
	'<http://anat.org/orifice-osseux>'		     => '0',
	'<http://anat.org/cloison-osseuse>'		     => '0',
	'<http://anat.org/cloison-osteo-carti>'		     => '0',
	'<http://anat.org/dent>'			     => '0',
	'<http://anat.org/dent-groupe>'			     => '1',
	'<http://anat.org/surf-insrt-mscl>'	             => '0',
	'<http://anat.org/surf-insrt-lgmt>'	             => '0',
	'<http://anat.org/surf-insrt-capsule-arti>'          => '0',
	'<http://anat.org/surf-insrt-bourse-arti>'           => '0',
	'<http://anat.org/surface-articulaire>'              => '0',
	'<http://anat.org/cartilage-articulaire>'            => '0',
	'<http://anat.org/carti-structure>'	             => '0',
	'<http://anat.org/carti-structure-groupe>'           => '1',
	'<http://anat.org/ligament>'   	                     => '0',
	'<http://anat.org/raphe>'   	                     => '0',
	'<http://anat.org/feuillet-ligamentaire>'            => '0',
	'<http://anat.org/groupe-ligamentaire>'              => '0',
	'<http://anat.org/structure-fibreuse>'               => '0',
	'<http://anat.org/retinaculum>'                      => '0',
	'<http://anat.org/capsule-arti>'                     => '0',
	'<http://anat.org/bourse-synoviale>'                 => '0',
	'<http://anat.org/str-diaphragmatiq>'                => '1',
	'<http://anat.org/groupe-musculaire>'                => '1',
	'<http://anat.org/muscle>'    	                     => '0',
	'<http://anat.org/chef-musculaire>'                  => '0',
	'<http://anat.org/muscle-visceral-volontaire>'       => '2',
	'<http://anat.org/muscle-visc-sphincter>'            => '0',
	'<http://anat.org/tendon>'    	                     => '0',
	'<http://anat.org/attache-musculaire>'               => '0',
	'<http://anat.org/groupe-tendineux>'                 => '2',
	'<http://anat.org/fascia>'    	                     => '0',
	'<http://anat.org/muqueuse>'   	                     => '0',
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
	'<http://anat.org/canal-lacrymal>'    	             => '0',
	'<http://anat.org/Sys-transition>'    	             => '0',
	'<http://anat.org/organe-vocal>'    	             => '1',
	'<http://anat.org/organe-vision>'    	             => '2',
	'<http://anat.org/Sys-echange-gaz>'    	             => '2',
	'<http://anat.org/anat:sous-sys-echange-gaz>'        => '1',
	'<http://anat.org/organe-respi>'    	             => '3',
	'<http://anat.org/organe-respi-subdi>'    	     => '0',
	'<http://anat.org/scissure-pulmoraire>'    	     => '0',
	'<http://anat.org/conduit-aerien>'    	             => '0',
	'<http://anat.org/gd-conduit-aerien>'                => '1',
	'<http://anat.org/groupe-conduit-aerien>'            => '3',
	'<http://anat.org/cavite-aerienne>'    	             => '0',
	'<http://anat.org/canal-aerien>'    	             => '0',
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

my $file = 'h0monculus_data';

my $store  = RDF::Trine::Store->temporary_store;
my $model  = RDF::Trine::Model->new($store);
my $parser = RDF::Trine::Parser->new('turtle');

my $rdf = read_file($file);
my $uri = 'file://' . File::Spec->rel2abs($file);
$parser->parse_into_model($uri, $rdf, $model);


get '/anatomie' => sub {
	template 'anatomie.tt';
};

get '/myologie' => sub {
	template 'myologie.tt';
};

get '/systemes_organiques' => sub {
	template 'systemes_organiques.tt';
};

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
							and $$statement{predicate} ne 'http://anat.org/hasImage3D'
							and $$statement{predicate} ne 'http://anat.org/hasImagemini3D'
							and $$statement{predicate} ne 'http://anat.org/has3DmodelURL'
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

sub get_model_URL {
	my $uri = shift;
	my $model_URL;
	my $query = RDF::Query->new( "SELECT ?o WHERE { $uri <http://anat.org/has3DmodelURL> ?o }" );
	if ($query) {
		my $iterator = $query->execute( $model );
		while (my $row = $iterator->next) {
			$model_URL = $$row{o}->as_string;
			$model_URL =~ s/^<|>$//g;
		}
	}
	return $model_URL;
}

sub get_Image3D {
	my $uri = shift;
	my $Image3D;
	my $query = RDF::Query->new( "SELECT ?o WHERE { $uri <http://anat.org/hasImage3D> ?o }" );
	if ($query) {
		my $iterator = $query->execute( $model );
		while (my $row = $iterator->next) {
			$Image3D = $$row{o}->as_string;
			$Image3D =~ s/^<|>$//g;
		}
	}
	return $Image3D;
}

sub get_Imagemini3D {
	my $uri = shift;
	my $Imagemini3D;
	my $query = RDF::Query->new( "SELECT ?o WHERE { $uri <http://anat.org/hasImagemini3D> ?o }" );
	if ($query) {
		my $iterator = $query->execute( $model );
		while (my $row = $iterator->next) {
			$Imagemini3D = $$row{o}->as_string;
			$Imagemini3D =~ s/^<|>$//g;
		}
	}
	return $Imagemini3D;
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

get qr{/desc/(?<uri> .*)$}x => sub {
	my $uri = decode_utf8(uri_decode(captures->{uri}));

	my $title = get_label("<$uri>");
	my $type = get_type("<$uri>");
	my $model_URL = get_model_URL("<$uri>");
	my $Image3D = get_Image3D("<$uri>");
	my $Imagemini3D = get_Imagemini3D("<$uri>");
	my $color = ($type and $$colors{"<$type>"}) ? $$colors{"<$type>"} : '#000000';
	my $type_label = get_label("<$type>") if $type;
	my $breadcrumb = get_surclass("<$type>", ()) if $type;
	my @breadcrumb = reverse @$breadcrumb if $breadcrumb;

	my @statements;
	
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
		$$statement{subject_Imagemini3D} = get_Imagemini3D("<$$statement{subject}>");
		$$statement{object_Imagemini3D} = get_Imagemini3D("<$$statement{object}>");

		my $sty = get_type("<$$statement{subject}>");
		my $oty = get_type("<$$statement{object}>");

		$$statement{subject_color} = ($sty and $$colors{"<$sty>"}) ? $$colors{"<$sty>"} : '#000000';
		$$statement{object_color}  = ($oty and $$colors{"<$oty>"}) ? $$colors{"<$oty>"} : '#000000';

		push @statements, $statement if $$statement{predicate} ne 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'
						and $$statement{predicate} ne 'http://www.w3.org/2000/01/rdf-schema#label'
						and $$statement{predicate} ne 'http://anat.org/has3DmodelURL'
						and $$statement{predicate} ne 'http://anat.org/hasImage3D'
						and $$statement{predicate} ne 'http://anat.org/hasImagemini3D';
	}


	template 'desc.tt', {
		breadcrumb => \@breadcrumb,
		uri => $uri,
		title => $title,
		Image3D => $Image3D,
		Imagemini3D => $Imagemini3D,
		type => $type,
		model_URL => $model_URL,
		color => $color,
		type_label => $type_label,
		statements => \@statements,
	};
};

true;
