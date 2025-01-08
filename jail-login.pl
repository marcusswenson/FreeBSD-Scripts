#!/usr/bin/env perl


################################################################################
# Author: M. Swenson - me@mswenson.dev
# Date: 2025.01.06
#
# This script makes it easier to select a FreeBSD jail to login to as root.
################################################################################


use utf8;
use strict;
use warnings;
use JSON::XS;
use Data::Dumper;


sub get_running_jails {
    decode_json(`jls --libxo=json`)->{'jail-information'}->{'jail'};
}

sub get_jail_selection {
    my $jails = shift;

    print "\n";
    print ">> Select the number of the jail to login to:\n\n";

    my $selection_number = 0;
    foreach (@$jails) {
        $selection_number++;
        print "\t${selection_number}. " . $_->{'hostname'} . "\n";
    }

    print "\n>> Selection: ";
    chomp(my $selection = <STDIN>);
    $selection =~ s/\s//g; # Remove whitespace globally

    $selection;
}



# Get a JSON response with details of running jails.
my $jails = get_running_jails();
my $selection = get_jail_selection($jails);

# Now handle our selection - either print an error or drop to a login.
if ($selection =~ /^\d+$/ && $selection > 0 && $selection <= scalar(@{$jails})) {
    my $selected_jail_name = $jails->[ $selection - 1 ]->{'hostname'};

    # Run the jail login command.
    print "\n>> Logging into '${selected_jail_name}' jail as root...\n\n";
    exec("jexec ${selected_jail_name} login -f root");
} else {
    print "\n>> '${selection}' is not a valid choice.\n\n";
}
