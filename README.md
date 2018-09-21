# DevOpsBroker
DevOpsBroker delivers enterprise-level software tools to maximize individual and organizational ability to deliver applications and services at high velocity

## Ubuntu 16.04 Desktop Configurator ![New Release](images/new-icon.png)

The DevOpsBroker Ubuntu 16.04 Desktop Configurator is a complete turn-key solution for configuring a fresh installation of Ubuntu 16.04 Desktop.

A complete list of features and installation instructions can be found [here](Ubuntu/16.04/Desktop/Configurator/doc/README.md).

### Installation Overview
1. Download the latest Ubuntu 16.04 Desktop ISO from [Ubuntu 16.04 Releases](http://releases.ubuntu.com/16.04/)

2. Install Ubuntu 16.04 Desktop

3. Download the latest release of [desktop-configurator](https://github.com/macvelli/DevOpsBroker/releases/download/desktop-configurator-1.0.0/desktop-configurator_1.0.0_amd64.deb) and its [SHA256 Checksum](https://github.com/macvelli/DevOpsBroker/releases/download/desktop-configurator-1.0.0/SHA256SUM)

4. Verify the **desktop-configurator** package against its SHA256 checksum

   * `sha256sum --check ./SHA256SUM`


5. Install the **desktop-configurator** package

   * `sudo apt install ./desktop-configurator_1.0.0_amd64.deb`


6. Configure your desktop

   * `sudo configure-desktop`

### Bugs / Feature Requests

Please submit any bugs or feature requests to GitHub by creating a [New issue](https://github.com/macvelli/DevOpsBroker/issues)
