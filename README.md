# Single species occupancy simulation

In this simple simulation we show the effect of introducing "known absences" that are then modelled by an occupancy model. 

Here we simulate a single species that is present in 50 sites `nsite` and it is sampled in 3 visits `nvisit` across 2 eras. 
Each era differs in detectability `p.1` and `p.2`, where the first era has a lower detectability than the second era (0.3 and 0.5 respectively).

To see the effect of adding known absences, change the parameter `nsite.foreign` to 500 or to 0.

See the estimated mean change in occupancy at occupied sites. Even when both eras have the same occupancy, the addition of 500 'known absence' sites will introduce an spurious decline in mean occupancy between eras. 


