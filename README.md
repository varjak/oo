## oo

oo is an experimental MATLAB package for processing EEG data from multiple files. It eases the loading and processing of a large number of files, by asking the user which words to find in a dataset, computing all its combinations, and loading the data from the corresponding files into a struct array (each row representing one file). Then, every function can be applied to the struct array, which will l[oo]p through it and process each row at a time.

It was developed to evaluate the reduction of MRI-artifacts on an EEG by the online reduction tool found in:
https://github.com/LaSEEB/NeuXus

To use it, download it and in your script, add the path to the package:
```
addpath('path_to_oo/oo')
```
Then, use the package namespace to call its functions. For example:
```
data = oo.io.load('set','Dataset-1','fol','Preprocessed/','sub',[1,2,3],'ses',["session-1","session-2"],'run',[1,2]);
```
