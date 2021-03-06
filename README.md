**The bellow deals with the *how* of the modelling, for the results please see our analysis page on the main iGem wiki: http://2012.igem.org/Team:Edinburgh/Modelling/Kappa/Analysis and 
http://2012.igem.org/Team:Edinburgh/Modelling/Kappa/Analysis-All**

Overview of modelling
------------
EdiGEM12 is the team from Edinburgh University taking part in the synthetic biology competition iGEM 2012. Part of EdiGEM's project is to implement the MtrCAB electron transfer system from *Shewanella* oneidensis in *E. coli*.

We model the electron transfer system in *E.coli* by using the stochastic, agent-based language Kappa and its implementation KaSim 3.0 (*). The whole process is divided into sub-processes which we try to model separately at first and combine at the end. The sub-processes can roughly be described in the following way:

1_TCA.ka
// Glucose -> TCA cycle -> Quinol

2_NapC.ka
// Quinol -> NapC 

3_MtrABC.ka
// NapC -> MtrA-> MtrB or Fe soluble

4_UFe.ka
// MtrC -> Flavins -> Fe insoluble

5.ka
// Combines 3. and 4.

The file "Electron Transfer - Process Description.pdf" contains a detailed description of the used information and assumptions in the modelling.


(*) More about Kappa and rule-based modelling can be found at http://kappalanguage.org/.

------------------


Following is a detailed description of the modelling process, including justifications for the ammounts of agents and the rates we used.
This same information is also available in the **"Electron Transfer - Process Description.pdf"** file included in the repository


Modelling the Electron Transfer in E.Coli Using Kappa 
=============

1_TCA.ka:
--
Glucose -> TCA cycle -> QH2 

**Agents and Tokens**

%token: Glucose %agent: TCA(glucose~0~1) 

%token: NADH %agent: ComplexI(FMN~0~H) 

%token: succinate %agent: ComplexII(FAD~0~H) 

%token: Quinol 

 

There is a linear relation between the amount of glucose and the amount of Acyl-CoA in the cell except when the amount of glucose is less than 0.5 mM or more than 5.5 mM. Acyl-CoA has a default minimal amount of 0.14mM and cannot go over 0.4mM. (Yoshichika Takamura, 1988) Since Acyl-CoA is mainly used in the TCA cycle, we assume linear relation between the amount of glucose and the number of ‘running’ TCA cycles. We estimate the amount of running TCA cycle by dividing the amount of Acyl-CoA in the cell (each TCA cycle needs two molecules of Acyl-CoA per molecule of glucose). The above relation between the glucose and the number of TCA cycles is expressed as perturbation rules in the kappa file. 

The token Quinol refers to coenzyme Q10 (aka ubiquinone). 

**Rules** 

'TCA consumes Glucose' 

'TCA produces NADH and succinate' 

'Complex I consumes NADH' 

'Complex I produces QH2' 

'Complex II consumes succinate' 

'Complex II produces QH2' 

The products from the TCA cycle per molecule of glucose are 6xNADH and 2xFADH (Citric acid cycle: Products, 2012). The main unit used in the model is μM. Thus, we do not get ‘huge numbers’ for the amount of tokens, such as Glucose, or values less than one for the number of agents, such as the TCA(). 

NADH binds to Complex I via FMN which takes the electrons from NADH. The electrons are then passed to a series of iron-sulphur clusters which we ignore in the model. The electrons leave Complex I and are taken by the ubiquinone. (Oxidative phosphorylation: NADH-coenzyme Q oxidoreductase (complex I), 2012) 

Succinate in the TCA cycle 'binds' to FAD in Complex II. Then Complex II reduces the quinol. (Oxidative phosphorylation: Succinate-Q oxidoreductase (complex II), 2012) 

In order to determine the rates of electron transfer between different agents in this kappa sub-model, we use the following oxidation-reduction potentials: http://hyperphysics.phy-astr.gsu.edu/hbase/chemical/redoxp.html 

Here are the oxidation-reduction potentials that are of interest to us: 

Half reaction Half reaction E'0(V) 

Succinate + CO2 + 2H+ +2e- О±-ketoglutarate + H2O -0.670 

NAD+ + 2H+ +2e- NADH + H+ -0.320 

Ubiquinone + 2H+ +2e- ubiquinol +0.045 

FAD + 2H+ +2e- FADH2 +0.031 

There is still little information on the electron transfer system in E.Coli involving NapC. This is why we assume the relations between the different rates in the model are the same as the corresponding relations between the oxidation-reduction potentials above. 

