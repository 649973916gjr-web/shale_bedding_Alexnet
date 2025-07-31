Recognition of shale bedding types based on AlexNet and transfer learning of elextrical borehole images
============
Yangiu Zhou,Jiarui Ge,Qixian Lin,Yanhui Liu,Jinzi Liu,DamingYang,Qinghua Zheng,Guangjin Wang,Xinyun Li,Jingning Bai
-----------
usage
-----------
**System Requirements**
The proper functioning of this software suite requires preliminary installation of the AlexNet convolutional neural network framework, which is available via MATLAB's Deep Learning Toolbox extension.    
**Usage Instructions:**   
1.Execute the **auto_picture_divided.m** program to process the **Original Full Borehole Image** as raw data, which will be segmented into multiple samples of identical dimensions. Following manual classification, the resulting samples will be stored in the **main image dataset**.   
2.Execute the **Train_Alexnet.m** script to perform local training of the modified AlexNet network by manually selecting samples from the **main image dataset**. Upon completion of training, users may examine the training accuracy, confusion matrix, and other relevant metrics. The trained network (netTransfer) should then be manually saved to local storage.   
3.Execute the **Predict_picture.m** program to load the locally pre-trained network and select target continuous borehole images for prediction. The program will generate an Excel spreadsheet containing all prediction results.     
   
**License and Acknowledgement**
---
The code and models in this repo are for research purposes only. Our code is bulit upon MATLAB.
