---
layout: default
title: un0rick Dual NDT
parent: un0rick
nav_order: 7
---

# Separate Tx/Rx paths

The board has a possibility to differentiate Tx and Rx path. By default, R72 is installed and not R73. The the schematics below, J1 and J16 are respectively the SMA connectors to Rx and Tx ("to sensor" - tx - goes to the piezo, "pulser input" goes to the acquistion - rx - path).

![](https://github.com/kelu124/un0rick/raw/master/images/txrx.png)

To differentiate the paths,  remove R72 and install R73 jumper instead. This way, pulse goes only to Tx (J16) and not to Rx (J1).

![](https://github.com/kelu124/un0rick/raw/master/images/separate_tx_rx.png)

See more for [NDT here](http://un0rick.cc/UseCase/NDT).


