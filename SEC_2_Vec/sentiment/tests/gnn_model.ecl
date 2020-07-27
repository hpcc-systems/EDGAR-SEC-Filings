IMPORT PYTHON3 AS Python;
IMPORT ML_Core;
IMPORT * FROM Python;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT * FROM sentiment.tests;
IMPORT * FROM GNN;

nf := ML_Core.Types.NumericField;
df := ML_Core.Types.DiscreteField;
t_tens := Tensor.R4.t_Tensor;

mod_form :=  ['Dense(64, input_shape=(100,))',
//[//'GRU(units=32,dropout=0.2,recurrent_dropout=0.2)',
            'Dense(32)',
             'Dense(1,activation="sigmoid")'];

mod_comp := ['loss="binary_crossentropy",optimizer="adam",metrics=["accuracy"]'];

sess_a := GNNI.GetSession();
sess_b := GNNI.DefineModel(sess_a,mod_form,mod_comp[1]);

spdat := sandplblvn;
ff := sent_model.getFields(spdat);
Xn := ff.NUMF;
Yd := ff.DSCF;

Yn := PROJECT(Yd,TRANSFORM(nf,
SELF.wi := LEFT.wi,
SELF.id := LEFT.id,
SELF.number := LEFT.number,
SELF.value := (REAL8) LEFT.value));

X_tens := Tensor.R4.dat.fromMatrix(Xn);
X := Tensor.R4.MakeTensor([0,100],X_tens);
Y_tens := Tensor.R4.dat.FromMatrix(Yn);
Y := Tensor.R4.MakeTensor([0,1],Y_tens);

mod := GNNI.Fit(sess_b,X,Y);

OUTPUT(GNNI.EvaluateMod(mod,X,Y));