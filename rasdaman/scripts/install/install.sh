#!/usr/bin/env bash

# Prints the usage of the script with all the available options
usage(){
local USAGE=$(cat <<'END_HEREDOC'
    Rasdaman Installer - Installs rasdaman based on an installation profile.

OPTIONS:
    -h, --help      Displays the usage information of this script
    -p, --profile   Use the profile with the following name. Profiles are used
                    by the installer to configure the installation according to
                    the user's preferences.
    -j, --profile_path
                    Use the profile at the given path. If set, this option
                    supersedes the -p, --profile option.
    -d, --download-only
                    Use this option if you want to edit the profile before
                    installing. This will only download the installer into a
                    path that will be printed at the end of the script run;
    -o, --download-directory
                    Use this option if you want to download the installer
                    in a specific directory. By default it is downloaded in /tmp/
                    and moved into the rasdaman installation path at the end of
                    script execution.

EXAMPLES:
    ./install.sh -h => Prints this message
    ./install.sh => Offers a choice of installation profiles to run
    ./install.sh -p osgeo => Runs the installation using the OSGEO profile
    ./install.sh -d -o /home/me/ => Downloads the installer in the /home/me directory
                                    and stops without running the installation procedure
    ./install.sh -j /home/me/someProfile.json => Runs the installer with the given profile

END_HEREDOC
)
echo "${USAGE}"
}

# Offers the user the possibility of choosing an existing profile using this script instead of manually running the installer
USER_PROFILE_CHOICE=""
choose_profile(){
local PROFILE_INFO=$(cat <<'END_HEREDOC'
Welcome to the rasdaman installation process. To find more information about rasdaman,
please visit http://rasdaman.org/.

This script aims to install all the rasdaman dependencies and then install and
configure rasdaman to work out of the box. In doing this, it will modify your
system by installing extra packages or reconfiguring existing ones. To find out
more about this installer, run again with option -h. Proceed with care.

Please choose one of the installations profiles displayed below or just press
enter to install the default one:

    [0] default     This profile will install rasdaman in /opt/rasdaman and will
                    also deploy petascope and secore in your tomcat folder. It uses
                    the recommended storage backend of rasdaman, SQLite/Filestorage.
    [1] postgres    This profile will install rasdaman in /opt/rasdaman using a
                    postgresql as a storage backend (deprecated). It will also
                    deploy petascope and secore in your tomcat folder.
    [2] petabeded   This profile will install rasdaman in /opt/rasdaman and it will
                    deploy petascope and secore using an embedded jetty container.
    [9] none        If you wish to customize your profile (for example, choosing
                    your installation path, storage backend and many other options),
                    please visit http://rasdaman.org/wiki/Installer and follow
                    the instructions there.
END_HEREDOC
)
echo "${PROFILE_INFO}"

while true; do
    read -p "Please choose one of the numeric options above (default: 0)? " choice
    case ${choice} in
        [0]* ) USER_PROFILE_CHOICE="default"; break;;
           "") USER_PROFILE_CHOICE="default"; break;;
        [1]* ) USER_PROFILE_CHOICE="postgres"; break;;
        [2]* ) USER_PROFILE_CHOICE="petabeded"; break;;
        [9]* ) exit 9; break;;
        * ) echo "Please choose one of the options above (0/1/2/9):";;
    esac
done
}

check_error(){
    if [ $1 -ne 0 ]; then
        echo "ERROR: $2"
        exit 1
    fi
}

check_warning(){
    if [ $1 -ne 0 ]; then
        echo "WARNING: $2"
    fi
}