'Complex I in' is the rate at which NADH gives electrons to Complex 1. We assume 'Complex I in' is equal to 1E-5. 'Complex I out' is the rate at which Ubiquinone takes electrons from Complex I. Given the table above we make 'Complex I out' equal (0.045/0.32)*'Complex I in'. 

Similarly, 'Complex II in' = (0.670/0.320)*'Complex I in' and 'Complex II out' = (0.031/0.320)*'Complex I in' 

**Perturbation Rules** 

The perturbation rules used in this file are used to keep the amounts of glucose, NADH and succinate from going below zero. They also update the number of TCA() agents depending on the amount of glucose. 


2_NapC.ka 
--
Quinol -> NapC 

**Agents and Tokens** 

%token: Quinol 
%agent: NapC(carry~0~2~4) 

 

NapC has 4 hemes. (Heather M. Jensen, Engineering of a synthetic electron conduit in living cells., 2010) 

We model the agent NapC so that it carries 0, 2 or 4 electrons. We assume that the 4 haems it contains act as two tuples (Michael L. CARTRON, 2002). 

**Rules**

'NapC(carry~0) absorbs Quinol' 
'NapC(carry~2) absorbs Quinol' 

 

 “Redox potentiometric analysis indicated that the haems had low midpoint redox potentials (Em,8,0) of -56 mV, -181 mV, -207 mV and -235 mV.” (Michael L. CARTRON, 2002) 

From the above citation, we assume that the ‘redox’ potentials of the two haem tuples of NapC are -118.5 mV (the average of -56 mV and -181 mV) and -221mV(the average of -207 mV and -235 mV), respectively. We also assume that the rate of the rule 'NapC(carry~0) absorbs Quinol' is the -221mV one, because the tuple with higher redox potential will most likely be ‘filled’ with electrons first. 

Assuming, again, that the relations between the different rates in the model are the same as the corresponding relations between the oxidation-reduction potentials above, we fix the following rate for the given rules: 

'NapC(carry~0) absorbs Quinol' ->(0.221/0.32)*(1E-5) 

'NapC(carry~2) absorbs Quinol' ->(0.1185/0.32)*(1E-5) 

Where -0.32V is the redox potential of NADH. 

3_MtrABC.ka 
--
NapC -> MtrA 

MtrA -> Fe soluble 

MtrA -> MtrB 

**Agents:** 

%agent: mtrB(dom) 

%agent: NapC(dom) 

%agent: mtrA(conn, carry~0~1~2~3~4~5~6~7~8~9~10) 

%agent: mtrBCounter() 

%agent: IronCounter() 

%agent: IronPlaceholder() 

 


mtrB is the end point of this model and accepts electrons from MtrA through a single connection site. 

(Katrin Richter, 2012) shows that MtrC stays attached to MtrB. (Heather M. Jensen, Engineering of a synthetic electron conduit in living cells., 2010) shows that there are 75 MtrC so there are 75 MtrBs as well. 

NapC is the start point and provides electrons to mtrA through a single heme. (Heather M. Jensen, Engineering of a synthetic electron conduit in living cells., 2010) suggests that the number of NapCs is significantly lower than that of mtrAs 

MtrA shuttles electrons between NapC and mtrA. On the way it can also encounter soluble iron molecules that accept an electron. Again, (Heather M. Jensen, Engineering of a synthetic electron conduit in living cells., 2010), sets the number of MtrAs at 2100. 

MtrBCounter and IronCounter are agents that just keep track of the number of electrons that have been involved in reactions involving mtrB and soluble Iron, respectively. 

IronPlaceholder is a single agent that acts as a placeholder for all the individual soluble Iron molecules. Its reaction rate is adjusted to take account of this fact. This complication is necessary because there are far too many iron molecules to be modelled individually. 

**Rules:** 

'mtrA connects to NapC' 

'mtrA disconnects from NapC' 

 

'mtrA connects to mtrB' 

'mtrA disconnects from mtrB' 

 

'mtrA donates to SolubleIron' 

 

mtrA can connect through a single heme to either NapC, where it accepts electrons, or to mtrB where it donates them. It can also encounter a soluble Iron particle in which case a single electron is donated to the molecule. 

(Heather M. Jensen, Engineering of a synthetic electron conduit in living cells., 2010) suggests that transfer between NapC and mtrA is the limiting factor in the soluble Iron oxidation rate. Additionally, we are given a change of oxidation rate dependent on the number of mtrAs. Modelling to fit this curve gives us the on and off rates between NapC and mtrA. 

