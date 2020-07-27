IMPORT STD;

tickrec := RECORD
    STRING tick;
END;

get_tick(STRING f) := FUNCTION
    parts := STD.Str.SplitWords(f,'_',FALSE);
    RETURN parts[1];
END;

sentrec := RECORD
    UNSIGNED8 sentId;
    STRING text;
    STRING label;
    STRING fname;
END;

spsents := DATASET(WORKUNIT('W20200702-195636','all_sentences_sandp'),sentrec);

ftickrec := RECORD
    STRING fname;
    STRING tick;
END;

ftickrec ftick_T(sentrec s) := TRANSFORM
    SELF.fname := s.fname;
    SELF.tick := get_tick(s.fname);
END;

fticks := PROJECT(spsents,ftick_T(LEFT));

ft_sort := SORT(fticks,tick);
ft_uniq := DEDUP(ft_sort,fname);

OUTPUT(ft_uniq,ALL);