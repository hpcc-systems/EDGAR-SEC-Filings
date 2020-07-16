IMPORT * FROM TextVectors.Types;
IMPORT std.System.Thorlib;
node := Thorlib.node();

oldweights := DATASET(WORKUNIT('W20200528-021727','Result 1'),Types.SliceExt);
OUTPUT(oldweights(nodeId = node AND sliceId =1)[1]);