###############################################################
# Driverlib.pm - A package of helper functions for Perl drivers
# 
# Copyright (c) 2005 David R. O'Hallaron, All rights reserved.
###############################################################

package Driverlib;

use Socket;
use LWP::Simple;

# Autogenerated header file with lab-specific constants
use lib ".";
use Driverhdrs;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(
	     driver_post
	     );

use strict;

#####
# Public functions
#

#
# driver_post - This is the routine that a driver calls when 
#    it needs to transmit an autoresult string to the result server.
#
sub driver_post ($$) {
    my $userid = shift;       # User id for this submission
    my $result = shift;       # Autoresult string
    my $autograded = shift;   # Set if called by an autograder

    # Echo the autoresult string to stdout if the driver was called
    # by an autograder
    if ($autograded) {
        print "\n";
        print "AUTORESULT_STRING=$result\n";
        return;
    }	

    # If the driver was called with a specific userid, then submit
    # the autoresult string to the result server over the Internet.
    if ($userid) {
        my $status = submitr($Driverhdrs::SUBMISSION_URL, 
                             $userid, 
                             $Driverhdrs::LAB, 
                             $result);
        
        # Print the status of the transfer
        if (!($status =~ /OK/)) {
            print "$status\n";
            print "Did not send autoresult string to the result server.\n";
            exit(1);
        }
        print "Success: Sent autoresult string for $userid to the result server.\n";
    }	
}


#####
# Private functions
#

#
# submitr - Sends an autoresult string to the result server
#
sub submitr ($$$$$$) {
    my $url = shift;
    my $userid = shift;
    my $lab = shift;
    my $result = shift;

    my $enc_result;

    $enc_result = url_encode($result);
    print "$url/?userid=$userid&lab=$lab&result=$enc_result&submit=submit";
    return get("$url/?userid=$userid&lab=$lab&result=$enc_result&submit=submit");
}

#
# url_encode - Encode text string so it can be included in URI of GET request
#
sub url_encode ($) {
    my $value = shift;

    $value =~s/([^a-zA-Z0-9_\-.])/uc sprintf("%%%02x",ord($1))/eg;
    return $value;
}

# Always end a module with a 1 so that it returns TRUE
1;
