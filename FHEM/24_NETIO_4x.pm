#
# $Id: 24_NETIO_4x.pm 7570 2018-02-18 15:15:44Z oliverschoenefeld $
#
# for installation/usage instructions please see
# https://github.com/elmicro/fhem_netio_4x_pm
# maintainer: Elektronikladen Microcomputer - fhem@elmicro.com
#

package main;

use strict;
use warnings;
use POSIX;
use JSON;
use LWP::UserAgent;
use LWP::Protocol::https;
use HTTP::Request::Common;

sub
NETIO_4x_Initialize(@)
{
  my ($hash) = @_;

  $hash->{DefFn}        = "NETIO_4x_Define";
  $hash->{UndefFn}      = "NETIO_4x_Undef";
  $hash->{SetFn}        = "NETIO_4x_Set";
  $hash->{GetFn}        = "NETIO_4x_Get";

  return undef;
}

sub
NETIO_4x_Define($$)
{
  my ($hash, $def) = @_;
  my @a = split("[ \t][ \t]*", $def);
  return "wrong syntax: define <name> NETIO_4x <model> <connection>" if(@a != 4);
  my $name = $a[0];
  return "only models '4', '4C' and '4All' are supported." if(($a[2] ne "4") and ($a[2] ne "4C") and ($a[2] ne "4All"));
  $hash->{MODEL} = $a[2];
  if ($a[3] =~ m/(http):\/\/(.+:.+@)?(.+):*(\d+)*/gi)
  {
    $hash->{STATE} = 'off';
    $hash->{CONNECTION} = $1;
    $hash->{CREDENTIALS} = $2?$2:"";
    $hash->{HOST} = $3;
    $hash->{PORT} = $4?$4:80;
  }
  else
  {
    return "Please provide the connection details in the following format:\n\nhttp://user:password\@HOST:PORT\nHTTPS is not implemented yet\nuser:password\@ may be omitted if no basicAuth is used\nHOST can be provided as an IPv4 address or host/domain\nif port is omitted, default port 80 is used\n\ne.g. \nhttp://10.10.10.1 or\n http://mynetio.example.domain or\nhttp://bob:bobspwd\@10.10.10.1:80";
  }
  return undef;
}

sub
NETIO_4x_Undef(@)
{
  return undef;
}

