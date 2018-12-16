#!/usr/bin/python
# -*- coding: utf-8 -*-
# -------------------------
# (c) kelu124
# GPLv3
# -------------------------

import json
import time
import datetime
import os
import sys
import spidev
import numpy as np
import matplotlib.pyplot as plt

try:
    import RPi.GPIO as GPIO
except:
    print "Not loading RPi.GPIO as not on RPi"

try:
    import pyexiv2
except:
    print "pyexiv2 does not exist on RPi"


'''Description: Most updated library for the un0rick platform.
@todo: improve doc: http://sametmax.com/les-docstrings/
'''

__author__ = "kelu124"
__copyright__ = "Copyright 2018, Kelu124"
__license__ = "GPLv3"





##############
#
# RPI Part
#
##############

class us_spi:
    """
       Creates a connection to the board.
       Used to acquire signals and store all acquisition parameters.
    """

    JSON = {}
    spi = spidev.SpiDev()

    JSON["firmware_md5"] = "fa6a7560ade6d6b1149b6e78e0de051f"
    JSON["firmware_version"] = "e_un0"
    JSON["data"] = []
    JSON["time"] = unicode(datetime.datetime.now())
    JSON["registers"] = {}
    JSON["experiment"] = {}
    JSON["parameters"] = {}
    JSON["timings"] = {}
    JSON["experiment"]["id"] = str(datetime.datetime.now().strftime("%Y%m%d"))+"a"
    JSON["experiment"]["description"] = "na"
    JSON["experiment"]["probe"] = "na"
    JSON["experiment"]["target"] = "na"
    JSON["experiment"]["position"] = "na"
    JSON["V"] = "-1"

    Fech = 0
    Nacq = 0
    LAcq = 0
    number_lines = 0

    def create_tgc_curve(self, Deb, Fin, CurveType):
        """
        Returns an arary with the TGC values, along a 40 values array.
        Used afterwards to set fpga registers.
        """
        n = 200/5
        DACValues = []
        for k in range(n+1):
            if CurveType:
                val = int(Deb+1.0*k*(Fin-Deb)/n)
            else:
                val = int((Fin-Deb)*k**3/n**3+Deb)
            DACValues.append(val)
        DACValues[-1] = 0
        DACValues[-2] = 0
        self.set_tgc_curve(DACValues)
        return DACValues, len(DACValues)

    def set_timings(self, t1, t2, t3, WaitTill, t5):
        t4 = WaitTill # 20us delay before acquisition
        self.set_pulse_train(t1, t2, t3, t4, t5)
        # Some figures about the acquisitions now
        self.LAcq = (t5-WaitTill)/1000 #ns to us
        self.Nacq = int(self.LAcq * self.Fech * self.number_lines)
        self.JSON["timings"]["t1"] = t1
        self.JSON["timings"]["t2"] = t2
        self.JSON["timings"]["t3"] = t3
        self.JSON["timings"]["t4"] = WaitTill
        self.JSON["timings"]["t5"] = t5
        self.JSON["timings"]["NAcq"] = self.Nacq
        self.JSON["timings"]["LAcq"] = self.LAcq
        self.JSON["timings"]["Fech"] = self.Fech
        self.JSON["timings"]["number_lines"] = self.number_lines
        print "NAcq = "+str(self.Nacq)
        if self.Nacq > 499999:
            raise NameError('Acquisition length over 500.000 points (8Mb = Flash limit)')
        return self.Nacq, self.LAcq, self.Fech, self.number_lines

    def set_multi_lines(self, Bool):
        """
        Determines if this is a single-line of multi-line acquisition.
        """
        if Bool:
            print "Remember to indicate how many lines"
            self.write_fpga(0xEB, 1) # Doing one line if 0, several if 1
            self.Nacq = 0
        else:
            print "Doing a single line"
            self.write_fpga(0xEB, 0) # Doing one line if 0, several if 1
            self.Nacq = 1

    def set_tgc_curve(self, tgc_values):
        """
        Sets up the TGC using an array
        """
        print "Setting up the DAC"
        if len(tgc_values) < 43: # to correct
            for i in range(len(tgc_values)):
                if (tgc_values[i] >= 0) and (tgc_values[i] < 1020):
                    self.write_fpga(16+i, tgc_values[i]/4) # /4 since 1024 values, on 8 bits
                else:
                    self.write_fpga(16+i, 0)

    #----------------
    # FPGA Controls
    #----------------

    def write_fpga(self, adress, value):
        """
        Basic function to write registers value to the FPGA
        """
        self.spi.xfer([0xAA])
        self.spi.xfer([adress])
        self.spi.xfer([value])
        self.JSON["registers"][int(adress)] = value


    def init(self):
        GPIO.setmode(GPIO.BCM)
        PRESET = 23 ## Reset for the FPGA
        IO4 = 26 ## 26 is the output connected to

        GPIO.setup(PRESET, GPIO.OUT)
        GPIO.setup(IO4, GPIO.IN, pull_up_down=GPIO.PUD_DOWN)
        print "Reset GPIO 23 - Low 1s"
        GPIO.output(PRESET, GPIO.LOW)
        time.sleep(3)
        print "Reset GPIO 23 - High 0.2s"
        GPIO.output(PRESET, GPIO.HIGH)
        time.sleep(0.2)
        self.spi.open(0, 0) # CS2 - FPGA, on CE1 = IO4
        self.spi.mode = 0b01
        print "spi.cshigh is " + str(self.spi.cshigh)
        print "spi mode is " + str(self.spi.mode)
        self.spi.max_speed_hz = 2000000
        print "spi maxspeed is "+str(self.spi.max_speed_hz)+"hz"

    #----------------
    # Testing functions
    #----------------

    def test_spi(self, n_cycles):
        """
        Blinks the multi-line LED n_cycles times.
        """
        i = 0
        while i < n_cycles:
            self.write_fpga(0xEB, 0x01) # 0: single mode 1 continious mode
            time.sleep(0.5)
            self.write_fpga(0xEB, 0x00) # 0: single mode 1 continious mode
            time.sleep(0.5)
            i = i+1

    def loop_spi(self):
        """
        Pure debug test to spam SPI bus
        """
        while 1:
            self.write_fpga(0xEB, 0x01) # 0: single mode 1 continious mode
            self.write_fpga(0xEB, 0x00) # 0: single mode 1 continious mode


    def loop_acq(self):
        while 1:
            self.write_fpga(0xEB, 0x00) # Doing 1 shot
            self.write_fpga(0xEF, 0x01) # Cleaning memory pointer
            self.write_fpga(0xEA, 0x0) # Software Trig : As to be clear by software
            time.sleep(0.001) # sleep 1ms


    def ClearMem(self):
        self.write_fpga(0xEF, 0x01) # To access memory

    #----------------
    # Setup functions
    #----------------
    def set_msps(self, F):
        """
        Setting acquisition speed.
        Using F, ADC speed is determined as 64Msps / (1 + F)
        """
        self.write_fpga(0xED, F)
        self.Fech = float(64/((1+F)))
        print "Acquisition frequency set at "+str(self.Fech)+" Msps"
        return self.Fech

    def do_acquisition(self):
        self.write_fpga(0xEF, 0x01) # Cleaning memory pointer
        self.JSON["time"] = unicode(datetime.datetime.now())
        self.write_fpga(0xEA, 0x01) # Software Trig : As to be clear by software
        self.JSON["data"] = []
        milestone = self.Nacq / 5
        start = time.time()
        for i in range(2*self.Nacq+2):
            self.JSON["data"].append (self.spi.xfer([0x00])[0])
            if not (i%milestone):
                print str((50*i)/self.Nacq)+"%"
        end = time.time()
        delta = end - start
        print "Took %.2f seconds to transfer." % delta
        print "for "+str(2*self.Nacq+2)+" transfers of data"
        name_json = self.JSON["experiment"]["id"]+"-"+str(self.JSON["N"])+".json"
        with open(name_json, 'w') as outfile:
            json.dump(self.JSON, outfile)
        print name_json+": file saved."
        return self.JSON["data"]

    def set_acquisition_number_lines(self, n):
        nMSB, nLSB = n/256, 0x00FF&n
        self.write_fpga(0xEE, nLSB)
        self.write_fpga(0xDE, nMSB)
        self.number_lines = n
        print "Number of lines: "+str(n)

    def configSPI(self):
        # Setup FPGA values by default
        self.setPon(200)          # Set PulseOn
        self.setPulsesDelay(100)  # Set Lengh between Pon and Poff: 100ns
        self.setPoff(2000)        # Setting Poff 2us
        #set_tgc_constant(20, spi)   # gain at 20mV (2%)
        self.write_fpga(0xEC, 0x33) # Set DAC constant
        self.setDeltaAcq(7000)    # 7us
        #write_fpga(0xEA, 0x00)     # Software Trig : As to be clear by software
        self.write_fpga(0xEB, 0x00) # 0: single mode 1 continious mode
        self.write_fpga(0xED, 0x03) # Frequency of ADC acquisition / sEEADC_freq (3 = 16Msps, 1 = 32, 0 = 64, 2 = 21Msps)
        self.set_acquisition_number_lines(0xA0)      # How many cycles in countinious mode
        print "Config FPGA done!"

    def set_tgc_constant(self, mV):
        if mV > 1000:
            mV = 1000
        elif mV < 0:
            mV = 0
            hmV = mV/4
        print "Gain:", mV, " mV -- ", hex(hmV)
        self.write_fpga(0xEC, hmV) # Voltage gain control: 0V to 1V


    def setPon(self, POn):
        if POn > 2500:
            POn = 2500
        elif POn < 0:
            POn = 0
        HPon = POn / 10
        self.JSON["parameters"]["Pon"] = int(POn)
        self.JSON["parameters"]["Pon_Real"] = int(HPon)
        print "Pulse width:", POn, " ns -- ", hex(HPon)
        self.write_fpga(0xE0, HPon) # set sEEPon
        return HPon*10

    def setPulsesDelay(self, pulse_on_off_delay_val):
    # Set Lengh between Pon and Poff
        if pulse_on_off_delay_val > 2500:
            pulse_on_off_delay_val = 2500
        elif pulse_on_off_delay_val < 0:
            pulse_on_off_delay_val = 0
        HPP = pulse_on_off_delay_val /10
        #print  hex(HPP)
        self.JSON["parameters"]["PulsesDelay"] = int(pulse_on_off_delay_val)
        self.JSON["parameters"]["PulsesDelay_Real"] = int(HPP)
        print "Pulses delay:", pulse_on_off_delay_val, " ns -- ", hex(HPP)
        self.write_fpga(0xD0, HPP) # set sEEPon
        return HPP*10

    def setPoff(self, poff_value):
        # Sets the damping length.
        POff = poff_value /10
        #print sEEPoff, POff
        POffMSB, POffLSB = 0x00FF&POff/256, 0x00FF&POff
        print "Poff:", poff_value, " ns -- ", hex(POffMSB), hex(POffLSB)
        self.JSON["parameters"]["Poff"] = int(poff_value)
        self.JSON["parameters"]["Poff_Real"] = int(POff)
        self.write_fpga(0xE1, POffMSB) # set sEEPon MSB
        self.write_fpga(0xE2, POffLSB) # set sEEPon LSB
        return POff*10

        # Setting Poff to Acq delay sEEDelayACQ
    def setDeltaAcq(self, acquisition_delay_val):
        if acquisition_delay_val > 255*255:
            acquisition_delay_val = 254*254
        elif acquisition_delay_val < 0:
            acquisition_delay_val = 0

        hDA = int((1.28*acquisition_delay_val)/10)
        hDAMSB, hDALSB = hDA/256, 0x00FF&hDA
        print "Delay between:", hDA*1000/128, "ns -- ", hex(hDAMSB), hex(hDALSB)
        self.JSON["parameters"]["DeltaAcq"] = int(acquisition_delay_val)
        self.JSON["parameters"]["DeltaAcq_Real"] = int(hDA)
        self.write_fpga(0xE3, hDAMSB) # set sEEPon MSB
        self.write_fpga(0xE4, hDALSB) # set sEEPon LSB
        return acquisition_delay_val

    def set_length_acq(self, LAcqI):
        correct_length_acq = int((128*LAcqI)/1000) # (LAcqI*128/1000)
        #print correct_length_acq, hex(LAcq), hex(LAcqI)
        self.JSON["parameters"]["LengthAcq"] = int(LAcqI)
        self.JSON["parameters"]["LengthAcq_Real"] = int(correct_length_acq)
        length_acq_msb, length_acq_lsb = 0x00FF&correct_length_acq/256, 0x00FF&correct_length_acq
        print "Acquisition length: ", int(correct_length_acq*1000/128), "ns -- ", hex(length_acq_msb), hex(length_acq_lsb)
        self.write_fpga(0xE5, length_acq_msb) # set sEEPon MSB
        self.write_fpga(0xE6, length_acq_lsb) # set sEEPon LSB
        return int(correct_length_acq*1000/128)

    def set_period_between_acqs(self, lEPeriod):
        repeat_length_arg = lEPeriod/10 #ns
        repeat_length_msb = 0x00FF&repeat_length_arg/(256*256)
        repeat_length = 0x00FF&repeat_length_arg/256
        repeat_length_lsb = 0x0000FF&repeat_length_arg
        print "Period between two acquisitions:", repeat_length_arg, "us --", hex(repeat_length_msb), hex(repeat_length), hex(repeat_length_lsb)
        self.JSON["parameters"]["PeriodAcq"] = int(lEPeriod)
        self.JSON["parameters"]["PeriodAcq_Real"] = int(repeat_length_arg)
        self.write_fpga(0xE7, repeat_length_msb) # Period of one cycle MSB
        self.write_fpga(0xE8, repeat_length) # Period of one cycle 15 to 8
        self.write_fpga(0xE9, repeat_length_lsb) # Period of one cycle LSB
        return repeat_length_arg*10

    def set_pulse_train(self, Pon, Pdelay, Poff, DelayAcq, Acq):
        RPon = self.setPon(Pon)
        RPD = self.setPulsesDelay(RPon+Pdelay)
        RPOff = self.setPoff(Poff+RPD) #@unused
        RDAcq = self.setDeltaAcq(DelayAcq) #@unused
        LenAcq = self.set_length_acq(Acq)
        print "set_pulse_train Lacq "+str(LenAcq)
        return LenAcq


