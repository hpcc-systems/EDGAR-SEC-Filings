IMPORT * FROM SEC_Viz;
IMPORT Visualizer;

path := '~ncf::edgarfilings::raw::tech10qs_medium';

ds := OUTPUT(SORT(sec_wordcloud.word_freqs(path,'SEC'),-wordcount)[25..50],NAMED('wordcloud'));
ds;
//wcloud := Visualizer.TwoD.WordCloud('WordCloud',, 'wordcloud');
//wcloud;
viz_bubble := Visualizer.Visualizer.TwoD.Bubble('bubble',,'wordcloud');
viz_bubble;
// viz_pie := Visualizer.TwoD.Pie('pie',,'wordcloud');
// viz_pie;