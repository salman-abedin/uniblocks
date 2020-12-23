# Uniblocks: Status bar agnostic module generator

Uniblocks wraps all of your status bar modules into a single string that updates only the part that has changed.  
This string can be used with any status bar application since Uniblocks itself handles all the updating.

![](https://gitlab.com/salman-abedin/assets/-/raw/master/uniblocks.gif)

![](https://gitlab.com/salman-abedin/assets/-/raw/master/uniblocks_bar.png)

## Features

- The modules can be updated without the status bar's interventions
- Updating is possible both periodically and manually
- Different modules can be updated at different intervals
- Can be used with any status bar application
- Tiny & fast ( hint: ~80 lines of POSIX shellscript with only sleep calls)

## Dependencies

- mkfifo, sleep

## Installation

```sh
git clone https://github.com/salman-abedin/uniblocks.git && cd uniblocks && make && sudo make install
```

## Usage

- Modify `~/.config/uniblocksrc` according to your particular status bar setup.

- Script belows commands as necessary.

| Command                       | Effect                                                      |
| ----------------------------- | ----------------------------------------------------------- |
| `uniblocks --gen,-g`          | Prints the status string according to the config            |
| `uniblocks --update,-u <TAG>` | Manually updates individual module (e.g. The volume module) |

## Update

```sh
cd uniblocks
git pull --no-rebase && sudo make install
```

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
| [faint](https://github.com/salman-abedin/faint)                              | The launcher wrapper            |
| [bolt](https://github.com/salman-abedin/bolt)                                | The launcher wrapper            |
| [tide](https://github.com/salman-abedin/puri)                                | Minimal Transmission CLI client |
| [puri](https://github.com/salman-abedin/puri)                                | Minimal URL launcher            |
| [devour](https://github.com/salman-abedin/devour)                            | X11 window swallower            |
| [crystal](https://github.com/salman-abedin/crystal)                          | The transparent setup           |
| [Magpie](https://github.com/salman-abedin/magpie)                            | The dotfiles                    |
| [Alfred](https://github.com/salman-abedin/alfred)                            | The scripts                     |

## Contact

SalmanAbedin@disroot.org
