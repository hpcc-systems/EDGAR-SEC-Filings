IMPORT * FROM SEC_2_Vec;
IMPORT * FROM SEC_2_Vec.sentiment;
IMPORT TextVectors AS tv;
IMPORT * FROM Types;
IMPORT * FROM EDGAR_Extract.Text_Tools;
IMPORT * FROM SEC_2_Vec.sentiment;

Sentence := tv.Types.Sentence;
TextMod := tv.Types.TextMod;

EXPORT sents_and_mod := FUNCTION
    path10k := '~ncf::edgarfilings::raw::labels_allsecs_all_10k';
    path10q := '~ncf::edgarfilings::raw::plainlabel_allsecs_all';

    plain := secvec_input_lbl(path10q,path10k);
    sv := tv.SentenceVectors();

    rawsents := PROJECT(plain,TRANSFORM(Sentence,SELF.sentId := LEFT.sentId,
                                            SELF.text := LEFT.text));

    mod := sv.getModel(rawsents);
    smod := mod(typ=2);

    trainrec make_tr_T(TextMod m) := TRANSFORM
        plainrow := plain(sentId=m.id)[1];
        SELF.label := plainrow.label;
        SELF.fname := plainrow.fname;
        SELF.id := m.id;
        SELF.text := m.text;
        SELF.vec := m.vec;
    END;

    tr := PROJECT(smod,make_tr_T(LEFT));

    result := MODULE
        EXPORT m := mod;
        EXPORT p := plain;
        EXPORT t := tr;
        EXPORT s := rawsents;
    END;

    RETURN result;
END;