(Jones ME, Apr 2010) shows that in Shewanella soluble oxidation is up to 20 times bigger than insoluble one. (Heather M. Jensen, Engineering of a synthetic electron conduit in living cells., 2010) claims that soluble oxidation in ecoli is ~30 times slower than Shewanella and insoluble is ~10 times slower. Therefore in ecoli the soluble rate should be about 7 times higher than the insoluble one. This fact is used to empirically determine the reaction rates. 

4_UFe.ka 
---
MtrC -> Flavins -> Fe insoluble 

**Agents:** 

%agent: mtrC(dom1, dom2, dom3) 

%agent: Flavin(conn, carry~0~2) 

%agent: InsolubleIron(conn, carry~0~2~10) 

 

MtrC has 3 hemes that interact with other agents in the model. 

As per (Heather M. Jensen, Engineering of a synthetic electron conduit in living cells., 2010), there are 75 MtrC. 

Flavin has 1 connection point to other agents and either carries 0 or 2 electrons at any time(initially they all carry 0). Number of flavins can be varied to observe how the electron transmission rate is affected.As per (Daniel Baron, 2009) The default rate is 0.2 micromoles 

InsolubleIron also has 1 connection point and can accept electrons either from Flavins or from MtrC directly. Initially all InsolubleIron agents carry 0 electrons. The number of InsolubleIron agents can also be varied. Specifically we try the values given by the two different sizes of Iron particles tried in (Heather M. Jensen, Engineering of a synthetic electron conduit in living cells., 2010) 

**Rules:** 

'mtrC connects to Flavin at dom2' 

'mtrC connects to Flavin at dom3' 

 

'mtrC disconnects from Flavin at dom2' 

'mtrC disconnects from Flavin at dom3' 

 

'mtrC connects to free InsolubleIron' 

'mtrC disconnects from InsolubleIron' 

 

'Flavin connects to free InsolubleIron' 

'Flavin with electrons disconnects from InsolubleIron' 

 

The heme structure of mtrC is detailed in (Thomas A. Clarke, 2011). This shows that one of mtrC’s hemes connects to insoluble iron and the others to flavins. The hemes work independently of one another. Both the Flavins and the Iron particles accept electrons from MtrC. Flavin then independently connect to InsolubleIron and pass on the electrons taken from MtrC. 

The relative rates at which the reactions occur can be determined from some experimental results. (Heather M. Jensen, Engineering of a synthetic electron conduit in living cells., 2010) shows that when the amount of iron particles is increased by several orders of magnitude, the rate of electron transfer increases only by 2.5 

However, (Daniel Baron, 2009) shows that addition of Flavin can increase the rate significantly more than that, therefore the amount of electrons reaching mtrC is not the bottleneck. By replicating this result we we’re able to empirically set the on and off rates between mtrC and InsolubleIron. 

Furthermore, (Daniel Baron, 2009) also shows that the effect of adding Flavins isn’t linear either. Here the bottleneck is likely the small amount of hemes where the Flavins can connect to accept electrons. Replicating the expected behaviour we are also able to determine the on and off rates between Flavin and the other agents. Our result is also corroborated by which predicts that decoupling between flavins and mtrC will be significantly faster than between InsolubleIron and mtrC. 

**Verifications:** 

(Heather M. Jensen, Engineering of a synthetic electron conduit in living cells., 2010) says reduction of InsolubleIron without any Flavins is ~10x slower than in Shewanella. 

The model predicts that 0.2 micromoles of Flavins would be needed to increase the rate 10x. (von Canstein H, Feb 2008) shows that external flavin production in Shewanella is within 0.1 – 0.8 micromoles. Therefore prediction is within the expected range. 

5.ka 
--
NapC -> MtrA 

MtrA -> Fe soluble 

MtrA -> MtrB -> mtrC 

MtrC -> Flavins -> Fe insoluble 

 

This model is just a concatenation of models 4 and 5. Therefore many of the rules and agents are identical to the previous ones. Only the ones that differ in some aspect are detailed upon below. 

**Agents:** 

%agent: NapC(dom, carry~0~2~4) 

%agent: mtrA(conn, carry~0~1~2~3~4~5~6~7~8~9~10) 

%agent: mtrBCounter() 

%agent: SolubleIronCounter() 

%agent: IronPlaceholder() 

%agent: InsolubleIronMtrCounter() 

%agent: InsolubleIronFlavinCounter() 

%agent: mtrBC(domB, domC1, domC2, domC3, carry~0~1~2~…~8~9~10) 

%agent: Flavin(conn, carry~0~1~2) 

%agent: InsolubleIron(dom1, dom2, carry~0~2~10) 

 

NapC can now carry 0, 2 or 4 electrons as per model 2. 

mtrB is now completely modelled, as per (Thomas A. Clarke, 2011), with 10 hemes 4 of which interact with other agents. 

