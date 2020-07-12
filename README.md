# Uniblocks: Universal updatable status bar modules generator

![](preview.gif)

![Uniblocks](https://cloud.disroot.org/s/fjQCarxJZNJj5Wz/preview)

## Features

-  Can be used with any status bar application
-  Periodic & event based update
-  Runs as fast as it gets! (hint: POSIX compliant shellscript)

## Dependencies

-  sed, grep, pgrep, xargs, cat, mkfifo

## Installation

```sh
git clone https://github.com/salman-abedin/uniblocks.git && cd uniblocks && sudo make install
```

## Usage

-  Create a **~/.config/uniblocksrc** file for configuring the modules.
   Here is an [examples](https://github.com/salman-abedin/uniblocks/blob/master/example_config)

-  run `uniblocks --server,-s` to launch the server (preferably on startup)

-  run `uniblocks --client,-c` to generate the status string

   -  Modules are ordered according to the order in the **config**

-  run `uniblocks --client,-c <TAG>` to generate individual modules

   -  This will be useful in order to integrate your updatable modules with a status bar applications

-  run `uniblocks --update,-u <TAG>` to update individual modules

## Uninstallation

```sh
sudo make uninstall
```

---

## Repos you might be interested in

[alfred/panel.sh](https://github.com/salman-abedin/alfred/blob/master/panel.sh)
: Collection of statusbar modules

[Bolt](https://github.com/salman-abedin/bolt)
: The lightning fast workflow creator

[Crystal](https://github.com/salman-abedin/crystal)
: The transparent setup

[Magpie](https://github.com/salman-abedin/magpie)
: The dotfiles

[Alfred](https://github.com/salman-abedin/alfred)
: The scripts

[Devour](https://github.com/salman-abedin/devour)
: Terminal swallowing

## Contact

SalmanAbedin@disroot.org
