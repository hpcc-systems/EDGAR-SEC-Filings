/*##############################################################################
## HPCC SYSTEMS software Copyright (C) 2019 HPCC Systems.  All rights reserved.
############################################################################## */
IMPORT TextVectors.Types;
IMPORT std.System.Thorlib;

wIndex := Types.wIndex;
Slice := Types.Slice;
CSlice := Types.CSlice;
SliceExt := Types.SliceExt; // Extended Slice includes a node id
WordInfo := Types.WordInfo;
t_Vector := Types.t_Vector;

nNodes := Thorlib.nodes();
node := Thorlib.node();
maxSliceSize := 260000 / 4; // Weights per slice -- 260,000 keeps us under the block size
MaxU4 := 4294967295; // Maximum value of UNSIGNED4

// Get the platform version information
majorVersion := __ECL_VERSION_MAJOR__;
minorVersion := __ECL_VERSION_MINOR__;
// Set flag to indicate that we're at 7.2 or above so we can use DISTRIBUTE(ds, ALL).
BOOLEAN isGE7_2 := (majorVersion > 7 OR (majorVersion = 7 AND minorVersion >= 2));


/**
  * Module to perform calculations to manage the weights, and their storage as
  * slices.
  * <p>Weights are stored in fixed size slices for ease of distribution and management.
  *
  * Currently only supports 3 layer Neural Network weights as used
  * in word vectorization.  Will need to be extended to handle a general
  * Neural Network shape.
  *
  * @param shape The number of neurons in each layer of the Neural Network.
  *        For example, [100, 10, 200] describes a neural network with
  *        100 neurons in the input layer, 10 in the hidden layer, and 200
  *        in the output layer.
  */
