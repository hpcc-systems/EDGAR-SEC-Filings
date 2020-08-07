IMPORT STD;
IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT * FROM SEC_2_Vec.similarity;
IMPORT TextVectors as tv;
IMPORT * FROM tv.internal.svUtils;
IMPORT * FROM Types;

#OPTION('outputLimit',500);

tmod := tv.types.textmod;
tvec := tv.types.t_Vector;

path10k := '~ncf::edgarfilings::raw::all_10k';
path10q := '~ncf::edgarfilings::raw::all_10q';

svl := secvec_input_lbl(path10q,path10k,TRUE,'plain');
dat := sent_model.trndata_wlbl(svl);

pl_vn := dat.s[1];
pl_tf := dat.s[2];

pvsl := simlabs(pl_vn);
ptsl := simlabs(pl_tf);
pvslm:= simlabs(pl_vn,'multiply');
ptslm:= simlabs(pl_tf,'multiply');

pvsl_sal := pvsl.sim_and_labels;
ptsl_sal := ptsl.sim_and_labels;
pvslm_sal := pvslm.sim_and_labels;
ptslm_sal := ptslm.sim_and_labels;

OUTPUT(pvsl_sal);
OUTPUT(ptsl_sal);
OUTPUT(pvslm_sal);
OUTPUT(ptslm_sal);