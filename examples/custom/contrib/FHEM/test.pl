
#
# test some perl stuff 
#

use HMMsg;

use vars qw(%customMsg);

sub say {print @_, "\n"}

$customMsg{"HB-UNI-Sen-PRESS"} = sub ($) {
  print "Msg Function: ".$_[0]."\n";
};


sub parseValueFormat {
  my @v;
  foreach my $value ( split / /,$_[0] ) {
    #print $value."\n";
    my @parts = split /:/,$value;
    my $valuedata = {};
    my $numb = @parts[0];
    $numb =~ s/([1,2,4,8])s?/$1/g;
    $valuedata->{'numbytes'} = $numb;
    $valuedata->{'signed'} = $parts[0] =~ m/([1,2,4,8])s/;
    $valuedata->{'reading'} = "value".scalar @v + 1;
    $valuedata->{'factor'} = 1;
    if( defined $parts[1] ) { $valuedata->{'reading'} = $parts[1]; }
    if( defined $parts[2] ) { $valuedata->{'factor'} = $parts[2]; }
    push @v, $valuedata;
  }
  return @v;
}

sub createReadings {
  my $msg = shift;
  my $vfmt = shift;
  my $packstr = "";
  foreach my $data (@{$vfmt}) {
    #print $data->{'numbytes'}."  ".$data->{'signed'}."  ".$data->{'reading'}."  ".$data->{'factor'}."\n";
	$packstr = $packstr."A".($data->{'numbytes'}*2);
  }
  #print $packstr."\n";
  my @unpacked = map{hex($_)} unpack($packstr,$msg);
  #print "$unpacked[0] $unpacked[1] $unpacked[2] $unpacked[3]\n";
  my $num = 0;
  foreach my $data (@{$vfmt}) {
    my $val = $unpacked[$num++];
	if( $data->{'signed'} ) {
	  my $max =  0x01 << (8*$data->{'numbytes'});
	  my $mask = $max >> 1;
	  $val = ($val & $mask) ? ($val - $max) : $val;
	}
	$val /= $data->{'factor'};
	print $data->{'reading'}." : ".$val."\n";
  }
}

my $fmt = "2s:temperature:10 1:humidity:1 2:pressure 2";
my @values = parseValueFormat($fmt);
createReadings("00E82803EB0000",\@values);
print "\n";
createReadings("FFFF0F03EB0100",\@values);

if( defined $customMsg{"HB-UNI-Sen-PRESS"} ) {
    print $customMsg{"HB-UNI-Sen-PRESS"}."\n";
  $customMsg{"HB-UNI-Sen-PRESS"}("Hello");
}

my @evtEt = ();

$msg = new HMMsg("53","A2","AA1133","996699","040400E83503ED0000");
$msg->print;

say $msg->payload;
say $msg->payload(2);
say $msg->payload(4,2);
say $msg->payloadByte(2);
say $msg->payloadByte(3);
say $msg->isStatus;
say $msg->channelId;

$msg = new HMMsg("10","A2","AA1133","996699","0605BE005C");
$msg->print;
say $msg->isStatus;
say $msg->channelId;

push @evtEt,$msg->processSwitchStatus;
say @evtEt;