sub
NETIO_4x_Set(@)
{
  my ($Device, $name, $cmd, @args) = @_;
  return "Unknown argument $cmd, choose one of 1:0,1,2,3,4,5,6 2:0,1,2,3,4,5,6 3:0,1,2,3,4,5,6 4:0,1,2,3,4,5,6" if (($cmd ne '1') and ($cmd ne '2') and ($cmd ne '3') and ($cmd ne '4'));
  return "only actions 0-6 allowed" if (($args[0] ne '0') and ($args[0] ne '1') and ($args[0] ne '2') and ($args[0] ne '3') and ($args[0] ne '4') and ($args[0] ne '5') and ($args[0] ne '6'));
  my $data = '{"Outputs":[{"ID":'.$cmd.',"Action":'.$args[0].'}]}';
  if (($args[0] eq "0") or ($args[0] eq "1") ) {
    readingsSingleUpdate($Device, "Output".$cmd."_State", $args[0], 1);
  }
  if ($args[0] eq "4") {
    my $current = ReadingsVal($Device, "Output".$cmd."_State", undef);
    if($current eq '0')
    {
      readingsSingleUpdate($Device, "Output".$cmd."_State", '1', 1);
    }
    else
    {
      readingsSingleUpdate($Device, "Output".$cmd."_State", '0', 1);
    }
  }
  my $ua = LWP::UserAgent->new();
  my $url = $Device->{CONNECTION}."://".$Device->{CREDENTIALS}.$Device->{HOST}.":".$Device->{PORT}."/netio.json";
  my $req = HTTP::Request->new( 'POST', $url );
  $req->header( 'Content-Type' => 'application/json' );
  $req->content( $data );
  my $response = $ua->request($req);
  if ($response->is_success) {
    my $response_json = JSON->new->utf8->decode($response->decoded_content);
    readingsBeginUpdate($Device);
    if($cmd ne '1')
    {
      readingsBulkUpdateIfChanged($Device, "Output1_State", $response_json->{'Outputs'}->[0]->{'State'});
    }
    readingsBulkUpdateIfChanged($Device, "Output1_Delay", $response_json->{'Outputs'}->[0]->{'Delay'});
    if($cmd ne '2')
    {
      readingsBulkUpdateIfChanged($Device, "Output2_State", $response_json->{'Outputs'}->[1]->{'State'});
    }
    readingsBulkUpdateIfChanged($Device, "Output2_Delay", $response_json->{'Outputs'}->[1]->{'Delay'});
    if($cmd ne '3')
    {
      readingsBulkUpdateIfChanged($Device, "Output3_State", $response_json->{'Outputs'}->[2]->{'State'});
    }
    readingsBulkUpdateIfChanged($Device, "Output3_Delay", $response_json->{'Outputs'}->[2]->{'Delay'});
    if($cmd ne '4')
    {
      readingsBulkUpdateIfChanged($Device, "Output4_State", $response_json->{'Outputs'}->[3]->{'State'});
    }
    readingsBulkUpdateIfChanged($Device, "Output4_Delay", $response_json->{'Outputs'}->[3]->{'Delay'});
    if($Device->{MODEL} eq '4All')
    {
      readingsBulkUpdateIfChanged($Device, "Output1_Current", $response_json->{'Outputs'}->[0]->{'Current'});
      readingsBulkUpdateIfChanged($Device, "Output1_PowerFactor", $response_json->{'Outputs'}->[0]->{'PowerFactor'});
      readingsBulkUpdateIfChanged($Device, "Output1_Load", $response_json->{'Outputs'}->[0]->{'Load'});
      readingsBulkUpdateIfChanged($Device, "Output1_Energy", $response_json->{'Outputs'}->[0]->{'Energy'});
      readingsBulkUpdateIfChanged($Device, "Output2_Current", $response_json->{'Outputs'}->[1]->{'Current'});
      readingsBulkUpdateIfChanged($Device, "Output2_PowerFactor", $response_json->{'Outputs'}->[1]->{'PowerFactor'});
      readingsBulkUpdateIfChanged($Device, "Output2_Load", $response_json->{'Outputs'}->[1]->{'Load'});
      readingsBulkUpdateIfChanged($Device, "Output2_Energy", $response_json->{'Outputs'}->[1]->{'Energy'});
      readingsBulkUpdateIfChanged($Device, "Output3_Current", $response_json->{'Outputs'}->[2]->{'Current'});
      readingsBulkUpdateIfChanged($Device, "Output3_PowerFactor", $response_json->{'Outputs'}->[2]->{'PowerFactor'});
      readingsBulkUpdateIfChanged($Device, "Output3_Load", $response_json->{'Outputs'}->[2]->{'Load'});
      readingsBulkUpdateIfChanged($Device, "Output3_Energy", $response_json->{'Outputs'}->[2]->{'Energy'});
      readingsBulkUpdateIfChanged($Device, "Output4_Current", $response_json->{'Outputs'}->[3]->{'Current'});
      readingsBulkUpdateIfChanged($Device, "Output4_PowerFactor", $response_json->{'Outputs'}->[3]->{'PowerFactor'});
      readingsBulkUpdateIfChanged($Device, "Output4_Load", $response_json->{'Outputs'}->[3]->{'Load'});
      readingsBulkUpdateIfChanged($Device, "Output4_Energy", $response_json->{'Outputs'}->[3]->{'Energy'});
      readingsBulkUpdateIfChanged($Device, "Voltage", $response_json->{'GlobalMeasure'}->{'Voltage'});
      readingsBulkUpdateIfChanged($Device, "Frequency", $response_json->{'GlobalMeasure'}->{'Frequency'});
      readingsBulkUpdateIfChanged($Device, "TotalCurrent", $response_json->{'GlobalMeasure'}->{'TotalCurrent'});
      readingsBulkUpdateIfChanged($Device, "OverallPowerFactor", $response_json->{'GlobalMeasure'}->{'OverallPowerFactor'});
      readingsBulkUpdateIfChanged($Device, "TotalLoad", $response_json->{'GlobalMeasure'}->{'TotalLoad'});
      readingsBulkUpdateIfChanged($Device, "TotalEnergy", $response_json->{'GlobalMeasure'}->{'TotalEnergy'});
      readingsBulkUpdateIfChanged($Device, "EnergyStart", $response_json->{'GlobalMeasure'}->{'EnergyStart'});
    }
    readingsEndUpdate($Device, 1);
    $Device->{STATE} = 'on';
    return undef;
  }
  else {
      return $response->status_line, "\n";
      $Device->{STATE} = 'off';
  }
}

