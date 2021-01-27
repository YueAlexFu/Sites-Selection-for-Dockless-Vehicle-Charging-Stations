FILENAME REFFILE '/home/zw3990/AlexFu/opr624/vehicles_center2.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.vehicle_center;
	GETNAMES=YES;
RUN;


data vehicle_center1; set vehicle_center;
ID = _n_;
run;

data range_point; set Range;
IDrange = _n_;
run;

proc optmodel;
/* read in vehicle data */
set<number> vehicle;
num EndLatitude{vehicle};
num EndLongitude{vehicle};
read data vehicle_center1 into vehicle=[ID] EndLatitude EndLongitude;


num numStation = 3;
num numVehicle = 8;

set stat = {1..numStation};
set vehi = {1..numVehicle};

/* weight 9*#vehicle */
var W{stat, vehi} binary;

/* longitude of station range from 8000 vehicles*/
var X{1..3} >= -85.842 <= -85.569;
/* latitude of station*/
var Y{1..3} >= 38.103 <= 38.371;


minimize TotalDistance = sum{i in stat, j in vehi}
	(W[i, j]*(EndLatitude[j] - Y[i])^2 + W[i, j]*(EndLongitude[j] - X[i])^2);
/* 	W[i, j]*(abs(EndLatitude[j] - Y[i]) + abs(EndLongitude[j] - X[i])); */
	
/* constraint */
con assign{j in vehi}: sum{i in stat}W[i, j] = 1; 
con total: sum{j in vehi, i in stat}W[i,j] = numVehicle;
/* con rangex{i in stat}:  Xmin[i] <= X[i] <= Xmax[i]; */
/* con rangey{i in stat}:  Ymin[i] <= Y[i] <= Ymax[i]; */

solve with lso / maxtime=5000 nthreads=4 primalin;
print TotalDistance X Y W;
