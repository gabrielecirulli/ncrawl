# ncrawl #

Network crawler capable of device identification and mass subnet-scanning. Automation and target generation to come!

## Installation ##

```bash
$ npm install ncrawl
$ ncrawl --help
```

or

```bash
$ git clone git@github.com:sebmck/ncrawl.git ncrawl
$ cd ncrawl
$ npm install
$ ./ncrawl.sh --help
```

### Examples ###

Scan subnet and display empty scans and failed modules.

```bash
$ ncrawl -T 192.168.2.1-192.168.2.255 --empty --errors
```

### Command Line Options ###

See the [wiki](https://github.com/sebmck/ncrawl/wiki/Options) for a detailed overview.

```bash
$ ncrawl --help

  Usage: ncrawl [options]

  Options:

    -h, --help                  output usage information
    -V, --version               output the version number
    -T, --targets [string]      List of targets (192.168.2.1-192.168.5.255)
    -m, --modules [string]      Only run specified modules - comma delimetered [all]
    -p, --ports [string]        Additional ports youd like scanned - comma delimetered
    -o, --operations [number]   Amount of concurrent operations [512]
    -t, --timeout [number]      Module timeout in milliseconds [2000]
    -r, --reporter [string]     Reporter to use [compact]
    -e, --errors                Show errored modules
    -h, --empty                 Show empty targets
    --http-user-agent [string]  User agent to use for the HTTP module [Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0)]

  Modules:

    https                       HTTPS module
    http                        HTTP module
    ftp                         FTP module

  Examples:

    $ ncrawl -T localhost

```

## Documentation ##

See the [wiki](https://github.com/sebmck/ncrawl/wiki/_pages) for additional documentation.

## Modules ##

Current modules are:

* **HTTP** using [request](https://github.com/mikeal/request)
* **HTTPS** using [request](https://github.com/mikeal/request)
* **FTP** using [node-ftp](https://github.com/mscdex/node-ftp)

## Todo ##

* SMTP module
* POP3 module
* SSH module
* MySQL module
* Telnet module
* Target generation
* Convert API to events.

## License ##

The MIT License (MIT)
Copyright (c) 2012 Sebastian McKenzie
 
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.