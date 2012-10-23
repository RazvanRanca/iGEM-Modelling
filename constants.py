import math
import sys

c = 299792458.0 # m/s
massElectron = 0.510998928 # Mev/c^2

kineticEnergy1 =  51000.0 # Mev for Stanford
kineticEnergy2 =  0.0000001 #Mev

def velocity(ke):
  p = math.sqrt(1 - ( massElectron/(ke + massElectron) )**2)
  return (p, c*p)

couloumb = 6.24150965E18 # electrons

time = 1.0E-3 # seconds
e1 = 37000.0 # electrons moved
e2 = 126000.0 # electrons moved

def current(e): # microAmperi
  return ((e/couloumb)/time) * 1.0E6

# Molecule Count = Concentration(Mols) * Avogadro * Volume
ecoliVolume = 0.6E-15 # l
avogadro = 6.022E23 # mol^(-1)
ironDensity = 5.242E-3 # grams / liter


flavinConc = 3E-6 # M 

def flavinCount(conc):
  return int(conc * avogadro * cellOutsideVolume)

ironLen1 = 2.5E-5 # decimeters
ironLen2 = 1.3E-8 
ironConc1 = 2.5 #grams/liter
ironConc2 = 0.25 #grams/liter
totalEcoliCells = 1.6E10 # given OD600 of 1.0 and 20ml culture
totalOutsideVolume = 20.0E-3 # l
cellOutsideVolume = (totalOutsideVolume - (totalEcoliCells * ecoliVolume) ) / totalEcoliCells

def ironCount(conc, length):
  ironVolume = 3.14159 * 4 * length**3 / 3 # decimeter^3 = liter
  return int((conc * cellOutsideVolume) / (ironVolume * ironDensity))

#print flavinCount(flavinConc)
#print ironCount(ironConc1, ironLen1), ironCount(ironConc2, ironLen2)
#print current(e1)
#print flavinCount(float(sys.argv[1]) * 1.0E-6)

periplasmThickness = 2.5E-8 # 25 nm

def solubleIronCount():
  noEcoliCells = 2.0E10 # given OD600 of 0.5 and 50ml culture
  solubleIronAmm = 1.0E-2 * avogadro # 10 mM
  totalCellVolume = noEcoliCells * ecoliVolume
  periplasmVol = (0.1 * totalCellVolume ) / 50.0E-3 # periplasm volume is ~10% of total cell volume
  solubleIronPerCell = (solubleIronAmm * periplasmVol) / noEcoliCells
  return solubleIronPerCell
  


def ironReduced():
  solVolume = 50 # 50 ml
  cellCount = 8.0E8 # OD600 of 1.0
  reducedPerCFU = 27.0E-6 # microM/cfu mL-1
  days = 24
  return reducedPerCFU * cellCount / (solVolume * days)
  
print ironReduced()
print ironReduced