##############
#
# Processing Part
#
##############

def metadatag_images_batch(Modules, Experiment, Category, Description):
    """
        Used to add proper tags to all images. Dangerous to use...
    """
    Imgs = []
    for dirpath, dirnames, filenames in os.walk("."):
        for filename in [f for f in filenames if (f.endswith(".jpg") or f.endswith(".png"))]:
            Imgs.append(os.path.join(dirpath, filename))

    for file_name in Imgs:
        edit = 0

        metadata = pyexiv2.ImageMetadata(file_name)
        try:
            metadata.read()
        except IOError:
            print "Not an image"
        else:
            # Modules
            metadata['Exif.Image.Software'] = Modules # "matty, cletus"
            metadata['Exif.Image.Make'] = Experiment #"20180516a"
            metadata['Exif.Photo.MakerNote'] = Category #"oscilloscope"
            metadata['Exif.Image.ImageDescription'] = Description #"Unpacking data"
            metadata.write()

        print file_name, "done"

def tag_image(file_name, Modules, Experiment, Category, Description):

    metadata = pyexiv2.ImageMetadata(file_name)
    try:
        metadata.read()
    except IOError:
        print "Not an image"
    else:
        metadata['Exif.Image.Software'] = Modules # "matty, cletus"
        metadata['Exif.Image.Make'] = Experiment #"20180516a"
        metadata['Exif.Photo.MakerNote'] = Category #"oscilloscope"
        metadata['Exif.Image.ImageDescription'] = Description #"Unpacking data"
        metadata.write()
    return 1

