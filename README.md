# fhem_netio_4x_pm
## FHEM module to control NETIO 4x (NETIO 4, NETIO 4All, NETIO 4C) Networked Power Sockets

by Oliver Schönefeld - for [Elektronikladen Microcomputer](https://elmicro.com)  
https://github.com/elmicro/fhem_netio_4x_pm

### Description

This module for the FHEM Home Automation System provides access to NETIO 4x series Networked Power Sockets
[NETIO 4](https://elmicro.com/de/netio.html) /
[NETIO 4All](https://elmicro.com/de/netio-4all.html) /
[NETIO 4C](https://elmicro.com/de/netio-4c.html).
These Ethernet- or WiFi-connected power sockets can be accessed over a JSON M2M-API, after enabling JSON via the device's web user interface.

### Installation

For the following instructions we assume that FHEM is properly installed on a Raspberry Pi as descibed at https://wiki.fhem.de/wiki/Raspberry_Pi

Begin with copying `24_NETIO_4x.pm` from this repository to `/opt/fhem/FHEM` without renaming the file:  
`sudo cp ./24_NETIO_4x.pm /opt/fhem/FHEM`

Change file privileges:  
`sudo chown fhem:dialout /opt/fhem/FHEM/24_NETIO_4x.pm`  
`sudo chmod 0775 /opt/fhem/FHEM/24_NETIO_4x.pm`

Restart FHEM service:  
`sudo service fhem restart`

### Usage

The following commands can be entered in the FHEM commandline or added to the fhem.cfg file.

#### `define` devices

`define <name> NETIO_4x <model> <connection>`

* <name> string providing a device name for FHEM
* <model> can be one of the following NETIO models: 4, 4C or 4All
* <connection> can be provided with the following format: http://user:password@HOST:PORT
* https is currently not implemented
* user:password@ may be omitted if basicAuth is not in use
* HOST may be supplied as an IPv4-address (e.g. 192.168.1.123) or as hostname/domain (e.g. mynetio.fritz.box)
* if :PORT if omitted, default port 80 is used

Examples:  
# define a '4' device using an IP-address:  
define MyNetio4 NETIO_4x 4 http://192.168.1.10

# define a '4C' device using a custom port:  
define MyNetio4 NETIO_4x 4C http://192.168.178.10:99

# define a '4All' device using basicAuth:  
define MyNetio4All NETIO_4x 4All http://bob:123456@192.168.1.10

# define a '4All' device using a domain name, basicAuth and a custom port:  
define MyNetio4All NETIO_4x 4All http://jsonuser:jsonpwd@mynetio.fritz.box:123

#### `set` output state

Enter in the FHEM commandline or submit via FHEM WebGUI/Tablet-UI:  
`set DeviceName output command`  
You can `set` an `output` (`1`, `2`, `3`, `4`) by submitting a `command`. All readings will be updated by the response of the device when they have changed (except the **OutputX_State** of the controlled outlet when the issued `command` was `2`, `3`, `5` or `6`).  
*available `command` values:*  
  * `0` - switch `output` off immediately
  * `1` - switch `output` on immediately
  * `2` - switch `output` off for the outputs **OutputX_Delay** reading (in ms) and then switch `output` on again (restart)
  * `3` - switch `output` on for the outputs **OutputX_Delay** reading (in ms) and then switch `output` off again
  * `4` - toggle `output` (invert the state)
  * `5` - no change on `output` (output state is retained)
  * `6` - ignore (state value is used to controll output) ***!NOTE!*** that no state value is send by the NETIO_4x module.
  
#### `get` output state

Enter in the FHEM commandline or submit via FHEM WebGUI/Tablet-UI:  
`get DeviceName status`  
You can `get` all the available info from the device and update the readings.

#### device readings

  * **OutputX_State** - state of each output (0=off, 1=on)  
  * **OutputX_Delay** - the delay which is used for short off/on (`command` `2` and `3`) in ms for each output  
*Netio-Devices of the `DeviceModel` `4All` also submit the following readings:*
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


### Copyright, License
This software is Copyright (C)2018 by ELMICRO - https://elmicro.com  
and may be freely used, modified and distributed under the terms  
of the MIT License - see accompanying LICENSE.md for details

### References
[1] FHEM Home Automation Server: http://fhem.de/
[2] NETIO products a.s.: https://www.netio-products.com/en
