# Security Constrained Unit Commitment Implementing User Cuts

This repository contains the information to simulate an security constrained unit commitment with "User Cuts" implementation in order to reduce the computational burden.

- [Description](#description)
- [Contact](#contact)
- [Files](#files)
- [Citation](#citation)
- [Clarification](#clarification)
- [License](#license)

## Description

Power system operators must schedule the available generation resources required to achieve an economical, reliable, and secure energy production in power systems. This is usually achieved by solving a security-constrained unit commitment (SCUC) problem. Through a SCUC the System Operator determines which generation units must be on and off-line over a time horizon of typically 24 h. The SCUC is a challenging problem that features high computational cost due to the amount and nature of the variables involved. This paper presents an alternative formulation to the SCUC problem aimed at reducing its computational cost using sensitivity factors and user cuts. Power Transfer Distribution Factors (PTDF) and Line Outage Distribution Factors (LODF) sensitivity factors allow a fast computation of power flows (in normal operative conditions and under contingencies), while the implementation of user cuts reduces computational burden by considering only biding N-1 security constraints. Several tests were performed with the IEEE RTS-96 power system showing the applicability and effectiveness of the proposed modelling approach. It was found that the use of Linear Sensitivity Factors (LSF) together with user cuts as proposed in this paper, reduces the computation time of the SCUC problem up to 97% when compared with its classical formulation. Furthermore, the proposed modelling allows a straightforward identification of the most critical lines in terms of the overloads they produce in other elements after an outage, and the number of times they are overloaded by a fault. Such information is valuable to system planners when deciding future network expansion projects.

## Contact 

Cristian Camilo Marín-Cano, Universidad de Antioquia, cristian1013@gmail.com   
Juan Esteban Sierra-Aguilar, Universidad de Antioquia, juane.sierra@udea.edu.co   
Jesús M. López-Lezama, Universidad de Antioquia, jmaria.lopez@udea.edu.co   
Álvaro Jaramillo-Duque, Universidad de Antioquia, alvaro.jaramillod@udea.edu.co   
Walter Mauricio Villa-Acevedo, Universidad de Antioquia, walter.villa@udea.edu.co   

## Files

file.gms is the main file  
inputdata.gms read the input data  
makeDF.py Python function to read system data from excel, compute PTDF adn LODF, then export the data as .inc
pyexcel2inc Python utility to convert data from excel to GAMS .inc format  
Any.inc file(s) with input data for this model  

## Citation

If you use this material, please refer to:

[C. C. Marín-Cano, J. E. Sierra-Aguilar, J. M. López-Lezama,  Jaramillo-Duque, andW. M. Villa-Acevedo, “Implementation of user cuts and linear sensitivity factors to im-prove the computational performance of the security-constrained unit commitment pro-blem,”Energies, vol. 12, no. 7, 2019.](https://www.mdpi.com/1996-1073/12/7/1399)

## Clarification

The input data and original model files were taken form: [The REAL Lab](https://labs.ece.uw.edu/real/gams_code.html)

This metodology is inspirted in the work of [D. A. Tejada.](http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=7886335&isnumber=8231802)

H. Pandzic, Y. Dvorkin, T. Qiu, Y. Wang, and D. Kirschen, Unit Commitment under Uncertainty - GAMS Models, Library of the Renewable Energy Analysis Lab (REAL), University of Washington, Seattle, USA. [Online]. Available at: http://www.ee.washington.edu/research/real/gams_code.html.

[D. A. Tejada-Arango, P. Sánchez-Martın and A. Ramos, "Security Constrained Unit Commitment Using Line Outage Distribution Factors," in IEEE Transactions on Power Systems, vol. 33, no. 1, pp. 329-337, Jan. 2018.
doi: 10.1109/TPWRS.2017.2686701](http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=7886335&isnumber=8231802)

## License

This code is provided under a BSD license as part of DEMIERI project.

[License file](../master/LICENSE)

## Gratefulness

[Colciencias](https://colciencias.gov.co)  

![alt tag](https://www.colciencias.gov.co/sites/default/files/logo_colciencias_png.png)

![alt tag](https://github.com/IceMerman/TransformerSoltion/blob/master/logoUDEA.png)

![alt tag](https://github.com/IceMerman/TransformerSoltion/blob/master/gimel.png)
