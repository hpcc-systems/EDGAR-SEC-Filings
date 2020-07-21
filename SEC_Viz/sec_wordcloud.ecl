//contains word clouds
IMPORT Visualizer;
IMPORT * FROM SEC_Viz;
IMPORT STD;

EXPORT sec_wordcloud := MODULE
  EXPORT word_freqs(STRING tpath, STRING tform) := FUNCTION

    WordLayout := RECORD
      STRING word;
    END;

    ds := wordcloud_prep(tpath,tform);
    
    convrec := RECORD
        STRING word := ds.text;
    END;

    wordDS := TABLE(ds,convrec);

    WordLayout XF(WordLayout L, INTEGER C, INTEGER Cnt) := TRANSFORM
      WordStart := IF(C=1,1,STD.str.Find(L.word,' ',C-1)+1);
      WordEnd   := IF(C=Cnt,LENGTH(L.word),STD.str.Find(L.word,' ',C)-1);
      SELF.word := L.word[WordStart .. WordEnd];
    END;                  
    EachWord := NORMALIZE(wordDS,
                      STD.str.WordCount(LEFT.word),
                      XF(LEFT,COUNTER,STD.str.WordCount(LEFT.word)));

    WordCountLayout := RECORD
      EachWord.word;
      wordCount := COUNT(GROUP);
    END;

    wordCountTable := TABLE(EachWord, WordCountLayout, word);

    RETURN wordCountTable;
  END;
    
  EXPORT show := FUNCTION
    wcloud := Visualizer.Visualizer.TwoD.WordCloud('WordCloud',, 'Chart2D__test');
    RETURN wcloud;
  END;
END;