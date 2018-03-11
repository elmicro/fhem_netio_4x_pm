# fhem_netio_4x_pm
## FHEM module to control NETIO 4x (NETIO 4, NETIO 4All, NETIO 4C) Networked Power Sockets

by Oliver Schönefeld - for [Elektronikladen Microcomputer](https://elmicro.com)  
https://github.com/elmicro/fhem_netio_4x_pm

### Description

This module for the FHEM Home Automation System provides access to NETIO 4x series Networked Power Sockets
[NETIO 4](https://elmicro.com/de/netio.html) /
[NETIO 4All](https://elmicro.com/de/netio-4all.html) /
[NETIO 4C](https://elmicro.com/de/netio-4c.html).
These Ethernet- or WiFi-connected power sockets can be accessed using a variety of protocols and M2M-API methods, including HTTP(s) CGI, Telnet, XML, JSON, MQTT, SNMPv3, SIP and Modbus/TCP. JSON API is actually used in this module implementation.

### Installation

For the following instructions it is assumed that FHEM is properly installed on a Raspberry Pi as descibed at  
https://wiki.fhem.de/wiki/Raspberry_Pi  
Example file paths etc. may differ for other environments.

First, you need to know (or find out) the IP addresses of your FHEM server (i.e. Raspberry Pi) and your NETIO4 unit. In these instructions we'll assume:
* Raspberry: 192.168.178.123
* NETIO 4All: 192.168.178.99

Begin with copying `24_NETIO_4x.pm` from this repository to `/opt/fhem/FHEM`. On a commandline this could be done by:  
`sudo cp ./24_NETIO_4x.pm /opt/fhem/FHEM`

Change file privileges:  
`sudo chown fhem:dialout /opt/fhem/FHEM/24_NETIO_4x.pm`  
`sudo chmod 0775 /opt/fhem/FHEM/24_NETIO_4x.pm`

Restart FHEM service:  
`sudo service fhem restart`

Open the web interface of your NETIO device, log in and enable JSON support. Setting user/password is recommended to incease security (we use the same combination `jsonuser`/`jsonpwd`here for read and write access):

![Enable JSON](https://raw.githubusercontent.com/elmicro/fhem_netio_4x_pm/master/images/netio4-enable-json.jpg)

Open FHEM web interface in a browser window (e.g. http://192.168.178.123:8083) and define your NETIO_4x device, e.g.:

`define MyNetio4All NETIO_4x 4All http://jsonuser:jsonpwd@192.168.178.99`

Now the new device *MyNetio4All* can be found (and accessed) under the *Everything* menu item.

In the menu click *Save config* to preserve settings beyond a system restart.

For a final test, switch on the 1st output by entering the following command:

`set MyNetio4All 1 1`

Then, switch it off again:

`set MyNetio4All 1 0`


### Command Reference

The following information is also available in the module's `commandref` section. Please note that the module's commandref will be added to the global commandref.html file only after an update, which can be triggered with `"/usr/bin/perl ./contrib/commandref_join.pl"` (even from FHEM's web interface - just preserve the quotes).

The commands listed below can be entered in the FHEM commandline or added to the fhem.cfg file.

> #### Define Devices

`define <name> NETIO_4x <model> <connection>`

* `<name>` string providing a device name for FHEM
* `<model>` can be one of the following NETIO models: 4, 4C or 4All
* `<connection>` can be provided with the following format: http://user:password@HOST:PORT
* https is currently not implemented
* user:password@ may be omitted if basicAuth is not in use
* HOST may be supplied as an IPv4-address (e.g. 192.168.1.123) or as hostname/domain (e.g. mynetio.fritz.box)
* if :PORT if omitted, default port 80 is used

Examples:

* define a '4' device using an IP-address:  
  `define MyNetio4 NETIO_4x 4 http://192.168.1.10`
* define a '4C' device using a custom port:  
  `define MyNetio4 NETIO_4x 4C http://192.168.178.10:99`
* define a '4All' device using basicAuth:  
  `define MyNetio4All NETIO_4x 4All http://bob:123456@192.168.1.10`
* define a '4All' device using a domain name, basicAuth and a custom port:  
  `define MyNetio4All NETIO_4x 4All http://jsonuser:jsonpwd@mynetio.fritz.box:123`

> #### Set Output State

`set <name> <output> <command>`

You can set an `<output>` (1-4) by submitting a `<command>` (0-6). All readings will be updated by the response of the device when they have changed (except the OutputX_State of the controlled outlet when the issued `<command>` was 2, 3, 5 or 6).
available `<command>` values:

* `0` - switch `<output>` off immediately
* `1` - switch `<output>` on immediately
* `2` - switch `<output>` off for a time specified by the output's OutputX_Delay reading (in ms) and then switch <output> on again
* `3` - switch `<output>` on for a time specified by the output's OutputX_Delay reading (in ms) and then switch <output> off again
* `4` - toggle `<output>` (invert the state)
* `5` - no change on `<output>` (output state is retained)
* `6` - ignore (state value is used to control output) !NOTE! that no state value is send by the NETIO_4x module
  
> #### Get Output State

`get <name> state`

Get all available information from the device - update the readings.

> #### Device Readings

* **OutputX_State** - state of each output (0=off, 1=on)  
* **OutputX_Delay** - the delay which is used for short off/on (`command` `2` and `3`) in ms for each output  

NETIO 4All model additionally submits the following readings:

* **OutputX_Current** - the current drawn from each outlet (in mA)
* **OutputX_Energy** - the energy consumed by each outlet since the time given in the **EnergyStart** reading (in Wh)
* **OutputX_Load** - the load on each outlet (in W)
* **OutputX_PowerFactor** - the power-factor on each outlet
* **EnergyStart** - date and time of the last reset of all energy counters
* **Frequency** - AC frequency within the device (in Hz)
* **OverallPowerFactor** - power-factor weighted average from all meters
* **TotalCurrent** - the current drawn from all outlets (in mA)
* **TotalEnergy** - the energy consumed on all outlets since the time given in the **EnergyStart** reading (in Wh)
* **TotalLoad** - the load on all outlets (in W)
* **Voltage** - AC voltage within the device (in V)

### ToDo

* add information about Tablet-UI example

### Copyright, License
This software is Copyright (C)2018 by ELMICRO - https://elmicro.com  
and may be freely used, modified and distributed under the terms  
of the MIT License - see accompanying LICENSE.md for details

### References
[1] FHEM Home Automation Server: http://fhem.de/  
[2] NETIO products a.s.: https://www.netio-products.com/en
