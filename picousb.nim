#[
Utilityfor USB write in Nim.
The MIT License (MIT)
Copyright (c) 2022 Martin Andrea (Martinix75)
testet with Nim 2.2.0
author Andrea Martin (Martinix75)
https://github.com/Martinix75/Raspberry_Pico/tree/main/Utils/picoUsb
]#

import picostdlib
from strutils import strip, parseFloat, parseInt
const picousbVer* = "0.5.0"

type
    PicoUsb*  = object 
      setBool: bool
      stringX: string
      readCh: char

#---- private functions -------
proc readLineInternal(self: var PicoUsb, time: uint32 = 100_000) = #proc general reading of a usb string.
    while true: #until you find '\ 255' it run... 
      let readBuffer = getCharTimeoutUs(time) #save the character in the variable  readCh.
      if readBuffer >= 0 and readBuffer != PicoErrorTimeout.int: #if there is a greater number to zero then they are given on the buffer.(ver 0.4.0)
        self.readCh = char(readBuffer) #if it is a greater number of zero, convert to char.
        if self.readCh == '\255':  #if  found '\255'..
          break #interrupt the while!
        else: #If there is not...
          self.stringX.add($self.readCh) #add the character in stringX (string) after converting it.
      else: #the buffer is empty (ver 0.4.0).
        break
        
proc setReady(self: var PicoUsb) = #proc to check if there is anything in the usb buffer. 
    self.readLineInternal() #read using the private procedure readLineInternal.
    if self.stringX.len > 0: #if string stringX is not empty .. 
        self.setBool = true #set setbool = true.
    else: #if string stringX is empty .. 
        self.setBool = false #set setbool = false .

#----- pubblic functions --------
proc isReady*(self: var PicoUsb): bool = #procedure for checking the buffer status. 
    self.setReady() #calls the procedure to set the variable.
    return self.setBool #return the value.
  ## Checking the buffer status (if there are characters).
  ##
  ## ==========
  ## **Returns:** 
  ## true = there are characters, false = there are no characters.
    
proc readLine*(self: var PicoUsb; time: uint32 = 100): string = #proc for read the string in usb 
    readLineInternal(self, time) #read with the private function.
    result = self.stringX #returns the complete string .
    self.stringX = "" #reset variable stringX (= "" empty string).
    self.readCh = '\255' #reset buffer
  ## Read the string in the usb buffer.
  ##
  ## **Parameters**
  ## time = time expected before the timeout (milliseconds).
  ## ==========
  ## 
  ## **Returns** 
  ## string
  
proc toInt*(self: PicoUsb; usbString: string): int = #proc for the conversion from string to INT.
  let stringClear: string  = usbString.strip(chars={'\r', '\n'}) #delete CF and CR
  try:
    result = parseInt(stringClear) #convert string to Int.
  except ValueError:
    print("ERROR!! not INT converted!") #if the conversion fail!
  ## Convert string in to int.
  ##
  ## **Parameters**
  ## usbString = string read in usb.
  ## =========
  ##
  ## **Results:** 
  ## int

proc toFloat*(self:PicoUsb; usbString: string; nround=2): float = #proc for tthe conversion from string to INT.
  let stringClear: string  = usbString.strip(chars={'\r', '\n'}) #delete CF and CR
  try:
    result = parseFloat(stringClear) #convert string to Float
  except ValueError:
    print("ERROR!! not FLOAT converted!")#if the conversion fail!
  ## Convert string in to float.
  ##
  ## **Parameters**
  ## usbString = string read in usb.
  ## =========
  ##
  ## **Results:** 
  ## float

when isMainModule:
  stdioInitAll()
  var serialUsb = PicoUsb()
  sleepMs(2800)
  print("PicoUsb Ver: " & picousbVer)
  
  while true:
    if serialUsb.isReady == true:
      let test = serialUsb.readLine()
      print("Ricevuto --> " & test)
    sleepMs(500)
