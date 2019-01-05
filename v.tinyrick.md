# Concept

## Chaine acquisition US au format pHAT

## Contraintes

* Petite taille (pHAT): même taille que pi zero 
* Acquisition temps réel signifie, lecture direct par le Rpi? avec buffer dans le FPGA?
Meme grandeur de nb de lignes?
-> Buffer dans le FPGA, temps réekl sur la période de l'acquisition seulement. Nécessité de 20k pts a minima, tout ce qui est en plus est bon à prendre.

* 20Msps au niveau de l'ADC, 12 bits
* No external RAM 

* Blocks DSPs disponibles
pour quelles utilisations? le code FGPA doit en laisser des disponibles?
-> Possiblement pour filtrage FFT (pour tests..) par la suite. Si le code FPGA peut en laisser des dispo ce serait top.

* Serie ice40 - UP5K en QFN pour ses 1Mbits de ram
* Used only with RPi: fpga can be programmable through RPi / ice40 toolchain

## Nice to have

If there's enough room:
droit d'avoir des composants en Top et Bottom?
-> Oui
* Test points for logic signals (PPon, PNon, damp, trig, ...)
ok, header 2.54?

-> there is no TRIG signal.. but there is a button trig attached also to the RPI . so this in input can read the button but in output can be used also as trig signal(to save one GPIO)
-> Header 2x20 pour RPi
-> Peut faire apparaitre sur les Pins du RPi.

* Flash
flash contenant le program ice40?  si on n'en met pas ca veux dire que le logiciel python program a chaque reset? cela ne doit pas etre un nice to have. on met ou pas? il faut choisir:)
-> OUI pour la flash
-> flash program only by RPI

* 2 petits boutons (1 reset, 1 trigger)
ok
-> yes

## Fonctions requises:

- Pulser, bipolar, en HVPos et HVNeg
matty est unipolar? right?
-> Yes. Par contre, je ferais bien des tests en bipolar. HV7361 semble bipolar sur petite place.. (avec une protection)
- Protect variable gain : path should not exceed +-2V
ok, protection zener devant l'adc
-> MD0100 et inclus également dans HV7361
- Choice between two entries for VGA path (one from pulser, another from raw SMA)
ok, comme matty V1.1, le sma cable sur la carte?
-> Tout à fait.
-> HV7361 unipolar in the Minie only.. could be bipolar with daughter : by default need a jumper between HV_base and HV  and -Hv and GND.


- Variable gain to have
 - DAC to set up the variable gain (as in matty)
 ok
-> same matty
 - activate, or not, a fixed gain (eg, the HILO input on AD8331)
-> done
 Quel est l'interet si le dac peut fixer le gain? sinon jumper? I/O sur Rpi?
-> En fait, le HILO sur AD8331 correspond à un gain fixe, qui s'ajoute au gain variable.
- Real time
- SPI connection through RPIo connector
ok
-> connection  RPI to FPGA for sure, not for the peripheral DAC/EXT
- Unused IOs to RPi GPIOs
ok
-> 3 GPIO
- Logic trigger to start acquisition
ok, 1 trig button et 1 I/O, plus besoin du trig Spi? existe deja donc ne coute rien.
-> Top
-> see previous comment
- 500 us d'acquisition
ca donne 20k mots de donnees a 20Msps sur les 64k dispo en ram, donc possibilitde de deverser en spi seulement apres l'aquisition
-> Et donc de faire par exemple 3 lignes

- possible form 20Msps t o 65MPS 10 bits to 14 bits
## Fonctions externes

- Generation des hautes tensions + et - (board separée, connecteur Ã  prévoir avec protection polarité )
- Controle RPi
-> Carte fille en effet pour la HV, quitte à avoir un connecteur simple entre les deux (HVP, HVN, 5V, GND). Mais pas dans ce devis, car je n'ai pas le dimensionnement du courant..

besoin d'un carte fille HV? Inclus dans ce devis? je n'ai pas le feedback de mon precedent design encore, mais je pense que la demande en courant est plus importante pour votre besoin. Si vous voulez une valeur variable, c'est possible mais demande plus de developement.
quelle est la tension voulue? le courant maximum a la tension maximum?

## Affichage

- LEDs sur HILO, CS du RPi
HILO: le gain ? Voir commentaire precedent. Cette entree ne fixe pas le gain.
Cs du rpi ?CS de l'acces spi vers le FPGA , right?
- 3 LEDs user accessible
ok, des couleurs ? 3 vertes? au fait que donne l'intensite lumineuse sur matty?

FPGA: 3 LED RGB
1 led power
1 led HILO
1 led SPI_RPI2ICE_CS
1 led CDONE