class us_json:
    """
        Class used to process data once acquired.
    """
    metatags = {}

    IDLine = []
    TT1 = []
    TT2 = []
    tmp = []
    tdac = []
    FFT_x = []
    FFT_y = []
    EnvHil = []
    Duration = 0
    filtered_fft = []
    LengthT = 0
    Nacq = 0
    Raw = []
    Signal = []
    filtered_signal = []
    Registers = {}
    t = []
    fPiezo = 3.5
    f = 0 # sampling freq

    experiment = ""
    len_acq = 0
    len_line = 0
    N = 0
    V = 0
    single = 0
    processed = False
    iD = 0
    TwoDArray = []

    metatags["firmware_md5"] = ""

    def JSONprocessing(self, path):
        """
            Creates actual raw data from the signals acquired.
        """
        IDLine = []
        TT1 = []
        TT2 = []
        tmp = []
        tdac = []
        with open(path) as json_data:
            DATA = {}
            d = json.load(json_data)
            json_data.close()

            self.description = d["experiment"]["description"]
            self.piezo = d["experiment"]["probe"]
            self.metatags["time"] = d["time"]
            self.metatags["original_json"] = d

            A = d["data"]
            #print d.keys()
            for i in range(len(A)/2-1):
                if (A[2*i+1]) < 128:
                #print "first"
                    value = 128*(A[2*i+0]&0b0000111) + A[2*i+1] - 512
                    IDLine.append(((A[2*i+0]&0b11110000)/16  -8) /2) # Identify the # of the line
                    TT1.append((A[2*i+0] & 0b00001000) / 0b1000)
                    TT2.append((A[2*i+0] & 0b00010000) / 0b10000)
                    tmp.append(2.0*value/512.0)
                else:
                #print "second"
                    value = 128*(A[2*i+1]&0b111) + A[2*i+2] - 512
                    IDLine.append(((A[2*i+1]&0b11110000)/16 -8) /2) # Identify the # of the line
                    TT1.append((A[2*i+1] & 0b00001000) / 0b1000)
                    TT2.append((A[2*i+1] & 0b00010000) / 0b10000)
                    tmp.append(2.0*value/512.0)
            print "Data acquired"
            self.Registers = d["registers"]
            self.timings = d["timings"]
            self.f = float(64/((1.0+int(d["registers"]["237"]))))

            t = [1.0*x/self.f + self.timings['t4']  for x in range(len(tmp))]
            self.t = t

            for i in range(len(IDLine)):
                if IDLine[i] < 0:
                    IDLine[i] = 0
            self.LengthT = len(t)

            #self.EnvHil = self.filtered_signal
            #self.EnvHil = np.asarray(np.abs(signal.rrt(self.filtered_signal)))

            self.TT1 = TT1
            self.TT2 = TT2
            self.Nacq = d["timings"]["number_lines"]
            self.len_acq = len(self.t)
            self.len_line = self.len_acq#/self.Nacq


            # Precising the DAC
            REG = [int(x) for x in d["registers"].keys() if int(x) < 100]
            REG.sort()
            dac = []
            for k in REG:
                dac.append(d["registers"][str(k)])
            # Building the DAC timeline
            tdac = []
            for pts in t[0:self.len_line]: # @todo -> corriger pour avoir une ligne de 200us
                i = int(pts/5.0) # time in us
        try:
            tdac.append(4.0*d["registers"][str(i+16)])
        except:
            tdac.append(-1)

            # Updating the JSON
            self.tdac = tdac
            self.tmp = tmp
            self.single = d["registers"][str(0XEB)]
            self.t = t
            self.IDLine = IDLine
            self.metatags["firmware_md5"] = d['firmware_md5']
            self.experiment = d['experiment']
            self.parameters = d['parameters']
            self.iD = d['experiment']["id"]
            self.N = d['N']
            self.V = d['V']
            self.processed = True


    def create_fft(self):
        self.FFT_x = [X*self.f / (self.LengthT) for X in range(self.LengthT)]
        self.FFT_y = np.fft.fft(self.tmp)
        self.filtered_fft = np.fft.fft(self.tmp)

        for k in range(self.LengthT/2 + 1):
            if k < (self.LengthT * self.fPiezo * 0.5 / self.f):
                self.filtered_fft[k] = 0
                self.filtered_fft[-k] = 0
            if k > (self.LengthT * self.fPiezo *1.5 / self.f):
                self.filtered_fft[k] = 0
                self.filtered_fft[-k] = 0

        self.filtered_signal = np.real(np.fft.ifft(self.filtered_fft))

        if self.processed:
            plt.figure(figsize=(15, 5))

            plot_time = self.FFT_x[1:self.LengthT/2]
            plot_abs_fft = np.abs(self.FFT_y[1:self.LengthT/2])
            plot_filtered_fft = np.abs(self.filtered_fft[1:self.LengthT/2])

            plt.plot(plot_time, plot_abs_fft, 'b-')
            plt.plot(plot_time, plot_filtered_fft, 'y-')

            plt.title("FFT of "+self.iD + " - acq. #: "+ str(self.N))
            plt.xlabel('Freq (MHz)')
            plt.tight_layout()
            file_name = "images/"+self.iD+"-"+str(self.N)+"-fft.jpg"
            plt.savefig(file_name)
            plt.show()
            description_experiment = "FFT of the of "+self.iD
            description_experiment += " experiment. "+self.experiment["description"]
            self.tag_image("matty, cletus", self.iD, "FFT", description_experiment)



    def mkImg(self):
        if self.processed:
            fig, ax1 = plt.subplots(figsize=(20, 10))
            ax2 = ax1.twinx()
            ax2.plot(self.t[0:self.len_line], self.tdac[0:self.len_line], 'g-')
            ax1.plot(self.t[0:self.len_line], self.tmp[0:self.len_line], 'b-')
            plt.title(self.iD + " - acq. #: "+ str(self.N))
            ax1.set_xlabel('Time (us)')
            ax1.set_ylabel('Signal from ADC (V)', color='b')
            ax2.set_ylabel('DAC output in mV (range 0 to 1V)', color='g')
            plt.tight_layout()
            file_name = "images/"+self.iD+"-"+str(self.N)+".jpg"
            plt.savefig(file_name)
            plt.show()
            #self.tag_image("matty, cletus", self.iD, "graph", "Graph of "+self.iD +" experiment. "+self.experiment["description"])

    def tag_image(self, Module, ID, Type, Description):
        ## Updating Metadata
        file_name = "images/"+self.iD+"-"+str(self.N)+".jpg"
        metadata = pyexiv2.ImageMetadata(file_name)
        try:
            metadata.read()
        except IOError:
            print "Not an image"
        else:
            metadata['Exif.Image.Software'] = Module
            metadata['Exif.Image.Make'] = ID
            metadata['Exif.Photo.MakerNote'] = Type
            metadata['Exif.Image.ImageDescription'] = Description
            metadata.write()

    def mk2DArray(self):
        L = len(self.tmp)
        img = []
        tmpline = []
        lineindex = 0
        for k in range(L):
            if self.IDLine[k] <> lineindex:
                img.append(tmpline)
                lineindex = self.IDLine[k]
                tmpline = []
            else:
                tmpline.append(self.tmp[k])


        self.Duration = (self.parameters['LengthAcq']-self.parameters['DeltaAcq'])/1000.0
        SelfDuration = int(float(self.f)*self.Duration)
        y = [s for s in img if (len(s) > SelfDuration-10 and len(s) < SelfDuration+10)]

        CleanImage = np.zeros((len(y), len(self.tmp)/len(y)))
        for i in range(len(y)):
            CleanImage[i][0:len(y[i])] = y[i]

        imSize = np.shape(CleanImage)
        #str(float(self.f)*Duration)
        Duration = (self.parameters['LengthAcq']-self.parameters['DeltaAcq'])/1000.0

        CleanImage = CleanImage[:, :int(Duration*self.f)]
        plt.figure(figsize = (15, 10))
        im = plt.imshow(np.sqrt(np.abs(CleanImage)), cmap='gray', aspect=0.5*(imSize[1]/imSize[0]), interpolation='nearest')


        plt.title(self.create_title_text())
        #plt.colorbar(im, orientation='vertical')
        plt.tight_layout()
        file_name = "images/2DArray_"+self.iD+"-"+str(self.N)+".jpg"
        plt.savefig(file_name)
        tag_image(file_name, "matty, "+self.piezo, self.iD, "BC", self.create_title_text().replace("\n", ". "))
        plt.show()
        self.TwoDArray = CleanImage
        return CleanImage

    def SaveNPZ(self):
        path_npz = "data/"+self.iD+"-"+str(self.N)+".npz"
        np.savez(path_npz, self)
        #print "Saved at "+NPZPath

    def plot_detail(self, NbLine, Start, Stop): #@todo: use it when processing data

        TLine = self.len_line/self.f
        Offset = NbLine*self.len_line

        plot_time_series = self.t[Offset+int(Start/self.f):Offset+int(Stop*self.f)]
        plot_signal = self.tmp[Offset+int(Start/self.f):int(Stop*self.f)]
        plot_enveloppe = self.EnvHil[Offset+int(Start/self.f):int(Stop*self.f)]

        plot_title = "Detail of "+self.iD + " - acq. #: "+ str(self.N)+", between "
        plot_title += str(Start)+" and "+str(Stop)+" (line #"+str(NbLine)+")."

        plt.figure(figsize=(15, 5))
        plt.plot(plot_time_series, plot_signal, 'b-')
        plt.plot(plot_time_series, plot_enveloppe, 'y-')
        plt.title(plot_title)
        plt.xlabel('Time in us')
        plt.tight_layout()

        file_name = "images/detail_"+self.iD+"-"+str(self.N)+"-"
        file_name += str(Start)+"-"+str(Stop)+"-line"+str(NbLine)+".jpg"
        plt.savefig(file_name)

        plt.show()

    def mkFiltered(self, original_image):
        Filtered = []
        fft_image_filtered = []
        if len(img):
            N, L = np.shape(original_image)
            FFT_x = [X*self.f / (L) for X in range(L)]
            for k in range(N):
                fft_single_line = np.fft.fft(original_image[k])
                fft_image_filtered.append(fft_single_line)
                for p in range(len(fft_single_line)/2+1):
                    f_min = (1000 * self.fPiezo * 0.7)
                    f_max = (1000 * self.fPiezo * 1.27)

                    if (FFT_x[p] > f_max or FFT_x[p] < f_min):
                        fft_single_line[p] = 0
                        fft_single_line[-p] = 0
                Filtered.append(np.real(np.fft.ifft(fft_single_line)))
        return Filtered, fft_image_filtered

    def mkSpectrum(self, img):
        Spectrum = []
        #Filtered = [] #@unused
        if len(img):
            N, L = np.shape(img)
            self.FFT_x = [X*self.f / (L) for X in range(L)] #@usuned, why?
            for k in range(N):
                fft_single_line = np.fft.fft(img[k])
                Spectrum.append(fft_single_line[0:L/2])

            plt.figure(figsize = (15, 10))
            plt.imshow(np.sqrt(np.abs(Spectrum)), extent=[0, 1000.0*self.f/2, N, 0], cmap='hsv', aspect=30.0, interpolation='nearest')

            plt.axvline(x=(1000 * self.fPiezo * 1.27), linewidth=4, color='b')
            plt.axvline(x=(1000 * self.fPiezo * 0.7), linewidth=4, color='b')

            plt.xlabel("Frequency (kHz)")
            plt.ylabel("Lines #")
     
            plt.title(self.create_title_text())
            plt.tight_layout()

            file_name = "images/Spectrum_"+self.iD+"-"+str(self.N)+".jpg"
            plt.savefig(file_name)
            tag_image(file_name, "matty,"+self.piezo, self.iD, "FFT", self.create_title_text().replace("\n", ". "))
        else:
            print "2D Array not created yet"

        return np.abs(Spectrum)

    def create_title_text(self):
        title_text = "Experiment: " +self.iD+"-"+str(self.N)+"\nDuration: "+str(self.Duration)
        title_text += "us ("+str(self.parameters['LengthAcq'])+" - "
        title_text += str(self.parameters['DeltaAcq'])+"), for "+str(self.Nacq)
        title_text += " repeats "
        title_text += "each "+str(self.parameters['PeriodAcq_Real']/128)+" us\n"
        title_text += "Fech = "+str(self.f)+"Msps, total of "+str(float(self.f)*self.Duration)
        title_text += " pts per line, Nacq = "+str(self.Nacq)+"\n"
        title_text += self.experiment["description"]+", probe: "
        title_text += self.piezo+", target = "+self.experiment["target"]+"\n"
        title_text += "Timestamp = "+str(self.metatags["time"])
        return title_text

