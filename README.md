![](preview.gif)

![](screenshot.png)

# Uniblocks: Universal updatable status bar module generator

Uniblocks wraps all of your status bar modules into a single string that updates only the part that has changed. This string can be used with any status bar application since Uniblocks itself handles all the updating.

## Features

-  The modules can be updated without the status bar's interventions
-  Updating is possible both periodically and manually
-  Runs as fast as it gets. (hint: ~70 Lines of POSIX shellscript)

## Dependencies

-  cat, sed, grep, pgrep, mkfifo

## Installation

```sh
git clone https://github.com/salman-abedin/uniblocks.git && cd uniblocks && sudo make install
```

## Usage

-  Create a **~/.config/uniblocksrc** file for configuring the modules.
   Here is an [examples](https://github.com/salman-abedin/uniblocks/blob/master/example_config)

| Command                       | Effect                                                                   |
| ----------------------------- | ------------------------------------------------------------------------ |
| `uniblocks --gen,-g`          | Prints the status string to standard out (The config dictates the order) |
| `uniblocks --update,-u <TAG>` | Manually updates individual module (e.g. The volume module)              |
| `uniblocks --kill,-k`         | Kills all running instances                                              |

## Uninstallation

```sh
sudo make uninstall
```

---

## Repos you might be interested in

[Alfred/panel.sh](https://github.com/salman-abedin/alfred/blob/master/panel.sh)
: The status bar modules

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
