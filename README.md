![](preview.gif)

![](screenshot.png)

# Uniblocks: Universal updatable status bar module generator

Uniblocks wraps all of your status bar modules into a single string that updates only the part that has changed. This string can be used with any status bar application since Uniblocks itself handles all the updating.

## Features

-  The modules can be updated without the status bar's interventions
-  Updating is possible both periodically and manually
-  Different modules can be updated at different intervals
-  Runs as fast as it gets. (hint: ~75 Lines of POSIX shell scripting with FIFO)

## Dependencies

-  pgrep, xargs, mkfifo, sleep

## Installation

```sh
git clone https://github.com/salman-abedin/uniblocks.git && cd uniblocks && sudo make install
```

## Patches

-  **dwm status support**.

```sh
cd uniblocks
patch < dwm.diff    # Add the feature
patch -R < dwm.diff # Remove the feature
```

## Usage

-  Create a **~/.config/uniblocksrc** file for configuring the modules.
   Here is an [examples](https://github.com/salman-abedin/uniblocks/blob/master/example_config)

| Command                       | Effect                                                                   |
| ----------------------------- | ------------------------------------------------------------------------ |
| `uniblocks --gen,-g`          | Prints the status string to standard out (The config dictates the order) |
| `uniblocks --update,-u <TAG>` | Manually updates individual module (e.g. The volume module)              |

## Uninstallation

```sh
cd uniblocks
sudo make uninstall
```

---

## Repos you might be interested in

| Name                                                                         | Description                     |
| ---------------------------------------------------------------------------- | ------------------------------- |
| [Alfred/panel](https://github.com/salman-abedin/alfred/blob/master/panel.sh) | The status bar modules          |
| [bolt](https://github.com/salman-abedin/bolt)                                | The launcher wrapper            |
| [tide](https://github.com/salman-abedin/puri)                                | Minimal Transmission CLI client |
| [puri](https://github.com/salman-abedin/puri)                                | Minimal URL launcher            |
| [devour](https://github.com/salman-abedin/devour)                            | Terminal swallowing             |
| [crystal](https://github.com/salman-abedin/crystal)                          | The transparent setup           |
| [Magpie](https://github.com/salman-abedin/magpie)                            | The dotfiles                    |
| [Alfred](https://github.com/salman-abedin/alfred)                            | The scripts                     |

## Contact

SalmanAbedin@disroot.org