sub
NETIO_4x_Get(@)
{
  my ($Device, $name, $cmd, @args) = @_;
  if ($cmd eq 'state')
  {
    my $ua = LWP::UserAgent->new();
    my $url = $Device->{CONNECTION}."://".$Device->{CREDENTIALS}.$Device->{HOST}.":".$Device->{PORT}."/netio.json";
    my $req = HTTP::Request->new( 'POST', $url );
    $req->header( 'Content-Type' => 'application/json' );
    $req->content( undef );
    my $response = $ua->request($req);
    if ($response->is_success) {
        my $response_json = JSON->new->utf8->decode($response->decoded_content);
        readingsBeginUpdate($Device);
        readingsBulkUpdateIfChanged($Device, "Output1_State", $response_json->{'Outputs'}->[0]->{'State'});
        readingsBulkUpdateIfChanged($Device, "Output1_Delay", $response_json->{'Outputs'}->[0]->{'Delay'});
        readingsBulkUpdateIfChanged($Device, "Output2_State", $response_json->{'Outputs'}->[1]->{'State'});
        readingsBulkUpdateIfChanged($Device, "Output2_Delay", $response_json->{'Outputs'}->[1]->{'Delay'});
        readingsBulkUpdateIfChanged($Device, "Output3_State", $response_json->{'Outputs'}->[2]->{'State'});
        readingsBulkUpdateIfChanged($Device, "Output3_Delay", $response_json->{'Outputs'}->[2]->{'Delay'});
        readingsBulkUpdateIfChanged($Device, "Output4_State", $response_json->{'Outputs'}->[3]->{'State'});
        readingsBulkUpdateIfChanged($Device, "Output4_Delay", $response_json->{'Outputs'}->[3]->{'Delay'});
        if($Device->{MODEL} eq '4All')
        {
          readingsBulkUpdateIfChanged($Device, "Voltage", $response_json->{'GlobalMeasure'}->{'Voltage'});
          readingsBulkUpdateIfChanged($Device, "Frequency", $response_json->{'GlobalMeasure'}->{'Frequency'});
          readingsBulkUpdateIfChanged($Device, "TotalCurrent", $response_json->{'GlobalMeasure'}->{'TotalCurrent'});
          readingsBulkUpdateIfChanged($Device, "OverallPowerFactor", $response_json->{'GlobalMeasure'}->{'OverallPowerFactor'});
          readingsBulkUpdateIfChanged($Device, "TotalLoad", $response_json->{'GlobalMeasure'}->{'TotalLoad'});
          readingsBulkUpdateIfChanged($Device, "TotalEnergy", $response_json->{'GlobalMeasure'}->{'TotalEnergy'});
          readingsBulkUpdateIfChanged($Device, "EnergyStart", $response_json->{'GlobalMeasure'}->{'EnergyStart'});
          readingsBulkUpdateIfChanged($Device, "Output1_Current", $response_json->{'Outputs'}->[0]->{'Current'});
          readingsBulkUpdateIfChanged($Device, "Output1_PowerFactor", $response_json->{'Outputs'}->[0]->{'PowerFactor'});
          readingsBulkUpdateIfChanged($Device, "Output1_Load", $response_json->{'Outputs'}->[0]->{'Load'});
          readingsBulkUpdateIfChanged($Device, "Output1_Energy", $response_json->{'Outputs'}->[0]->{'Energy'});
          readingsBulkUpdateIfChanged($Device, "Output2_Current", $response_json->{'Outputs'}->[1]->{'Current'});
          readingsBulkUpdateIfChanged($Device, "Output2_PowerFactor", $response_json->{'Outputs'}->[1]->{'PowerFactor'});
          readingsBulkUpdateIfChanged($Device, "Output2_Load", $response_json->{'Outputs'}->[1]->{'Load'});
          readingsBulkUpdateIfChanged($Device, "Output2_Energy", $response_json->{'Outputs'}->[1]->{'Energy'});
          readingsBulkUpdateIfChanged($Device, "Output3_Current", $response_json->{'Outputs'}->[2]->{'Current'});
          readingsBulkUpdateIfChanged($Device, "Output3_PowerFactor", $response_json->{'Outputs'}->[2]->{'PowerFactor'});
          readingsBulkUpdateIfChanged($Device, "Output3_Load", $response_json->{'Outputs'}->[2]->{'Load'});
          readingsBulkUpdateIfChanged($Device, "Output3_Energy", $response_json->{'Outputs'}->[2]->{'Energy'});
          readingsBulkUpdateIfChanged($Device, "Output4_Current", $response_json->{'Outputs'}->[3]->{'Current'});
          readingsBulkUpdateIfChanged($Device, "Output4_PowerFactor", $response_json->{'Outputs'}->[3]->{'PowerFactor'});
          readingsBulkUpdateIfChanged($Device, "Output4_Load", $response_json->{'Outputs'}->[3]->{'Load'});
          readingsBulkUpdateIfChanged($Device, "Output4_Energy", $response_json->{'Outputs'}->[3]->{'Energy'});
        }
        readingsEndUpdate($Device, 1);
        $Device->{STATE} = 'on';
        return undef;
    }
    else {
        return $response->status_line, "\n";
        $Device->{STATE} = 'off';
    }
  }
}

