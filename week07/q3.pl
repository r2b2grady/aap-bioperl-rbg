#!/usr/bin/perl
use strict;
use warnings;

# Created on: Jul 16, 2016
# Written by: Robert Grady

my $Version = 1.0.0;

=pod

=head1 q3.pl
Converts a given temperature value from Celsius to Fahrenheit or vice versa.

=head1 Usage Examples
C<q3.pl -i>
C<q3.pl --help>
C<q3.pl TEMP_VAL>
C<q3.pl -s c TEMP_VAL>
C<q3.pl --scale=C TEMP_VAL>

=head1 How to Use
This script takes a temperature value, prompts the user for a scale (Celsius or
Fahrenheit), converts the given value to the other scale, and prints out the
converted value.  The user can also specify a scale through the use of
command-line flags.

=head1 Flags
-s SCALE        Set the scale to C<SCALE> (must be "C" or "F"; ignores case).
--scale=SCALE   Set the scale to C<SCALE> (must be "C" or "F"; ignores case).

=cut

my $scale;  # Scale.  Will be 'C' or 'F'.
my $val;    # Temperature value.

sub getinput($$);       # Process command-line input using the given rules.

# Process command-line variables.
while (@ARGV) {
	my $a = shift;     # Current argument.
	my $s;             # Scale temporary variable.
	
	# If the temperature and scale are both defined, 
	if (defined $val && defined $scale) {
		last;
	}
	
	if ($a =~ m/^-(?:[h\?]|-help)/) {
		# Run perldoc.
		exit;
	} elsif ($a =~ m/^-s$/) {
		# -s SCALE syntax
		$s = uc(shift);
	} elsif ($a =~ m/^--scale=(.*)/) {
		# --scale=SCALE syntax
		$s = $1;
	} elsif ($a =~ m/^(\d+(?:\.\d+)?)$/) {
		# Handle a temperature argument.
		$val = $1;
	} else {
		# Handle an invalid temperature argument.
		warn "Invalid temperature argument '$a' given; argument skipped."
	}
	
	# If the scale temporary variable was set, interpret it.
	if (defined $s) {
	   if ($s =~ m/^[cf]$/) {
            $scale = $s unless $scale;
        } else {
            warn "Invalid scale command-line argument '$s' given.";
        }
    }
}

# Get the temperature value if it wasn't defined already.
unless (defined $val) {
	$val = getinput("Enter temperature value:",
                    {-re    => qr/^\d+(?:\.\d+)?$/,
                     -name  => "temperature"});
}

# Get the scale value if it wasn't defined already.
unless (defined $scale) {
	$scale = uc(getinput("Enter scale (ignores case)",
		                 {-re     => qr/^[CcFf]$/,
		                  -opts   => "[C/F]",
		                  -name   => "scale"}));
}

# Make the conversion and print the result.
print "$val $scale is ";

if ($scale eq 'C') {
	printf('%.3f F', (($val * 9) / 5) + 32);
} else {
	printf('%.3f C', (($val - 32) * 5) / 9);
}

print "\n";


# Takes a message (first argument) and a set of options (second argument) and
# prompts the user for input according to the options.  The options are passed
# as a reference to a hash.  The following keys are REQUIRED:
#   -re     Regex that is used to validate the input.  Can be a string or a
#           qr// construct.
# 
# The following keys can also be used:
#   -name   Name of parameter being retrieved.
#   -opts   String to use for prompting the user for input.
#   -nre    If true, the regex is used in a NEGATIVE manner--that is, input is
#           considered valid if the regex does NOT match the input.  Defaults
#           to false.
#   -lim    The maximum number of invalid answers before the program exits.
#           Defaults to 20.
#   -exit   The exit message.  Defaults to: "Your utter inability to follow the
#           simplest of instructions completely baffles me.  Goodbye."
#   -err    Text to use to prompt the user for input after an invalid input.
#           Defaults to "Invalid input.  " followed by the initial message.
#   -nl     If true, the message will end in a newline instead of two spaces.
#           Defaults to false.
sub getinput($$) {
	my ($msg, $cfg) = @_;
	
	my $ans;
	my $valid = 0;         # Set to true if the 
	my $count = 0;         # Counts the number 
	
	# Dig through nested references.
	$msg = $$msg while ref($msg) =~ m/^(?:REF|SCALAR)/;
	$cfg = $$cfg while ref($cfg) eq 'REF';
	
	# Handle invalid input types.
	die "Invalid message parameter passed to getinput(): $!"
        unless ref($msg) eq '';
    die "Non-hash config parameter passed to getinput(): $!"
        unless ref($cfg) eq 'HASH';
    die "Config hash requires -re value: $!" unless exists $cfg->{-re};
    
    # Initialize defaults for optional keys.
    $cfg->{-lim} = 20 unless exists $cfg->{-lim};
    $cfg->{-lim} = int($cfg->{-lim});
    $cfg->{-lim} = 0 if $cfg->{-lim} < 0;
    
    unless (exists $cfg->{-exit}) {
        $cfg->{-exit} = "Your utter inability to follow even the simplest of" .
                        " instructions completely baffles me.  Goodbye.";
    }
    
    $cfg->{-name} = "input" unless exists $cfg->{-name};
    
    $cfg->{-err} = "Invalid $cfg->{-name}.  $msg" unless exists $cfg->{-err};
    
    $cfg->{-re} = qr/$cfg->{-re}/ unless ref($cfg->{-re}) eq 'Regex';
    
    # Process input.
    until ($valid || $count == $cfg->{-lim}) {
    	# Prompt the user for input.
    	print(($count ? $cfg->{-err} : $msg) .
    	      "  $cfg->{-opts}" . ($cfg->{-nl} ? "\n" : "  "));
    	# Get the input.
    	$ans = <STDIN>;
    	# Interpret the input.
    	$valid = ($ans =~ $cfg->{-re} xor $cfg->{-nre});
    }
    
    if ($valid) {
    	return $ans;
    } else {
    	die $cfg->{-exit};
    }
}