# Reads the arguments from the command line and initialized the global variables that will be passed to the other
# functions
read_args(){
    if [ -z "$USER_PROFILE_CHOICE" ] ; then
        local PROFILE_NAME_OPTION="default"
    else
        local PROFILE_NAME_OPTION="$USER_PROFILE_CHOICE"
    fi
    local PROFILE_PATH_OPTION=
    local DWD_DIR_OPTION="/tmp/"
    local DWD_ONLY_OPTION=false

    while [[ $# > 0 ]]; do
        local key="$1"
        case ${key} in
            -p|--profile)
            PROFILE_NAME_OPTION="$2"
            shift # past argument
            ;;
            -j|--profile-path)
            PROFILE_PATH_OPTION="$2"
            shift # past argument
            ;;
            -o|--download-directory)
            DWD_DIR_OPTION="$2"
            shift # past argument
            ;;
            -d|--download-only)
            DWD_ONLY_OPTION=true
            ;;
            -h|--help)
            usage
            exit 1
            ;;
            *)
              echo "You have passed an unknown option to the script: ${1}."
              echo "Please check if you misspelled the option or remove it if not necessary."
              exit 1
            ;;
        esac
        shift # past argument or value
    done

    #Conditional options
    readonly ONLY_DOWNLOAD="${DWD_ONLY_OPTION}"

    #Paths for the installer download
    readonly INSTALLER_DOWNLOAD_PARENT_DIRECTORY="${DWD_DIR_OPTION}"
    readonly RASDAMAN_INSTALLER_NAME="rasdaman-installer"
    readonly INSTALLER_URL="http://download.rasdaman.org/installer/${RASDAMAN_INSTALLER_NAME}.zip"
    readonly INSTALLER_LOCATION="${INSTALLER_DOWNLOAD_PARENT_DIRECTORY}/${RASDAMAN_INSTALLER_NAME}"
    readonly INSTALLER_ARCHIVE_DOWNLOAD_LOCATION="${INSTALLER_LOCATION}.zip"

    # Paths for the installer main script
    readonly INSTALLER_PYTHON_MAIN="${INSTALLER_LOCATION}/main.py"

    # Choosing the right profile
    if [ -n "$PROFILE_PATH_OPTION" ] ; then
        readonly INSTALLER_PROFILE=`readlink -m "${PROFILE_PATH_OPTION}"`
    else
        readonly INSTALLER_PROFILE="${INSTALLER_LOCATION}/profiles/installer/${PROFILE_NAME_OPTION}.json"
    fi
}


# Checks the minimal dependencies needed to run the installer:
# - wget: needed to download the installer
# - sudo: needed to install extra packages
# - python: needed to run the installer
check_deps(){
    wget --help &> /dev/null
    check_error $? "You need to install wget on your machine in order to continue the installation.
       E.g. sudo apt-get install wget / sudo yum install wget"

    unzip &> /dev/null
    check_error $? "You need to install unzip on your machine in order to continue the installation.
       E.g. sudo apt-get install unzip / sudo yum install unzip"
}

# Downloads the installer
# @param 1: the folder to download the installer to
# @param 2: the url to the installer
# @param 3: the path where the file should be downloaded
download_installer(){
    cd "${1}"
    check_error $? "The selected path to download the installer in is not valid."

    wget "${2}" -q -O "${3}"
    check_error $? "Could not download the installer. Please check that you are connected to the internet.
       If the problem still appears, try again later when the download server is available"

    unzip -o "${3}" > /dev/null
    check_error $? "Could not unzip the installer. Please check that your unzip command works correctly."
}

# Runs the installer
# @param 1: the path to the main script
# @param 2: the path to the profile
run_installer(){                                                                                                                                                                                                sudo -l > /dev/null
    check_error $? "You need to be able to run the sudo command in order to continue the installation.
       Check your sudo rights using sudo -l"

    sudo python --version &> /dev/null
    check_error $? "You need to install python and make it available in the PATH for the root user."

    sudo python "${1}" "${2}"
    check_error $? "The installer returned an error code. The installation might not be valid."
}

# Cleans up the tmp directory of any downloaded file
cleanup() {
  if [ "$ONLY_DOWNLOAD" != true ] ; then
    rm -rf ${INSTALLER_LOCATION}
  fi
  rm -f ${INSTALLER_ARCHIVE_DOWNLOAD_LOCATION}
}
trap cleanup EXIT

# Choose a profile if no other option given
if [ "$#" -eq 0 ]; then
    choose_profile
fi

# Read commandline arguments and decide what to do
read_args "$@"

# Checks dependencies, reads the user options an executes the script
check_deps

# Download the installer
download_installer ${INSTALLER_DOWNLOAD_PARENT_DIRECTORY} ${INSTALLER_URL} ${INSTALLER_ARCHIVE_DOWNLOAD_LOCATION}

#If the user wants to examine the installer first
if [ "$ONLY_DOWNLOAD" = true ] ; then
    echo "Rasdaman installer downloaded in ${INSTALLER_LOCATION}"
else
    # Run the installer
    run_installer ${INSTALLER_PYTHON_MAIN} ${INSTALLER_PROFILE}

    # Start rasdaman
    sudo service rasdaman start > /dev/null
    check_error $? "Failed starting rasdaman; please check the rasdaman logs in /opt/rasdaman/log for further details."
fi
