#!/bin/zsh
# Detect ARCH and download correct mpm version. Then download specified release of matlab and package it using an autopkg recipe

# Help function
Help () {
	echo "Use '-v \$version' to specify a version of matlab to download."
}
# -------------

# CLI Option handling
while getopts ":hv:" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      v) # Enter a name
         version=$OPTARG;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done
echo $version
if [[ -z $version ]]; then
	echo "No version specified. Exiting..."
	exit;
fi
# -------------

# Variables
cur_dir="${0:a:h}"
mpm_path="${0:a:h}/mpm"
matlab_path="${0:a:h}/matlab.app"
dmg_output_path="${0:a:h}/matlab.dmg"
ARCH=$(uname -m)
mpm_arm_link="https://www.mathworks.com/mpm/maca64/mpm"
mpm_intel_link="https://www.mathworks.com/mpm/maci64/mpm"
# ----------

echo "running on $ARCH hardware"

# Downloading mpm
if [[ ! -e $mpm_path ]]; then
	echo "mpm not installed at $mpm_path"
	echo "starting download of mpm for $ARCH$ hardware..."

	if [[ $ARCH = "arm64" ]]; then
		curl -L -o "${0:a:h}/mpm" "$mpm_arm_link"
	fi
	if [[ $ARCH = "x86_64" ]]; then
		curl -L -o "${0:a:h}/mpm" "$mpm_intel_link"
	fi

	echo "done downloading mpm."
	echo "apply '+x' permissions to 'mpm' file"
	chmod +x $mpm_path
	echo "done."

else
	echo "mpm already installed. Skipping download of mpm"
fi
# --------------

# Installiere Matlab
./mpm install --release=$version --destination $matlab_path --products MATLAB

# Paketiere Matlab.app mit autopkg recipe
autopkg run -v matlab.dmg.recipe -k dmg_root=$matlab_path -k dmg_path=dmg_output_path

echo $version