1;

=pod

=item summary Control NETIO 4/4All/4C Networked Power Sockets via Ethernet or WiFi using JSON M2M-API

=begin html

<a name="NETIO_4x"></a>
<h3>NETIO_4x</h3>
<ul>
    <p>The NETIO_4x module provides access to NETIO 4/4All/4C Networked Power Sockets via Ethernet or WiFi.
    These power sockets can be accessed over a JSON M2M-API, after enabling it over the device's web user interface
    (please see <a href="https://github.com/elmicro/fhem_netio_4x_pm">installation instructions</a> for details).</p>

    <a name="NETIO_4x_Define"></a>
    <b>Define</b><br>
    <ul>
        <p><code>define &lt;name&gt; NETIO_4x &lt;model&gt; &lt;connection&gt;</code></p>
        <ul>
          <li><code>&lt;name&gt;</code> string providing a device name for FHEM</li>
          <li><code>&lt;model&gt;</code> can be one of the following NETIO models: <code>4</code>, <code>4C</code> or <code>4All</code></li>
          <li><code>&lt;connection&gt;</code> can be provided with the following format: <code>http://user:password@HOST:PORT</code></li>
          <li><code>https</code> is currently not implemented</li>
          <li><code>user:password@</code> may be omitted if basicAuth is not in use</li>
          <li><code>HOST</code> may be supplied as an IPv4-address (e.g. <code>192.168.1.123</code>) or as hostname/domain (e.g. <code>mynetio.fritz.box</code>)</li>
          <li>if <code>:PORT</code> if omitted, default port 80 is used</li>
        </ul>
        <p>Examples:</p>
        <code>
          # define a '4' device using an IP-address:<br/>
          define MyNetio4 NETIO_4x 4 http://192.168.1.10 <br/>
          # define a '4C' device using a custom port:<br/>
          define MyNetio4 NETIO_4x 4C http://192.168.178.10:99 <br/>
          # define a '4All' device using basicAuth:<br/>
          define MyNetio4All NETIO_4x 4All http://bob:123456@192.168.1.10 <br/>
          # define a '4All' device using a domain name, basicAuth and a custom port:<br/>
          define MyNetio4All NETIO_4x 4All http://jsonuser:jsonpwd@mynetio.fritz.box:123 <br/>
        </code>
    </ul>
    <br>

    <a name="NETIO_4x_Set"></a>
    <b>Set</b><br>
    <ul>
        <p><code>set &lt;name&gt; &lt;output&gt; &lt;command&gt;</code></p>
        <p>You can <i>set</i> an <code>&lt;output&gt;</code> (1-4) by submitting a <code>&lt;command&gt;</code> (0-6).
        All readings will be updated by the response of the device when they have changed (except the <b>OutputX_State</b>
        of the controlled outlet when the issued <code>&lt;command&gt;</code> was 2, 3, 5 or 6).
        </p>
        available <code>&lt;command&gt;</code> values:
        <ul>
              <li><code>0</code> - switch <code>&lt;output&gt;</code> off immediately</li>
              <li><code>1</code> - switch <code>&lt;output&gt;</code> on immediately</li>
              <li><code>2</code> - switch <code>&lt;output&gt;</code> off for a time specified by the output's <b>OutputX_Delay</b> reading (in ms) and then switch <code>&lt;output&gt;</code> on again</li>
              <li><code>3</code> - switch <code>&lt;output&gt;</code> on for a time specified by the output's <b>OutputX_Delay</b> reading (in ms) and then switch <code>&lt;output&gt;</code> off again</li>
              <li><code>4</code> - toggle <code>&lt;output&gt;</code> (invert the state)</li>
              <li><code>5</code> - no change on <code>&lt;output&gt;</code> (output state is retained)</li>
              <li><code>6</code> - ignore (state value is used to control output) <b><i>!NOTE!</i></b> that no state value is send by the NETIO_4x module.</li>
        </ul>
    </ul>
    <br>

    <a name="NETIO_4x_Get"></a>
    <b>Get</b><br>
    <ul>
        <p><code>get &lt;name&gt; state</code></p>
        <p>Get all available information from the device - update the readings.</p>
    </ul>
    <br>

    <a name="NETIO_4x_Readings"></a>
    <b>Readings</b><br>
    <ul>
      <ul>
            <li><b>OutputX_State</b> - state of each output (0=off, 1=on)</li>
            <li><b>OutputX_Delay</b> - the delay which is used for short off/on (<code>&lt;command&gt;</code> 2/3) in ms for each output</li>
      </ul>
      <p>NETIO model <code>4All</code> additionally submits the following readings:</p>
      <ul>
            <li><b>OutputX_Current</b> - the current drawn from each outlet (in mA)</li>
            <li><b>OutputX_Energy</b> - the energy consumed by each outlet since the time given in the <b>EnergyStart</b> reading (in Wh)</li>
            <li><b>OutputX_Load</b> - the load on each outlet (in W)</li>
            <li><b>OutputX_PowerFactor</b> - the power-factor on each outlet</li>
            <li><b>EnergyStart</b> - date and time of the last reset of all energy counters</li>
            <li><b>Frequency</b> - AC frequency within the device (in Hz)</li>
            <li><b>OverallPowerFactor</b> - power-factor weighted average from all meters</li>
            <li><b>TotalCurrent</b> - the current drawn from all outlets (in mA)</li>
            <li><b>TotalEnergy</b> - the energy consumed on all outlets since the time given in the <b>EnergyStart</b> reading (in Wh)</li>
            <li><b>TotalLoad</b> - the load on all outlets (in W)</li>
            <li><b>Voltage</b> - AC voltage within the device (in V)</li>
      </ul>
    </ul>
    <br>
</ul>

=end html

=cut
