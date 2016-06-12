# Basic directory tree creator.
#
# Creates a project directory tree.  If given an argument, uses that
# argument as the project name, otherwise the tool assigns the new
# project a name by appending ".#", where "#" is a number achieved by
# looping through the numbers 1-20 and finding the first that does NOT
# create a conflict when appended to the project name..  The tool will
# also automatically skip over project names that are already present
# if no project name is provided.  If a project name *is* provided, it
# will prompt the user if it should overwrite the existing project or
# create a new project directory tree.
#
# The tool also takes the '-q' parameter, which triggers "quiet mode."
# This causes the tool to assume that any conflicts should be resolved
# by creating new projects.


# Quiet Mode variable
q_mode=0
# Default Project Name variable
p_dflt="my_proj"
# Project name variable.
p_name=""

# Full directory path.
fpath=""

# Function for resolving name conflicts.  Takes no arguments.
conf_res () {
    n=1
    fpath="$p_name.$n"
    while [ -d ~/$fpath ]; do
        # The current number conflicts, so we need to check if
        # we're over the limit of 20 yet.
	if [[ "$n" < "20" ]]; then
	    # We haven't reached the limit of 20, so we increment the
	    # number and see if the new number causes a conflict.
	    ((n++))
	    fpath="${p_name}.$n"
	else
	    # We've reached the limit of 20:  Throw an error
	    # message and exit.
	    errmsg="Unable to create project directory \"$p_name\""
	    errmsg+=":  Too many conflicts."
	    #echo $errmsg
	    exit 1
	fi
    done
}

# Interpret command-line arguments.
# Based on http://stackoverflow.com/a/14203146
while [[ $# > 0 ]]; do
    key="$1"
    #echo $key
    
    case $key in
	-q|--quiet)
	    q_mode=1
	    #echo "Quiet Mode = ON"
	    ;;
	*)
	    if [ "$p_name" == "" ]; then
		p_name=$key
		#echo "Proj Name = \"$p_name\""
	    fi
	    ;;
    esac
    shift
done

# If no project name was defined, set it to the default of 'proj'
if [ "$p_name" == "" ]; then
    p_name="$p_dflt"
    #echo "SET PROJECT NAME TO DEFAULT"
fi

# Check if a directory with the specified project name already exists.
if [ -d ~/${p_name} ]; then
    echo "CONFLICT!"
    # If there is a name conflict, check to see if the project name is
    # the default of 'proj' AND Quiet Mode is OFF.
    if [[ "$p_name" == "$p_dflt" || $q_mode != 0 ]]; then
	conf_res
	fpath=$?
    else
	# Quiet Mode is off AND the user specified a custom project
	# name:  prompt the user whether to continue or not.
	msg="A project with name \"$p_name\" already exists."
	msg+="  Overwrite?  [y/n]  "
	
	# Prompt user and interpret his/her answer.
	while true; do
	    read -p "$msg" ans
	    case $ans in
		[Yy]* ) fpath=$p_name; break;;
		[Nn]* ) conf_res; break;;
		* ) echo "Please answer yes or no.";;
	    esac
	done
    fi
else
    fpath="${p_name}"
fi

# Create the directory.  Will NOT clobber any pre-existing files.
mkdir -p ~/$fpath/{bin,lib}