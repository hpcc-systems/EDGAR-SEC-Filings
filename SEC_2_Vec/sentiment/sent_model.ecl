IMPORT Types as secTypes;
IMPORT * FROM secTypes;
IMPORT ML_Core;
IMPORT * FROM SEC_2_Vec;
IMPORT SEC_2_Vec.sentiment as s;
IMPORT * FROM s;
IMPORT TextVectors as tv;
IMPORT * FROM LogisticRegression;

Sentence := tv.Types.Sentence;
TextMod := tv.Types.TextMod;

EXPORT sent_model := MODULE

    //takes labeled sentences and creates vanilla, tfidf sentence vectors
    //PARAMETERS:
    //
    // rawsents (dataset of type sveclblrec, the labeled sentences without vectors)
    //
    //INITIALIZED DATASETS:
    //
    // trndata_wlbl() (outputs a set containing both the vanilla and tfidf sentence
    // vectors. If the variable 'out' contains the results of this function, out[1]
    // would contain the vanilla vectors and out[2] the tfidf vectors)
    EXPORT trndata_wlbl(DATASET(sveclblrec) rawsents) := FUNCTION

        rawrec := RECORD
            UNSIGNED8 sentId := rawsents.sentId;
            STRING text := rawsents.text;
        END;
        outlblrec := RECORD
            UNSIGNED8 sentId := rawsents.sentId;
            STRING label := rawsents.label;
            STRING fname := rawsents.fname;
        END;

        trainSentences := TABLE(rawsents,rawrec);
        labelSentences := TABLE(rawsents,outlblrec);

        sv := tv.SentenceVectors();
        model := sv.GetModel(trainSentences);

        vanstart := model(typ=2);
        vanrec := RECORD
            UNSIGNED8 sentId := vanstart.id;
            STRING text := vanstart.text;
            tv.Types.t_Vector vec := vanstart.vec;
        END;
        vands := TABLE(vanstart,vanrec);

        smodrec := RECORD
            UNSIGNED8 sentId;
            STRING text;
            tv.Types.t_Vector vec;
        END;

        trainrec lrT(smodrec s,DATASET(outlblrec) r) := TRANSFORM
            SELF.id := s.sentId;
            SELF.text := s.text;
            SELF.vec := s.vec;
            SELF.label := r(sentId = s.sentId)[1].label;
            SELF.fname := r(sentId = s.sentId)[1].fname;
        END;

        vanout := PROJECT(vands,lrT(LEFT,labelSentences));
        tfout  := tfidf(model(typ=1),rawsents,100,1);

        RETURN [vanout,tfout];
    END;
    
    //takes sentence vectors and prepares for ML.
    //PARAMETERS:
    // tr (dataset of type trainrec, the sentence vectors to be used for training)
    //
    //INITIALIZED DATASETS:
    // getFields() (outputs a module containing both the independent and dependent
    // variables, the former as NumericField and the latter as DiscreteField. If
    // the variable 'out' contains the results of this function, out.NUMF would be the
    // independent variables and out.DSCF the dependent variables)
    EXPORT getFields(DATASET(trainrec) tr) := FUNCTION
        vecrec := RECORD
            REAL8 value;
        END;

        fldrec := RECORD
            UNSIGNED rowid;
            DATASET(vecrec) vecds;
            INTEGER4 label;
        END;

        fldrec fldT(trainrec d,INTEGER C) := TRANSFORM
            SELF.rowid := C;
            SELF.vecds := DATASET(d.vec,vecrec);
            SELF.label := (INTEGER4) d.label;
        END;

        vec_as_ds := PROJECT(tr,fldT(LEFT,COUNTER));

        //FIXME: Currently written out explicitly
        //Consider applying MACRO
        nastyrec := RECORD
            UNSIGNED id;REAL8 val1;REAL8 val2;REAL8 val3;REAL8 val4;REAL8 val5;REAL8 val6;REAL8 val7;REAL8 val8;REAL8 val9;REAL8 val10;REAL8 val11;REAL8 val12;REAL8 val13;REAL8 val14;REAL8 val15;REAL8 val16;REAL8 val17;REAL8 val18;REAL8 val19;REAL8 val20;REAL8 val21;REAL8 val22;REAL8 val23;REAL8 val24;REAL8 val25;REAL8 val26;REAL8 val27;REAL8 val28;REAL8 val29;REAL8 val30;REAL8 val31;REAL8 val32;REAL8 val33;REAL8 val34;REAL8 val35;REAL8 val36;REAL8 val37;REAL8 val38;REAL8 val39;REAL8 val40;REAL8 val41;REAL8 val42;REAL8 val43;REAL8 val44;REAL8 val45;REAL8 val46;REAL8 val47;REAL8 val48;REAL8 val49;REAL8 val50;REAL8 val51;REAL8 val52;REAL8 val53;REAL8 val54;REAL8 val55;REAL8 val56;REAL8 val57;REAL8 val58;REAL8 val59;REAL8 val60;REAL8 val61;REAL8 val62;REAL8 val63;REAL8 val64;REAL8 val65;REAL8 val66;REAL8 val67;REAL8 val68;REAL8 val69;REAL8 val70;REAL8 val71;REAL8 val72;REAL8 val73;REAL8 val74;REAL8 val75;REAL8 val76;REAL8 val77;REAL8 val78;REAL8 val79;REAL8 val80;REAL8 val81;REAL8 val82;REAL8 val83;REAL8 val84;REAL8 val85;REAL8 val86;REAL8 val87;REAL8 val88;REAL8 val89;REAL8 val90;REAL8 val91;REAL8 val92;REAL8 val93;REAL8 val94;REAL8 val95;REAL8 val96;REAL8 val97;REAL8 val98;REAL8 val99;REAL8 val100;
            INTEGER4 label;
        END;
        
        nastyrec nastyT(fldrec vr) := TRANSFORM
            SELF.id := vr.rowid;SELF.val1:=vr.vecds[1].value;SELF.val2:=vr.vecds[2].value;SELF.val3:=vr.vecds[3].value;SELF.val4:=vr.vecds[4].value;SELF.val5:=vr.vecds[5].value;SELF.val6:=vr.vecds[6].value;SELF.val7:=vr.vecds[7].value;SELF.val8:=vr.vecds[8].value;SELF.val9:=vr.vecds[9].value;SELF.val10:=vr.vecds[10].value;SELF.val11:=vr.vecds[11].value;SELF.val12:=vr.vecds[12].value;SELF.val13:=vr.vecds[13].value;SELF.val14:=vr.vecds[14].value;SELF.val15:=vr.vecds[15].value;SELF.val16:=vr.vecds[16].value;SELF.val17:=vr.vecds[17].value;SELF.val18:=vr.vecds[18].value;SELF.val19:=vr.vecds[19].value;SELF.val20:=vr.vecds[20].value;SELF.val21:=vr.vecds[21].value;SELF.val22:=vr.vecds[22].value;SELF.val23:=vr.vecds[23].value;SELF.val24:=vr.vecds[24].value;SELF.val25:=vr.vecds[25].value;SELF.val26:=vr.vecds[26].value;SELF.val27:=vr.vecds[27].value;SELF.val28:=vr.vecds[28].value;SELF.val29:=vr.vecds[29].value;SELF.val30:=vr.vecds[30].value;SELF.val31:=vr.vecds[31].value;SELF.val32:=vr.vecds[32].value;SELF.val33:=vr.vecds[33].value;SELF.val34:=vr.vecds[34].value;SELF.val35:=vr.vecds[35].value;SELF.val36:=vr.vecds[36].value;SELF.val37:=vr.vecds[37].value;SELF.val38:=vr.vecds[38].value;SELF.val39:=vr.vecds[39].value;SELF.val40:=vr.vecds[40].value;SELF.val41:=vr.vecds[41].value;SELF.val42:=vr.vecds[42].value;SELF.val43:=vr.vecds[43].value;SELF.val44:=vr.vecds[44].value;SELF.val45:=vr.vecds[45].value;SELF.val46:=vr.vecds[46].value;SELF.val47:=vr.vecds[47].value;SELF.val48:=vr.vecds[48].value;SELF.val49:=vr.vecds[49].value;SELF.val50:=vr.vecds[50].value;SELF.val51:=vr.vecds[51].value;SELF.val52:=vr.vecds[52].value;SELF.val53:=vr.vecds[53].value;SELF.val54:=vr.vecds[54].value;SELF.val55:=vr.vecds[55].value;SELF.val56:=vr.vecds[56].value;SELF.val57:=vr.vecds[57].value;SELF.val58:=vr.vecds[58].value;SELF.val59:=vr.vecds[59].value;SELF.val60:=vr.vecds[60].value;SELF.val61:=vr.vecds[61].value;SELF.val62:=vr.vecds[62].value;SELF.val63:=vr.vecds[63].value;SELF.val64:=vr.vecds[64].value;SELF.val65:=vr.vecds[65].value;SELF.val66:=vr.vecds[66].value;SELF.val67:=vr.vecds[67].value;SELF.val68:=vr.vecds[68].value;SELF.val69:=vr.vecds[69].value;SELF.val70:=vr.vecds[70].value;SELF.val71:=vr.vecds[71].value;SELF.val72:=vr.vecds[72].value;SELF.val73:=vr.vecds[73].value;SELF.val74:=vr.vecds[74].value;SELF.val75:=vr.vecds[75].value;SELF.val76:=vr.vecds[76].value;SELF.val77:=vr.vecds[77].value;SELF.val78:=vr.vecds[78].value;SELF.val79:=vr.vecds[79].value;SELF.val80:=vr.vecds[80].value;SELF.val81:=vr.vecds[81].value;SELF.val82:=vr.vecds[82].value;SELF.val83:=vr.vecds[83].value;SELF.val84:=vr.vecds[84].value;SELF.val85:=vr.vecds[85].value;SELF.val86:=vr.vecds[86].value;SELF.val87:=vr.vecds[87].value;SELF.val88:=vr.vecds[88].value;SELF.val89:=vr.vecds[89].value;SELF.val90:=vr.vecds[90].value;SELF.val91:=vr.vecds[91].value;SELF.val92:=vr.vecds[92].value;SELF.val93:=vr.vecds[93].value;SELF.val94:=vr.vecds[94].value;SELF.val95:=vr.vecds[95].value;SELF.val96:=vr.vecds[96].value;SELF.val97:=vr.vecds[97].value;SELF.val98:=vr.vecds[98].value;SELF.val99:=vr.vecds[99].value;SELF.val100:=vr.vecds[100].value;
            SELF.label := vr.label;
        END;
            
        input_tofield := PROJECT(vec_as_ds,nastyT(LEFT));

        numericrec := RECORD
            UNSIGNED id := input_tofield.id;
            REAL8 val1 := input_tofield.val1;
            REAL8 val2 := input_tofield.val2;
            REAL8 val3 := input_tofield.val3;
            REAL8 val4 := input_tofield.val4;
            REAL8 val5 := input_tofield.val5;
            REAL8 val6 := input_tofield.val6;
            REAL8 val7 := input_tofield.val7;
            REAL8 val8 := input_tofield.val8;
            REAL8 val9 := input_tofield.val9;
            REAL8 val10 := input_tofield.val10;
            REAL8 val11 := input_tofield.val11;
            REAL8 val12 := input_tofield.val12;
            REAL8 val13 := input_tofield.val13;
            REAL8 val14 := input_tofield.val14;
            REAL8 val15 := input_tofield.val15;
            REAL8 val16 := input_tofield.val16;
            REAL8 val17 := input_tofield.val17;
            REAL8 val18 := input_tofield.val18;
            REAL8 val19 := input_tofield.val19;
            REAL8 val20 := input_tofield.val20;
            REAL8 val21 := input_tofield.val21;
            REAL8 val22 := input_tofield.val22;
            REAL8 val23 := input_tofield.val23;
            REAL8 val24 := input_tofield.val24;
            REAL8 val25 := input_tofield.val25;
            REAL8 val26 := input_tofield.val26;
            REAL8 val27 := input_tofield.val27;
            REAL8 val28 := input_tofield.val28;
            REAL8 val29 := input_tofield.val29;
            REAL8 val30 := input_tofield.val30;
            REAL8 val31 := input_tofield.val31;
            REAL8 val32 := input_tofield.val32;
            REAL8 val33 := input_tofield.val33;
            REAL8 val34 := input_tofield.val34;
            REAL8 val35 := input_tofield.val35;
            REAL8 val36 := input_tofield.val36;
            REAL8 val37 := input_tofield.val37;
            REAL8 val38 := input_tofield.val38;
            REAL8 val39 := input_tofield.val39;
            REAL8 val40 := input_tofield.val40;
            REAL8 val41 := input_tofield.val41;
            REAL8 val42 := input_tofield.val42;
            REAL8 val43 := input_tofield.val43;
            REAL8 val44 := input_tofield.val44;
            REAL8 val45 := input_tofield.val45;
            REAL8 val46 := input_tofield.val46;
            REAL8 val47 := input_tofield.val47;
            REAL8 val48 := input_tofield.val48;
            REAL8 val49 := input_tofield.val49;
            REAL8 val50 := input_tofield.val50;
            REAL8 val51 := input_tofield.val51;
            REAL8 val52 := input_tofield.val52;
            REAL8 val53 := input_tofield.val53;
            REAL8 val54 := input_tofield.val54;
            REAL8 val55 := input_tofield.val55;
            REAL8 val56 := input_tofield.val56;
            REAL8 val57 := input_tofield.val57;
            REAL8 val58 := input_tofield.val58;
            REAL8 val59 := input_tofield.val59;
            REAL8 val60 := input_tofield.val60;
            REAL8 val61 := input_tofield.val61;
            REAL8 val62 := input_tofield.val62;
            REAL8 val63 := input_tofield.val63;
            REAL8 val64 := input_tofield.val64;
            REAL8 val65 := input_tofield.val65;
            REAL8 val66 := input_tofield.val66;
            REAL8 val67 := input_tofield.val67;
            REAL8 val68 := input_tofield.val68;
            REAL8 val69 := input_tofield.val69;
            REAL8 val70 := input_tofield.val70;
            REAL8 val71 := input_tofield.val71;
            REAL8 val72 := input_tofield.val72;
            REAL8 val73 := input_tofield.val73;
            REAL8 val74 := input_tofield.val74;
            REAL8 val75 := input_tofield.val75;
            REAL8 val76 := input_tofield.val76;
            REAL8 val77 := input_tofield.val77;
            REAL8 val78 := input_tofield.val78;
            REAL8 val79 := input_tofield.val79;
            REAL8 val80 := input_tofield.val80;
            REAL8 val81 := input_tofield.val81;
            REAL8 val82 := input_tofield.val82;
            REAL8 val83 := input_tofield.val83;
            REAL8 val84 := input_tofield.val84;
            REAL8 val85 := input_tofield.val85;
            REAL8 val86 := input_tofield.val86;
            REAL8 val87 := input_tofield.val87;
            REAL8 val88 := input_tofield.val88;
            REAL8 val89 := input_tofield.val89;
            REAL8 val90 := input_tofield.val90;
            REAL8 val91 := input_tofield.val91;
            REAL8 val92 := input_tofield.val92;
            REAL8 val93 := input_tofield.val93;
            REAL8 val94 := input_tofield.val94;
            REAL8 val95 := input_tofield.val95;
            REAL8 val96 := input_tofield.val96;
            REAL8 val97 := input_tofield.val97;
            REAL8 val98 := input_tofield.val98;
            REAL8 val99 := input_tofield.val99;
            REAL8 val100 := input_tofield.val100;
        END;

        input_tonumfield := TABLE(input_tofield,numericrec);

        ML_Core.ToField(input_tonumfield,X);

        Y := PROJECT(input_tofield,TRANSFORM(Types.DiscreteField,SELF.wi := 1,SELF.value := LEFT.label,SELF.id := LEFT.id,SELF.number := 1));
        
        result := MODULE
            EXPORT NUMF := X;
            EXPORT DSCF := Y;
        END;
        RETURN result;
    END;

    //FIXME: Add BLR parameters as arguments
    //for returning a BLR model from sentence vectors. deprecated
    //PARAMETERS:
    //
    // tr (dataset of type trainrec, contains the sentence vectors
    // to be trained on)
    // iters (max iterations for the binomial logistic regression
    // model training, default is 100. Increasing it increases model
    // training time and may increase accuracy as well as overfitting)
    //
    //INITIALIZED DATASETS:
    //
    // train_binlogreg() (returns a BLR model that can be used for classification)
    EXPORT train_binlogreg(DATASET(trainrec) tr,INTEGER iters = 100) := FUNCTION

        fieldform := getFields(tr);
        train_feats := fieldform.NUMF;
        train_label := fieldform.DSCF;

        blr := BinomialLogisticRegression(iters,.000000000001,LogisticRegression.Constants.default_ridge);
        mod := blr.getModel(train_feats,train_label);
        RETURN mod;
    END;
END;