# Basic fileset copier.
# Iteratively copies a set of files from one directory to another.  Can take a
# list of files/patterns and an output directory.  If no output is specified,
# defaults to ./copied_files

# If true, print help and exit.
hmode=0

# Array of file/directory paths and patterns.
tocopy=()

# Output directory
outdir=""

n=0

while [[ $# > 0 ]]; do
    arg="$1"
    
    case $arg in
        -h|-?|--help)
            # Display help text; break out of the loop.
            hmode=1
            break
        -o)
            # Output directory given in -o format.
            shift
            outdir=$1
            ;;
        --out=*)
            # Output directory given in --out=DIR format.
            outdir=$(grep -oP "--out=\K.*")
            ;;
        *)
            # Add current argument to list of input items.
            n=${#tocopy}
            ((n++))
            tocopy[$n]="$arg"
            ;;
    esac
    shift
done

# If no valid arguments were given OR the help flag was given, print help text
# and exit.
if [[ [[ "$outdir" == "" && ${#tocopy[@]} == 0 ]] || [[ $hmode == 1 ]] ]]; then
    msg="Usage: q1 [OPTION]... FILE_1 [FILE_2 FILE_3...]\n"
    msg="${msg}Copy one or more files/patterns/directories to a specified "
    msg="${msg}directory.\n\n"
    msg="${msg}OPTIONS:\n  -o, --out=DIR     Define output directory.  If the"
    msg="${msg} -o syntax is used, the\n                    next argument "
    msg="${msg}will be used as the output directory.\n  -h, -?, --help    "
    msg="${msg}Display help text.\n"
    print "$msg"
    exit 0
fi

# If no inputs were defined, exit with error.
if [[ ${#tocopy[@]} == 0 ]]; then
    print "No input files provided: exiting.\n"
    exit 1
fi

# If no output directory was defined, default to "./copied_files".
if [[ "$outdir" == "" ]]; then
    print "No output directory provided, defaulting to ./copied_files"
    outdir=./copied_files
fi

for p in ${tocopy[@]}; do
    cp $p $outdir
done

print "Copy complete.\n"