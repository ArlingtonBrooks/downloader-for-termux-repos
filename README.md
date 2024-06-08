I have no affiliation with the termux project, nor do they endorse this script.  
You use this script at your own risk and are expected to use it responsibly. 
## DO NOT USE THIS SCRIPT TO ABUSE THE TERMUX REPOSITORY SERVER!

# Description
If you have an air-gapped android system with termux installed on it, you may want to install packages for that system to be useful.  The built-in package manager for termux tends to want an internet connection (and if your system is air-gapped, this presents a problem).  
Of course, you can download the .deb files and install them directly in your termux environment, but this involves downloading a lot of dependencies.  

This script parses the termux repository package list and locates where to find the relevent dependencies for a package you are trying to install.  It then downloads those dependencies as well as the .deb package for the program you are interested in.  You may then load these .deb files onto an SD card or trusted data transfer device to move to your air-gapped system.

This may not get you 100% of the way there, but it will do most of the hard work.

# WARNING
If there is a dependency loop, this will not resolve it.  It will just call continue recursively calling the GetDepends function until it dies.
