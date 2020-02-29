# Single species occupancy simulation

In this simulation, we demonstrate the effect of introducing "known absences" (sites where a species cannot be present) into an occupancy model. Specifically, we show that including such known absences can lead to incorrect inferences about changes in occupancy at sites where the species was detected at least once.
We simulate detections for a single species across some number of visits (specified by `nvisit`) at some number of sites (specified by `nsite`) across 2 eras. Each era may differ in detectability (respectively, detectabilities are `p.1` and `p.2`).
One can see the effect of adding known absences by changing the parameter `nsite.foreign` from 0 to a non-zero value and also by varying `p.1` and `p.2`.
For example, the estimated mean change in occupancy at occupied sites will resemble the raw data, even when both eras have the same occupancy probability, when the number of 'known absences' increases. In other words, the known absences cause the occupancy model to stop accounting for differneces in detectability. 
