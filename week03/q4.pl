#!/usr/bin/perl

use v5.10.1;

use Cwd;

use strict;
use warnings;

# Print the help text and exit.
sub printhelp() {
    my $helpfile = $0;
    $helpfile =~ s{([^\\/\r\n]*).pl$}{help.$1};
    open my $fh, "<:utf8", $helpfile;
    print while <$fh>;
    close $fh;
    exit 0;
}

# Generates a random DNA sequence with the given length (first parameter). If
# the second parameter is true, the function generates a random length between
# 1 and the first parameter.
sub randseq($;$) {
    my ($len, $randlen) = @_;
    
    # Randomize the length parameter if a second parameter was given.
    $len = int(rand $len) + 1 if $randlen;
    
     my @nt = qw(A C G T);
    
    my $seq = "";
    
    for (1..$len) {
        $seq .= $nt[int(rand(scalar(@nt)))];
    }
    
    return $seq;
}

# Parse the command-line arguments.
#   Print help if there weren't any arguments provided.
printhelp() unless @ARGV;

# Declare the general variables.
my $length = 0; # Length of sequence(s).
my $num = 0;    # Number of sequences to generate.
my $mode = "";  # Stores all flags used.
my $fsuff = ""; # File suffix used to avoid conflicts.

#   Loop through the different arguments.
for (@ARGV) {
    if (m/^-/) {
        # If the argument is a collection of flags and contains the "show help"
        # flag, print help and exit. If it does NOT contain the "show help"
        # flag, store the flags in the '$mode' variable after stripping out all
        # invalid flags.
        if (m/h/) {
            printhelp();
        } else {
            $mode = $_;
            $mode =~ s/[^for]+//g
        }
    } elsif ($length) {
        # If the argument is not a collection of flags AND the length value has
        # already been assigned, use the current number as the number of
        # sequences to generate UNLESS that value has already been set.
        $num = $_ unless $num;
    } else {
        # If the argument is not a collection of flags AND the length value has
        # NOT been assigned yet, set the length to the current value.
        $length = $_;
    }
}

# Number defaults to 1.
$num = 1 unless $num;

# Current directory.
my $dir = getcwd();

if ($mode =~ m/f/ && $mode !~ m/o/) {
    # Get a string listing all FILES in the current working directory.
    opendir(my $dh, $dir);
    my $ls = join("\n", grep { $_ !~ m/^\.{1,2}$/ && -f $dir/$_ } readdir $dh);
    
    # If there is a file named "seq#" in the current working directory,
    # generate the suffix.
    if ($ls =~ m/^seq\d+$/m) {
        $fsuff = 1;
        while ($ls =~ m/^seq\d+\.$fsuff$/m) {
            $fsuff++;
        }
    }
}

for (1..$num) {
    # Generate sequence and assign to a temporary variable.
    my $s = randseq($length, ($mode =~ m/r/ ? 1 : 0));
    
    # If in -f mode, print to a file, otherwise print to STDOUT.
    if ($mode =~ m/f/) {
        open my $fh, ">:utf8", "$dir/seq$_" . ($fsuff ? ".$fsuff" : "");
        print $fh "$s\n";
        close $fh;
    } else {
        print "$s\n";
    }
}