InsolubleIronMtrCounter and InsolubleIronFlavinCounter are added to keep track of the number of electrons passing through the mtrC-InsolubleIron and the Flavin-InsolubleIron reactions respectively. 

All other agents are identical to the ones in models 3 and 4. 

**Rules:** 

'mtrA connects to NapC' 

'mtrA disconnects from NapC' 

 

'mtrA connects to mtrB' 

'mtrA disconnects from mtrB' 

 

'mtrA donates to SolubleIron' 

 

'mtrC connects to Flavin at dom2' 

'mtrC connects to Flavin at dom3' 

 

'mtrC donates to Flavin at dom2' 

'mtrC donates to Flavin at dom3' 

 

'mtrC connects to free InsolubleIron' 

'mtrC disconnects from InsolubleIron' 

 

'Flavin connects to free InsolubleIron' 

'Flavin disconnects from InsolubleIron' 

 

All the rules are the same as in models 4 and 5 

The relative rates are kept in the same proportions, they are just multiplied by a factor such that all the models work on roughly the same timescale and can therefore be linked. 

**Verifications:** 

As expected from (Jones ME, Apr 2010) and (Heather M. Jensen, Engineering of a synthetic electron conduit in living cells., 2010), increasing the amount of NapC makes the behaviour of the system more similar to that of Shewanella and the ratio between soluble and insoluble oxidation rates increases from ~9 to ~20 

Increasing the amount of Flavins by 2 orders of magnitude only increases the oxidation rate by 4-5 times. This is the same behaviour observed in (Dan Coursolle, 2010). 

 

Bibliography:
--
Brutinel ED, G. J. (Jan 2012). Shuttling happens: soluble flavin mediators of extracellular electron 
transfer in Shewanella. Appl Microbiol Biotechnol , 93(1):41-8. Epub 2011 Nov 10. 

Citric acid cycle: Products. (2012). Retrieved August 28, 2012, from Wikipedia: 
http://en.wikipedia.org/wiki/Citric_acid_cycle#Products 

Dan Coursolle, D. B. (2010). The Mtr Respiratory Pathway Is Essential for Reducing Flavins and 
Electrodes in Shewanella oneidensis. Journal of Bacteriology , Vol. 192. 467-474. 

Daniel Baron, E. L. (2009). Electrochemical Measurement of Electron Transfer Kinetics by Shewanella 
oneidensis MR-1. J Biol Chem. , Vol. 284(42). 28865–28873. 

Heather M. Jensen, A. E. (2010). Engineering of a synthetic electron conduit in living cells. PNAS, Vol. 
107 . 

Heather M. Jensen, A. E. (2010). Engineering of a synthetic electron conduit in living cells. Vol. 107 . 

Jones ME, F. C. (Apr 2010). Shewanella oneidensis MR-1 mutants selected for their inability to 
produce soluble organic-Fe(III) complexes are unable to respire Fe(III) as anaerobic electron acceptor. 
Environ Microbiol. , 12(4):938-50. Epub 2010 Jan 18. 

Katrin Richter, M. S. (2012). Dissimilatory Reduction of Extracellular Electron Acceptors in Anaerobic 
Respiration. Applied and Environmental Microbiology , Vol. 78. 913-921. 

Michael L. CARTRON, M. D. (2002). Identification of two domains and distal histidine ligands to the 
four haems. Biochem. Journal , 425-432. 

Oxidative phosphorylation: NADH-coenzyme Q oxidoreductase (complex I). (2012). Retrieved August 
28, 2012, from Wikipedia: http://en.wikipedia.org/wiki/Oxidative_phosphorylation#NADH-
coenzyme_Q_oxidoreductase_.28complex_I.29 

Oxidative phosphorylation: Succinate-Q oxidoreductase (complex II). (2012). Retrieved September 3, 
2012, from Wikipedia: http://en.wikipedia.org/wiki/Oxidative_phosphorylation#Succinate-
Q_oxidoreductase_.28complex_II.29 

Thomas A. Clarke, 1. M. (2011). Structure of a bacterial cell surface decaheme electron conduit. 
PNAS, Vol. 107 , 9384-9389. 

von Canstein H, O. J. (Feb 2008). Secretion of flavins by Shewanella species and their role in 
extracellular electron transfer. Appl Environ Microbiol. , 74(3):615-23. Epub 2007 Dec 7. 

Yoshichika Takamura, G. N. (1988). Changes in the Intracellular Concentration of Acetyl-CoA and 
Malonyl-CoA in Relation to the Carbon and Energy Metabolism of Escherichia coli K12. 134. 