EXPORT Weights_modified(SET OF INTEGER4 shape) := MODULE
  SHARED COMPRESS := FALSE;
  SHARED nLayers := COUNT(shape);

  SHARED nLayerWeights := [shape[1] * shape[2], shape[2] * shape[3]];

  /**
    * The total number of weights in the network
    */
  EXPORT nWeights := nLayerWeights[1] + nLayerWeights[2];

  /**
    * Convert the compound index: (layer, j, i) to a contiguous flat index into
    * a set of weights.
    */
  EXPORT UNSIGNED4 toFlatIndex(UNSIGNED2 l, UNSIGNED4 j, UNSIGNED4 i) := FUNCTION
    indx := (l-1) * nLayerWeights[2] + shape[l+1] * (j-1) + (i-1) + 1;
    RETURN indx;
  END;
  /**
    * Convert a flat index into a list of weights into a compound index into the weights
    * of the neural network: (layer, j, i).
    */
  EXPORT wIndex fromFlatIndex(UNSIGNED4 indx) := FUNCTION
    l := (indx-1) DIV nLayerWeights[2] + 1;
    lIndx := indx - ((l-1) * nLayerWeights[2]);
    j := (lIndx-1) DIV (shape[l+1]) + 1;
    i := lIndx - ((j-1) * shape[l+1]);
    RETURN ROW({l, j, i}, wIndex);
  END;

  SHARED maxSliceSize := MIN([ROUNDUP(nWeights / nNodes), maxSliceSize]);

  SHARED minSlices := ROUNDUP(nWeights / maxSliceSize);

  /**
    * The number of slices needed for each node
    */
  EXPORT slicesPerNode := ROUNDUP(minSlices / nNodes);
  /**
    * The total number of slices used to hold the weights.
    */
  EXPORT nSlices := slicesPerNode * nNodes;
  /**
    * The number of weights in each slice.
    */
  EXPORT sliceSize := ROUNDUP(nWeights / nSlices);
  /**
    * The number of slots to hold weights across all slices.  This may be different
    * from nWeights because nWeights does not always divide exactly into nSlices.
    */
  EXPORT nWeightSlots := sliceSize * nSlices;

  /**
    * Initialize a single slice's weights randomly.
    */
  SHARED t_Vector initWeightsVec(UNSIGNED4 n, REAL8 maxweight, UNSIGNED4 seed) := EMBED(C++)
    #include <stdlib.h>
    #include <stdint.h>
    #include <time.h>
    #body
    __lenResult = n * sizeof(double);
    __isAllResult = false;
    double* result = (double*) rtlMalloc(__lenResult);
    __result = (void*) result;
    srand(seed);
    // Assign a random number between -maxweight and maxweight.
    for (uint32_t i=0; i<n; i++) {
      result[i] = maxweight * 2 * (double)rand() / (double)(RAND_MAX) - maxweight;
    }
  ENDEMBED;


  SHARED t_Vector custWeightsVec(UNSIGNED4 n, t_Vector currweight) := EMBED(C++)//, REAL8 maxweight, UNSIGNED4 seed) := EMBED(C++)
    #include <stdlib.h>
    #include <stdint.h>
    #include <time.h>
    #body
    __lenResult = n * sizeof(double);
    __isAllResult = false;
    double *result = (double*) rtlMalloc(__lenResult);
    //float* cw = (float*) currweight;
    //__result = (void*) result;
    __result = (void *) result;
    //srand(seed);
    // Assign a random number between -maxweight and maxweight.
    double *cw = (double *) currweight;
    
    for (uint32_t i=0; i<n; i++) {
      result[i] = cw[i];
      //result[i] = maxweight * 2 * (double)rand() / (double)(RAND_MAX) - maxweight;
    }
  ENDEMBED;
  /**
    * Return an initial set of weight slices with weights set to random values.
    */
  EXPORT DATASET(slice) initWeights := FUNCTION
    slice makeSlice(UNSIGNED c) := TRANSFORM
      SELF.sliceId := IF(node+1 <= nNodes, (node + 1) + ((c-1) * nNodes), SKIP);
      SELF.weights := initWeightsVec(sliceSize, 1/shape[2], RANDOM());
    END;
    // Create each slice
    slices := DATASET(slicesPerNode, makeSlice(COUNTER), LOCAL);
    slicesD := DISTRIBUTE(slices, sliceId);
    RETURN slicesD;
  END;



  EXPORT DATASET(slice) init_customWeights (DATASET(SliceExt) customweights):= FUNCTION

    slice makeSlice(UNSIGNED c,DATASET(SliceExt) lr) := TRANSFORM
      SELF.sliceId := IF(node+1 <= nNodes, (node + 1) + ((c-1) * nNodes), SKIP);
      //SELF.weights := customweights;
      SELF.weights := custWeightsVec(sliceSize, lr[c].weights);
    END;
    // Create each slice
    slices := DATASET(slicesPerNode, makeSlice(COUNTER, customweights), LOCAL);
    slicesD := DISTRIBUTE(slices, sliceId);
    RETURN slicesD;
  END;
  /**
    * Copy weights to all nodes and assign the node id to the copy on each node.
    * <p>If running on 7.2 or greater, use the DISTRIBUTE(.., ALL) facility.
    * Otherwise, use NORMALIZE to make copies of each and assign nodeId, then
    * DISTRIBUTE by nodeId.
    */
  EXPORT DATASET(SliceExt) distributeAllSlices(DATASET(SliceExt) slices) := FUNCTION
    useAll := isGE7_2;
    //useAll := FALSE;
    #IF (useAll = FALSE)
      // Use legacy method -- NORMALIZE then DISTRIBUTE
      copied_noall := NORMALIZE(slices, nNodes, TRANSFORM(sliceExt, SELF.nodeId := COUNTER - 1,
                                                     SELF := LEFT));
      outSlices := DISTRIBUTE(copied_noall, nodeId);
    #ELSE
      // Use DISTRIBUTE(ds, ALL).  Should be more efficient
      copied_all := DISTRIBUTE(slices, ALL);
      // Fixup the nodeId attribute on the local node's copy.
			// Use NOCOMBINE to prevent the project from being combined with the DISTRIBUTE, causing
			// the assignment to occur on the wrong nodes.
      outSlices := PROJECT(NOCOMBINE(copied_all), TRANSFORM(RECORDOF(LEFT), SELF.nodeId := node, SELF := LEFT), LOCAL);
    #END
    outSlicesS := SORT(outSlices, sliceId, LOCAL);
    RETURN outSlicesS;
  END;
  /**
    * Make Extended Weights.  Return a dataset of weight slices that have been
    * replicated to all nodes and converted to SliceExt record type that includes
    * a node id.
    */
  EXPORT DATASET(SliceExt) toSliceExt(DATASET(Slice) weights) := FUNCTION
    // Transform slices to extSlices with initial values for the bookkeeping attributes.
    extWts := PROJECT(weights, TRANSFORM(sliceExt, SELF.nodeId := 0,
                                                    SELF.loss := 0,
                                                    SELF.minLoss := MaxU4,
                                                    SELF.minEpoch := 0,
                                                    SELF.maxNoProg := 0,
                                                    SELF.batchPos := 1,
                                                    SELF := LEFT), LOCAL);
    // Copy the weights to all nodes (use DISTRIBUTE(..., ALL) when available)
    repWeights := distributeAllSlices(extWts);
    weightsS := SORT(repWeights, sliceId, LOCAL);
  RETURN weightsS;
  END;

  /**
    * Take a set of Extended Weight slices (i.e. replicated to all nodes) and
    * return a dataset of Weight slices that are distributed by sliceId.
    * The duplicated copies are filtered out except on the node that owns each
    * slice.
    */
  EXPORT DATASET(Slice) fromSliceExt(DATASET(SliceExt) extWeights) := FUNCTION
    // Deduplicate the extended slices and leave them distributed by sliceId
    weightsDedup := PROJECT(extWeights(sliceId % nNodes = node), Slice);
    RETURN weightsDedup;
  END;

  /**
    * Convert a dataset of replicated slices (SliceExt) into a single SliceExt
    * replicated on each node and containing one linear array (i.e. SET) of
    * weights.
    */
  EXPORT SliceExt slices2Linear(DATASET(SliceExt) slices) := FUNCTION
    // Concatenate all slices to form a LOCAL set of all weights.
    // Note that weights, at this point, are copied to all nodes.
    // Slices should always be sorted by SliceId.
    SliceExt concatSlices(SliceExt l, SliceExt r) := TRANSFORM
      SELF.nodeId := node;
      SELF.sliceId := 1;
      SELF.loss := l.loss;
      SELF.weights := l.weights + r.weights;
      SELF := l;
    END;
    SliceExt linear := ROLLUP(slices, concatSlices(LEFT, RIGHT), LOCAL)[1];
    RETURN linear;
  END;
  /**
    * Compress a set of weights (assumed to be sparse) by converting to
    * a sparse representation [<index><weight>...] packed into a DATA field.
    */
  EXPORT DATA compressOne(t_Vector wts, UNSIGNED4 slicesize) := EMBED(C++)
    struct cdat1
    {
      uint32_t indx;
      double weight;
    };
    #body
    double * weights = (double *)wts;
    uint32_t i;
    uint32_t out = 0;
    cdat1 * cweights = (cdat1 *) rtlMalloc(slicesize * sizeof(cdat));
    for (i = 0; i < slicesize; i++)
    {
      if (fabs(weights[i]) > 0.000000001)
      {
        cweights[out].indx = i;
        cweights[out++].weight = weights[i];
      }
    }
    uint32_t outSize = out * sizeof(cdat1);
    __lenResult = outSize;
    cdat1 * outBuff = (cdat1 *) rtlMalloc(outSize);
    for (i = 0; i < out; i++)
    {
      outBuff[i] = cweights[i];
    }
    delete cweights;
    __result = (void*) outBuff;
  ENDEMBED;
  /**
    * Decompress a set of compressed weights in sparse format (i.e. [<index><weight>...] into a dense
    * set of weights.
    */
  EXPORT t_Vector decompressOne(DATA cwts, UNSIGNED4 slicesize) := EMBED(C++)
    #body
    cdat * cweights = (cdat *) cwts;
    uint32_t inCnt = lenCwts / sizeof(cdat);
    uint32_t i;
    uint32_t outSize = slicesize * sizeof(double);
    double * outBuff = (double *)rtlMalloc(outSize);
    for (i = 0; i < slicesize; i++)
      outBuff[i] = 0.0;
    for (i = 0; i < inCnt; i++)
    {
      cdat c = cweights[i];
      outBuff[c.indx] = c.weight;
    }
    __isAllResult = false;
    __lenResult = outSize;
    __result = (void *) outBuff;
  ENDEMBED;
  /**
    * Compress a set of extended slices (e.g. SliceExt) into CSlice format.
    */
  EXPORT DATASET(CSlice) compressWeights(DATASET(SliceExt) slices) := FUNCTION
    CSlice compress(SliceExt s) := TRANSFORM
      SELF.cweights := compressOne(s.weights, sliceSize);
      SELF := s;
    END;
    outSlices := PROJECT(slices, compress(LEFT), LOCAL);
    RETURN outSlices;
  END;
  /**
    * Decompress a set of compressed slices into the native extended slice format.
    */
  EXPORT DATASET(SliceExt) decompressWeights(DATASET(CSlice) cslices) := FUNCTION
    SliceExt decompress(CSlice cs) := TRANSFORM
      SELF.weights := decompressOne(cs.cweights, sliceSize);
      SELF := cs;
    END;
    outSlices := PROJECT(cslices, decompress(LEFT), LOCAL);
    RETURN outSlices;
  END;
END;