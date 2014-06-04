name             'hadoop_services'
maintainer       'EPAM'
maintainer_email 'Ievgen_Kabanets@epam.com'
license          'All rights reserved'
description      'Installs/Configures Hadoop cluster'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.2.0'
depends 		 "hadoop", "= 1.0.1"
depends			 "java_wrapper"
depends 		 "nfs"
