#!/bin/zsh

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
mpm_arm_path="${0:a:h}/mpm_arm"
mpm_intel_path="${0:a:h}/mpm_intel"
matlab_arm_path="${0:a:h}/arm/matlab.app"
matlab_intel_path="${0:a:h}/intel/matlab.app"
dmg_output_arm_path="${0:a:h}/matlab_arm.dmg"
dmg_output_intel_path="${0:a:h}/matlab_intel.dmg"
ARCH=$(uname -m)
mpm_arm_link="https://www.mathworks.com/mpm/maca64/mpm"
mpm_intel_link="https://www.mathworks.com/mpm/maci64/mpm"
# ----------

echo "running on $ARCH hardware"

# Downloading mpm

if [[ ! -e "$mpm_intel_path" ]]; then
	echo "mpm not installed at $mpm_intel_path"
	echo "starting download of mpm for intel hardware..."
	curl -L -o "$mpm_intel_path" "$mpm_intel_link"

	echo "done downloading mpm."
	echo "apply '+x' permissions to 'mpm' file"
	chmod +x $mpm_intel_path

	echo "done."
else
	echo "mpm for intel already installed. Skipping download of mpm"
fi
if [[ ! -e "$mpm_arm_path" ]]; then
	echo "mpm not installed at $mpm_arm_path"
	echo "starting download of mpm for arm hardware..."
	curl -L -o "$mpm_arm_path" "$mpm_arm_link"

	echo "done downloading mpm."
	echo "apply '+x' permissions to 'mpm' file"
	chmod +x $mpm_arm_path

	echo "done."
else
	echo "mpm for arm already installed. Skipping download of mpm"
fi

# --------------

# Installiere Matlab

if [[ $ARCH = "arm64" ]]; then
	$mpm_arm_path install --release=$version --destination $matlab_arm_path --products MATLAB
	$mpm_intel_path install --release=$version --destination $matlab_intel_path --products MATLAB
else
	$mpm_intel_path install --release=$version --destination $matlab_intel_path --products MATLAB
fi


# Paketiere Matlab.app mit autopkg recipe

if [[ $ARCH = "arm64" ]]; then
	autopkg run -v matlab.dmg.recipe -k dmg_root=$matlab_arm_path -k dmg_path=$dmg_output_arm_path
	autopkg run -v matlab.dmg.recipe -k dmg_root=$matlab_intel_path -k dmg_path=$dmg_output_intel_path
else
	autopkg run -v matlab.dmg.recipe -k dmg_root=$matlab_intel_path -k dmg_path=$dmg_output_intel_path
fi



