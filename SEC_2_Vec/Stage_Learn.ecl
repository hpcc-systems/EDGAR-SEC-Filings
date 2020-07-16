IMPORT * FROM EDGAR_Extract;
IMPORT * FROM EDGAR_Extract.Text_Tools;
IMPORT TextVectors AS tv;
IMPORT * FROM tv;
IMPORT tv.Types;
IMPORT SEC_2_Vec;
IMPORT * FROM SEC_2_Vec;
Sentence := Types.Sentence;
t_Vector := Types.t_Vector;
SliceExt := Types.SliceExt;

//#OPTION('outputLimit',25);
EXPORT Stage_Learn := MODULE
  EXPORT Stage1(STRING filePath) := FUNCTION
  //path := '~ncf::edgarfilings::raw::tech10qs_group';

    rawsents := secvec_input(filePath);
    rawrec   := RECORD
        UNSIGNED8 sentId := rawsents.sentId;
        STRING    text   := rawsents.text;
    END;
    trainSentences := TABLE(rawsents,rawrec);

    sv := SEC_2_Vec.SentenceVectors_modified();

    stage1weights := sv.GetModel_finalweights(trainSentences);

    RETURN stage1weights;
  END;
  EXPORT FinalStage(STRING trainPath, STRING trainform, STRING corpPath) := FUNCTION
    

    ptext_extr(STRING tPath) := FUNCTION
      corp := DATASET(tPath,STRING);
      
      rec := RECORD
        STRING text := corp.line;
      END;
      corp_concat := Concat(TABLE(corp,rec));
      corp_sents  := sep_sents(corp_concat);
      sentrec := RECORD
        UNSIGNED8 sentId := corp_sents.sentId;
        STRING    text   := corp_sents.text;
      END;
      
      outsents := TABLE(corp_sents,sentrec);

      RETURN outsents;
    END;

    rs(STRING tpath, STRING tform) := FUNCTION
      out := CASE(tform,
           'SEC' => secvec_input(tpath),
           'ptext' => ptext_extr(tpath));
      RETURN out;
    END;    

    rawsents := rs(trainPath, trainform);

    rawrec := RECORD
        UNSIGNED8 sentId := rawsents.sentId;
        STRING    text   := rawsents.text;
    END;
    
    trainSentences := TABLE(rawsents,rawrec);

    sv := SentenceVectors_modified();

    corpweights := Stage1(corpPath);

    finalstage := sv.GetModel_custom(trainSentences, corpweights);

    RETURN finalstage;    
  
  END;

END;