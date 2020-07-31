IMPORT Text_Tools FROM EDGAR_Extract AS tt;
IMPORT secvec_input FROM SEC_2_Vec;

//takes a logical file path 'trainPath' and extracts
//and formats the text field for use in the wordcloud
//method. the 'trainform' parameter expects the string
//'SEC' if the input file is a BLOB of XBRL files, and
//any other value for 'trainform' will currently treat
//input data as a csv with fields sentId,text

EXPORT wordcloud_prep(STRING trainPath, STRING trainform) := FUNCTION
    ptext_extr(STRING tPath) := FUNCTION
      corp := DATASET(tPath,STRING);
      
      rec := RECORD
        STRING text := corp.line;
      END;
      corp_concat := tt.Concat(TABLE(corp,rec));
      corp_sents  := tt.sep_sents(corp_concat);
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

    rawsents := rs(trainPath,trainform);

    rawrec := RECORD
        UNSIGNED8 sentId := rawsents.sentId;
        STRING    text   := rawsents.text;
    END;
    
    trainSentences := TABLE(rawsents,rawrec);

    RETURN trainSentences;
END;