##############
#
# Main
#
##############

if __name__ == "__main__":
    print "Loaded!"

    if len(sys.argv) > 1:
        if "test" in sys.argv[1]:
            un0rick = us_spi()
            un0rick.init()
            un0rick.test_spi(3)
        if "single" in sys.argv[1]:
            un0rick = us_spi()
            un0rick.init()
            un0rick.test_spi(3)
            Curve = un0rick.create_tgc_curve(0, 1000, True)[0]    # Start, Stop, Linear (if False, expo)
            un0rick.set_tgc_curve(Curve)
            un0rick.JSON["N"] = 1 				  # Experiment ID
            un0rick.set_multi_lines(True)                         # Multi lines acquisition
            un0rick.set_acquisition_number_lines(2)             # Setting the number of lines
            un0rick.set_msps(3)                                  # Acquisition Freq
            A = un0rick.set_timings(200, 100, 2000, 5000, 200000)# Settings the series of pulses
            un0rick.JSON["data"] = un0rick.do_acquisition()

        if "loop" in sys.argv[1]:
            un0rick = us_spi()
            un0rick.init()
            un0rick.set_multi_lines(True)                         # Multi lines acquisition
            un0rick.set_acquisition_number_lines(2)		  # Setting the number of lines
            un0rick.set_msps(3)                                  # Acquisition Freq
            A = un0rick.set_timings(200, 100, 2000, 5000, 200000)
            while True:
                un0rick.write_fpga(0xEA, 0x01) # trigs
                time.sleep(50.0 / 1000.0)
