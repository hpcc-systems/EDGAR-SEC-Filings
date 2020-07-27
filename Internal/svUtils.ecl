IMPORT TextVectors as tv;

t_Vector := tv.Types.t_Vector;

EXPORT svUtils := MODULE
    //Multiplying vectors by a real number
    EXPORT t_Vector vecmult(t_Vector v,REAL8 x) := BEGINC++
        #body
        //size32_t N = lenV;
        size32_t N = lenV/sizeof(double);
        __lenResult = (size32_t) (N * sizeof(double));
        double *wout = (double*) rtlMalloc(__lenResult);
        __isAllResult = false;
        __result = (void *) wout;
        double *vv = (double *) v;
        double xx = (double) x;
        for (unsigned i = 0; i < N; i++)
        {
          wout[i] = vv[i] * xx;
        }
    ENDC++;

    //C++ function for adding t_Vector sets element-wise
    EXPORT t_Vector addvecs(t_Vector v1,t_Vector v2) := BEGINC++
        #body
        //size32_t N = lenV1;
        size32_t N = lenV1/sizeof(double);
        __lenResult = (size32_t) (N*sizeof(double));
        double *wout = (double *) rtlMalloc(__lenResult);
        __isAllResult = false;
        __result = (void *) wout;
        double *vv1 = (double *) v1;
        double *vv2 = (double *) v2;

        for (unsigned i = 0; i < N; i++)
        {
          wout[i] = vv1[i]+vv2[i];
        }
    ENDC++;
END;