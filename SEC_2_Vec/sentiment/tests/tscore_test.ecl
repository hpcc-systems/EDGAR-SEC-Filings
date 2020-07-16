secaccrec := RECORD
    STRING sector;
    REAL8 acc;
END;

plain := DATASET(WORKUNIT('W20200711-084827','Result 1'),secaccrec);
sandp := DATASET(WORKUNIT('W20200711-084827','Result 2'),secaccrec);

//we also want to t-test the difference in means
m1 := AVE(plain,acc);
m2 := AVE(sandp,acc);

var1 := VARIANCE(plain,acc);
var2 := VARIANCE(sandp,acc);

c1 := COUNT(plain);
c2 := COUNT(sandp);

diffmean := m1-m2;
stderr := SQRT((var1/c1) + (var2/c2));

tscore := diffmean/stderr;

secdiffs := JOIN(plain,sandp,LEFT.sector = RIGHT.sector,TRANSFORM(secaccrec,SELF.sector := LEFT.sector,SELF.acc := RIGHT.acc-LEFT.acc));


OUTPUT(plain);
OUTPUT(sandp);
OUTPUT(diffmean);
OUTPUT(tscore);
OUTPUT(secdiffs);