testvec := SET OF REAL8;

vecrec := RECORD
    testvec vec;
END;

testds := DATASET([{[1.2,3.8]},{[2.4,3.6]},{[-1.2,9.1]}],vecrec);


vecrec rollout(vecrec l,vecrec r) := TRANSFORM
    SELF.vec := l.vec + r.vec;
END;

out := ROLLUP(testds,TRUE,rollout(LEFT,RIGHT));

OUTPUT(out);