#!/bin/bash

module purge
module load gromacs/2024-rpbs

pz_name="1HSI"

gmx editconf -f "${pz_name}_processed.gro" -o "${pz_name}_newbox.gro" -c -d 1.0 -bt cubic 
gmx solvate -cp "${pz_name}_newbox.gro" -cs spc216.gro -o "${pz_name}_solv.gro" -p topol.top 

gmx grompp -f mini1.mdp -c "${pz_name}_solv.gro" -p topol.top -o mini1.tpr 
echo "13" | gmx genion -s mini1.tpr -o "${pz_name}_solv_ions.gro" -p topol.top -pname NA -nname CL -neutral 

gmx grompp -f mini2.mdp -c "${pz_name}_solv_ions.gro" -p topol.top -o mini2.tpr 
gmx mdrun -v -deffnm mini2

gmx grompp -f NVT.mdp -c mini2.gro -r mini2.gro -p topol.top -o NVT.tpr 
gmx mdrun -v -deffnm NVT 

gmx grompp -f NPT.mdp -c NVT.gro -r NVT.gro -t NVT.cpt -p topol.top -o NPT.tpr 
gmx mdrun -v -deffnm NPT

gmx grompp -f md.mdp -c NPT.gro -t NPT.cpt -p topol.top -o md.tpr
gmx mdrun -v -deffnm md

